/*
* Forum Browser
*
* Copyright (c) 2014-2015 Niklas Wenzel <nikwen.developer@gmail.com>
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

//The respective ApiRequest had to be placed in ForumBackend.qml as XmlListModel does not allow Items as children

XmlListModel {
    id: configModel
    objectName: "configModel"

    query: "/methodResponse/params/param/value/struct"

    property bool hasLoaded: false

    property string version
    property bool isVBulletin: false
    property bool supportMd5: false
    property bool supportSHA1: false
    property bool subscribeForum: true

    XmlRole { name: "support_md5"; query: "member[name='support_md5']/value/number()" }
    XmlRole { name: "support_sha1"; query: "member[name='support_sha1']/value/number()" }
    XmlRole { name: "version"; query: "member[name='version']/value/string()" }
    XmlRole { name: "subscribe_forum"; query: "member[name='subscribe_forum']/value/number()" }

    onStatusChanged: {
        if (status === XmlListModel.Ready) {
            var element = get(0)

            version = element.version.trim()
            isVBulletin = version.indexOf("vb") === 0
            supportMd5 = (typeof(element.support_md5) === "number") ? element.support_md5 : false
            supportSHA1 = (typeof(element.support_sha1) === "number") ? element.support_sha1 : false
            subscribeForum = (typeof(element.subscribe_forum) === "number") ? element.subscribe_forum : true

            console.log("version: " + element.version.trim())

            console.log("configModel has loaded")

            hasLoaded = true
        }
    }

    function loadConfig() {
        hasLoaded = false
        configModel.xml = ""

        loadConfigRequest.start()
    }

}
