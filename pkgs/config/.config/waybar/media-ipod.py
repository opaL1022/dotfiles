#!/usr/bin/env python3
"""A small retro iPod-like MPRIS controller for the Waybar media module."""

import argparse
import os
import signal
import subprocess
import sys

import gi

gi.require_version("Gdk", "3.0")
gi.require_version("Gtk", "3.0")
from gi.repository import Gdk, GLib, Gtk  # noqa: E402


PLAYER = ("-p", "spotify,mpd,%any")
PIDFILE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "retro-media-ipod.pid")
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

        self.install_css()
        self.build_ui()
        self.refresh()
        GLib.timeout_add_seconds(1, self.refresh)

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
            return True

        status, artist, title, album, length = (metadata.split(SEPARATOR) + [""] * 5)[:5]
        position_text = playerctl("position")
        try:
            position = float(position_text)
            duration = float(length) / 1_000_000
        except ValueError:
            position, duration = 0, 0
        self.status.set_text(title or "UNTITLED")
        self.artist.set_text(artist or "UNKNOWN ARTIST")
        self.album.set_text(album or "")
        self.progress.set_fraction(min(position / duration, 1) if duration else 0)
        self.time.set_text(f"{self.format_time(position)} / {self.format_time(duration)}")
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
