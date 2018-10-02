#========================================================================
#
# Tool Name	: Pwsh Tweets Apps
# Author 	: Jérôme Bezet-Torres
# Date 		: 29/09/2018
# Website	: http://JM2K69.github.io/
# Twitter	: https://twitter.com/JM2K69
#
#========================================================================

##Initialize######
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       			| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MaterialDesignThemes.Wpf.dll') 			| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MaterialDesignColors.dll')       			| out-null
[String]$ScriptDirectory = split-path $myinvocation.mycommand.path

function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml("$ScriptDirectory\main.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)


$XamlMainWindow.SelectNodes("//*[@Name]") | %{
    try {Set-Variable -Name "$("WPF_"+$_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop}
    catch{throw}
    }
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable *WPF*
}
  #Get-FormVariables

###################### Twitter Configuration Application #################
$ConsumerKey       = 'FakeKey299EBHjrZ3p8';
$ConsumerSecret    = 'FakeKeyR0MIX37XEy8EsccpaRdrtS9q7rulK8SBux0y';
$AccessToken       = 'FakeKeypWcDm2MWoSHUJdeI3zsp4PyaMS6ypneGemi';
$AccessSecret      = 'FakeKey4iA7YSF3eAWk710SkOWNYoiY';
 ###################### End Twitter Configuration ########################


#########################################################################
#                       Functions       								#
#########################################################################

$WPF_TweetB.add_Click({

    if (Get-Module -ListAvailable -Name PoshTwit) 
    {
        $TT = $WPF_Tweet_txt.Text
       
        Publish-Tweet -Tweet $TT -ConsumerKey $ConsumerKey -ConsumerSecret $ConsumerSecret -AccessToken $AccessToken -AccessSecret $AccessSecret 	

    } 
    else 
    {
        [MahApps.Metro.Controls.Dialogs.DialogManager]::ShowModalMessageExternal($Form,"Oups ;-(", "The Powershell Module PoshTwit isn't present.Please Install it ( Install-module -name PoshTwit -scope CurrentUser ).")
        Exit
    }
    
})
$WPF_Facebook_G.add_Click({

 Start-Process https://www.facebook.com/groups/PowershellGUI/

})

$WPF_Twitter_P.add_Click({

start-process https://twitter.com/JM2K69 

})
$WPF_Youtube_P.add_Click({

    Start-Process https://www.youtube.com/channel/UCw0FgKxddLugh9EpxccqZ4Q
})
$WPF_Youtube_Chaine.add_Click({

    Start-Process https://www.youtube.com/channel/UCw0FgKxddLugh9EpxccqZ4Q

})
$WPF_Github_P.add_Click({
   
    Start-Process https://github.com/JM2K69
})
$WPF_Github_P2.add_Click({
    
    Start-Process https://github.com/JM2K69

})
$WPF_Website.add_Click({

    if ($WPF_Website.IsChecked -eq $true)
    {
        Start-Process https://JM2K69.github.io

    }
})
$Form.ShowDialog() | Out-Null

