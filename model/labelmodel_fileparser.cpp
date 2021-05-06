#include "labelmodel.h"

#include <QDir>
#include <QDateTime>
#include <QFile>
#include <QTextStream>
#include <QUrl>
#include <QRegularExpression>

#include <QTextCodec>

#include <memory>
#include <algorithm>

#define MAX_PARSE_LINE_SIZE 8192
#define MAX_TAG_COUNT 32
#define MAX_BAK_NUM 120

bool isAutoSaveFileName(QString name);
bool trimFileListTo(QFileInfoList list, int size);
static bool isInit(QString &str);
static bool isTagToggler(QString &str);
static bool isNewRowIndicator(QString &str, double &x, double &y, int &tagindex);
static bool isNewPageIndicator(QString &str, QString &pagename);
static void tryToRemoveTrailingReturn(QString &str, int num);

#define QSTRING_APPEND_LINE(str, expr) str.append(expr).append('\n')
#define QSTRING_APPEND_EMPTY_LINE(str) str.append('\n')

enum LPParserState {
  s_nil,
  s_init, // read (%d,%d) to switch to init state
  s_tag, // expect to parse a tag description
  s_comment, // expect to parse comment line
  s_page, // expect to parse a row description
  s_row, // expext to parse a new translation line (or new row / new page)
};

bool LabelModel::openUrl(QVariant name)
{

  beginResetModel();

  resetModel_nosignal();

  QString path = QUrl(name.toString()).toLocalFile();
  QFileInfo fi(path);

  QFile file(path);
  if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
    qDebug("file format incorrect"); // TODO: test this
    endResetModel();
    emit tagsChanged();
    return false;
  }

  /* used for parsing methods */
  QTextStream in(&file);
  LPParserState state = s_nil;
  QString pagename = "";
  double x = 0.0;
  double y = 0.0;
  int tagindex = 0;
  int currentPage = 0;
  Translation* currentEntry = NULL;

  cached_serialized_model = ""; // reset cached model to ""

  while (!in.atEnd()) {
    QString line = in.readLine(MAX_PARSE_LINE_SIZE);
    switch (state) {
      case s_nil:
        if (isInit(line)) {
          state = s_init;
        } else {
          goto error;
        }
        break;
      case s_init:
        if (isTagToggler(line)) {
          state = s_tag;
        } else {
          goto error;
        }
        break;
      case s_tag:
        if (isTagToggler(line)) {
          if (tags.count() == 0) {
            qWarning("not available tag found");
            goto error;
          }
          state = s_comment;
        } else {
          tags.append(line);
          if (tags.count() > MAX_TAG_COUNT) {
            qWarning("too many tags");
            goto error;
          }
        }
        break;
      case s_comment:
        if (isNewPageIndicator(line, pagename)) {
          currentPage = pages.count();
          createPage(pages.count(), pagename);
          state = s_page;
        } else {
          comment.append(line);
        }
        break;
      case s_page:
        if (isNewPageIndicator(line, pagename)) {
          currentPage = pages.count();
          createPage(pages.count(), pagename);
        } else if (isNewRowIndicator(line, x, y, tagindex)) {
          currentEntry = new Translation(x, y, tagindex);
          pages.at(currentPage)->entries.append(currentEntry);
          state = s_row;
        } else {
        }
        break;
      case s_row:
        if (isNewPageIndicator(line, pagename)) {
          tryToRemoveTrailingReturn(currentEntry->text, 2);
          currentPage = pages.count();
          createPage(pages.count(), pagename);
          state = s_page;
        } else if (isNewRowIndicator(line, x, y, tagindex)) {
          tryToRemoveTrailingReturn(currentEntry->text, 1);
          currentEntry = new Translation(x, y, tagindex);
          pages.at(currentPage)->entries.append(currentEntry);
        } else {
          if (currentEntry->text != "") {
            currentEntry->text.append("\n");
          }
          currentEntry->text.append(line);
        }
        break;
    }
  }

  cached_serialized_model = serializeModel();

  endResetModel();
  emit tagsChanged();
  setCurrentPage(0);
  file.close();
  return true;

  error: // TODO: test this
  resetModel_nosignal();
  endResetModel();
  emit tagsChanged();
  file.close();
  return false;

}

bool LabelModel::saveUrl(QVariant name)
{
  QString path = QUrl(name.toString()).toLocalFile();
  cached_serialized_model = serializeModel();

  QFile file(path);
  if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
    qWarning("can not create file for saving");
    return false;
  }

  QTextStream out(&file);
//  out.setCodec("UTF-8");
  out.setCodec("UTF-16LE");
  out.setGenerateByteOrderMark(true);

  out << cached_serialized_model;

  file.close();
  return true;
}

