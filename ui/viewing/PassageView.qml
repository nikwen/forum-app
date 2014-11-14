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
                when: dataItem !== undefined && dataItem.text === "" //TODO-r: What does the following do: "[quote][/quote]"

                Column {
                    id: passageColumn
                    width: parent.width
                    height: childrenRect.height

                    Repeater {
                        model: (dataItem !== undefined) ? dataItem.childElements : 0

                        delegate: Item {
                            height: loader.item.height

                            anchors {
                                left: parent.left
                                right: parent.right
                                leftMargin: (modelData.tagType !== "") ? units.gu(2) : 0
                            }

                            Loader {
                                id: loader
                                source: "PassageView.qml"
                                width: parent.width
                            }

                            Binding {
                                target: loader.item
                                property: "dataItem"
                                value: modelData
                            }
                        }


                    }
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
