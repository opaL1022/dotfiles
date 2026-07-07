// Launcher —「從天空降下」的 app 啟動器,取代 wofi。
// Super+D → `ags toggle launcher`。搜尋框 + fuzzy app 清單;Enter 開頂項、點擊開、Esc 關。
import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { createState, For } from "ags"
import AstalApps from "gi://AstalApps"

const apps = new AstalApps.Apps()

export default function Launcher(gdkmonitor: Gdk.Monitor) {
  const { TOP } = Astal.WindowAnchor
  const [search, setSearch] = createState("")
  const results = search.as((t) => apps.fuzzy_query(t).slice(0, 8))

  function hide() {
    setSearch("")
    app.get_window("launcher")?.set_visible(false)
  }
  function launch(a: AstalApps.Application) {
    a.launch()
    hide()
  }

  const entry = (
    <entry
      class="launcher-entry"
      placeholderText="召喚…"
      primaryIconName="system-search-symbolic"
      onNotifyText={(self: Gtk.Entry) => setSearch(self.text)}
      onActivate={() => {
        const r = apps.fuzzy_query(search.get())[0]
        if (r) launch(r)
      }}
    />
  ) as Gtk.Entry

  const win = (
    <window
      visible={false}
      name="launcher"
      class="Launcher"
      namespace="empty-sky-launcher"
      gdkmonitor={gdkmonitor}
      layer={Astal.Layer.OVERLAY}
      keymode={Astal.Keymode.EXCLUSIVE}
      anchor={TOP}
      marginTop={90}
      application={app}
    >
      <box class="launcher-box" orientation={Gtk.Orientation.VERTICAL}>
        {entry}
        <box class="launcher-list" orientation={Gtk.Orientation.VERTICAL}>
          <For each={results}>
            {(a: AstalApps.Application) => (
              <button class="launcher-item" onClicked={() => launch(a)}>
                <box orientation={Gtk.Orientation.HORIZONTAL} spacing={12}>
                  <image iconName={a.iconName} pixelSize={30} />
                  <label label={a.name} halign={Gtk.Align.START} />
                </box>
              </button>
            )}
          </For>
        </box>
      </box>
    </window>
  ) as Astal.Window

  // Esc 關(用 EventControllerKey,window 沒有直接的 key 事件 prop)
  const keyctl = new Gtk.EventControllerKey()
  keyctl.connect("key-pressed", (_ctl, keyval: number) => {
    if (keyval === Gdk.KEY_Escape) { hide(); return true }
    return false
  })
  win.add_controller(keyctl)

  // 顯示時清空搜尋 + 聚焦輸入框
  win.connect("notify::visible", () => {
    if (win.visible) { entry.set_text(""); entry.grab_focus() }
  })

  return win
}
