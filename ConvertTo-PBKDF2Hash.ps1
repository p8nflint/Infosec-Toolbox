function ConvertTo-PBKDF2Hash {
    param(
        [string]$password,
        [string]$salt,
        [int]$iterations,
        [string]$hash,
        [int]$size,
        [string]$keyType
    )

    $saltBytes = [Text.Encoding]::UTF8.GetBytes($salt)

    $hash = [System.Security.Cryptography.HashAlgorithmName]::$hash

    try {
        $pbkdf2 = New-Object System.Security.Cryptography.Rfc2898DeriveBytes $password, $saltBytes, $iterations, $hash
        $keyBytes = $pbkdf2.GetBytes($size)

        $keyBase64 = [System.Convert]::ToBase64String($keyBytes)
        $keyHex =    [System.BitConverter]::ToString($keyBytes) -replace "-", ""
        
        # normalize case
        $keyType = $keyType.ToLower()
        
        If ($keyType -eq "base64") {
            return $keyBase64
        } ElseIf ( $keyType -eq "hex") {
            return $keyHex
        } Else {
            Write-Host -ForegroundColor Red "Please specify key type (Base64/Hex)."
        }

    } catch {
        Write-Host "Error: $_.Exception.Message"
    }
}

# Example usage:
$derivedKey = ConvertTo-PBKDF2Hash -password "myPassword" -salt "OyD,2b~1&|eQ1XS^Rx%ZyDyG" -iterations 1024 -hash "SHA256" -size 32 -keyType "base64"

$derivedKey
