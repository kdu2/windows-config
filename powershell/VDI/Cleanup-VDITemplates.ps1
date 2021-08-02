param(
    [string]$searchbase,
    [string]$list
)
$adtemplates = get-adcomputer -searchbase "$searchbase" -filter 'name -like "it*"' -properties description

$templates = get-content $list

foreach ($pc in $adtemplates) {
  $template = $pc.description.replace("Internal Template account. Can be deleted if vm ","").replace(" does not exist in the VC","")
  #if ($templates -contains $template) {
  #   Write-Host "Active template $pc.name" -Foregroundcolor Green
  #}
  #
  if ($templates -notcontains $template) {
    Write-Host "Deleting $pc.name" -Foregroundcolor Cyan
    #Remove-ADComputer $pc
  }
  #>
}
