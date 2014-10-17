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

Item {
    property string query
    property bool checkSuccess: false
    property bool allowMultipleRequests: false

    property var runningQueries: [] //Multiple queries by one ApiRequest object are currently only planned for features like subscribing or thanking for a post, so the queryId does not need to be passed by the signals
                                    //DO NOT use variant here as it will for some reason not allow to push objects to the array

    signal queryResult(var session, bool withoutErrors, string responseXml)
    signal querySuccessResult(var session, bool success, string responseXml)

    function start() { //Returns whether the request will be executed
        if (!allowMultipleRequests && runningQueries.length > 0) {
            console.log("Will not run second api query (allowMultipleRequests === false)")
            return false
        }

        var currentQueryId = -1
        if (checkSuccess) {
            currentQueryId = backend.currentSession.apiSuccessQuery(query)
            backend.currentSession.querySuccessResult.connect(executedSuccessQuery)
        } else {
            currentQueryId = backend.currentSession.apiQuery(query)
            backend.currentSession.queryResult.connect(executedQuery)
        }
        runningQueries.push(currentQueryId)

        return true
    }

    function executedSuccessQuery(queryId, session, success, responseXml) {
        var index = runningQueries.indexOf(queryId)
        if (session !== backend.currentSession || index === -1) {
            return
        }

        runningQueries.shift() //Removes first query (The splice() function does not work properly with properties in QML. As the backend processes queries serially, shift() can be used as a workaround.)
        if (runningQueries.length === 0) {
            backend.currentSession.querySuccessResult.disconnect(executedSuccessQuery)
        }

        querySuccessResult(session, success, responseXml)
    }

    function executedQuery(queryId, session, withoutErrors, responseXml) {
        var index = runningQueries.indexOf(queryId)
        if (session !== backend.currentSession || index === -1) {
            return
        }

        runningQueries.shift() //See comment above
        if (runningQueries.length === 0) {
            backend.currentSession.queryResult.disconnect(executedQuery)
        }

        queryResult(session, withoutErrors, responseXml)
    }

}
