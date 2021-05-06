#include "qlabeltranslator.h"

#include <QDir>
#include <QGuiApplication>

QLabelTranslator::QLabelTranslator(QQmlEngine *engine)
{
  _translator = new QTranslator(this);
  _engine = engine;
}

QLabelTranslator::~QLabelTranslator()
{
  delete(_translator);
}

void QLabelTranslator::selectLanguage(QString lang)
{
  QDir dir = QDir(qApp->applicationDirPath()).absolutePath();
  QString i18n = QString("%1/i18n").arg(dir.path());
  QString qm = QString("qlabel_%1").arg(lang);

  if (!_translator->load(qm, i18n)) {
    if (lang != "en") { // english is default language
      qWarning("lang %s not found in %s", qUtf8Printable(lang), qUtf8Printable(i18n));
    }
  }

  qApp->installTranslator(_translator);
  _engine->retranslate();

  emit languageChanged();

}
