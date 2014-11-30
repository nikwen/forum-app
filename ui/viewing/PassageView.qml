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
                            height: (loader.item !== null) ? loader.item.height : loader.height

                            anchors {
                                left: parent.left
                                right: parent.right
                                leftMargin: getMarginForTag(modelData.tagType)
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
//                                console.log("Tag:", tag)
                                var bbCodeDirectoryPrefix = "bbcode/"
                                if (tag === "quote") { //TODO-r: Tapatalk API passes [code] tags from XDA as [quote]
                                    return bbCodeDirectoryPrefix + "QuotePassageView.qml"
                                } else {
                                    return "PassageView.qml"
                                }
                            }

                            function getMarginForTag(tag) {
                                if (tag === "quote") {
                                    return units.gu(1)
                                } else if (tag !== "") {
                                    return units.gu(2)
                                } else {
                                    return 0
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

                    onLinkActivated: Qt.openUrlExternally(link)

                    function replaceBBMarkupWithHtml(text) {
                        var bb = [];
                        bb[0] = /\[url\](.*?)\[\/url\]/gi;
                        bb[1] = /\[url\="?(.*?)"?\](.*?)\[\/url\]/gi;
                        bb[2] = /\[img\](.*?)\[\/img\]/gi;

                        var html =[];
                        html[0] = "<a href=\"$1\">$1</a>";
                        html[1] = "<a href=\"$1\">$2</a>";
                        html[2] = "<img src=\"$1\">";

                        for (var i = 0; i < bb.length; i++) {
                            text = text.replace(bb[i], html[i]);
                        }

                        return text;
                    }
                }
            }
        ]
    }

}
