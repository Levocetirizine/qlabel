import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import '../common'
import '../dialogs'

ToolBar {
  id: toolbar_root

  NewProjectDialog { id: newproject }
  SaveBeforeOpenDialog { id: savebefore }
  DelectPageDialog { id: deletedialog }
  SettingsDialog { id: settingsdialog }

  Flow {
    anchors.fill: parent

    Row {
      id: toolbar_basic

      ToolButton {
        id: op_new
        text: qsTr('new')
        icon.source: '../svg/file.svg'
        ToolTip.text: 'Ctrl+N'
        ToolTip.visible: hovered
        onClicked: {
          if (root.model_loaded && mainmodel.modelChanged()) {
            newproject.open()
          } else {
            root.close_project()
            addImage.open()
          }
        }

        Shortcut {
          sequence: StandardKey.New
          onActivated: op_new.clicked()
        }
      }

      ToolButton {
        id: op_open
        text: qsTr('Open')
        icon.source: '../svg/folder.svg'
        ToolTip.text: 'Ctrl+O'
        ToolTip.visible: hovered
        onClicked: {
          if (root.model_loaded && mainmodel.modelChanged()) {
            savebefore.open()
          } else {
            openProject.open()
          }
        }

        Shortcut {
          sequence: StandardKey.Open
          onActivated: op_open.clicked()
        }
      }

      ToolButton {
        id: op_save
        text: qsTr('Save')
        icon.source: '../svg/save.svg'
        ToolTip.text: 'Ctrl+S'
        ToolTip.visible: hovered
        onClicked: {
          if (root.model_loaded) {
            if (root.work_name) {
              mainmodel.saveUrl(root.work_dir + '/' + root.work_name)
            } else {
              saveProject.folder = root.work_dir
              saveProject.open()
            }
          } else {
            console.log('save: model not loaded')
          }
        }

        Shortcut {
          sequence: StandardKey.Save
          onActivated: op_save.clicked()
        }
      }

      ToolButton {
        id: op_saveas
        text: qsTr('Save as')
        icon.source: '../svg/download.svg'
        ToolTip.text: 'Ctrl+Shift+S'
        ToolTip.visible: hovered
        onClicked: {
          if (root.model_loaded) {
            if (root.work_dir !== '') {
              saveProject.folder = root.work_dir
            }
            saveProject.open()
          } else {
            console.log('save as: model not loaded')
          }
        }

        Shortcut {
          sequence: 'Ctrl+Shift+S'
          onActivated: op_saveas.clicked()
        }
      }


      ToolSeparator {}
    }

    Row {
      id: toolbar_pagectl

      ToolButton {
        text: qsTr('add page')
        icon.source: '../svg/add.svg'
        onClicked: {
          if (root.model_loaded) {
            addImage.open()
          }
        }
      }

      ToolButton {
        text: qsTr('delete page')
        icon.source: '../svg/remove.svg'
        onClicked: {
          if (root.model_loaded) {
            deletedialog.open()
          }
        }
      }

      ToolSeparator {}
    }

    Row {
      id: toolbar_mode

      ToolButton {
        text: qsTr('label mode')
        icon.source: '../svg/origin.svg'
        autoExclusive: true
        checkable: true
        checked: root.mode === Enum.Label
        onClicked: root.mode = Enum.Label
      }

      ToolButton {
        text: qsTr('view mode')
        icon.source: '../svg/cursor.svg'
        autoExclusive: true
        checkable: true
        checked: root.mode === Enum.View
        onClicked: root.mode = Enum.View
      }

      ToolSeparator { }
    }

    Row {
      id: toolbar_utils

      ToolButton {
        id: op_punc
        text: qsTr('punc check')
        icon.source: '../svg/left-quote.svg'
        ToolTip.text: 'Ctrl+P'
        ToolTip.visible: hovered
        onClicked: {
          if (mainmodel.currentPage !== -1) {
            pcdialog.open()
          }
        }

        Shortcut {
          sequence: 'Ctrl+P'
          onActivated: op_punc.clicked()
        }
      }

      ToolButton {
        id: op_find
        text: qsTr('find')
        icon.source: '../svg/search.svg'
        ToolTip.text: 'Ctrl+F'
        ToolTip.visible: hovered
        onClicked: {
          if (mainmodel.currentPage !== -1) {
            searchdialog.open()
          }
        }

        Shortcut {
          sequence: 'Ctrl+F'
          onActivated: op_find.clicked()
        }
      }

      ToolSeparator {
        id: utils_separator
        visible: false
      }
    }

    ToolButton {
      id: modify_tags
      display: AbstractButton.IconOnly
      icon.source: '../svg/new.svg'
      visible: false
      onClicked: {
        if (root.model_loaded) {
          modifytagdialog.open()
        }
      }
    }

    Row {
      id: toolbar_tags
      property bool inited: false
      
      Connections {
        target: mainmodel
        function onTagsChanged() {
          if (!toolbar_tags.inited) {
            let tagComponent = Qt.createComponent('TagButton.qml')
            for (let i = 0; i < 9; i++) {
              tagComponent.createObject(toolbar_tags, {index: i})
            }
            utils_separator.visible = true
            modify_tags.visible = true
            toolbar_tags.inited = true
          }

          let taglist = mainmodel.getTags()
          let j = 0
          for (j = 0; j < Math.min(taglist.length, 9); j++) {
            let button = toolbar_tags.children[j]
            button.text = taglist[j]
            button.visible = true
          }
          while (j < 9) {
            toolbar_tags.children[j].visible = false
            j++
          }
        }
      }
    }

    ToolSeparator {}
    ToolButton {
      text: qsTr('settings')
      icon.source: '../svg/settings.svg'
      onClicked: {
        settingsdialog.open()
//        trans.selectLanguage("zh_CN")
      }
    }

    ToolSeparator {}
    ToolButton {
      text: qsTr('info')
      icon.source: '../svg/help.svg'
      onClicked: {
        infodialog.text = qsTr('QLabel 0.1')
        infodialog.open()
      }
    }
  }
}
