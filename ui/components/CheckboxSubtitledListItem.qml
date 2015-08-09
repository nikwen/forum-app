/*
 * Copyright 2012 Canonical Ltd.
 * Copyright 2015 Niklas Wenzel <nikwen.developer@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem

ListItem.Base {
    id: subtitledListItem
    __height: units.gu(6)

    property alias subText: subLabel.text
    property alias checked: checkBox.checked

    Column  {
        id: middleVisuals
        anchors {
            left: parent.left
            right: checkBox.left
            rightMargin: units.gu(2)
            verticalCenter: parent.verticalCenter
        }
        height: childrenRect.height

        LabelVisual {
            id: label
            width: parent.width
            text: subtitledListItem.text
            selected: subtitledListItem.selected
        }

        LabelVisual {
            id: subLabel
            width: parent.width
            selected: subtitledListItem.selected
            secondary: true
            fontSize: "small"
            wrapMode: Text.Wrap
            visible: subText !== ""
            maximumLineCount: 1
        }
    }

    CheckBox {
        id: checkBox

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
    }
}
