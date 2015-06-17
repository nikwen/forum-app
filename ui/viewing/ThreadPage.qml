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
import Ubuntu.Components.Popups 1.0
import "../components"
import "../../backend"

//TODO: Horizontal swiping

PageWithBottomEdge {
    id: threadPage
    objectName: "threadPage"
    flickable: null

    property alias current_topic: threadList.current_topic
    property string forum_id: "-1"
    property alias vBulletinAnnouncement: threadList.vBulletinAnnouncement

    property int pageCount: Math.floor(threadList.totalPostCount/backend.postsPerPage + (threadList.totalPostCount % backend.postsPerPage === 0 ? 0 : 1))

    bottomEdgePageSource: "MessageComposerPage.qml"
    bottomEdgeTitle: i18n.tr("New Post")
    bottomEdgeEnabled: backend.currentSession.loggedIn && threadList.canReply && !threadList.isClosed && !vBulletinAnnouncement

    onBottomEdgeReleased: {
        if (bottomEdgePage !== null) {
            bottomEdgePage.mode = "post"
            bottomEdgePage.forum_id = forum_id
            bottomEdgePage.topic_id = current_topic
            bottomEdgePage.posted.connect(threadList.reload)
        }
    }

    Connections {
        target: pageStack

        property var previousPage: null

        onCurrentPageChanged: {
            if (pageStack.currentPage === threadPage && previousPage !== null && (previousPage.objectName === "threadPage" || (previousPage.objectName === "forumsPage" && !previousPage.viewSubscriptions))) {
                console.log("Destroy page")
                previousPage.destroy()
            }
            previousPage = pageStack.currentPage
        }
    }

    function openPageSelectionDialog() {
        PopupUtils.open(pageSelectionDialog)
    }

    function goToPage(pageNumber) { //Starting with 0
        if (pageNumber >= 0 && pageNumber < pageCount) {
            var firstPost = pageNumber * backend.postsPerPage
            if (firstPost !== threadList.firstDisplayedPost) {
                threadList.loadPosts(firstPost, backend.postsPerPage)
            }
        }
    }

    function goToFirstPage() {
        if (threadList.firstDisplayedPost !== 0) {
            threadList.loadPosts(0, backend.postsPerPage);
        }
    }

    function goToPreviousPage() {
        if (threadList.firstDisplayedPost > 0) {
            threadList.loadPosts(Math.max(threadList.firstDisplayedPost - backend.postsPerPage, 0), backend.postsPerPage);
        }
    }

    function goToNextPage() {
        if (threadList.lastDisplayedPost < threadList.totalPostCount - 1) {
            threadList.loadPosts(threadList.lastDisplayedPost + 1, backend.postsPerPage);
        }
    }

    function goToLastPage() {
        var postsOnLastPage = (threadList.totalPostCount % backend.postsPerPage);
        var beginningLastPage = threadList.totalPostCount - (postsOnLastPage === 0 ? backend.postsPerPage : postsOnLastPage);
        if (beginningLastPage !== threadList.firstDisplayedPost) {
            threadList.loadPosts(beginningLastPage, backend.postsPerPage);
        }
    }

    head.actions: [
        Action {
            id: reloadAction
            text: i18n.tr("Reload")
            iconName: "reload"
            onTriggered: {
                threadList.reload()
            }
        },
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
            id: subscribeAction
            text: threadList.isSubscribed ? i18n.tr("Unsubscribe") : i18n.tr("Subscribe")
            iconName: threadList.isSubscribed ? "starred" : "non-starred"
            visible: backend.currentSession.loggedIn && threadList.canSubscribe

            onTriggered: subscriptionChange()

            function subscriptionChange() {
                if (threadList.isSubscribed) {
                    subscribeRequest.query = '<?xml version="1.0"?><methodCall><methodName>unsubscribe_topic</methodName><params><param><value>' + current_topic + '</value></param></params></methodCall>'
                } else {
                    subscribeRequest.query = '<?xml version="1.0"?><methodCall><methodName>subscribe_topic</methodName><params><param><value>' + current_topic + '</value></param></params></methodCall>'
                }

                if (subscribeRequest.start()) {
                    threadList.isSubscribed = !threadList.isSubscribed //If the api request fails, it will be changed back later
                    subscribeRequest.notificationQueue.push(threadList.isSubscribed ? i18n.tr("Subscribed to this topic") : i18n.tr("Unsubscribed from this topic"))
                }
            }
        },
        Action {
            id: gotoAction
            text: i18n.tr("Go To Page")
            iconName: "view-list-symbolic"
            visible: !vBulletinAnnouncement && threadList.totalPostCount > backend.postsPerPage
            onTriggered: {
                openPageSelectionDialog()
            }
        }
    ]

    ApiRequest {
        id: subscribeRequest
        checkSuccess: true
        allowMultipleRequests: true
        property var notificationQueue: [] //Needed when subscribeRequest.queryQueue.length > 1

        onQuerySuccessResult: {
            if (success) {
                notification.show(notificationQueue.shift())
            } else {
                threadList.isSubscribed = !threadList.isSubscribed
                notificationQueue.shift()
            }
        }
    }

    head.contents: Label {
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        text: threadPage.title
        fontSize: "x-large"
        maximumLineCount: fontSize === "medium" ? 2 : 1
        wrapMode: Text.Wrap
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

    ActivityIndicator {
        id: loadingSpinner
        anchors.centerIn: threadList

        running: threadList.count === 0 //TODO-r: Empty view (when network is switched off while loading)

        Component.onCompleted: { //Determines header height and sets offset, then sets flickable
            anchors.verticalCenterOffset = (mainView.height - threadList.height) / 2
            parent.flickable = threadList
        }
    }

    ThreadList {
        id: threadList
        anchors.fill: parent
    }

    Component {
        id: pageSelectionDialog

        Dialog {
            id: dialog
            title: i18n.tr("Go to page")

            TextField {
                id: goToTextField
                inputMethodHints: Qt.ImhDigitsOnly
                placeholderText: i18n.tr("Enter page number")

                onTextChanged: goToErrorLabel.visible = false
            }

            Label {
                id: goToErrorLabel
                text: i18n.tr("Invalid page number")
                color: UbuntuColors.red
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                visible: false
            }

            Button {
                id: goToButton
                text: i18n.tr("Go")
                color: UbuntuColors.green

                onClicked: {
                    if (goToTextField.text > 0 && goToTextField.text <= pageCount) {
                        goToPage(goToTextField.text - 1)
                        PopupUtils.close(dialog)
                    } else {
                        goToErrorLabel.visible = true
                    }
                }
            }

            Button {
                id: goToCancelButton
                text: i18n.tr("Cancel")
                color: UbuntuColors.red

                onClicked: PopupUtils.close(dialog)
            }
        }
    }
}
