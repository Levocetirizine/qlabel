import QtQuick 2.15
import QtQuick.Dialogs 1.2

import '../common/utils.js' as Utils

FileDialog {
  title: qsTr('Please choose the translation file you want to import... ')

  selectExisting: true
  nameFilters: [ "Text files (*.txt)", "All files (*)" ]

  onAccepted: {
    let url = fileUrl.toString()
    root.work_dir = Utils.getdir(url)
    root.work_name = Utils.getname(url)
    mainmodel.openUrl(fileUrl)
    root.model_loaded = true
    root.last_opened_dir = folder
    close()
  }

  onRejected: {
    console.log("Canceled")
    close()
  }
}

