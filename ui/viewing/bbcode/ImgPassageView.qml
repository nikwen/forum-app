import QtQuick 2.3
import Ubuntu.Components 1.1

Image {
    id: image

    source: dataItem.text
    fillMode: Image.PreserveAspectFit

    property var dataItem
}
