import QtQuick.Dialogs 1.3

MessageDialog {
  title: qsTr('Exit')
  text: qsTr('Current model unsaved, save and continue ?')

  standardButtons: StandardButton.Yes | StandardButton.No | StandardButton.Cancel

  onNo: {
    root.model_loaded = false // disable the model
    root.close()
  }

  onYes: {
    mainmodel.saveUrl(root.work_dir + '/' + root.work_name)
    root.model_loaded = false
    root.close()
  }

}
