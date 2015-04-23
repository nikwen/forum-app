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

                onClicked: goToPreviousPage()
            }

            Row {
                id: buttonsRow

                height: childrenRect.height
                anchors.centerIn: parent

                spacing: units.gu(1)

                AbstractButton { //TODO-r: Separate file
                    width: label.width + units.gu(1)
                    height: label.height + units.gu(1)

                    //TODO-r: Indication when pressed

                    Label {
                        id: label
                        text: "1"
                        fontSize: "large"
                        anchors.centerIn: parent
                    }

                    onClicked: goToFirstPage()
                }

                Label {
                    id: label3
                    text: "…"
                    fontSize: "large"
                    anchors.verticalCenter: parent.verticalCenter
                }

                AbstractButton { //TODO-r: Separate file
                    width: label1.width + units.gu(1)
                    height: label1.height + units.gu(1)

                    //TODO-r: Indication when pressed

                    Label {
                        id: label1
                        text: Math.floor(threadList.firstDisplayedPost / 10) + 1
                        fontSize: "large"
                        anchors.centerIn: parent
                    }
                }

                Label {
                    id: label4
                    text: "…"
                    fontSize: "large"
                    anchors.verticalCenter: parent.verticalCenter
                }

                AbstractButton { //TODO-r: Separate file
                    width: label2.width + units.gu(1)
                    height: label2.height + units.gu(1)

                    //TODO-r: Indication when pressed

                    Label {
                        id: label2
                        text: Math.floor(threadList.totalPostCount / 10) + ((threadList.totalPostCount % backend.postsPerPage) === 0 ? 0 : 1)
                        fontSize: "large"
                        anchors.centerIn: parent
                    }

                    onClicked: goToLastPage()
                }
            }

            NavigationButton {
                id: nextButton
                previous: false

                onClicked: goToNextPage()
            }
        }
    }
}
