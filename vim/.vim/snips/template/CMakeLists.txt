
cmake_minimum_required(VERSION 3.5)

#set(CMAKE_C_COMPILER "clang")
#set(CMAKE_CXX_COMPILER "clang++")
#set(CMAKE_C_FLAGS "${CMAKE_CXX_FLAGS} -g")
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g")
project(main LANGUAGES CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

#set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
set(DIR_INC
    ${CMAKE_CURRENT_SOURCE_DIR}/inc
)
include_directories(${DIR_INC})
aux_source_directory(${CMAKE_CURRENT_SOURCE_DIR}/src SRC)

add_compile_options(-g -Wall)
add_executable(${PROJECT_NAME} ${SRC})
#add_library(${PROJECT_NAME} <SHARED,STATIC,MODULE>
#    ${SRC}
#)
#target_link_libraries(${PROJECT_NAME} <libs>)
#add_dependencies(${PROJECT_NAME} <libs>)

# tags
set_source_files_properties(tags PROPERTIES GENERATED TRUE)
add_custom_target(tags
    COMMAND ctags -R ${SRC} ${DIR_INC}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
