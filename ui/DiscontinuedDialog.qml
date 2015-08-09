import QtQuick 2.3
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0

Component {
     id: discontinuedDialog

     Dialog {
         id: dialog
         title: i18n.tr("Forum Browser development has come to an end")
         text: i18n.tr("With Tapatalk no longer updating their API documentation, shutting down their developer support forums and killing other third-party Tapatalk clients through their lawyers, I do not feel like continuing Forum Browser development is worth the effort.\n\nThat being said, you can still get Forum Browser's source code from Github and modify it to your needs. There will just not be any other official updates.")

         property var onClosed

         Button {
             id: button
             color: UbuntuColors.green
             text: i18n.tr("Got it")
             onClicked: {
                 PopupUtils.close(dialog)

                 if (dialog.onClosed) {
                     dialog.onClosed()
                 }
             }
         }
     }
}
