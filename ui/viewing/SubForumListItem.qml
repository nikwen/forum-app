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
import Ubuntu.Components.ListItems 1.0
import "../components"

Base {
    id: subtitledListItem
    property alias replies: counter.text
    property string author: ''
    property bool has_new: false

    onAuthorChanged: {
        subLabel.text = "Thread by: " + author
    }

    __height: Math.max(middleVisuals.height + units.gu(2), units.gu(6))

    property alias text: label.text
    property alias subText: subLabel.text

    UbuntuShape {
        id: countContainer
        height: units.gu(4)
        width: units.gu(4)
        color: "green"

        visible: model.topic

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }

        Label {
            id: counter
            anchors.centerIn: parent
            fontSize: "medium"
            text: "0"
            color: "white"

            Component.onCompleted: {
                var sizes = ["small", "x-small", "xx-small"]
                var index = 0
                while (width > units.gu(3) && index < sizes.length) {
                    fontSize = sizes[index]
                    index++
                }
            }
        }
    }

    Column  {
        id: middleVisuals
        anchors {
            left: model.topic?countContainer.right:parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: model.topic?units.gu(2):0
        }
        height: childrenRect.height

        LabelVisual {
            id: label
            width: parent.width
            selected: subtitledListItem.selected
        }
        LabelVisual {
            id: subLabel
            width: parent.width
            selected: subtitledListItem.selected
            secondary: !model.topic //No grey color when browsing through topics
            visible: text !== ""
            fontSize: "small"
            wrapMode: Text.Wrap
            maximumLineCount: 5
        }
    }
}
