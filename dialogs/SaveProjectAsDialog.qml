import QtQuick 2.15
import QtQuick.Dialogs 1.2

import '../common/utils.js' as Utils

FileDialog {
  title: qsTr('Save as... ')

  selectExisting: false
  nameFilters: [ "Text files (*.txt)" ]
  defaultSuffix: 'txt'

  onAccepted: {
    mainmodel.saveUrl(fileUrl)
    console.log(fileUrl)
    root.work_dir = Utils.getdir(String(fileUrl))
    root.work_name = Utils.getname(String(fileUrl))
    console.log('done')
  }

  onRejected: {
    console.log("Canceled")
    close()
  }
}
