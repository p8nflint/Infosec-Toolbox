# Check for PsExec, if not present, install
Function Install-PsExec {
    param (
        [bool]$AcceptEULA
    )
    $PsExec = Get-Command psexec -ErrorAction SilentlyContinue
    If($PsExec){
        # Accept EULA if specified
        If ($AcceptEULA -eq $True) {
            psexec.exe -accepteula | Out-Null
        }
    } Else {
        # courtesy of Adam Bertram @ https://adamtheautomator.com/psexec/
        Invoke-WebRequest -Uri 'https://download.sysinternals.com/files/PSTools.zip' -OutFile 'pstools.zip'
        Expand-Archive -Path 'pstools.zip' -DestinationPath "$env:TEMP\pstools"
        Move-Item -Path "$env:TEMP\pstools\psexec.exe" .
        Remove-Item -Path "$env:TEMP\pstools" -Recurse
        # Accept EULA if specified
        If ($AcceptEULA -eq $True) {
            psexec.exe -accepteula | Out-Null
        }
    }
} # End Function Install-PsExec

Install-PsExec -AcceptEULA $True
