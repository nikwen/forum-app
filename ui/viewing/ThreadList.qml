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
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0
import "../../backend"
import "bbcode"


ListView {

    property alias current_topic: threadModel.topic_id
    property alias firstDisplayedPost: threadModel.firstDisplayedPost
    property alias lastDisplayedPost: threadModel.lastDisplayedPost
    property int totalPostCount: -1
    property bool canReply: false
    property bool isClosed: false
    property bool canSubscribe: false
    property bool isSubscribed: false

    property bool vBulletinAnnouncement: false

    anchors {
        topMargin: units.gu(1)
        bottomMargin: units.gu(1)
        leftMargin: units.gu(1)
        rightMargin: units.gu(1)
    }

    spacing: units.gu(1)
    clip: true

    delegate: MessageDelegate {
        titleText: model.title
        postBody: model.postBody
        authorText: model.author
        avatar: model.avatar
        thanksInfo: model.thanksInfo
        postTime: model.postTime
        postNumber: model.index + firstDisplayedPost + 1
    }

    header: ThreadPageButtonRow {
        visible: parsedThreadModel.count > 0
    }

    footer: ThreadPageButtonRow { //TODO-r: Hard to click buttons with bottom edge hint in front of it
        visible: parsedThreadModel.count > 0
    }

    function loadPosts(startNum, count) {
        if (!threadModel.hasLoadedCompletely) { //Do nothing if it is already loading
            return
        }

        parsedThreadModel.clear()
        totalPostCount = -1
        loadingSpinner.running = true
        threadModel.loadPosts(startNum, count)
    }

    function reload() {
        loadPosts(firstDisplayedPost, backend.postsPerPage) //lastDisplayedPost might not be the latest any more
    }

    model: ListModel {
        id: parsedThreadModel
    }

    XmlListModel {
        id: threadModel
        objectName: "threadModel"

        property int firstDisplayedPost: -1
        property int lastDisplayedPost: -1

        property bool hasLoadedCompletely: true

        property string topic_id: "-1"
        query: "/methodResponse/params/param/value/struct/member[name='posts']/value/array/data/value/struct"

        XmlRole { name: "id"; query: "member[name='post_id']/value/string/string()" }
        XmlRole { name: "title"; query: "member[name='post_title']/value/base64/string()" }
        XmlRole { name: "content"; query: "member[name='post_content']/value/base64/string()" }
        XmlRole { name: "author"; query: "member[name='post_author_name']/value/base64/string()" }
        XmlRole { name: "avatar"; query: "member[name='icon_url']/value/string/string()" }
        XmlRole { name: "thanks_info"; query: "member[name='thanks_info']/value/array/data/string()" }
        XmlRole { name: "post_time"; query: "member[name='post_time']/value/dateTime.iso8601/string()" }

        onStatusChanged: {
            if (status === 1) {
                //Parse the fetched posts and append the results to parsedThreadModel

                for (var i = 0; i < count; i++) {
                    var element = get(i)
                    parsedThreadModel.append({ "id": element.id, "title": Qt.atob(element.title).trim(), "postBody": passageParser.parse("", [], Qt.atob(element.content)), "author": Qt.atob(element.author).trim(), "avatar": element.avatar.trim(), "thanksInfo": element.thanks_info.trim(), "postTime": element.post_time.trim() })
                }

                //Extract the total number of posts from XML
                //Excerpt from the returned XML: <member><name>total_post_num</name><value><int>3</int></value></member>

                var totalPostNumStringPosition = xml.indexOf("<name>total_post_num</name>");
                var openIntTagPosition = xml.indexOf("<int>", totalPostNumStringPosition);
                var closeIntTagPosition = xml.indexOf("</int>", openIntTagPosition);
                var numSubstring = xml.substring(openIntTagPosition + 5, closeIntTagPosition); //equals + "<int>".length

//                console.log(xml)

                totalPostCount = numSubstring;

                lastDisplayedPost = Math.min(lastDisplayedPost, totalPostCount - 1);

                //Check if the user is allowed to reply

                var canReplyStringPosition = xml.indexOf("<name>can_reply</name>");
                if (canReplyStringPosition < 0) {
                    canReply = true
                } else {
                    var openBoolTagPosition = xml.indexOf("<boolean>", canReplyStringPosition);
                    var closeBoolTagPosition = xml.indexOf("</boolean>", openBoolTagPosition);
                    var canPostSubstring = xml.substring(openBoolTagPosition + 9, closeBoolTagPosition); //equals + "<boolean>".length

                    canReply = canPostSubstring.trim() === "1"
                }

                //Check if the topic has been closed

                var isClosedStringPosition = xml.indexOf("<name>is_closed</name>");
                if (isClosedStringPosition < 0) {
                    isClosed = false
                } else {
                    var openBoolTagPosition = xml.indexOf("<boolean>", isClosedStringPosition);
                    var closeBoolTagPosition = xml.indexOf("</boolean>", openBoolTagPosition);
                    var isClosedSubstring = xml.substring(openBoolTagPosition + 9, closeBoolTagPosition); //equals + "<boolean>".length

                    isClosed = isClosedSubstring.trim() === "1"
                }

                //Check if can subscribe

                var canSubscribeStringPosition = xml.indexOf("<name>can_subscribe</name>");
                if (canSubscribeStringPosition < 0) {
                    canSubscribe = true
                } else {
                    var openBoolTagPosition = xml.indexOf("<boolean>", canSubscribeStringPosition);
                    var closeBoolTagPosition = xml.indexOf("</boolean>", openBoolTagPosition);
                    var canSubscribeSubstring = xml.substring(openBoolTagPosition + 9, closeBoolTagPosition); //equals + "<boolean>".length

                    canSubscribe = canSubscribeSubstring.trim() === "1"
                }

                //Check if is subscribed

                var isSubscribedStringPosition = xml.indexOf("<name>is_subscribed</name>");
                if (isSubscribedStringPosition < 0) {
                    isSubscribed = false
                } else {
                    var openBoolTagPosition = xml.indexOf("<boolean>", isSubscribedStringPosition);
                    var closeBoolTagPosition = xml.indexOf("</boolean>", openBoolTagPosition);
                    var isSubscribedSubstring = xml.substring(openBoolTagPosition + 9, closeBoolTagPosition); //equals + "<boolean>".length

                    isSubscribed = isSubscribedSubstring.trim() === "1"
                }

                hasLoadedCompletely = true
            }
        }

        onTopic_idChanged: loadPosts(0, backend.postsPerPage)

        function loadPosts(startNum, count) {
            hasLoadedCompletely = false

            firstDisplayedPost = startNum
            lastDisplayedPost = startNum + count - 1

            threadModel.xml = ""

            if (!vBulletinAnnouncement) {
                loadThreadListRequest.query = '<?xml version="1.0"?><methodCall><methodName>get_thread</methodName><params><param><value>' + topic_id + '</value></param><param><value><int>' + firstDisplayedPost + '</int></value></param><param><value><int>' + lastDisplayedPost + '</int></value></param><param><value><boolean>true</boolean></value></param></params></methodCall>'
            } else {
                console.log("vb announcement")
                loadThreadListRequest.query = '<?xml version="1.0"?><methodCall><methodName>get_announcement</methodName><params><param><value>' + topic_id + '</value></param></params></methodCall>'
            }

            loadThreadListRequest.start()
        }

    }

    ApiRequest {
        id: loadThreadListRequest

        onQueryResult: {
            loadingSpinner.running = false
            threadModel.xml = responseXml
        }
    }

    PassageParser {
        id: passageParser
    }

}
