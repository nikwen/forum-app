import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Layouts 1.0

//TODO-r: Wrapping an image with a [url] tag.

Item {

    property var dataItem: undefined

    height: childrenRect.height

    Layouts { //TODO-r: Use synchronous Loader to fix remaining scrolling issues
        id: layouts
        width: parent.width

        layouts: [
            ConditionalLayout {
                name: "column"
                when: dataItem !== undefined && dataItem.text === ""

                Column {
                    id: passageColumn
                    width: parent.width
                    height: childrenRect.height
                    spacing: units.gu(2.5)

                    onHeightChanged: {
                        layouts.height = height
                    }

                    Repeater {
                        model: (dataItem !== undefined) ? dataItem.childElements : 0

                        delegate: Item {
                            height: (loader.item !== null) ? loader.item.height : loader.height

                            anchors {
                                left: parent.left
                                right: parent.right
                            }

                            Loader {
                                id: loader
                                source: getSourceForTag(modelData.tagType)
                                width: parent.width
                                asynchronous: false
                            }

                            Binding {
                                target: loader.item
                                property: "dataItem"
                                value: modelData
                            }

                            function getSourceForTag(tag) {
                                if (tag === "quote") {
                                    return "QuotePassageView.qml"
                                } else if (tag === "img") {
                                    return "ImgPassageView.qml"
                                } else {
                                    return "PassageView.qml"
                                }
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
                    text: replaceBBMarkupWithHtml(dataItem.text)
                    width: parent.width
                    wrapMode: Text.Wrap
                    textFormat: Text.StyledText

                    onLinkActivated: Qt.openUrlExternally(link)

                    onHeightChanged: {
                        layouts.height = height
                    }

                    function replaceBBMarkupWithHtml(text) {
                        var bb = []
                        bb[0] = /\[url\](.*?)\[\/url\]/gi
                        bb[1] = /\[url\="?(.*?)"?\](.*?)\[\/url\]/gi

                        var html =[]
                        html[0] = "<a href=\"$1\">$1</a>"
                        html[1] = "<a href=\"$1\">$2</a>"

                        for (var i = 0; i < bb.length; i++) {
                            text = text.replace(bb[i], html[i])
                        }

                        return text
                    }
                }
            }
        ]
    }
}
