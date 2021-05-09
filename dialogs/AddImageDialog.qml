import QtQuick 2.15
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.15

import '../common/utils.js' as Utils
import '../common'

FileDialog {
  id: filedialog_root

  title: qsTr('Please choose the pages you want to translate... ')

  selectMultiple: true
  selectExisting: true

  nameFilters: [ "Image files (*.jpg *.jpeg *.png)", "All files (*)" ]


  onAccepted: {
    addImages(fileUrls)
    close()
  }
  onRejected: {
    console.log("Canceled")
    close()
  }

  function addImages(fileUrls) {
    let firstinsert = true // jump to the first-inserted page
    for (let i = 0; i < fileUrls.length; i++) {
      let fileUrl = fileUrls[i]
      let dir = Utils.getdir(fileUrl)
      let name = Utils.getname(fileUrl)

      /* Init model directory */
      if (!root.model_loaded && root.work_dir === '') {
        root.work_dir = dir
        mainmodel.setTags(config.defaultTag)
        root.model_loaded = true
      }

      if (root.work_dir !== dir) {
        infodialog.text = qsTr('Only support images in the same directory')
        infodialog.icon = StandardIcon.Warning
        infodialog.open()
        return
      }

      let index = mainmodel.insertPage(name)

      if (firstinsert) {
        console.log(index)
        mainmodel.gotoPage(index)
        firstinsert = false
      }
    }

    root.last_opened_dir = folder
  }
}
