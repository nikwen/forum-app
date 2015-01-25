import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Components.ListItems 1.0 as ListItem

Item {

    width: parent.width
    height: units.gu(6)

    Row {
        id: buttonsRow

        height: childrenRect.height
        anchors.centerIn: parent

        spacing: units.gu(2)

        Icon {
            name: "media-skip-backward"
            width: units.gu(4)
            height: units.gu(4)

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (threadList.firstDisplayedPost !== 0) {
                        threadList.loadPosts(0, backend.postsPerPage);
                    }
                }
            }
        }

        Icon {
            name: "media-playback-start-rtl"
            width: units.gu(4)
            height: units.gu(4)

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
            id: pageLabel
            anchors.verticalCenter: parent.verticalCenter
            fontSize: "large"

            text: threadList.totalPostCount !== -1 ? (Math.floor(threadList.firstDisplayedPost/backend.postsPerPage + 1) + " / " + pageCount) : ""
        }

        Icon {
            name: "media-playback-start"
            width: units.gu(4)
            height: units.gu(4)

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (threadList.lastDisplayedPost < threadList.totalPostCount - 1) {
                        threadList.loadPosts(threadList.lastDisplayedPost + 1, backend.postsPerPage);
                    }
                }
            }
        }

        Icon {
            name: "media-skip-forward"
            width: units.gu(4)
            height: units.gu(4)

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
