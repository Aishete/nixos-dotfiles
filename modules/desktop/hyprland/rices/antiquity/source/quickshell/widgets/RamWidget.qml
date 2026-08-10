import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell.Wayland
import Quickshell.Io
import ".."

Rectangle {
  id: root
  color: "transparent"
  width: ramText.implicitWidth + 12
  height: parent.height

  Text {
    id: ramText
    anchors.centerIn: parent
    text: "RAM " + (ramProc.running ? "" : ramOut)
    color: Config.colors.text
    font.pixelSize: 11
    font.family: fontMonaco.name
  }

  Process {
    id: ramProc
    running: true
    command: ["sh", "-c", "free -m | awk '/^Mem:/ {printf \"%d/%dMB\", $3, $2}'"]
    stdout: SplitParser { onRead: (out) => { ramOut = out; } }
  }
  property string ramOut: ""

  // Process runs its command ONCE at startup; re-run every 5s so RAM
  // usage stays live.
  Timer {
    interval: 5 * 1000
    running: true
    repeat: true
    onTriggered: {
      ramProc.running = false;
      ramProc.running = true;
    }
  }
}
