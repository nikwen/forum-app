import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Layouts 1.0

//TODO: Wrapping an image or multiple passages with a [url] tag. Maybe remove tag in that case?

Item {

    property var dataItem: undefined

    height: childrenRect.height

    Loader {
        id: passageLoader
        height: item.heigth
        width: parent.width
        asynchronous: false

        Binding {
            target: passageLoader
            when: dataItem !== undefined
            property: "sourceComponent"
            value: (dataItem.text === "") ? column : label
        }
    }

    Component {
        id: column

        Column {
            id: passageColumn
            width: parent.width
            height: childrenRect.height
            spacing: units.gu(2.5)

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

                    Binding {
                        target: loader.item
                        property: "code"
                        value: true
                        when: modelData.tagType === "code"
                    }

                    function getSourceForTag(tag) {
                        if (tag === "quote" || tag === "code") {
                            return "QuotePassageView.qml"
                        } else if (tag === "img") {
                            return "ImgPassageView.qml"
                        } else if (tag === "spoiler" || tag === "hide") {
                            return "SpoilerPassageView.qml"
                        } else {
                            return "PassageView.qml"
                        }
                    }
                }
            }
        }
    }

    Component {
        id: label

        Label {
            id: passageLabel
            text: replaceBBMarkupWithHtml(dataItem.text)
            width: parent.width
            wrapMode: Text.Wrap
            textFormat: Text.StyledText

            onLinkActivated: Qt.openUrlExternally(link)

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
}
