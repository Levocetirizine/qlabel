#include "labelmodel.h"

int LabelModel::pageCount() const {
  return pages.count();
}

int LabelModel::rowCountInPage(int page) const {
  return pages[page]->entries.count();
}

QString LabelModel::getText(int page, int row) const {
  return pages[page]->entries[row]->text;
}


bool LabelModel::setText(int page, int row, QString text) {
  pages[page]->entries[row]->text = text;
  return true;
}
