
#.Install
<#
Get install.ps1 from https://github.com/ScoopInstaller/Install/blob/master/install.ps1
Then unlock install.ps1 from attributes to install scoop. How stupid!
#>
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh -outfile 'install.ps1'
.\install.ps1 -ScoopDir 'C:\apps\_packs' -ScoopGlobalDir 'C:\apps\_packs' -NoProxy
.\install.ps1 -ScoopDir "$env:APPS_HOME\_packs" -ScoopGlobalDir "$env:APPS_HOME\_packs" -NoProxy

#.Patch
$SCOOP_PACKAGE_REPO = "https://kkgithub.com/ScoopInstaller/Scoop/archive/master.zip"
$SCOOP_MAIN_BUCKET_REPO = "https://kkgithub.com/ScoopInstaller/Main/archive/master.zip"
$SCOOP_PACKAGE_GIT_REPO = "https://kkgithub.com/ScoopInstaller/Scoop.git"
$SCOOP_MAIN_BUCKET_GIT_REPO = "https://kkgithub.com/ScoopInstaller/Main.git"
.\install.ps1 -ScoopDir "$env:APPS_HOME\_packs" -ScoopGlobalDir "$env:APPS_HOME\_packs" -NoProxy
<#
Patch source code: $APPS_HOME/_packs/apps/scoop/current/lib/install.ps1
function Invoke-CachedDownload ($app, $version, $url, $to, $cookies = $null, $use_cache = $true) {
+    $url = "$url".Replace("https://github.com", "https://kkgithub.com").Replace("https://raw.githubusercontent.com", "https://raw.kkgithub.com")
#>
<# Code patch is not compatible with aria2 #>
scoop config scoop_repo http://kkgithub.com/ScoopInstaller/Scoop
scoop config aria2-enabled false

#.Bucket
<#
The 'extras' is some big, so can clone manually or use mirror github:
    cd $APPS_HOME/_packs/buckets
    git clone --depth 1 https://github.com/ScoopInstaller/Extras.git
#>
scoop bucket add extras https://github.com/ScoopInstaller/Extras.git
scoop bucket add versions https://github.com/ScoopInstaller/Versions.git
scoop bucket add nonportable https://github.com/ScoopInstaller/Nonportable.git
scoop bucket add nerd-fonts https://github.com/matthewjberger/scoop-nerd-fonts.git

#.Add
scoop install neovim neovide nvy vim-nightly vscode -a 64bit
scoop install bat delta fd fzf ripgrep lf universal-ctags
scoop install 7zip cmake ninja
scoop install lua python deno nodejs # Then run apps/python/current/install-pep-514.reg
scoop install conemu wox snipaste everything  screentogif rapidee
scoop install notepadnext honeyview qttabbar-indiff-np
scoop download clink -h
scoop install CodeNewRoman-NF-Mono FantasqueSansMono-NF-Mono -s
scoop install https://raw.githubusercontent.com/daipeihust/im-select/master/bucket/im-select.json

scoop install vulkan renderdoc shadered # Then run apps/vulkan/current/install-vk-layers.ps1
scoop install cuda11.1 # Prefer conda install cudatoolkit cudnn
scoop install llvm portable-virtualbox
scoop install draw.io wpsoffice sioyek
