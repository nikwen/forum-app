import QtQuick 2.3
import Ubuntu.Components 1.1

//TODO: Enlarge on click (like in scopes)

Item {
    property var dataItem

    height: Math.max(childrenHeight, units.gu(4)) //childrenRect.height would somehow cause a binding loop here

    readonly property real childrenHeight: errorRect.visible ? errorRect.height : (activityIndicator.running ? activityIndicator.height : image.height)

    Image {
        id: image

        width: parent.width

        source: dataItem.text
        fillMode: Image.PreserveAspectFit
    }

    ActivityIndicator {
        id: activityIndicator
        anchors.centerIn: parent
        running: image.status === Image.Loading || dataItem === undefined || dataItem === null || dataItem.text === ""
    }

    Rectangle {
        id: errorRect
        width: Math.min(parent.width, errorLabel.contentWidth + units.gu(4))
        height: errorLabel.height + units.gu(2)
        anchors.centerIn: parent
        visible: errorLabel.visible
        radius: units.gu(0.5)
        border {
            width: units.dp(1)
            color: "#CCCCCC"
        }

        Rectangle {
            radius: errorRect.radius - errorRect.border.width
            color: "#F7F7F7" //TODO: Central place for storing such colors

            anchors {
                fill: parent
                margins: errorRect.border.width
            }
        }
    }

    Label {
        id: errorLabel

        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            leftMargin: units.gu(1)
            rightMargin: anchors.leftMargin
        }

        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        visible: image.status === Image.Error || (image.status === Image.Ready && image.sourceSize.width <= 1 && image.sourceSize.height <= 1)

        text: (dataItem.tagArguments[""] !== undefined && dataItem.tagArguments[""] !== null && dataItem.tagArguments[""] !== "") ? qsTr(i18n.tr("Could not load image \"%1\"")).arg(dataItem.tagArguments[""]) : i18n.tr("Could not load image")
    }
}
