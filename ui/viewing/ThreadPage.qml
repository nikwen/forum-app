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
import Ubuntu.Components.Popups 1.0
import "../components"

PageWithBottomEdge {
    id: threadPage
    flickable: null

    property alias current_topic: threadList.current_topic
    property int forum_id: -1
    property alias vBulletinAnnouncement: threadList.vBulletinAnnouncement

    property alias loadingSpinnerRunning: loadingSpinner.running

    property int pageCount: Math.floor(threadList.totalPostCount/backend.postsPerPage + (threadList.totalPostCount % backend.postsPerPage === 0 ? 0 : 1))

    bottomEdgePageSource: "PostCreationPage.qml"
    bottomEdgeTitle: i18n.tr("New Post")
    bottomEdgeEnabled: backend.currentSession.loggedIn && threadList.canReply && !threadList.isClosed && !vBulletinAnnouncement

    onBottomEdgeReleased: {
        if (bottomEdgePage !== null) {
            bottomEdgePage.forum_id = forum_id
            bottomEdgePage.topic_id = current_topic
            bottomEdgePage.posted.connect(threadList.reload)
        }
    }

    Component.onCompleted: {
        header.show() //Workaround to show the header when it was previously hidden in SubForumPage
    }

    head.actions: [
        Action {
            id: loginAction
            text: i18n.tr("Login")
            iconName: "contact"
            visible: !backend.currentSession.loggedIn
            onTriggered: {
                pageStack.push(loginPage)
            }
        },
        Action {
            id: gotoAction
            text: i18n.tr("Go To Page")
            iconName: "view-list-symbolic"
            visible: !vBulletinAnnouncement && threadList.totalPostCount > backend.postsPerPage
            onTriggered: {
                var popup = PopupUtils.open(pageSelectionDialog, pageLabel)
                var selected = threadList.firstDisplayedPost / backend.postsPerPage
                popup.itemSelector.selectedIndex = selected
//                popup.itemSelector.positionViewAtIndex(selected, ListView.Center) //TODO: Add to UI Toolkit?
            }
        },
        Action {
            id: reloadAction
            text: i18n.tr("Reload")
            iconName: "reload"
            onTriggered: {
                threadList.reload()
            }
        }
    ]

    head.contents: Label {
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        text: threadPage.title
        fontSize: "x-large"
        maximumLineCount: fontSize === "medium" ? 2 : 1
        wrapMode: Text.WordWrap
        elide: Text.ElideRight

        onTruncatedChanged: {
            if (truncated) {
                fontSize = "large"
                if (truncated) {
                    fontSize = "medium"
                }
            }
        }
    }

    head.backAction: Action {
        text: i18n.tr("Back")
        iconName: "back"
        onTriggered: {
            pageStack.pop()
            threadPage.destroy(500)
        }
    }

    ActivityIndicator {
        id: loadingSpinner
        anchors.centerIn: threadList
    }

    Row {
        id: buttonsRow

        anchors {
            top: parent.top
            topMargin: units.gu(1)
            bottomMargin: units.gu(1)
            horizontalCenter: parent.horizontalCenter
        }

        spacing: units.gu(2)

        Icon {
            name: "media-skip-backward"
            width: units.gu(4)
            height: units.gu(4)

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (threadList.firstDisplayedPost !== 0) {
                        threadList.loadPosts(0, backend.postsPerPage);
                    }
                }
            }
        }

        Icon {
            name: "media-playback-start-rtl"
            width: units.gu(4)
            height: units.gu(4)

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (threadList.firstDisplayedPost > 0) {
                        threadList.loadPosts(Math.max(threadList.firstDisplayedPost - backend.postsPerPage, 0), backend.postsPerPage);
                    }
                }
            }
        }

        Label {
            id: pageLabel
            anchors.verticalCenter: parent.verticalCenter
            fontSize: "large"

            text: threadList.totalPostCount !== -1 ? (Math.floor(threadList.firstDisplayedPost/backend.postsPerPage + 1) + " / " + pageCount) : ""
        }

        Icon {
            name: "media-playback-start"
            width: units.gu(4)
            height: units.gu(4)

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (threadList.lastDisplayedPost < threadList.totalPostCount - 1) {
                        threadList.loadPosts(threadList.lastDisplayedPost + 1, backend.postsPerPage);
                    }
                }
            }
        }

        Icon {
            name: "media-skip-forward"
            width: units.gu(4)
            height: units.gu(4)

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    var postsOnLastPage = ((threadList.totalPostCount) % backend.postsPerPage);
                    var beginningLastPage = threadList.totalPostCount - (postsOnLastPage === 0 ? backend.postsPerPage : postsOnLastPage);
                    if (beginningLastPage !== threadList.firstDisplayedPost) {
                        threadList.loadPosts(beginningLastPage, backend.postsPerPage);
                    }
                }
            }
        }
    }

    ThreadList {
        id: threadList
        anchors {
            top: buttonsRow.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
    }

    Component {
        id: pageSelectionDialog

        Dialog {
            id: dialog
            title: i18n.tr("Go to")

            property alias itemSelector: selector

            ItemSelector {
                id: selector
                expanded: true

                containerHeight: itemHeight * Math.min(model.count, 8)

                model: ListModel {
                    Component.onCompleted: {
                        for (var i = 0; i < pageCount; i++) {
                            append({pageText: qsTr(i18n.tr("Page %1 (Post %2 - %3)")).arg(i + 1).arg(i * 10 + 1).arg(Math.min((i + 1) * 10, threadList.totalPostCount))})
                        }
                    }
                }

                delegate: OptionSelectorDelegate {
                    text: pageText

                    onTriggered: {
                        var firstPost = index * backend.postsPerPage
                        if (firstPost !== threadList.firstDisplayedPost) {
                            threadList.loadPosts(firstPost, backend.postsPerPage)
                        }
                        PopupUtils.close(dialog)
                    }
                }
            }
        }
    }

}
