import QtQuick.Dialogs 1.3

MessageDialog {
  title: qsTr('Open project')
  text: qsTr('Current model unsaved, save and continue ?')

  standardButtons: StandardButton.Yes | StandardButton.No | StandardButton.Cancel

  onNo: {
    openProject.open()
  }

  onYes: {
    mainmodel.saveUrl(root.work_dir + '/' + root.work_name)
    openProject.open()
  }
}
