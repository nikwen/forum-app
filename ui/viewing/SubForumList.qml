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
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import "../../stringutils.js" as StringUtils


ListView {
    id: forumsList

    property alias current_forum: categoryModel.parentForumId
    property int current_topic: -1
    property int selected_forum: -1
    property string selected_title: ""
    property bool canPost: false
    property bool hasTopics: false
    property string mode: ""
    property bool moreLoading: false

    property bool viewSubscriptions: false

    readonly property bool modelLoading: (categoryModel.status === XmlListModel.Loading) || (topicModel.status === XmlListModel.Loading)
    readonly property bool modelsHaveLoadedCompletely: categoryModel.hasLoadedCompletely && topicModel.hasLoadedCompletely

    clip: true

    onModeChanged: reload()

    delegate: SubForumListItem {
        text: StringUtils.base64_decode(model.name)
        subText: StringUtils.base64_decode(model.description)
        replies: model.topic ? (parseInt(model.posts) + 1) : 0 //+1 to include OP
        author: model.topic ? StringUtils.base64_decode(model.author) : ""
        has_new: model.has_new === '1' ? true : false
        progression: true

        onTriggered: {
            selected_title = text
            if (model.topic) {
                current_topic = -1
                current_topic = model.id
            } else {
                selected_forum = -1
                selected_forum = model.id
            }
        }

        Component.onCompleted: {
            if (modelsHaveLoadedCompletely && hasTopics && mode === "" && index === forumListModel.count - 3 && forumListModel.count % backend.topicsLoadCount === categoryModel.count) {
                console.log("load more, index: " + index)
                loadMore(backend.topicsLoadCount)
            }
        }
    }

    footer: Standard { //ListItem.Standard
        visible: moreLoading
        width: parent.width
        height: visible ? units.gu(6) : 0
        divider.visible: false

        ActivityIndicator {
            id: loadMoreIndicator
            running: visible
            anchors.centerIn: parent
        }
    }

    model: ListModel {
        id: forumListModel

        Component.onCompleted: {
            backend.loginDone.connect(clearSetLoadingOnLoginDone)
        }

        Component.onDestruction: {
            backend.loginDone.disconnect(clearSetLoadingOnLoginDone)
        }

        function clearSetLoadingOnLoginDone(session) {
            if (session === backend.currentSession) {
                clearSetLoading()
            }
        }

        function clearSetLoading() {
            clear()
            loadingSpinnerRunning = true
        }
    }

    function topicCount() {
       var count = 0;
       for (var i = 0; i < forumListModel.count; i++) {
           if (forumListModel.get(i).topic) {
               count++;
           }
       }
       return count;
    }

    function loadMore(count) {
        moreLoading = true
        var tCount = topicCount();
        topicModel.__loadTopics(tCount, tCount + count - 1);
    }

    function reload() {
        forumListModel.clear()
        loadingSpinner.running = true
        if (mode === "") {
            categoryModel.__loadForums()
        }
        topicModel.__loadTopics()
    }

    XmlListModel {
        id: categoryModel
        objectName: "categoryModel"

        property bool hasLoadedCompletely: true

        property int parentForumId: -1
        property bool viewSubscriptions: forumsList.viewSubscriptions
        query: viewSubscriptions ? "/methodResponse/params/param/value/struct/member[name='forums']/value/array/data/value/struct" : "/methodResponse/params/param/value/array/data/value/struct"

        XmlRole { name: "id"; query: "member[name='forum_id']/value/string()" }
        XmlRole { name: "name"; query: "member[name='forum_name']/value/base64/string()" }
        XmlRole { name: "description"; query: "member[name='description']/value/base64/string()" }
        XmlRole { name: "logo"; query: "member[name='logo_url']/value/string()" }

        property bool checkingForChildren: false

        onStatusChanged: {
            if (status === 1) {
//                console.log(xml) //Do not run on XDA home!!! (Too big, will freeze QtCreator)
                if (!checkingForChildren) {
                    console.debug("categoryModel has: " + count + " items");

                    if (count !== 1 || parentForumId !== parseInt(get(0).id)) {
                        insertResults()
                    } else { //Header with a child attribute
                        if (!topicModel.hasLoadedCompletely) {
                            topicModel.onHasLoadedCompletelyChanged.connect(loadChildren)
                        } else {
                            loadChildren()
                        }
                    }
                } else {
                    checkingForChildren = false
                    switch (count) {
                    case 0: //Check for id
                        console.log("no subs")
                        loadingFinished()
                        break
                    default:
                        console.log("Subs")
                        insertResults()
                    }
                }


            }
        }

        function loadChildren() { //Reloading should overall be faster than loading the children attribute for every item
            topicModel.onHasLoadedCompletelyChanged.disconnect(loadChildren)

            checkingForChildren = true

            query = "/methodResponse/params/param/value/array/data/value/struct/member[name='child']/value/array/data/value/struct"
            __loadForums()
        }

        function insertResults() { //If changed, adjust above as well
            for (var i = 0; i < count; i++) {
                var element = get(i)
                //We need to declare even unused properties here
                //Needed when there are both topics and categories in a subforum
                forumListModel.insert(i, {"topic": false, "id": element.id.trim(), "name": element.name.trim(), "description": element.description.trim(), "logo": element.logo.trim(), "author": "", "posts": "-1", "has_new": "0"});
            }

            loadingFinished()
        }

        function loadingFinished() {
            hasLoadedCompletely = true
            loadingSpinner.running = !(topicModel.hasLoadedCompletely || current_forum === 0)
        }

        Component.onCompleted: {
            backend.loginDone.connect(loadOnLoginDone)
        }

        Component.onDestruction: {
            backend.loginDone.disconnect(loadOnLoginDone)
        }

        onParentForumIdChanged: if (backend.currentSession.loginFinished) __loadForums()
        onViewSubscriptionsChanged: if (viewSubscriptions && backend.currentSession.loginFinished) __loadForums()

        function loadOnLoginDone(session) {
            if (session === backend.currentSession) {
                __loadForums()
            }
        }

        function __loadForums() {
            if (parentForumId < 0 && !viewSubscriptions) {
                return;
            }

            console.log("loading categories")

            hasLoadedCompletely = false

            var xhr = new XMLHttpRequest;
            categoryModel.xml="";
            xhr.open("POST", backend.currentSession.apiSource);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200) {
//                        console.log(xhr.responseText)
                        categoryModel.xml = StringUtils.xmlFromResponse(xhr.responseText)
                    } else {
                        notification.show(i18n.tr("Connection error"))

                        loadingFinished()
                    }
                }
            }
            if (!viewSubscriptions) {
                xhr.send('<?xml version="1.0"?><methodCall><methodName>get_forum</methodName><params><param><value><boolean>true</boolean></value></param><param><value>'+parentForumId+'</value></param></params></methodCall>');
            } else {
                xhr.send('<?xml version="1.0"?><methodCall><methodName>get_subscribed_forum</methodName></methodCall>')
            }


        }
    }

    XmlListModel {
        id: topicModel
        objectName: "topicModel"

        property bool hasLoadedCompletely: true

        property int forumId: current_forum
        property bool viewSubscriptions: forumsList.viewSubscriptions
        query: "/methodResponse/params/param/value/struct/member/value/array/data/value/struct"

        XmlRole { name: "id"; query: "member[name='topic_id']/value/string()" }
        XmlRole { name: "title"; query: "member[name='topic_title']/value/base64/string()" }
//        XmlRole { name: "description"; query: "member[name='short_content']/value/base64/string()" }
        XmlRole { name: "author"; query: "member[name='topic_author_name']/value/base64/string()" }
        XmlRole { name: "posts"; query: "member[name='reply_number']/value/int/string()" }
        XmlRole { name: "has_new"; query: "member[name='new_post']/value/boolean/string()" }

        onStatusChanged: {
            if (status === 1) {
                if (count > 0) {
                    hasTopics = true //no else needed (and it may interfere with moreLoading)

                    //TODO: Check if if is needed or if it won't be added twice even without the if
                    if (count === 1 && forumListModel.count > 0 && get(0).id.trim() === forumListModel.get(forumListModel.count - 1).id && forumListModel.get(forumListModel.count - 1).topic === true) {
                        //Do not add the element as it is a duplicate of the last one which was added
                        //Happens if a forum contains n * backend.topicsLoadCount topics (with n = 2, 3, 4, ...) and loadMore() is called (sadly, that's how the API handles the request)

                        console.log("Don't add duplicate topic (n * backend.topicsLoadCount posts)")

                        showNoMoreNotification()
                    } else {
                        //Add to forumListModel

                        console.debug("topicModel has: " + count + " items");

                        for (var i = 0; i < count; i++) {
                            var element = get(i);
                            //We need to declare even unused properties here
                            //Needed when there are both topics and categories in a subforum
                            forumListModel.append({"topic": true, "id": element.id.trim(), "name": element.title.trim(), "description": "" /*element.description.trim()*/, "logo": "", "author": element.author.trim(), "posts": element.posts.trim(), "has_new": element.has_new.trim()});
                        }
                    }
                }

//                console.log(xml)

                //Check if the user is allowed to create a new topic

                var canPostStringPosition = xml.indexOf("<name>can_post</name>");
                if (canPostStringPosition < 0) {
                    canPost = true
                } else {
                    var openBoolTagPosition = xml.indexOf("<boolean>", canPostStringPosition);
                    var closeBoolTagPosition = xml.indexOf("</boolean>", openBoolTagPosition);
                    var canPostSubstring = xml.substring(openBoolTagPosition + 9, closeBoolTagPosition); //equals + "<boolean>".length

                    canPost = canPostSubstring.trim() === "1"
                }

                loadingFinished()
            }
        }

        function showNoMoreNotification() {
            notification.show(i18n.tr("No more threads to load"))
        }

        function loadingFinished() {
            if (count === 0 && moreLoading) {
                showNoMoreNotification()
            }

            moreLoading = false
            hasLoadedCompletely = true
            loadingSpinner.running = !categoryModel.hasLoadedCompletely
        }

        Component.onCompleted: {
            backend.loginDone.connect(loadOnLoginDone)
        }

        Component.onDestruction: {
            backend.loginDone.disconnect(loadOnLoginDone)
        }

        function loadOnLoginDone(session) {
            if (session === backend.currentSession) {
                __loadTopics()
            }
        }

        onForumIdChanged: if (backend.currentSession.loginFinished) __loadTopics()
        onViewSubscriptionsChanged: if (viewSubscriptions && backend.currentSession.loginFinished) __loadTopics()

        function __loadTopics(startNum, endNum) {
            if (forumId <= 0 && !viewSubscriptions) {
                return;
            }

            console.log("loading categories")

            hasLoadedCompletely = false

            var xhr = new XMLHttpRequest;
            topicModel.xml="";
            xhr.open("POST", backend.currentSession.apiSource);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200) {
                        topicModel.xml = StringUtils.xmlFromResponse(xhr.responseText)
                    } else {
                        notification.show(i18n.tr("Connection error"))

                        loadingFinished()
                    }
                }
            }
            var startEndParams = "";
            if (startNum !== undefined && endNum !== undefined) {
                console.log("load topics: " + startNum + " - " + endNum)
                startEndParams += '<param><value><int>'+startNum+'</int></value></param>'
                startEndParams += '<param><value><int>'+endNum+'</int></value></param>'
            } else {
                startEndParams += '<param><value><int>0</int></value></param>'
                startEndParams += '<param><value><int>' + (backend.topicsLoadCount - 1) + '</int></value></param>'
            }

            if (!viewSubscriptions) {
                xhr.send('<?xml version="1.0"?><methodCall><methodName>get_topic</methodName><params><param><value>'+forumId+'</value></param>'+startEndParams+'<param><value>'+mode+'</value></param></params></methodCall>');
            } else {
                xhr.send('<?xml version="1.0"?><methodCall><methodName>get_subscribed_topic</methodName><params>'+startEndParams+'</params></methodCall>');
            }
        }
    }



}
