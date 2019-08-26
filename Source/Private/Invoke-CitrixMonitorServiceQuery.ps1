function Invoke-CitrixMonitorServiceQuery {
    
    <#
        .SYNOPSIS
        
        .DESCRIPTION
        
        .LINK
        https://github.com/karjona/citrix-odata
        
        .PARAMETER DeliveryController
        Specifies a single Citrix Virtual Apps & Desktops Delivery Controller to collect data from.
        
        .PARAMETER Credential
        Specifies a user account that has permission to send the request. The default is the current user. A
        minimum of read-only administrator permissions on Citrix Virtual Apps & Desktops are required to collect
        this data.
        
        Enter a PSCredential object, such as one generated by the Get-Credential cmdlet.
        
        .PARAMETER Endpoint

        
        .PARAMETER Query
        
        
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

        [Parameter()]
        [String]
        $Endpoint,

        [Parameter()]
        [String]
        $Query
    )
    
    begin {
        if ($Query) {
            if ($Query.Substring(0,1) -ne '&') {
                $Query = "&$Query"
            }
        }
    }

    process {
        try {
            if ($Credential) {
                $Result = Invoke-RestMethod -Uri `
                "http://$DeliveryController/Citrix/Monitor/OData/v3/Data/$Endpoint`?`$format=json$Query" `
                -Credential $Credential
            } else {
                $Result = Invoke-RestMethod -Uri `
                "http://$DeliveryController/Citrix/Monitor/OData/v3/Data/$Endpoint`?`$format=json$Query" `
                -UseDefaultCredentials
            }
        } catch {
            $ConnectionError = $_
            # Handle 401 (invalid credentials) error
            if ($ConnectionError.Exception.Response.StatusCode) {
                if ($ConnectionError.Exception.Response.StatusCode.ToString() -eq 'Unauthorized') {
                    if (!$Credential) {
                        Write-Error ("The current user does not have at least read-only administrator " +
                        "permissions on $DeliveryController.")
                    } else {
                        Write-Error ("The supplied credentials do not have at least read-only administrator " +
                        "permissions on $DeliveryController.")
                    }
                # There's a web server on that address, but responded with an error (404, 500...)
                } else {
                    Write-Error ("The server on $DeliveryController responded with an error: " +
                    "$($ConnectionError.Exception.Message)")
                }
            } else {
                # Handle DNS resolution errors
                if ($ConnectionError.Exception.Status.ToString() -eq 'NameResolutionFailure') {
                    Write-Error "Could not find host $DeliveryController."
                # Handle all other errors
                } else {
                    Write-Error ("An error occurred while trying to connect to $DeliveryController. Check " +
                    "network connectivity and that the specified host is a Citrix Delivery Controller.`r`n" +
                    "$($ConnectionError.Exception.Message)")
                }
            }
        }
        $Result
    }
}
