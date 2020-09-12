
TEMPLATE = app
CONFIG  -= qt
CONFIG  -= app_bundle
CONFIG  += c++11 console

# debug, release, debug_and_release
CONFIG += debug
CONFIG -= release
CONFIG(debug, debug|release) {
    TARGET      = cpp-project
    OBJECTS_DIR = debug
} else {
    TARGET      = cpp-project
    OBJECTS_DIR = release
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
