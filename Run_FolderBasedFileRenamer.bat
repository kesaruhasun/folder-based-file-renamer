@echo off
echo Running Folder-Based File Renamer...
echo.

powershell.exe -ExecutionPolicy Bypass -File "%~dp0FolderBasedFileRenamer.ps1"

echo.
echo Script execution completed.
pause