
cmake_minimum_required(VERSION 3.5)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR})

#set(CMAKE_C_COMPILER "clang")
#set(CMAKE_CXX_COMPILER "clang++")
#set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS} -g")
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
project(main LANGUAGES CXX)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/inc
    )
#file(GLOB_RECURSE SRC ${CMAKE_CURRENT_SOURCE_DIR}/src)
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/src SRC)
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/lib)

add_compile_options(-g -Wall -DMYVAR=1)
add_compile_definitions(MYVAR=1)
add_executable(${PROJECT_NAME} ${SRC})
add_library(${PROJECT_NAME} <SHARED,STATIC,MODULE>
    ${SRC}
    )
#target_include_directories # target_xxx命令：其它Target链接此Target需要的include_directories
#target_compile_options
#target_compile_definitions
#target_link_options
#target_link_directories
target_link_libraries(${PROJECT_NAME} lib)
add_dependencies(${PROJECT_NAME} lib)


# tags
set_source_files_properties(tags PROPERTIES GENERATED TRUE)
add_custom_target(tags
    COMMAND ctags -R ${CMAKE_CURRENT_SOURCE_DIR}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
