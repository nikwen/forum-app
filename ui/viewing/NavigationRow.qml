/*
* Forum Browser
*
* Copyright (c) 2015 Niklas Wenzel <nikwen.developer@gmail.com>
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
import Ubuntu.Components.ListItems 1.0 as ListItem
import "../components"

//TODO-r: Solution similar to gallery navigation on m.heise.de

Item {
    width: parent.width
    height: units.gu(8)

    UbuntuShape {
        width: parent.width
        height: units.gu(6)
        anchors.verticalCenter: parent.verticalCenter
        color: "white"

        Rectangle {
            anchors.fill: parent
            color: "transparent"

            NavigationButton {
                id: previousButton
                previous: true

                onClicked: {
                    if (threadList.firstDisplayedPost > 0) {
                        threadList.loadPosts(Math.max(threadList.firstDisplayedPost - backend.postsPerPage, 0), backend.postsPerPage);
                    }
                }
            }

            Row {
                id: buttonsRow

                height: childrenRect.height
                anchors.centerIn: parent

                spacing: units.gu(1)


//                onClicked: {
//                    if (threadList.firstDisplayedPost !== 0) {
//                        threadList.loadPosts(0, backend.postsPerPage);
//                    }
//                }


//                onClicked: {
//                    if (threadList.firstDisplayedPost > 0) {
//                        threadList.loadPosts(Math.max(threadList.firstDisplayedPost - backend.postsPerPage, 0), backend.postsPerPage);
//                    }
//                }

//                onClicked: {
//                    if (threadList.lastDisplayedPost < threadList.totalPostCount - 1) {
//                        threadList.loadPosts(threadList.lastDisplayedPost + 1, backend.postsPerPage);
//                    }
//                }

//                onClicked: {
//                    var postsOnLastPage = ((threadList.totalPostCount) % backend.postsPerPage);
//                    var beginningLastPage = threadList.totalPostCount - (postsOnLastPage === 0 ? backend.postsPerPage : postsOnLastPage);
//                    if (beginningLastPage !== threadList.firstDisplayedPost) {
//                        threadList.loadPosts(beginningLastPage, backend.postsPerPage);
//                    }
//                }
            }

            NavigationButton {
                id: nextButton
                previous: false

                onClicked: {
                    if (threadList.lastDisplayedPost < threadList.totalPostCount - 1) {
                        threadList.loadPosts(threadList.lastDisplayedPost + 1, backend.postsPerPage);
                    }
                }
            }
        }
    }
}
