import QtQuick 2.15
import QtQuick.Controls 2.15


Item {
  id: editbox_root

  property var editbox: editbox

  Rectangle {
    anchors.fill: parent
    color: '#f7fff8'
  }

  Flickable {
    id: scrollview
    anchors.top: parent.top
    anchors.bottom: quicktext_wrapper.top
    anchors.left: parent.left
    anchors.right: parent.right
    contentWidth: editbox.paintedWidth
    contentHeight: editbox.paintedHeight
    clip: true

    anchors.topMargin: 10
    anchors.leftMargin: 10

    ScrollBar.vertical: ScrollBar {
      id: scrollbar
      policy: ScrollBar.AlwaysOn

      width: 10
    }

    TextEdit  {
      id: editbox
      width: root.width - scrollview.anchors.leftMargin - scrollbar.width
      height: Math.max(root.height - quicktext_wrapper.height, contentHeight)
      selectByMouse : true
      selectionColor: '#3399FF'
//      persistentSelection: true

      wrapMode: TextEdit.Wrap
      visible: mainmodel.focusRow !== -1

      text: ''
      onTextChanged: {
        if (mainmodel.focusRow !== -1) {
          mainmodel.setTextAt((mainmodel.focusRow), text)
        } else {
          text = ''
        }
      }

      Keys.onPressed: {
        if (event.modifiers & Qt.AltModifier) {
          if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
            let index = event.key - Qt.Key_1
            let quicktext_list = config.quickText
            if (index < quicktext_list.length) {
              editbox.insert(editbox.cursorPosition, quicktext_list[index])
            }
            event.accepted = true
          }
        }
      }

      Text {
        text: qsTr('Click to input translation...')
        visible: editbox.text === '' && editbox.inputMethodComposing === false
        color: '#a1a1a1'
      }

      Connections {
        target: mainmodel
        function onFocusRowChanged(row) {
          if (row === -1) {
            editbox.text = ''
          } else {
            editbox.text = mainmodel.getTextAt(row)
          }
        }
      }
    }
  }

  Rectangle {
    id: quicktext_wrapper
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right

    height: 30

    Item {
      id: quicktext_menubar
      anchors.fill: parent

      ToolButton {
        id: quicktext_editbutton
        anchors.top: quicktext_menubar.top
        anchors.bottom: quicktext_menubar.bottom
        anchors.left: quicktext_menubar.left

        text: qsTr('Quicktext')
        height: parent.height
        flat: true
        display: AbstractButton.TextBesideIcon
        icon.source: '../svg/edit.svg'
        onClicked: {
          infodialog.text = qsTr('Edit function is under development, please edit config toml to change quicktexts')
          infodialog.open()
        }
      }

      ToolSeparator {
        id: quicktext_separator
        anchors.top: quicktext_menubar.top
        anchors.bottom: quicktext_menubar.bottom
        anchors.left: quicktext_editbutton.right

        contentItem.visible: true
        height: parent.height
      }

      Row  {
        id: quicktext_selector
        anchors.top: quicktext_menubar.top
        anchors.bottom: quicktext_menubar.bottom
        anchors.left: quicktext_separator.right
      }

      Connections {
        target: config

        // TODO: imple qtext change
      }

      Component.onCompleted: {
        quicktext_menubar.buildQuickTextItems()
      }

      function buildQuickTextItems() {
        quicktext_selector.children = []
        let quicktext_list = config.quickText
        let quicktext_comp = Qt.createComponent('QuickTextItem.qml')
        for (let i = 0; i < quicktext_list.length; i++) {
          quicktext_comp.createObject(quicktext_selector, {index: i, text_p: quicktext_list[i]})
        }

      }
    }
  }
}

