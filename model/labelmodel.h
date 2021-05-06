#ifndef LABELMODEL_H
#define LABELMODEL_H

#include <QAbstractTableModel>
#include <QFileInfo>

#include "translation.hpp"
#include "page.hpp"

class LabelModel : public QAbstractTableModel
{
  Q_OBJECT

public:
  explicit LabelModel(QObject *parent = nullptr);
  ~LabelModel();

  // Header:
  QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;

//  bool setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role = Qt::EditRole) override;

  // Basic functionality:
  int rowCount(const QModelIndex &parent = QModelIndex()) const override;
  int columnCount(const QModelIndex &parent = QModelIndex()) const override;

  QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

  // Editable:
  bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

  bool moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild) override;


  Qt::ItemFlags flags(const QModelIndex& index) const override;

  QHash<int, QByteArray> roleNames() const override;

  /* Custom data */
  enum RoleNames {
    SelectRole = Qt::UserRole,
    LabelRole = Qt::UserRole + 1
  };

  enum ColumnNames {
    Index = 0,
    Text = 1,
    Type = 2
  };

  /* focusRow defines which translation line is active now,
   * this prop is read-only. Active line can be changed by doSelect functions.
   */
  Q_PROPERTY(int focusRow READ focusRow NOTIFY focusRowChanged)
  Q_PROPERTY(int currentPage READ currentPage WRITE setCurrentPage NOTIFY currentPageChanged)
  Q_PROPERTY(QStringList pageNamesList READ pageNamesList NOTIFY pageNamesListChanged)
  int focusRow () const;
  int currentPage () const;
  void setCurrentPage (int page);
  QStringList pageNamesList() const;

  /* a lot of model APIs */

  // by comparing btw. old & new serialized model, inefficient
  Q_INVOKABLE bool modelChanged();

  Q_INVOKABLE bool openUrl(QVariant name);
  Q_INVOKABLE bool saveUrl(QVariant name);
  Q_INVOKABLE bool autoSave(QVariant url, QVariant name);
  QString serializeModel();
  Q_INVOKABLE void clearData();

  Q_INVOKABLE QVariant getTags();
  Q_INVOKABLE bool setTags(QStringList taglist);

  Q_INVOKABLE int insertPage(QVariant name);
  Q_INVOKABLE void delectCurrentPage();
  Q_INVOKABLE void gotoPage(int index);
  Q_INVOKABLE void refreshPage();
  Q_INVOKABLE QVariant getPageName(int page);

  Q_INVOKABLE void doSelect(int row);
  Q_INVOKABLE void doCtrlSelect(int row);
  Q_INVOKABLE void doShiftSelect(int row);
  Q_INVOKABLE bool doAppendRow(double x, double y, int type);
  Q_INVOKABLE bool doRemoveSelectedRows();
  Q_INVOKABLE bool changeSelectedRowsTagTo(int tag);
  Q_INVOKABLE bool moveFocusRowTo(int target);

  Q_INVOKABLE QVariant getTextAt(int row) const;
  Q_INVOKABLE bool setTextAt(int row, QVariant text);

  Q_INVOKABLE QVariant getLabelPosition(int row, QVariant name) const;
  Q_INVOKABLE bool setLabelPosition(int row, double x, double y);

  /* Methods with direct data access, no error check, will not emit signal */

  Q_INVOKABLE int pageCount() const;
  Q_INVOKABLE int rowCountInPage(int page) const;
  Q_INVOKABLE QString getText(int page, int row) const;
  Q_INVOKABLE bool setText(int page, int row, QString text);

signals:
  void focusRowChanged(int);
  void currentPageChanged(int);
  void tagsChanged();
  void pageNamesListChanged();

private:
  QList<Page*> pages;
  QStringList tags;
  QString comment;

  /* no boundary check will be done in private method */

  void resetModel_nosignal();

  void createPage(int index, QVariant name);
  bool isValidPage(int page);

  void selectRow(int row);
  void unSelectRow(int row);
  bool isSelectedRow(int row) const;
  bool isValidRow(int row) const;
  bool removeRow(int row);
  QList<Translation*>& entries () const;

  QHash<int, QByteArray> customRoleNames;

  /* private field for q_property, DO NOT CALL DIRECTLY ! */
  int _focusRow = -1;
  int _currentPage = -1;
  void setFocusRow(int focusRow); // FIXME: use setfocusrow in property
  QString cached_serialized_model = "";
};

#endif // LABELMODEL_H
