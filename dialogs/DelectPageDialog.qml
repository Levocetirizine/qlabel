import QtQuick.Dialogs 1.3

MessageDialog {
  title: qsTr('Do delete')
  text: qsTr('Are you SURE to delect the page ?')

  standardButtons: StandardButton.Yes | StandardButton.No

  onYes: {
    if (mainmodel.pageCount() > 1) {
      mainmodel.delectCurrentPage()
    } else {
      root.close_project()
    }
  }
}
