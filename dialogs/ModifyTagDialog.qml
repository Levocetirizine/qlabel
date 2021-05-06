import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
  id: mt_root

  width: 360
  height: 360

  flags: Qt.Dialog

  Rectangle {
    id: mt_bg
    anchors.fill: parent
    color: '#f2f2f2'
  }


  Item {
    id: mt_label
    anchors.top: mt_bg.top
    width: parent.width
    height: 50

    Label {
      id: mt_label_text
      anchors.left: parent.left
      anchors.leftMargin: 30
      anchors.verticalCenter: parent.verticalCenter
      text: qsTr('Please edit tag, one line each')
    }
  }


  Item {
    id: mt_editbox_wrapper
    anchors.top: mt_label.bottom
    anchors.horizontalCenter: mt_bg.horizontalCenter
    width: mt_root.width - 60
    height: mt_root.height - mt_label.height - mt_bot.height

    Rectangle {
      anchors.fill: parent
      color: 'white'
    }

    Flickable {
      id: mt_editbox_ctl
      anchors.fill: parent
      contentWidth: mt_editbox.paintedWidth
      contentHeight: mt_editbox.paintedHeight
      clip: true

      ScrollBar.vertical: ScrollBar {
        id: mt_editbox_scrollbar
        width: 10
      }

      TextEdit {
        id: mt_editbox
        width: mt_editbox_wrapper.width - mt_editbox_scrollbar.width
        height: Math.max(mt_editbox_wrapper.height, contentHeight)
        wrapMode: TextEdit.Wrap
        selectByMouse : true
        selectionColor: '#3399FF'
        text: ''
      }
    }
  }

  Item {
    id: mt_bot
    anchors.top: mt_editbox_wrapper.bottom
    width: mt_root.width
    height: 80

    Row {
      anchors.right: parent.right
      anchors.rightMargin: parent.width * 0.05
      anchors.verticalCenter: parent.verticalCenter
      spacing: 30

      Button {
        text: qsTr("OK")
        onClicked: {
          let tags = mt_editbox.text.split('\n').map(tag => tag.trim()).filter(Boolean)
          mainmodel.setTags(tags)
          mainmodel.refreshPage()
          mt_root.close()
        }
      }

      Button {
        flat: true
        text: qsTr("Cancel")
        onClicked: {
          mt_root.close()
        }
      }
    }
  }


  function open() {
    /* load current tags */
    let tags = mainmodel.getTags()
    let out = ''
    for (let i = 0; i < tags.length; i++) {
      out += tags[i]
      out += '\n'
    }
    mt_editbox.text = out
    mt_root.show()
  }
}
