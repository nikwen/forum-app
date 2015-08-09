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
import Ubuntu.Components.Popups 1.0
import U1db 1.0 as U1db
import "../md5utils.js" as Md5Utils
import "../sha1utils.js" as Sha1Utils

Object {

    property var sessions: []
    property var currentSession: (currentSessionIndex >= 0) ? sessions[currentSessionIndex] : undefined
    property int currentSessionIndex: -1

    property int postsPerPage: 10
    property int topicsLoadCount: 20
    property alias signature: settingsBackend.signature
    property alias useAlternativeDateFormat: settingsBackend.useAlternativeDateFormat
    property alias subjectFieldWhenReplying: settingsBackend.subjectFieldWhenReplying

    U1db.Index {
        database: db
        id: by_url
        expression: ["url", "user", "password"]
    }

    SettingsBackend {
        id: settingsBackend
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
            property alias loginRequest: loginRequest

            readonly property string user: (loginDbQuery.results[0].user !== undefined) ? loginDbQuery.results[0].user : ""

            signal loginDone

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

            U1db.Query {
                id: loginDbQuery
                index: by_url
                query: [forumUrl, "*", "*"]

                onResultsChanged: { //User changed login details in dialog
                    if (configModel.hasLoaded) {
                        if (results[0].user !== "") {
                            session.login()
                        } else if (currentSession.loggedIn) {
                            session.logout()
                        }
                    }
                }
            }

            ApiRequest {
                id: loginRequest
                actionName: i18n.tr("Login")
                checkSuccess: true
                loginAgain: false

                onQuerySuccessResult: {
                    if (success) {
                        console.log("logged in")

                        session.loggedIn = true
                        session.loginFinished = true
                        session.loginDone()
                        if (session === currentSession) {
                            notification.show(qsTr(i18n.tr("Logged in as %1")).arg(loginDbQuery.results[0].user))
                        }
                    } else {
                        console.log("login failed")
                        var willLogOut = session.logout(false)
                        if (!willLogOut) {
                            session.loginFinished = true
                            session.loginDone()
                        }
                    }
                }
            }

            function login() {
                var user = loginDbQuery.results[0].user
                var password = loginDbQuery.results[0].password

                if (user === undefined || password === undefined || user === "" || password === "") {
                    console.log("no login")
                    var willLogOut = session.logout(false)
                    if (!willLogOut) {
                        loginFinished = true
                        loginDone()
                    }
                    return
                }

                console.log("login")

                loginFinished = false //do not set loggedIn to false => ability to change login data

                if (configModel.supportMd5) {
                    console.log("md5")
                    password = Md5Utils.md5(password)
                } else if (configModel.supportSHA1) { //Untested yet
                    console.log("sha1")
                    password = Sha1Utils.sha1(password)
                } else {
                    console.log("no encryption")
                }

                loginRequest.query = '<?xml version="1.0"?><methodCall><methodName>login</methodName><params><param><value><base64>' + Qt.btoa(user) + '</base64></value></param><param><value><base64>' + Qt.btoa(password) + '</base64></value></param></params></methodCall>'
                loginRequest.start()
            }

            function logout(connectToLoginDone) { //Return value: Whether it will try to log out; Parameter: only needed when called from login function, do not provide otherwise!
                console.log("logout")

                loginDone.disconnect(logout)

                if (loggedIn) {
                    loginFinished = false

                    //Do not use ApiRequest here as it will do many unnecessary and unwanted things,
                    //especially it will login again if the server has automatically logged the user out before
                    var xhr = new XMLHttpRequest
                    xhr.open("POST", apiSource)
                    xhr.onreadystatechange = function() {
                        if (xhr.readyState === XMLHttpRequest.DONE) {
                            if (loggedIn) { //Set to false if another attempt to login has already started
                                console.log("logged out")
                                loginFinished = true
                                loginDone()
                                loggedIn = false
                            }
                        }
                    }
                    xhr.send('<?xml version="1.0"?><methodCall><methodName>logout_user</methodName></methodCall>')

                    return true
                } else {
                    if (connectToLoginDone !== false) {
                        connectToLoginDone = true
                    }

                    if (!loginFinished && connectToLoginDone) { //Pressed back while still logging in => Logout after login finished
                        console.log("logout: connect to loginDone")
                        loginDone.connect(logout)
                    }

                    return false
                }
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
        session.logout()
        sessions.splice(index, 1) //Remove session from list
        if (currentSessionIndex != -1) {
            currentSessionIndex = sessions.indexOf(saveCurrentSession)
        }
        session.destroy()
    }

}
