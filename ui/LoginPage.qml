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
    id: sheet
    title: qsTr("Login to %1").arg(loginQuery.results[0].name)

    head.backAction: Action {
        id: cancelAction
        text: i18n.tr("Cancel")
        iconName: "close"
        onTriggered: pageStack.pop()
    }

    head.actions: [
        Action {
            id: loginAction
            text: i18n.tr("Login")
            iconName: "ok"

            onTriggered: {
                var doc = db.getDoc(loginQuery.documents[0])
                doc["user"] = nameTextField.text
                doc["password"] = passwordTextField.text
                db.putDoc(doc, loginQuery.documents[0])

                pageStack.pop()
            }
        }

    ]

    U1db.Index {
        database: db
        id: by_forum
        expression: ["name", "url", "user", "password"]
    }

    U1db.Query {
        id: loginQuery
        index: by_forum
        query: ["*", backend.currentSession.forumUrl, "*", "*"]

        onResultsChanged: {
            if (results[0] !== undefined) {
                if (results[0].user !== undefined) nameTextField.text = results[0].user
                if (results[0].password !== undefined) passwordTextField.text = results[0].password
            }
        }
    }

    Column {
        id: column
        spacing: units.gu(1)
        anchors.fill: parent
        anchors.margins: units.gu(2)

        Label {
            id: nameLabel
            text: i18n.tr("User-Name:")
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
            KeyNavigation.tab: passwordTextField
        }

        Label {
            id: passwordLabel
            text: i18n.tr("Password:")
            anchors {
                left: column.left;
                right: column.right;
            }

            fontSize: "medium"
        }

        TextField {
            id: passwordTextField
            anchors {
                left: column.left;
                right: column.right;
            }

            echoMode: TextInput.Password

            KeyNavigation.priority: KeyNavigation.BeforeItem
            KeyNavigation.backtab: nameTextField
        }
    }
}
