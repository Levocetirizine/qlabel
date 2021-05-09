import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Qt.labs.qmlmodels 1.0

Window {
  id: punc_root

  property bool inited: false

  /* used for parsing */
  property var rules: []
  property var rule_names: []
  property var match_results: []

  width: 800
  height: 600

  flags: Qt.Dialog

  modality: Qt.WindowModal

  title: qsTr('Punc Check')

  Rectangle {
    id: punc_bg
    anchors.fill: parent
    color: '#f7f7f7'
  }

  ColumnLayout {
    id: punc_ctx
    anchors.fill: parent
    spacing: height * 0.05

    Row {
      id: punc_ctx_top
      Layout.preferredWidth: parent.width * 0.8
      Layout.preferredHeight: 80
      Layout.alignment: Qt.AlignHCenter
      spacing: width * 0.05

      Text {
        id: punc_combo_text
        anchors.verticalCenter: parent.verticalCenter
        text: qsTr('Rule: ')
      }

      ComboBox {
        id: punc_combo
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - punc_combo_text.width - parent.spacing

        onActivated: punc_root.preview(currentIndex)
      }
    }

    Item {
      id: punc_ctx_sheet
      Layout.preferredWidth: parent.width * 0.8
      Layout.fillHeight: true
      Layout.alignment: Qt.AlignHCenter

      Rectangle {
        id: punc_ctx_tableheader
        anchors.top: punc_ctx_sheet.top
        anchors.left: punc_ctx_sheet.left
        height: 30
        width: punc_ctx_sheet.width
        color: '#289672'

        Row {
          Text {
            text: qsTr("page")
            color: 'white'
            font.bold: true
            width: punc_ctx_tableheader.width * 0.1
          }

          Text {
            text: qsTr("index")
            color: 'white'
            font.bold: true
            width: punc_ctx_tableheader.width * 0.1
          }

          Text {
            text: qsTr("text")
            color: 'white'
            font.bold: true
            width: punc_ctx_tableheader.width * 0.7
          }

          Text {
            text: qsTr("replace")
            color: 'white'
            font.bold: true
            width: punc_ctx_tableheader.width * 0.1
          }
        }
      }

      Item {
        anchors.top: punc_ctx_tableheader.bottom
        anchors.left: punc_ctx_sheet.left
        height: punc_ctx_sheet.height - punc_ctx_tableheader.height
        width: punc_ctx_sheet.width
        clip: true // avoid table element go out of boundary

        TableView {
          id: punc_ctx_tableview
          height: parent.height
          width: parent.width
          columnSpacing: 0
          rowSpacing: 2

          ScrollBar.vertical: ScrollBar {
            id: punc_ctx_tableview_scrollbar
            width: 10
          }

          model: TableModel {
            id: punc_render_model
            TableModelColumn { display: 'page' }
            TableModelColumn { display: 'index' }
            TableModelColumn { display: 'position'}
            TableModelColumn { display: 'replace' }
            rows: match_results
          }

          delegate: Rectangle {
            id: punc_render_delegate
            implicitWidth: findwidth(column) //FIXME: bug here, width not update correctly
            implicitHeight: 30

            Text {
              anchors.fill: parent
              text: model.display
              elide: Text.ElideRight
            }

            function findwidth(column) {
              switch (column) {
                case 0: // page
                  return punc_ctx_sheet.width * 0.1
                case 1: // index
                  return punc_ctx_sheet.width * 0.1
                case 2: // position
                  return punc_ctx_sheet.width * 0.7
                case 3: // shallbe
                  return punc_ctx_sheet.width * 0.1
              }
            }
          }
        }
      }
    }

    Item {
      id: punc_ctx_bot
      Layout.preferredWidth: parent.width
      Layout.preferredHeight: 80

      Row {
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.05
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20

        Button {
          text: qsTr("OK")
          onClicked: {
            console.log('ok')
            punc_root.apply(punc_combo.currentIndex)
            mainmodel.refreshPage()
            punc_root.close()
          }
        }

        Button {
          text: qsTr("Cancel")
          onClicked: punc_root.close()
          flat: true
        }

      }
    }

  }

  function render(results) {
    punc_render_model.rows = results
    punc_ctx_tableview.contentX = 0
    punc_ctx_tableview.contentY = 0
  }

  // FIXME: this function is vulnerable to html injection
  function makeRichText(text, pos, len) {
    let rich_text = text.slice(0, pos) + '<b><font color="#ce1212">'
                  + text.slice(pos, pos+len) + '</font></b>' + text.slice(pos+len)
    let rich_text_out = rich_text.replace(/(\r\n|\n|\r)/gm, " ") // keep in one line

    // truncate in case we can't see the bold-marked texts
    if (pos > 15) { // FIXME: what if \r\n exists in first 15 digit ?
      rich_text_out = '...' + rich_text_out.slice(pos - 14)
    }
    return rich_text_out
  }

  /**
   * match text with rule descs, rules will be applied to the string one by one
   * will return a list of [richtext with matched text highlighted, string will be replaced to]
   *
   */

  function text_match(text, rule_descs) {
    let results = []
    rule_descs.forEach(function(rule_desc, i) { // for each match rule
      let rule_to = rule_desc['to']
      rule_desc['from'].forEach(function(rule_from, i) { // for each rule_from field
        let pos = 0
        let matched = false
        while (true) {
          pos = text.indexOf(rule_from, pos)
          if (pos >= 0) {
            let matched_text = makeRichText(text, pos, rule_from.length)
            results.push([matched_text, rule_to])
            pos++
            matched = true
          } else break
        }

        // update text based on one rule_from
        if (matched) {
          text = text.split(rule_from).join(rule_to);
        }
      })
    })

    return [text, results]
  }


 /**
  *  Example of rule:
  *
  *      [[edit.punc_checks]]
  *      name = "Force Halfwidth"
  *      rules = [
  *        { from = ["："] , to = ":" } ,
  *        { from = ["；"] , to = ";" } ,
  *        { from = ["，"] , to = "," } ,
  *        { from = ["。"] , to = "." } ,
  *        { from = ["？"] , to = "?" } ,
  *        { from = ["！"] , to = "!" } ,
  *        { from = ["“", "”"] , to = "\"" } ,
  *        { from = ["‘", "’"] , to = "'" } ,
  *        { from = ["～"] , to = "~" }
  *       ]
  */

  /* update everything based on rules */
  function apply(index) {

    console.log('run apply')

    let rule_descs = punc_root.rules[index]['rules']

    let pageNum = mainmodel.pageCount()
    for (let p = 0; p < pageNum; p++) {
      let rowNum = mainmodel.rowCountInPage(p)
      for (let r = 0; r < rowNum; r++) {
        let text = mainmodel.getText(p, r)
        let new_text = text_match(text, rule_descs)[0]
        mainmodel.setText(p, r, new_text) // FIXME: known bug here, maybe not send reset signal here ?
      }
    }
  }

  function preview(index) {
    let rule_descs = punc_root.rules[index]['rules']
    let results = [] // page, index, position, shallbe
    let pageNum = mainmodel.pageCount()
    for (let p = 0; p < pageNum; p++) {
      let rowNum = mainmodel.rowCountInPage(p)
      for (let r = 0; r < rowNum; r++) {
        let text = mainmodel.getText(p, r)
        let matches = text_match(text, rule_descs)[1]
        matches.forEach(function(match) {
          results.push({page: p, index: r, position: match[0], replace: match[1]})
        })
      }
    }
    render(results)
  }

  function open() {
    if (!punc_root.inited) {
      init()
    }

    if (punc_root.rule_names.length !== 0) {
      punc_root.preview(punc_combo.currentIndex)
    }

    punc_root.show()
  }

  function init() {
    punc_root.rules = config.puncCheck
    punc_root.rules.forEach(function(rule, i){
      punc_root.rule_names.push(rule['name'])
    })
    punc_combo.model = rule_names
    punc_root.inited = true
  }

}
