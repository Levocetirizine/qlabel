import QtQuick 2.15
import QtQuick.Controls 2.15

import '../common'

Item {
  id: iz_root

  property var labelComponent: Qt.createComponent('CustomLabel.qml')

  clip: true

  Item {
    id: iz_labels
    z: iz_img.z + 1

    Connections {
      target: mainmodel
      // FIXME: this is inefficient, but easy to implement
      function onModelReset() {
        iz_labels.rebuildLabels()
      }

      function onRowsInserted() {
        iz_labels.rebuildLabels()
      }

      function onRowsRemoved() {
        iz_labels.rebuildLabels()
      }

      function onRowsMoved() {
        iz_labels.rebuildLabels()
      }

      function onDataChanged(tl, br) {
        if (tl.column === 2 && br.column === 2) {
          iz_labels.rebuildLabels()
        }
      }
    }

    function rebuildLabels() {

      iz_labels.children = []

      for (let i = 0; i < mainmodel.rowCount(); i++) {
        labelComponent.createObject(iz_labels, {index: i})
      }

    }

  }

  Image {
    id: iz_img
    z: iz_bg.z + 1
    fillMode: Image.PreserveAspectFit
    source: ''
    scale: size * Math.min(iz_imgctl.height / height, iz_imgctl.width / width)

    transformOrigin: Item.TopLeft

    property double size: 1.0
    property double size_min: 0.5
    property double size_max: 3.0

    Connections {
      target: mainmodel
      function onCurrentPageChanged() {
        iz_img.source = findSrc()
      }
    }

    onSizeChanged: {
      if (iz_img.source == '') {
        size = 1.0
      }
      size = Math.max(Math.min(size, size_max), size_min)

      iz_img.x = Math.max(iz_img.x, iz_imgctl.drag.minimumX)
      iz_img.y = Math.max(iz_img.y, iz_imgctl.drag.minimumY)
    }
  }

  /* this mousearea overlays with the image to provide function of creating new label */
  MouseArea {
    id: iz_imgctl
    anchors.top: parent.top
    anchors.bottom: bottombar.top
    anchors.left: parent.left
    anchors.right: parent.right

    drag.target: iz_img

    drag.minimumX: Math.min(width - iz_img.width * iz_img.scale, x)
    drag.minimumY: Math.min(height - iz_img.height * iz_img.scale, y)
    drag.maximumX: parent.x
    drag.maximumY: parent.y

    property var pressedX: 0
    property var pressedY: 0

    onWheel: {
      let angle = wheel.angleDelta.y / 120
      if (angle > 0) {
        iz_img.size *= 1.1
      } else {
        iz_img.size /= 1.1
      }

      iz_img.x = Math.max(iz_img.x, drag.minimumX)
      iz_img.y = Math.max(iz_img.y, drag.minimumY)
    }

    onPressed: {
      pressedX = mouse.x
      pressedY = mouse.y
    }

    onReleased: {
      function valid(coord) {
        if (coord < 0) return false
        if (coord > 1) return false
        return true
      }

      let releasedX = mouse.x
      let releasedY = mouse.y
      let distsq = (releasedX - pressedX)**2 + (releasedY - pressedY)**2

      if (distsq < 1000) {
        if (root.mode === Enum.Label && labelComponent.status === Component.Ready) {
          let xr = (mouse.x - iz_img.x) / iz_img.width / iz_img.scale
          let yr = (mouse.y - iz_img.y) / iz_img.height / iz_img.scale
          if (valid(xr) && valid(yr)) {
            mainmodel.doAppendRow(xr, yr, root.tag);
          }
        }
      }
    }
  }

  BottomToolBar {
    id: bottombar
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    z: iz_img.z + 1
  }

  Rectangle {
    id: iz_bg
    color: "#fff2fb"
    anchors.fill: parent

  }

  function findSrc() {
    if (mainmodel.currentPage == -1) return ''
    let path = root.work_dir + '/' + mainmodel.getPageName(mainmodel.currentPage)
    return path
  }

}
