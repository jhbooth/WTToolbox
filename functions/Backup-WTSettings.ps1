
#create backup copies of the Windows Terminal settings.json file

<#
    .SYNOPSIS
        A brief description of the Backup-WTSetting function.
    
    .DESCRIPTION
        A detailed description of the Backup-WTSetting function.
    
    .PARAMETER Limit
        how many backup copies should be saved
    
    .PARAMETER Destination
        backup folder
    
    .PARAMETER Passthru
        A description of the Passthru parameter.
    
    .EXAMPLE
        PS C:\> Backup-WTSetting
    
    .NOTES
        Additional information about the function.
#>
function Backup-WTSetting
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [int]$Limit = 10,
        [Parameter(Mandatory = $true,
                   HelpMessage = 'Specify the backup location. It must already exist.')]
        [ValidateScript({ Test-Path $_ })]
        [string]$Destination,
        [switch]$Passthru
    )
    
    Write-Verbose "[$((Get-Date).TimeofDay)] Starting $($myinvocation.MyCommand)"
    $json = "$ENV:Userprofile\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    
    if (Test-Path $json)
    {
        
        Write-Verbose "[$((Get-Date).TimeofDay)] Backing up $json to $Destination"
        
        [array]$bak = Get-ChildItem -path $Destination\settings.bak.*.json | Where-Object {$_.Name -match 'settings\.bak\.\d{3}\.json'} | Sort-Object
        
        if ($bak.count -eq 0)
        {
            Write-Verbose "[$((Get-Date).TimeofDay)] Creating first backup copy."
            [int]$new = 1
        }
        else
        {
            $bak | Select-Object -ExpandProperty Name | ForEach-Object{Write-Debug $_}
            #get the numeric value
            [int]$counter = ([regex]"\d+").match($bak[-1]).value
            Write-Verbose "[$((Get-Date).TimeofDay)] Last backup is #$counter"
            
            [int]$new = $counter + 1
            Write-Verbose "[$((Get-Date).TimeofDay)] Creating backup copy #$('{0:d3}' -f $new)"
        }
        
        $backup = Join-Path -path $Destination -ChildPath ('settings.bak.{0:d3}.json' -f $new)
        
        Write-Verbose "[$((Get-Date).TimeofDay)] Creating backup $backup"
        
        Copy-Item -Path $json -Destination $backup
        
        #update the list of backups sorted by age and delete extras
        Write-Verbose "Removing any extra backup files over the limit of $Limit"
        
        Get-ChildItem -path $Destination\settings.bak.*.json |
        Where-Object { $_.Name -match 'settings\.bak\.\d{3}\.json' } |
        Sort-Object -Descending |
        Select-Object -Skip $Limit | Remove-Item
        
    }
    else
    {
        Write-Warning "Failed to find expected settings file $json"
    }
    Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($myinvocation.MyCommand)"
}