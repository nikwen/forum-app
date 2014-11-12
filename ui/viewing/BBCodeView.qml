import QtQuick 2.2
import Ubuntu.Components 1.1

Item {
    id: rootItem

    readonly property variant tagsWithChildren: [ "quote", "code", "hide" ] //lower-case

    property string code: ""
    property var bbRoot: parse("", code) //of type passage

    height: label.height

    Label {
        id: label
        width: parent.width
        text: bbRoot.text
    }

    Component {
        id: passage
        Item {
            property string tagType: ""
            //Only one of the following two is used at a time
            property string text: ""
            property var childElements: []
        }
    }

    function parse(tagType, content) { //Post content which should be parsed
        var oldPos = 0
        var pos = -1
        var root = passage.createObject(rootItem, { "tagType": tagType }) //TODO: Proper parent here

        while ((pos = content.indexOf("[", pos + 1)) !== -1) {
            var tag = content.substring(pos + 1, content.indexOf("]", pos)).toLowerCase()
            if (arrayContains(tagsWithChildren, tag)) { //else: don't parse
                var notFormattedText = content.substring(oldPos, pos)
                if (!notFormattedText === "") {
                    root.childElements.push(parse("", notFormattedText))
                }
                var endPos = pos + tag.length
                var moreStartTags = 1
                while (moreStartTags > 0) {
                    endPos = content.indexOf(tag, endPos + tag.length)
                    if (endPos === -1) {
                        console.log("Error: endPos === -1")
                        break
                    }
                    var currentTag = content.substring(content.lastIndexOf("[", endPos), content.indexOf("]", endPos) + 1)
                    if (currentTag === "[" + tag + "]") {
                        moreStartTags++
                    } else if (currentTag === "[/" + tag + "]") {
                        moreStartTags--
                    }
                }
                if (moreStartTags === 0) { //else: user forgot closing tag => ignore tag
                    root.childElements.push(parse(tag, content.substring(pos + tag.length + 2, endPos - 2))) //TODO: Check: content substring
                    oldPos = endPos + tag.length + 1
                    pos = oldPos
                }
            }
        }
        if (root.childElements.length === 0) {
            root.text = content
        } else {
            var restText = content.substring(oldPos, content.length)
            if (restText.trim() !== "") {
                root.childElements.push(parse("", restText))
            }
        }
        return root
    }

    function arrayContains(array, value) {
        for (var i = 0; i < array.length; i++) {
            if (array[i] === value) {
                return true
            }
        }
        return false
    }

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
