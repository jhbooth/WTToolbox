

Function Test-WTVersion
{
    [CmdletBinding()]
    [OutputType([boolean])]
    param
    (
        [switch]$Update
    )
    
    Write-Verbose "[$((Get-Date).TimeofDay)] Starting $($myinvocation.MyCommand)"
    Write-Verbose "[$((Get-Date).TimeofDay)] Get the currently installed application"
    $pkg = Get-AppxPackage -Name Microsoft.WindowsTerminalPreview
    
    if ($pkg)
    {
        
        #get the version number
        [version]$current = $pkg.Version
        Write-Verbose "[$((Get-Date).TimeofDay)] Found version $current"
        #check for previous version file
        $verFile = Join-Path -path $home -ChildPath wtver.json
        Write-Verbose "[$((Get-Date).TimeofDay)] Testing for version tracking file $verFile"
        
        if (Test-Path -path $verfile)
        {
            Write-Verbose "[$((Get-Date).TimeofDay)] Comparing versions"
            $in = Get-Content -Path $verFile | ConvertFrom-Json
            $previous = $in.VersionString -as [version]
            
            Write-Verbose "[$((Get-Date).TimeofDay)] Comparing stored version $previous with current version $current"
            if ($current -gt $previous)
            {
                Write-Verbose "[$((Get-Date).TimeofDay)] A newer version of Windows Terminal has been detected."
                $True
            }
            else
            {
                Write-Verbose "[$((Get-Date).TimeofDay)] Windows Terminal is up to date."
                $False
            }
        }
        
        if ($Update -or (!(Test-Path -Path $verFile)))
        {
            #create the json file, adding the version as a string which makes it easier to reconstruct
            Write-Verbose "[$((Get-Date).TimeofDay)] Writing current information to $verFile."
            $current | Select-Object *,
                                     @{ Name = "VersionString"; Expression = { $_.tostring() } },
                                     @{ Name = "Date"; Expression = { (Get-Date).DateTime } } |
            ConvertTo-Json | Out-File -FilePath $verfile -Encoding ascii -Force
        }
        
    } # if package found
    else
    {
        Throw "Windows Terminal is not installed."
    }
    Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($myinvocation.MyCommand)"
} #close function