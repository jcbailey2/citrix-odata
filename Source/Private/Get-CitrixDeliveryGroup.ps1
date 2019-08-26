function Get-CitrixDeliveryGroups {

   <#
    .SYNOPSIS

    .DESCRIPTION

    .LINK
    https://github.com/karjona/citrix-odata

    .PARAMETER DeliveryController
    Specifies a single Citrix Virtual Apps & Desktops Delivery Controller to collect data from.

    .PARAMETER Credential
    Specifies a user account that has permission to send the request. The default is the current user. A minimum of
    read-only administrator permissions on Citrix Virtual Apps & Desktops are required to collect this data.

    Enter a PSCredential object, such as one generated by the Get-Credential cmdlet.

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
        $Credential
    )

    process {
        try {
            $Query = '$select=Id,Name'
            if ($Credential) {
                $DeliveryGroups = Invoke-CitrixMonitorServiceQuery -DeliveryController $DeliveryController `
                -Credential $Credential -Endpoint 'DesktopGroups' -Query $Query -ErrorAction Stop
            } else {
                $DeliveryGroups = Invoke-CitrixMonitorServiceQuery -DeliveryController $DeliveryController `
                -Credential $Credential -Endpoint 'DesktopGroups' -Query $Query -ErrorAction Stop
            }
        } catch {
            $ConnectionError = $_
            throw $ConnectionError
        }
        $DeliveryGroups.value
    }
}
