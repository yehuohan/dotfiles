#!/usr/bin/env python3

"""
utils for UltiSnips
"""

import os

DotVimPath = os.getenv("DotVimPath")

def load_template(filename):
    """从文件中加载模版"""
    f = DotVimPath + '/snips/template/' + filename
    with open(f, 'r', encoding='utf-8') as fp:
        return ''.join(fp.readlines())
    return 'Failed to load template: ' + f
