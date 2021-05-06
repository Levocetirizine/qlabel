import QtQuick 2.15
import QtQuick.Controls 2.15

MenuItem {
  property int tagIndex: 0

  font.pixelSize: fontsize
  implicitHeight: fontsize * 2.0

  onTriggered: {
    mainmodel.changeSelectedRowsTagTo(tagIndex)
    root.tag = tagIndex
  }
}
