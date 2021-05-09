#ifndef TRANSLATION_H
#define TRANSLATION_H

#include <QtGlobal>
#include <QString>


class Translation {
  /*
   * @COL_NUM: columnCount, {index, text, type}
   * @x: label position in picture (0.0 ~ 1.0)
   * @y: label position in picture (0.0 ~ 1.0)
   * @text: translation data
   * @type: type of label.
   *
   */
public:
  static const quint32 COL_NUM = 3;
  double x;
  double y;
  QString text;
  quint32 type;
  bool selected;

  Translation(double x = 0.0, double y = 0.0, quint32 type = 0):
    x(x), y(y), type(type){
    text = "";
    selected = false;
  }


  ~Translation() {}

  void setText(const QString newtext) {
    text = newtext;
  }

};

#endif // TRANSLATION_H
