import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
  id: se_root

  width: 300
  height: 100

  flags: Qt.Dialog
  modality: Qt.WindowModal
  title: qsTr('Settings')

  ColumnLayout {
    Rectangle {
      height: 5
    }

    RowLayout {
      Layout.leftMargin: 10
      Label {
        text: qsTr('Language: ')
      }

      RadioButton {
        checked: true
        text: '简体中文'
        onClicked: {
          trans.selectLanguage('zh_CN')
        }
      }

      RadioButton {
        text: 'English'
        onClicked: {
          trans.selectLanguage('en')
        }
      }
    }
  }

  function open() {
    se_root.show()
  }

}
