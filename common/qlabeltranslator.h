#ifndef QLABELTRANSLATOR_H
#define QLABELTRANSLATOR_H

#include <QTranslator>
#include <QObject>
#include <QQmlEngine>

class QLabelTranslator : public QObject
{
  Q_OBJECT
public:
  QLabelTranslator(QQmlEngine *engine);
  ~QLabelTranslator();

  Q_INVOKABLE void selectLanguage(QString lang);

signals:
  void languageChanged();

private:
  QTranslator *_translator;
  QQmlEngine *_engine;
};

#endif // QLABELTRANSLATOR_H
