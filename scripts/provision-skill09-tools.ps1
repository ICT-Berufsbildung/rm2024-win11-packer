choco install -y git

choco install -y openjdk --version=21.0.1

choco install -y maven

$ProgressPreference = 'SilentlyContinue'

Invoke-WebRequest -Uri "https://download2.gluonhq.com/openjfx/21.0.1/openjfx-21.0.1_windows-x64_bin-sdk.zip" -OutFile "$HOME\Desktop\openjfx-21.0.1_windows-x64_bin-sdk.zip"

$programFiles = (${env:ProgramFiles}, ${env:ProgramFiles(x86)} -ne $null)[0]
Expand-Archive -LiteralPath "$HOME\Desktop\openjfx-21.0.1_windows-x64_bin-sdk.zip" -DestinationPath "$programFiles"

[System.Environment]::SetEnvironmentVariable('PATH_TO_FX',"$programFiles\javafx-sdk-21.0.1\lib", 'Machine')

Invoke-WebRequest -Uri "https://github.com/gluonhq/scenebuilder/releases/download/21.0.1/SceneBuilder-21.0.1.msi" -OutFile "$($env:TEMP)\SceneBuilder-21.0.1.msi"

Start-Process msiexec.exe -Wait -ArgumentList "/I $($env:TEMP)\SceneBuilder-21.0.1.msi /qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""

choco install -y mysql

choco install -y sql-server-express

choco install -y sql-server-management-studio

choco install -y intellijidea-community

choco install visualstudio2022community -y --allWorkloads --includeRecommended

choco install visualstudio2022-workload-manageddesktop -y

choco install notepadplusplus -y

choco install vscode -y

choco install dd --pre -y

Copy-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft SQL Server Tools 19\SQL Server Management Studio 19.lnk" "$HOME\Desktop"

Copy-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Visual Studio 2022.lnk" "$HOME\Desktop"
