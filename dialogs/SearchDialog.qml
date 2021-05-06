import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.qmlmodels 1.0

import QtQuick.Dialogs 1.3

Window {
  id: sd_root

  width: 800
  height: 250

  flags: Qt.Dialog
  modality: Qt.NonModal
  title: qsTr('Search')

  Item {
    id: sd_inputzone
    width: parent.width - 180
    height: parent.height
    anchors.top: parent.top
    anchors.leftMargin: 0
    anchors.topMargin: 20
    anchors.left: parent.left

    property int text_margin : 80

    ColumnLayout {

      RowLayout {
        Label {
          text: qsTr('Search: ')
          Layout.leftMargin: sd_inputzone.text_margin - width

        }
        TextField {
          id: sd_searchtext
          Layout.preferredWidth: sd_inputzone.width - sd_inputzone.text_margin - 80

          property bool is_empty: text === ''
        }
      }

      RowLayout {
        Label {
          text: qsTr('Replace: ')
          Layout.leftMargin: sd_inputzone.text_margin - width

        }
        TextField {
          id: sd_replacetext
          Layout.preferredWidth: sd_inputzone.width - sd_inputzone.text_margin - 80

        }
      }

      RowLayout {
        Layout.leftMargin: 15

        RadioButton {
          id: sd_find_next
          checked: true
          text: qsTr('Next')
        }

        RadioButton {
          id: sd_find_prev
          text: qsTr('Prev')
        }

        CheckBox {
          id: sd_find_loop
          text: qsTr('Loop')
        }

      }
    }

  }

  Item {
    id: sd_controlzone
    width: 180
    height: parent.height
    anchors.top: parent.top
    anchors.topMargin: 20
    anchors.right: parent.right

    ColumnLayout {
      property int button_width: parent.width * 0.8
      property int button_height: 35

      Button {
        enabled: !sd_searchtext.is_empty
        text: qsTr('Find next')
        Layout.preferredWidth: parent.button_width
        Layout.preferredHeight: parent.button_height

        onClicked: {
          if (!sd_root.find(false)) {
            sd_inform.text = qsTr('Not Found')
            sd_inform.open()
          }
        }
      }

      Button {
        enabled: !sd_searchtext.is_empty
        text: qsTr('Replace')
        Layout.preferredWidth: parent.button_width
        Layout.preferredHeight: parent.button_height
        Layout.alignment: Qt.AlignHCenter
        onClicked: {
          if (!sd_root.find(true)) {
            sd_inform.text = qsTr('Not Found')
            sd_inform.open()
          }
        }
      }

      Button {
        enabled: !sd_searchtext.is_empty
        text: qsTr('Count')
        Layout.preferredWidth: parent.button_width
        Layout.preferredHeight: parent.button_height
        Layout.alignment: Qt.AlignHCenter
        onClicked: {
          sd_inform.text = qsTr('Found ' + sd_root.findStrAll() + ' occurrences')
          sd_inform.open()
        }
      }

      Button {
        enabled: !sd_searchtext.is_empty
        text: qsTr('Replace All')
        Layout.preferredWidth: parent.button_width
        Layout.preferredHeight: parent.button_height
        Layout.alignment: Qt.AlignHCenter
        onClicked: {
          let cnt = sd_root.findStrAll()
          if (cnt === 0) {
            sd_inform.text = qsTr('Not Found')
            sd_inform.open()
          } else {
            sd_replaceall_confirm.text = qsTr('Replace ' + cnt + ' occurrences ?')
            sd_replaceall_confirm.open()
          }
        }

        MessageDialog {
          id: sd_replaceall_confirm
          title: qsTr('Replace All ?')
          standardButtons: StandardButton.Yes | StandardButton.No
          onYes: {
            sd_root.replaceStrAll()
          }
        }
      }

      Button {
        text: qsTr('Close')
        Layout.preferredWidth: parent.button_width
        Layout.preferredHeight: parent.button_height
        Layout.alignment: Qt.AlignHCenter
        onClicked: {
          sd_root.close()
        }
      }

    }

  }

  function find(replace) {
    if (sd_find_next.checked) {
      return sd_root.findNext(replace)
    }

    if (sd_find_prev.checked) {
      return sd_root.findPrev(replace)
    }
  }

  function findStrAll() {
    let pattern = sd_searchtext.text
    let cnt = 0

    for (let page = 0; page < mainmodel.pageCount(); page++) {
      for (let row = 0; row < mainmodel.rowCountInPage(page) ; row++) {
        let str = mainmodel.getText(page, row)
        let pos = 0
        while (true) {
          pos = str.indexOf(pattern, pos)
          if (pos >= 0) {
            cnt++
            pos += pattern.length
          } else break
        }
      }
    }
    return cnt
  }

  function replaceStrAll(replace) {
    let success = false

    for (let page = 0; page < mainmodel.pageCount(); page++) {
      for (let row = 0; row < mainmodel.rowCountInPage(page); row++) {
        let str = mainmodel.getText(page, row)
        let new_str= str.replace(new RegExp(sd_searchtext.text, 'g'), sd_replacetext.text)
        if (str !== new_str) {
          success = true
          mainmodel.setText(page, row, new_str)
        }
      }
    }
    if (success) {
      mainmodel.refreshPage()
    } else {
      console.log('fail')
    }

  }

  /* match (replace) one pattern in model, also select & highlight the match str */
  function findStr(page, row, pattern, index, replace, inverse) {
    if (row === -1) {
      return false
    }

    let str = mainmodel.getText(page, row)
    let from

    if (inverse) {
      if (index === -1) {
        from = str.lastIndexOf(pattern)
      } else if (index === 0) {
        from = -1 // avoid bug of searching from [0]
      } else {
        from = str.lastIndexOf(pattern, index - 1)
      }
    } else {
      if (index === -1) {
        from = str.indexOf(pattern)
      } else {
        from = str.indexOf(pattern, index)
      }
    }

    if (from === -1) {
      return false
    } else {
      if (mainmodel.currentPage !== page) {
        mainmodel.gotoPage(page)
      }

      if (mainmodel.focusRow !== row) {
        mainmodel.doSelect(row)
      }
      let to = from + pattern.length

      if (replace) {
        let new_str = str.substring(0, from) + sd_replacetext.text + str.substring(to)
        editzone.editbox.text = new_str
        to = from + sd_replacetext.text.length
      }
      editzone.editbox.select(from, to)
      return true
    }
  }

  function findNext(replace) {
    let page = mainmodel.currentPage
    let row = mainmodel.focusRow

    if (sd_root.findStr(page, row, sd_searchtext.text,
                        editzone.editbox.selectionEnd, replace, false)) {
      return true
    }

    let loop_flag = true
    while (true) {
      if (row === mainmodel.rowCountInPage(page) - 1) {
        do {
          if (page === mainmodel.pageCount() - 1) {
            if (sd_find_loop.checked && loop_flag) {
              page = 0
              loop_flag = false // only allow one round in one search
            } else {
              return false
            }
          } else {
            page++
          }
        } while (mainmodel.rowCountInPage(page) === 0) // skip page without any translation
        row = 0
      } else {
        row ++
      }

      if (sd_root.findStr(page, row, sd_searchtext.text, -1, replace, false)) {
        return true
      }
    }
  }

  function findPrev(replace) {
    let page = mainmodel.currentPage
    let row = mainmodel.focusRow

    if (sd_root.findStr(page, row, sd_searchtext.text,
                        editzone.editbox.selectionStart, replace, true)) {
      return true
    }

    let loop_flag = true
    while (true) {
      if (row === 0) {
        do {
          if (page === 0) {
            if (sd_find_loop.checked && loop_flag) {
              page = mainmodel.pageCount() - 1
              loop_flag = false // only allow one round in one search
            } else {
              return false
            }
          } else {
            page--
          }
        } while (mainmodel.rowCountInPage(page) === 0) // skip page without any translation
        row = mainmodel.rowCountInPage(page) - 1
      } else {
        row --
      }

      if (sd_root.findStr(page, row, sd_searchtext.text, -1, replace, true)) {
        return true
      }
    }

  }

  function open() {
    sd_root.show()
  }


  MessageDialog {
    id: sd_inform
    title: qsTr('Info')
    standardButtons: StandardButton.Ok
  }

}
