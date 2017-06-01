Get-AppxPackage | % {if (!($_.IsFramework -or $_.PublisherId -eq "cw5n1h2txyewy")) {$_}} | Remove-AppxPackage

Get-AppXProvisionedPackage -online | Remove-AppxProvisionedPackage –online
