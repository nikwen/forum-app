import QtQuick 2.3
import Ubuntu.Components 1.1

//TODO: Enlarge on click (like in scopes)
//TODO-r: More visually pleasing while loading image and while showing error message, maybe put a grey box around the view in that case (like for quotes)

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

    Label {
        id: errorLabel
        anchors.centerIn: parent
        visible: image.status === Image.Error

        text: i18n.tr("Could not load image")
    }
}
