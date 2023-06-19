
# Get install.ps1 from https://github.com/ScoopInstaller/Install/blob/master/install.ps1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh -outfile 'install.ps1'

# Patch repos
$SCOOP_PACKAGE_REPO = "https://kgithub.com/ScoopInstaller/Scoop/archive/master.zip"
$SCOOP_MAIN_BUCKET_REPO = "https://kgithub.com/ScoopInstaller/Main/archive/master.zip"
$SCOOP_PACKAGE_GIT_REPO = "https://kgithub.com/ScoopInstaller/Scoop.git"
$SCOOP_MAIN_BUCKET_GIT_REPO = "https://kgithub.com/ScoopInstaller/Main.git"

# Install scoop (Unlock install.ps1 from attributes. How stupid!)
.\install.ps1 -ScoopDir 'C:\apps\_packs' -ScoopGlobalDir 'C:\apps\_packs' -NoProxy
.\install.ps1 -ScoopDir "$env:APPS_HOME\_packs" -ScoopGlobalDir "$env:APPS_HOME\_packs" -NoProxy

# Patch scoop
# $APPS_HOME/_packs/apps/scoop/current/lib/install.ps1
# $APPS_HOME/_packs/apps/scoop/current/libexec/scoop-download.ps1
#   => before invoking Invoke-CachedDownload
+$url_patch = "$url".Replace("https://github.com", "https://kgithub.com").Replace("https://raw.githubusercontent.com", "https://raw.kgithub.com")
-Invoke-CachedDownload $app $version $url "$dir\$fname" $cookies $use_cache
+Invoke-CachedDownload $app $version $url_patch "$dir\$fname" $cookies $use_cache

# Config scoop
scoop config scoop_repo http://kgithub.com/ScoopInstaller/Scoop
scoop config aria2-enabled false

# Add buckets
# 'extras' is some big, so can clone manually
# cd $APPS_HOME/_packs/buckets
# git clone --depth 1 https://kgithub.com/ScoopInstaller/Extras.git
scoop bucket add extras https://kgithub.com/ScoopInstaller/Extras.git
scoop bucket add nonportable https://kgithub.com/ScoopInstaller/Nonportable.git
scoop bucket add nerd-fonts https://kgithub.com/matthewjberger/scoop-nerd-fonts.git

# Add packs
scoop install bat fd fzf ripgrep lf universal-ctags 7zip cmake ninja
scoop install neovim neovide vim
scoop install llvm lua python deno nodejs vulkan
scoop install https://raw.githubusercontent.com/daipeihust/im-select/master/bucket/im-select.json
scoop install conemu wox snipaste everything  screentogif rapidee
scoop install notepadnext honeyview qttabbar-indiff-np
scoop download clink -h
scoop install renderdoc shadered draw.io wpsoffice
# need vertions: scoop install cuda11.1
scoop install Agave-NF-Mono CascadiaCode-NF-Mono FantasqueSansMono-NF-Mono -s
