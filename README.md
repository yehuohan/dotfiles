
---
# LinuxConfigs
 - 管理Linux的一些配置文件，包括Msys2中的配置文件
 - Author : yehuohan
 - E-mail : 550034086@qq.com, yehuohan@gmail.com
 - Git    : [github](github.com), [oschina](git.oschina.net)


---
# TODO
 - 尝试新字体

---
# Files
 - cf-vim                   : vim配置文件
    - .vimrc                : vim配置文件
    - .ycm\_extra\_conf.py  : vim-ycm配置文件
    - plugin                : vim插件，放于~/.vim/下即可

 - cf-zsh                   : zsh配置文件
    - .zshrc                : zsh配置文件
    - frisk.zsh-them        : zsh主题文件
 
 - cf-Msys2                 : Windows下Msys2配置文件
    - .minttyrc             : Msys2模拟终端mintty配置文件
 
---
# Log
## 20170505 - v1.0.0
 - release v1.0.0，方便对应commit和Log
 - gvim高亮行和列背景改成black

## 20170505
 - wrap映射改成leader-wn/wo
 - 添加visual block的surronding映射
 - 大小写toggle改成用leader-u

## 20170505
 - mintty改用Courier 10 Picth字体

## 20170504
 - 完善注释snippet
 - ycm添加linux下的/usr/include路径

## 20170504
 - 添加注释snippets
 - 设置C-n/m用于补全上下选择，Tab用于选择snippets补全，C-o/p用于snippets位置补全移动
 - 添加ultisnips和snippets插件，同时将自定义mySnippets添加到仓库
 - YCM添加mingw头文件库
 - YCM设置error和warning提示符
 
## 20170504
 - 添加Courier 10 Pitch字体到仓库
 - 改用new-railscasts theme，改用Courier 10 Pitch字体
 - 修改ctrlspace配色方案，添加RootMarks
 - airline添加ctrlspace和ycm支持
 - windows下HOME路径改成VIM安装路径
 - vim内部使用utf-8编码，ctrlspace需要utf-8编码
 
## 20170504
 - 添加vim-ctrlspace插件
 - 去除powerline，改用airline，设置成非分屏时同样显示
 - 去掉visualmark插件
 - 添加wrap和nowrap映射
 - 去掉leader-d
 - 去掉inoremap C-hjkl，改成用C-hl选择tab页
 - vimgrep改成leader-f，去除leader-fj/k，因为quickfix可以直接跳转

## 20170503
 - EasyMotion修改leader-w为leader-ww，防止等待

## 20170502
 - F5编译时，文件名添加引号，防止文件名有空格
 
## 20170502
 - 使用SaveSession!，强制保存会话

## 20170430
 - 优化vimrc注释格式
 - 去掉vimrc中折retab

## 20170429
 - 添加windows下Msys2环境的配置文件

## 20170429
 - Window添加YCM插件  

## 20170428
 - 添加F5程序运行映射
 - 添加平台判断函数IsLinux和IsWin

## 20170426
 - 将C-nm改成C-jk映射

## 20170426
 - 添加EasyMotion插件
 - 添加frisk.zsh-theme主题
 - .vimrc的vundle指定安装路径
 - .vimrc添加MyNotes部分

## 20170424
 - 添加MyVimPath，windows下同样添加插件
 - 分屏窗口焦点移动，改成使用leader-hjkl
 - 添加leader-ff，搜索当前单词，并显示结果，添加cnext和cprevious映射
 - 修改leader-v，为择择当前单词

## 20170423
 - 添加Session插件，并添加相应map
 - 添加显示查找结果窗口快捷键

## 20170422
 - 添加文本对齐插件Tabularize
 - YCM添加"转到定义"和"显示错误”快捷键
 - 添加map leader-` ~

## 20170420
 - 添加visualmark
 - 添加<M-left/right/0～9>来切换tab标签

## 20170410
 - 去掉leader-q等映射

## 20170329
 - 修改Map，将;映射成:
 - 增加一些映射，主要是当leader当成Shift

## 20170325
 - 添加alias cman，使用~代替主目录路径

## 20170320
 - 取消C-a映射，对调capslock和esc键
 
## 20170315
 - 修改KeyMap段注释
 - 将C-a映射imap成esc

## 20170315
 - 添加gvim配置
 - 对unix和win32环境分别配置
 - 添加寄存器相关键映射(复制等)

## 20170314
 - 添加zshrc配置，关于命令记录的命令
 - 添加vim按键Map，使用;作为大写字母开头命令，添加“行”快速选择
 
## 20170312
 - 添加.ycm_extra_conf.py
 - .vimrc添加到display, keymap, vundel三部分
 - .zshrc添加ctrl-z返回vim
 - 添加cc.sh，将需要git的文件copy到文件侠LinuxCongifs中
 
## 20170311
 - 添加git仓
 - 添加zsh和vim基本配置
