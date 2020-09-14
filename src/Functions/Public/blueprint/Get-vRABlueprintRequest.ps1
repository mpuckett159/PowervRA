function Get-vRABlueprintRequest {
    <#
        .SYNOPSIS
        Get a vRA Blueprint Request
    
        .DESCRIPTION
        Get a vRA Blueprint Request

        .PARAMETER DeploymentId
        The ID of a Deployment

        .PARAMETER DeploymentName
        The Name of a Deployment
    
        .PARAMETER BlueprintId
        The ID of a Blueprint
    
        .PARAMETER BlueprintName
        The Name of a Blueprint

        .PARAMETER BlueprintVersion
        The version number of a Blueprint
    
        .INPUTS
        System.String
    
        .OUTPUTS
        System.Management.Automation.PSObject
    
        .EXAMPLE
        Get-vRABlueprintRequest
    
        .EXAMPLE
        Get-vRABlueprintRequest -DeploymentId '6087a130-ef46-435e-9a67-40c11de3e6f9'

        .EXAMPLE
        Get-vRABlueprintRequest -DeploymentName 'example Deployment name'

        .EXAMPLE
        Get-vRAblueprintRequest -BlueprintId '8087a130-ef46-455e-9a97-40c11de3e6f9'

        .EXAMPLE
        Get-vRAblueprintRequest -BlueprintId '8087a130-ef46-455e-9a97-40c11de3e6f9' -BlueprintVersion '1.1'

        .EXAMPLE
        Get-vRAblueprintRequest -BlueprintId '8087a130-ef46-455e-9a97-40c11de3e6f9' -BlueprintVersion @('1.1','1.2','1.3')

        .EXAMPLE
        Get-vRAblueprintRequest -BlueprintName 'example Blueprint name'

        .EXAMPLE
        Get-vRAblueprintRequest -BlueprintName 'example Blueprint name' -BlueprintVersion '1.1'

        .EXAMPLE
        Get-vRAblueprintRequest -BlueprintName 'example Blueprint name' -BlueprintVersion @('1.1','1.2','1.3')
    
    #>
    [CmdletBinding(DefaultParameterSetName="Standard")][OutputType('System.Management.Automation.PSObject')]
    
        Param (
    
            [Parameter(Mandatory=$true,ParameterSetName="ByRequestId")]
            [ValidateNotNullOrEmpty()]
            [String[]]$RequestId,

            [Parameter(Mandatory=$true,ParameterSetName="ByDeploymentId")]
            [ValidateNotNullOrEmpty()]
            [String[]]$DeploymentId,
    
            [Parameter(Mandatory=$true,ParameterSetName="ByDeploymentName")]
            [ValidateNotNullOrEmpty()]
            [String[]]$DeploymentName,
    
            [Parameter(Mandatory=$true,ParameterSetName="ByBlueprintId")]
            [ValidateNotNullOrEmpty()]
            [String[]]$BlueprintId,
    
            [Parameter(Mandatory=$false,ParameterSetName="ByBlueprintName")]
            [ValidateNotNullOrEmpty()]
            [String[]]$BlueprintName,
    
            [Parameter(Mandatory=$false,ParameterSetName="ByBlueprintId")]
            [Parameter(Mandatory=$false,ParameterSetName="ByBlueprintName")]
            [ValidateNotNullOrEmpty()]
            [String[]]$BlueprintVersion
        )
    
        begin {
            $APIUrl = '/blueprint/api/blueprint-requests'
    
            function CalculateOutput([PSCustomObject]$BlueprintRequest) {
    
                [PSCustomObject] @{
                    Id = $BlueprintRequest.id
                    CreatedAt = $BlueprintRequest.createdAt
                    CreatedBy = $BlueprintRequest.createdBy
                    UpdatedAt = $BlueprintRequest.updatedAt
                    UpdatedBy = $BlueprintRequest.updatedBy
                    OrganizationId = $BlueprintRequest.orgId
                    ProjectId = $BlueprintRequest.projectId
                    ProjectName = $BlueprintRequest.projectName
                    DeploymentId = $BlueprintRequest.deploymentId
                    RequestTrackerId = $BlueprintRequest.requestTrackerId
                    DeploymentName = $BlueprintRequest.deploymentName
                    Reason = $BlueprintRequest.reason
                    Plan = $BlueprintRequest.plan
                    Destroy = $BlueprintRequest.destroy
                    IgnoreDeleteFailures = $BlueprintRequest.ignoreDeleteFailures
                    Simulate = $BlueprintRequest.simulate
                    BlueprintId = $BlueprintRequest.blueprintId
                    BlueprintVersion = $BlueprintRequest.blueprintVersion
                    Inputs = $BlueprintRequest.inputs
                    Status = $BlueprintRequest.status
                    FlowId = $BlueprintRequest.flowId
                    FlowExecutionId = $BlueprintRequest.flowExecutionId
                }
            }
        }
    
        process {
    
            try {
    
                switch ($PsCmdlet.ParameterSetName) {
    
                    # --- Get Blueprint Request by Id
                    'ByRequestId' {
    
                        foreach ($Id in $RequestId){
    
                            $URI = "$($APIUrl)/$($Id)"
                            $Response = Invoke-vRARestMethod -Method GET -URI $URI -Verbose:$VerbosePreference
                            CalculateOutput $Response
                        }
    
                        break
                    }
                    # --- Get Blueprint Request by Deployment Id
                    'ByDeploymentId' {
    
                        foreach ($Id in $DeploymentId){
    
                            $URI = $APIUrl
                            $Response = Invoke-vRARestMethod -Method GET -URI $URI -Verbose:$VerbosePreference
    
                            foreach($BlueprintRequest in $Response.content){
                                if($BlueprintRequest.deploymentId -eq $Id){
                                    CalculateOutput $BlueprintRequest
                                }
                            }
                        }
    
                        break
                    }
                    # --- Get Blueprint Request by Name
                    'ByDeploymentName' {
    
                        foreach ($Name in $DeploymentName){
    
                            $URI = "$($APIUrl)"
                            $Response = Invoke-vRARestMethod -Method GET -URI $URI -Verbose:$VerbosePreference
    
                            foreach ($BlueprintRequest in $Response.content) {
                                if($BlueprintRequest.deploymentName -eq $DeploymentName){
                                    CalculateOutput $BlueprintRequest
                                }
                            }
                        }
    
                        break
                    }
                    # --- Get Blueprint Request by Blueprint Id and optionally version number
                    'ByBlueprintId' {
    
                        foreach ($Id in $BlueprintId){
    
                            $URI = "$($APIUrl)"
                            $Response = Invoke-vRARestMethod -Method GET -URI $URI -Verbose:$VerbosePreference
    
                            if($BlueprintVersion){
                                foreach ($BlueprintRequest in $Response.content) {
                                    if($BlueprintRequest.blueprintId -eq $Id -and $BlueprintVersion -contains $BlueprintRequest.blueprintVersion){
                                        CalculateOutput $BlueprintRequest
                                    }
                                }
                            }
                            else {
                                foreach ($BlueprintRequest in $Response.content) {
                                    if($BlueprintRequest.blueprintId -eq $Id){
                                        CalculateOutput $BlueprintRequest
                                    }
                                }
                            }
                        }
    
                        break
                    }
                    # --- Get Blueprint Request by Blueprint Name and optionally version number
                    'ByBlueprintName' {
    
                        foreach ($Name in $BlueprintName){

                            # Get relevant Blueprint Ids into array
                            $blueprintIds = (Get-vRABlueprint -Name $BlueprintName).Id
    
                            $URI = "$($APIUrl)"
                            $Response = Invoke-vRARestMethod -Method GET -URI $URI -Verbose:$VerbosePreference
    
                            if($BlueprintVersion){
                                foreach ($BlueprintRequest in $Response.content) {
                                    if($blueprintIds -contains $BlueprintRequest.blueprintId -and $BlueprintVersion -contains $BlueprintRequest.blueprintVersion){
                                        CalculateOutput $BlueprintRequest
                                    }
                                }
                            }
                            else {
                                foreach ($BlueprintRequest in $Response.content) {
                                    if($blueprintIds -contains $BlueprintRequest.blueprintId){
                                        CalculateOutput $BlueprintRequest
                                    }
                                }
                            }
                        }
    
                        break
                    }
                    # --- No parameters passed so return all Blueprint Requests
                    'Standard' {
    
                        $URI = $APIUrl
                        $Response = Invoke-vRARestMethod -Method GET -URI $URI -Verbose:$VerbosePreference

                        foreach ($BlueprintRequest in $Response.content) {
                            CalculateOutput $BlueprintRequest
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
    