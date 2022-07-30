#!/usr/bin/env python3

"""
utils for UltiSnips
"""

import os

DotVimDir = os.getenv("DotVimDir")

def load_template(filename):
    """从文件中加载模版"""
    with open(DotVimDir + '/snips/template/' + filename, 'r', encoding='utf-8') as fp:
        return ''.join(fp.readlines())
