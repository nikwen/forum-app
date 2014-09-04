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
import U1db 1.0 as U1db

Page {
    id: addForumPage
    title: (docId !== "") ? i18n.tr("Edit Forum") : i18n.tr("Add Forum")

    property string docId: ""
    onDocIdChanged: {
        if (docId !== "") {
            var doc = db.getDoc(docId)
            nameTextField.text = doc["name"]
            urlTextField.text = doc["url"]
        }
    }

    head.actions: [
       Action {
            id: save
            iconName: "ok"
            text: docId !== ""?i18n.tr("Edit"):i18n.tr("Add")
            onTriggered: {
                if (nameTextField.text !== "" && urlTextField.text !== "") {
                    //Remove protocol from url (so that there are no multiple instances of one forum but with different prefixes)
                    var url = urlTextField.text
                    var pos = url.indexOf("://")
                    if (pos === 4 || pos === 5) {
                        url = url.substring(pos + 3)
                    }

                    //Check if name or url already exist
                    var docs = db.listDocs()
                    for (var d in docs) {
                        if (docs[d] !== docId) {
                            var contents = db.getDoc(docs[d])
                            if (contents["name"] === nameTextField.text) {
                                notification.show(i18n.tr("Error: Name already exists"))
                                return
                            } else if (contents["url"] === url) {
                                notification.show(i18n.tr("Error: Url already exists"))
                                return
                            }
                        }
                    }

                    if (docId !== "") {
                        var doc = db.getDoc(docId)
                        doc["name"] = nameTextField.text
                        doc["url"] = url
                        db.putDoc(doc, docId)
                        docId = ""
                    } else {
                        db.putDoc({ name: nameTextField.text, url: url })
                    }

                    pageStack.pop()
                } else {
                    if (nameTextField.text.trim() === "") {
                        notification.show(i18n.tr("Error: Name is empty"))
                    } else if (urlTextField.text.trim() === "") {
                        notification.show(i18n.tr("Error: Url is empty"))
                    }
                }
            }
        }
    ]

    head.backAction: Action {
        id: dismissOption
        text: i18n.tr("Dismiss")
        iconName: "close"
        onTriggered: pageStack.pop()
    }

    Column {
        id: column
        spacing: units.gu(1)
        anchors.fill: parent
        anchors.margins: units.gu(2)

        Label {
            id: nameLabel
            text: i18n.tr("Forum-Name:")
            anchors {
                left: column.left;
                right: column.right;
            }

            fontSize: "medium"
        }

        TextField {
            id: nameTextField
            anchors {
                left: column.left;
                right: column.right;
            }

            KeyNavigation.priority: KeyNavigation.BeforeItem
            KeyNavigation.tab: urlTextField
        }

        Label {
            id: urlLabel
            text: i18n.tr("Forum-Url:")
            anchors {
                left: column.left;
                right: column.right;
            }

            fontSize: "medium"
        }

        TextField {
            id: urlTextField
            anchors {
                left: column.left;
                right: column.right;
            }

            inputMethodHints: Qt.ImhUrlCharactersOnly

            KeyNavigation.priority: KeyNavigation.BeforeItem
            KeyNavigation.backtab: nameTextField
        }
    }
}
