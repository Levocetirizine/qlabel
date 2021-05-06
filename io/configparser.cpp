#include <QDir>
#include <QFileInfo>
#include <QFile>

#include "configparser.h"

#include <iostream>

#define COMMA ,
#define SAFE_ASSIGN(var, expr_try)      \
        try {                           \
          var = (expr_try);             \
        } catch (std::exception &e) {   \
          qDebug("%s", e.what());       \
        }

#define SAFE_RUN(expr_try)              \
        try {                           \
          expr_try;                     \
        } catch (std::exception &e) {   \
          qDebug("%s", e.what());       \
        }

ConfigParser::ConfigParser(QObject *parent) : QObject(parent)
{

  QString dir = QDir::currentPath();
  QString path = QDir(dir).filePath("config.toml");

  SAFE_RUN(parseConfig(path))

}

void ConfigParser::parseConfig(QString path)
{

  const toml::value root = toml::parse(path.toStdString());

//  SAFE_RUN(parseDisplay(root))
  SAFE_RUN(parseModel(root))
  SAFE_RUN(parseView(root))
  SAFE_RUN(parseEdit(root))

}

void ConfigParser::parseDisplay(toml::value node)
{
  const auto &display = toml::find(node, "display");
  Q_UNUSED(display) // nothing now

//  SAFE_ASSIGN(_width, toml::find<int>(display, "width"))
//  SAFE_ASSIGN(_height, toml::find<int>(display, "height"))
//  SAFE_ASSIGN(_maximize, toml::find<bool>(display, "maximize"))

}

void ConfigParser::parseModel(toml::value node)
{
  const auto &model = toml::find(node, "model");

  SAFE_RUN(
    const auto parsedDefaultTag = toml::find<std::vector<std::string>>(model, "default_tag");
    _defaultTag.clear();
    for (size_t i = 0; i < parsedDefaultTag.size(); i++) {
      _defaultTag.append(QString::fromStdString(parsedDefaultTag[i]));
    }
  )

}

void ConfigParser::parseView(toml::value node)
{
  const auto &view = toml::find(node, "view");

  SAFE_RUN(
    const auto parsedPalette = toml::find<std::vector<std::string>>(view, "palette");
    _palette.clear();
    for (size_t i = 0; i < parsedPalette.size(); i++) {
      _palette.append(QString::fromStdString(parsedPalette[i]));
    }
  )
}

void ConfigParser::parseEdit(toml::value node)
{
  const auto &edit = toml::find(node, "edit");

  SAFE_RUN(
    const auto parsedQuickText = toml::find<std::vector<std::string>>(edit, "quick_text");
    _quickText.clear();
    for (size_t i = 0; i < parsedQuickText.size(); i++) {
      _quickText.append(QString::fromStdString(parsedQuickText[i]));
    }
  )


  SAFE_RUN(
    const auto parsedPuncCheck = toml::find<std::vector<toml::value>>(edit, "punc_checks");

    _puncCheck.clear();
    for (size_t i = 0; i < parsedPuncCheck.size(); i++) {
      SAFE_RUN(
        const auto desc = parsedPuncCheck[i];
        const auto name = toml::find<std::string>(desc, "name");
        const auto rules = toml::find<std::vector<toml::value>>(desc, "rules");

        QList<QVariant> q_rules;
        for (size_t j = 0; j < rules.size(); j++) {
          const auto rule = rules[j];
          const auto from = toml::find<std::vector<std::string>>(rule, "from");
          const auto to = toml::find<std::string>(rule, "to");

          QList<QVariant> q_from;
          for (size_t k = 0; k < from.size(); k++) {
            q_from.append(QString::fromStdString(from[k]));
          }
          QString q_to = QString::fromStdString(to);
          QMap<QString COMMA QVariant> q_rule;

          q_rule.insert("from", q_from);
          q_rule.insert("to", q_to);
          q_rules.append(q_rule);
        }

        QMap<QString COMMA QVariant> q_desc;
        q_desc.insert("name", QString::fromStdString(name));
        q_desc.insert("rules", q_rules);

        /* one rule's parse is successful ! */
        _puncCheck.append(q_desc);
      )
    }

    )
}

QStringList ConfigParser::defaultTag() const
{
  return _defaultTag;
}

QList<QString> ConfigParser::palette() const
{
  return _palette;
}

QList<QString> ConfigParser::quickText() const
{
  return _quickText;
}

QList<QVariant> ConfigParser::puncCheck() const
{
  return _puncCheck;
}
