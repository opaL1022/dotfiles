#!/usr/bin/env python3
"""A small retro iPod-like MPRIS controller for the Waybar media module."""

import argparse
import json
import os
import signal
import subprocess
import sys
import threading
import time

import gi

gi.require_version("Gdk", "3.0")
gi.require_version("Gtk", "3.0")
from gi.repository import Gdk, GLib, Gtk  # noqa: E402


PLAYER = ("-p", "spotify,mpd,%any")
PIDFILE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "retro-media-ipod.pid")
DURATION_CACHE_FILE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "retro-media-durations.json")
SEPARATOR = "\x1f"


def playerctl(*arguments):
    """Run playerctl quietly and return stripped stdout, or an empty string."""
    result = subprocess.run(
        ("playerctl", *PLAYER, *arguments),
        check=False,
        capture_output=True,
        text=True,
    )
    return result.stdout.strip() if result.returncode == 0 else ""


def shared_duration(track_key):
    try:
        with open(DURATION_CACHE_FILE, encoding="utf-8") as handle:
            durations = json.load(handle)
        return float(durations.get(SEPARATOR.join(track_key), 0))
    except (FileNotFoundError, json.JSONDecodeError, TypeError, ValueError):
        return 0.0


def active_pid():
    try:
        with open(PIDFILE, encoding="utf-8") as handle:
            pid = int(handle.read().strip())
        os.kill(pid, 0)
        return pid
    except (FileNotFoundError, ProcessLookupError, PermissionError, ValueError):
        return None


def toggle_existing_window():
    pid = active_pid()
    if pid:
        os.kill(pid, signal.SIGTERM)
        try:
            os.unlink(PIDFILE)
        except FileNotFoundError:
            pass
        return True
    try:
        os.unlink(PIDFILE)
    except FileNotFoundError:
        pass
    return False


def reserve_pidfile():
    try:
        descriptor = os.open(PIDFILE, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o600)
    except FileExistsError:
        # A second rapid click is a toggle request, even before GTK has drawn.
        if toggle_existing_window():
            return False
        return reserve_pidfile()
    with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
        handle.write(str(os.getpid()))
    return True


