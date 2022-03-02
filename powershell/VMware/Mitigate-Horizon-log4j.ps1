$messagebus = (Get-ItemProperty -Path 'HKLM:\VMware, Inc.\VMware VDM\plugins\wsnm\MessageBus\Params' -Name JvmOptions).JvmOptions
$tomcat = (Get-ItemProperty -Path 'HKLM:\VMware, Inc.\VMware VDM\plugins\wsnm\TomcatService\Params' -Name JvmOptions).JvmOptions
$tunnel = (Get-ItemProperty -Path 'HKLM:\VMware, Inc.\VMware VDM\plugins\wsnm\TunnelService\Params' -Name JvmOptions).JvmOptions

Set-ItemProperty -Path 'HKLM:\VMware, Inc.\VMware VDM\plugins\wsnm\MessageBus\Params' -Name JvmOptions2 -Value "$messagebus -Dlog4j2.formatMsgNoLookups=true"
Set-ItemProperty -Path 'HKLM:\VMware, Inc.\VMware VDM\plugins\wsnm\MessageBus\Params' -Name JvmOptions2 -Value "$tomcat -Dlog4j2.formatMsgNoLookups=true"
Set-ItemProperty -Path 'HKLM:\VMware, Inc.\VMware VDM\plugins\wsnm\MessageBus\Params' -Name JvmOptions2 -Value "$tunnel -Dlog4j2.formatMsgNoLookups=true"
