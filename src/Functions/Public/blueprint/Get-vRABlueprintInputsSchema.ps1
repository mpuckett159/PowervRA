function Get-vRABlueprintInputsSchema {
    <#
        .SYNOPSIS
        Get a vRA Blueprint's Inputs Schema
    
        .DESCRIPTION
        Get a vRA Blueprint's Inputs Schema. By default the current version
        of the inputs schema is fetched by the API when no version is passed.
        Only one blueprint object is accepted at a time.
    
        .PARAMETER Blueprint
        The vRA Blueprint object as returned by Get-vRABlueprint
    
        .INPUTS
        System.String
    
        .OUTPUTS
        System.Management.Automation.PSObject

        .EXAMPLE
        $blueprint = Get-vRABlueprint -Id '3492a6e8-r5d4-1293-b6c4-39037ba693f9'
        Get-vRABlueprintInputsSchema -Blueprint $blueprint

        .EXAMPLE
        $blueprint = Get-vRABlueprint -Id '3492a6e8-r5d4-1293-b6c4-39037ba693f9'
        $versions = Get-vRABlueprintVersion -Blueprint $blueprint
        Get-vRABlueprintInputsSchema -Blueprint $blueprint -Version $versions

        .EXAMPLE
        $blueprint = Get-vRABlueprint -Id '3492a6e8-r5d4-1293-b6c4-39037ba693f9'
        $versions = Get-vRABlueprintVersion -Blueprint $blueprint
        Get-vRABlueprintInputsSchema -Blueprint $blueprint -Version $versions[0]
    
        .EXAMPLE
        Get-vRABlueprintInputsSchema -Blueprint (Get-vRABlueprint -Id '3492a6e8-r5d4-1293-b6c4-39037ba693f9')
    
        .EXAMPLE
        Get-vRABlueprintInputsSchema -Blueprint (Get-vRABlueprint -Name 'TestBlueprint')
    
    #>
    [CmdletBinding(DefaultParameterSetName="Standard")][OutputType('System.Management.Automation.PSObject')]
    
        Param (
    
            [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,ParameterSetName="Blueprint")]
            [ValidateNotNullOrEmpty()]
            [PSCustomObject]$Blueprint,
            
            [Parameter(ParameterSetName="Blueprint")]
            [ValidateNotNullOrEmpty()]
            [PSCustomObject[]]$Version
        )
    
        begin {
            $APIUrl = '/blueprint/api/blueprints'
    
            function CalculateOutput([PSCustomObject]$BlueprintInputSchema) {
    
                [PSCustomObject] @{
                    Required = $BlueprintInputSchema.required
                    Properties = $BlueprintInputSchema.properties
                }
            }
        }
    
        process {
    
            try {
    
                switch ($PsCmdlet.ParameterSetName) {
    
                    # --- Get Blueprint Input Schema from Blueprint object
                    'Blueprint' {
    
                        if($Version){
                            foreach($Versionobj in $Version){
                                $URI = "$($APIUrl)/$($Blueprint.Id)/versions/$($Versionobj.Id)/inputs-schema"
                                $Response = Invoke-vRARestMethod -Method GET -URI $URI -Verbose:$VerbosePreference
                                
                                foreach($InputSchema in $Response){
                                    CalculateOutput $InputSchema
                                }
                            }
                        }
                        else {
                            $URI = "$($APIUrl)/$($Blueprint.Id)/inputs-schema"
                            $Response = Invoke-vRARestMethod -Method GET -URI $URI -Verbose:$VerbosePreference
                            
                            foreach($InputSchema in $Response){
                                CalculateOutput $InputSchema
                            }
                        }
    
                        break
                    }
                }
            }
            catch [Exception]{
    
                throw
            }
        }
    
        end {
    
        }
    }
    