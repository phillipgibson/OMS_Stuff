    #The name of the Automation Credential Asset this runbook will use to authenticate to Azure.
    $CredentialAssetName = “AzureCredential”
	$AzureSubscriptionIDAssetName = ‘AzureSubscriptionId’
	$SubID = Get-AutomationVariable -Name $AzureSubscriptionIDAssetName

    #Get the credential with the above name from the Automation Asset store
    $Cred = Get-AutomationPSCredential -Name $CredentialAssetName
    if(!$Cred) {
        Throw “Could not find an Automation Credential Asset named ‘${CredentialAssetName}’. Make sure you have created one in this Automation Account.”
    }

    #Connect to your Azure Account           
    Add-AzureRmAccount -Credential $Cred -SubscriptionId $SubID

    # Set default Azure storage account
    $StorageAccountName = "<YOUR STORAGE ACCOUNT NAME>"
    $StorageContainerName = "<YOUR STORAGE CONTAINER NAME>"
    $StorageAccountObj = Get-AzureRmStorageAccount | ? { $_.StorageAccountName -eq $StorageAccountName }
    
    # Create Azure Storage Context
    $StorageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $StorageAccountObj.ResourceGroupName -StorageAccountName $StorageAccountName
    $StorageAccountKey1Value = $StorageAccountKey | ? { $_.KeyName -eq "key1" }
    $Ctx = New-AzureStorageContext $StorageAccountName -StorageAccountKey $StorageAccountKey1Value.Value
    Get-AzureStorageContainer -Name $StorageContainerName -Context $Ctx
    
    # Run the OMS Saved Query Search
    Write-Output "Executing the saved search query An account failed to log on past 24 hours."
    $result = Get-AzureRmOperationalInsightsSavedSearchResults `
    -ResourceGroupName (Get-AutomationVariable -Name "OMSResourceGroupName") `
    -WorkspaceName (Get-AutomationVariable -Name "OMSWorkspaceName") `
    -SavedSearchId "security and audit|An account failed to log on past 24 hours"

    $result.Value | ConvertFrom-Json | Export-Csv -NoTypeInformation $env:TEMP\acctfailedlogonpast24hours.csv -Force

    Write-Output "Moving CSV Results File to Azure Blob Storage."
    Set-AzureStorageBlobContent -Context $Ctx -File $env:TEMP\acctfailedlogonpast24hours.csv -Container $StorageContainerName -Force | Out-Null
