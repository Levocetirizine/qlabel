#ifndef PAGE_H
#define PAGE_H

#include "translation.hpp"

#include <QList>
#include <QString>

class Page {
  /*
   * @page: contains list of translations
   * @name: page name (image name)
   */
public:
  QList<Translation*> entries;
  QString name;

  Page(QString name = ""): name(name) { }

  ~Page() {
    qDeleteAll(entries);
  }



};

#endif // PAGE_H
