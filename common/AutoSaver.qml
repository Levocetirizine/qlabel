import QtQuick 2.0
import QtQml 2.15

/**
 * Format of autosave: YYMMDD_hhmmss_{$work_name}.txt
 *
 */


Item {
  property var locale: Qt.locale()

  function savebak() {
    if (root.model_loaded && root.work_dir !== '') {
      mainmodel.autoSave(root.work_dir, makefilename())
    }
  }

  function makefilename() {
    let namebody = qsTr('unnamed.txt')
    if (root.work_name !== '') {
      namebody = root.work_name
    }

    let prefix = new Date().toLocaleString(locale, 'yyMMdd_hhmmss')
    return prefix + '_' + namebody
  }

  Component.onCompleted: {
    console.log('autosaver init')
  }
}
