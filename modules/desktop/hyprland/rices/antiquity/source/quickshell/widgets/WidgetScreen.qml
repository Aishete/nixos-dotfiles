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
            // widgetScreen_<mon> toggleFront: raise/lower this panel to Overlay on SUPER+Grave.
            // Sibling Scope of the PanelWindow (IpcHandler is not valid inside a PanelWindow).
            Scope {
                id: widgetScreenIpc
                property string screenName: root.modelData.name
                IpcHandler {
                    target: "widgetScreen_" + widgetScreenIpc.screenName
                    function toggleFront() {
                        root.frontMode = !root.frontMode;
                    }
                }
            }
            PanelWindow {
                id: widgetScreen
                screen: root.modelData
                // Raised to Overlay by SUPER+Grave (shared with the bars) so the
                // stats/network panel sits on top of all apps. Toggled by
                // widgetScreen_<mon> toggleFront.
                WlrLayershell.layer: root.frontMode ? WlrLayer.Overlay : WlrLayer.Bottom
                color: "Transparent"
                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
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
