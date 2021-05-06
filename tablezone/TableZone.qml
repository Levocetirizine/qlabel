import QtQuick 2.15
import QtQuick.Controls 2.15

import QLabel.LabelModel 0.1

TableView {
  property int fontsize: 15

  columnSpacing: 0
  rowSpacing: fontsize * 0.2
  clip: true

  id : tablezone
  flickableDirection: Flickable.VerticalFlick

  model: mainmodel
  reuseItems : true

  Rectangle {
    color: '#f7feff'

    width: tablezone.width
    height: tablezone.height
    x: tablezone.x
    y: tablezone.y
  }

  delegate:  Rectangle {
    implicitWidth: findWidth(column)
    implicitHeight: fontsize * 2.5

    color: findColor(select)

    Rectangle {
      visible: (select === true) && (column === 0)
      color: '#4b74ff'
      implicitWidth: parent.implicitWidth * 0.1
      implicitHeight: parent.implicitHeight
      z: 100
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.leftMargin: implicitHeight * 0.6
      anchors.rightMargin: implicitHeight * 0.5
      text: findText(display)
      font.pixelSize: fontsize
      color: column === 2 ? config.palette[display % config.palette.length] : '#333333'
      elide: Text.ElideRight
    }

    Connections {
      target: tablezone
      function onWidthChanged() {
        tablezone.forceLayout()
      }
    }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.LeftButton | Qt.RightButton

      onClicked: {
        if (mouse.button === Qt.RightButton) {
          if (!select) {
            mainmodel.doSelect(row)
          }
          quickmenu.popup()
        } else {
          if (mouse.modifiers & Qt.ControlModifier) {
            mainmodel.doCtrlSelect(row)
          } else if (mouse.modifiers & Qt.ShiftModifier) {
            mainmodel.doShiftSelect(row)
          } else {
            mainmodel.doSelect(row)
          }
        }

      }
    }

    function findColor(select) {
      if (select) {
        return '#e5eaf8'
      } else {
        return 'white'
      }
    }

    function findText(display) {
      if (display !== undefined) {
        switch (column) {
          case 0:
            return display + 1
          case 1:
            return display.replace(/(\r\n|\n|\r)/gm, " ");
          case 2:
            return mainmodel.getTags()[display]
          default:
            return null
        }
      } else {
        return null
      }
    }

    function findWidth(column) {
      switch (column) {
        case 0:
          return 50
        case 1:
          return tablezone.width - 200
        case 2:
          return 150
        default:
          return 0
      }
    }
  }


  Shortcut {
    sequence: 'Alt+Up'
    onActivated: mainmodel.doSelect(mainmodel.focusRow - 1)
  }

  Shortcut {
    sequence: 'Alt+Down'
    onActivated: mainmodel.doSelect(mainmodel.focusRow + 1)
  }

  Shortcut {
    sequence: 'Alt+Home'
    onActivated: mainmodel.doSelect(0)
  }

  Shortcut {
    sequence: 'Alt+End'
    onActivated: mainmodel.doSelect(mainmodel.rowCountInPage(mainmodel.currentPage) - 1)
  }

}


