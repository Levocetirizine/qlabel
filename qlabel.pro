QT += quick

CONFIG += c++11

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

#QMAKE_CXXFLAGS += /source-charset:utf-8 /execution-charset:utf-8

SOURCES += \
        common/qlabeltranslator.cpp \
        io/configparser.cpp \
        main.cpp \
        model/labelmodel.cpp \
        model/labelmodel_dataaccess.cpp \
        model/labelmodel_fileparser.cpp \
        model/strnatcmp.c

RESOURCES += qml.qrc

TRANSLATIONS += \
    qlabel_zh_CN.ts


# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

INCLUDEPATH += $$PWD/toml11/

HEADERS += \
  common/qlabeltranslator.h \
  io/configparser.h \
  model/labelmodel.h \
  model/page.hpp \
  model/strnatcmp.h \
  model/translation.hpp \
  toml11/toml.hpp \
  toml11/toml/color.hpp \
  toml11/toml/combinator.hpp \
  toml11/toml/comments.hpp \
  toml11/toml/datetime.hpp \
  toml11/toml/exception.hpp \
  toml11/toml/from.hpp \
  toml11/toml/get.hpp \
  toml11/toml/into.hpp \
  toml11/toml/lexer.hpp \
  toml11/toml/literal.hpp \
  toml11/toml/parser.hpp \
  toml11/toml/region.hpp \
  toml11/toml/result.hpp \
  toml11/toml/serializer.hpp \
  toml11/toml/source_location.hpp \
  toml11/toml/storage.hpp \
  toml11/toml/string.hpp \
  toml11/toml/traits.hpp \
  toml11/toml/types.hpp \
  toml11/toml/utility.hpp \
  toml11/toml/value.hpp

DISTFILES += \
  design.md
