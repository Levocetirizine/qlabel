#include "labelmodel.h"

#include <QUrl>

extern "C" {
  #include "strnatcmp.h"
}

LabelModel::LabelModel(QObject *parent)
  : QAbstractTableModel(parent)
{
  qDebug("model created");

  /* Roles
   * Displayrole: used in table view
   * EditRole: used in editor
   * SelectRole: used in table view to indicate if item selected
   * LabelRole: used in navigator to show label position
   *
   */
  customRoleNames[Qt::DisplayRole] = "display";
  customRoleNames[Qt::EditRole] = "edit";
  customRoleNames[SelectRole] = "select";
  customRoleNames[LabelRole] = "label";

  tags = QStringList();

}

LabelModel::~LabelModel() {
  qDeleteAll(pages);
  pages.clear();
  tags.clear();
  qDebug("model destroyed");
}



QVariant LabelModel::headerData(int section, Qt::Orientation orientation, int role) const
{
  if (role != Qt::DisplayRole) {
    qDebug("only support display role now");
    return QVariant();
  }

  if (orientation == Qt::Horizontal) {
    return "Row " + QString(section+1);
  }

  if (orientation == Qt::Vertical) {
    switch (section) {
      case 0:
        return "Index";
        break;
      case 1:
        return "Text";
        break;
      case 2:
        return "Type";
        break;
      default:
        qWarning("Column index is not valid !");
      return QVariant();
    }
  }

  return QVariant();
}

int LabelModel::rowCount(const QModelIndex &parent) const
{
  Q_UNUSED(parent);
  if (pages.isEmpty()) {
    return 0;
  } else {
    return entries().count();
  }
}

int LabelModel::columnCount(const QModelIndex &parent) const
{
  Q_UNUSED(parent);
  if (pages.isEmpty()) {
    return 0;
  } else {
    return Translation::COL_NUM;
  }
}

QVariant LabelModel::data(const QModelIndex &index, int role) const
{
  if (pages.isEmpty() || !index.isValid()) {
    return QVariant();
  }

  int row = index.row();
  int col = index.column();

  if (!isValidRow(row)) {
    qWarning("row index is not valid");
    return QVariant();
  }

  auto entry = entries().at(row);

  switch (role) {

    case Qt::DisplayRole:
    case Qt::EditRole:
      switch (col) {
        case Index:
          return row;
          break;
        case Text:
          return entry->text;
          break;
        case Type:
          return entry->type;
          break;
        default:
          qWarning("column index is not valid");
          return QVariant();
      }
      break;
    case SelectRole:
      return isSelectedRow(row);
      break;
    case LabelRole:
      qDebug("in");
      switch (col) {
        case 0:
          return entry->x;
          break;
        case 1:
          return entry->y;
          break;
        default:
          qWarning("column label index is not valid");
          return QVariant();
      }
      break;
    default:
      qWarning("Unsupported role");
      return QVariant();
  }


}

bool LabelModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
  int row = index.row();
  int col = index.column();

  if (!pages.isEmpty() && isValidRow(row)) {

    auto entry = entries().at(row);
    auto roleSet = QVector<int>(Qt::DisplayRole);

    switch (role) {
      case Qt::EditRole:
        switch (col) {
          case Text:
            entry->setText(value.toString());
            emit dataChanged(index, index, roleSet);
            return true;
            break;
          case Type:
            entry->type = value.toInt();
            emit dataChanged(index, index, roleSet);
            return true;
            break;
          default:
            qWarning("column index is not valid");
            return false;
        }
      break;
      default:
        qWarning("Unsupported role");
        return false;
    }

  } else {
    return false;
  }
}

bool LabelModel::moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild)
{

  if (count != 1) {
    qWarning("Do not support multi move");
    return false;
  }

  // notice the difference between QModel.MoveRows() and QList.move()
  if (sourceRow < destinationChild) {
    beginMoveRows(sourceParent, sourceRow, sourceRow, destinationParent, destinationChild + 1);
  } else {
    beginMoveRows(sourceParent, sourceRow, sourceRow, destinationParent, destinationChild);
  }

  entries().move(sourceRow, destinationChild);

  qDebug("done");

  endMoveRows();

  return true;

}

int LabelModel::focusRow() const
{
  return _focusRow;
}

