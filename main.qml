import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2

Window {
    id: root
    width: 520
    height: 440
    visible: true
    color: "transparent"

    readonly property color cBg:     "#FA0A1020"
    readonly property color cCard:   "#2AFFFFFF"
    readonly property color cBorder: "#50FFFFFF"
    readonly property color cAccent: "#00FFCC"
    readonly property color cWarn:   "#FF9900"
    readonly property color cDanger: "#FF4455"
    readonly property color cText:   "#FFFFFF"
    readonly property color cDim:    "#CCFFFFFF"
    readonly property color cNet:    "#5599FF"

    property int  prevW: 520; property int prevH: 440
    property int  prevX: 0;   property int prevY: 0
    property bool maxed:     false
    property bool locked:    false
    property bool collapsed: false
    property real winOpacity: 1.0

    function memClr(v) { return v > 0.85 ? cDanger : v > 0.70 ? cWarn : "#4499FF" }

    Rectangle {
        id: shell
        anchors.fill: parent
        opacity: root.winOpacity
        color: cBg; radius: 16
        border.color: cBorder; border.width: 1
        clip: true

        states: State {
            name: "collapsed"
            when: root.collapsed
            PropertyChanges { target: root; height: bar.height + 2 }
        }
        transitions: Transition {
            NumberAnimation { property: "height"; duration: 250; easing.type: Easing.OutCubic }
        }

        Rectangle {
            width: parent.width * 0.55; height: 1
            color: cAccent; opacity: 0.7
            anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        }
        Rectangle {
            width: parent.width * 0.4; height: 1
            color: cNet; opacity: 0.4
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
        }

        // ── 标题栏 ────────────────────────────────────────────────
        Item {
            id: bar
            width: parent.width; height: 42

            Row {
                id: ctrlBtns
                anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                spacing: 7

                // 红：关闭
                Rectangle {
                    width: 12; height: 12; radius: 6; color: "#FF4455"
                    opacity: maClose.containsMouse ? 1.0 : 0.85
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                    Text {
                        anchors.centerIn: parent; text: "x"
                        color: "#80000000"; font.pixelSize: 8; font.bold: true
                        visible: maClose.containsMouse
                    }
                    MouseArea { id: maClose; anchors.fill: parent; hoverEnabled: true; onClicked: Qt.quit() }
                }

                // 橙：隐藏/展开
                Rectangle {
                    width: 12; height: 12; radius: 6; color: "#FF9900"
                    opacity: maHide.containsMouse ? 1.0 : 0.85
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                    Text {
                        anchors.centerIn: parent
                        text: root.collapsed ? "\u25bc" : "\u25b2"
                        color: "#80000000"; font.pixelSize: 7; font.bold: true
                        visible: maHide.containsMouse
                    }
                    MouseArea { id: maHide; anchors.fill: parent; hoverEnabled: true; onClicked: root.collapsed = !root.collapsed }
                }

                // 绿：最大化/还原
                Rectangle {
                    width: 12; height: 12; radius: 6; color: "#00FFCC"
                    opacity: maMax.containsMouse ? 1.0 : 0.85
                    Behavior on opacity { NumberAnimation { duration: 120 } }
                    Text {
                        anchors.centerIn: parent
                        text: root.maxed ? "\u2199" : "\u2197"
                        color: "#80000000"; font.pixelSize: 8; font.bold: true
                        visible: maMax.containsMouse
                    }
                    MouseArea {
                        id: maMax; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            if (!root.maxed) {
                                root.prevW = root.width; root.prevH = root.height
                                root.prevX = root.x;     root.prevY = root.y
                                root.width = Screen.width; root.height = Screen.height
                                root.x = 0; root.y = 0; root.maxed = true
                            } else {
                                root.width = root.prevW; root.height = root.prevH
                                root.x = root.prevX; root.y = root.prevY
                                root.maxed = false
                            }
                        }
                    }
                }

                // 锁：固定/解锁
                Rectangle {
                    width: 36; height: 15; radius: 4
                    color: root.locked ? "#FF9900" : "#30FFFFFF"
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Row {
                        anchors.centerIn: parent; spacing: 3

                        Item {
                            width: 9; height: 11
                            Rectangle {
                                width: 7; height: 4; radius: 4
                                color: "transparent"
                                border.color: root.locked ? "#CC000000" : "#AAFFFFFF"
                                border.width: 1.5
                                anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                                anchors.topMargin: root.locked ? 0 : -1
                                anchors.horizontalCenterOffset: root.locked ? 0 : 2
                            }
                            Rectangle {
                                width: 9; height: 6; radius: 2
                                color: root.locked ? "#CC000000" : "#AAFFFFFF"
                                anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                            }
                        }

                        Text {
                            text: root.locked ? "\u9501\u5b9a" : "\u81ea\u7531"
                            color: root.locked ? "#CC000000" : "#AAFFFFFF"
                            font.pixelSize: 8; font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent; hoverEnabled: true
                        onClicked: root.locked = !root.locked
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: "Linux \u7cfb\u7edf\u76d1\u63a7"
                color: cAccent; font.pixelSize: 13; font.letterSpacing: 2; font.bold: true
            }

            Text {
                id: clock
                anchors { right: opacityRow.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                color: cText; font.pixelSize: 12; font.family: "Monospace"
                text: Qt.formatTime(new Date(), "hh:mm:ss")
            }

            // 透明度控制
            Row {
                id: opacityRow
                anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                spacing: 4

                Text {
                    text: "\u900f\u660e\u5ea6"
                    color: cDim; font.pixelSize: 9
                    anchors.verticalCenter: parent.verticalCenter
                }

                Slider {
                    id: opacitySlider
                    width: 55; height: 18
                    from: 0.2; to: 1.0; value: 1.0; stepSize: 0.05
                    anchors.verticalCenter: parent.verticalCenter
                    onValueChanged: root.winOpacity = value

                    background: Rectangle {
                        x: opacitySlider.leftPadding
                        y: opacitySlider.topPadding + opacitySlider.availableHeight / 2 - height / 2
                        width: opacitySlider.availableWidth; height: 3; radius: 2
                        color: "#40FFFFFF"
                        Rectangle {
                            width: opacitySlider.visualPosition * parent.width
                            height: parent.height; radius: 2
                            color: cAccent
                        }
                    }
                    handle: Rectangle {
                        x: opacitySlider.leftPadding + opacitySlider.visualPosition * opacitySlider.availableWidth - width / 2
                        y: opacitySlider.topPadding + opacitySlider.availableHeight / 2 - height / 2
                        width: 11; height: 11; radius: 6
                        color: cAccent
                        opacity: opacitySlider.pressed ? 1.0 : 0.85
                    }
                }

                Text {
                    text: Math.round(opacitySlider.value * 100) + "%"
                    color: cAccent; font.pixelSize: 9; font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // 拖拽
            MouseArea {
                anchors {
                    left: ctrlBtns.right; leftMargin: 8
                    right: clock.left; rightMargin: 8
                    top: parent.top; bottom: parent.bottom
                }
                property point p
                onPressed: p = Qt.point(mouse.x, mouse.y)
                onPositionChanged: {
                    if (!root.locked) {
                        root.x += mouse.x - p.x
                        root.y += mouse.y - p.y
                    }
                }
            }
        }

        Text {
            id: dateLbl
            anchors { top: bar.bottom; horizontalCenter: parent.horizontalCenter }
            text: Qt.formatDate(new Date(), "yyyy\u5e74MM\u6708dd\u65e5  dddd")
            color: cDim; font.pixelSize: 11
            visible: !root.collapsed
        }

        Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: {
                clock.text   = Qt.formatTime(new Date(), "hh:mm:ss")
                dateLbl.text = Qt.formatDate(new Date(), "yyyy\u5e74MM\u6708dd\u65e5  dddd")
            }
        }

        // ── 卡片网格 ──────────────────────────────────────────────
        GridLayout {
            anchors {
                top: dateLbl.bottom; topMargin: 8
                bottom: parent.bottom; bottomMargin: 12
                left: parent.left; leftMargin: 10
                right: parent.right; rightMargin: 10
            }
            columns: 2; rowSpacing: 8; columnSpacing: 8
            visible: !root.collapsed

            // ══ 处理器 ════════════════════════════════════════════
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: cCard; radius: 12; clip: true
                border.color: cBorder; border.width: 1

                Rectangle {
                    width: parent.width * 0.45; height: 2; radius: 1
                    color: cAccent; opacity: 0.9
                    anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                }

                Item {
                    id: r1hdr
                    anchors { top: parent.top; topMargin: 11; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }
                    height: 18
                    Text {
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                        text: "\u5904\u7406\u5668"; color: cDim; font.pixelSize: 11; font.letterSpacing: 1
                    }
                    Text {
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        text: Math.round(sysData.cpuLoad * 100) + "%"
                        color: sysData.cpuLoad > 0.85 ? cDanger : sysData.cpuLoad > 0.60 ? cWarn : cAccent
                        font.pixelSize: 12; font.bold: true
                    }
                }

                Column {
                    anchors {
                        top: r1hdr.bottom; topMargin: 6
                        bottom: parent.bottom; bottomMargin: 8
                        left: parent.left; leftMargin: 12
                        right: parent.right; rightMargin: 12
                    }
                    spacing: 5

                    Row {
                        width: parent.width; height: 64; spacing: 12

                        Canvas {
                            id: ring
                            width: 62; height: 62
                            anchors.verticalCenter: parent.verticalCenter
                            property real val: 0
                            onValChanged: requestPaint()

                            Behavior on val { NumberAnimation { duration: 800; easing.type: Easing.OutCubic } }
                            Connections { target: sysData; onDataChanged: ring.val = sysData.cpuLoad }

                            function ringColor(v) {
                                var r, g, b
                                if (v < 0.60) {
                                    var t = v / 0.60
                                    r = Math.round(t * 255)
                                    g = Math.round(255 + t * (238 - 255))
                                    b = Math.round(204 + t * (0 - 204))
                                } else if (v < 0.85) {
                                    var t = (v - 0.60) / 0.25
                                    r = 255
                                    g = Math.round(238 + t * (102 - 238))
                                    b = 0
                                } else {
                                    var t = (v - 0.85) / 0.15
                                    r = 255
                                    g = Math.round(102 + t * (32 - 102))
                                    b = Math.round(t * 32)
                                }
                                return "rgb(" + r + "," + g + "," + b + ")"
                            }

                            onPaint: {
                                var c = getContext("2d")
                                c.clearRect(0, 0, width, height)
                                var cx = 31, cy = 31, r = 23, lw = 6
                                c.beginPath()
                                c.arc(cx, cy, r, 0, 2 * Math.PI)
                                c.strokeStyle = "#30FFFFFF"; c.lineWidth = lw; c.stroke()
                                if (val > 0) {
                                    var segments = 60
                                    var startAngle = -Math.PI / 2
                                    var totalAngle = 2 * Math.PI * val
                                    var segAngle = totalAngle / segments
                                    for (var i = 0; i < segments; i++) {
                                        var t = i / (segments - 1)
                                        var from = startAngle + i * segAngle
                                        var to = from + segAngle + 0.01
                                        c.beginPath()
                                        c.arc(cx, cy, r, from, to)
                                        c.strokeStyle = ringColor(t * val)
                                        c.lineWidth = lw; c.lineCap = "butt"; c.stroke()
                                    }
                                    var endAngle = startAngle + totalAngle
                                    c.beginPath()
                                    c.arc(cx, cy, r, endAngle - 0.01, endAngle + 0.01)
                                    c.strokeStyle = ringColor(val)
                                    c.lineWidth = lw + 1; c.lineCap = "round"; c.stroke()
                                }
                                c.fillStyle = "#FFFFFF"; c.font = "bold 12px sans-serif"
                                c.textAlign = "center"; c.textBaseline = "middle"
                                c.fillText(Math.round(val * 100) + "%", cx, cy)
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            Repeater {
                                model: [
                                    { dot: "#00FFCC", label: "\u6e29\u5ea6", val: sysData.cpuTemp },
                                    { dot: "#AA88FF", label: "\u8fdb\u7a0b", val: sysData.processCount + " \u4e2a" }
                                ]
                                Row {
                                    spacing: 6
                                    Rectangle { width: 7; height: 7; radius: 4; color: modelData.dot; anchors.verticalCenter: parent.verticalCenter }
                                    Text { text: modelData.label + "\uff1a" + modelData.val; color: cText; font.pixelSize: 11 }
                                }
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: "#40FFFFFF" }
                    Text { text: "60 \u79d2\u8d1f\u8f7d\u5386\u53f2"; color: cDim; font.pixelSize: 10 }

                    Canvas {
                        id: chart
                        width: parent.width
                        height: Math.max(16, parent.height - 64 - 1 - 14 - 16 - 6)
                        property var history: sysData.cpuHistory
                        onHistoryChanged: requestPaint()
                        onHeightChanged: requestPaint()
                        onPaint: {
                            var c = getContext("2d")
                            c.clearRect(0, 0, width, height)
                            var arr = history
                            if (!arr || arr.length < 2 || height < 5) return
                            var w = width / (arr.length - 1)
                            for (var g = 1; g < 4; g++) {
                                var gy = height * g / 4
                                for (var x = 0; x < width; x += 7) {
                                    c.beginPath(); c.strokeStyle = "#25FFFFFF"; c.lineWidth = 1
                                    c.moveTo(x, gy); c.lineTo(Math.min(x + 3, width), gy); c.stroke()
                                }
                            }
                            var g2 = c.createLinearGradient(0, 0, 0, height)
                            g2.addColorStop(0, "#6000FFCC"); g2.addColorStop(1, "#0000FFCC")
                            c.fillStyle = g2
                            c.beginPath(); c.moveTo(0, height)
                            for (var i = 0; i < arr.length; i++)
                                c.lineTo(i * w, height - arr[i] * height)
                            c.lineTo((arr.length - 1) * w, height); c.closePath(); c.fill()
                            c.beginPath()
                            for (var j = 0; j < arr.length; j++) {
                                if (j === 0) c.moveTo(0, height - arr[0] * height)
                                else c.lineTo(j * w, height - arr[j] * height)
                            }
                            c.strokeStyle = cAccent; c.lineWidth = 1.5; c.stroke()
                        }
                    }
                }
            }

            // ══ 内存 ══════════════════════════════════════════════
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: cCard; radius: 12; clip: true
                border.color: cBorder; border.width: 1

                Rectangle {
                    width: parent.width * 0.45; height: 2; radius: 1
                    color: memClr(sysData.memPercent); opacity: 0.9
                    anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                }

                Item {
                    id: r2hdr
                    anchors { top: parent.top; topMargin: 11; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }
                    height: 18
                    Text {
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                        text: "\u7269\u7406\u5185\u5b58"; color: cDim; font.pixelSize: 11; font.letterSpacing: 1
                    }
                    Text {
                        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                        text: Math.round(sysData.memPercent * 100) + "%"
                        color: memClr(sysData.memPercent); font.pixelSize: 12; font.bold: true
                    }
                }

                Item {
                    anchors { top: r2hdr.bottom; topMargin: 6; bottom: parent.bottom; bottomMargin: 10; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }
                    Column {
                        anchors.centerIn: parent; spacing: 10; width: parent.width

                        Rectangle {
                            width: parent.width; height: 10; radius: 5; color: "#30FFFFFF"
                            Rectangle {
                                width: parent.width * sysData.memPercent
                                height: parent.height; radius: 5
                                color: memClr(sysData.memPercent)
                                Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                            }
                        }

                        Text { text: "\u5df2\u7528 / \u603b\u8ba1\uff1a" + sysData.memUsage; color: cText; font.pixelSize: 11; font.family: "Monospace" }
                        Rectangle { width: parent.width; height: 1; color: "#40FFFFFF" }

                        Row {
                            spacing: 16
                            Repeater {
                                model: [
                                    { label: "\u5df2\u7528", dynamic: true  },
                                    { label: "\u7a7a\u95f2", dynamic: false }
                                ]
                                Row {
                                    spacing: 6
                                    Rectangle {
                                        width: 10; height: 10; radius: 3
                                        color: modelData.dynamic ? memClr(sysData.memPercent) : "#40FFFFFF"
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    Text { text: modelData.label; color: cDim; font.pixelSize: 11 }
                                }
                            }
                        }
                    }
                }
            }

            // ══ 磁盘 ══════════════════════════════════════════════
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: cCard; radius: 12; clip: true
                border.color: cBorder; border.width: 1

                Rectangle {
                    width: parent.width * 0.45; height: 2; radius: 1
                    color: "#FFCC00"; opacity: 0.9
                    anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                }

                Item {
                    id: r3hdr
                    anchors { top: parent.top; topMargin: 11; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }
                    height: 18
                    Text {
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                        text: "\u78c1\u76d8\u8bfb\u5199"; color: cDim; font.pixelSize: 11; font.letterSpacing: 1
                    }
                }

                Item {
                    anchors { top: r3hdr.bottom; topMargin: 6; bottom: parent.bottom; bottomMargin: 10; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }
                    Row {
                        anchors.centerIn: parent; spacing: 14
                        Canvas {
                            width: 38; height: 38; anchors.verticalCenter: parent.verticalCenter
                            onPaint: {
                                var c = getContext("2d"); c.clearRect(0, 0, width, height)
                                c.strokeStyle = "#60FFFFFF"; c.lineWidth = 1.5
                                c.beginPath(); c.moveTo(4, 7); c.lineTo(34, 7); c.lineTo(34, 31); c.lineTo(4, 31); c.closePath(); c.stroke()
                                c.beginPath(); c.arc(19, 19, 8, 0, 2 * Math.PI); c.strokeStyle = "#FFCC00"; c.lineWidth = 1.5; c.stroke()
                                c.beginPath(); c.arc(19, 19, 3, 0, 2 * Math.PI); c.fillStyle = "#FFCC00"; c.fill()
                                c.beginPath(); c.moveTo(27, 9); c.lineTo(19, 19); c.strokeStyle = "#AAFFCC00"; c.lineWidth = 1; c.stroke()
                            }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter; spacing: 10
                            Repeater {
                                model: [ { dot: "#00FFCC", idx: 0 }, { dot: "#FFCC00", idx: 1 } ]
                                Row {
                                    spacing: 6
                                    Rectangle { width: 7; height: 7; radius: 4; color: modelData.dot; anchors.verticalCenter: parent.verticalCenter }
                                    Text {
                                        text: { var p = sysData.diskIO.split("   "); return p.length > modelData.idx ? p[modelData.idx] : "" }
                                        color: cText; font.pixelSize: 11; font.family: "Monospace"
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ══ 网络 ══════════════════════════════════════════════
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: cCard; radius: 12; clip: true
                border.color: cBorder; border.width: 1

                Rectangle {
                    width: parent.width * 0.45; height: 2; radius: 1
                    color: cNet; opacity: 0.9
                    anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                }

                Item {
                    id: r4hdr
                    anchors { top: parent.top; topMargin: 11; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }
                    height: 18
                    Text {
                        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                        text: "\u7f51\u7edc\u6d41\u91cf"; color: cDim; font.pixelSize: 11; font.letterSpacing: 1
                    }
                }

                Item {
                    anchors { top: r4hdr.bottom; topMargin: 6; bottom: parent.bottom; bottomMargin: 10; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }
                    Row {
                        anchors.centerIn: parent; spacing: 14
                        Canvas {
                            width: 38; height: 38; anchors.verticalCenter: parent.verticalCenter
                            onPaint: {
                                var c = getContext("2d"); c.clearRect(0, 0, width, height)
                                c.strokeStyle = cNet; c.lineWidth = 2; c.lineCap = "round"
                                c.beginPath(); c.moveTo(11, 26); c.lineTo(11, 10); c.stroke()
                                c.beginPath(); c.moveTo(7, 15);  c.lineTo(11, 10); c.lineTo(15, 15); c.stroke()
                                c.beginPath(); c.moveTo(25, 12); c.lineTo(25, 28); c.stroke()
                                c.beginPath(); c.moveTo(21, 23); c.lineTo(25, 28); c.lineTo(29, 23); c.stroke()
                            }
                        }
                        Column {
                            anchors.verticalCenter: parent.verticalCenter; spacing: 10
                            Repeater {
                                model: [ { dot: "#5599FF", idx: 0 }, { dot: "#AA88FF", idx: 1 } ]
                                Row {
                                    spacing: 6
                                    Rectangle { width: 7; height: 7; radius: 4; color: modelData.dot; anchors.verticalCenter: parent.verticalCenter }
                                    Text {
                                        text: { var p = sysData.netIO.split("   "); return p.length > modelData.idx ? p[modelData.idx] : "" }
                                        color: cText; font.pixelSize: 11; font.family: "Monospace"
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }
    }
}
