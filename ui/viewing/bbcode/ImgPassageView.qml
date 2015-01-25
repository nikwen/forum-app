import QtQuick 2.3
import Ubuntu.Components 1.1

//TODO-r: Error message if image cannot be loaded
//TODO-r: Loading indicator

Image {
    id: image

    source: dataItem.text
    fillMode: Image.PreserveAspectFit

    property var dataItem
}
