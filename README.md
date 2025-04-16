# Folder-Based File Renamer

> Automatically rename files by adding parent folder names as prefix or suffix

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](https://github.com/PowerShell/PowerShell)

A flexible PowerShell tool that renames files based on their parent folder names. Perfect for organizing files from multiple projects, clients, or categories with consistent naming patterns.

## Overview

This tool automatically renames files within subfolders by adding the parent folder name as a prefix or suffix to each filename. It's useful for organizing files from multiple sources, projects, clients, or categories.

## Features

- **Prefix or Suffix Mode**: Add folder names to the beginning or end of filenames
- **Configurable Separator**: Choose any character(s) to separate folder names from filenames
- **Duplicate Prevention**: Intelligently detects and fixes files with duplicate prefixes/suffixes
- **File & Folder Exclusions**: Skip specific folders or file patterns from processing
- **Configuration Flexibility**: Use command-line parameters or JSON configuration
- **Detailed Logging**: Shows actions taken for each file and folder
- **Cross-Platform Support**: Works with Windows PowerShell and PowerShell Core

## Folder Structure Examples

**Before:**
```
ParentFolder/
├── ClientA/
│   ├── document.pdf
│   └── spreadsheet.xlsx
├── Project2023/
│   ├── report.xlsx
│   └── presentation.pptx
├── Summer2022/
│   ├── photo1.jpg
│   └── photo2.jpg
```

**After (With Prefix):**
```
ParentFolder/
├── ClientA/
│   ├── ClientA-document.pdf
│   └── ClientA-spreadsheet.xlsx
├── Project2023/
│   ├── Project2023-report.xlsx
│   └── Project2023-presentation.pptx
├── Summer2022/
│   ├── Summer2022-photo1.jpg
│   └── Summer2022-photo2.jpg
```

**After (With Suffix):**
```
ParentFolder/
├── ClientA/
│   ├── document-ClientA.pdf
│   └── spreadsheet-ClientA.xlsx
├── Project2023/
│   ├── report-Project2023.xlsx
│   └── presentation-Project2023.pptx
├── Summer2022/
│   ├── photo1-Summer2022.jpg
│   └── photo2-Summer2022.jpg
```

## Use Cases

### Web Development
Organize assets from multiple websites by prefixing files with domain names.
```
Websites/
├── example.com/
│   ├── example.com-logo.png
│   └── example.com-header.jpg
├── client-site.org/
│   ├── client-site.org-banner.png
│   └── client-site.org-favicon.ico
```

### Client Work
Keep client files organized by adding client names as prefixes.
```
Clients/
├── Acme_Corp/
│   ├── Acme_Corp-contract.pdf
│   └── Acme_Corp-proposal.docx
├── GlobalTech/
│   ├── GlobalTech-invoice.pdf
│   └── GlobalTech-specs.xlsx
```

### Project Management
Add project codes to filenames for easier tracking.
```
Projects/
├── PRJ001/
│   ├── PRJ001-timeline.xlsx
│   └── PRJ001-budget.xlsx
├── PRJ002/
│   ├── PRJ002-requirements.docx
│   └── PRJ002-mockups.pdf
```

### Photo Organization
Organize photos by event names or locations.
```
Photos/
├── Beach_Vacation/
│   ├── Beach_Vacation-sunset.jpg
│   └── Beach_Vacation-family.jpg
├── NYC_Trip/
│   ├── NYC_Trip-skyline.jpg
│   └── NYC_Trip-central_park.jpg
```

## Installation

1. Clone this repository or download the ZIP file
2. Extract files to your desired location
3. Ensure PowerShell execution policy allows script execution

## Usage

### Method 1: Using the Batch File

1. Double-click `Run_FolderBasedFileRenamer.bat`
2. The script will execute with default settings (or from config.json if present)
3. A PowerShell window will open showing progress
4. When complete, press any key to close the window

### Method 2: Running PowerShell Script Directly

1. Open PowerShell
2. Navigate to the script directory: `cd path\to\script`
3. Run the script with desired parameters:
   ```powershell
   .\FolderBasedFileRenamer.ps1
   ```

## Configuration

The tool can be customized using command-line parameters or a configuration file.

### Command-Line Parameters

- `-ParentFolderPath`: Specify a custom parent folder path
- `-Separator`: Character(s) to use between folder name and filename (default: "-")
- `-UsePrefix`: Add folder name at the beginning of filenames (default: true)
- `-UseSuffix`: Add folder name at the end of filenames (default: false)
- `-ConfigFile`: Specify custom config file path (default: "config.json")

Example:
```powershell
.\FolderBasedFileRenamer.ps1 -Separator "_" -UseSuffix $true -UsePrefix $false
```

### Configuration File

Create a `config.json` file in the same directory as the script:

```json
{
    "separator": "_",
    "usePrefix": false,
    "useSuffix": true,
    "parentFolderPath": "C:\\Users\\Username\\Documents\\MyProjects",
    "excludeFolders": ["backup", "temp", "logs"],
    "excludeFiles": ["*.tmp", "*.bak", "Thumbs.db", ".DS_Store"]
}
```

#### Configuration Options

- `separator`: Character(s) to use between folder name and filename (string)
- `usePrefix`: Add folder name at the beginning of filenames (boolean)
- `useSuffix`: Add folder name at the end of filenames (boolean)
- `parentFolderPath`: Path to the parent folder containing subfolders (string)
- `excludeFolders`: Array of folder names or patterns to exclude (array of strings)
- `excludeFiles`: Array of file patterns to exclude (array of strings)

## Requirements

- Windows PowerShell 5.1+ or PowerShell Core 6.0+ (for cross-platform support)
- File write permissions in the target folders

## File Structure

```
folder-based-file-renamer/
├── FolderBasedFileRenamer.ps1  - Main PowerShell script
├── Run_FolderBasedFileRenamer.bat - Batch file for easy execution
├── config.json                 - Configuration file
├── README.md                   - Documentation
├── LICENSE                     - MIT License
└── samples/                    - Example configurations
    ├── prefix_config.json      - Example prefix configuration
    ├── suffix_config.json      - Example suffix configuration
    └── exclude_config.json     - Example with exclusions
```

## Samples

The `samples` directory contains example configurations for different use cases:

- `prefix_config.json`: Standard configuration using prefixes
- `suffix_config.json`: Alternative configuration using suffixes
- `exclude_config.json`: Configuration with file and folder exclusions

## Troubleshooting

### Common Issues:

1. **"Cannot be loaded because running scripts is disabled"**
   - Solution: Use the batch file instead, which bypasses execution policy restrictions
   - Or run PowerShell as administrator and execute: `Set-ExecutionPolicy RemoteSigned`

2. **Files aren't being renamed**
   - Check that the script is placed in the correct parent folder
   - Verify that files don't already have the folder prefix/suffix
   - Check if files match any exclusion patterns in config

3. **Some files have multiple prefixes/suffixes**
   - Run the script again; the clean-up function will fix duplicate affixes

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

```
MIT License

Copyright (c) 2025 IT24102576

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

*Documentation last updated: 2025-04-16*