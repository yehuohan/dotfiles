
---
# LinuxConfigs
 - 管理Linux的一些配置文件
 - Author : yehuohan
 - E-mail : <550034086@qq.com>, <yehuohan@gmail.com>
 - Git    : <github.com>, <git.oschina.net>


---
# Files
 - .vimrc               : vim配置文件
 - .ycm\_extra\_conf.py : vim-ycm配置文件
 - .zshrc               : zsh配置文件
 - frisk.zsh-them       : zsh主题文件
 - plugin               : vim插件，放于~/.vim/下即可
 
---
# Log
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
 - 分屏窗口焦点移动，改成使用<leader>hjkl
 - 添加<leader>ff，搜索当前单词，并显示结果，添加cnext和cprevious映射
 - 修改<leader>v，为择择当前单词

## 20170423
 - 添加Session插件，并添加相应map
 - 添加显示查找结果窗口快捷键

## 20170422
 - 添加文本对齐插件Tabularize
 - YCM添加"转到定义"和"显示错误”快捷键
 - 添加map <leader>` ~

## 20170420
 - 添加visualmark
 - 添加<M-left/right/0～9>来切换tab标签

## 20170410
 - 去掉<leader>q等映射

## 20170329
 - 修改Map，将;映射成:
 - 增加一些映射，主要是当<leader>当成<S>

## 20170325
 - 添加alias cman，使用~代替主目录路径

## 20170320
 - 取消<C-a>映射，对调capslock和esc键
 
## 20170315
 - 修改KeyMap段注释
 - 将<C-a>映射imap成<esc>

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
