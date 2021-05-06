// force to use qt-style dialog to avoid platform-dependent bugs

import QtQuick.Dialogs 1.3

MessageDialog {
  title: qsTr('Info')
  standardButtons: StandardButton.Ok
}
