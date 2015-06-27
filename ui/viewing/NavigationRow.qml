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

            Item {
                id: centerItem

                anchors {
                    top: parent.top
                    left: previousButton.right
                    right: nextButton.left
                    bottom: parent.bottom
                    leftMargin: units.dp(1) //Half of the width of the NavigationButtons' VerticalDividers so that them and the text do not overlap
                    rightMargin: leftMargin
                }

                Flickable {
                    clip: true
                    anchors.centerIn: parent
                    height: parent.height
                    width: Math.min(parent.width, buttonsRowWidthPlusMargins)
                    contentWidth: buttonsRowWidthPlusMargins

                    property real buttonsRowWidthPlusMargins: buttonsRow.width + 2 * buttonsRow.x //Need to declare this here as referring to contentWidth in the width attribute will for some reason result in a binding loop

                    Row {
                        id: buttonsRow

                        x: units.gu(1)
                        height: childrenRect.height
                        anchors.verticalCenter: parent.verticalCenter

                        ListModel { //TODO-r: Center underlined item by scrolling (https://forum.qt.io/topic/55054/solved-flickable-flick-doesn-t-work/3)
                            id: pageModel

                            function fillWithValues() {
                                if (firstDisplayedPost < 0 || totalPostCount <= 0) {
                                    return
                                }

                                clear()

                                if (pageCount <= 5) {
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

                            delegate: AbstractButton {
                                width: pageLabel.width + units.gu(1.5)
                                height: pageLabel.height + units.gu(1.5)

                                Rectangle {
                                    anchors.fill: parent
                                    color: parent.pressed ? "#F3F3F3" : "transparent"
                                }

                                Label {
                                    id: pageLabel
                                    text: model.ellipsis ? "…" : model.pageNumber
                                    fontSize: "large"
                                    anchors.centerIn: parent
                                }

                                Rectangle {
                                    id: underlineRect
                                    height: units.gu(0.1)
                                    anchors {
                                        top: pageLabel.bottom
                                        left: pageLabel.left
                                        right: pageLabel.right
                                        topMargin: units.gu(0.15)
                                        leftMargin: - units.gu(0.1)
                                        rightMargin: leftMargin
                                    }
                                    visible: model.current
                                    color: pageLabel.color
                                }

                                onClicked: model.ellipsis ? threadPage.openPageSelectionDialog() : goToPage(model.pageNumber - 1)
                            }
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
}
