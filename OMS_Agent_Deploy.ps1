

$Param1 = '/Q:A'
$Param2 = '/R:N'
$Param3 = '/C:"setup.exe /qn ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_ID=<YOUR WORKSPACE GUID> OPINSIGHTS_WORKSPACE_KEY=<YOUR WOWRKSPACE KEY> AcceptEndUserLicenseAgreement=1"'


Invoke-Command -ComputerName <SERVER01> -ScriptBlock {

    param(

            [Parameter (Position=0)]
            $LocalParam1,
            [Parameter (Position=1)]
            $LocalParam2,
            [Parameter (Position=2)]
            $LocalParam3

        )


    Start-Process -Wait -FilePath "C:\TEMP\MMASetup-AMD64.exe" -ArgumentList $LocalParam1, $LocalParam2, $LocalParam3



} -ArgumentList $Param1, $Param2, $Param3 
