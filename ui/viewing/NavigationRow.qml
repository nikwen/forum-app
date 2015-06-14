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

                ListModel {
                    id: pageModel

                    function fillWithValues() {
                        if (firstDisplayedPost < 0 || totalPostCount <= 0) {
                            return
                        }

                        clear()

                        if (pageCount <= 5) { //TODO-r: Make sure the view is not bigger than the space which is available, e.g. by using a lower font size (like in the header)
                            for (var i = 1; i <= pageCount; i++) {
                                append({ "ellipsis": false, "pageNumber": i, "current": i === currentPage })
                            }
                        } else if (currentPage <= 3) {
                            for (var i = 1; i <= Math.max(currentPage + 1, 3); i++) {
                                append({ "ellipsis": false, "pageNumber": i, "current": i === currentPage })
                            }

                            append({ "ellipsis": true,  "pageNumber": -1, "current": false })
                            append({ "ellipsis": false, "pageNumber": pageCount, "current": false })
                        } else if (currentPage >= pageCount - 2) {
                            append({ "ellipsis": false, "pageNumber": 1, "current": false })
                            append({ "ellipsis": true,  "pageNumber": -1, "current": false })

                            for (var i = Math.min(pageCount - 2, currentPage - 1); i <= pageCount; i++) {
                                append({ "ellipsis": false, "pageNumber": i, "current": i === currentPage })
                            }
                        } else {
                            append({ "ellipsis": false, "pageNumber": 1, "current": false })
                            append({ "ellipsis": true,  "pageNumber": -1, "current": false })

                            for (var i = currentPage - 1; i <= currentPage + 1; i++) {
                                append({ "ellipsis": false, "pageNumber": i, "current": i === currentPage })
                            }

                            append({ "ellipsis": true,  "pageNumber": -1, "current": false })
                            append({ "ellipsis": false, "pageNumber": pageCount, "current": false })
                        }
                    }
                }

                Connections {
                    target: threadList

                    onFirstDisplayedPostChanged: pageModel.fillWithValues()
                    onTotalPostCountChanged: pageModel.fillWithValues()
                }

                Repeater {
                    model: pageModel

                    delegate: Loader {
                        sourceComponent: model.ellipsis ? ellipsisComponent : selectPageButton

                        Binding {
                            target: item
                            property: "pageNumber"
                            value: model.pageNumber
                            when: !model.ellipsis
                        }

                        Binding {
                            target: item
                            property: "current"
                            value: model.current
                            when: !model.ellipsis
                        }
                    }
                }
            }

            NavigationButton {
                id: nextButton
                previous: false

                onClicked: goToNextPage()
            }
        }
    }

    Component {
        id: selectPageButton

        AbstractButton { //TODO-r: Make buttons a bit bigger (reduce Row spacing and add margin to Label)
            width: label.width + units.gu(1)
            height: label.height + units.gu(1)

            property int pageNumber
            property bool current: false

            Rectangle {
                anchors.fill: parent
                color: parent.pressed ? "#F3F3F3" : "transparent"
            }

            Label {
                id: label
                text: pageNumber
                fontSize: "large"
                anchors.centerIn: parent
                font.underline: current //TODO-r: Line a bit lower (by adding a custom Rectangle component) OR invert color
            }

            onClicked: goToPage(pageNumber - 1)
        }
    }

    Component {
        id: ellipsisComponent

        Label {
            id: ellipsisLabel
            text: "…"
            fontSize: "large"
            anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: units.gu(0.5) //Due to "+ units.gu(1)" in selectPageButton
            }
        }
    }
}
