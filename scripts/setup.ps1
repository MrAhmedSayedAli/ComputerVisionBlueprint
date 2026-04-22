param(
    [string]$QtVersion = "6.8.3",
    [string]$QtArch = "win64_msvc2022_64",
    [string]$QtInstallRoot = ".qt",
    [string]$ConanVersion = "2.11",
    [string]$NodeEditorRepo = "https://github.com/paceholder/nodeeditor.git"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptDir "..")).Path
Set-Location $repoRoot

function Add-UserPythonScriptsToPath {
    $pythonVersionDir = python -c "import sys; print(f'Python{sys.version_info.major}{sys.version_info.minor}')"
    $scriptsDir = Join-Path $env:APPDATA "Python\$pythonVersionDir\Scripts"

    if (Test-Path $scriptsDir) {
        $pathEntries = $env:Path -split ";"
        if ($scriptsDir -notin $pathEntries) {
            $env:Path = "$scriptsDir;$env:Path"
        }
    }

    return $scriptsDir
}

function Get-QtFolderName {
    param([string]$Arch)

    switch ($Arch) {
        "win64_msvc2022_64" { return "msvc2022_64" }
        "win64_msvc2022_arm64_cross_compiled" { return "msvc2022_arm64_cross_compiled" }
        default { return ($Arch -replace "^win64_", "") }
    }
}

Write-Host "Installing Python tooling..."
python -m pip install --user --upgrade pip
python -m pip install --user --disable-pip-version-check "conan==$ConanVersion" aqtinstall

$userScriptsDir = Add-UserPythonScriptsToPath
$conan = (Get-Command conan -ErrorAction Stop).Source
$aqt = (Get-Command aqt -ErrorAction Stop).Source

Write-Host "Detecting Conan profile..."
& $conan profile detect --force

if (-not (Test-Path "3rdparty")) {
    New-Item -ItemType Directory -Path "3rdparty" | Out-Null
}

if (-not (Test-Path "3rdparty\nodeeditor")) {
    Write-Host "Cloning nodeeditor..."
    git clone --depth 1 $NodeEditorRepo "3rdparty\nodeeditor"
}
else {
    Write-Host "nodeeditor already present. Skipping clone."
}

$qtFolderName = Get-QtFolderName -Arch $QtArch
$qtDir = Join-Path $QtInstallRoot "$QtVersion\$qtFolderName"
$qmakePath = Join-Path $qtDir "bin\qmake.exe"

if (-not (Test-Path $qmakePath)) {
    Write-Host "Installing Qt $QtVersion ($QtArch)..."
    & $aqt install-qt windows desktop $QtVersion $QtArch -m qtmultimedia -O $QtInstallRoot
}
else {
    Write-Host "Qt already present at $qtDir. Skipping Qt install."
}

Write-Host "Installing Conan dependencies for Debug..."
& $conan install . --output-folder=.conan\Debug --build=missing --settings=build_type=Debug

Write-Host "Installing Conan dependencies for Release..."
& $conan install . --output-folder=.conan\Release --build=missing --settings=build_type=Release

Write-Host ""
Write-Host "Setup complete."
Write-Host "Qt directory: $((Resolve-Path $qtDir).Path)"
Write-Host "Python user scripts: $userScriptsDir"
