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

Page {
    id: postCreationPage
    anchors.fill: parent

    signal posted();

    property int forum_id: -1
    property int topic_id: -1

    title: i18n.tr("New Post")

    head.actions: [
        Action {
            id: submitAction
            text: i18n.tr("Submit")
            iconName: "ok"

            onTriggered: submit()

            function submit() {
                var message = messageTextField.text

                if (appendSignatureCheckBox.checked) {
                    message += "\n\n" + backend.signature
                }

                submitRequest.query = '<?xml version="1.0"?><methodCall><methodName>reply_post</methodName><params><param><value>' + forum_id + '</value></param><param><value>' + topic_id + '</value></param><param><value><base64>' + StringUtils.base64_encode(subjectTextField.text) + '</base64></value></param><param><value><base64>' + StringUtils.base64_encode(message) + '</base64></value></param></params></methodCall>'

                submitRequest.start()
            }
        }
    ]

    ApiRequest {
        id: submitRequest
        checkSuccess: true

        onQuerySuccessResult: {
            if (success) {
                pageStack.pop()
                posted()
            }
        }
    }

    Flickable {
        anchors.fill: parent

        contentHeight: column.height + units.gu(1) //For a margin at the bottom

        Column {
            id: column
            height: childrenRect.height
            width: parent.width
            spacing: units.gu(1)

            ListItem.Header {
                text: i18n.tr("Subject:")
            }

            TextArea {
                id: subjectTextField
                width: parent.width
                autoSize: true
                maximumLineCount: 1
                placeholderText: i18n.tr("Enter Subject")

                anchors {
                    right: parent.right
                    left: parent.left
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
                text: i18n.tr("Message:")
            }

            TextArea {
                id: messageTextField
                autoSize: true
                maximumLineCount: 0
                placeholderText: i18n.tr("Enter Message")

                anchors {
                    right: parent.right
                    left: parent.left
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

            Row {
                id: signatureRow
                spacing: units.gu(1)

                anchors {
                    right: parent.right
                    left: parent.left
                    rightMargin: units.gu(2)
                    leftMargin: units.gu(2)
                }

                CheckBox {
                    id: appendSignatureCheckBox
                    checked: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    id: signatureLabel
                    text: backend.signature
                    wrapMode: Text.Wrap

                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - signatureRow.spacing - appendSignatureCheckBox.width
                }
            }

        }

    }
}
