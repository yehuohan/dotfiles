cmake_minimum_required(VERSION 3.5)

set(PROJECT_ROOT ${CMAKE_CURRENT_SOURCE_DIR})
set(PROJECT_BUILD_DIR ${PROJECT_ROOT}/_VOut/${CMAKE_BUILD_TYPE})
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BUILD_DIR}/Outputs)
set(LIBRARY_OUTPUT_PATH ${PROJECT_BUILD_DIR}/Outputs)
set(CMAKE_STATIC_LIBRARY_PREFIX "")
set(CMAKE_SHARED_LIBRARY_PREFIX "")

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
install(FILES ${PROJECT_BUILD_DIR}/compile_commands.json DESTINATION ${PROJECT_ROOT})

set(CMAKE_C_COMPILER "clang")
set(CMAKE_CXX_COMPILER "clang++")
set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS} -g")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
set(CMAKE_C_STANDARD 99) # 11, 17
set(CMAKE_CXX_STANDARD 11) # 14, 17, 20
set(CMAKE_BUILD_TYPE "Debug")
set(CMAKE_BUILD_TYPE "Release")

# Args for COMMAND should be list(print from message() is a;b;c),
# or use separate_arguments()
execute_process(COMMAND xxx)
add_custom_command(TARGET ${PROJECT_NAME} # add_executable或add_library时执行的命令
    PRE_BUILD or PRE_LINK or POST_BUILD
    COMMAND xxx
    VERBATIM)
add_custom_command(OUTPUT dep # 生成add_custom_target的依赖
    COMMAND xxx
    VERBATIM)
add_subdirectory(${PROJECT_ROOT}/third) # set的变量，在子目录中也生效

# tags
set_source_files_properties(tags PROPERTIES GENERATED TRUE)
add_custom_target(tags # 定义目标（类似于Makefile中的target）
    COMMAND ctags -R ${CMAKE_CURRENT_SOURCE_DIR}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Build library
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
project(main LANGUAGES CXX)

file(GLOB_RECURSE SRC ${CMAKE_CURRENT_SOURCE_DIR}/src/*.*)
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/src SRC)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/inc)
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/lib)
add_compile_options(-g -Wall)
add_compile_definitions(FOO=1)
if(MSVC)
    add_compile_options(/utf-8)
endif()

add_executable(${PROJECT_NAME} ${SRC})
add_library(${PROJECT_NAME} SHARED|STATIC ${SRC})
add_library(${PROJECT_NAME} INTERFACE)
target_sources(${PROJECT_NAME} INTERFACE|PUBLIC|PRIVATE src)
target_include_directories(${PROJECT_NAME} INTERFACE|PUBLIC|PRIVATE inc)
target_compile_options(${PROJECT_NAME} INTERFACE|PUBLIC|PRIVATE -g -Wall)
target_compile_definitions(${PROJECT_NAME} INTERFACE|PUBLIC|PRIVATE FOO=1)
target_link_directories(${PROJECT_NAME} INTERFACE|PUBLIC|PRIVATE dir)
target_link_libraries(${PROJECT_NAME} INTERFACE|PUBLIC|PRIVATE lib)
target_link_options(${PROJECT_NAME} INTERFACE|PUBLIC|PRIVATE -z)

install(FILES,DIRECTORY <src-dirs> DESTINATION ${CMAKE_INSTALL_PREFIX})
install(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_PREFIX})

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# External library
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
project(libname)

add_library(${PROJECT_NAME} INTERFACE)
set_target_properties(${PROJECT_NAME} PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES   "${CMAKE_CURRENT_SOURCE_DIR}/inc"
    INTERFACE_SOURCES               "${CMAKE_CURRENT_SOURCE_DIR}/src"
    INTERFACE_COMPILE_DEFINITIONS   "VAR1=xxx;VAR2=xxx"
    INTERFACE_LINK_DIRECTORIES      "SoPath" # for libsoname.so
    INTERFACE_LINK_LIBRARIES        "targetA;targetB;soname")

add_library(${PROJECT_NAME} STATIC|SHARED IMPORTED GLOBAL)
set_target_properties(${PROJECT_NAME} PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES   "${CMAKE_CURRENT_SOURCE_DIR}/inc"
    IMPORTED_LOCATION_DEBUG         "${CMAKE_CURRENT_SOURCE_DIR}/lib.a"
    IMPORTED_LOCATION_RELEASE       "${CMAKE_CURRENT_SOURCE_DIR}/lib-d.a"
    IMPORTED_LOCATION               "${CMAKE_CURRENT_SOURCE_DIR}/lib.dll"
    IMPORTED_IMPLIB                 "${CMAKE_CURRENT_SOURCE_DIR}/lib.lib"
    INTERFACE_LINK_LIBRARIES        "targetA;targetB")

install(IMPORTED_RUNTIME_ARTIFACTS ${PROJECT_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX})

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Find library
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
set(OpenCV_DIR <path-to-opencv-cmake>) # 设置package的cmake文件查找路径
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})
target_link_libraries(${PROJECT_NAME} ${OpenCV_LIBS})
