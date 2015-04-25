import QtQuick 2.3
import Ubuntu.Components 1.1

Item {
    height: childrenRect.height

    property var dataItem

    AbstractButton {
        id: showContentButton
        width: label.width + units.gu(2)
        height: label.height + units.gu(2)

        anchors.top: parent.top

        onClicked: passageView.visible = !passageView.visible

        Rectangle {
            anchors.fill: parent
            color: showContentButton.pressed ? "#DDDDDD" : "#EEEEEE" //TODO-r: Color when inside QuotePassageView, same applies to quotes inside quotes

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
        visible: false

        Binding {
            target: passageView
            property: "height"
            value: 0
            when: !passageView.visible
        }
    }
}
