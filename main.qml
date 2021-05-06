import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.3
import Qt.labs.settings 1.1

import QLabel.ConfigParser 0.1
import QLabel.LabelModel 0.1

import 'menu'
import 'dialogs'
import 'common'
import 'imagezone'
import 'tablezone'
import 'editzone'

ApplicationWindow {
  id: root

  width: 1024
  height: 768
  visible: false
  title: qsTr('qLabel alpha 0.1')

  /* global states */
  property int tag: 0
  property int mode: Enum.Label
  property string work_dir: ''
  property string work_name: ''
  property bool model_loaded: false

  /* setting_loaded = 1, yaml_loaded = 1 */
  property int cfg_load_flag: 0 // TODO: is this MT safe ?
  property bool initialised: false

  /* invisible children */
  LabelModel { id: mainmodel }
  AutoSaver { id: autosaver }
  QuickMenu { id: quickmenu }
  IndexSelectorDialog { id: isdialog }
  PuncCheckDialog { id: pcdialog }
  SearchDialog { id: searchdialog }
  OpenProjectDialog { id: openProject }
  SaveProjectAsDialog { id: saveProject }
  AddImageDialog { id: addImage }
  ModifyTagDialog { id: modifytagdialog }

  /* shared info dialog box */
  InfoDialog { id: infodialog }

  /* persistent settings */
  Settings {
    id: settings

    property alias width: root.width
    property alias height: root.height
    property bool maximized: false

    Component.onCompleted: {
      root.cfg_load_flag ++
      root.init()
    }
  }

  /* toml read-only configs */
  ConfigParser {
    id: config

    Component.onCompleted: {
      root.cfg_load_flag ++
      root.init()
    }
  }

  /* timer for auto-save */
  Timer {
    id: root_timer
    interval: 60 * 1000
    repeat: true
    onTriggered: autosaver.savebak()
  }

  /* visible children */

  header: Column {
    width: parent.width
    LabelToolBar {
      id: toolbar
      width:parent.width
    }
  }

  SplitView {
    id: context

    property double imagezoneWidth: 0.4

    orientation: Qt.Horizontal
    anchors.fill: parent

    ImageZone {
      id: imagezone
      SplitView.minimumWidth: context.width * 0.2
      SplitView.maximumWidth: context.width * 0.8
      SplitView.preferredWidth: context.width * context.imagezoneWidth

      onWidthChanged: {
        context.imagezoneWidth = width / context.width
      }
    }

    SplitView {
      id: context_right

      property double tablezoneHeight: 0.6

      orientation: Qt.Vertical

      TableZone {
        SplitView.minimumHeight: parent.height * 0.2
        SplitView.maximumHeight: parent.height * 0.8
        SplitView.preferredHeight: context_right.height * context_right.tablezoneHeight

        onHeightChanged: {
          context_right.tablezoneHeight = height / context.height
        }
      }

      EditZone {
        id: editzone
        SplitView.fillHeight: true
      }
    }
  }

  function init() {
    if (root.cfg_load_flag == 2) {
      /* both config load complete */
      if (settings.maximized) {
        root.visibility = 4
      }

      root.visible = true
      root.initialised = true
      root_timer.start()
    }
  }

  function close_project() {
    mainmodel.clearData()
    root.model_loaded = false
    root.work_dir = ''
    root.work_name = ''
  }

  onClosing: {
    /* 4 represents maximized in enum QWindow::Visibility */
    if (root.visibility == 4) {
      settings.maximized = true
    } else {
      settings.maximized = false
    }
  }
}
