function Get-vRAFabricAWSVolumeType {
    <#
        .SYNOPSIS
        Get a vRA Fabric AWS Volume Types
    
        .DESCRIPTION
        Get a vRA Fabric AWS Volume Types
    
        .INPUTS
        None
    
        .OUTPUTS
        System.Management.Automation.PSObject
    
        .EXAMPLE
        Get-vRAFabricAWSVolumeTypes
    
    #>
    [CmdletBinding(DefaultParameterSetName="Standard")][OutputType('System.Management.Automation.PSObject')]
    
        Param (
        )
    
        begin {
            $APIUrl = '/iaas/api/fabric-aws-volume-types'
    
            function CalculateOutput([PSCustomObject]$FabricAWSVolumeTypes) {
    
                [PSCustomObject] @{
                    VolumeTypes = $FabricAWSVolumeTypes.volumeTypes
                }
            }
        }
    
        process {
    
            try {
    
                switch ($PsCmdlet.ParameterSetName) {
    
                    # --- Return all Fabric AWS Volume Types
                    'Standard' {
    
                        $URI = $APIUrl
                        $Response = Invoke-vRARestMethod -Method GET -URI $URI -Verbose:$VerbosePreference

                        foreach ($FabricAWSVolumeTypes in $Response.content) {
                            CalculateOutput $FabricAWSVolumeTypes
                        }
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
    