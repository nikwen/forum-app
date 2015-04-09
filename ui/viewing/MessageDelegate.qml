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
import "bbcode"

UbuntuShape {

    width: parent.width
    height: contentRect.height
    color: "white"

    property string titleText
    property Passage postBody
    property string avatar
    property string authorText
    property string thanksInfo
    property string postTime
    property string editTime
    property int postNumber

    Item {
        id: contentRect

        width: parent.width
        height: childrenRect.height + (thanksLabel.visible ? units.gu(4) : units.gu(2))

        Item {
            id: headerRect
            height: childrenRect.height
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: units.gu(2)
            }

            Item {
                id: iconItem
                width: units.gu(5)
                height: width

                anchors {
                    top: parent.top
                    left: parent.left
                }

                Image {
                    id: avatarImage
                    source: (avatar === "") ? "../../graphics/contact.svg" : avatar
                    width: units.gu(5)
                    height: width
                    anchors.centerIn: parent

                    onStatusChanged: {
                        if (avatarImage.status === Image.Error) { //Load default avatar in case of a loading error
                            avatar = ""
                        }
                    }
                }

                ActivityIndicator {
                    id: imageActivityIndicator
                    anchors.centerIn: parent
                    running: avatarImage.status !== Image.Ready
                }
            }

            Label {
                id: author
                text: authorText
                elide: Text.ElideRight
                anchors {
                    top: parent.top
                    left: iconItem.right
                    right: postNumberLabel.left
                    rightMargin: units.gu(1)
                    leftMargin: units.gu(1)
                }
            }

            Label {
                id: time
                text: formatIsoTime(postTime) + ((editTime !== "") ? qsTr(i18n.tr(" (last edited %1)")).arg(formatUnixTimestamp(editTime)) : "") //TODO-r: "Last edited March 2014" sounds wrong
                elide: Text.ElideRight
                anchors {
                    bottom: iconItem.bottom
                    left: iconItem.right
                    right: postNumberLabel.right
                    leftMargin: units.gu(1)
                }

                function formatTime(postDate) {
                    var todaysDate = new Date()

                    if (backend.useAlternativeDateFormat) {
                        if (Qt.formatDate(postDate, "ddMMyy") === Qt.formatDate(todaysDate, "ddMMyy")) { //Posted today => show only the time
                            //TRANSLATORS: Refers to the time when a post was made
                            return qsTr(i18n.tr("At %1")).arg(Qt.formatTime(postDate, i18n.tr("hh:mm")))
                        } else if (postDate.getFullYear() === todaysDate.getFullYear()) { //Posted this year
                            //TRANSLATORS: Refers to the date when a post was made
                            return qsTr(i18n.tr("On %1")).arg(Qt.formatDate(postDate, i18n.tr("MMM d")))
                        } else {
                            //TRANSLATORS: Refers to the date when a post was made
                            return qsTr(i18n.tr("On %1")).arg(Qt.formatDate(postDate, i18n.tr("MMM d, yyyy"))) //TODO-r: Translators comments for format strings
                        }
                    } else {
                        var timeDiff = (todaysDate.getTime() - postDate.getTime()) / 1000 //in seconds

                        if (timeDiff < 60) { //Posted within the last minute
                            return i18n.tr("Just now") //TODO-r: Edited: lower case letter
                        } else if (timeDiff < 3600) { //Posted within the last hour
                            var minutes = Math.floor(timeDiff / 60)
                            return qsTr(i18n.tr("%1 minute ago", "%1 minutes ago", minutes)).arg(minutes)
                        } else if (timeDiff < 86400) { //Posted within the last 24 hours
                            var hours = Math.floor(timeDiff / 3600)
                            return qsTr(i18n.tr("%1 hour ago", "%1 hours ago", hours)).arg(hours)
                        } else if (timeDiff < 2592000 || (postDate.getMonth() === todaysDate.getMonth() && postDate.getFullYear() === todaysDate.getFullYear())) { //Posted within the last 30 days or this month
                            var days = Math.floor(timeDiff / 86400)
                            return qsTr(i18n.tr("%1 day ago", "%1 days ago", days)).arg(days)
                        } else {
                            //TRANSLATORS: Refers to the date when a post was made. Example: March 2015
                            return Qt.formatDate(postDate, i18n.tr("MMMM yyyy"))
                        }
                    }
                }

                function formatUnixTimestamp(time) {
                    var date = new Date(time * 1000)
                    return formatTime(date)
                }

                function formatIsoTime(time) {
                    if (time.charAt(4) !== "-") { //Fixes ISO 8601 format if necessary
                        time = time.substring(0, 4) + "-" + time.substring(4, 6) + "-" + time.substring(6)
                    }

                    var date = new Date(time)
                    return formatTime(date)
                }
            }

            Label {
                id: postNumberLabel
                text: "#" + postNumber
                anchors {
                    top: parent.top
                    right: parent.right
                    rightMargin: units.gu(0.5)
                }
            }
        }

        Label {
            id: titleLabel
            text: titleText
            wrapMode: Text.Wrap
            visible: titleText !== undefined && titleText !== ""
            anchors {
                top: headerRect.bottom
                left: parent.left
                right: parent.right
                margins: visible ? units.gu(2) : units.gu(0)
            }
        }

        PassageView {
            id: bbRootView
            dataItem: postBody

            anchors {
                top: titleLabel.bottom
                left: parent.left
                right: parent.right
                margins: units.gu(2)
                topMargin: titleLabel.visible ? units.gu(2) : units.gu(0)
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
                left: parent.left
                right: parent.right
                margins: visible ? units.gu(2) : 0
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
