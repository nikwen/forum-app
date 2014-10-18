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
import QtQuick.XmlListModel 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import U1db 1.0 as U1db
import "../md5utils.js" as Md5Utils
import "../sha1utils.js" as Sha1Utils
import "../stringutils.js" as StringUtils

Object {

    signal loginDone(var session);

    property var sessions: []
    property var currentSession: (currentSessionIndex >= 0) ? sessions[currentSessionIndex] : undefined
    property int currentSessionIndex: -1

    property int postsPerPage: 10
    property int topicsLoadCount: 20

    U1db.Index {
        database: db
        id: by_url
        expression: ["url", "user", "password"]
    }

    U1db.Query {
        id: loginQuery
        index: by_url
        query: [currentSession.forumUrl, "*", "*"]

        onResultsChanged: { //User changed login details in dialog
            if (currentSession !== undefined && currentSession.configModel.hasLoaded) {
                if (results[0].user !== "") {
                    login()
                } else if (currentSession.loggedIn) {
                    logout(currentSession)
                }
            }
        }
    }

    Component {
        id: sessionComponent

        Object {
            id: session

            property string forumUrl: ""
            property string apiSource: ""
            property bool loginFinished: false
            property bool loggedIn: false
            property alias configModel: configModel

            ForumConfigModel {
                id: configModel

                onHasLoadedChanged: {
                    if (hasLoaded && session === currentSession && !session.loggedIn) {
                        login()
                    }
                }
            }

            onApiSourceChanged: {
                if (apiSource !== "") {
                    configModel.loadConfig()
                }
            }

            ApiRequest {
                id: loadConfigRequest
                query: '<?xml version="1.0"?><methodCall><methodName>get_config</methodName></methodCall>'

                onQueryResult: {
                    configModel.xml = responseXml
                }
            }

            property var queryQueue: [] //Array of arrays following this structure: [ queryId, queryString, isSuccessQuery ]; DO NOT use variant as it cannot handle objects properly
            property bool processingQuery: false
            property int currentQueryId: -1
            property int nextQueryId: 0

            signal queryResult(int queryId, var session, bool withoutErrors, string responseXml)
            signal querySuccessResult(int queryId, var session, bool success, string responseXml)

            function checkRunNextQuery() {
                console.log("Pending queries: " + queryQueue.length)
                if (!processingQuery && queryQueue.length > 0) {
                    runNextQuery()
                }
            }

            onQueryResult: {
                if (!queryQueue[0].isSuccessQuery) {
                    processingQueryDone()
                }
            }

            onQuerySuccessResult: processingQueryDone()

            function processingQueryDone() {
                currentQueryId = -1
                processingQuery = false
                queryQueue.shift() //removes first element
                checkRunNextQuery()
            }

            function apiSuccessQuery(queryString) {
                nextQueryId++
                queryQueue.push({ "queryId": nextQueryId, "queryString": queryString, "isSuccessQuery": true })
                checkRunNextQuery()
                return nextQueryId
            }

            function apiQuery(queryString) {
                nextQueryId++
                queryQueue.push({ "queryId": nextQueryId, "queryString": queryString, "isSuccessQuery": false })
                checkRunNextQuery()
                return nextQueryId
            }

            function checkApiQuerySuccess(currentQueryId, session, withoutErrors, xml) {
                queryResult.disconnect(checkApiQuerySuccess)

                if (!withoutErrors) {
                    querySuccessResult(currentQueryId, session, false, xml)
                    return
                }

                var resultIndex = xml.indexOf("result")
                var booleanTag = xml.indexOf("<boolean>", resultIndex)
                var booleanEndTag = xml.indexOf("</boolean>", resultIndex)
                var result = xml.substring(booleanTag + 9, booleanEndTag)

                var success = result === "1"

                if (success) {
                    querySuccessResult(currentQueryId, session, success, xml)
                } else {
                    var resultTextIndex = xml.indexOf("result_text")
                    var resultText
                    if (resultTextIndex > 0) {
                        var base64Tag = xml.indexOf("<base64>", resultTextIndex)
                        var base64EndTag = xml.indexOf("</base64>", resultTextIndex)
                        resultText = StringUtils.base64_decode(xml.substring(base64Tag + 8, base64EndTag))
                        console.log(resultText)
                    }
                    var dialog = PopupUtils.open(errorDialog)
                    dialog.title = i18n.tr("Action failed")
                    if (resultText !== undefined) {
                        dialog.text = i18n.tr("Text returned by the server:\n") + resultText
                    }
                    querySuccessResult(currentQueryId, session, success, xml)
                }
            }

            function runNextQuery() { //parameter only for connection with loginDone - TODO: Does this comment still make sense?
                processingQuery = true

                if (session !== undefined) { //TODO: First if needed???
                    if (session === backend.currentSession) {
                        backend.loginDone.disconnect(runNextQuery)
                    } else {
                        return
                    }
                }

                currentQueryId = queryQueue[0].queryId
                if (queryQueue[0].isSuccessQuery) {
                    queryResult.connect(checkApiQuerySuccess)
                }

                var xhr = new XMLHttpRequest
                xhr.open("POST", backend.currentSession.apiSource)
                var onReadyStateChangeFunction = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        if (xhr.status === 200) {
                            if (xhr.getResponseHeader("Mobiquo_is_login") === "false" && backend.currentSession.loggedIn) {
                                if (backend.currentSession.loginFinished) { //login might already have been started in categoryModel
                                    backend.login() //Connection to loginDone will take care of retrying afterwards
                                    backend.loginDone.connect(runNextQuery)
                                }
                            } else {
                                var xml = StringUtils.xmlFromResponse(xhr.responseText)
                                if (xml.trim() !== "") {
                                    queryResult(currentQueryId, session, true, xml)
                                } else {
                                    notification.show(i18n.tr("Error: Could not get Tapatalk API response using the given URL"))
                                    console.log("Error: Could not get Tapatalk API response using the given URL")
                                    queryResult(currentQueryId, session, false, "")
                                }
                            }

                        } else {
                            notification.show((xhr.status === 404) ? i18n.tr("Error 404: Could not find Tapatalk API for given URL") : i18n.tr("Connection error"))
                            console.log((xhr.status === 404) ? "Error 404: Could not find Tapatalk API for given URL" : "Connection error")
                            queryResult(currentQueryId, session, false, "")
                        }
                    }
                }
                xhr.onreadystatechange = onReadyStateChangeFunction
                xhr.send(queryQueue[0].queryString)
            }
        }
    }

    function newSession(forumUrl, apiSource) {
        var session = sessionComponent.createObject(mainView, { "forumUrl": forumUrl })
        sessions.push(session)
        currentSessionIndex = sessions.indexOf(session)
        session.apiSource = apiSource //Needs to be set after object creation to provide ApiRequest with a valid currentSession
    }

    function endSession(session) {
        console.log("endSession")
        var index = sessions.indexOf(session)
        var saveCurrentSession
        if (currentSessionIndex === index) { //end current session?
            currentSessionIndex = -1
        } else {
            saveCurrentSession = currentSession
        }
        logout(session)
        sessions.splice(index, 1) //Remove session from list
        if (currentSessionIndex != -1) {
            currentSessionIndex = sessions.indexOf(saveCurrentSession)
        }
    }

    function login() {
        var session = currentSession
        if (loginQuery.results[0] !== undefined && loginQuery.results[0].user !== undefined && loginQuery.results[0].password !== undefined && loginQuery.results[0].user !== "" && loginQuery.results[0].password !== "") {
            console.log("login")
            var api = session.apiSource
            session.loginFinished = false //do not set loggedIn to false => ability to change login data
            var xhr = new XMLHttpRequest
            xhr.open("POST", session.apiSource)
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
//                    console.log(xhr.responseText)
                    console.log("logged in")

                    if (xhr.status === 200) {
                        var resultIndex = xhr.responseText.indexOf("result");
                        var booleanTag = xhr.responseText.indexOf("<boolean>", resultIndex)
                        var booleanEndTag = xhr.responseText.indexOf("</boolean>", resultIndex)
                        var result = xhr.responseText.substring(booleanTag + 9, booleanEndTag)

                        var success = result === "1"

                        if (success) {
                            session.loggedIn = true
                            session.loginFinished = true
                            loginDone(session)
                            if (session === currentSession) {
                                notification.show(qsTr(i18n.tr("Logged in as %1")).arg(loginQuery.results[0].user))
                            }
                        } else {
                            var resultTextIndex = xhr.responseText.indexOf("result_text")
                            var resultText
                            if (resultTextIndex > 0) {
                                var base64Tag = xhr.responseText.indexOf("<base64>", resultTextIndex)
                                var base64EndTag = xhr.responseText.indexOf("</base64>", resultTextIndex)
                                resultText = StringUtils.base64_decode(xhr.responseText.substring(base64Tag + 8, base64EndTag))
                                console.log(resultText)
                            }
                            var willLogOut = logout(session)
                            if (!willLogOut) {
                                session.loggedIn = false
                                session.loginFinished = true
                                loginDone(session)
                            }
                            var dialog = PopupUtils.open(errorDialog)
                            dialog.title = i18n.tr("Login failed")
                            if (resultText !== undefined) {
                                dialog.text = i18n.tr("Text returned by the server:\n") + resultText
                            }
                        }
                    } else {
                        if (session === currentSession) {
                            notification.show(i18n.tr("Connection error"))
                        }
                    }
                }
            }
            var user = ""
            if (loginQuery.results[0].user !== undefined) {
                user = loginQuery.results[0].user
            }

            var password = ""
            if (session.configModel.get(0).support_md5) {
                console.log("md5")
                password = Md5Utils.md5(loginQuery.results[0].password)
            } else if (session.configModel.get(0).support_sha1) { //Untested yet
                console.log("sha1")
                password = Sha1Utils.sha1(loginQuery.results[0].password)
            } else {
                console.log("no encryption")
                password = loginQuery.results[0].password
            }

            xhr.send('<?xml version="1.0"?><methodCall><methodName>login</methodName><params><param><value><base64>'+StringUtils.base64_encode(user)+'</base64></value></param><param><value><base64>'+StringUtils.base64_encode(password)+'</base64></value></param></params></methodCall>');
        } else {
            console.log("no login")
            session.loginFinished = true
            loginDone(session)
        }

    }

    //Return value: If it will try to log out
    function logout(session) {
        if (session === undefined) {
            return
        }

        console.log("logout")
        if (session.loggedIn) {
            session.loginFinished = false;
            var api = session.apiSource
            var xhr = new XMLHttpRequest;
            xhr.open("POST", session.apiSource);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (session.loggedIn) { //Set to false if another attempt to login has already started
                        console.log("logged out")
                        session.loginFinished = true
                        loginDone(session)
                        session.loggedIn = false
                    }
                }
            }
            xhr.send('<?xml version="1.0"?><methodCall><methodName>logout_user</methodName></methodCall>');
            return true
        } else {
            if (!session.loginFinished) { //Pressed back while still logging in => Logout after login finished
                var otherLoginCount = 0 //A way to disconnect in case that the page was destroyed before login() has even been called

                var connectFunction = function(loginSession) {
                    console.log("connected function called")
                    if (loginSession === session) {
                        loginDone.disconnect(connectFunction)
                        logout(session)
                        console.log("logout in connected")
                    } else {
                        otherLoginCount++
                        if (otherLoginCount >= 2) {
                            loginDone.disconnect(connectFunction)
                        }
                    }
                }

                console.log("connect")
                loginDone.connect(connectFunction)
            }

            return false
        }
    }



}
