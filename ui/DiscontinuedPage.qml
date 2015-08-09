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
import Ubuntu.Components 1.2

Page {
    id: discontinuedPage
    title: ""

    Flickable {
        id: flickable
        anchors.fill: parent
        clip: true

        contentHeight: discontinuedColumn.height + 2 * discontinuedColumn.anchors.margins

        Column {
            id: discontinuedColumn
            height: childrenRect.height
            spacing: units.gu(1)
            y: anchors.margins

            anchors {
                left: parent.left
                right: parent.right
                margins: units.gu(1)
            }

            Label {
                width: parent.width
                fontSize: "x-large"
                text: i18n.tr("Forum Browser development has come to an end")
                wrapMode: Text.Wrap
            }

            Item {
                id: spacer1
                width: parent.width
                height: units.gu(2)
            }

            UbuntuShape {
                property real maxWidth: units.gu(45)
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(parent.width, maxWidth)/2
                height: Math.min(parent.width, maxWidth)/2
                radius: "medium"
                image: Image {
                    source: "../icon.png"
                    smooth: true
                    fillMode: Image.PreserveAspectFit
                }
            }

            Item {
                id: spacer2
                width: parent.width
                height: units.gu(2)
            }

            Label {
                width: parent.width
                text: i18n.tr("With Tapatalk no longer updating their API documentation, shutting down their developer support forums and killing other third-party Tapatalk clients through their lawyers, I do not feel like continuing Forum Browser development is worth the effort.")
                wrapMode: Text.Wrap
            }

            Label {
                width: parent.width
                text: i18n.tr("That being said, you can still get Forum Browser's source code and modify it to your needs. There will just not be any other official updates.")
                wrapMode: Text.Wrap
            }

            AbstractButton {
                id: gotItButton
                width: parent.width
                height: units.gu(6)

                onTriggered: pageStack.pop()

                Rectangle {
                    id: buttonRect
                    anchors.fill: parent
                    color: gotItButton.pressed ? UbuntuColors.green : Qt.darker(UbuntuColors.green, 1.1)
                }

                Label {
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr("Got it")

                    anchors.centerIn: buttonRect
                }
            }
        }
    }
}
