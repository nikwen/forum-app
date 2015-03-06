import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem

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
    //        width: parent.width
    //        height: units.gu(6)
    //        color: "white"
            color: "transparent"
    //        radius: units.gu(0.5)
    //        anchors.verticalCenter: parent.verticalCenter

            Row {
                id: buttonsRow

                height: childrenRect.height
                anchors.centerIn: parent

                spacing: units.gu(1)

                Row {
                    anchors.verticalCenter: parent.verticalCenter

                    Icon { //TODO-r: Really height of Label
                        name: "go-first"
                        width: height
                        height: firstLabel.height

                        MouseArea { //TODO-r: Center in Row
                            anchors.fill: parent

                            onClicked: {
                                if (threadList.firstDisplayedPost !== 0) {
                                    threadList.loadPosts(0, backend.postsPerPage);
                                }
                            }
                        }
                    }

                    Label {
                        id: firstLabel
                        text: i18n.tr("First")
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter

                    Icon {
                        name: "go-previous"
                        width: height
                        height: backLabel.height

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                if (threadList.firstDisplayedPost > 0) {
                                    threadList.loadPosts(Math.max(threadList.firstDisplayedPost - backend.postsPerPage, 0), backend.postsPerPage);
                                }
                            }
                        }
                    }

                    Label {
                        id: backLabel
                        text: i18n.tr("Back")
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Label {
                    id: pageLabel
                    anchors.verticalCenter: parent.verticalCenter
                    fontSize: "large"

                    text: threadList.totalPostCount !== -1 ? (Math.floor(threadList.firstDisplayedPost/backend.postsPerPage + 1) + " / " + pageCount) : ""
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        id: nextLabel
                        text: i18n.tr("Next")
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Icon {
                        name: "go-next"
                        width: height
                        height: nextLabel.height

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                if (threadList.lastDisplayedPost < threadList.totalPostCount - 1) {
                                    threadList.loadPosts(threadList.lastDisplayedPost + 1, backend.postsPerPage);
                                }
                            }
                        }
                    }
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        id: lastLabel
                        text: i18n.tr("Last")
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Icon {
                        name: "go-last"
                        width: height
                        height: lastLabel.height

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                var postsOnLastPage = ((threadList.totalPostCount) % backend.postsPerPage);
                                var beginningLastPage = threadList.totalPostCount - (postsOnLastPage === 0 ? backend.postsPerPage : postsOnLastPage);
                                if (beginningLastPage !== threadList.firstDisplayedPost) {
                                    threadList.loadPosts(beginningLastPage, backend.postsPerPage);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