class RetroMediaIpad(Gtk.Window):
    def __init__(self):
        super().__init__(title="RETRO MEDIA")
        self.set_default_size(390, 486)
        self.set_resizable(False)
        self.set_position(Gtk.WindowPosition.CENTER)
        self.set_type_hint(Gdk.WindowTypeHint.DIALOG)
        self.connect("destroy", self.quit)
        self.connect("key-press-event", self.handle_key_press)
        self.track_key = None
        self.player_status = "Stopped"
        self.last_reported_position = None
        self.position_anchor = 0.0
        self.position_anchor_at = time.monotonic()
        self.duration = 0.0
        self.duration_cache = {}
        self.follow_process = None

        self.install_css()
        self.build_ui()
        self.start_metadata_watcher()
        self.refresh()
        GLib.timeout_add_seconds(1, self.refresh)
        GLib.timeout_add(250, self.tick_progress)

    def install_css(self):
        css = b'''
            window { background: #d9caba; color: #3e3d38; }
            #shell { border: 3px solid #3e3d38; padding: 15px; }
            #heading { font-family: monospace; font-weight: bold; font-size: 15px; letter-spacing: 2px; }
            #screen { background: #b9c7a0; border: 3px inset #756b5f; padding: 13px; min-height: 205px; }
            #screen-title { font-family: monospace; font-weight: bold; font-size: 19px; }
            #screen-detail { font-family: monospace; font-size: 12px; }
            #art { font-family: monospace; font-size: 70px; font-weight: bold; color: #3d5a72; }
            progressbar trough { min-height: 10px; background: #f0e2d3; border: 2px solid #756b5f; }
            progressbar progress { background: #3d5a72; }
            button { min-height: 38px; border: 3px outset #f0e2d3; border-radius: 0; background: #d9caba; color: #3e3d38; font-family: monospace; font-weight: bold; }
            button:active { border-style: inset; background: #b9c7a0; }
            scale trough { min-height: 8px; background: #f0e2d3; border: 2px solid #756b5f; }
            scale slider { min-width: 18px; min-height: 18px; border: 2px outset #f0e2d3; border-radius: 0; background: #3d5a72; }
            #footer { font-family: monospace; font-size: 11px; }
        '''
        provider = Gtk.CssProvider()
        provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(), provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

    @staticmethod
    def label(text, name=None, xalign=0.0):
        widget = Gtk.Label(label=text, xalign=xalign)
        widget.set_line_wrap(True)
        if name:
            widget.set_name(name)
        return widget

    def build_ui(self):
        shell = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        shell.set_name("shell")
        self.add(shell)
        shell.pack_start(self.label("■  RETRO MEDIA PLAYER  ■", "heading", 0.5), False, False, 0)

        screen = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=7)
        screen.set_name("screen")
        shell.pack_start(screen, True, True, 0)
        screen.pack_start(self.label("♫", "art", 0.5), False, False, 0)
        self.status = self.label("WAITING FOR PLAYER", "screen-title", 0.5)
        screen.pack_start(self.status, False, False, 0)
        self.artist = self.label("Start Spotify, MPD, or another MPRIS player", "screen-detail", 0.5)
        screen.pack_start(self.artist, False, False, 0)
        self.album = self.label("", "screen-detail", 0.5)
        screen.pack_start(self.album, False, False, 0)
        self.progress = Gtk.ProgressBar()
        screen.pack_start(self.progress, False, False, 4)
        self.time = self.label("--:-- / --:--", "screen-detail", 0.5)
        screen.pack_start(self.time, False, False, 0)

        controls = Gtk.Box(homogeneous=True, spacing=7)
        shell.pack_start(controls, False, False, 0)
        controls.pack_start(self.control("|<<", "previous"), True, True, 0)
        self.play_button = self.control("PLAY", "play-pause")
        controls.pack_start(self.play_button, True, True, 0)
        controls.pack_start(self.control(">>|", "next"), True, True, 0)

        volume = Gtk.Box(spacing=9)
        shell.pack_start(volume, False, False, 0)
        volume.pack_start(self.label("VOL", "footer"), False, False, 0)
        self.volume = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        self.volume.set_draw_value(False)
        self.volume.connect("value-changed", self.set_volume)
        volume.pack_start(self.volume, True, True, 0)
        shell.pack_start(self.label("LEFT CLICK AGAIN TO CLOSE", "footer", 0.5), False, False, 0)

    def control(self, label, command):
        button = Gtk.Button(label=label)
        button.connect("clicked", lambda _button: self.command(command))
        return button

    def handle_key_press(self, _window, event):
        if event.keyval == Gdk.KEY_Escape:
            self.destroy()
            return True
        return False

    def command(self, command):
        playerctl(command)
        self.refresh()

    @staticmethod
    def format_time(seconds):
        if seconds is None or seconds < 0:
            return "--:--"
        minutes, seconds = divmod(int(seconds), 60)
        return f"{minutes}:{seconds:02d}"

    def set_volume(self, slider):
        if getattr(self, "setting_volume", False):
            return
        playerctl("volume", f"{slider.get_value() / 100:.2f}")

    def start_metadata_watcher(self):
        """Cache transient MPRIS lengths which Firefox clears after switching media."""
        def watch():
            try:
                self.follow_process = subprocess.Popen(
                    (
                        "playerctl", *PLAYER, "metadata", "--follow", "--format",
                        "{{artist}}\x1f{{title}}\x1f{{album}}\x1f{{mpris:length}}",
                    ),
                    stdout=subprocess.PIPE,
                    stderr=subprocess.DEVNULL,
                    text=True,
                    bufsize=1,
                )
                assert self.follow_process.stdout is not None
                for line in self.follow_process.stdout:
                    artist, title, album, length = (line.strip().split(SEPARATOR) + [""] * 4)[:4]
                    try:
                        duration = float(length) / 1_000_000
                    except ValueError:
                        continue
                    if duration > 0:
                        self.duration_cache[(artist, title, album)] = duration
            except OSError:
                pass

        threading.Thread(target=watch, name="retro-media-metadata", daemon=True).start()

    def displayed_position(self):
        if self.player_status == "Playing":
            elapsed = time.monotonic() - self.position_anchor_at
            position = self.position_anchor + elapsed
            return min(position, self.duration) if self.duration else position
        return self.position_anchor

    def tick_progress(self):
        position = self.displayed_position()
        if self.duration:
            self.progress.set_fraction(min(position / self.duration, 1))
        elif self.player_status == "Playing":
            self.progress.pulse()
        else:
            self.progress.set_fraction(0)
        self.time.set_text(f"{self.format_time(position)} / {self.format_time(self.duration)}")
        return True

    def refresh(self):
        metadata = playerctl(
            "metadata",
            "--format",
            "{{status}}\x1f{{artist}}\x1f{{title}}\x1f{{album}}\x1f{{mpris:length}}",
        )
        if not metadata:
            self.status.set_text("WAITING FOR PLAYER")
            self.artist.set_text("Start Spotify, MPD, or another MPRIS player")
            self.album.set_text("")
            self.progress.set_fraction(0)
            self.time.set_text("--:-- / --:--")
            self.play_button.set_label("PLAY")
            self.track_key = None
            self.player_status = "Stopped"
            self.last_reported_position = None
            self.position_anchor = 0.0
            self.duration = 0.0
            return True

        status, artist, title, album, length = (metadata.split(SEPARATOR) + [""] * 5)[:5]
        track_key = (artist, title, album)
        position_text = playerctl("position")
        try:
            reported_position = float(position_text)
            position = reported_position
        except ValueError:
            reported_position = None
            position = 0
        try:
            reported_duration = float(length) / 1_000_000
        except ValueError:
            reported_duration = 0
        if reported_duration > 0:
            self.duration_cache[track_key] = reported_duration
        duration = self.duration_cache.get(track_key, shared_duration(track_key))
        now = time.monotonic()
        unchanged_report = (
            track_key == self.track_key
            and status == "Playing"
            and self.player_status == "Playing"
            and self.last_reported_position is not None
            and abs(position - self.last_reported_position) < 0.25
        )
        # Some players (notably browser MPRIS integrations) only publish a new
        # Position when playback state changes.  Keep time moving locally while
        # their reported position is unchanged; a real seek or fresh position
        # update resets this anchor on the next poll.
        if unchanged_report:
            position = self.displayed_position()
        self.track_key = track_key
        self.player_status = status
        self.last_reported_position = reported_position
        self.position_anchor = position
        self.position_anchor_at = now
        self.duration = duration
        self.status.set_text(title or "UNTITLED")
        self.artist.set_text(artist or "UNKNOWN ARTIST")
        self.album.set_text(album or "")
        self.tick_progress()
        self.play_button.set_label("PAUSE" if status == "Playing" else "PLAY")

        volume = playerctl("volume")
        try:
            self.setting_volume = True
            self.volume.set_value(float(volume) * 100)
        except ValueError:
            pass
        finally:
            self.setting_volume = False
        return True

    @staticmethod
    def quit(*_args):
        window = _args[0] if _args else None
        process = getattr(window, "follow_process", None)
        if process and process.poll() is None:
            process.terminate()
        try:
            os.unlink(PIDFILE)
        except FileNotFoundError:
            pass
        Gtk.main_quit()


def main():
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("--toggle", action="store_true")
    arguments = parser.parse_args()
    if arguments.toggle and toggle_existing_window():
        return
    if not reserve_pidfile():
        return

    window = RetroMediaIpad()
    window.show_all()
    Gtk.main()


if __name__ == "__main__":
    main()
