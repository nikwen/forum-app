import QtQuick 2.3
import Ubuntu.Components 1.1

Item {
    height: childrenRect.height

    property var dataItem
    property color parentBackgroundColor

    AbstractButton {
        id: showContentButton
        width: label.width + units.gu(2)
        height: label.height + units.gu(2)

        anchors.top: parent.top

        onClicked: passageView.visible = !passageView.visible

        Rectangle {
            anchors.fill: parent
            color: Qt.darker(parentBackgroundColor, 15.0 / (showContentButton.pressed ? 13.0 : 14.0)) //On a white background these are "#DDDDDD" and "#EEEEEE"

            Behavior on color {
                ColorAnimation {
                    duration: UbuntuAnimation.SnapDuration
                }
            }
        }

        Label {
            id: label
            text: passageView.visible ? i18n.tr("Click to hide content") : i18n.tr("Click to show content")
            anchors.centerIn: parent
        }
    }

    PassageView {
        id: passageView

        width: parent.width

        anchors {
            top: showContentButton.bottom
            topMargin: visible ? units.gu(2) : 0
        }

        dataItem: parent.dataItem
        parentBackgroundColor: parent.parentBackgroundColor
        visible: false

        Binding {
            target: passageView
            property: "height"
            value: 0
            when: !passageView.visible
        }
    }
}
