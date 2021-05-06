import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtGraphicalEffects 1.15

Rectangle {
  id: toolbar

  color: '#ffffff'
  height: 50

  RowLayout {
    anchors.left: parent.left
    anchors.top: parent.top
    anchors.bottom: parent.bottom

    BottomToolBarButton {
      id: op_in
      imgsrc: '../svg/zoom-in.svg'
      ToolTip.text: 'Ctrl+]'
      ToolTip.visible: hovered
      onClicked: {
        iz_img.size *= 1.1
      }

      Shortcut {
        sequence: 'Ctrl+]'
        onActivated: op_in.clicked()
      }
    }

    BottomToolBarButton {
      id: op_out
      imgsrc: '../svg/zoom-out.svg'
      ToolTip.text: 'Ctrl+['
      ToolTip.visible: hovered
      onClicked: {
        iz_img.size /= 1.1
      }

      Shortcut {
        sequence: 'Ctrl+['
        onActivated: op_out.clicked()
      }
    }

    BottomToolBarButton {
      id: op_max
      imgsrc: '../svg/maximise.svg'
      ToolTip.text: 'Ctrl+0'
      ToolTip.visible: hovered
      onClicked: {
        iz_img.size = 1.0
      }

      Shortcut {
        sequence: 'Ctrl+0'
        onActivated: op_max.clicked()
      }
    }


    BottomToolBarButton {
      id: slidertoggler
      imgsrc: '../svg/search.svg'
      onClicked: {
        sizeslider.visible = !sizeslider.visible
      }

      Slider {
        id: sizeslider
        visible: false
        anchors.bottom: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        value: (iz_img.size - iz_img.size_min) / (iz_img.size_max - iz_img.size_min)
        enabled: iz_img.source !== ''

        onMoved: {
          iz_img.size = (iz_img.size_max - iz_img.size_min) * value + iz_img.size_min
        }
      }
    }
  }

  RowLayout {
    anchors.centerIn: parent

    BottomToolBarButton {
      id: op_prev
      imgsrc: '../svg/arrow-left.svg'
      ToolTip.text: 'Alt+Left'
      ToolTip.visible: hovered
      onClicked: {
        mainmodel.gotoPage(mainmodel.currentPage - 1)
      }
      Shortcut {
        sequence: 'Alt+Left'
        onActivated: op_prev.clicked()
      }
    }

    Label {
      text: (mainmodel.currentPage + 1) + ' / ' + mainmodel.pageNamesList.length
      font.pixelSize: 15
    }

    BottomToolBarButton {
      id: op_next
      imgsrc: '../svg/arrow-right.svg'
      ToolTip.text: 'Alt+Right'
      ToolTip.visible: hovered
      onClicked: {
        mainmodel.gotoPage(mainmodel.currentPage + 1)
      }
      Shortcut {
        sequence: 'Alt+Right'
        onActivated: op_next.clicked()
      }
    }

  }

  ComboBox {
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    model: mainmodel.pageNamesList
    flat: true
    currentIndex: mainmodel.currentPage

    onActivated: {
      mainmodel.currentPage = currentIndex
    }
  }
}
