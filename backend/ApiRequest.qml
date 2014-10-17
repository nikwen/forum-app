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
    property int backendQueryId: -1
    property bool checkSuccess: false

    signal queryResult(var session, bool withoutErrors, string responseXml)
    signal querySuccessResult(var session, bool success, string responseXml)

    function start() {
        if (checkSuccess) {
            backendQueryId = backend.currentSession.apiSuccessQuery(query)
            backend.currentSession.querySuccessResult.connect(executedSuccessQuery) //TODO: Pass a function to the method instead which calls executedQuery()? Or make it call executedQuery() on the ApiRequest item directly? -> Depends on the queue implementation
        } else {
            backendQueryId = backend.currentSession.apiQuery(query)
            backend.currentSession.queryResult.connect(executedQuery)
        }
    }

    function executedSuccessQuery(queryId, session, success, responseXml) {
        if (session !== backend.currentSession || queryId !== backendQueryId) {
            return
        }

        backend.currentSession.querySuccessResult.disconnect(executedSuccessQuery)

        backendQueryId = -1
        querySuccessResult(session, success, responseXml)
    }

    function executedQuery(queryId, session, withoutErrors, responseXml) {
        if (session !== backend.currentSession || queryId !== backendQueryId) {
            return
        }

        backend.currentSession.queryResult.disconnect(executedQuery)

        backendQueryId = -1
        queryResult(session, withoutErrors, responseXml)
    }

}
