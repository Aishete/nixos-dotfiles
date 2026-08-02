import Quickshell
import QtQuick
import ".."
import "../widgets" as Widgets

// Status items (clock + Power/Gpu/Ram) positioned ON the radial curve.
// Each item's t places it along the curve (t=0 left end, t=1 right end),
// matching how the workspace stars and systray arc are positioned.
// The workspace stars occupy the left half (t ~0.13..0.45) and the tray the
// far right (t ~0.85..0.97), so status items live in the center-right band.
// Each widget's own `height: parent.height` resolves to the wrapper's 18px.
Item {
    id: root
    anchors.fill: parent

    required property var curve // the radialBarCurve Item (pointOnCurve + pointA/B)

    // Clock at the curve peak (t=0.5)
    Item {
        id: clockHolder
        property real t: 0.5
        property point p: root.curve.pointOnCurve(t, root.curve.pointA, root.curve.pointB)
        x: p.x - width / 2
        y: p.y - height / 2
        width: clockText.implicitWidth + 10
        height: 18
        Text {
            id: clockText
            anchors.centerIn: parent
            text: Time.time
            color: Config.colors.text
            font.pixelSize: 11
            font.family: fontMonaco.name
            style: Text.Sunken
            styleColor: Config.colors.base
        }
    }

    // Status widgets spread on the right side of the curve, before the tray.
    Item {
        id: powerHolder
        property real t: 0.62
        property point p: root.curve.pointOnCurve(t, root.curve.pointA, root.curve.pointB)
        x: p.x - width / 2
        y: p.y - height / 2
        width: powerW.width
        height: 18
        Widgets.PowerWidget { id: powerW }
    }
    Item {
        id: gpuHolder
        property real t: 0.70
        property point p: root.curve.pointOnCurve(t, root.curve.pointA, root.curve.pointB)
        x: p.x - width / 2
        y: p.y - height / 2
        width: gpuW.width
        height: 18
        Widgets.GpuWidget { id: gpuW }
    }
    Item {
        id: ramHolder
        property real t: 0.78
        property point p: root.curve.pointOnCurve(t, root.curve.pointA, root.curve.pointB)
        x: p.x - width / 2
        y: p.y - height / 2
        width: ramW.width
        height: 18
        Widgets.RamWidget { id: ramW }
    }
}
