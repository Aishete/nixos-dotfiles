import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

import "../popups" as Popups
import ".."

Scope {
    // Taskbar variants, we have one taskber per screen.
    Variants {
        model: Quickshell.screens
        Item {
            id: root
            required property var modelData

            PanelWindow {
                id: widgetScreen
                screen: root.modelData
                // Raised to Overlay by SUPER+Grave (shared with the bars) so the
                // stats/network panel sits on top of all apps. Toggled by
                // widgetScreen_<mon> toggleFront.
                property bool frontMode: false
                WlrLayershell.layer: root.frontMode ? WlrLayer.Overlay : WlrLayer.Bottom
                color: "Transparent"
                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }
                Scope {
                    IpcHandler {
                        target: "widgetScreen_" + widgetScreen.screen.name
                        function toggleFront() {
                            root.frontMode = !root.frontMode;
                        }
                    }
                }
                Rectangle {
                    anchors.fill: parent
                    color: "Transparent"

                    Repeater {
                        anchors.fill: parent
                        model: Object.values(Config.widgets[widgetScreen.screen.name])

                        delegate: Loader {
                            //anchors.fill: parent
                            required property var modelData
                            source: Config.widgetPaths[modelData.widgetName]
                            onLoaded: {
                                item.x = modelData.x;
                                item.y = modelData.y;
                                item.widgetBackground = modelData.enableBackground;
                            }
                        }
                    }
                }
            }
        }
    }
}
