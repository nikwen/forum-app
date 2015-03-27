import QtQuick 2.3
import Ubuntu.Components 1.1

Item {
    height: childrenRect.height

    property var dataItem

    Rectangle { //TODO-r: AbstractButton as base!!!
        id: rectangle
        color: mouseArea.pressed ? "#DDDDDD" : "#EEEEEE" //TODO-r: Color when inside QuotePassageView, same applies to quotes inside quotes
        width: label.width + units.gu(2)
        height: label.height + units.gu(2)

        anchors.top: parent.top

        Label {
            id: label
            text: passageView.visible ? i18n.tr("Click to hide content") : i18n.tr("Click to show content")
            anchors.centerIn: parent
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent

            onClicked: passageView.visible = !passageView.visible
        }
    }

    PassageView {
        id: passageView

        width: parent.width

        anchors {
            top: rectangle.bottom
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
