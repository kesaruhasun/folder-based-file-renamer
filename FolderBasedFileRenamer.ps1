# =========================================================================
# File: FolderBasedFileRenamer.ps1
# Description: Renames files by adding parent folder name as prefix/suffix
# Author: IT24102576
# Date: 2025-04-16
# =========================================================================

# Script parameters for command-line configuration
param(
    [string]$ParentFolderPath = "",
    [string]$Separator = "-",
    [switch]$UsePrefix = $true,
    [switch]$UseSuffix = $false,
    [string]$ConfigFile = "config.json"
)

# Function to load configuration from JSON file
function Load-Configuration {
    param (
        [string]$ConfigFilePath
    )
    
    # Default configuration
    $config = @{
        separator = $Separator
        usePrefix = $UsePrefix.IsPresent
        useSuffix = $UseSuffix.IsPresent
        parentFolderPath = $ParentFolderPath
        excludeFolders = @()
        excludeFiles = @()
    }
    
    # Check if config file exists
    if (Test-Path -Path $ConfigFilePath) {
        try {
            $fileConfig = Get-Content -Path $ConfigFilePath -Raw | ConvertFrom-Json
            
            # Update configuration from file
            if ($null -ne $fileConfig.separator) { $config.separator = $fileConfig.separator }
            if ($null -ne $fileConfig.usePrefix) { $config.usePrefix = [bool]$fileConfig.usePrefix }
            if ($null -ne $fileConfig.useSuffix) { $config.useSuffix = [bool]$fileConfig.useSuffix }
            if ($null -ne $fileConfig.parentFolderPath) { $config.parentFolderPath = $fileConfig.parentFolderPath }
            if ($null -ne $fileConfig.excludeFolders) { $config.excludeFolders = $fileConfig.excludeFolders }
            if ($null -ne $fileConfig.excludeFiles) { $config.excludeFiles = $fileConfig.excludeFiles }
            
            Write-Host "Configuration loaded from $ConfigFilePath"
        }
        catch {
            Write-Host "Error reading configuration file: $_"
            Write-Host "Using default configuration"
        }
    }
    else {
        Write-Host "Configuration file not found. Using default or command-line configuration."
    }
    
    # Command-line parameters override config file
    if ($ParentFolderPath -ne "") { $config.parentFolderPath = $ParentFolderPath }
    if ($PSBoundParameters.ContainsKey('Separator')) { $config.separator = $Separator }
    if ($PSBoundParameters.ContainsKey('UsePrefix')) { $config.usePrefix = $UsePrefix.IsPresent }
    if ($PSBoundParameters.ContainsKey('UseSuffix')) { $config.useSuffix = $UseSuffix.IsPresent }
    
    # Validate configuration
    if ($config.usePrefix -eq $false -and $config.useSuffix -eq $false) {
        Write-Host "Warning: Both UsePrefix and UseSuffix are set to false. Setting UsePrefix to true."
        $config.usePrefix = $true
    }
    
    return $config
}

# Function to clean duplicate prefixes or suffixes
function Clean-DuplicateAffixes {
    param (
        [string]$folderPath,
        [string]$folderName,
        [string]$separator,
        [bool]$usePrefix,
        [bool]$useSuffix
    )
    
    $files = Get-ChildItem -Path $folderPath -File
    $count = 0
    
    foreach ($file in $files) {
        $extension = $file.Extension
        $currentName = $file.BaseName
        $patternChanged = $false
        
        # Check for duplicate prefixes
        if ($usePrefix -and ($currentName -match "^($folderName$separator)+.*")) {
            # Extract the actual filename part (after all prefixes)
            $parts = $currentName -split [regex]::Escape($separator), 2
            if ($parts.Count -gt 1) {
                $actualFileName = $parts[1]
                # Create proper name with just one prefix
                $properName = "$folderName$separator$actualFileName$extension"
                Write-Host "Fixing duplicate prefixes: $($file.Name) -> $properName"
                Rename-Item -Path $file.FullName -NewName $properName -Force
                $count++
                $patternChanged = $true
            }
        }
        
        # Check for duplicate suffixes if not already fixed
        if (-not $patternChanged -and $useSuffix -and ($currentName -match ".*($separator$folderName)+$")) {
            # Extract the actual filename part (before all suffixes)
            $parts = $currentName -split [regex]::Escape($separator), 2
            if ($parts.Count -gt 1) {
                $actualFileName = $parts[0]
                # Create proper name with just one suffix
                $properName = "$actualFileName$separator$folderName$extension"
                Write-Host "Fixing duplicate suffixes: $($file.Name) -> $properName"
                Rename-Item -Path $file.FullName -NewName $properName -Force
                $count++
            }
        }
    }
    
    if ($count -gt 0) {
        Write-Host "Fixed $count files with duplicate prefixes/suffixes in $folderName"
    }
}

