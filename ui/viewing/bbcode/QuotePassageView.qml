import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Layouts 1.0
import ".."

Rectangle {
    height: quoteLabel.height + 2 * quoteLabel.anchors.margins + passageView.height + 2 * passageView.anchors.margins
    color: "#EEEEEE"

    property alias dataItem: passageView.dataItem

    onDataItemChanged: {
        if (dataItem.tagArguments["name"] !== undefined) {
            console.log("Quote name:", dataItem.tagArguments["name"])
            console.log("Quote post:", dataItem.tagArguments["post"])
        }
    }

    Label {
        id: quoteLabel

        text: i18n.tr("<b>Quote</b>")

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: units.gu(1)
        }
    }

    PassageView {
        id: passageView
        dataItem: bbRoot
        anchors {
            top: quoteLabel.bottom
            left: parent.left
            right: parent.right
            margins: units.gu(1)
        }
    }
}
