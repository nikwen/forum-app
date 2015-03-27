import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem
import "../components"

//TODO-r: Solution similar to gallery navigation on m.heise.de

Item {
    width: parent.width
    height: units.gu(8)

    UbuntuShape {
        width: parent.width
        height: units.gu(6)
        anchors.verticalCenter: parent.verticalCenter
        color: "white"

        Rectangle {
            anchors.fill: parent
            color: "transparent"

            AbstractButton { //TODO-r: Separate file for Button (with attribute right/left)
                id: previousButton

                width: units.gu(5)

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                }

                onClicked: {
                    if (threadList.firstDisplayedPost > 0) {
                        threadList.loadPosts(Math.max(threadList.firstDisplayedPost - backend.postsPerPage, 0), backend.postsPerPage);
                    }
                }

                Rectangle {
                    id: roundedRect

                    anchors {
                        fill: parent

                        topMargin: units.gu(0.1)
                        bottomMargin: units.gu(0.1)
                        leftMargin: units.gu(0.1)
                    }
                    color: parent.pressed ? "#F3F3F3" : "transparent"
                    radius: units.gu(0.8)
                }

                Rectangle {
                    anchors {
                        top: roundedRect.top
                        bottom: roundedRect.bottom
                        right: roundedRect.right

                        topMargin: roundedRect.anchors.topMargin
                        bottomMargin: roundedRect.anchors.bottomMargin
                        leftMargin: roundedRect.anchors.leftMargin
                    }

                    width: roundedRect.width - roundedRect.radius
                    color: roundedRect.color
                }


                Icon {
                    name: "go-previous"
                    anchors.centerIn: parent
                    height: units.gu(3)
                    width: height
                }
            }

            VerticalDivider {
                dividerHeight: units.gu(4)
                anchors.horizontalCenter: previousButton.right
            }

            Row {
                id: buttonsRow

                height: childrenRect.height
                anchors.centerIn: parent

                spacing: units.gu(1)


//                onClicked: {
//                    if (threadList.firstDisplayedPost !== 0) {
//                        threadList.loadPosts(0, backend.postsPerPage);
//                    }
//                }


//                onClicked: {
//                    if (threadList.firstDisplayedPost > 0) {
//                        threadList.loadPosts(Math.max(threadList.firstDisplayedPost - backend.postsPerPage, 0), backend.postsPerPage);
//                    }
//                }

//                onClicked: {
//                    if (threadList.lastDisplayedPost < threadList.totalPostCount - 1) {
//                        threadList.loadPosts(threadList.lastDisplayedPost + 1, backend.postsPerPage);
//                    }
//                }

//                onClicked: {
//                    var postsOnLastPage = ((threadList.totalPostCount) % backend.postsPerPage);
//                    var beginningLastPage = threadList.totalPostCount - (postsOnLastPage === 0 ? backend.postsPerPage : postsOnLastPage);
//                    if (beginningLastPage !== threadList.firstDisplayedPost) {
//                        threadList.loadPosts(beginningLastPage, backend.postsPerPage);
//                    }
//                }
            }
        }
    }
}
