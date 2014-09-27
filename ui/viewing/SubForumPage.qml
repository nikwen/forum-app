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
import Ubuntu.Components.Popups 1.0
import "../components"
import "../../backend"

PageWithBottomEdge {
    id: forumsPage
    objectName: "forumsPage"
    title: i18n.tr("Forums")

    property bool disableBottomEdge: false
    property alias viewSubscriptions: forumsList.viewSubscriptions //Not via mode for maintainability (e.g. you easily forget to add a && mode === "SUBS" when adding a mode === "" to an if-statement for basic topic list features)

    property alias current_forum: forumsList.current_forum
    property bool isForumOverview: current_forum === 0

    property alias selectedTitle: forumsList.selected_title

    property alias loadingSpinnerRunning: loadingSpinner.running
    property bool showSections: false

    bottomEdgeTitle: i18n.tr("Subscriptions")
    bottomEdgeEnabled: !disableBottomEdge && current_forum >= 0 && backend.currentSession.loggedIn
    bottomEdgePageSource: (!disableBottomEdge && current_forum >= 0) ? Qt.resolvedUrl("SubForumPage.qml") : ""

    onBottomEdgeReleased: {
        if (!isCollapsed) {
            bottomEdgePage.loadingSpinnerRunning = true
            bottomEdgePage.viewSubscriptions = true
            bottomEdgePage.title = i18n.tr("Subscriptions")
            bottomEdgePage.disableBottomEdge = true
        }
    }

    Connections {
        target: pageStack

        property var previousPage: null

        onCurrentPageChanged: {
            if (pageStack.currentPage === forumsPage && previousPage !== null && (previousPage.objectName === "threadPage" || (previousPage.objectName === "forumsPage" && !previousPage.viewSubscriptions))) {
                console.log("Destroy page")
                previousPage.destroy()
            }
            previousPage = pageStack.currentPage
        }
    }

    Connections {
        target: pageStack

        onCurrentPageChanged: { //Reload when going back to the subscriptions page
            if (viewSubscriptions && pageStack.currentPage === forumsPage && forumsList.modelsHaveLoadedCompletely) {
                forumsList.reload()
            }
        }
    }

    Action {
        id: reloadAction
        text: i18n.tr("Reload")
        iconName: "reload"
        onTriggered: {
            if (!backend.currentSession.configModel.hasLoaded) { //e.g. if there was no internet connection, when the forum was opened
                backend.currentSession.configModel.loadConfig()
            } else {
                forumsList.reload()
            }
        }
    }

    Action {
        id: loginAction
        text: i18n.tr("Login")
        iconName: "contact"
        onTriggered: {
            pageStack.push(loginPage)
        }
    }

    Action {
        id: newTopicAction
        text: i18n.tr("New Topic")
        iconName: "compose"
        visible: backend.currentSession.loggedIn && current_forum > 0 && forumsList.canPost && forumsList.mode === "" && forumsList.hasTopics //hasTopics as a workaround for disabling posting in category-only subforums; current_forum > 0 also disables the action when viewSubscriptions === true
        onTriggered: {
            component = Qt.createComponent("ThreadCreationPage.qml")

            if (component.status === Component.Ready) {
                finishNewTopicPageCreation()
            } else {
                component.statusChanged.connect(finishNewTopicPageCreation)
            }
        }

        function finishNewTopicPageCreation() {
            var page = component.createObject(mainView, {"forum_id": current_forum})
            page.posted.connect(onNewTopicCreated)
            pageStack.push(page)
        }
    }

    Action {
        id: subscribeAction
        text: forumsList.isSubscribed ? i18n.tr("Unsubscribe") : i18n.tr("Subscribe")
        iconName: forumsList.isSubscribed ? "starred" : "non-starred"
        visible: backend.currentSession.loggedIn && !viewSubscriptions && backend.currentSession.configModel.subscribeForum && forumsList.canSubscribe

        onTriggered: subscriptionChange()

        function subscriptionChange() {
            if (forumsList.isSubscribed) {
                subscribeRequest.query = '<?xml version="1.0"?><methodCall><methodName>unsubscribe_forum</methodName><params><param><value>' + current_forum + '</value></param></params></methodCall>'
            } else {
                subscribeRequest.query = '<?xml version="1.0"?><methodCall><methodName>subscribe_forum</methodName><params><param><value>' + current_forum + '</value></param></params></methodCall>'
            }

            forumsList.isSubscribed = !forumsList.isSubscribed //If the api request fails, it will be changed back later

            subscribeRequest.start()
        }
    }

    ApiRequest {
        id: subscribeRequest
        checkSuccess: true

        onQuerySuccessResult: {
            if (success) {
                notification.show(forumsList.isSubscribed ? i18n.tr("Subscribed to this subforum") : i18n.tr("Unsubscribed from this subforum"))
            } else {
                forumsList.isSubscribed = !forumsList.isSubscribed
            }
        }
    }

    function onNewTopicCreated(subject, topicId) {
        selectedTitle = subject
        forumsList.current_topic = -1
        forumsList.current_topic = topicId //Show topic

        forumsList.reload()
    }

    readonly property var headerActions: [
        reloadAction,
        newTopicAction,
        subscribeAction,
        loginAction
    ]

    Connections {
        target: forumsList
        onHasTopicsChanged: {
            if (forumsList.hasTopics && forumsList.mode === "" && !viewSubscriptions) {
                showSections = true
            }
        }
    }

    state: showSections ? "topics" : "no_topics" //e.g. show message "no stickies"
    onStateChanged: console.log("state: " + state)

    states: [
        PageHeadState {
            id: noTopicsState
            name: "no_topics"
            head: forumsPage.head
            actions: headerActions
        },
        PageHeadState {
            id: topicsState
            name: "topics"
            head: forumsPage.head

            PropertyChanges {
                target: forumsPage.head
                sections.enabled: forumsList.modelsHaveLoadedCompletely
                sections.model: [i18n.tr("Standard"), i18n.tr("Stickies"), i18n.tr("Announcements")]
                sections.selectedIndex: 0
                actions: headerActions
            }
        }
    ]

    ActivityIndicator {
        id: loadingSpinner
        anchors.centerIn: forumsList
    }

    SubForumList {
        id: forumsList
        height: parent.height //No anchors.fill due to bottom edge
        width: parent.width

        mode: (forumsPage.head.sections.selectedIndex === 1) ? "TOP" : ((forumsPage.head.sections.selectedIndex === 2) ? "ANN" : "")

        onSelected_forumChanged: {
            if (selected_forum > 0) {
                component = Qt.createComponent("SubForumPage.qml");

                if (component.status === Component.Ready) {
                    finishSubForumPageCreation();
                } else {
                    component.statusChanged.connect(finishSubForumPageCreation);
                }
            }
        }

        function finishSubForumPageCreation() {
            var page = component.createObject(mainView, {"title": selectedTitle, "current_forum": selected_forum, "loadingSpinnerRunning": true, "disableBottomEdge": disableBottomEdge})
            pageStack.push(page)
        }

        onCurrent_topicChanged: {
            if (current_topic > 0) {
                component = Qt.createComponent("ThreadPage.qml")

                if (component.status === Component.Ready) {
                    finishThreadPageCreation();
                } else {
                    component.statusChanged.connect(finishThreadPageCreation);
                }
            }
        }

        function finishThreadPageCreation() {
            var vBulletinAnnouncement = backend.currentSession.configModel.isVBulletin && forumsList.mode === "ANN"
            var page = component.createObject(mainView, {"title": selectedTitle, "loadingSpinnerRunning": true, "forum_id": current_forum, "vBulletinAnnouncement": vBulletinAnnouncement})
            page.current_topic = current_topic //Need to set vBulletinAnnouncement before current_topic!!! Therefore, this is executed after the creation of the Page.
            pageStack.push(page)
        }
    }

    Label {
        id: emptyView
        text: viewSubscriptions ? i18n.tr("You are not subscribed to any topics or forums") : ((forumsList.mode === "") ? i18n.tr("No topics available here") : ((forumsList.mode === "TOP") ? i18n.tr("No stickies available here") : i18n.tr("No announcements available here")))
        visible: forumsList.model.count === 0 && !loadingSpinnerRunning && (current_forum > 0 || viewSubscriptions)
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        fontSize: "large"
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            right: parent.right
            margins: units.gu(2)
        }
    }

    Scrollbar {
        flickableItem: forumsList
        align: Qt.AlignTrailing
    }

}
