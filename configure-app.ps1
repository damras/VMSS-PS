Param (
    #[string]$app_location    
)

# Force use of TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Firewall
netsh advfirewall firewall add rule name="http" dir=in action=allow protocol=TCP localport=80

# Folders
New-Item -ItemType Directory c:\temp
New-Item -ItemType Directory c:\DemoApp

# Install iis
Install-WindowsFeature web-server -IncludeManagementTools


# Install dot.net core sdk
Invoke-WebRequest https://download.visualstudio.microsoft.com/download/pr/9b9f4a6e-aef8-41e0-90db-bae1b0cf4e34/4ab93354cdff8991d91a9f40d022d450/dotnet-hosting-3.1.6-win.exe -outfile c:\temp\dotnet-hosting-3.1.6-win.exe
Start-Process c:\temp\dotnet-hosting-3.1.6-win.exe -ArgumentList '/quiet' -Wait


# Download the demo app
#Invoke-WebRequest  "https://deploymentscriptsdevops.blob.core.windows.net/deployments/vmsswebapp.zip?sp=r&st=2020-08-12T14:29:48Z&se=2030-08-12T22:29:48Z&spr=https&sv=2019-12-12&sr=b&sig=n%2FaGPiV%2BxN0KpDnMOUUXeu4MHjvBfIGEJlmR4oAzcfs%3D" -OutFile c:\temp\DemoApp.zip

Invoke-WebRequest  "https://stspoke1devtestvdc001.blob.core.windows.net/deployments/vmsswebapp.zip?sp=r&st=2020-09-16T08:05:38Z&se=2021-03-30T16:05:38Z&spr=https&sv=2019-12-12&sr=b&sig=zZlUyalQk7xzaR9t7znJVXEWu5sWShygWjjhh6Hh7gg%3D" -OutFile c:\temp\DemoApp.zip

Expand-Archive C:\temp\DemoApp.zip c:\DemoApp

# Azure SQL connection sting in environment variable
#[Environment]::SetEnvironmentVariable("Data:DefaultConnection:ConnectionString", "Server=$sqlserver;Database=MusicStore;Integrated Security=False;User Id=$user;Password=$password;MultipleActiveResultSets=True;Connect Timeout=30",[EnvironmentVariableTarget]::Machine)

# Pre-create database
#$env:Data:DefaultConnection:ConnectionString = "Server=$sqlserver;Database=MusicStore;Integrated Security=False;User Id=$user;Password=$password;MultipleActiveResultSets=True;Connect Timeout=30"
# Start-Process 'C:\Program Files\dotnet\dotnet.exe' -ArgumentList 'c:\DemoApp\webappvmss.dll'

# Configure iis
Remove-WebSite -Name "Default Web Site"
Set-ItemProperty IIS:\AppPools\DefaultAppPool\ managedRuntimeVersion ""
New-Website -Name "DemoApp" -Port 80 -PhysicalPath c:\DemoApp\ -ApplicationPool DefaultAppPool
& iisreset
