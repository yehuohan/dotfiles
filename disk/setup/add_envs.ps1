
### DOT_HOME and DOT_APPS
# $dot_home = (Get-ItemProperty -Path Registry::HKEY_CURRENT_USER\Environment -Name DOT_HOME).DOT_HOME
# $dot_home = Get-ItemPropertyValue -Path HKCU:\Environment -Name DOT_HOME
# $dot_apps = Get-ItemPropertyValue -Path HKCU:\Environment -Name DOT_APPS
# if ($dot_home) { echo $dot_home }
# if ($dot_apps) { echo $dot_apps }

### Add DOT_HOME and DOT_APPS
$dot_home = 'D:'
$dot_apps = 'C:\apps'

### Add android
# $android_home = 'D:\Android\SDK'

### Setup Rust
$rustup_home = "$dot_apps\rust\rustup"
$cargo_home = "$dot_apps\rust\cargo"

# miniconda3, miniconda3/Scripts, miniconda3/Library/bin 应该放在DOT_PATH之前，防止msys64拦截miniconda3的python
$vars = @(
    @{ Name = 'DOT_HOME'; Value = $dot_home; },
    @{ Name = 'DOT_APPS'; Value = $dot_apps; },
    @{
        Name = 'DOT_PATH';
        Value = (
            "$dot_apps\msys64\usr\bin",
            "$dot_apps\msys64\ucrt64\bin",
            "$rustup_home\toolchains\stable-x86_64-pc-windows-msvc\bin",
            "$cargo_home\bin",
            "$dot_apps\vcpkg"
        ) -join ';';
    },
    @{
        Name = 'RUSTUP_DIST_SERVER';
        Value = 'https://mirrors.tuna.tsinghua.edu.cn/rustup';
        # Value = 'https://mirrors.ustc.edu.cn/rust-static';
    },
    @{
        Name = 'RUSTUP_UPDATE_ROOT';
        Value = 'https://mirrors.tuna.tsinghua.edu.cn/rustup/rustup';
        # Value = 'https://mirrors.ustc.edu.cn/rust-static/rustup';
    },
    @{ Name = 'RUSTUP_HOME'; Value = $rustup_home; },
    @{ Name = 'CARGO_HOME'; Value = $cargo_home; },
    @{ Name = 'VCPKG_DEFAULT_BINARY_CACHE'; Value = "$dot_apps\vcpkg\archives"; }
)
if ($android_home) {
    $vars = $vars + @(
        @{ Name = 'ANDROID_HOME'; Value = $android_home },
        @{
            Name = 'ANDROID_PATH';
            Value = @(
                "$android_home\ndk-bundle",
                "$android_home\emulator",
                "$android_home\platform-tools"
            ) -join ';';
        },
        @{ Name = 'GRADLE_USER_HOME'; Value = "$android_home\.gradle"}
    )
}
$prop = @{
    Path = 'HKCU:\Environment';
    PropertyType = 'String';
    Force = $true;
}

foreach ($var in $vars) {
    $item = $var + $prop
    # echo $item
    New-ItemProperty @item
}

pause
