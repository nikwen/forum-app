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
import Ubuntu.Components.Popups 1.0
import "../components"
import "../../backend"

PageWithBottomEdge {
    id: forumsPage
    objectName: "forumsPage"
    title: i18n.tr("Forums")
    flickable: null

    property bool disableBottomEdge: false
    property alias viewSubscriptions: forumsList.viewSubscriptions //Not via mode for maintainability (e.g. you easily forget to add a && mode === "SUBS" when adding a mode === "" to an if-statement for basic topic list features)

    property alias current_forum: forumsList.current_forum
    property bool isForumOverview: current_forum === 0

    property string selectedTopicId: "-1"
    property string selectedForumId: "-1"
    property string selectedTitle: ""
    property bool selectedCanSubscribe: false
    property bool selectedIsSubscribed: false

    property alias loadingSpinnerRunning: loadingSpinner.running
    property bool showSections: false

    property bool isSubscribed: false
    property bool canSubscribe: false

    property real appHeaderHeight: 0

    bottomEdgeTitle: i18n.tr("Subscriptions")
    bottomEdgeEnabled: !disableBottomEdge && current_forum >= 0 && backend.currentSession.loggedIn
    bottomEdgePageSource: (!disableBottomEdge && current_forum >= 0) ? Qt.resolvedUrl("SubForumPage.qml") : ""

    onBottomEdgeReleased: {
        if (!isCollapsed) {
            bottomEdgePage.appHeaderHeight = appHeaderHeight
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
            component = Qt.createComponent("MessageComposerPage.qml")

            if (component.status === Component.Ready) {
                finishNewTopicPageCreation()
            } else {
                component.statusChanged.connect(finishNewTopicPageCreation)
            }
        }

        function finishNewTopicPageCreation() {
            var page = component.createObject(mainView, { "mode": "thread" })
            page.forum_id = current_forum //Needs to be set after mode
            page.posted.connect(onNewTopicCreated)
            pageStack.push(page)
        }
    }

    Action {
        id: subscribeAction
        text: isSubscribed ? i18n.tr("Unsubscribe") : i18n.tr("Subscribe")
        iconName: isSubscribed ? "starred" : "non-starred"
        visible: backend.currentSession.loggedIn && !viewSubscriptions && backend.currentSession.configModel.subscribeForum && canSubscribe

        onTriggered: subscriptionChange()

        function subscriptionChange() {
            if (isSubscribed) {
                subscribeRequest.query = '<?xml version="1.0"?><methodCall><methodName>unsubscribe_forum</methodName><params><param><value>' + current_forum + '</value></param></params></methodCall>'
            } else {
                subscribeRequest.query = '<?xml version="1.0"?><methodCall><methodName>subscribe_forum</methodName><params><param><value>' + current_forum + '</value></param></params></methodCall>'
            }

            if (subscribeRequest.start()) {
                isSubscribed = !isSubscribed //If the api request fails, it will be changed back later
                subscribeRequest.notificationQueue.push(isSubscribed ? i18n.tr("Subscribed to this subforum") : i18n.tr("Unsubscribed from this subforum"))
            }
        }
    }

    ApiRequest {
        id: subscribeRequest
        checkSuccess: true
        allowMultipleRequests: true
        property var notificationQueue: [] //Needed when subscribeRequest.queryQueue.length > 1

        onQuerySuccessResult: {
            if (success) {
                notification.show(notificationQueue.shift())
            } else {
                isSubscribed = !isSubscribed
                notificationQueue.shift()
            }
        }
    }

    function onNewTopicCreated(subject, forumId, topicId) {
        pushThreadPage(forumId, topicId, subject) //Show thread

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

        anchors {
            centerIn: forumsList
            verticalCenterOffset: appHeaderHeight / 2
        }

        Component.onCompleted: { //Determines header height (needed for offset), then sets flickable
            appHeaderHeight = mainView.height - forumsList.height
            parent.flickable = forumsList
        }
    }

    SubForumList { //TODO-r: Fix bottom edge
        id: forumsList
        anchors.fill: parent

        mode: (forumsPage.head.sections.selectedIndex === 1) ? "TOP" : ((forumsPage.head.sections.selectedIndex === 2) ? "ANN" : "")

    }

    function pushSubForumPage(forumId, title, canSubscribe, isSubscribed) {
        selectedForumId = forumId
        selectedTitle = title
        selectedCanSubscribe = (typeof(canSubscribe) === "boolean" || typeof(canSubscribe) === "number") ? canSubscribe : true
        selectedIsSubscribed = (typeof(isSubscribed) === "boolean" || typeof(isSubscribed) === "number") ? isSubscribed : false
        component = Qt.createComponent("SubForumPage.qml")

        if (component.status === Component.Ready) {
            finishSubForumPageCreation()
        } else {
            component.statusChanged.connect(finishSubForumPageCreation)
        }
    }

    function finishSubForumPageCreation() {
        var page = component.createObject(mainView, {"title": selectedTitle, "current_forum": selectedForumId, "loadingSpinnerRunning": true, "disableBottomEdge": disableBottomEdge, "canSubscribe": selectedCanSubscribe, "isSubscribed": selectedIsSubscribed})
        page.onIsSubscribedChanged.connect(function() { //Change is_subscribed attribute when the subscription state is changed
            for (var i = 0; i < forumsList.model.count; i++) {
                if (forumsList.model.get(i).id === selectedForumId) {
                    forumsList.model.setProperty(i, "is_subscribed", page.isSubscribed ? 1 : 0) //is_subscribed requires a number
                    break
                }
            }
        })
        pageStack.push(page)
    }

    function pushThreadPage(forumId, topicId, title) {
        selectedForumId = forumId
        selectedTopicId = topicId
        selectedTitle = title
        component = Qt.createComponent("ThreadPage.qml")

        if (component.status === Component.Ready) {
            finishThreadPageCreation()
        } else {
            component.statusChanged.connect(finishThreadPageCreation)
        }
    }

    function finishThreadPageCreation() {
        var vBulletinAnnouncement = backend.currentSession.configModel.isVBulletin && forumsList.mode === "ANN"
        var page = component.createObject(mainView, {"title": selectedTitle, "loadingSpinnerRunning": true, "forum_id": selectedForumId, "vBulletinAnnouncement": vBulletinAnnouncement})
        page.current_topic = selectedTopicId //Need to set vBulletinAnnouncement before current_topic!!! Therefore, this is executed after the creation of the Page.
        pageStack.push(page)
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

}
