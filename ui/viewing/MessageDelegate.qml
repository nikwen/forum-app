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
    property string postTime

    width: parent.width
    height: contentRect.height
    anchors {
        horizontalCenter: parent.horizontalCenter
    }
    color: "white"

    Rectangle {
        id: contentRect
        width: parent.width
        height: childrenRect.height + (thanksLabel.visible ? units.gu(1) : -units.gu(1))
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

        Label {
            id: author
            text: authorText
            anchors {
                top: parent.top
                left: rect.right
                right: time.right
                topMargin: units.gu(1)
                leftMargin: units.gu(1)
            }
            color: "black"
            font.bold: true
        }

        Label {
            id: time
            text: formatTime(postTime)
            anchors {
                top: parent.top
                right: parent.right
                topMargin: units.gu(1)
                leftMargin: units.gu(1)
                rightMargin: units.gu(1)
            }

            function formatTime(time) {
                if (time.charAt(4) !== "-") { //Fix ISO 8601 format if necessary
                    time = time.substring(0, 4) + "-" + time.substring(4, 6) + "-" + time.substring(6)
                }

                var postDate = new Date(time)

                var todaysDate = new Date()

                if (Qt.formatDate(postDate, "ddMMyy") === Qt.formatDate(todaysDate, "ddMMyy")) { //Posted today => show only the time
                    return Qt.formatTime(postDate, i18n.tr("hh:mm"))
                } else if (postDate.getFullYear() === todaysDate.getFullYear()) {
                    return Qt.formatDate(postDate, i18n.tr("dd. MMM"))
                } else {
                    return Qt.formatDate(postDate, i18n.tr("dd.MM.yyyy")) //TODO: Localize!!!
                }
            }
        }

        Label {
            id: title
            text: titleText
            wrapMode: Text.Wrap
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
            anchors {
                top: title.visible ? title.bottom : author.bottom
                left: rect.right
                right: parent.right
                margins: units.gu(1)
            }
            onLinkActivated: Qt.openUrlExternally(link)
        }

        Label {
            id: thanksLabel
            wrapMode: Text.Wrap
            visible: thanksInfo !== undefined && thanksInfo !== "" && thanksCount > 0
            text: qsTr((thanksCount === 1) ? i18n.tr("%1 user thanked %2 for this useful post") : i18n.tr("%1 users thanked %2 for this useful post")).arg(thanksCount).arg(authorText)
            fontSize: "small"
            anchors {
                top: contentLabel.bottom
                left: rect.right
                right: parent.right
                margins: visible ? units.gu(1) : 0
            }

            property int thanksCount: occurrences(thanksInfo, "userid")

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

    function parseBBCode(text) {
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
