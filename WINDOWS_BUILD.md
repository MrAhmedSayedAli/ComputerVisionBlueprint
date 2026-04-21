# Windows build guide

This repository supports a source build on Windows with **CMake** and **Visual Studio 2022**. The recommended workflow is the PowerShell setup and compile scripts added to the repository.

## Requirements

- Visual Studio 2022 with C++ desktop tooling
- Python 3 on `PATH`
- Git
- CMake

## Recommended workflow

### 1. Setup dependencies

```powershell
.\scripts\setup.ps1
```

`setup.ps1` performs the Windows-specific project bootstrap:

1. Installs **Conan 2.11** and **aqtinstall** with Python.
2. Clones `3rdparty\nodeeditor` if it is missing.
3. Installs **Qt 6.8.3 for MSVC 2022** with the `qtmultimedia` module into `.qt`.
4. Generates Conan outputs for both **Debug** and **Release** under `.conan\Debug` and `.conan\Release`.

### 2. Configure and build

```powershell
.\scripts\compile.ps1 -Type Release -Deploy
```

Useful options:

- `-Type Debug` to build a debug configuration
- `-QtDir <path>` to point at an existing Qt installation instead of `.qt\6.8.3\msvc2022_64`
- `-Clean` to remove the existing `build\vs2022-*` directory before configuring
- `-Deploy` to run `windeployqt` and copy the runtime dependencies next to the executable

### 3. Run

```powershell
.\build\vs2022-release\dist\ComputerVisionBlueprint.exe
```

If you omit `-Deploy`, the compiled executable is located at `build\vs2022-release\Release\ComputerVisionBlueprint.exe`.

## Generated layout

- Qt install root: `.qt\6.8.3\msvc2022_64`
- Conan outputs: `.conan\Debug` and `.conan\Release`
- Visual Studio build folders: `build\vs2022-debug` / `build\vs2022-release`
- Deploy output: `build\vs2022-release\dist\ComputerVisionBlueprint.exe`

## Notes

- `CMakePresets.json` currently defines **Ninja** presets, so the Windows workflow uses the **Visual Studio 17 2022** generator directly through `compile.ps1`.
- The configure step passes `-DCMAKE_POLICY_DEFAULT_CMP0091=NEW`, the Conan toolchain file, the Qt path, and `OpenCV_DIR` so `find_package(OpenCV CONFIG REQUIRED)` resolves correctly on Windows.
- `windeployqt` may warn that `dxcompiler.dll` and `dxil.dll` are not present; that warning did not prevent the application from launching in the documented Windows workflow.
