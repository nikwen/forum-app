import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Layouts 1.0

//TODO: Show only 5 lines + a "show more" label
//TODO-r: Somewhat smaller margin below quotes

Rectangle {
    id: quoteRect
    height: quoteLabel.height + quoteLabel.anchors.topMargin + dividerRect.height + dividerRect.anchors.topMargin + passageView.height + passageView.anchors.topMargin + passageView.anchors.bottomMargin + border.width
    radius: units.gu(0.5)
    border {
        width: units.dp(1)
        color: "#CCCCCC"
    }

    property alias dataItem: passageView.dataItem
    property bool code: false
    property color tintColor: "#F7F7F7" //TODO-r: Darker with every step downwards the hierarchy?! (important: Also when [code] inside [quote] or the other way round)

    Label {
        id: quoteLabel
        wrapMode: Text.Wrap

        text: code ? i18n.tr("Code") : ((dataItem.tagArguments["name"] !== undefined) ? qsTr(i18n.tr("Quote by %1")).arg(dataItem.tagArguments["name"]) : i18n.tr("Quote"))

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: units.gu(1)
        }
    }

    Rectangle {
        id: dividerRect
        height: quoteRect.border.width
        color: quoteRect.border.color

        anchors {
            top: quoteLabel.bottom
            left: parent.left
            right: parent.right
            topMargin: units.gu(1)
        }
    }

    Rectangle {
        radius: quoteRect.radius
        color: tintColor

        anchors {
            top: dividerRect.top
            bottom: quoteRect.bottom
            left: parent.left
            right: parent.right
            margins: quoteRect.border.width
        }
    }

    Rectangle {
        height: quoteRect.radius
        color: tintColor

        anchors {
            top: dividerRect.top
            left: parent.left
            right: parent.right
            margins: quoteRect.border.width
        }
    }

    PassageView {
        id: passageView
        dataItem: bbRoot

        anchors {
            top: dividerRect.bottom
            left: parent.left
            right: parent.right
            topMargin: units.gu(1.25)
            bottomMargin: units.gu(1.25)
            leftMargin: units.gu(1)
            rightMargin: units.gu(1)
        }
    }
}
