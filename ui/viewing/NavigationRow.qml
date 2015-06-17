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

                property int spaceLeft: parent.width - width - previousButton.width - nextButton.width - 3 * spacing
                property int sizeStep: -1
                property string pageButtonFontSize: "large"

                onSpaceLeftChanged: {
                    if (pageButtonFontSize === "large" && spaceLeft < 0) {
                        sizeStep = width + 2 //So that it does not automatically reset back to medium and to improve performance if the fontSize is "medium" when the component is created
                        pageButtonFontSize = "medium"
                    } else if (pageButtonFontSize === "medium" && width + spaceLeft > sizeStep) {
                        pageButtonFontSize = "large"
                    }
                }

                ListModel {
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

                    delegate: AbstractButton { //TODO-r: Make buttons a bit bigger (reduce Row spacing and add margin to Label)
                        width: pageLabel.width + units.gu(1)
                        height: pageLabel.height + units.gu(1)

                        Rectangle {
                            anchors.fill: parent
                            color: parent.pressed ? "#F3F3F3" : "transparent"
                        }

                        Label {
                            id: pageLabel
                            text: model.ellipsis ? "…" : model.pageNumber
                            fontSize: buttonsRow.pageButtonFontSize
                            anchors.centerIn: parent
                            font.underline: model.current //TODO-r: Line a bit lower (by adding a custom Rectangle component) OR invert color
                        }

                        onClicked: model.ellipsis ? threadPage.openPageSelectionDialog() : goToPage(model.pageNumber - 1)
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
