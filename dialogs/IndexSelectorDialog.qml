import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
  id: root

  width: 360
  height: 240

  flags: Qt.Dialog

  // blocks other inputs belonging to root context (the application)
  modality: Qt.WindowModal

  title: qsTr('Select the index')

  property int limit: 0
  property int selected: spinbox.value

  Rectangle {
    id: bg
    anchors.fill: parent
    color: '#f7f7f7'
  }

  Item {
    id: body
    width: parent.width
    anchors.top: parent.top
    anchors.bottom: footer.top

    Column {

      anchors.centerIn: parent
      spacing: parent.height * 0.1

      Row {
        id: selector
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: parent.width * 0.1

        Text {
          anchors.verticalCenter: parent.verticalCenter
          text: qsTr('New Index: ')
        }

        SpinBox {
          id: spinbox
          anchors.verticalCenter: parent.verticalCenter

          editable: true
          from: 1
          to: root.limit
          value: root.selected
        }
      }


      ScrollView {
        height: (body.height - selector.height) * 0.8
        width: root.width * 0.9
        clip: true

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.width: 10

        Text {
          width: root.width * 0.9
          wrapMode: Text.WrapAnywhere
          text: mainmodel.getTextAt(spinbox.value - 1)
        }

      }

    }
  }


  Item {
    id:footer
    width: parent.width
    height: 80
    anchors.bottom: parent.bottom

    Row {
      anchors.right: parent.right
      anchors.rightMargin: parent.width * 0.05
      anchors.verticalCenter: parent.verticalCenter
      spacing: 20

      Button {
        text: qsTr("OK")


        onClicked: {
          let ret = mainmodel.moveFocusRowTo(spinbox.value - 1)
          console.log(ret)
          root.close()
        }
      }

      Button {
        text: qsTr("Cancel")
        onClicked: root.close()

        flat: true

      }

    }
  }

  function open() {
    root.show()
  }

}
