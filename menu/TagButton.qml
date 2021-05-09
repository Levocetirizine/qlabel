import QtQuick 2.15
import QtQuick.Controls 2.15

ToolButton {
  id: tag_root

  property int index: 0
  property bool activated: true

  visible: false
  text: '(nil)'
  autoExclusive: true
  checkable: true
  checked: root.tag === index
  onClicked: {
    root.tag = index
    mainmodel.changeSelectedRowsTagTo(index)
  }

  Shortcut {
    sequence: 'Ctrl+' + (index + 1)
    onActivated: {
      if (tag_root.visible) {
        tag_root.clicked()
      }
    }
  }

  ToolTip.text: 'Ctrl+' + (index + 1)
  ToolTip.visible: hovered
  flat: false
}
