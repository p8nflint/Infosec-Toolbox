<#
.SYNOPSIS
    Install PsExec.exe of the Sysinternals suite if not installed
    Optionally set Registry Key to accept EULA (silences prompt on initial execution)

.NOTES
    Name: Install-PsExec
    Author: Payton Flint
    Version: 1.1
    DateCreated: 2023-Aug

.LINKS
    https://adamtheautomator.com/psexec/
    
#>


# Check for PsExec, if not present, install
Function Install-PsExec {
    param (
        [bool]$AcceptEULA
    )

    Function RegEdit {
        param(
        $regPath,
        $regName,
        $regValue,
        [bool]$silent
        )
        $regFull = Join-Path $regPath $regName
            Try {
                    $CurrentKeyValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName
                    If (Test-Path $regPath) {
                        If ($CurrentKeyValue -eq $regValue) {
                            If (!($silent)) {
                                Write-Host -ForegroundColor Green 'Registry key' $regFull 'value is set to the desired value of' $regValue'.'
                            }
                            $script:regTest = $True  
                        } Else {
                            If (!($silent)) {
                                Write-Host -ForegroundColor Red 'Registry key' $regFull 'value is not' $regValue'.'
                                Write-Host -ForegroundColor Cyan 'Setting registry key' $regFull 'value to' $regValue'.'
                            }
                            New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType DWORD -Force | Out-Null
                            $CurrentKeyValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName
                            If ($CurrentKeyValue -eq $regValue) {
                                If (!($silent)) {
                                    Write-Host -ForegroundColor Green 'Registry key' $regFull 'value is set to the desired value of' $regValue'.'
                                }
                                $script:regTest = $True  
                            } Else {
                                If (!($silent)) {
                                    Write-Host -ForegroundColor Red 'Registry key' $regFull 'value could not be set to' $regValue '.'
                                }
                            }
                        }
                    } Else {
                        If (!($silent)) {
                            Write-Host -ForegroundColor Red 'Registry key' $regFull 'path does not exist.'
                            Write-Host -ForegroundColor Cyan 'Creating registry key' $regFull'.'
                        }
                        New-Item -Path $regPath -Force | Out-Null
                        If (!($silent)) {
                            Write-Host -ForegroundColor Cyan 'Setting registry key' $regFull 'value to' $regValue'.'
                        }
                        New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType DWORD -Force | Out-Null
                        $CurrentKeyValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName
                        If ($CurrentKeyValue -eq $regValue) {
                            If (!($silent)) {
                                Write-Host -ForegroundColor Green 'Registry key' $regFull 'value is set to the desired value of' $regValue'.'
                            }
                            $script:regTest = $True  
                        } Else {
                            If (!($silent)) {
                                Write-Host -ForegroundColor Red 'Registry key' $regFull 'value could not be set to' $regValue '.'
                            }
                        }
                    }
            } Catch {
                If (!($silent)) {
                    Write-Host -ForegroundColor Red 'Registry key' $regFull 'value could not be set to' $regValue '.'
                }
            }
    } # End RegEdit Function

    $PsExec = Get-Command psexec -ErrorAction SilentlyContinue
    If($PsExec){
        # Accept EULA if specified
        If ($AcceptEULA -eq $True) {
            RegEdit -regPath "HKCU:\SOFTWARE\Sysinternals\PsExec" -regName "EulaAccepted" -regValue "1" -silent $true
        }
    } Else {
        # courtesy of Adam Bertram @ https://adamtheautomator.com/psexec/
        Invoke-WebRequest -Uri 'https://download.sysinternals.com/files/PSTools.zip' -OutFile 'pstools.zip'
        Expand-Archive -Path 'pstools.zip' -DestinationPath "$env:TEMP\pstools"
        Move-Item -Path "$env:TEMP\pstools\psexec.exe" .
        Remove-Item -Path "$env:TEMP\pstools" -Recurse
        # Accept EULA if specified
        If ($AcceptEULA -eq $True) {
            RegEdit -regPath "HKCU:\SOFTWARE\Sysinternals\PsExec" -regName "EulaAccepted" -regValue "1" -silent $true
        }
    }
} # End Function Install-PsExec

Install-PsExec -AcceptEULA $True
