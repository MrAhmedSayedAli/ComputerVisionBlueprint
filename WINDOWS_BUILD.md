# Windows build notes

This repository can be built on Windows with **CMake** and **Visual Studio 2022**, but I had to add a few pieces that are not present in a fresh checkout.

## What I had to do

1. Clone `3rdparty\nodeeditor`, because the project expects it to exist locally.
2. Install **Conan 2.11** and **aqtinstall** with Python.
3. Install **Qt 6.8.3 for MSVC 2022** with the `qtmultimedia` module into a local `.qt` directory.
4. Run Conan for **Debug** and **Release** so it generates `.conan\Debug` and `.conan\Release`, including `OpenCVConfig.cmake` and `conan_toolchain.cmake`.
5. Configure CMake with the **Visual Studio 17 2022** generator instead of the Ninja presets in `CMakePresets.json`.
6. Pass the Conan toolchain and generated package directory explicitly so `find_package(OpenCV CONFIG REQUIRED)` resolves on Windows.
7. Build the project and then run `windeployqt` so the executable can run outside a custom PATH setup.

## Working Windows layout

- Qt install root: `.qt\6.8.3\msvc2022_64`
- Conan outputs: `.conan\Debug` and `.conan\Release`
- Visual Studio build folder: `build\vs2022-release`
- Runnable packaged app: `build\vs2022-release\dist\ComputerVisionBlueprint.exe`

## Working commands

### Setup

```powershell
.\scripts\setup.ps1
```

### Build

```powershell
.\scripts\compile.ps1 -Type Release -Deploy
```

### Run

```powershell
.\build\vs2022-release\dist\ComputerVisionBlueprint.exe
```

## Notes

- The current `CMakePresets.json` uses the **Ninja** generator, so I did not use it for the Windows Visual Studio workflow.
- The successful configure step needed `-DCMAKE_POLICY_DEFAULT_CMP0091=NEW` together with the Conan toolchain.
- `windeployqt` warned that `dxcompiler.dll` and `dxil.dll` were not found, but the application still launched successfully.
