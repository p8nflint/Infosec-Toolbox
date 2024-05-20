# identify if shell is elevated
function Test-ElevatedShell
		{
			$user = [Security.Principal.WindowsIdentity]::GetCurrent()
			(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
		}

# execute function to check for elevated shell
$admin = Test-ElevatedShell

# if elevated, execute install
if ($admin) {

        # check for PsExec, if not present, install
    function Install-PsExec {
        param (
            [bool]$AcceptEULA
        )

        function RegEdit {
            param(
            $regPath,
            $regName,
            $regValue,
            [bool]$silent
            )
            $regFull = Join-Path $regPath $regName
                try {
                        $CurrentKeyValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName
                        if (Test-Path $regPath) {
                            if ($CurrentKeyValue -eq $regValue) {
                                if (!($silent)) {
                                    Write-Host -ForegroundColor Green 'Registry key' $regFull 'value is set to the desired value of' $regValue'.'
                                }
                                $script:regTest = $True  
                            } else {
                                if (!($silent)) {
                                    Write-Host -ForegroundColor Red 'Registry key' $regFull 'value is not' $regValue'.'
                                    Write-Host -ForegroundColor Cyan 'Setting registry key' $regFull 'value to' $regValue'.'
                                }
                                New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType DWORD -Force | Out-Null
                                $CurrentKeyValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName
                                if ($CurrentKeyValue -eq $regValue) {
                                    if (!($silent)) {
                                        Write-Host -ForegroundColor Green 'Registry key' $regFull 'value is set to the desired value of' $regValue'.'
                                    }
                                    $script:regTest = $True  
                                } else {
                                    if (!($silent)) {
                                        Write-Host -ForegroundColor Red 'Registry key' $regFull 'value could not be set to' $regValue '.'
                                    }
                                }
                            }
                        } else {
                            if (!($silent)) {
                                Write-Host -ForegroundColor Red 'Registry key' $regFull 'path does not exist.'
                                Write-Host -ForegroundColor Cyan 'Creating registry key' $regFull'.'
                            }
                            New-Item -Path $regPath -Force | Out-Null
                            if (!($silent)) {
                                Write-Host -ForegroundColor Cyan 'Setting registry key' $regFull 'value to' $regValue'.'
                            }
                            New-ItemProperty -Path $regPath -Name $regName -Value $regValue -PropertyType DWORD -Force | Out-Null
                            $CurrentKeyValue = (Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue).$regName
                            if ($CurrentKeyValue -eq $regValue) {
                                if (!($silent)) {
                                    Write-Host -ForegroundColor Green 'Registry key' $regFull 'value is set to the desired value of' $regValue'.'
                                }
                                $script:regTest = $True  
                            } else {
                                if (!($silent)) {
                                    Write-Host -ForegroundColor Red 'Registry key' $regFull 'value could not be set to' $regValue '.'
                                }
                            }
                        }
                } catch {
                    if (!($silent)) {
                        Write-Host -ForegroundColor Red 'Registry key' $regFull 'value could not be set to' $regValue '.'
                    }
                }
        } # end RegEdit Function

        $PsExec = Get-Command psexec -ErrorAction SilentlyContinue
        if($PsExec){
            # accept EULA if specified
            if ($AcceptEULA -eq $True) {
                RegEdit -regPath "HKCU:\SOFTWARE\Sysinternals\PsExec" -regName "EulaAccepted" -regValue "1" -silent $true
            }
        } else {
            # courtesy of Adam Bertram @ https://adamtheautomator.com/psexec/
            Invoke-WebRequest -Uri 'https://download.sysinternals.com/files/PSTools.zip' -OutFile 'pstools.zip'
            Expand-Archive -Path 'pstools.zip' -DestinationPath "$env:SystemRoot\System32\pstools"
            Move-Item -Path "$env:SystemRoot\System32\pstools\psexec.exe"
            Remove-Item -Path "$env:SystemRoot\System32\pstools" -Recurse
            # accept EULA if specified
            if ($AcceptEULA -eq $True) {
                RegEdit -regPath "HKCU:\SOFTWARE\Sysinternals\PsExec" -regName "EulaAccepted" -regValue "1" -silent $true
            }
        }
    } # end function Install-PsExec

    # execute install function
    Install-PsExec -AcceptEULA $True

# else print error
} else {
    Write-Host -ForegroundColor Red "Insufficient privilege level- please exeucte script with elevated privileges."
}
