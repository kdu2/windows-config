param([string]$computername)

# Retrieve the PCoIP network statistics for the client
$networkstats = Get-WmiObject -namespace "root\cimv2" -computername $computername -class Win32_PerfRawData_TeradiciPerf_PCoIPSessionNetworkStatistics

# Retrieve the PCoIP general session statistics for client if any transmitted packets have been lost.
$droppedstats = Get-WmiObject -namespace "root\cimv2" -computername $computername -query "select * from Win32_PerfRawData_TeradiciPerf_PCoIPSessionGeneralStatistics where TXPacketsLost > 0"
