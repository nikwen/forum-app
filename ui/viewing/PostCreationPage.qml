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
import "../../stringutils.js" as StringUtils

Page {
    id: postCreationPage
    anchors.fill: parent

    readonly property string signature: i18n.tr("Sent from my awesome Ubuntu Touch device using the Forum Browser app")

    signal posted();

    property int forum_id: -1
    property int topic_id: -1

    title: i18n.tr("New Post")

    Flickable {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: units.gu(1)
        }

        contentHeight: column.height

        Column {
            id: column
            height: childrenRect.height
            width: parent.width
            spacing: units.gu(1)

            Label {
                text: i18n.tr("Subject:")
            }

            TextField {
                id: subjectTextField
                width: parent.width

                KeyNavigation.priority: KeyNavigation.BeforeItem
                KeyNavigation.tab: messageTextField
            }

            Label {
                text: i18n.tr("Message:")
            }

            TextArea {
                id: messageTextField
                width: parent.width

                KeyNavigation.priority: KeyNavigation.BeforeItem
                KeyNavigation.backtab: subjectTextField
            }

            Row {
                id: signatureRow
                width: parent.width
                spacing: units.gu(1)

                CheckBox {
                    id: appendSignatureCheckBox
                    checked: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    id: signatureLabel
                    text: signature
                    wrapMode: Text.Wrap

                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - signatureRow.spacing - appendSignatureCheckBox.width
                }
            }

            Button {
                id: submitButton
                text: i18n.tr("Submit")
                width: parent.width

                onClicked: {
                    var message = messageTextField.text

                    if (appendSignatureCheckBox.checked) {
                        message += "\n\n" + signature
                    }

                    var xhr = new XMLHttpRequest;
                    xhr.open("POST", backend.currentSession.apiSource);
                    xhr.onreadystatechange = function() {
                        if (xhr.readyState === XMLHttpRequest.DONE) {
//                            console.log(xhr.responseText)
                            if (xhr.status === 200) {
                                var resultIndex = xhr.responseText.indexOf("result");
                                var booleanTag = xhr.responseText.indexOf("<boolean>", resultIndex)
                                var booleanEndTag = xhr.responseText.indexOf("</boolean>", resultIndex)
                                var result = xhr.responseText.substring(booleanTag + 9, booleanEndTag)

                                var success = result === "1";

                                if (success) {
                                    pageStack.pop()
                                    posted()
                                } else {
                                    var resultTextIndex = xhr.responseText.indexOf("result_text")
                                    var resultText
                                    if (resultTextIndex > 0) {
                                        var base64Tag = xhr.responseText.indexOf("<base64>", resultTextIndex)
                                        var base64EndTag = xhr.responseText.indexOf("</base64>", resultTextIndex)
                                        resultText = StringUtils.base64_decode(xhr.responseText.substring(base64Tag + 8, base64EndTag))
                                        console.log(resultText)
                                    }
                                    var dialog = PopupUtils.open(errorDialog)
                                    dialog.title = i18n.tr("Action failed")
                                    if (resultText !== undefined) {
                                        dialog.text = i18n.tr("Text returned by the server:\n") + resultText
                                    }
                                }
                            } else {
                                notification.show(i18n.tr("Connection error"))
                            }
                        }
                    }
                    xhr.send('<?xml version="1.0"?><methodCall><methodName>reply_post</methodName><params><param><value>' + forum_id + '</value></param><param><value>' + topic_id + '</value></param><param><value><base64>' + StringUtils.base64_encode(subjectTextField.text) + '</base64></value></param><param><value><base64>' + StringUtils.base64_encode(message) + '</base64></value></param></params></methodCall>');
                }
            }

        }

    }
}
