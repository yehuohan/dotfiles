
---
# cf-vim-ChangeLog

## 20170922 - vv2.1.165
 - 显示airline-tabline
 - 使用powerline font
 - 修改;与:的映射

## 20170921 - vv2.1.162
 - 完善FindVimgrep函数

## 20170921 - vv2.1.161
 - 添加scrolloff参数设置

## 20170921 - vv2.1.160
 - 添加quickhl leader-hc映射

## 20170921 - vv2.1.159
 - 添加quickfix和location-list预览函数
 - 使用fork的quickhl插件

## 20170921 - vv2.1.157
 - 添加M-d/f映射，用于书签切换

## 20170921 - vv2.1.156
 - 添加大写字母寄存器的粘贴映射

## 20170921 - vv2.1.155
 - 添加leader-rf映射

## 20170920 - vv2.1.154
 - 设置fswitch-fsnonewfiles选项
 - copen和lopen添加botright参数

## 20170920 - vv2.1.152
 - FindVimgrep搜索函数添加lvimgrep特性

## 20170920 - vv2.1.151
 - 添加bookmark plugin
 - 添加quickfix和location-list的next,previous映射

## 20170920 - vv2.1.149
 - 添加quickhl
 - 修改InvConcealLevel映射

## 20170919 - vv2.1.147
 - 添加popset参数

## 20170912 - vv2.1.146
 - 添加Fzf相关映射

## 20170910 - vv2.1.145
 - 完善find-vimgrep

## 20170910 - vv2.1.144
 - 添加find-vimgrep

## 20170907 - vv2.1.143
 - 去除asd2num插件，将asd2num代码直接添加到vimrc中

## 20170907 - vv2.1.142
 - vimgrep映射中的copen添加botright参数

## 20170907 - vv2.1.141
 - 修改diff中的dp和dg的map

## 20170907 - vv2.1.140
 - 添加水平滚屏map

## 20170907 - vv2.1.139
 - 移除CCTree

## 20170907 - vv2.1.138
 - 移除自定义的surrouding map
 - 更改nerd-commenter map
 - 添加matchit
 - 添加CCTree

## 20170906 - vv2.1.134
 - 添加M-nm为半屏滚动map

## 20170906 - vv2.1.133
 - 改用M-io来切换Tab

## 20170906 - vv2.1.132
 - 添加NERDTree按键map

## 20170906 - vv2.1.131
 - 添加autocmd：新文件自动设置为unix格式

## 20170831 - vv2.1.130
 - 添加popset options

## 20170830 - vv2.1.129
 - 添加popset

## 20170820 - vv2.1.128
 - 更改NERDTree,region-expand,goyo插件的按键映射

## 20170818 - vv2.1.127
 - 用autocmd实现针对不同类型文件的设定

## 20170818 - vv2.1.126
 - 添加F5 matlab命令

## 20170816 - vv2.1.125
 - 添加startify插件，代替session
 - 优化替vim-over, expand-region插件的映射
 - 添加fzf搜索插件
 - 使用tagbar代替taglist
 - 将插件加载写在vimrc的前面，防止插件的设置覆盖了自定义设置

## 20170815 - vv2.1.120
 - 修改Ycm和ultisnips的映射

## 20170814 - vv2.1.119
 - 添加行号类型与折叠列宽切换函数

## 20170813 - vv2.1.118
 - 添加diff映射
 
## 20170813 - vv2.1.117
 - 优化折叠设置

## 20170812 - vv2.1.116
 - 优化AsyncRun命令映射

## 20170812 - vv2.1.115
 - 修改ctrlspace映射，同时支持neovim和vim

## 20170811 - vv2.1.114
 - 添加directx选项

## 20170811 - vv2.1.113
 - 添加undotree插件
 - 添加gruvbox主题

## 20170811 - vv2.1.111
 - 添加neovim-gui-shim插件

## 20170811 - vv2.1.110
 - 添加neovim配置基本选项

## 20170810 - vv2.0.109
 - 添加quickfix窗口管理映射
 - 添加vim帮帮助和man帮助映射

## 20170805 - vv2.0.107
 - 优化Surround和motion按键配置

## 20170805 - vv2.0.106
 - 完善ycm_extra_conf

## 20170804 - vv2.0.105
 - 添加markdown显示插件
 
## 20170804 - vv2.0.104
 - 实现xfce4-terminal光标变化

## 20170803 - vv2.0.103
 - 实现xterm光标变化

## 20170803 - vv2.0.102
 - 添加multiple-cursors插件
 - 添加Alt按键映射设置

## 20170803 - vv2.0.100
 - 添加fcitx输入自动切换

## 20170802 - vv2.0.99
 - 添加AsyncRun插件，实现异步运行程序
 - 完善ycm路径

## 20170801 - vv2.0.97
 - 添加切换透明背景映射(Arch)

## 20170728 - vv2.0.96
 - linux下gvim改用DejaVu字体

## 20170728 - vv2.0.95
 - 添加expand-region插件

## 20170728 - vv2.0.94
 - incsearch使用C-j,k,n,b来在查找时滚动
 - scroll使用C-n,b来滚屏

## 20170726 - vv2.0.92
 - Linux下gvim使用consolas字体

## 20170726 - vv2.0.91
 - 设置NERDTreeShowHidden为true

## 20170726 - vv2.0.90
 - 不同项目配置，使用不同ChangeLog



## 20170725 - v2.0.89
 - 添加invlist映射

## 20170725 - v2.0.88
 - 添加vimcdoc

