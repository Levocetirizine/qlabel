import QtQuick.Dialogs 1.3

MessageDialog {
  title: qsTr('New project')
  text: qsTr('Current model unsaved, save and continue ?')

  standardButtons: StandardButton.Yes | StandardButton.No | StandardButton.Cancel

  onNo: {
    root.close_project()
    addImage.open()
  }

  onYes: {
    mainmodel.saveUrl(root.work_dir + '/' + root.work_name)
    root.close_project()
    addImage.open()
  }
}
