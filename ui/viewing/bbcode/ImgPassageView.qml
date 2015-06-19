import QtQuick 2.3
import Ubuntu.Components 1.1

//TODO: Enlarge on click (like in scopes)

Item {
    property var dataItem

    height: Math.max(childrenRect.height, units.gu(4))

    Image {
        id: image

        width: parent.width

        source: dataItem.text
        fillMode: Image.PreserveAspectFit
    }

    ActivityIndicator {
        anchors.centerIn: parent
        running: image.status === Image.Loading || dataItem === undefined || dataItem === null || dataItem.text === ""
    }

    Rectangle {
        id: errorRect
        width: errorLabel.width + units.gu(4)
        height: errorLabel.height + units.gu(2)
        anchors.horizontalCenter: parent.horizontalCenter
        visible: image.status === Image.Error || (image.status === Image.Ready && image.sourceSize.width <= 1 && image.sourceSize.height <= 1)
        radius: units.gu(0.5)
        border {
            width: units.dp(1)
            color: "#CCCCCC"
        }

        Rectangle {
            radius: errorRect.radius - errorRect.border.width
            color: "#F7F7F7" //TODO: Central place for storing

            anchors {
                fill: parent
                margins: errorRect.border.width
            }
        }

        Label {
            id: errorLabel
            anchors.centerIn: parent //TODO-r: Wrap text if width too small

            text: i18n.tr("Could not load image")
        }
    }
}
