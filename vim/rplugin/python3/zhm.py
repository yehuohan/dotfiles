#!/usr/bin/env python3

"""
使用jieba(`pip install jieba`)实现中文Motion。

- ZhmInit: 初始化命令，jieba加载字典大约需要0.5秒，可以提前初始化
- ZhmCmd: Motion命令，支持目前w,e,b,ge四个参数
- ZhmLog: 调试命令

Zhm使用示例：

::

    nnoremap <silent> w :ZhmCmd w<CR>
    nnoremap <silent> b :ZhmCmd b<CR>
    nnoremap <silent> e :ZhmCmd e<CR>
    nnoremap <silent> ge :ZhmCmd ge<CR>

"""

from itertools import accumulate
import bisect
import re
import pynvim
import jieba


@pynvim.plugin
class Zhm(object):
    """Text motion (w,e,b,ge) for zh"""

    zh = re.compile(r'[\u4e00-\u9fa5]')
    sp = re.compile(r'([\u4e00-\u9fa5]+)|([^\u4e00-\u9fa5]+)')
    # sp = re.compile(r'([\x20-\x7e]+)|([^\x20-\x7e]+)')
    dirs = {
        'w': True,
        'e': True,
        'b': False,
        'ge': False,
        }
    flgs = {
        'w': 'W',
        'e': 'We',
        'b': 'Wb',
        'ge': 'Wbe',
        }

    def __init__(self, vim:pynvim.Nvim):
        # self.vim.api.<func> = nvim_<func>
        self.vim = vim
        self.log = ['Zhm inited']

    @pynvim.command('ZhmInit')
    def init(self):
        jieba.initialize()

    @pynvim.command('ZhmCmd', nargs=1)
    def cmd(self, args):
        """support w, e, b, ge"""
        self.move(args[0])

    @pynvim.command('ZhmLog')
    def disp_log(self):
        self.vim.command('echo "{}"'.format('\n'.join(self.log)))

    def move(self, motion):
        """Move cursor according to motion"""
        self.log.clear()
        txt = self.next(Zhm.dirs[motion])
        if txt:
            self.log.append('next return: ' + txt)
            self.vim.call('search',
                    '\\V\\C' + self.vim.call('escape', txt, '/\\'),
                    Zhm.flgs[motion])
        else:
            self.vim.command('normal! ' + motion)

    def next(self, forward:bool):
        """Calc next token according to cursor"""
        line = self.vim.current.line
        if not Zhm.zh.search(line):
            return None

        # Split Chinese chars and non-Chinese chars
        self.col = self.vim.call('getcurpos')[4]
        self.chars = list(filter(None, Zhm.sp.split(line)))
        self.chars_wid = list(accumulate([self.vim.strwidth(s) for s in self.chars]))
        idx = bisect.bisect_left(self.chars_wid, self.col) # Search index of cursor from chars list
        if idx >= len(self.chars):
            idx = len(self.chars) - 1
            self.col = self.chars_wid[-1] # fix wrong col resulted by virtualedit
            if self.vim.strwidth(self.chars[-1][-1]) == 2: # for wide-char, col is the value of left cell's col
                self.col -= 1
        self.log.append('col: {}'.format(self.col))
        self.log.append('chars: {}'.format(' | '.join(self.chars)))
        self.log.append('chars_wid: {}'.format(str(self.chars_wid)))
        self.log.append('chars_idx: {}'.format(idx))

        if Zhm.zh.search(self.chars[idx]):
            # Cursor is at Chinese char
            segs = list(jieba.cut(self.chars[idx], cut_all = False))
            segs_wid = list(accumulate([self.vim.strwidth(s) for s in segs]))
            idx = bisect.bisect_left(segs_wid, self.col - (0 if idx == 0 else self.chars_wid[idx - 1]))
            self.log.append('cursor is in zh')
            self.log.append('\tsegs: {}'.format(' | '.join(segs)))
            self.log.append('\tsegs_wid: {}'.format(str(segs_wid)))
            self.log.append('\tsegs_idx: {}'.format(idx))
            if forward and idx + 1 < len(segs):
                return segs[idx + 1]
            if not forward and idx > 0:
                return segs[idx - 1]
        elif forward and idx + 1 < len(self.chars) and self.chars_wid[idx] == self.col:
            # Cursor is next to Chinese char
            segs = list(jieba.cut(self.chars[idx + 1], cut_all = False))
            return segs[0]
        elif not forward and idx > 0 and self.chars_wid[idx - 1] + 1 == self.col:
            # Cursor is prev to Chinese char
            segs = list(jieba.cut(self.chars[idx - 1], cut_all = False))
            return segs[-1]
        return None
