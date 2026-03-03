
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "This script requires administrator privileges. Please re-run it as an administrator."
    exit
}

Write-Host "Starting comprehensive Copilot removal..."

$RegistryPaths = @(
    "HKCU:\Software\Policies\Microsoft\Windows",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
)
$KeyName = "WindowsCopilot"
$ValueName = "TurnOffWindowsCopilot"

foreach ($RegistryPath in $RegistryPaths) {
    $FullPath = Join-Path -Path $RegistryPath -ChildPath $KeyName
    if (-not (Test-Path -Path $FullPath)) {
        New-Item -Path $RegistryPath -Name $KeyName -Force | Out-Null
    }
    Set-ItemProperty -Path $FullPath -Name $ValueName -Value 1 -Type DWord -Force
}

$ExplorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$ExplorerValueName = "ShowCopilotButton"
Set-ItemProperty -Path $ExplorerPath -Name $ExplorerValueName -Value 0 -Type DWord -Force

Write-Host "Disabling Edge Copilot policies..."
$EdgePolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
if (-not (Test-Path -Path $EdgePolicyPath)) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft" -Name "Edge" -Force | Out-Null
}
Set-ItemProperty -Path $EdgePolicyPath -Name "AllowCopilot" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $EdgePolicyPath -Name "ShowHubsSidebar" -Value 0 -Type DWord -Force

Write-Host "Attempting to remove the provisioned Copilot package..."
try {
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like "*Copilot*" } | Remove-AppxProvisionedPackage -Online -ErrorAction Stop | Out-Null
    Write-Host "Successfully removed provisioned package."
} catch {
    Write-Host "Could not remove the provisioned Copilot package or it was not found."
}

Write-Host "Attempting to remove the Copilot application package for all users..."
try {
    Get-AppxPackage -AllUsers -Name "Microsoft.Windows.Copilot" | Remove-AppxPackage -AllUsers -ErrorAction Stop
    Write-Host "Successfully removed the Windows Copilot application package."
} catch {
    Write-Host "Could not remove the Copilot application package or it was not found."
}

Write-Host "Removing Copilot protocol handlers from registry..."
$ProtocolKeys = @(
    "HKCR:\ms-copilot",
    "HKCR:\ms-edge-copilot"
)
foreach ($key in $ProtocolKeys) {
    if (Test-Path $key) {
        try {
            Remove-Item -Path $key -Recurse -Force -ErrorAction Stop
            Write-Host "Removed $key"
        } catch {
            Write-Host "Failed to remove $key. It might be protected or already gone."
        }
    } else {
        Write-Host "$key not found."
    }
}

Write-Host "CoPilot's dumbass is gone. Please restart your computer for all changes to take effect."
Write-Host "After restarting, check Task Manager -> Startup apps for any remaining Copilot entries and disable them manually."
