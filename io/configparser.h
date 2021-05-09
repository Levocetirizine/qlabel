#ifndef CONFIGPARSER_H
#define CONFIGPARSER_H

#include <QObject>
#include <QVariant>
#include <QList>
#include <QString>
#include <QChar>
#include <QTextCodec>

#include <toml.hpp>

class ConfigParser : public QObject
{
  Q_OBJECT
public:
  explicit ConfigParser(QObject *parent = nullptr);

  Q_PROPERTY(QStringList defaultTag READ defaultTag NOTIFY defaultTagChanged)
  Q_PROPERTY(QList<QString> palette READ palette NOTIFY paletteChanged)
  Q_PROPERTY(QList<QString> quickText READ quickText NOTIFY quickTextChanged)
  Q_PROPERTY(QList<QVariant> puncCheck READ puncCheck)

  QStringList defaultTag() const;
  QList<QString> palette() const;
  QList<QString> quickText() const;
  QList<QVariant> puncCheck() const;

signals:
  void defaultTagChanged(QStringList);
  void paletteChanged(QList<QString>);
  void quickTextChanged(QList<QString>);

private:
  void parseConfig(QString path);
  void parseDisplay(toml::value node);
  void parseModel(toml::value node);
  void parseView(toml::value node);
  void parseEdit(toml::value node);

  /* display */
  // nothing here now

  /* model */
  QStringList _defaultTag =
    {tr("inbox"), tr("outbox"), tr("other")};

  /* view */
  QList<QString> _palette =
    {"#b91d47","#2b5797","#1e7145","#603cba","#e3a21a","#00aba9","#1d1d1d"};

  /* edit */
  QList<QString> _quickText =
    {u8"❤", u8"♡",u8"♪",u8"——",u8"……"};

  /**
   * punc check format:
   * [
   *   {
   *     name = "ruleset1"
   *     rules = [
   *       {from = ["from_str1", "from_str2", ...], to = "to_str"},
   *       ...
   *     ]
   *   },
   *   ...
   * ]
   *
   */
  QList<QVariant> _puncCheck = {};

};

#endif // CONFIGPARSER_H
