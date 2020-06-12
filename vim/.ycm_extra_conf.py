
"""
.ycm_extra_conf.py for YouCompleteMe.vim

:Author: yehuohan, yehuohan@gmail.com, yehuohan@qq.com
:Ref:
    - https://github.com/Valloric/ycmd
    - https://github.com/Valloric/YouCompleteMe
"""

import os
import platform
import re

LOC_DIR = os.path.dirname(os.path.abspath(__file__))  # Local working path

#===============================================================================
# cfamily
#===============================================================================
def NewWalk(top, suffixs, exdirs):
    """
    Implement new walk function with suffix and diretory filter.
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
    - flag: the clang flag to each directory.
    - paths: the root path list to collect.
    - suffixs: collect the directory which contains files with suffix.
    - exdirs: exclude the directory in exdirs.
    """
    flags = []
    for path in paths:
        for root, dirs, files in NewWalk(os.path.expanduser(path), suffixs, exdirs):
            # files or dirs is not empty
            if files or dirs:
                flags.append(flag)
                flags.append(root)
    return flags

def GetCfamilyFlags(gen='all'):
    """
    Collect all cfamily flags.
    All the header file should be in absolute path.
    """
    project_flags = [
        '-Wall',
        '-Wextra',
        '-Wno-long-long',
        '-Wno-variadic-macros',
        '-fexceptions',
        '-DNDEBUG',
        # '-Werror',                # Take all errors as warnings
        # '-Wno-unused-variable',   # Show warning of unused variable
        # '-Wno-unused-parameter',  # Show warning of unused parameter
        # '-DXX=XX'                 # define macro to elimate some errors
        # '-std=c++17',             # std parameter with 'c++17', 'c++14', 'c++11', 'c99'
        '-xc++',                    # Set language: 'c', 'c++', 'objc', 'cuda',
    ]

    # local flags from project
    local_paths = [
            # os.path.join(LOC_DIR, ''),
        ]
    if gen == 'tags':
        return local_paths 
    local_flags = GetDirsRecursive('-isystem' if gen == 'all' else '',
            local_paths, ['.c', '.cpp', '.h', '.hpp' ], ['sample', 'test'])

    # global flags from host-system, $VPath is from env#env
    if platform.system() == "Linux":
        UNIX_DIR = '/usr/include'
        GCC_DIR = os.path.join('/usr/include/c++', os.listdir('/usr/include/c++')[0])
    elif platform.system() == "Windows":
        UNIX_DIR = os.getenv('VPathCygwin') + '/usr/include'
        GCC_DIR = os.path.join(os.getenv('VPathCygwin') + '/lib/gcc/x86_64-pc-cygwin',
                os.listdir(os.getenv('VPathCygwin') + '/lib/gcc/x86_64-pc-cygwin')[0] + '/include')
        VS_DIR = os.getenv('VPathVs') + '/include/'

    global_flags = [
            # '-isystem', GCC_DIR,
            # '-isystem', UNIX_DIR,
            # '-isystem', VS_DIR,
        ] + GetDirsRecursive('-isystem', [
            # GCC_DIR,
            # UNIX_DIR,
        ])

    # all flags
    flags_cfamily = project_flags + local_flags + global_flags
    return flags_cfamily

if __name__ == "__main__":
    # Create compile_flags.txt and tags
    with open('compile_flags.txt', 'w') as fp:
        fp.write('\n'.join(GetCfamilyFlags()))
    os.system('ctags -R ' + ' '.join(GetCfamilyFlags('tags')))

#===============================================================================
# python
#===============================================================================
def GetPythonPath():
    if platform.system() == "Linux":
        return '/usr/bin/python'
    elif platform.system() == "Windows":
        return os.getenv('VPathPython') + '/python.exe'

def GetPythonSysPath():
    return [
        LOC_DIR,
        os.getenv('VPathPython') + '/Lib/site-packages',
        os.getenv('VPathPython') + '/Scripts'
        ]

#===============================================================================
# Settings function called by ycmd to return language flags.
#===============================================================================
def Settings( **kwargs ):
    language = kwargs[ 'language' ]
    if language == 'cfamily':
        return {
            'flags': GetCfamilyFlags(),
            }
    elif language == 'python':
        return {
            # 'interpreter_path': GetPythonPath(),
            # 'sys_path': GetPythonSysPath(),
            }
    return {}


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
