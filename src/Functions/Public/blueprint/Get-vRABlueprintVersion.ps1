function Get-vRABlueprintVersion {
    <#
        .SYNOPSIS
        Get a vRA Blueprint's Version objects
    
        .DESCRIPTION
        Get a vRA Blueprint's Version objects
    
        .PARAMETER Blueprint
        The vRA Blueprint object as returned by Get-vRABlueprint
    
        .INPUTS
        System.String
    
        .OUTPUTS
        System.Management.Automation.PSObject

        .EXAMPLE
        $blueprint = Get-vRABlueprint -Id '3492a6e8-r5d4-1293-b6c4-39037ba693f9'
        Get-vRABlueprintVersion -Blueprint $blueprint
    
        .EXAMPLE
        Get-vRABlueprintVersion -Blueprint (Get-vRABlueprint -Id '3492a6e8-r5d4-1293-b6c4-39037ba693f9')
    
        .EXAMPLE
        Get-vRABlueprintVersion -Blueprint (Get-vRABlueprint -Name 'TestBlueprint')
    
    #>
    [CmdletBinding(DefaultParameterSetName="Standard")][OutputType('System.Management.Automation.PSObject')]
    
        Param (
    
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
            [ValidateNotNullOrEmpty()]
            [PSCustomObject]$Blueprint,

            [Parameter(Mandatory=$false,ParameterSetName='ByVersion')]
            [ValidateNotNullOrEmpty()]
            [String[]]$VersionNumber,
            
            [Parameter(Mandatory=$false,ParameterSetName='CurrentVersion')]
            [switch]$CurrentVersion
        )
    
        begin {
            $APIUrl = '/blueprint/api/blueprints'
    
            function CalculateOutput([PSCustomObject]$BlueprintVersion) {
    
                [PSCustomObject] @{
                    Id = $BlueprintVersion.id
                    CreatedAt = $BlueprintVersion.createdAt
                    CreatedBy = $BlueprintVersion.createdBy
                    UpdatedAt = $BlueprintVersion.updatedAt
                    UpdatedBy = $BlueprintVersion.updatedBy
                    OrganizationId = $BlueprintVersion.orgId
                    ProjectId = $BlueprintVersion.projectId
                    ProjectName = $BlueprintVersion.projectName
                    SelfLink = $BlueprintVersion.selfLink
                    BlueprintId = $BlueprintVersion.blueprintId
                    Name = $BlueprintVersion.name
                    Description = $BlueprintVersion.description
                    Version = $BlueprintVersion.version
                    Content = $BlueprintVersion.content
                    Status = $BlueprintVersion.status
                    VersionDescription = $BlueprintVersion.versionDescription
                    VersionChangeLog = $BlueprintVersion.versionChangeLog
                    Valid = $BlueprintVersion.valid
                }
            }
        }
    
        process {
    
            try {
    
                switch ($PsCmdlet.ParameterSetName) {
    
                    # --- Get Blueprint Version Object from Blueprint object and specified version number
                    'ByVersion' {
                        foreach ($Version in $VersionNumber){
                            $URI = "$($APIUrl)/$($Blueprint.Id)/versions/$Version"
                            $Response = Invoke-vRARestMethod -Method GET -URI $URI -Verbose:$VerbosePreference
                            CalculateOutput $Response
                        }
                    }

                    # --- Get most recent Blueprint Version Object from Blueprint Object
                    'CurrentVersion' {
                        $URI = "$($APIUrl)/$($Blueprint.Id)/versions"
                        $ResponseTerse = Invoke-vRARestMethod -Method GET -URI $URI -Verbose:$VerbosePreference

                        # Content is sorted by the API so we can always just select the object in position 0 in the array
                        $URI = $ResponseTerse.content[0].selfLink
                        $Response = Invoke-vRARestMethod -Method GET -URI $URI -Verbose:$VerbosePreference

                        CalculateOutput $Response
                    }

                    # --- Get all Blueprint Version Objects from Blueprint Object
                    default {
                        $URI = "$($APIUrl)/$($Blueprint.Id)/versions"
                        $Response = Invoke-vRARestMethod -Method GET -URI $URI -Verbose:$VerbosePreference
                        
                        foreach($Version in $Response.content){
                            $URI = $Version.selfLink
                            $Response = Invoke-vRARestMethod -Method GET -URI $URI -Verbose:$VerbosePreference
                            CalculateOutput $Response
                        }
                    }
                }
                break
            }
            catch [Exception]{
    
                throw
            }
        }
    
        end {
    
        }
    }
    