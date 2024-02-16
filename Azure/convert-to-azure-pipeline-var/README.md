# 🚀 Azure DevOps Variables Importer 🚀

## Overview
This PowerShell script (`Convert-ToAzurePipelineVar.ps1`) is designed to streamline the process of converting JSON configuration files into Azure DevOps pipeline variables. It caters to a range of functionalities from parsing JSON files, prompting for variable security, to committing these variables directly to Azure DevOps, and optionally outputting to files for review or documentation purposes.

## Features
- 📁 **JSON File Parsing:** Converts JSON file contents into a structured format.
- 🔐 **Security Prompting:** Interactively asks whether variables should be marked as secure.
- ☁ **Azure DevOps Committing:** Optionally commits variables to a specified Azure DevOps project and pipeline.
- 📝 **Output to Files:** Can output the variables list to JSON file for documentation.
- 🛠 **Flexible Configuration:** Supports various parameters for customized operation.

## Prerequisites
- PowerShell 5.1 or higher.
- Azure CLI for committing variables to Azure DevOps (if used).
- Appropriate permissions to manage Azure DevOps project and pipeline variables.

## Parameters

| Alias | Parameter       | Description                                                            | Mandatory |
|-------|-----------------|------------------------------------------------------------------------|-----------|
| `-f`  | `JsonFilePath`  | Path to the JSON file to be parsed.                                    | No        |
| `-c`  | `CommitToAzure` | Commits the variables to Azure DevOps if specified.                    | No        |
| `-u`  | `UnsecureValues`| Treats all variables as unsecure, skipping the security prompt.        | No        |
| `-p`  | `VSOProject`    | The Azure DevOps project name for committing variables.                | No        |
| `-pl` | `VSOPipeLine`   | The Azure DevOps pipeline name within the project for committing.      | No        |
| `-h`  | `ShowHelp`      | Shows help information and exits.                                      | No        |
| `-o`  | `OutputToFile`  | Outputs the variables list to a file in the "./examples" directory.    | No        |

## Usage

### Secure Variables
To interactively prompt for the security status of each variable, simply run without the `-u` flag. The script will prompt for each variable:

```powershell
.\Convert-ToAzurePipelineVar.ps1 -f "./path/to/secure-config.json"
```
### Commit to Azure DevOps
To directly commit the variables to a specific Azure DevOps project and pipeline, use the -c flag along with -P for the project and -p for the pipeline:
```powershell
.\Convert-ToAzurePipelineVar.ps1 -f "./path/to/azure-config.json" -c -p "YourProject" -pl "YourPipeline"
```

### Output to Files
To output the variables list to files without committing them to Azure DevOps, include the -o flag:
```powershell
.\Convert-ToAzurePipelineVar.ps1 -f "./path/to/file.json" -o
```
### Displaying Help Information
To display detailed help information about the script and its parameters, use the -h flag:
```powershell
.\Convert-ToAzurePipelineVar.ps1 -h
```

### Basic Conversion:
Convert and print variables from config.json:
```powershell
.\Convert-ToAzurePipelineVar.ps1 -f "config.json"
```

### Skip Security Prompt:
Treat all variables as unsecure from unsecure-config.json and skip the security prompt:
```powershell
.\Convert-ToAzurePipelineVar.ps1 -f "unsecure-config.json" -u
```

### Contributing
Contributions are welcome! Please submit a pull request or open an issue to discuss proposed changes or additions.

### License
This project is licensed under [INSERT LICENSE HERE]. See the LICENSE file for details.
