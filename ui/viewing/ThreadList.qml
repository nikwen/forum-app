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

    property alias current_topic: threadModel.topic_id
    property alias firstDisplayedPost: threadModel.firstDisplayedPost
    property alias lastDisplayedPost: threadModel.lastDisplayedPost
    property int totalPostCount: -1
    property bool canReply: false
    property bool isClosed: false

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
        titleText: StringUtils.base64_decode(model.title)
        content: StringUtils.base64_decode(model.content)
        authorText: StringUtils.base64_decode(model.author)
        avatar: model.avatar
        thanksInfo: model.thanks_info
    }

    function loadPosts(startNum, count) {
        totalPostCount = -1
        loadingSpinner.running = true;
        threadModel.__loadPosts(startNum, count);
    }

    function reload() {
        loadPosts(firstDisplayedPost, backend.postsPerPage) //lastDisplayedPost might not be the latest any more
    }

    model: XmlListModel {
        id: threadModel
        objectName: "threadModel"

        property int firstDisplayedPost: -1
        property int lastDisplayedPost: -1

        property int topic_id: -1
        query: "/methodResponse/params/param/value/struct/member[name='posts']/value/array/data/value/struct"

        XmlRole { name: "id"; query: "member[name='post_id']/value/string()" }
        XmlRole { name: "title"; query: "member[name='post_title']/value/base64/string()" }
        XmlRole { name: "content"; query: "member[name='post_content']/value/base64/string()" }
        XmlRole { name: "author"; query: "member[name='post_author_name']/value/base64/string()" }
        XmlRole { name: "avatar"; query: "member[name='icon_url']/value/string/string()" }
        XmlRole { name: "thanks_info"; query: "member[name='thanks_info']/value/array/data/string()" }

        onStatusChanged: {
            if (status === 1) {
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
            }
        }

        onTopic_idChanged: __loadPosts(0, backend.postsPerPage)
        function __loadPosts(startNum, count) {
            firstDisplayedPost = startNum;
            lastDisplayedPost = startNum + count - 1;

            var xhr = new XMLHttpRequest;
            threadModel.xml="";
            xhr.open("POST", backend.currentSession.apiSource);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    loadingSpinner.running=false;
                    if (xhr.status === 200) {
                        if (xhr.getResponseHeader("Mobiquo_is_login") === "false" && backend.currentSession.loggedIn) {
                            if (backend.currentSession.loginFinished) { //login might already have been started in categoryModel
                                backend.login() //Connection to loginDone will care about reloading afterwards
                            }
                        } else {
                            threadModel.xml = StringUtils.xmlFromResponse(xhr.responseText)
                        }
                    } else {
                        notification.show(i18n.tr("Connection error"))
                    }
                }
            }
            if (!vBulletinAnnouncement) {
                xhr.send('<?xml version="1.0"?><methodCall><methodName>get_thread</methodName><params><param><value>'+topic_id+'</value></param><param><value><int>' + firstDisplayedPost + '</int></value></param><param><value><int>' + lastDisplayedPost + '</int></value></param><param><value><boolean>true</boolean></value></param></params></methodCall>');
            } else { //TODO: BBCode parsing for announcements
                console.log("vb announcement")
                xhr.send('<?xml version="1.0"?><methodCall><methodName>get_announcement</methodName><params><param><value>'+topic_id+'</value></param></params></methodCall>');
            }
        }


    }


}