bool LabelModel::autoSave(QVariant url, QVariant name) {

  // sanity check
  QString path = QUrl(url.toString()).toLocalFile();
  QDir dir(path);
  if (!dir.exists()) {
    qWarning("Current directory %s not available", qUtf8Printable(path));
    return false;
  }

  // prepare bak dir
  QString bakdir_path = dir.filePath("bak");
  QDir bakdir(bakdir_path);
  if (!bakdir.exists()) {
    qInfo("Make bak directory");
    bakdir.mkpath(".");
  }

  QFileInfo bakdir_info(bakdir_path);
  if (!bakdir_info.isReadable() || !bakdir_info.isWritable()) {
    qWarning("Directory permission not correct");
    return false;
  }

  // get all existed baks
  QFileInfoList bakinfo_list;
  foreach (QFileInfo info, bakdir.entryInfoList()) {
    if (info.isFile()) {
      if (isAutoSaveFileName(info.fileName())) {
        bakinfo_list.append(info);
      }
    }
  }

  // remove old bakinfo
  if (bakinfo_list.count() > MAX_BAK_NUM) {
    if (!trimFileListTo(bakinfo_list, MAX_BAK_NUM)) {
      qWarning("Unable to delete deprecated bak files");
      return false;
    }
  }

  // save new bakfile
  QString data = serializeModel();
  QString savepath = bakdir.filePath(name.toString());
  QFile savefile(savepath);
  if (!savefile.open(QIODevice::WriteOnly | QIODevice::Text)) {
    qWarning("can not create file for saving");
    return false;
  }

  QTextStream out(&savefile);
  out.setCodec("UTF-16LE");
  out.setGenerateByteOrderMark(true);
  out << data;
  savefile.close();
  return true;
}

bool isAutoSaveFileName(QString name) {

  QRegularExpression re("^\\d{6}_\\d{6}_(?<name>.+)$");
  QRegularExpressionMatch match = re.match(name);
  if (match.hasMatch()) {
    return true;
  }
  return false;
}

/* remove deprecated bak files in list until defined size */
bool trimFileListTo(QFileInfoList list, int size) {

  // sort list acc. to last modify date
  std::sort(list.begin(), list.end(), [](QFileInfo a, QFileInfo b){
    return a.lastModified() < b.lastModified();
  });

  // trim sorted list
  for (int i = 0; i < list.count() - size; i++) {
    QFileInfo fi = list[i];
    QString fp = fi.filePath();
    QFile f(fp);
    bool ret = f.remove();
    if (ret) {
      qInfo("Delete %s", qUtf8Printable(fp));
    } else {
      qWarning("Unable to delete old bak file");
      return false;
    }
  }
  return true;
}

QString LabelModel::serializeModel() {
  QString out_str;
  QSTRING_APPEND_LINE(out_str, "1,0");
  QSTRING_APPEND_LINE(out_str, '-');
  foreach(QString tag, tags) {
    QSTRING_APPEND_LINE(out_str, tag);
  }
  QSTRING_APPEND_LINE(out_str, '-');
  QSTRING_APPEND_LINE(out_str, "Created by qlabel 0.1");
  QSTRING_APPEND_EMPTY_LINE(out_str);
  QSTRING_APPEND_EMPTY_LINE(out_str);

  for (int page = 0; page < pageCount(); page++) {
    QSTRING_APPEND_LINE(out_str, ">>>>>>>>[" + pages.at(page)->name + "]<<<<<<<<");
    for (int row = 0; row < rowCountInPage(page); row++) {
      Translation* tr = pages[page]->entries[row];
      QSTRING_APPEND_LINE(out_str,
                          QString::asprintf("----------------[%d]----------------[%.3f,%.3f,%u]",
                          row+1, tr->x, tr->y, tr->type + 1));
      QSTRING_APPEND_LINE(out_str, getText(page, row));
      QSTRING_APPEND_EMPTY_LINE(out_str);
    }
    QSTRING_APPEND_EMPTY_LINE(out_str);
  }
  tryToRemoveTrailingReturn(out_str, 2);
  return out_str;
}

/* private methods for parser */
static bool isInit(QString &str)
{
  QRegularExpression re("^\\d+,\\d+$");
  QRegularExpressionMatch match = re.match(str);
  return match.hasMatch();
}

static bool isTagToggler(QString &str)
{
  QRegularExpression re("^-$");
  QRegularExpressionMatch match = re.match(str);
  return match.hasMatch();
}

static bool isNewPageIndicator(QString &str, QString &pagename)
{
  QRegularExpression re("^>{8}\\[(?<name>.+)]<{8}$");
  QRegularExpressionMatch match = re.match(str);
  if (match.hasMatch()) {
    pagename = match.captured("name");
    return true;
  }
  return false;
}

static bool isNewRowIndicator(QString &str, double &x, double &y, int &tagindex)
{
  QRegularExpression re("^-{16}\\[(?<index>\\d+)]-{16}\\[(?<x>\\d+.\\d+),(?<y>\\d+.\\d+),(?<type>\\d+)]$");
  QRegularExpressionMatch match = re.match(str);
  if (match.hasMatch()) {
    x = match.captured("x").toDouble();
    y = match.captured("y").toDouble();
    tagindex = match.captured("type").toInt() - 1;
    return true;
  }
  return false;
}

static void tryToRemoveTrailingReturn(QString &str, int num) {
  for (int i = 0; i < num; i++) {
    if (str.endsWith('\n')) {
      str.truncate(str.count() - 1);
    } else break;
  }
}
