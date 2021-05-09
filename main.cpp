#include <QGuiApplication>

#include <QQmlApplicationEngine>
#include <QQmlFileSelector>
#include <QFileSelector>
#include <QFont>
#include <QtQml>

#include "io/configparser.h"
#include "model/labelmodel.h"
#include "common/qlabeltranslator.h"

void setGlobalFont(QGuiApplication &app);

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

  QCoreApplication::setOrganizationName("Individual");

  /* Set C++ classes */
  qmlRegisterType<ConfigParser>("QLabel.ConfigParser", 0, 1, "ConfigParser");
  qmlRegisterType<LabelModel>("QLabel.LabelModel", 0, 1, "LabelModel");

  /* init qt GUI */
  QGuiApplication app(argc, argv);
  QQmlApplicationEngine engine;

  /* init lang */
  QLabelTranslator trans(&engine);
  engine.rootContext()->setContextProperty("trans", &trans);
  trans.selectLanguage("zh_CN"); // default choose: chinese

  /* set font */
  setGlobalFont(app);

  /* Config Application */
  const QUrl url(QStringLiteral("qrc:/main.qml"));
  QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                   &app, [url](QObject *obj, const QUrl &objUrl) {
    if (!obj && url == objUrl)
      QCoreApplication::exit(-1);
  }, Qt::QueuedConnection);
  engine.load(url);

  return app.exec();
}

void setGlobalFont(QGuiApplication &app) {

#ifdef Q_OS_WINDOWS
//  QFont default_font;
  QFont default_font("Microsoft Yahei");
  default_font.setStyleHint(QFont::SansSerif);
  app.setFont(default_font);
#endif

#ifdef Q_OS_MACOS
  QFont default_font("PingFang");
  default_font.setStyleHint(QFont::SansSerif);
  app.setFont(default_font);
#endif

  /* different linux distro uses different font */
}
