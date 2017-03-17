Param(
    [string]$ResourceGroupName = '*',
    [string]$AzureRunAsConnection = 'AzureRunAsConnection'
)
Write-Output ('Start Starting of VMs in RessourceGroup {0} - {1:HH}:{1:mm}' -f $ResourceGroupName, (Get-Date))

$Conn = Get-AutomationConnection -Name $AzureRunAsConnection 
if(!$Conn) {
    Throw "Could not find an Automation Connection Asset named '${AzureRunAsConnection}'. Make sure you have created one in this Automation Account."
}
$account = Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint
# manuell login
#$cred = Get-Credential -Message 'AAD Account' -UserName stefan.denninger@doco.com
#$account = Add-AzureRmAccount -Credential $cred | select -Property *
 
Write-Output ('Connecting Azure Account to Tenant {0}' -f $Conn.TenantID)

Write-Output ('Selecting Azure Subscription {1} {0}' -f $Conn.SubscriptionId,  $account.Context.Subscription.SubscriptionName )
Select-AzureRmSubscription -SubscriptionId $Conn.SubscriptionId | Out-Null
	
$VMs = Get-AzureRmResourceGroup | ? { $_.ResourceGroupName -like $ResourceGroupName } | Get-AzureRmVM 
		
if (!$VMs) {
    Write-Output "No VMs were found in your subscription."
} else {
    Foreach ($VM in $VMs) {
        $name = $VM.Name
        Write-Output ('Starting {0}' -f $VM.Name)
        if (($VM | Start-AzureRmVM ).IsSuccessStatusCode) {
            Write-Output ('Started {0}' -f $VM.Name)
        } else {
            Write-Output ('Failed to start {0}' -f $VM.Name)
        }
    }
}
Write-Output ('DONE - Starting of VMs in RessourceGroup {0} - {1:HH}:{1:mm}' -f $ResourceGroupName, (Get-Date))
