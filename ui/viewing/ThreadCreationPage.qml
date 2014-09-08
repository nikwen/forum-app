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
    id: threadCreationPage
    anchors.fill: parent

    readonly property string signature: i18n.tr("Sent from my awesome Ubuntu Touch device using the Forum Browser app")

    signal posted(string subject, int topicId);

    property int forum_id: -1
    property int topic_id: -1

    title: i18n.tr("New Topic")

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

                onClicked: submit()

                function submit(session) { //parameter only for connection with loginDone
                    if (session !== undefined) {
                        if (session === backend.currentSession) {
                            backend.loginDone.disconnect(submit)
                        } else {
                            return
                        }
                    }

                    var message = messageTextField.text

                    if (appendSignatureCheckBox.checked) {
                        message += "\n\n" + signature
                    }

                    var xhr = new XMLHttpRequest;
                    xhr.open("POST", backend.currentSession.apiSource);
                    var onReadyStateChangeFunction = function() {
                        if (xhr.readyState === XMLHttpRequest.DONE) {
//                            console.log(xhr.responseText)
                            if (xhr.status === 200) {
                                var resultIndex = xhr.responseText.indexOf("result");
                                var booleanTag = xhr.responseText.indexOf("<boolean>", resultIndex)
                                var booleanEndTag = xhr.responseText.indexOf("</boolean>", resultIndex)
                                var result = xhr.responseText.substring(booleanTag + 9, booleanEndTag)

                                var success = result === "1";

                                if (success) {
                                    //Get the id of the topic
                                    var idIndex = xhr.responseText.indexOf("topic_id");
                                    var stringTag = xhr.responseText.indexOf("<string>", idIndex)
                                    var stringEndTag = xhr.responseText.indexOf("</string>", idIndex)
                                    var id = parseInt(xhr.responseText.substring(stringTag + 8, stringEndTag))

                                    pageStack.pop()
                                    posted(subjectTextField.text, id)
                                } else {
                                    if (xhr.getResponseHeader("Mobiquo_is_login") === "false" && backend.currentSession.loggedIn) {
                                        if (backend.currentSession.loginFinished) { //login might already have been started in categoryModel
                                            backend.login() //Connection to loginDone will care about reloading afterwards
                                            backend.loginDone.connect(submit)
                                        }
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
                                }
                            } else {
                                notification.show(i18n.tr("Connection error"))
                            }
                        }
                    }
                    xhr.onreadystatechange = onReadyStateChangeFunction
                    xhr.send('<?xml version="1.0"?><methodCall><methodName>new_topic</methodName><params><param><value>' + forum_id + '</value></param><param><value><base64>' + StringUtils.base64_encode(subjectTextField.text) + '</base64></value></param><param><value><base64>' + StringUtils.base64_encode(message) + '</base64></value></param></params></methodCall>');
                }
            }

        }

    }
}
