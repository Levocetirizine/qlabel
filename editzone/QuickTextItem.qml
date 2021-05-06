import QtQuick 2.15
import QtQuick.Controls 2.15

ToolButton {
  property int index: 0
  property string text_p: 'nil'

  text: (index + 1) + '.  ' + text_p
  height: quicktext_menubar.height
  flat: true
  onClicked : {
    editbox.insert(editbox.cursorPosition, text_p)
  }

}
