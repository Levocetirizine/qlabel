import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

RoundButton {
  flat: true

  property string imgsrc: ''

  contentItem: Image {
    id: img
    source: imgsrc
    sourceSize.width: toolbar.height * 0.5
    sourceSize.height: toolbar.height * 0.5

  }

  ColorOverlay {
    anchors.fill: img
    source: img
    color: "#333333"
    antialiasing: true
  }
}