int LabelModel::currentPage() const
{
  return _currentPage;
}

QStringList LabelModel::pageNamesList() const
{
  QStringList out;
  Page *page;
  foreach (page, pages) {
    out.append(page->name);
  }
  return out;
}

bool LabelModel::modelChanged()
{
  QString current = serializeModel();

//  qDebug("--OLD--\n %s", qUtf8Printable(cached_serialized_model));
//  qDebug("--NEW--\n %s", qUtf8Printable(current));

  if (cached_serialized_model == current) {
    return false;
  }
  return true;
}

void LabelModel::setCurrentPage(int page)
{
  beginResetModel();
  _currentPage = page;
  endResetModel();
  emit currentPageChanged(page);
  if (!entries().isEmpty()) {
    doSelect(0);
  } else {
    setFocusRow(-1);
  }
}

/* invokable methods */

void LabelModel::clearData()
{
  beginResetModel();
  resetModel_nosignal();
  endResetModel();
  emit focusRowChanged(focusRow());
  emit currentPageChanged(currentPage());
  emit tagsChanged();
  emit pageNamesListChanged();
}

QVariant LabelModel::getTags()
{
  return tags;
}

bool LabelModel::setTags(QStringList taglist)
{
  if (taglist.count() == 0) {
    return false;
  } else {
    tags = taglist;
    emit tagsChanged();
    return true;
  }
}

int LabelModel::insertPage(QVariant name)
{
  /* find the index to insert */
  int lo = 0;
  int hi = pages.count() - 1;
  while (lo <= hi) {
    int index = (lo + hi) / 2;
    int comp = strnatcmp(qUtf8Printable(name.toString()), qUtf8Printable(pages.at(index)->name));

    if (comp < 0) {
      hi = index - 1;
    } else if (comp > 0) {
      lo = index + 1;
    } else {
      qDebug("Ignore existed page");
      return -1;
    }
  }

  /* insert at lo index */
  pages.insert(lo, new Page(name.toString()));

  /* page name changed, emit signal */
  emit pageNamesListChanged();

  return lo;
}

void LabelModel::delectCurrentPage()
{
  if (pages.count() <= 1) {
    qWarning("Should be at least 2 pages");
    return;
  }

  /* remove current page */
  pages.removeAt(currentPage());

  /* page name changed, emit signal */
  emit pageNamesListChanged();

  /* select new currentpage */
  if(currentPage() >= pages.count()) {
    setCurrentPage(pages.count() - 1);
  } else {
    refreshPage();
  }
  return;
}

void LabelModel::createPage(int index, QVariant name)
{
  pages.insert(index, new Page(name.toString()));
  emit pageNamesListChanged();
  if (pages.count() == 1) {
    setCurrentPage(0);
  }
}

void LabelModel::gotoPage(int index)
{
  if (isValidPage(index)) {
    setCurrentPage(index);
  }
}

void LabelModel::refreshPage()
{
  setCurrentPage(_currentPage);
}

QVariant LabelModel::getPageName(int page)
{
  if (isValidPage(page)) {
    return pages.at(page)->name;
  } else {
    return QVariant();
  }
}

void LabelModel::doSelect(int row)
{
  if (!pages.isEmpty() && isValidRow(row)) {
    for (int index = 0; index < entries().count(); index++) {
      if (index == row) {
        selectRow(index);
      } else {
        unSelectRow(index);
      }
    }
    setFocusRow(row);
  }
}

void LabelModel::doCtrlSelect(int row)
{
  if (!pages.isEmpty() && isValidRow(row)) {
    if (isSelectedRow(row)) {
      unSelectRow(row);
    } else {
      selectRow(row);
    }
    setFocusRow(row);
  }
}

void LabelModel::doShiftSelect(int row)
{
  if (!pages.isEmpty() && isValidRow(row)) {
    int focus = focusRow();
    int min = row < focus ? row : focus;
    int max = row > focus ? row : focus;

    for (int index = 0; index < entries().count(); index++) {
      if (index < min || index > max) {
        unSelectRow(index);
      } else {
        selectRow(index);
      }
    }
    setFocusRow(row);
  }
}

