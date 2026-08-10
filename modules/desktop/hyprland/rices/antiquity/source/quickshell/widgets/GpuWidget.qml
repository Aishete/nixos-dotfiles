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
  width: gpuText.implicitWidth + 12
  height: parent.height

  Text {
    id: gpuText
    anchors.centerIn: parent
    text: "GPU " + (gpuProc.running ? "" : gpuOut)
    color: Config.colors.text
    font.pixelSize: 11
    font.family: fontMonaco.name
  }

  Process {
    id: gpuProc
    running: true
    command: ["sh", "-c", "cat /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | head -1 | awk '{printf \"%d%%\", $1}'"]
    stdout: SplitParser { onRead: (out) => { gpuOut = out; } }
  }
  property string gpuOut: ""

  // Process runs its command ONCE at startup; re-run every 5s so the
  // GPU busy % stays live.
  Timer {
    interval: 5 * 1000
    running: true
    repeat: true
    onTriggered: {
      gpuProc.running = false;
      gpuProc.running = true;
    }
  }
}
