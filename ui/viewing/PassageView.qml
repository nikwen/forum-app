import QtQuick 2.2
import Ubuntu.Components 1.1
import Ubuntu.Layouts 1.0

Item {

    property var dataItem: undefined

    height: layouts.height

    Layouts {
        id: layouts
        width: parent.width
        height: childrenRect.height

        layouts: [
            ConditionalLayout {
                name: "column"
                when: dataItem !== undefined && dataItem.text === ""

                Column {
                    id: passageColumn
                    width: parent.width
                }
            },
            ConditionalLayout {
                name: "label"
                when: dataItem !== undefined && dataItem.text !== ""

                Label {
                    id: passageLabel
                    text: dataItem.text
                    width: parent.width
                    wrapMode: Text.Wrap

                    onLinkActivated: Qt.openUrlExternally(link)
                }
            }
        ]
    }

}
