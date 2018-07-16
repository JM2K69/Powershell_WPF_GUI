[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\ControlzEx.dll')       | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.IconPacks.dll') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.IconPacks.FontAwesome.dll') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') | out-null
Add-Type -AssemblyName "System.Windows.Forms"
Add-Type -AssemblyName "System.Drawing"
[System.Windows.Forms.Application]::EnableVisualStyles()

#########################################################################
#                        Load Main Panel                                #
#########################################################################

$Global:pathPanel= split-path -parent $MyInvocation.MyCommand.Definition

function LoadXaml ($filename){
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}
$XamlMainWindow=LoadXaml($pathPanel+"\Main.xaml")
$reader = (New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form = [Windows.Markup.XamlReader]::Load($reader)


#########################################################################
#                        HAMBURGER VIEWS                                #
#########################################################################

#******************* Item in the menu  *****************
$Installed      		= $Form.FindName("Installed")
$Updated      			= $Form.FindName("Updated")
$InstalleOne      		= $Form.FindName("InstalleOne")

#******************* Generral controls  *****************
$TabMenuHamburger 	= $Form.FindName("TabMenuHamburger")

#******************* Load Other Views  *****************
$viewFolder = $pathPanel +"\views"

$XamlChildWindow = LoadXaml($viewFolder+"\Installed.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$Installed_Xaml  = [Windows.Markup.XamlReader]::Load($Childreader)
$Installed.Children.Add($Installed_Xaml)        		 | Out-Null

$XamlChildWindow = LoadXaml($viewFolder+"\InstalleOne.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$InstalleOne_Xaml    = [Windows.Markup.XamlReader]::Load($Childreader)
$InstalleOne.Children.Add($InstalleOne_Xaml )	   		 | Out-Null

$XamlChildWindow = LoadXaml($viewFolder+"\Updated.xaml")
$Childreader     = (New-Object System.Xml.XmlNodeReader $XamlChildWindow)
$Updated_Xaml    = [Windows.Markup.XamlReader]::Load($Childreader)
$Updated.Children.Add($Updated_Xaml )	   		 | Out-Null


$XamlMainWindow.SelectNodes("//*[@Name]") | %{
    try {Set-Variable -Name "$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop}
    catch{throw}
	}
#******************************************************
# Initialize with the first value of Item Section *****
#******************************************************

$TabMenuHamburger.SelectedItem = $TabMenuHamburger.ItemsSource[0]

#########################################################################
#                        HAMBURGER EVENTS                               #
#########################################################################


#******************* Items Section  *******************
# Controls for Connection part
$DataGrid_Installed 	 = $Installed_Xaml.FindName("DataGrid_Installed")
$FindInstallModule 		 = $Installed_Xaml.FindName("FindIM")
$NBInstallModule 		 = $Installed_Xaml.FindName("NBModInstall")

$UpdatedMod				 = $Updated_Xaml.FindName("Update")
$FindUpdatedMod			 = $Updated_Xaml.FindName("Find")
$DataGrid_Updated 		 = $Updated_Xaml.FindName("DataGrid_Updated")
$NBupdateModule 		 = $Updated_Xaml.FindName("NBUpdateMod")
$Scopes 				 = $Updated_Xaml.FindName("Scopes")

$NameModules		 	 =$InstalleOne_Xaml.FindName("Name")
$VersNameModules		 =$InstalleOne_Xaml.FindName("Version")
$FindMModules		 	 =$InstalleOne_Xaml.FindName("FindM")
$InstallMModules		 =$InstalleOne_Xaml.FindName("InstallM")
$Author 				 =$InstalleOne_Xaml.FindName("Author")
$Description			 =$InstalleOne_Xaml.FindName("Description")

#########################################################################
#                        Variables                                      #
#########################################################################
$verboseLogFile = "WinUpdModule.log"
$Scopes.IsChecked = $false

#########################################################################
#                       Functions       								#
#########################################################################
Function New-Log {
    param(
    [Parameter(Mandatory=$true)]
    [String]$message
    )
	$logMessage = [System.Text.Encoding]::UTF8
    $timeStamp = Get-Date -Format "MM-dd-yyyy_HH:mm:ss"
	$logMessage = "[$timeStamp] $message"
	
    $logMessage | Out-File -Append -LiteralPath $verboseLogFile 
}

function Update-MyModule {
	[CmdletBinding()]
    Param
    (
        [switch]$AllUsers
	)


	if ($AllUsers.IsPresent)
	{
		Get-Module -ListAvailable |
		Where-Object ModuleBase -like $env:ProgramFiles\WindowsPowerShell\Modules\* |
		Sort-Object -Property Name, Version -Descending |
		Get-Unique -PipelineVariable Module |
		ForEach-Object {

        Find-Module -Name $_.Name -OutVariable Repo -ErrorAction SilentlyContinue |
        Compare-Object -ReferenceObject $_ -Property Name, Version |
        Where-Object SideIndicator -eq '=>' |
        Select-Object -Property Name,
                                Version,
                                @{label='Repository';expression={$Repo.Repository}},
                                @{label='Installed';expression={$Module.Version}}
}

	}
	else{	

		Get-Module -ListAvailable |
		Where-Object ModuleBase -like $env:USERPROFILE\documents\WindowsPowershell\Modules\* |
		Sort-Object -Property Name, Version -Descending |
		Get-Unique -PipelineVariable Module |
		ForEach-Object {
				Find-Module -Name $_.Name -OutVariable Repo -ErrorAction SilentlyContinue |
				Compare-Object -ReferenceObject $_ -Property Name, Version |
				Where-Object SideIndicator -eq '=>' |
				Select-Object -Property Name,
										Version,
										@{label='Repository';expression={$Repo.Repository}},
										@{label='Installed';expression={$Module.Version}}
		}

	}

}
#########################################################################
#                        Controls                                       #
#########################################################################
$TabMenuHamburger.add_ItemClick({
	$TabMenuHamburger.Content = $TabMenuHamburger.SelectedItem
	$TabMenuHamburger.IsPaneOpen = $false
})
New-Log "####################################"
New-Log "# Windows Update Module Starting   #"
New-Log "####################################"


$FindInstallModule.add_Click({
	New-Log "####################################"
	New-Log "# Find PowerShell Module on $Env:COMPUTERNAME   #"
	New-Log "####################################"
	$InstalledModule = Get-InstalledModule
	$NbModInstalled = $InstalledModule.count
	New-log "We found $NbModInstalled installed module"
	$NBInstallModule.Content = $NbModInstalled
	foreach ($Value in $InstalledModule)
				{
					$ModuleName = $Value.Name
					$ModuleVersion = $Value.Version
					New-log "We find the $ModuleName with the version $ModuleVersion"
					$PowerMod_values = New-Object PSObject
					$PowerMod_values = $PowerMod_values | Add-Member NoteProperty Name $Value.Name -passthru
					$PowerMod_values = $PowerMod_values | Add-Member NoteProperty Version $Value.Version -passthru
					$PowerMod_values = $PowerMod_values | Add-Member NoteProperty Repository $Value.Repository -passthru
					$DataGrid_Installed.Items.Add($PowerMod_values) > $null
				}

})
$FindUpdatedMod.add_Click({
	[System.Windows.Forms.Application]::DoEvents()
	[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Process begin","Be patient it depends on the number of modules and your Internet speed." )
	[System.Windows.Forms.Application]::DoEvents()


	If ($Scopes.IsChecked -eq $false)
	{
		$Global:ModulestoUpdateU = Update-MyModule
		$nbMod = $Global:ModulestoUpdateU.count
		$NBupdateModule.Content = $nbMod
		foreach($Value in $Global:ModulestoUpdateU)
			{
				$DataGrid_Updated.Items.Add($Value) > $null

			}

	}
	Else
	{
		$Global:ModulestoUpdateA = Update-MyModule -AllUsers
		$nbMod = $Global:ModulestoUpdateA.count
		$NBupdateModule.Content = $nbMod
		foreach($Value in $Global:ModulestoUpdateA)
			{
				$DataGrid_Updated.Items.Add($Value) > $null

			}

	}
	[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Form, "Process Finished", "Thank you...;)")

})

$UpdatedMod.add_Click({

	If ($Scopes.IsChecked -eq $false)
	{
		$Global:ModulestoUpdateU | ForEach-Object {Install-Module -Name $_.Name -Force}
	}
	Else
	{
		$Global:ModulestoUpdateA = Update-MyModule -AllUsers
		$nbMod = $Global:ModulestoUpdateA.count
		$NBupdateModule.Content = $nbMod
		$Global:ModulestoUpdateA | ForEach-Object {Install-Module -Name $_.Name -Force}
	}

})
$Scopes.add_Click({

		$DataGrid_Updated.Items.Clear()
		$DataGrid_Updated.Items.Refresh()
		$NBupdateModule.Content= ""

		If ($Scopes.IsChecked -eq $false)
	{

	[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Form, "Change scope", "Path where module will be update $env:USERPROFILE\documents\WindowsPowershell\Modules\ (Recommended)")
	}
	Else
	{

	[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Form, "Change scope", "Path where module will be update $env:ProgramFiles\WindowsPowerShell\Modules\. And need ADMINISTRATOR RIGHT!!")
	}

})
$FindMModules.add_Click({

	$NameModules.Text

	$Module = Find-Module -Name $NameModules.Text -AllVersions

		foreach ($value in $Module)
			{
					$PowerMod_values = New-Object PSObject
					$PowerMod_values = $PowerMod_values | Add-Member NoteProperty Name $Value.Version -passthru
					$VersNameModules.Items.Add($PowerMod_values.Name) > $null
			}
	$VersNameModules.SelectedIndex = 0
	$Author.Content = $Module.Author[0]
	$Description.Content =$Module.Description[0]

})
$InstallMModules.add_Click({

	Install-module -name $NameModules.Text -MaximumVersion $VersNameModules.SelectionBoxItem
	$Module = $NameModules.Text
	$Version = $VersNameModules.SelectionBoxItem

	[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Form, "Install Module", "The Module $Module is install with the version $Version")

})
$Form.ShowDialog() | Out-Null
