/*************************************************************************
** Forum Browser
**
** Copyright (c) 2014 Niklas Wenzel <nikwen.developer@gmail.com>
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
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Themes.Ambiance 0.1
import "../../stringutils.js" as StringUtils
import "../../backend"
import "../components"

//TODO-r: Signature settings

Page {
    id: postCreationPage

    signal posted(string subject, int topicId)

    property int forum_id: -1
    property int topic_id: -1

    property string mode: "post" //Can be either "post" or "thread"

    title: (mode === "post") ? i18n.tr("New Post") : i18n.tr("New Topic")

    head.actions: [
        Action {
            id: submitAction
            text: i18n.tr("Submit")
            iconName: "ok"

            onTriggered: submit()

            function submit() {
                var message = messageTextField.text

                if (backend.signature !== "") {
                    message += "\n\n" + backend.signature
                }

                if (mode === "post") {
                    submitRequest.query = '<?xml version="1.0"?><methodCall><methodName>reply_post</methodName><params><param><value>' + forum_id + '</value></param><param><value>' + topic_id + '</value></param><param><value><base64>' + StringUtils.base64_encode(subjectTextField.text) + '</base64></value></param><param><value><base64>' + StringUtils.base64_encode(message) + '</base64></value></param></params></methodCall>'
                } else {
                    submitRequest.query = '<?xml version="1.0"?><methodCall><methodName>new_topic</methodName><params><param><value>' + forum_id + '</value></param><param><value><base64>' + StringUtils.base64_encode(subjectTextField.text) + '</base64></value></param><param><value><base64>' + StringUtils.base64_encode(message) + '</base64></value></param></params></methodCall>'
                }

                submitRequest.start() //TODO: Loading dialog
            }
        }
    ]

    ApiRequest {
        id: submitRequest
        checkSuccess: true

        onQuerySuccessResult: {
            if (success) {
                if (mode === "post") {
                    pageStack.pop()
                    posted(subjectTextField.text, topic_id)
                } else {
                    var idIndex = responseXml.indexOf("topic_id");
                    var stringTag = responseXml.indexOf("<string>", idIndex)
                    var stringEndTag = responseXml.indexOf("</string>", idIndex)
                    var id = parseInt(responseXml.substring(stringTag + 8, stringEndTag))

                    pageStack.pop()
                    posted(subjectTextField.text, id)
                }
            }
        }
    }

    ListItem.Header {
        id: subjectHeader
        text: i18n.tr("Subject:")

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: units.gu(1)
        }
    }

    TextArea { //TODO: Fix topMargin; issue related to background???
        id: subjectTextField
        width: parent.width
        autoSize: true
        maximumLineCount: 1
        placeholderText: i18n.tr("Enter Subject")

        anchors {
            top: subjectHeader.bottom
            right: parent.right
            left: parent.left
            topMargin: units.gu(1)
            rightMargin: units.gu(2)
            leftMargin: units.gu(2)
        }

        style: TextAreaStyle {
            overlaySpacing: 0
            frameSpacing: 0
            background: Item {}
        }

        KeyNavigation.priority: KeyNavigation.BeforeItem
        KeyNavigation.tab: messageTextField
    }

    ListItem.Header {
        id: messageHeader
        text: i18n.tr("Message:")

        anchors {
            top: subjectTextField.bottom
            left: parent.left
            right: parent.right
            topMargin: units.gu(1)
        }
    }

    TextArea { //TODO: Fix topMargin; issue related to background???
        id: messageTextField
        autoSize: false
        maximumLineCount: 0
        placeholderText: i18n.tr("Enter Message")

        anchors {
            top: messageHeader.bottom
            bottom: parent.bottom
            right: parent.right
            left: parent.left
            topMargin: units.gu(1)
            bottomMargin: units.gu(1)
            rightMargin: units.gu(2)
            leftMargin: units.gu(2)
        }

        style: TextAreaStyle {
            overlaySpacing: 0
            frameSpacing: 0
            background: Item {}
        }

        KeyNavigation.priority: KeyNavigation.BeforeItem
        KeyNavigation.backtab: subjectTextField
    }
}
