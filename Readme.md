# RmEDir 

RmEDir is a small command line utility which allows you to recursively delete all empty subdirectories from the specified directory.

By default, the program also deletes empty directories with the Read-only, System and Hidden attributes (on Windows system), but you can disable it with the `--keep-special-dirs` switch.

The program has no built-in file deletion function, **so you can be sure that no file will be deleted by accident**.

RmEDir supports network directories and paths exceeding the [MAX_PATH](https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247%28v=vs.85%29.aspx?f=255&MSPPError=-2147217396#maxpath) (260) character limit.


# Download

Source: https://github.com/jackdp/RmEDir

Binary (Windows 32-bit, Windows 64-bit, Linux 32-bit, Linux 64-bit): http://www.pazera-software.com/products/rmedir/


# Usage

Usage: **rmedir** `[-r=X] [-d] [-k] [-h] [-V] [--home] Directory`

Mandatory arguments to long options are mandatory for short options too.  
Options are **case-sensitive**. Options in square brackets are optional.  
The last parameter must be the name of an existing directory.

Available options:

Switch | Description |
|:---|:---|
| `-r`, `--recurse=X` | Recursively removes empty directories up to level X in the directory structure (default X=500). |
| `-d`, `--remove-main-dir` | It also removes the input directory given on the command line (if empty).
| `-k`, `--keep-special-dirs` | By default, the program deletes empty directories with the *Read-only*, *Hidden* and *System* attributes set. If you want to keep such directories, use this option. Available only in the Windows version. |
| `-h`, `--help` | Show this help. |
| `-V`, `--version` | Show application version. |
| `--home` | Opens program homepage in the default browser. |


# Compilation

To compile, you need:
- [CodeTyphon](http://pilotlogic.com/sitejoom/) or [Lazarus](https://www.lazarus-ide.org/).
- [JPL.CmdLineParser](https://github.com/jackdp/JPL.CmdLineParser) unit.
- JPL.Utils, JPL.Conversion, JPL.FileSearch and JPL.Strings units from [JPLib/Base](https://github.com/jackdp/JPLib/tree/master/Base).

How to build:
1. Open `src\rmedir.ctpr` file with CodeTyphon or `src\rmedir.lpi` with Lazarus.
2. Set build mode for your destination system.  
Select menu `Project -> Project Options...` A new window will appear.
In the tree view (on the left), select `Compiler Options`.
At the top of this window you can select the build mode from the dropdown list.
Choose: `Release Win32`, `Release Win64`, `Release Lin32` or `Release Lin64`.
3. Build project (menu `Run->Build`).


# Releases

2018.01.19 - Version 1.0




