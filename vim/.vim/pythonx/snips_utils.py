#!/usr/bin/env python3

"""
utils for UltiSnips
"""

import os

DotVimPath = os.getenv("DotVimPath")

def load_template(filename):
    """从文件中加载模版"""
    with open(DotVimPath + '/snips/template/' + filename, 'r', encoding='utf-8') as fp:
        return ''.join(fp.readlines())
