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
import "ui"
import "ui/viewing"
import "ui/components"
import "backend"

MainView {
    id: mainView

    applicationName: "com.ubuntu.developer.nikwen.forum-app"

    width: units.gu(50)
    height: units.gu(75)

    useDeprecatedToolbar: false

    anchorToKeyboard: true

    U1db.Database {
        id: db
        path: "forums.u1db"
    }

    U1db.Document {
        id: forumsDocument
        database: db
        docId: 'xda-default'
        create: true
        defaults: { "name": "XDA Developers", "url": "forum.xda-developers.com", "user": "", "password": "" }
    }

    U1db.Database {
        id: draftsDb
        path: "drafts.u1db"
    }

    U1db.Index {
        id: draftsIndex
        database: draftsDb
        expression: [ "forum_url", "username", "forum_id", "topic_id", "subject", "message" ]
    }

    PageStack {
        id: pageStack

        Component.onCompleted: {
            pageStack.push(forumsListPage);
        }
    }

    Notification {
        id: notification
    }

    ForumsListPage {
        id: forumsListPage
        visible: false
    }

    LoginPage {
        id: loginPage
        visible: false
    }

    ForumBackend {
        id: backend
    }
}
