# This file is NOT licensed under the GPLv3, which is the license for the rest
# of YouCompleteMe. The license text is in the end of this file.

import os
import platform
import ycm_core
import re

def NewWalk(top, suffixs, exdirs):
    """
    NotImplement new walk function with suffix and dir filter.
    """
    top = os.fspath(top)
    dirs = []
    nondirs = []

    # We have read permission to our project obviously.
    scandir_it = os.scandir(top)
    with scandir_it:
        while True:
            try:
                try:
                    entry = next(scandir_it)
                except StopIteration:
                    break
            except OSError as error:
                return

            try:
                is_dir = entry.is_dir()
            except OSError:
                # If is_dir() raises an OSError, consider that the entry is not
                # a directory, same behaviour than os.path.isdir().
                is_dir = False

            if is_dir:
                # 'entry is not is exdirs'
                if entry.name not in exdirs:
                    dirs.append(entry.name)
            else:
                # 'suffixs is empty' or 'entry is in suffix'
                if not suffixs or os.path.splitext(entry.name)[1] in suffixs:
                    nondirs.append(entry.name)

    yield top, dirs, nondirs

    # Recurse into sub-directories
    islink, join = os.path.islink, os.path.join
    for dirname in dirs:
        new_path = join(top, dirname)
        if not islink(new_path):
            yield from NewWalk(new_path, suffixs, exdirs)

def GetDirsRecursive(flag, paths, suffixs=[], exdirs=[]):
    """
    Get dirs recursive with suffix and dir filter.
    """
    flags = []
    for path in paths:
        for root, dirs, files in NewWalk(path, suffixs, exdirs):
            # files or dirs is not empty
            if files or dirs:
                flags.append(flag)
                flags.append(root)
    return flags


LOC_DIR = os.path.dirname(os.path.abspath(__file__))
log_out = False

#===============================================================================
# user flags
# search order : "-I >= -isystem >= std"
#===============================================================================
project_flags = [
    # '-Werror',                # Take all errors as warnings
    # '-Wno-unused-variable',   # Show warning of unused variable
    # '-Wno-unused-parameter',  # Show warning of unused parameter
    '-std=c++11',               # std parameter with 'c++11', 'c99',
    '-xc++',                    # Set language: 'c', 'c++', 'objc', 'cuda',
    # '-DXX=XX'                 # define macro to elimate some errors
    ]

local_flags = GetDirsRecursive('-isystem',
    [
        # os.path.join(LOC_DIR, ''),
    ], ['.c', '.cpp', '.h', '.hpp' ], ['sample'])

if platform.system() == "Linux":
    GCC_DIR = os.path.join('/usr/include/c++',
        list(filter(lambda dir: re.compile(r'^\d{1,2}\.\d{1,2}\.\d{1,2}$').match(dir),
                    os.listdir('/usr/include/c++')))[0])
    QT_DIR = '/usr/include/qt/'
elif platform.system() == "Windows":
    # GCC_DIR = 'C:/MyApps/msys64/mingw64/lib/gcc/x86_64-w64-mingw32/7.3.0/include'
    GCC_DIR = 'D:/VS2017/VC/Tools/MSVC/14.13.26128/include/'
    QT_DIR  = 'D:/Qt/5.10.1/msvc2017_64/include/'

global_flags = ['-isystem', GCC_DIR] + \
    GetDirsRecursive('-isystem',
    [
        # QT_DIR,
    ])

user_flags = project_flags + local_flags + global_flags
if log_out:
    with open(os.path.join(LOC_DIR, "log.txt"), 'w+') as flog:
        flog.write("Try to use :YcmDiags(<leader>yD) to find out where's the error!\n")
        flog.write("Size: {}\n".format(len(user_flags)))
        for k in range(len(user_flags)):
            flog.write(user_flags[k] + '\n')


#===============================================================================
# defaults flags
#===============================================================================
flags = [
'-Wall',
'-Wextra',
'-Wno-long-long',
'-Wno-variadic-macros',
'-fexceptions',
'-DNDEBUG',
] + user_flags


# Set this to the absolute path to the folder (NOT the file!) containing the
# compile_commands.json file to use that instead of 'flags'. See here for
# more details: http://clang.llvm.org/docs/JSONCompilationDatabase.html
#
# You can get CMake to generate this file for you by adding:
#   set( CMAKE_EXPORT_COMPILE_COMMANDS 1 )
# to your CMakeLists.txt file.
#
# Most projects will NOT need to set this to anything; you can just change the
# 'flags' list of compilation flags. Notice that YCM itself uses that approach.
compilation_database_folder = ''

if os.path.exists( compilation_database_folder ):
  database = ycm_core.CompilationDatabase( compilation_database_folder )
else:
  database = None

SOURCE_EXTENSIONS = [ '.cpp', '.cxx', '.cc', '.c', '.m', '.mm' ]

def DirectoryOfThisScript():
  return os.path.dirname( os.path.abspath( __file__ ) )


def MakeRelativePathsInFlagsAbsolute( flags, working_directory ):
  if not working_directory:
    return list( flags )
  new_flags = []
  make_next_absolute = False
  path_flags = [ '-isystem', '-I', '-iquote', '--sysroot=' ]
  for flag in flags:
    new_flag = flag

    if make_next_absolute:
      make_next_absolute = False
      if not flag.startswith( '/' ):
        new_flag = os.path.join( working_directory, flag )

    for path_flag in path_flags:
      if flag == path_flag:
        make_next_absolute = True
        break

      if flag.startswith( path_flag ):
        path = flag[ len( path_flag ): ]
        new_flag = path_flag + os.path.join( working_directory, path )
        break

    if new_flag:
      new_flags.append( new_flag )
  return new_flags


def IsHeaderFile( filename ):
  extension = os.path.splitext( filename )[ 1 ]
  return extension in [ '.h', '.hxx', '.hpp', '.hh' ]


def GetCompilationInfoForFile( filename ):
  # The compilation_commands.json file generated by CMake does not have entries
  # for header files. So we do our best by asking the db for flags for a
  # corresponding source file, if any. If one exists, the flags for that file
  # should be good enough.
  if IsHeaderFile( filename ):
    basename = os.path.splitext( filename )[ 0 ]
    for extension in SOURCE_EXTENSIONS:
      replacement_file = basename + extension
      if os.path.exists( replacement_file ):
        compilation_info = database.GetCompilationInfoForFile(
          replacement_file )
        if compilation_info.compiler_flags_:
          return compilation_info
    return None
  return database.GetCompilationInfoForFile( filename )


def FlagsForFile( filename, **kwargs ):
  if database:
    # Bear in mind that compilation_info.compiler_flags_ does NOT return a
    # python list, but a "list-like" StringVec object
    compilation_info = GetCompilationInfoForFile( filename )
    if not compilation_info:
      return None

    final_flags = MakeRelativePathsInFlagsAbsolute(
      compilation_info.compiler_flags_,
      compilation_info.compiler_working_dir_ )

    # NOTE: This is just for YouCompleteMe; it's highly likely that your project
    # does NOT need to remove the stdlib flag. DO NOT USE THIS IN YOUR
    # ycm_extra_conf IF YOU'RE NOT 100% SURE YOU NEED IT.
    try:
      final_flags.remove( '-stdlib=libc++' )
    except ValueError:
      pass
  else:
    relative_to = DirectoryOfThisScript()
    final_flags = MakeRelativePathsInFlagsAbsolute( flags, relative_to )

  return { 'flags': final_flags }



#
# Here's the license text for this file:
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org/>
