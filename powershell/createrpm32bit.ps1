
<# Require the package, password, repouser and repopass name as parameter to build #>
param (
  [string]$package = $(throw "-package is required."),
  [string]$password = $(throw "-password is required."),
  [string]$repouser = $(throw "-repouser is required."),
  [string]$repopass = $(throw "-repopass is required."),
  [string]$repo = $(throw "-repo is required."),
  [string]$port = $(throw "-port is required.")
)
 
<# Set all required variables. #>
$PackageArray = @("ulyaoth-mbedtls", "ulyaoth-monkey", "ulyaoth-nginx-passenger4", "ulyaoth-nginx-passenger4-selinux", "ulyaoth-nginx-mainline-passenger4", "ulyaoth-nginx-mainline-passenger4-selinux", "ulyaoth-nginx-passenger5", "ulyaoth-nginx-passenger5-selinux", "ulyaoth-nginx-mainline-passenger5", "ulyaoth-nginx-mainline-passenger5-selinux", "ulyaoth-tengine-development-selinux", "ulyaoth-tengine-development", "ulyaoth-tengine-selinux", "ulyaoth-tengine", "ulyaoth-httpdiff-masterbuild", "ulyaoth-solr5-examples", "ulyaoth-solr5-docs", "ulyaoth-solr5", "ulyaoth-banana", "spotify", "ulyaoth", "ulyaoth-nginx", "ulyaoth-nginx-mainline", "ulyaoth-nginx-pagespeed", "ulyaoth-nginx-mainline-pagespeed", "ulyaoth-nginx-pagespeed-selinux", "ulyaoth-nginx-mainline-pagespeed-selinux", "ulyaoth-nginx-modsecurity", "ulyaoth-nginx-naxsi-masterbuild", "ulyaoth-nginx-mainline-naxsi-masterbuild", "ulyaoth-nginx-ironbee-masterbuild", "ulyaoth-kibana4", "ulyaoth-tomcat6", "ulyaoth-tomcat7", "ulyaoth-tomcat8", "ulyaoth-tomcat6-admin", "ulyaoth-tomcat7-admin", "ulyaoth-tomcat8-admin", "ulyaoth-tomcat6-docs", "ulyaoth-tomcat7-docs", "ulyaoth-tomcat8-docs", "ulyaoth-tomcat6-examples", "ulyaoth-tomcat7-examples", "ulyaoth-tomcat8-examples", "ulyaoth-tomcat-native", "ulyaoth-logstash-forwarder-masterbuild", "ulyaoth-fcgiwrap", "ulyaoth-hhvm")
$MachineArray = @{ '51f10cde-56b2-40bd-bc4e-656632d368a8' = '192.168.1.118'; '82b9c8f4-1afe-4bed-a845-7a88b080aefe' = '192.168.1.101'; '7c64ee00-3040-4803-8f6e-4392c6fa6ef8' = '192.168.1.107'; '31d4cc79-4391-44f4-beaa-57292463bc1f' = '192.168.1.112'; '864610ff-9373-4ab1-909a-ba2d25a208cd' = '192.168.1.103'; '1012bcbf-6bce-4312-b39f-0a94096022a6' = '192.168.1.105'; '20f33fac-e9cb-40ed-88b4-f5e0768cfc7b' = '192.168.1.109'; 'a1b5baaf-3cce-4920-9170-eb7a24d09768' = '192.168.1.115'}

<# Set the correct build variable based on package input #>
if ($PackageArray -contains $package)
{
  $build = "wget https://raw.githubusercontent.com/sbagmeijer/ulyaoth/master/Repository/ulyaoth-rpm-build.sh ; chmod +x ulyaoth-rpm-build.sh ; ./ulyaoth-rpm-build.sh -b $package -u $repouser -r $repo -p $port"
}
Else
{
  "Only a supported Ulyaoth repository package can be used as input."
  exit
} 
 
"CHECK 0: a valid package parameter was provide ($package)."
 
 
<# check if the ulyaoth directory exist and if not then create it #>
if(!(Test-Path -Path c:\ulyaoth\createrpm))
  {
   new-item c:\ulyaoth\createrpm -itemtype directory
   "The directory 'c:\ulyaoth\createrpm' was created."
  }
else
  {
   "CHECK 1: c:\ulyaoth\createrpm  directory already exists"
  }
  
  <# check if the plink application exist and if not then download it #>
  if(!(Test-Path -Path c:\ulyaoth\createrpm\plink.exe))
  {
   Invoke-WebRequest -uri https://trash.ulyaoth.net/trash/exe/putty/0.63/plink.exe -Method Get -OutFile c:\ulyaoth\createrpm\plink.exe
   "The program plink was downloaded."
  }
else
  {
   "CHECK 2: putty program is already available"
  }
  
  <# check if the psftp application exist and if not then download it #>
  if(!(Test-Path -Path c:\ulyaoth\createrpm\psftp.exe))
  {
   Invoke-WebRequest -uri https://trash.ulyaoth.net/trash/exe/putty/0.63/psftp.exe -Method Get -OutFile c:\ulyaoth\createrpm\psftp.exe
   "The program psftp was downloaded."
  }
else
  {
   "CHECK 3: psftp program is already available"
  }

ForEach ($buildbox in $MachineArray.GetEnumerator()) 
{
<# Create the virtual machine #>
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" clonevm $buildbox.Name --name buildmachine32 --mode all --options keepallmacs --register
"Creating the virtual machine"

<# If we build ulyaoth-hhvm then give the server more ram and cpus #>
If ($package -Match "ulyaoth-hhvm")
{
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyvm buildmachine32 --vram 8192 --cpus 4
"We are building $package so increasing Memory to 8GB and cpus to 4."
}

<# Start the virtual machine #>
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" startvm buildmachine32
"Starting the virtual machine"
  
<# Sleep for 25 seconds so machine can boot #>
"Sleeping 25 seconds while waiting for the Virtual Machine to boot."
Start-Sleep -Seconds 30

<# ssh into the machine and start the rpm build process #>
"Running the build script"
echo y | c:\ulyaoth\createrpm\plink.exe -ssh -l root $buildbox.Value -pw $password "$build"

<# Poweroff the virtual machine #>
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" controlvm buildmachine32 poweroff
"Stopping the virtual machine"

<# Sleep for 5 seconds so machine can power off #>
"Sleeping 5 seconds while waiting for the Virtual Machine to power off."
Start-Sleep -Seconds 5

<# Delete the virtual machine #>
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" unregistervm --delete buildmachine32
"Deleting the virtual machine"

<# Sleep for 5 seconds before looping again #>
"Sleeping 5 seconds just to make sure the delete operation is finished."
Start-Sleep -Seconds 5
}