# Function to check if file should be excluded
function Should-ExcludeFile {
    param (
        [System.IO.FileInfo]$file,
        [array]$excludePatterns
    )
    
    foreach ($pattern in $excludePatterns) {
        if ($file.Name -like $pattern) {
            return $true
        }
    }
    return $false
}

# Main function
function Rename-FilesWithFolderName {
    param (
        [hashtable]$config
    )
    
    # Get the directory to process
    $parentFolder = ""
    
    if ([string]::IsNullOrEmpty($config.parentFolderPath)) {
        # Get the directory where the script is located and use its parent directory
        $scriptLocation = Split-Path -Parent $MyInvocation.MyCommand.Path
        $parentFolder = $scriptLocation
    }
    else {
        $parentFolder = $config.parentFolderPath
    }
    
    # Display the detected parent folder for verification
    Write-Host "Using parent folder: $parentFolder"
    
    # Check if the parent folder exists
    if (-not (Test-Path -Path $parentFolder -PathType Container)) {
        Write-Host "Error: Parent folder does not exist."
        return
    }
    
    # Get all subdirectories from the parent folder
    $subFolders = Get-ChildItem -Path $parentFolder -Directory
    
    # Filter out excluded folders
    if ($config.excludeFolders.Count -gt 0) {
        $subFolders = $subFolders | Where-Object { $folderName = $_.Name; -not ($config.excludeFolders | Where-Object { $folderName -like $_ }) }
    }
    
    Write-Host "Found $($subFolders.Count) folders to process."
    
    # Count variables for reporting
    $totalFolders = 0
    $totalFiles = 0
    $totalRenamed = 0
    $totalSkipped = 0
    
    # Loop through each subfolder we found
    foreach ($folder in $subFolders) {
        # Extract the current folder name
        $folderName = $folder.Name
        
        # Get the full path to the current folder
        $folderPath = $folder.FullName
        
        Write-Host "Processing folder: $folderName..."
        
        # First, fix any files with duplicate prefixes/suffixes
        Clean-DuplicateAffixes -folderPath $folderPath -folderName $folderName -separator $config.separator -usePrefix $config.usePrefix -useSuffix $config.useSuffix
        
        # Get all files in the current folder
        $files = Get-ChildItem -Path $folderPath -File
        
        # Filter out excluded files
        if ($config.excludeFiles.Count -gt 0) {
            $files = $files | Where-Object { -not (Should-ExcludeFile -file $_ -excludePatterns $config.excludeFiles) }
        }
        
        $filesRenamed = 0
        $filesSkipped = 0
        
        # Loop through each file in the current folder
        foreach ($file in $files) {
            # Get the file extension (including the dot, e.g., ".txt")
            $extension = $file.Extension
            
            # Get the filename without the extension (e.g., "document" from "document.txt")
            $fileNameWithoutExtension = $file.BaseName
            
            # Create the new file name based on config
            $newName = ""
            if ($config.usePrefix) {
                $newName = "$folderName$($config.separator)$fileNameWithoutExtension$extension"
                $alreadyFormatted = $fileNameWithoutExtension.StartsWith("$folderName$($config.separator)")
            }
            elseif ($config.useSuffix) {
                $newName = "$fileNameWithoutExtension$($config.separator)$folderName$extension"
                $alreadyFormatted = $fileNameWithoutExtension.EndsWith("$($config.separator)$folderName")
            }
            
            # Check if the file is already properly named to avoid renaming files multiple times
            if (-not $alreadyFormatted) {
                # Rename the file with the new name
                Write-Host "  Renaming $($file.Name) to $newName"
                Rename-Item -Path $file.FullName -NewName $newName -Force
                $filesRenamed++
                $totalRenamed++
            }
            else {
                # File already has the correct format
                $filesSkipped++
                $totalSkipped++
            }
        }
        
        $totalFolders++
        $totalFiles += $files.Count
        
        Write-Host "  - Renamed $filesRenamed files in $folderName"
        Write-Host "  - Skipped $filesSkipped files (already have correct format)"
        Write-Host "  - Finished processing $folderName"
        Write-Host ""
    }
    
    # Display summary
    Write-Host "========== SUMMARY ==========="
    Write-Host "Processed $totalFolders folders"
    Write-Host "Found $totalFiles total files"
    Write-Host "Renamed $totalRenamed files"
    Write-Host "Skipped $totalSkipped files (already had correct format)"
    Write-Host "Script completed successfully at $(Get-Date)"
}

# Check for cross-platform compatibility
if ($PSVersionTable.PSEdition -eq "Core") {
    Write-Host "Running on PowerShell Core (Cross-platform)"
}
else {
    Write-Host "Running on Windows PowerShell"
}

# Load configuration
$configPath = Join-Path -Path (Split-Path -Parent $MyInvocation.MyCommand.Path) -ChildPath $ConfigFile
$config = Load-Configuration -ConfigFilePath $configPath

# Execute the main function
Rename-FilesWithFolderName -config $config