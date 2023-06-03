
QT += core
QT -= gui

TEMPLATE = app
CONFIG  += c++11 console

# debug, release, debug_and_release
CONFIG += debug
CONFIG -= release
CONFIG(debug, debug|release) {
    TARGET      = qcon-project
    OBJECTS_DIR = debug
} else {
    TARGET      = qcon-project
    OBJECTS_DIR = release
    DEFINES    += QT_NO_WARNING_OUTPUT \
                QT_NO_DEBUG_OUTPUT
}
#DESTDIR = $$OBJECTS_DIR/../
MOC_DIR  = $$OBJECTS_DIR/moc
UI_DIR   = $$OBJECTS_DIR/ui
RCC_DIR  = $$OBJECTS_DIR/rcc

#INCLUDEPATH +=
#LIBS        +=
unix {
    #LIBS += \`pkg-config --libs \`
}

#PRECOMPILED_HEADER = pch.h
SOURCES    += \
	main.cpp
#HEADERS   += .h
