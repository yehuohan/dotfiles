
### Install
<#
Get install.ps1 from https://github.com/ScoopInstaller/Install/blob/master/install.ps1
Then unlock install.ps1 from attributes to install scoop. How stupid!
#>
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh -outfile 'install.ps1'
.\install.ps1 -ScoopDir "$env:DOT_APPS\_packs" -ScoopGlobalDir "$env:DOT_APPS\_packs" -NoProxy


### Patch
$SCOOP_PACKAGE_REPO = "https://kkgithub.com/ScoopInstaller/Scoop/archive/master.zip"
$SCOOP_MAIN_BUCKET_REPO = "https://kkgithub.com/ScoopInstaller/Main/archive/master.zip"
$SCOOP_PACKAGE_GIT_REPO = "https://kkgithub.com/ScoopInstaller/Scoop.git"
$SCOOP_MAIN_BUCKET_GIT_REPO = "https://kkgithub.com/ScoopInstaller/Main.git"
.\install.ps1 -ScoopDir "$env:DOT_APPS\_packs" -ScoopGlobalDir "$env:DOT_APPS\_packs" -NoProxy
<#
Patch source code '$DOT_APPS/_packs/apps/scoop/current/lib/install.ps1':
    function Invoke-CachedDownload ($app, $version, $url, $to, $cookies = $null, $use_cache = $true) {
    +    $url = "$url".Replace("https://github.com", "https://kkgithub.com").Replace("https://raw.githubusercontent.com", "https://raw.kkgithub.com")
#>
<# Code patch is not compatible with aria2 #>
scoop config scoop_repo http://kkgithub.com/ScoopInstaller/Scoop
scoop config aria2-enabled false


### Buckets
<#
The 'extras' is some big, so can clone manually or use mirror github:
    cd $DOT_APPS/_packs/buckets
    git clone --depth 1 https://github.com/ScoopInstaller/Extras.git
#>
scoop bucket add main https://github.com/ScoopInstaller/Main.git # If main is not inited
scoop bucket add extras https://github.com/ScoopInstaller/Extras.git
scoop bucket add versions https://github.com/ScoopInstaller/Versions.git
scoop bucket add sysinternals https://github.com/niheaven/scoop-sysinternals.git
scoop bucket add nonportable https://github.com/ScoopInstaller/Nonportable.git
scoop bucket add nerd-fonts https://github.com/matthewjberger/scoop-nerd-fonts.git


### Add
scoop install 7zip 7ztm
scoop install neovim neovim-qt neovide nvy vim-nightly vscode -a 64bit
scoop install bat delta fd fzf ripgrep universal-ctags lazygit@0.40.2
scoop install cmake ninja just lua deno nodejs
scoop install wox everything screentogif rapidee snipaste # Or snipaste-beta for latest version
scoop install autoruns process-explorer procmon context-menu-manager # cpu-z gpu-z
scoop install qttabbar-indiff-np # Works with [ExplorerPatcher](https://github.com/valinet/ExplorerPatcher) on windows 11
scoop install windows-terminal pwsh # For windows-10
scoop install FantasqueSansMono-NF-Mono Maple-Mono-NF-CN Cousine-NF-Mono CodeNewRoman-NF-Mono -s
scoop install https://raw.githubusercontent.com/daipeihust/im-select/master/bucket/im-select.json

scoop install vulkan # Then run apps/vulkan/current/install-vk-layers.ps1
scoop install renderdoc shadered llvm
scoop install notepadnext typst draw.io
scoop install wpsoffice potplayer honeyview
scoop install sioyek
scoop shim add sioyek $env:DOT_APPS/_packs/apps/sioyek/current/sioyek.exe

### Deprecated
scoop install python # Run apps/python/current/install-pep-514.reg
scoop install conemu # Prefer windows-terminal
scoop download clink -h
scoop install cuda11.1 # Prefer `conda install cudatoolkit cudnn`
scoop install portable-virtualbox # Prefer wsl
