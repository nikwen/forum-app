/*************************************************************************
** Forum Browser
**
** Copyright (c) 2014 Niklas Wenzel <nikwen.developer@gmail.com>
** Copyright (c) 2013 - 2014 Michael Hall <mhall119@ubuntu.com>
**
** $QT_BEGIN_LICENSE:GPL$
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
** General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; see the file COPYING. If not, write to
** the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
** Boston, MA 02110-1301, USA.
**
**
** $QT_END_LICENSE$
**
*************************************************************************/

import QtQuick 2.2
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0

UbuntuShape {
    property string titleText
    property string content
    property string avatar
    property string authorText
    property string thanksInfo

    width: parent.width
    height: contentRect.height
    anchors {
        horizontalCenter: parent.horizontalCenter
    }
    color: "white"

    Rectangle {
        id: contentRect
        width: parent.width
        height: childrenRect.height + units.gu(1)
        color: "transparent"

        Rectangle {
            id: rect
            width: units.gu(7)
            height: units.gu(7)
            color: "transparent"

            anchors {
                top: parent.top
                left: parent.left
            }

            UbuntuShape {
                width: units.gu(5)
                height: width
                anchors.centerIn: parent
                image: Image {
                    id: avatarp
                    source: if(avatar === "") { "../../graphics/contact.svg" } else { avatar }
                    anchors.fill: parent
                    onStatusChanged: { if(avatarp.status === Image.Ready || avatar === "") { load_image.running=false; } }
                }
            }
            ActivityIndicator {
                id: load_image
                z: 100
                anchors.centerIn: parent
                running: true
            }
        }

        Rectangle {
            id: thanksRect
            width: units.gu(7)
            height: units.gu(5)
            color: "transparent"

            anchors {
                bottom: contentLabel.bottom
                left: parent.left
            }

            UbuntuShape { //TODO: Replace with thumb-up image
                id: thanksShape
                width: units.gu(5)
                height: width
                anchors.centerIn: parent
                color: "grey"
            }

            Label {
                anchors.centerIn: thanksShape
                wrapMode: Text.Wrap
                color: "white"
                visible: thanksInfo !== undefined
                text: thanksCount
                onLinkActivated: Qt.openUrlExternally(link)

                property int thanksCount: occurrences(thanksInfo, "userid")

                Component.onCompleted: {
                    var sizes = ["small", "x-small", "xx-small"]
                    var index = 0
                    while (width > thanksShape.width - units.gu(1) && index < sizes.length) {
                        fontSize = sizes[index]
                        index++
                    }
                }

                function occurrences(string, subString) {
                    var n = 0
                    var pos = 0
                    var step = subString.length

                    while (true) {
                        pos = string.indexOf(subString,pos)
                        if (pos >= 0) {
                            n++
                            pos += step
                        } else {
                            break
                        }
                    }
                    return n
                }
            }

        }

        Label {
            id: author
            text: authorText
            anchors {
                top: parent.top
                left: rect.right
                topMargin: units.gu(1)
                leftMargin: units.gu(1)
            }
            color: "black"
            font.bold: true
        }

        Label {
            id: title
            text: titleText
            wrapMode: Text.Wrap
            color: "#808080"
            font.italic: true
            visible: titleText !== undefined && titleText !== ""
            anchors {
                top: author.bottom
                left: rect.right
                right: parent.right
                leftMargin: units.gu(1)
                rightMargin: units.gu(1)
            }
        }

        Label {
            id: contentLabel
            text: parseBBCode(content)
            wrapMode: Text.Wrap
            color: "#808080"
            anchors {
                top: title.visible?title.bottom:author.bottom
                left: rect.right
                right: parent.right
                topMargin: units.gu(1)
                leftMargin: units.gu(1)
                rightMargin: units.gu(1)
            }
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }

    function parseBBCode(text) {
        var bb = [];
        bb[0] = /\[url\](.*?)\[\/url\]/gi;
        bb[1] = /\[url\="?(.*?)"?\](.*?)\[\/url\]/gi;

        var html =[];
        html[0] = "<a href=\"$1\">$1</a>";
        html[1] = "<a href=\"$1\">$2</a>";

        for (var i = 0; i < bb.length; i++) {
            text = text.replace(bb[i], html[i]);
        }

        return text;
    }

}
