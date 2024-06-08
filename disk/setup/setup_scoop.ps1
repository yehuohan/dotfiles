
### .Install
<#
Get install.ps1 from https://github.com/ScoopInstaller/Install/blob/master/install.ps1
Then unlock install.ps1 from attributes to install scoop. How stupid!
#>
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh -outfile 'install.ps1'
.\install.ps1 -ScoopDir 'D:\apps\_packs' -ScoopGlobalDir 'D:\apps\_packs' -NoProxy
.\install.ps1 -ScoopDir "$env:DOT_APPS\_packs" -ScoopGlobalDir "$env:DOT_APPS\_packs" -NoProxy

### .Patch
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


### .Bucket
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


### .Add
scoop install neovim neovim-qt neovide nvy vim-nightly vscode -a 64bit
scoop install bat delta fd fzf ripgrep lf universal-ctags lazygit@0.40.2
scoop install 7zip 7ztm cmake ninja just
scoop install lua deno nodejs
scoop install python # Then run apps/python/current/install-pep-514.reg (Prefer miniconda3)
scoop install wox snipaste everything screentogif rapidee
scoop install autoruns process-explorer procmon context-menu-manager # cpu-z gpu-z
scoop install qttabbar-indiff-np # Works with [ExplorerPatcher](https://github.com/valinet/ExplorerPatcher) on windows 11
scoop install https://raw.githubusercontent.com/daipeihust/im-select/master/bucket/im-select.json # Only for vim's im-select plugin
scoop install conemu # Windows 11's terminal is better
scoop download clink -h # For conemu
scoop install CodeNewRoman-NF-Mono FantasqueSansMono-NF-Mono -s

scoop install vulkan renderdoc shadered # Then run apps/vulkan/current/install-vk-layers.ps1
scoop install cuda11.1 # Prefer conda install cudatoolkit cudnn
scoop install llvm portable-virtualbox
scoop install notepadnext honeyview potplayer persepolis
scoop install draw.io wpsoffice sioyek 
