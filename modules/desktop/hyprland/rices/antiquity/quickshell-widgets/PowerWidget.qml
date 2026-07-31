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
  width: powText.implicitWidth + 12
  height: parent.height

  Text {
    id: powText
    anchors.centerIn: parent
    text: powOut
    color: Config.colors.text
    font.pixelSize: 11
    font.family: fontMonaco.name
  }

  Process {
    id: powProc
    running: true
    command: ["sh", "-c", "if [ -d /sys/class/power_supply/BAT0 ]; then st=$(cat /sys/class/power_supply/BAT0/status); pct=$(cat /sys/class/power_supply/BAT0/capacity); echo \"BAT ${pct}% ${st}\"; else echo \"AC\"; fi"]
    stdout: SplitParser { onRead: (out) => { powOut = out; } }
  }
  property string powOut: ""
}
