
# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# http://www.sphinx-doc.org/en/master/config


# -- Path setup --------------------------------------------------------------

# 设置源码路径（use absolute path）
# import os
# import sys
# sys.path.insert(0, os.path.abspath('.'))


# -- Project information -----------------------------------------------------

# 项目信息
project = ''
copyright = '2020, user@mail.com'
author = ''



# -- General configuration ---------------------------------------------------
extensions = [ # Sphinx扩展模块
    'sphinx.ext.autodoc',
    'recommonmark',
]
templates_path = ['_templates'] # 模版路径
language = 'zh' # 文档语言
source_suffix = { # 文档支持格式
    '.rst' : 'restructuredtext',
    '.md' : 'markdown',
}
exclude_patterns = [] # 忽略的文件和目录


# -- Options for HTML output -------------------------------------------------
html_theme = 'sphinxdoc' # 文档主题样式: sphinxdoc, nature
html_theme_options = {
    'sidebarwidth': '25%',
}
html_static_path = ['_static'] # HTML静态文件(style sheets ...)


# -- Options for Latex output ------------------------------------------------
latex_engine = 'xelatex'
latex_elements = {
    'papersize': 'a4paper',
    'pointsize': '11pt',
    'extraclassoptions': 'oneside',
    'preamble': r'''
\usepackage[titles]{tocloft}
\usepackage{ctex}
\setmainfont{Noto Serif}
\setsansfont{Noto Sans}
\setmonofont{Noto Sans Mono}
\setCJKmainfont{Noto Serif CJK SC}
\setCJKsansfont{Noto Sans CJK SC}
\setCJKmonofont{Noto Sans Mono CJK SC}
'''
}
