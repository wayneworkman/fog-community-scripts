#
# Module manifest for module 'StartLayoutCreator'
#
# Generated by: JJ Fullmer
#
# Generated on: 10/04/2017
#

@{
    
    # Script module or binary module file associated with this manifest.
    RootModule = 'C:\Program Files\WindowsPowerShell\Modules\StartLayoutCreator\StartLayoutCreator.psm1'
    
    # Version number of this module.
    ModuleVersion = '1.0'
    
    # Supported PSEditions
    # CompatiblePSEditions = @()
    
    # ID used to uniquely identify this module
    GUID = 'ced210c0-f339-406e-8d91-24d3c609b3e2'
    
    # Author of this module
    Author = 'JJ Fullmer'
    
    # Company or vendor of this module
    CompanyName = 'JJ Fullmer'
    
    # Copyright statement for this module
    Copyright = '(c) 2017 jfullmer. All rights reserved.'
    
    # Description of the functionality provided by this module
    Description = 'Goes through the current user''s or a given path of shortcuts and creates a layout with groups and sub groups based on
    folders and subfolders.
    After creating a startlayout you can export-startlayoutxml and then set-startlayout
    Currently only supports tiles of 2x2 (medium) size. Could be made to work with small tiles, but wide size tiles might be trickier.
    
    .PARAMETER startMenuPath
    the path to the shortcut files desired to become a start layout
    
    .PARAMETER width
    The width of the layout, defaults to 6. Suggest keeping at 6 as 8 can cause issues with applying
    
    .PARAMETER overrideOptions
    The options such as the default ''LayoutCustomizationRestrictionType=OnlySpecifiedGroups'' that makes it so only
    the groups in this layout can''t be edited when applied via group policy. Other things can be pinned in custom groups
    
    .PARAMETER startFormat
    The startStr of the xml format for a later to string variable
    
    .PARAMETER endFormat
    The ending strings of the xml format
    
    .PARAMETER groups
    The custom object created by the function that is a list of start group psobjects from Get-StartGroup'
    
    # Minimum version of the Windows PowerShell engine required by this module
    # PowerShellVersion = ''
    
    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''
    
    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''
    
    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''
    
    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''
    
    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''
    
    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()
    
    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()
    
    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()
    
    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()
    
    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()
    
    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()
    
    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport = '*'
    
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport = '*'
    
    # Variables to export from this module
    VariablesToExport = '*'
    
    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport = '*'
    
    # DSC resources to export from this module
    # DscResourcesToExport = @()
    
    # List of all modules packaged with this module
    # ModuleList = @()
    
    # List of all files packaged with this module
    # FileList = @()
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
    
        PSData = @{
    
            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()
    
            # A URL to the license for this module.
            # LicenseUri = ''
    
            # A URL to the main website for this project.
            # ProjectUri = ''
    
            # A URL to an icon representing this module.
            # IconUri = ''
    
            # ReleaseNotes of this module
            # ReleaseNotes = ''
    
        } # End of PSData hashtable
    
    } # End of PrivateData hashtable
    
    # HelpInfo URI of this module
    HelpInfoURI = 'https://github.com/FOGProject/fog-community-scripts/tree/master/PowershellModules/StartLayoutCreator'
    
    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
    
    }
    
    