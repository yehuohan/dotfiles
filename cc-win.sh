
#!/bin/bash

# copy all the <config-files> to <cf-dir>
# cd to LinuxConfigs before execute this file.
# this file must be in "LinuxConfigs/"


# cf-vim
cp ../Vim/_vimrc ./cf-vim/.vimrc
cp ../Vim/vimfiles/.ycm_extra_conf.py ./cf-vim/
cp -r ../Vim/vimfiles/mySnippets/ ./cf-vim/
cp -r ../Vim/vimfiles/autoload/ ./cf-vim/

# cf-msys2
cp ~/.minttyrc ./cf-msys2/
cp ~/.gitconfig ./cf-msys2/
cp ~/.zshrc ./cf-msys2/