bool LabelModel::doAppendRow(double x, double y, int type)
{
  if (pages.isEmpty()) return false;
  int newIndex = entries().count();
  beginInsertRows(QModelIndex(), newIndex, newIndex);
  Translation* newEntry = new Translation(x, y, type);
  entries().append(newEntry);
  endInsertRows();
  doSelect(newIndex);
  return true;
}

bool LabelModel::doRemoveSelectedRows()
{
  if (pages.isEmpty()) return false;
  int i = 0;
  int lastRemove = 0;
  while (i < entries().count()) {
    Translation* entry = entries().at(i);
    if (entry->selected) {
      removeRow(i);
      lastRemove = i;
    } else {
      i++;
    }
  }
  if (!entries().isEmpty()) {
    doSelect(lastRemove);
  } else {
    setFocusRow(-1);
  }
  return true;
}

bool LabelModel::changeSelectedRowsTagTo(int tag)
{
  if (pages.isEmpty()) return false;
  for (int i = 0; i < entries().count(); i++) {
    Translation* entry = entries().at(i);
    if (entry->selected) {
      entry->type = tag;
      QModelIndex tl = index(i, 2);
      QModelIndex br = index(i, 2);
      emit dataChanged(tl, br);
    }
  }


  return true;
}

bool LabelModel::moveFocusRowTo(int target)
{
  if (pages.isEmpty()) return false;
  if (target > entries().count()) return false;
  if (focusRow() == target) return true;

  moveRows(QModelIndex(), focusRow(), 1, QModelIndex(), target);
  setFocusRow(target);

  return true;
}

QVariant LabelModel::getTextAt(int row) const
{
  if (pages.isEmpty()) return "";
  QModelIndex i = index(row, Text);
  return data(i, Qt::EditRole);
}

bool LabelModel::setTextAt(int row, QVariant text)
{
  if (pages.isEmpty()) return false;
  QModelIndex i = index(row, Text);
  return setData(i, text);
}

QVariant LabelModel::getLabelPosition(int row, QVariant name) const
{
  if (!isValidRow(row)) {
    qWarning("illegal row index");
    return QVariant();
  }

  if (name == "x") {
    return entries().at(row)->x;
  } else if (name == "y") {
    return entries().at(row)->y;
  } else {
    qWarning("illegal getlabelposition name");
    return QVariant();
  }

}

bool LabelModel::setLabelPosition(int row, double x, double y)
{
  if (!isValidRow(row)) {
    qWarning("illegal row index");
    return false;
  }

  entries().at(row)->x = x;
  entries().at(row)->y = y;
  return true;
}

void LabelModel::resetModel_nosignal()
{
  qDeleteAll(pages);
  pages.clear();
  tags.clear();
  comment = "";
  _focusRow = -1;
  _currentPage = -1;
}

/* private methods, no boundary check will be done in private method */

bool LabelModel::isValidPage(int page)
{
  return (page >= 0 && page < pages.count());
}

void LabelModel::selectRow(int row)
{
  Translation* target = entries().at(row);
  if (! target->selected) {
    target->selected = true;
    QModelIndex tl = index(row, 0);
    QModelIndex br = index(row, Translation::COL_NUM - 1);
    emit dataChanged(tl, br);
  }
}

void LabelModel::unSelectRow(int row)
{
  Translation* target = entries().at(row);
  if (target->selected) {
    target->selected = false;
    QModelIndex tl = index(row, 0);
    QModelIndex br = index(row, Translation::COL_NUM - 1);
    emit dataChanged(tl, br);
  }
}

bool LabelModel::isSelectedRow(int row) const
{
  return entries().at(row)->selected;
}

bool LabelModel::isValidRow(int row) const
{
  return (row >= 0 && row < entries().count());
}

bool LabelModel::removeRow(int row)
{
  beginRemoveRows(QModelIndex(), row, row);
  delete entries().at(row);
  entries().removeAt(row);
  endRemoveRows();
  return true;
}

QList<Translation *>& LabelModel::entries() const
{
  return pages.at(currentPage())->entries;
}

void LabelModel::setFocusRow(int focusRow)
{
  _focusRow = focusRow;
  emit focusRowChanged(_focusRow);
}

Qt::ItemFlags LabelModel::flags(const QModelIndex &index) const
{
  Q_UNUSED(index)
  return Qt::ItemIsSelectable;
}

QHash<int, QByteArray> LabelModel::roleNames() const
{
  return customRoleNames;
}
