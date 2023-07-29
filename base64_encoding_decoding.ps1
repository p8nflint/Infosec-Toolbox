# clear variables for repeatability
Get-Variable -Exclude PWD,*Preference | Remove-Variable -EA 0

# set encoding type
$encodingType = "UTF8"

# string input
$plaintext = "<INSERT PLAINTEXT>"

# encode plaintext and print to console in red
$bytes = [System.Text.Encoding]::$encodingType.GetBytes($plaintext)
$ciphertext = [Convert]::ToBase64String($bytes)
Write-Host -ForegroundColor Red $ciphertext

# decode plaintext and print to console in green
$deciphered = [System.Text.Encoding]::$encodingType.GetString([System.Convert]::FromBase64String($ciphertext))
Write-Host -ForegroundColor Green $deciphered
