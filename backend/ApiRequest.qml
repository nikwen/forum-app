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
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import "../stringutils.js" as StringUtils

Item {
    property string query
    property string actionName: i18n.tr("Action") //Will be used for the error dialog title
    property bool checkSuccess: false
    property bool allowMultipleRequests: false
    property bool loginAgain: true //Should not be used by anything else than the session's loginRequest

    property bool busy: false
    property var queryQueue: [] //Array of query strings; DO NOT use variant as it cannot handle objects properly

    signal queryResult(bool withoutErrors, string responseXml)
    signal querySuccessResult(bool success, string responseXml)

    function start() { //Returns whether the query will be executed
        if (!allowMultipleRequests && queryQueue.length > 0) {
            console.log("Will not run second api query (allowMultipleRequests === false)")
            return false
        }

        queryQueue.push(query)
        checkRunNextQuery()

        return true
    }

    // ===============================================================
    // The following functions should NEVER be used in any other file!
    // ===============================================================

    function checkRunNextQuery() {
        console.log("Pending queries: " + queryQueue.length)
        if (!busy && queryQueue.length > 0) {
            runNextQuery()
        }
    }

    function processingQueryDone() {
        busy = false
        queryQueue.shift() //removes first element
        checkRunNextQuery()
    }

    function queryExecuted(withoutErrors, xml) {
        if (checkSuccess) {
            checkApiQuerySuccess(withoutErrors, xml)
        } else {
            queryResult(withoutErrors, xml)
            processingQueryDone()
        }
    }

    onQuerySuccessResult: processingQueryDone()

    function checkApiQuerySuccess(withoutErrors, xml) {
        if (!withoutErrors) {
            querySuccessResult(false, xml)
            return
        }

        var resultIndex = xml.indexOf("result")
        var booleanTag = xml.indexOf("<boolean>", resultIndex)
        var booleanEndTag = xml.indexOf("</boolean>", resultIndex)
        var result = xml.substring(booleanTag + 9, booleanEndTag)

        var success = result === "1"

        if (success) {
            querySuccessResult(success, xml)
        } else {
            var resultTextIndex = xml.indexOf("result_text")
            var resultText
            if (resultTextIndex > 0) {
                var base64Tag = xml.indexOf("<base64>", resultTextIndex)
                var base64EndTag = xml.indexOf("</base64>", resultTextIndex)
                resultText = StringUtils.base64_decode(xml.substring(base64Tag + 8, base64EndTag))
                console.log(resultText)
            }
            var dialog = PopupUtils.open(Qt.resolvedUrl("../ui/components/ErrorDialog.qml"))
            dialog.title = qsTr(i18n.tr("%1 failed")).arg(actionName)
            if (resultText !== undefined) {
                dialog.text = i18n.tr("Text returned by the server:\n") + resultText
            }
            querySuccessResult(success, xml)
        }
    }

    function runNextQuery() {
        backend.currentSession.loginDone.disconnect(runNextQuery)

        busy = true

        var xhr = new XMLHttpRequest
        xhr.open("POST", backend.currentSession.apiSource)
        var onReadyStateChangeFunction = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    if (xhr.getResponseHeader("Mobiquo_is_login") === "false" && backend.currentSession.loggedIn && loginAgain) {
                        if (backend.currentSession.loginFinished) { //login might already have been started elsewhere
                            backend.currentSession.login() //Connection to loginDone will take care of retrying afterwards
                        }
                        backend.currentSession.loginDone.connect(runNextQuery)
                    } else {
                        var xml = StringUtils.xmlFromResponse(xhr.responseText)
                        if (xml.trim() !== "") {
                            queryExecuted(true, xml)
                        } else {
                            notification.show(i18n.tr("Error: Could not get Tapatalk API response using the given URL"))
                            console.log("Error: Could not get Tapatalk API response using the given URL")
                            queryExecuted(false, "")
                        }
                    }

                } else {
                    notification.show((xhr.status === 404) ? i18n.tr("Error 404: Could not find Tapatalk API for given URL") : i18n.tr("Connection error"))
                    console.log((xhr.status === 404) ? "Error 404: Could not find Tapatalk API for given URL" : "Connection error")
                    queryExecuted(session, false, "")
                }
            }
        }
        xhr.onreadystatechange = onReadyStateChangeFunction
        xhr.send(queryQueue[0])
    }

}
