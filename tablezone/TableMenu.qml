import QtQuick 2.15
import QtQuick.Controls 2.15

Menu {
  property int fontsize: 15

  id: root

  MenuSeparator {}

  MenuItem {
    text: qsTr("Change index to ...")
    font.pixelSize: fontsize
    implicitHeight: fontsize * 2.0
    onTriggered: {
      isdialog.limit = mainmodel.rowCount()
      isdialog.selected = mainmodel.focusRow + 1
      isdialog.open()
    }
  }

  MenuItem {
    text: qsTr("Delete Selected")
    font.pixelSize: fontsize
    implicitHeight: fontsize * 2.0
    onTriggered: {
      mainmodel.doRemoveSelectedRows();
    }
  }

  Connections {
    target: mainmodel

    // FIXME: known bug here, tag menu item may disappear
    function onTagsChanged() {
      root.rebuildMenuItems()
    }

    function onModelReset() {
      root.rebuildMenuItems()
    }

    function onRowsRemoved() {
      root.rebuildMenuItems()
    }

    function onRowsMoved() {
      root.rebuildMenuItems()
    }

    function onDataChanged(tl, br) {
      if (tl.column === 2 && br.column === 2) {
        root.rebuildMenuItems()
      }
    }

  }

  function rebuildMenuItems() {
    while (root.count > 3) {
      root.takeItem(0)
    }
    let tagComponent = Qt.createComponent('TableZoneMenuItem.qml')
    let tags = mainmodel.getTags()
    for (let i = tags.length - 1; i >= 0; i--) {
      root.insertItem(0, tagComponent.createObject(null, {tagIndex: i, text: tags[i]}))
    }
  }

}
