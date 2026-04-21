param(
    [ValidateSet("Debug", "Release")]
    [string]$Type = "Release",
    [string]$QtDir = "",
    [switch]$Deploy,
    [switch]$Clean
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = (Resolve-Path (Join-Path $scriptDir "..")).Path
Set-Location $repoRoot

if (-not $QtDir) {
    $defaultQtDir = ".qt\6.8.3\msvc2022_64"
    if (Test-Path (Join-Path $defaultQtDir "bin\qmake.exe")) {
        $QtDir = $defaultQtDir
    }
}

if (-not $QtDir) {
    throw "Qt directory not provided and the default local Qt installation was not found. Use -QtDir <path>."
}

$qtDirPath = (Resolve-Path $QtDir).Path
$lowerType = $Type.ToLowerInvariant()
$buildDir = "build\vs2022-$lowerType"
$conanDir = ".conan\$Type"
$toolchainPath = (Resolve-Path (Join-Path $conanDir "conan_toolchain.cmake")).Path
$conanConfigDir = (Resolve-Path $conanDir).Path

if ($Clean -and (Test-Path $buildDir)) {
    Remove-Item $buildDir -Recurse -Force
}

Write-Host "Configuring $Type build..."
& cmake `
    -S . `
    -B $buildDir `
    -G "Visual Studio 17 2022" `
    -A x64 `
    "-DCMAKE_POLICY_DEFAULT_CMP0091=NEW" `
    "-DCMAKE_TOOLCHAIN_FILE=$toolchainPath" `
    "-DCMAKE_PREFIX_PATH=$qtDirPath;$conanConfigDir" `
    "-DOpenCV_DIR=$conanConfigDir"

Write-Host "Building $Type..."
& cmake --build $buildDir --config $Type --parallel

if ($Deploy) {
    $exePath = (Resolve-Path (Join-Path $buildDir "$Type\ComputerVisionBlueprint.exe")).Path
    $qtNodesDll = (Resolve-Path (Join-Path $buildDir "bin\$Type\QtNodes.dll")).Path
    $distDir = Join-Path $buildDir "dist"
    $windeployqt = (Resolve-Path (Join-Path $qtDirPath "bin\windeployqt.exe")).Path

    if (Test-Path $distDir) {
        Remove-Item $distDir -Recurse -Force
    }

    New-Item -ItemType Directory -Path $distDir | Out-Null
    Copy-Item $exePath $distDir
    Copy-Item $qtNodesDll $distDir

    $deployArgs = @("--compiler-runtime", "--dir", $distDir)
    if ($Type -eq "Release") {
        $deployArgs = @("--release") + $deployArgs
    }
    else {
        $deployArgs = @("--debug") + $deployArgs
    }

    Write-Host "Deploying Qt runtime to $distDir..."
    & $windeployqt @deployArgs (Join-Path $distDir "ComputerVisionBlueprint.exe")
}

Write-Host ""
Write-Host "Build complete."
Write-Host "Build directory: $((Resolve-Path $buildDir).Path)"
if ($Deploy) {
    Write-Host "Runnable application: $((Resolve-Path (Join-Path $buildDir "dist\ComputerVisionBlueprint.exe")).Path)"
}
