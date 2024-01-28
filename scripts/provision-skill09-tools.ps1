choco install -y git

choco install -y openjdk --version=21.0.1

choco install -y maven

Install-ChocolateyZipPackage -PackageName 'openjfx' -Url 'https://download2.gluonhq.com/openjfx/21.0.1/openjfx-21.0.1_windows-x64_bin-sdk.zip' -UnzipLocation "C:\Program Files\Java\" -Checksum "01d111605367bef6025928e8cf66afb9c949036799b7b3d3d51cde63fc4c2e29" -ChecksumType "sha256"

$ErrorActionPreference = 'Stop';
$url        = 'https://github.com/gluonhq/scenebuilder/releases/download/21.0.1/SceneBuilder-21.0.1.msi'

$packageArgs = @{
  packageName   = "scenebuilder"
  unzipLocation = $toolsDir
  fileType      = 'msi'
  url           = $url

  softwareName  = 'SceneBuilder*'

  checksum      = 'f59e69237ed2917d1db758fdd16a248784404651ab3a01a802f86eceb995aa0b'
  checksumType  = 'sha256'

  silentArgs    = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`""
  validExitCodes= @(0)
}

Install-ChocolateyPackage @packageArgs

choco install -y mysql

choco install -y sql-server-express

choco install -y sql-server-management-studio

choco install -y intellijidea-community

choco install visualstudio2022community -y --allWorkloads --includeRecommended