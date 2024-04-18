# Retrieve IP list
$ipList = Get-Content "<FILEPATH>"

# Specify path for file Export
$exportPath = "<FILEPATH>"

# Build request headers
$apiKey = "<API KEY>" # Specify API key
$maxAgeInDays = '90'
$verbose = 'true'
$headers = @{
    'Accept' = 'application/json'
    'Key' = $apiKey
}

# Sort, deduplicate, clean the IPs
$ipList = $ipList | Sort-Object
$ipList = $ipList | Select-Object -Unique
$ipList = $ipList | ForEach-Object {
    $_.Replace("Â","").Trim()
}
$ipList = $ipList | Where-Object {$_ -notlike ""}

# Initialize a list object
$ipInfoList = New-Object System.Collections.Generic.List[Object]

foreach ($ip in $ipList) {
    $uri = "https://api.abuseipdb.com/api/v2/check?ipAddress=$ip&maxAgeInDays=$maxAgeInDays&verbose=$verbose"
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

        # Create an ordered custom object based on the response
        $ipInfo = [PSCustomObject][ordered]@{
            IPAddress            = $response.data.ipAddress
            IsPublic             = $response.data.isPublic
            IPVersion            = $response.data.ipVersion
            IsWhitelisted        = $response.data.isWhitelisted
            AbuseConfidenceScore = $response.data.abuseConfidenceScore
            CountryCode          = $response.data.countryCode
            CountryName          = $response.data.countryName
            UsageType            = $response.data.usageType
            ISP                  = $response.data.isp
            Domain               = $response.data.domain
            Hostnames            = ($response.data.hostnames -join ', ')
            IsTor                = $response.data.isTor
            TotalReports         = $response.data.totalReports
            NumDistinctUsers     = $response.data.numDistinctUsers
            LastReportedAt       = $response.data.lastReportedAt
        }
        # Add the custom object to the list
        $ipInfoList.Add($ipInfo)
    } catch {
        Write-Host "Failed to retrieve data for IP: $ip. Error: $_"
    }
}

# If you want to display the array in a more readable format, you can pipe the output to Format-Table
$ipInfoList | Format-Table

# Export file to .CSV
$ipInfoList | Export-Csv -Path $exportPath -Force -NoTypeInformation
