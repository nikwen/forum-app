/*
* Forum Browser
*
* Copyright (c) 2014-2015 Niklas Wenzel <nikwen.developer@gmail.com>
* Copyright (c) 2013-2014 Michael Hall <mhall119@ubuntu.com>
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0

UbuntuShape {

    property string titleText
    property Passage postBody
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
                if (time.charAt(4) !== "-") { //Fixes ISO 8601 format if necessary
                    time = time.substring(0, 4) + "-" + time.substring(4, 6) + "-" + time.substring(6)
                }

                var postDate = new Date(time)

                var todaysDate = new Date()

                if (Qt.formatDate(postDate, "ddMMyy") === Qt.formatDate(todaysDate, "ddMMyy")) { //Posted today => show only the time
                    return Qt.formatTime(postDate, i18n.tr("hh:mm"))
                } else if (postDate.getFullYear() === todaysDate.getFullYear()) {
                    return Qt.formatDate(postDate, i18n.tr("dd MMM"))
                } else {
                    return Qt.formatDate(postDate, i18n.tr("dd/MM/yyyy")) //TODO: Localize!!!
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

        PassageView {
            id: bbRootView
            dataItem: postBody

            anchors {
                top: title.visible ? title.bottom : author.bottom
                left: rect.right
                right: parent.right
                margins: units.gu(1)
            }
        }

        Label {
            id: thanksLabel
            wrapMode: Text.Wrap
            visible: thanksInfo !== undefined && thanksInfo !== "" && thanksCount > 0
            text: qsTr((thanksCount === 1) ? i18n.tr("%1 user thanked %2 for this useful post") : i18n.tr("%1 users thanked %2 for this useful post")).arg(thanksCount).arg(authorText)
            fontSize: "small"
            anchors {
                top: bbRootView.bottom
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

}
