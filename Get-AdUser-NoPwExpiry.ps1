<#
.SYNOPSIS
    Get AD users where password is set to not expire

.NOTES
    Name: Get-AdUser-NoPwExpiry
    Author: Payton Flint
    Version: 1.0
    DateCreated: 2023-Aug

.LINK
    https://github.com/p8nflnt/Infosec-Toolbox/blob/main/Get-AdUser-NoPwExpiry.ps1
#>


# Clear variables for repeatability
Get-Variable -Exclude PWD,*Preference | Remove-Variable -EA 0

# Identify location of script
$ScriptPath = Split-Path ($MyInvocation.MyCommand.Path) -Parent

# Identify if shell is elevated
function Test-ElevatedShell
		{
			$user = [Security.Principal.WindowsIdentity]::GetCurrent()
			(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
		}
$admin = Test-ElevatedShell

If($admin) {
    Get-ADUser -filter * -Properties PasswordNeverExpires `
    | Select-Object Name, PasswordNeverExpires `
    | Where-Object {$_.PasswordNeverExpires -notlike "True"} `
    | Sort-Object -Property Name `
    | Export-Csv -Path "$ScriptPath\ADUser-NoPWExpiry.csv" -NoTypeInformation
} Else {
    "Insufficient privilege level- please exeucte script with elevated privileges."
}
