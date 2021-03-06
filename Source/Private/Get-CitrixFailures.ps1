function Get-CitrixFailures {
    
    <#
    .SYNOPSIS
    Retrieves the total number of connection failures for a single Citrix Virtual Apps and Desktops Delivery
    Controller.
    
    .DESCRIPTION
    This cmdlet returns a custom object with Delivery Group IDs and connection failure counts of all Delivery
    Groups of the specified Delivery Controller for the specified period of time. Data granularity depends on the
    specified period of time.
    
    .LINK
    https://github.com/karjona/citrix-odata
    
    .PARAMETER DeliveryController
    Specifies a single Citrix Virtual Apps and Desktops Delivery Controller to collect data from.
    
    .PARAMETER Credential
    Specifies a user account that has permission to send the request. A minimum of read-only administrator
    permissions on Citrix Virtual Apps and Desktops are required to collect this data.
    
    Enter a PSCredential object, such as one generated by the Get-Credential cmdlet.
    
    .PARAMETER StartDate
    Specifies the start date for the data collection in yyyy-MM-ddTHH:mm:ss format.
    
    .PARAMETER EndDate
    Specifies the end date for the data collection in yyyy-MM-ddTHH:mm:ss format.
    
    .COMPONENT
    citrix-odata
    #>
    
    
    [CmdletBinding()]
    [OutputType('PSCustomObject')]
    
    param(
    [Parameter(Mandatory=$true)]
    [String]
    $DeliveryController,
    
    [Parameter()]
    [PSCredential]
    $Credential,
    
    [Parameter(Mandatory=$true)]
    [DateTime]
    $StartDate,
    
    [Parameter(Mandatory=$true)]
    [DateTime]
    $EndDate
    )
    
    process {
        try {
            $Timespan = New-TimeSpan -Start $StartDate -End $EndDate
            if ($Timespan.TotalSeconds -le 3600) {
                $Granularity = '1'      # Less than an hour, request per-minute granularity
            } elseif ($Timespan.TotalSeconds -le 2592000) {
                $Granularity = '60'     # Less than 30 days, request per-hour granularity
            } else {
                $Granularity = '1440'   # More than a month, request per-day granularity
            }
            
            $Query = (
            "`$select=DesktopGroupId,FailureCount&" +
            "`$filter=(SummaryDate gt DateTime'$(Get-Date -Date $StartDate -Format "yyyy-MM-ddTHH:mm:ss")') and " +
            "(SummaryDate lt DateTime'$(Get-Date -Date $EndDate -Format "yyyy-MM-ddTHH:mm:ss")') and " +
            "(FailureCategory eq 1) and (Granularity eq $Granularity)"
            )
            
            $InvokeCitrixMonitorServiceQueryParams = @{
                DeliveryController = $DeliveryController
                Endpoint = 'FailureLogSummaries'
                Query = $Query
                ErrorAction = 'Stop'
            }
            if ($Credential) {
                $InvokeCitrixMonitorServiceQueryParams.Add("Credential", $Credential)
            }
            
            Write-Progress -Id 1 -Activity "Retrieving failures for $DeliveryController"
            $Failures = Invoke-CitrixMonitorServiceQuery @InvokeCitrixMonitorServiceQueryParams
        } catch {
            $ConnectionError = $_
            throw $ConnectionError
        } finally {
            Write-Progress -Id 1 -Activity "Retrieving failures for $DeliveryController" -Completed
        }
        $Failures
    }
}
