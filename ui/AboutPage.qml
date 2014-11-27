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

import QtQuick 2.0
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem

Page {
    id: aboutPage
    title: i18n.tr("About Forum Browser")
    visible:false

    Flickable {
        id: flickable
        anchors.fill: parent
        clip: true

        contentHeight: aboutColumn.height + aboutColumn.marginTop

        Column {
            id: aboutColumn
            width: parent.width
            property real marginTop: units.gu(3)
            y: marginTop

            UbuntuShape {
                property real maxWidth: units.gu(45)
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(parent.width, maxWidth)/2
                height: Math.min(parent.width, maxWidth)/2
                image: Image {
                    source: "../icon.png"
                    smooth: true
                    fillMode: Image.PreserveAspectFit
                }
            }

            Item {
                id: spacer
                width: parent.width
                height: units.gu(2)
            }

            ListItem.Header {
                text: i18n.tr("Info:")
            }

            ListItem.Standard {
                text: i18n.tr("Version:")
                control: Label {
                    text: "0.2.3"
                }
            }

            ListItem.Header {
                text: i18n.tr("Development:")
            }

            ListItem.Standard {
                text: i18n.tr("License:")
                control: Label {
                    text: "GPL v3"
                }
                progression: true
                onClicked: Qt.openUrlExternally("http://www.gnu.org/licenses/gpl-3.0.txt")
            }

            ListItem.Standard {
                text: i18n.tr("Source code & bug tracker:")
                control: Label {
                    text: i18n.tr("Github")
                }
                progression: true
                onClicked: Qt.openUrlExternally("https://github.com/nikwen/forum-app")
            }

            ListItem.Standard {
                text: i18n.tr("Uses code from:")
                control: Label {
                    text: i18n.tr("phpjs (MIT License)")
                }
                progression: true
                onClicked: Qt.openUrlExternally("https://github.com/kvz/phpjs")
            }

            ListItem.Header {
                text: i18n.tr("Authors:")
            }

            ListItem.Standard {
                text: "Niklas Wenzel"
                control: Label {
                    text: i18n.tr("Maintainer")
                }
            }

            ListItem.Standard {
                text: "Michael Hall"
                control: Label {
                    text: i18n.tr("XDA Developers app")
                }
            }

            ListItem.Header {
                text: i18n.tr("Contact:")
            }

            ListItem.Standard {
                text: "nikwen.developer@gmail.com"
                progression: true
                onClicked: Qt.openUrlExternally("mailto:nikwen.developer@gmail.com")
            }

            ListItem.Standard {
                text: i18n.tr("XDA Developers thread")
                progression: true
                onClicked: Qt.openUrlExternally("http://forum.xda-developers.com/ubuntu-touch/apps-games/app-forum-browser-0-1-0-t2867227") //TODO: Open in app
            }

            ListItem.Empty {
                id: poweredByTapatalkItem
                width: parent.width
                height: units.gu(9)
                divider.visible: false

                onClicked: Qt.openUrlExternally("https://tapatalk.com")

                Label {
                    id: poweredLabel
                    font.bold: true
                    text: i18n.tr("Powered by Tapatalk")
                    anchors.centerIn: parent
                }
            }
        }
    }
}