## 20170725 - v2.0.87
 - 添加nnoremap Tabularize

## 20170724 - v2.0.86
 - 换用vim-plug管理插件

## 20170724 - v1.7.85
 - 添加后比缀名检测

## 20170723 - v1.7.84
 - 添加vim-latex

## 20170720 - v1.6.83
 - 添加寄存器快速复制与粘贴映射

## 20170715 - v1.6.82
 - 添加显示markdown等格式中的隐藏字符的映射

## 20170715 - v1.6.81
 - gvim打开重新设定窗口尺寸

## 20170714 - v1.6.80
 - zshrc添加Apps和PATH路径

## 20170711 - v1.6.79
 - 添加C-r按键映射

## 20170630 - v1.6.78
 - 添加page,module等snippets

## 20170626 - v1.6.77
 - 将c,cpp等文件设置成syntax折叠

## 20170623 - v1.6.76
 - windows下ycm添加qt的QtCore等头文件路径

## 20170620 - v1.6.75
 - F5编译c++程序时，添加c++11标准

## 20170619 - v1.6.74
 - 修改linux下gvim字体设置错误

## 20170617 - v1.6.73
 - windows下gvim中文字体使用YaHei Mono，对应英文字体使用Consolas

## 20170604 - v1.6.72
 - 添加doxygen相关的snippets

## 20170602 - v1.6.71
 - linux下天加markdown-preview插件的google路径

## 20170601 - v1.6.70
 - 添加markdown-preview插件
 - 添加mathjax-support-for-mkdp插件
 - 添加MarkdownToggle函数以及映射

## 20170531 - v1.5.47
 - mintty更改背景颜色与透明度
 
## 20170531 - v1.5.46
 - 修改F5 map对于py和pyw文件的问题

## 20170531 - v1.5.45
 - 优化README.md文件列表显示
 
## 20170522 - v1.5.44
 - 添加Ycm Goto等命令的映射
 - 添加错误显示信息命令映射，以及设置错误列表窗口大小
 - 开启YCM语法补全和tags补全
  
## 20175021 - v1.5.41
 - Linux下gvim字体使用Ubuntu Mono

## 20170520 - v1.5.40
 - 添加vnoremap下的S-l和S-h的映射
 
## 20170519 - v1.5.39
 - 去掉yL对ySS的映射，添加yL和yH的映射
 
## 20170516 - v1.5.38
 - 添加leader-wp映射，跳转到preview窗口
 
## 20170516 - v1.5.37
 - 添加C-w-HJKLT移动窗口相关映射，以及C-w-=等宽高映射
 - 改成leader-qa来关闭所有窗口，并保存会话
 
## 20170516 - v1.5.35
 - 去掉对viw的映射
 - 显示相对行号
 
## 20170516 - v1.5.33
 - 关闭normal模式下按esc的声音及闪屏

## 20170515 - v1.5.32
 - 添加F5映射，使用python运行.pyw，方便调试

## 20170515 - v1.5.31
 - set fileformat=unix，以unix格式保存文件文件

## 20170515 - v1.5.30
 - 主题改成通插件new-railscasts-theme来加载
 - 使用set invwrap的映射为leader-iw，同时去掉set wrap和set nowrap的命令
 - 更新TODO和LinuxConfigs基本介绍

## 20170513 - v1.5.29
 - 添加asd2num插件

## 20170513 - v1.4.28
 - 添加vim-over插件，实现substitute preview
 - 添加fswitch插件，使用leader-fh切换
 - 使用leader-t?作为toggle命令前缀
 - 添加rainbow插件
 - vimgrep查打当前单词改用leader-fw 
 - map L to $ and H to ^ and S to %
 - 取消ysw,ysiw,yss,ySS的映射

## 20170513 - v1.1.21
 - 添加smooth-scroll插件，平滑屏幕滚动效果
 - 添加incsearch插件，并配置相应的搜索映射按键，强化查找功能
 - 修改search在cterm下的背景与前景

## 20170512 - v1.0.18
 - 修改c/c++ comment block snippet

## 20170510 - v1.0.17
 - 将vmap leader-f改成使用vmap leader-/来vimgrep选择的字符串

## 20170510 - v1.0.16
 - 简化vim-surround的map
 - 添加vim-repeat插件

## 20170509 - v1.0.14
 - highlight search的guifg只在gvim环境下改
 - 添加vim-surround插件

## 20170509 - v1.0.12
 - 添加buffer switch相关映射(leader-bn/bp/bl)
 - easy-motion原来的leader-b改成leader-bb映射

## 20170509 - v1.0.10
 - 添加vmap / : 查找选择的字符串，所选字符串不能含有转义符
 - 添加vmap leader-f : 使用vimgrep查找所选字符串，所选字符串不能含有转义符
 - nmap下的leader-f改成"/\<str\>"模式，vmap下的查找使用"/str"模式，自己输入str时，默认使用"/str"模式，也可以自己输入所想要的查找模式

## 20170509 - v1.0.7
 - 初化改成set nowrap

## 20170508 - v1.0.6
 - win下gvim的cousine字体大小改为h11

## 20170508 - v1.0.5
 - 修复多行block surrounding问题
 - highlight search的guifg改成white
 - nerdcommenter注释后添加space
 
## 20170507 - v1.0.2
 - Win下gvim使用cousine字体

## 20170505 - v1.0.1
 - 隐藏gvim的横竖滚动条

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
 - 添加map leader-\` ~

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
