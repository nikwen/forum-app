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
    __height: Math.max(middleVisuals.height, units.gu(6))

    /*!
      \preliminary
      The list of strings that will be shown under the label text
      \qmlproperty string subText
     */
    property alias subText: subLabel.text

    property alias checked: checkBox.checked

    Item  {
        id: middleVisuals
        anchors {
            left: parent.left
            right: checkBox.left //NOTE: Changed the anchor here (also removed the example code comments and fixed the imports)
            rightMargin: units.gu(2) //NOTE: Added this margin
            verticalCenter: parent.verticalCenter
        }
        height: childrenRect.height + label.anchors.topMargin + subLabel.anchors.bottomMargin

        LabelVisual {
            id: label
            text: subtitledListItem.text
            selected: subtitledListItem.selected
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
        }
        LabelVisual {
            id: subLabel
            selected: subtitledListItem.selected
            secondary: true
            anchors {

                left: parent.left
                right: parent.right
                top: label.bottom
            }
            fontSize: "small"
            wrapMode: Text.Wrap
            maximumLineCount: 1 //NOTE: Changed the line count here
        }
    }

    CheckBox { //NOTE: Added this CheckBox
        id: checkBox

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
    }
}
