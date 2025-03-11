# check if script is running as admnin
$runAsAdmin = [System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin = $runAsAdmin.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

# if not, relaunch
if (-not $isAdmin) {
    Write-Host "This script requires administrator privileges. Restarting with elevation..."
    Start-Process powershell -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# define target
$target = "192.168.1.0"

# test if pingable
Write-Host "Pinging $target to check connectivity..."
$pingResult = Test-Connection -ComputerName $target -Count 1 -Quiet

if ($pingResult) {
    Write-Host "Ping successful. Proceeding with further checks..." -ForegroundColor Green
} else {
    Write-Host "Ping failed. The device $target is not reachable." -ForegroundColor Red
    exit
}

#check if openssh is installed
Write-Host "Checking if OpenSSH Server is installed..."
$sshInstalled = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'

if ($sshInstalled) {
    Write-Host "OpenSSH Server is installed." -ForegroundColor Green
} else {
    Write-Host "OpenSSH Server is not installed." -ForegroundColor Red
    Write-Host "You can install OpenSSH Server by running the following command:"
    Write-Host "Add-WindowsCapability -Online -Name OpenSSH.Server~~~"
    exit
}

# check if ssh service is running
Write-Host "Checking if SSH service (sshd) is running..."
$sshService = Get-Service -Name sshd -ErrorAction SilentlyContinue

if ($sshService) {
    if ($sshService.Status -eq 'Running') {
        Write-Host "SSH service (sshd) is running." -ForegroundColor Green
    } else {
        Write-Host "SSH service (sshd) is not running. Attempting to start it..." -ForegroundColor Yellow
        Start-Service sshd
        if ($sshService.Status -eq 'Running') {
            Write-Host "SSH service started successfully." -ForegroundColor Green
        } else {
            Write-Host "Failed to start SSH service." -ForegroundColor Red
            exit
        }
    }
} else {
    Write-Host "SSH service (sshd) is not found on the system." -ForegroundColor Red
    exit
}

# test ssh connection on 22
Write-Host "Testing SSH connectivity on port 22..."
$sshTest = Test-NetConnection -ComputerName $target -Port 22

if ($sshTest.TcpTestSucceeded) {
    Write-Host "SSH service is reachable on port 22." -ForegroundColor Green
} else {
    Write-Host "SSH service is not reachable on port 22. Check firewall and service status." -ForegroundColor Red
}

# done
Write-Host "SSH troubleshooting complete." -ForegroundColor Cyan
