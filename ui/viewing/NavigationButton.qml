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
import "../components"

AbstractButton {
    id: navigationButton

    width: units.gu(5)

    property bool previous: true //Set true for previous button, false for next button

    anchors {
        top: parent.top
        bottom: parent.bottom
    }

    Binding {
        target: navigationButton
        property: previous ? "anchors.left" : "anchors.right"
        value: previous ? parent.left : parent.right
    }

    Rectangle {
        id: roundedRect

        anchors {
            fill: parent

            topMargin: units.gu(0.1)
            bottomMargin: units.gu(0.1)
        }

        Binding {
            target: roundedRect
            property: previous ? "anchors.leftMargin" : "anchors.rightMargin"
            value: units.gu(0.1)
        }

        color: parent.pressed ? "#F3F3F3" : "transparent"
        radius: units.gu(0.8)
    }

    Rectangle { //Removes rounded corners on the other side
        id: removeRoundedCornersRect

        anchors {
            top: roundedRect.top
            bottom: roundedRect.bottom
        }

        Binding {
            target: removeRoundedCornersRect
            property: previous ? "anchors.right" : "anchors.left"
            value: previous ? roundedRect.right : roundedRect.left
        }

        width: roundedRect.width - roundedRect.radius
        color: roundedRect.color
    }

    Icon {
        name: previous ? "go-previous" : "go-next"
        anchors.centerIn: parent
        height: units.gu(3)
        width: height
    }

    VerticalDivider {
        dividerHeight: units.gu(4)
        anchors.horizontalCenter: previous ? parent.right : parent.left
        rotateClockwise: previous //Fixes a small display issue where the overlay would be shown on top of the divider when previous === false
    }
}
