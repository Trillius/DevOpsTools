<#
.SYNOPSIS
Converts JSON to Azure DevOps pipeline variables, optionally commits them to Azure.

.DESCRIPTION
Reads a JSON file, parses it, and converts properties into Azure DevOps pipeline variables. Supports marking variables as secure, committing them to Azure, and outputting variables to files. Handles nested objects and arrays, creating structured variable paths.

.PARAMETER f
Path to the JSON file. If omitted, the script doesn't proceed with conversion.

.PARAMETER c
If set, commits generated variables to Azure DevOps using Azure CLI. Otherwise, prints variables to console.

.PARAMETER u
Treats all variables as unsecure. If omitted, prompts for each variable's security.

.PARAMETER P
Azure DevOps project name for committing variables. Required if -c is set.

.PARAMETER p
Azure DevOps pipeline name for committing variables. Required if -c is set.

.PARAMETER h
Shows this help message and exits, providing script usage and parameter details.

.PARAMETER o
Outputs variables to JSON and text files in ".\examples\" directory if set.

.EXAMPLE
PS> .\convert-to-azure-pipeline-var.ps1 -f './path/to/file.json' -c -p 'MyProject' -pl 'MyPipeline'

Reads './path/to/file.json', prompts for secrets, and commits them to the specified Azure DevOps project and pipeline.

.EXAMPLE
PS> .\convert-to-azure-var.ps1 -f './path/to/file.json' -o

Reads './path/to/file.json', prompts for secrets, and outputs variables to files without committing to Azure DevOps.

.EXAMPLE
PS> .\convert-to-azure-var.ps1 -f "C:\config\settings.json"

This command reads the JSON file located at "C:\config\settings.json", prompts the user to specify if each variable is a secret, and prints the variable details to the console without committing them to Azure DevOps.

.EXAMPLE
PS> .\convert-to-azure-var.ps1 -f "C:\config\settings.json" -u

Reads the JSON file from "C:\config\settings.json" and treats all variables as unsecured. It then prints all variable details to the console, bypassing the prompt for marking variables as secret.

.EXAMPLE
PS> .\convert-to-azure-var.ps1 -f "C:\config\settings.json" -c -p "ProjectName" -pl "PipelineName"

Loads variables from "C:\config\settings.json", prompts for secret designation, and commits them to the specified Azure DevOps project and pipeline. This usage is essential for updating or creating pipeline variables based on the JSON configuration.

.EXAMPLE
PS> .\convert-to-azure-var.ps1 -h

.NOTES
- Azure CLI required for committing to Azure DevOps.
- Ensure permission to modify pipeline variables in the specified Azure project and pipeline.

#>

param (
    [Parameter(Mandatory = $false)]
    [Alias('f', 'file')]
    [string]$JsonFilePath,
            
    [Parameter(Mandatory = $false)]
    [Alias('c', 'commit')]
    [switch]$CommitToAzure,

    [Parameter(Mandatory = $false)]
    [Alias('u', 'unsecure')]
    [switch]$UnsecureValues,
    
    [Parameter(Mandatory = $false)]
    [Alias('p', 'project')]
    [string]$VSOProject = "",
   
    [Parameter(Mandatory = $false)]
    [Alias('pl', 'pipeline')]
    [int]$VSOPipeLine,

    [Parameter(Mandatory = $false)]
    [Alias('h')]
    [switch]$ShowHelp,

    [Parameter(Mandatory = $false)]
    [Alias('o')]
    [switch]$OutputToFile

)

$tempVariables = @{}
            
function Convert-JsonToAzureVariables {
    param (
        [pscustomobject]$JsonObject,
        [string]$ParentPath = '',
        [int]$ArrayIndex = $null
    )     
    foreach ($prop in $JsonObject.PSObject.Properties) {
        if ($ParentPath -ne '') {
            $currentPath = "$ParentPath.$($prop.Name)"
        }
        else {
            $currentPath = $prop.Name
        }
        if ($prop.Value -is [array]) {
            for ($i = 0; $i -lt $prop.Value.Count; $i++) {
                $elementPath = "${currentPath}[$i]"
                Convert-JsonToAzureVariables -JsonObject $prop.Value[$i] -ParentPath $elementPath
            }
        }
        elseif ($prop.Value -is [pscustomobject]) {
            Convert-JsonToAzureVariables -JsonObject $prop.Value -ParentPath $currentPath
        }
        else {
            if (!$UnsecureValues) {
                $promptMessage = "Is the variable'$($prop.Name)' with value '$($prop.Value)' a secret? (Y/N)"
                $isSecure = Read-Host -Prompt $promptMessage
                $secret = ($isSecure -eq 'Y' -or $isSecure -eq 'y')
            }
            else {
                $secret = $false
            }

            $tempVariables[$currentPath] = @{
                Name     = $currentPath
                Value    = $prop.Value
                IsSecure = $secret
            }
        }
    }
}
            
function Send-VariablesToAzure {
    param (
        [hashtable]$Variables
    )
            
    foreach ($Value in $Variables.Values) {
        $variableName = $Value.Name
        $variableValue = $Value.Value
        $variableIsSecure = $Value.IsSecure
            
        if ($CommitToAzure) {
            #az pipelines variable create --name $variableName --value $variableValue --project $VSOProject --pipeline-id $VSOPipeLine --secret $variableIsSecure --allow-override $true --output table
            Write-Host "Running Azure CLI command to create/update variable: $variableName , $variableValue , $variableIsSecure"
        }
        else {
            Write-Host "Variable: $variableName, Value: $variableValue, Secure: $variableIsSecure"
        }
    }
    if ($OutputToFile) {
        $Variables.Values | ConvertTo-Json | Out-File -FilePath ".\examples\output.json"
    }
}

if (!$JsonFilePath) {
    Write-Output "No file path specified, using default file path and disabling commit to Azure DevOps"
    $JsonFilePath = ".\examples\short.json"
    $CommitToAzure = $false
}


if ($ShowHelp) {
    Get-Help $MyInvocation.MyCommand.Definition -Detailed
    exit
}


$jsonContent = Get-Content -Path $JsonFilePath -ErrorAction Stop | Out-String
$jsonObject = ConvertFrom-Json -InputObject $jsonContent
Convert-JsonToAzureVariables -JsonObject $jsonObject
Send-VariablesToAzure -Variables $tempVariables
$tempVariables = @{}
