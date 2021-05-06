import QtQuick 2.0
import QtQuick.Controls 2.15

Text {
  id: lb_root
  text: index + 1
  font.family: "Arial" // TODO: set dynamic font
  font.pointSize: 24
  font.bold: true
  color: config.palette[mainmodel.data(mainmodel.index(index, 2)) % config.palette.length]

  /* this double-bind is not clean, works although */
  x: iz_img.x + iz_img.width * iz_img.scale * xr - width / 2
  y: iz_img.y + iz_img.height * iz_img.scale * yr - height / 2

  transformOrigin: Item.Center

  property double xr: mainmodel.getLabelPosition(index, 'x')
  property double yr: mainmodel.getLabelPosition(index, 'y')
  property int index: 0

  ToolTip {
    id: lb_tip
    delay: 300
    text: mainmodel.getTextAt(lb_root.index)
    visible: lb_mouse.containsMouse

    Connections {
      target: mainmodel

      function onDataChanged(tl, br) {
        if (tl.row <= index && br.row >= index) {
          if (tl.column <= 1 && br.column >= 1) {
            lb_tip.text = mainmodel.getTextAt(lb_root.index)
          }
        }
      }
    }
  }

  MouseArea {
    id: lb_mouse
    anchors.fill: parent
    drag.target: parent
    acceptedButtons: Qt.LeftButton
    hoverEnabled: true

    drag.smoothed: false

    drag.minimumX: iz_img.x
    drag.minimumY: iz_img.y
    drag.maximumX: iz_img.x + iz_img.width * iz_img.scale - parent.width
    drag.maximumY: iz_img.y + iz_img.height * iz_img.scale - parent.height

    onPressed: {
      mainmodel.doSelect(index)
    }

    onReleased: {
      let nx = (parent.x + parent.width / 2 - iz_img.x) / iz_img.width / iz_img.scale
      let ny = (parent.y + parent.height / 2 - iz_img.y) / iz_img.height / iz_img.scale
      mainmodel.setLabelPosition(parent.index, nx, ny)
      xr = nx
      yr = ny
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.RightButton

    onClicked: {
      mainmodel.doSelect(index)
      quickmenu.popup()
    }
  }
}
