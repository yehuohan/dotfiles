
TEMPLATE = app
CONFIG  -= qt
CONFIG  -= app_bundle
CONFIG  += c++11 console

# debug, release, debug_and_release
CONFIG += debug
CONFIG -= release
CONFIG(debug, debug|release) {
    TARGET      = qcuda-project
    OBJECTS_DIR = debug
} else {
    TARGET      = qcuda-project
    OBJECTS_DIR = release
}
#DESTDIR = $$OBJECTS_DIR/../
MOC_DIR  = $$OBJECTS_DIR/moc
UI_DIR   = $$OBJECTS_DIR/ui
RCC_DIR  = $$OBJECTS_DIR/rcc

#INCLUDEPATH +=
#LIBS +=
unix {
	#INCLUDEPATH += -I/usr/include/GL
    #LIBS += \`pkg-config --libs gl glu freeglut\`
}

#HEADERS   += .h

#===============================================================================
# build as cuda application in linux
#===============================================================================
CONFIG(release, debug|release): CUDA_OBJECTS_DIR = $$OBJECTS_DIR/cuda
else: CUDA_OBJECTS_DIR = $$OBJECTS_DIR/cuda

CUDA_TARGET = $$TARGET
CUDA_SOURCES += $0

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# cuda settings
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CUDA_DIR    = /opt/cuda
CUDA_INC    = $$CUDA_DIR/include \
              $$CUDA_DIR/samples/common/inc
CUDA_LIBDIR = $$CUDA_DIR/lib64
CUDA_LIBS   = cudart cuda

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# cuda nvcc settings
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CUDA_NVCC   = $$CUDA_DIR/bin/nvcc -ccbin g++
NVCC_INC   += $$join(CUDA_INC, '" -I"', '-I"', '"') \
              $$INCLUDEPATH
NVCC_LIBS  += $$join(CUDA_LIBS, ' -l', '-l', '') \
              $$LIBS
NVCC_ARCH   = sm_61
NVCC_FLAGS  = -use_fast_math -arch=$$NVCC_ARCH -m64

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# add compiler
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
QMAKE_LIBDIR += $$CUDA_LIBDIR
cuda.input    = CUDA_SOURCES
cuda.output   = $$CUDA_OBJECTS_DIR/${QMAKE_FILE_BASE}_cuda.o
cuda.commands = $$CUDA_NVCC \
                $$NVCC_FLAGS $$NVCC_INC $$NVCC_LIBS \
                -c -o ${QMAKE_FILE_OUT} ${QMAKE_FILE_NAME}
cuda.depend_type = TYPE_C
QMAKE_EXTRA_COMPILERS += cuda

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# add target, link ${OBJECTS} in makefile
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
cudapp.target   = $$CUDA_TARGET
cudapp.commands = $$CUDA_NVCC \
                $$NVCC_FLAGS $$NVCC_INC $$NVCC_LIBS \
                -o $$CUDA_TARGET ${OBJECTS}
QMAKE_EXTRA_TARGETS += cudapp
