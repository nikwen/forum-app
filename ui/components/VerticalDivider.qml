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
import Ubuntu.Components 1.1

Rectangle {
    id: verticalDivider

    property alias dividerHeight: verticalDivider.width
    property real dividerPadding: units.gu(1)

    height: (visible) ? units.dp(2) : 0

    y: width / 2 + dividerPadding
    rotation: 90
    transformOrigin: Item.Center

    property bool __lightBackground: ColorUtils.luminance(Theme.palette.normal.background) > 0.85

    gradient: Gradient {
        GradientStop { position: 0.0; color: __lightBackground ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(0, 0, 0, 0.4) }
        GradientStop { position: 0.49; color: __lightBackground ? Qt.rgba(0, 0, 0, 0.1) : Qt.rgba(0, 0, 0, 0.4) }
        GradientStop { position: 0.5; color: __lightBackground ? Qt.rgba(1, 1, 1, 0.4) : Qt.rgba(1, 1, 1, 0.1) }
        GradientStop { position: 1.0; color: __lightBackground ? Qt.rgba(1, 1, 1, 0.4) : Qt.rgba(1, 1, 1, 0.1) }
    }
}
