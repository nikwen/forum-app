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
import Ubuntu.Components.Popups 1.0
import Ubuntu.Components.ListItems 1.0 as ListItem
import Ubuntu.Components.Themes.Ambiance 0.1
import "../../backend"
import "../components"

Page {
    id: editSignaturePage

    title: i18n.tr("Edit Signature")

    Component.onCompleted: {
        signatureTextField.text = backend.signature
    }

    head.actions: [
        Action {
            id: saveAction
            text: i18n.tr("Save")
            iconName: "ok"

            onTriggered: {
                backend.signature = signatureTextField.text
                pageStack.pop()
            }
        }
    ]

    head.backAction: Action {
        id: cancelAction
        text: i18n.tr("Cancel")
        iconName: "close"

        onTriggered: {
            pageStack.pop()
        }
    }

    TextArea {
        id: signatureTextField
        autoSize: false
        maximumLineCount: 0
        placeholderText: i18n.tr("Enter signature or leave blank")

        anchors {
            fill: parent
            margins: units.gu(2)
        }

        style: TextAreaStyle {
            overlaySpacing: 0
            frameSpacing: 0
            background: Item {}
        }
    }
}
