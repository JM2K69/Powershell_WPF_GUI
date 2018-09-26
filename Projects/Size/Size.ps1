#########################################################################
#                        Add shared_assemblies                          #
#########################################################################

[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')      | out-null  
[System.Reflection.Assembly]::LoadFrom('assembly\dev4sys.Tree.dll')      | out-null 
[System.Reflection.Assembly]::LoadFrom('assembly\LiveCharts.dll')      | out-null 
[System.Reflection.Assembly]::LoadFrom('assembly\LiveCharts.Wpf.dll')      | out-null 
[System.Reflection.Assembly]::LoadFrom('assembly\ControlzEx.dll')      | out-null 
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.IconPacks.dll') | out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.IconPacks.FontAwesome.dll') | out-null



#########################################################################
#                        Load Main Panel                                #
#########################################################################

$Global:pathPanel= split-path -parent $MyInvocation.MyCommand.Definition
function LoadXaml ($filename){
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}
$XamlMainWindow=LoadXaml($pathPanel+"\main.xaml")
$reader = (New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form = [Windows.Markup.XamlReader]::Load($reader)

$okAndCancel = [MahApps.Metro.Controls.Dialogs.MessageDialogStyle]::AffirmativeAndNegative
$FolderTree     = $Form.FindName("TreeView")
$Size           = $Form.FindName("Size")
$Clear          = $form.FindName("Clear")
$LetterDisk     = $form.FindName("LetterDisk") 
$BadgeMod_S		= $Form.FindName("B_Add")
$Github 		= $Form.FindName("Github")

function Get-diskletter {
    $Global:Letter = get-volume | Where-Object {$_.DriveType -eq 'Fixed'} | Sort-Object -Property DriveLetter
}
function Start-Scan {
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # Description d’aide param1
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true)]
        $DriveLetter
    )
    begin
        {
            $DriveLetterf = $DriveLetter +":\"

        }
    process
        {
            $dummyNode = $null
            $AllDirectory = [IO.Directory]::GetDirectories($DriveLetterf)

            # ================== Handle Folders ===========================
            $Global:TabHashTable = New-Object System.Collections.ArrayList
            $Global:TabHashTable2 = New-Object System.Collections.ArrayList
            foreach ($folder in $AllDirectory)
            {

                $treeViewItem = [Windows.Controls.TreeViewItem]::new()
                $treeViewItem.Header = $folder.Substring($folder.LastIndexOf("\") + 1)
                $treeViewItem.Tag = @("folder",$folder)
                $treeViewItem.Items.Add($dummyNode) | Out-Null
                $treeViewItem.Add_Expanded({
                    $Global:TabHashTable.Add($_.OriginalSource.Header)
                    TreeExpanded($_.OriginalSource)
                    $BadgeMod_S.Badge = $BadgeMod_S.Badge + 1

                })
                $FolderTree.Items.Add($treeViewItem)| Out-Null
            }
        }
    end
        {

        }
}

#########################################################################
#                        Stuff                                          #
#########################################################################
Get-diskletter

foreach ($item in $Global:Letter) {
    if ($item.DriveLetter -ne $null){
        $LetterDisk.Items.Add($item.DriveLetter) |out-null
    }          
}
$LetterDisk.SelectedIndex = 0
$Global:DiskLetter =  "C"
Start-Scan -DriveLetter C
Function TreeExpanded($sender){
    
    $item = [Windows.Controls.TreeViewItem]$sender
    
    If ($item.Items.Count -eq 1 -and $item.Items[0] -eq $dummyNode)
    {
        $item.Items.Clear();
        Try
        {
            
            foreach ($string in [IO.Directory]::GetDirectories($item.Tag[1].ToString()))
            {
                $subitem = [Windows.Controls.TreeViewItem]::new();
                $subitem.Header = $string.Substring($string.LastIndexOf("\") + 1)
                $subitem.Tag = @("folder",$string)
                $subitem.Items.Add($dummyNode)
                $subitem.Add_Expanded({
                    TreeExpanded($_.OriginalSource)

                })
                $item.Items.Add($subitem) | Out-Null
            }
        }
        Catch [Exception] { }
    }

}
$Github.Add_Click({

    Start-Process https://github.com/JM2K69

})

$Size.add_Click({
   
  
[xml]$xaml = @"
<Controls:MetroWindow
xmlns:Controls="clr-namespace:MahApps.Metro.Controls;assembly=MahApps.Metro"
xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
xmlns:lvc="clr-namespace:LiveCharts.Wpf;assembly=LiveCharts.Wpf"
Title="Folder Size" Height="400" Width="600"
WindowStartupLocation="CenterScreen" Topmost="True">
<Window.Resources>
    <ResourceDictionary>
        <ResourceDictionary.MergedDictionaries>
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Controls.xaml" />
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Fonts.xaml" />
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Colors.xaml" />
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Accents/Blue.xaml" />
            <ResourceDictionary Source="pack://application:,,,/MahApps.Metro;component/Styles/Accents/BaseLight.xaml" />
            </ResourceDictionary.MergedDictionaries>
    </ResourceDictionary>
</Window.Resources>
<Grid >
<StackPanel Orientation="Vertical" >
    <lvc:CartesianChart Series="{Binding SeriesCollection}" x:Name="CartesianChart" Width="550" Height="300">
        <lvc:CartesianChart.DataTooltip>
            <lvc:DefaultTooltip BulletSize="20"/>
        </lvc:CartesianChart.DataTooltip>
        <lvc:CartesianChart.AxisX>
            <lvc:Axis Title="Folders" Labels="{Binding}" FontSize="14" Foreground="Black"></lvc:Axis>
        </lvc:CartesianChart.AxisX>
        <lvc:CartesianChart.AxisY>
            <lvc:Axis Title="Size (Go)" FontSize="14" Foreground="Black"></lvc:Axis>
        </lvc:CartesianChart.AxisY>
    </lvc:CartesianChart> 
    <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" >
    <Button Name="Save" Margin="10" Width="60" Height="30" ToolTip="Export to PNG">Save</Button>
    <Button Name="Excel" Margin="10" Width="60" Height="30" ToolTip="Export to CSV">Export</Button>
    </StackPanel>
    </StackPanel>
</Grid>
</Controls:MetroWindow>
"@
    
    
    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $Window = [Windows.Markup.XamlReader]::Load( $reader )

    $Global:TabHashTable2 = $Global:TabHashTable | Foreach-Object {
        $name = "$Global:DiskLetter"+":\" + "$_"
        [PscustomObject]@{
            Path = [string]$(Split-Path -Path $name -Leaf)
            Size = (Get-ChildItem -Path $name -File -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB
        }
    } | Sort-Object -Property Size -Descending
    
    $chart  = $Window.FindName('CartesianChart')
    $Save   = $Window.FindName('Save')
    $Excel   = $Window.FindName('Excel')

    $Column = [LiveCharts.Wpf.ColumnSeries]::new()
    $CHartValues = [LiveCharts.ChartValues[int]]$Global:TabHashTable2.Size
    $Column.Title = 'Size'
    $Column.Values = $CHartValues
    $Column.MaxColumnWidth = 20
    
    $SeriesCollection = [LiveCharts.SeriesCollection]::new()
    $SeriesCollection.Add($Column)
    
    $chart.Series = $SeriesCollection
    
        $Chart.AxisX[0].Labels = [String[]]$Global:TabHashTable2.Path
    #########################
Function New-ScreenShot { 
    <#   
.SYNOPSIS   
    Used to take a screenshot of the desktop or the active window.  
.DESCRIPTION   
    Used to take a screenshot of the desktop or the active window and save to an image file if needed. 
.PARAMETER screen 
    Screenshot of the entire screen 
.PARAMETER activewindow 
    Screenshot of the active window 
.PARAMETER file 
    Name of the file to save as. Default is image.bmp 
.PARAMETER imagetype 
    Type of image being saved. Can use JPEG,BMP,PNG. Default is bitmap(bmp)   
.PARAMETER print 
    Sends the screenshot directly to your default printer       
.INPUTS 
.OUTPUTS     
.NOTES   
    Name: Take-ScreenShot 
    Author: Boe Prox 
    DateCreated: 07/25/2010      
.EXAMPLE   
    Take-ScreenShot -activewindow 
    Takes a screen shot of the active window         
.EXAMPLE   
    Take-ScreenShot -Screen 
    Takes a screenshot of the entire desktop 
.EXAMPLE   
    Take-ScreenShot -activewindow -file "C:\image.bmp" -imagetype bmp 
    Takes a screenshot of the active window and saves the file named image.bmp with the image being bitmap 
.EXAMPLE   
    Take-ScreenShot -screen -file "C:\image.png" -imagetype png     
    Takes a screenshot of the entire desktop and saves the file named image.png with the image being png 
.EXAMPLE   
    Take-ScreenShot -Screen -print 
    Takes a screenshot of the entire desktop and sends to a printer 
.EXAMPLE   
    Take-ScreenShot -ActiveWindow -print 
    Takes a screenshot of the active window and sends to a printer     
#>   
#Requires -Version 2 
        [cmdletbinding( 
                SupportsShouldProcess = $True, 
                DefaultParameterSetName = "screen", 
                ConfirmImpact = "low" 
        )] 
Param ( 
       [Parameter( 
            Mandatory = $False, 
            ParameterSetName = "screen", 
            ValueFromPipeline = $True)] 
            [switch]$screen, 
       [Parameter( 
            Mandatory = $False, 
            ParameterSetName = "window", 
            ValueFromPipeline = $False)] 
            [switch]$activewindow, 
       [Parameter( 
            Mandatory = $False, 
            ParameterSetName = "", 
            ValueFromPipeline = $False)] 
            [string]$file,  
       [Parameter( 
            Mandatory = $False, 
            ParameterSetName = "", 
            ValueFromPipeline = $False)] 
            [string] 
            [ValidateSet("bmp","jpeg","png")] 
            $imagetype = "bmp", 
       [Parameter( 
            Mandatory = $False, 
            ParameterSetName = "", 
            ValueFromPipeline = $False)] 
            [switch]$print                        
        
) 
# C# code 
$code = @' 
using System; 
using System.Runtime.InteropServices; 
using System.Drawing; 
using System.Drawing.Imaging; 
namespace ScreenShotDemo 
{ 
  /// <summary> 
  /// Provides functions to capture the entire screen, or a particular window, and save it to a file. 
  /// </summary> 
  public class ScreenCapture 
  { 
    /// <summary> 
    /// Creates an Image object containing a screen shot the active window 
    /// </summary> 
    /// <returns></returns> 
    public Image CaptureActiveWindow() 
    { 
      return CaptureWindow( User32.GetForegroundWindow() ); 
    } 
    /// <summary> 
    /// Creates an Image object containing a screen shot of the entire desktop 
    /// </summary> 
    /// <returns></returns> 
    public Image CaptureScreen() 
    { 
      return CaptureWindow( User32.GetDesktopWindow() ); 
    }     
    /// <summary> 
    /// Creates an Image object containing a screen shot of a specific window 
    /// </summary> 
    /// <param name="handle">The handle to the window. (In windows forms, this is obtained by the Handle property)</param> 
    /// <returns></returns> 
    private Image CaptureWindow(IntPtr handle) 
    { 
      // get te hDC of the target window 
      IntPtr hdcSrc = User32.GetWindowDC(handle); 
      // get the size 
      User32.RECT windowRect = new User32.RECT(); 
      User32.GetWindowRect(handle,ref windowRect); 
      int width = windowRect.right - windowRect.left; 
      int height = windowRect.bottom - windowRect.top; 
      // create a device context we can copy to 
      IntPtr hdcDest = GDI32.CreateCompatibleDC(hdcSrc); 
      // create a bitmap we can copy it to, 
      // using GetDeviceCaps to get the width/height 
      IntPtr hBitmap = GDI32.CreateCompatibleBitmap(hdcSrc,width,height); 
      // select the bitmap object 
      IntPtr hOld = GDI32.SelectObject(hdcDest,hBitmap); 
      // bitblt over 
      GDI32.BitBlt(hdcDest,0,0,width,height,hdcSrc,0,0,GDI32.SRCCOPY); 
      // restore selection 
      GDI32.SelectObject(hdcDest,hOld); 
      // clean up 
      GDI32.DeleteDC(hdcDest); 
      User32.ReleaseDC(handle,hdcSrc); 
      // get a .NET image object for it 
      Image img = Image.FromHbitmap(hBitmap); 
      // free up the Bitmap object 
      GDI32.DeleteObject(hBitmap); 
      return img; 
    } 
    /// <summary> 
    /// Captures a screen shot of the active window, and saves it to a file 
    /// </summary> 
    /// <param name="filename"></param> 
    /// <param name="format"></param> 
    public void CaptureActiveWindowToFile(string filename, ImageFormat format) 
    { 
      Image img = CaptureActiveWindow(); 
      img.Save(filename,format); 
    } 
    /// <summary> 
    /// Captures a screen shot of the entire desktop, and saves it to a file 
    /// </summary> 
    /// <param name="filename"></param> 
    /// <param name="format"></param> 
    public void CaptureScreenToFile(string filename, ImageFormat format) 
    { 
      Image img = CaptureScreen(); 
      img.Save(filename,format); 
    }     
    
    /// <summary> 
    /// Helper class containing Gdi32 API functions 
    /// </summary> 
    private class GDI32 
    { 
       
      public const int SRCCOPY = 0x00CC0020; // BitBlt dwRop parameter 
      [DllImport("gdi32.dll")] 
      public static extern bool BitBlt(IntPtr hObject,int nXDest,int nYDest, 
        int nWidth,int nHeight,IntPtr hObjectSource, 
        int nXSrc,int nYSrc,int dwRop); 
      [DllImport("gdi32.dll")] 
      public static extern IntPtr CreateCompatibleBitmap(IntPtr hDC,int nWidth, 
        int nHeight); 
      [DllImport("gdi32.dll")] 
      public static extern IntPtr CreateCompatibleDC(IntPtr hDC); 
      [DllImport("gdi32.dll")] 
      public static extern bool DeleteDC(IntPtr hDC); 
      [DllImport("gdi32.dll")] 
      public static extern bool DeleteObject(IntPtr hObject); 
      [DllImport("gdi32.dll")] 
      public static extern IntPtr SelectObject(IntPtr hDC,IntPtr hObject); 
    } 
 
    /// <summary> 
    /// Helper class containing User32 API functions 
    /// </summary> 
    private class User32 
    { 
      [StructLayout(LayoutKind.Sequential)] 
      public struct RECT 
      { 
        public int left; 
        public int top; 
        public int right; 
        public int bottom; 
      } 
      [DllImport("user32.dll")] 
      public static extern IntPtr GetDesktopWindow(); 
      [DllImport("user32.dll")] 
      public static extern IntPtr GetWindowDC(IntPtr hWnd); 
      [DllImport("user32.dll")] 
      public static extern IntPtr ReleaseDC(IntPtr hWnd,IntPtr hDC); 
      [DllImport("user32.dll")] 
      public static extern IntPtr GetWindowRect(IntPtr hWnd,ref RECT rect); 
      [DllImport("user32.dll")] 
      public static extern IntPtr GetForegroundWindow();       
    } 
  } 
} 
'@ 
#User Add-Type to import the code 
add-type $code -ReferencedAssemblies 'System.Windows.Forms','System.Drawing' 
#Create the object for the Function 
$capture = New-Object ScreenShotDemo.ScreenCapture 
 
#Take screenshot of the entire screen 
If ($Screen) { 
    Write-Verbose "Taking screenshot of entire desktop" 
    #Save to a file 
    If ($file) { 
        If ($file -eq "") { 
            $file = "$pwd\image.bmp" 
            } 
        Write-Verbose "Creating screen file: $file with imagetype of $imagetype" 
        $capture.CaptureScreenToFile($file,$imagetype) 
        } 
    ElseIf ($print) { 
        $img = $Capture.CaptureScreen() 
        $pd = New-Object System.Drawing.Printing.PrintDocument 
        $pd.Add_PrintPage({$_.Graphics.DrawImage(([System.Drawing.Image]$img), 0, 0)}) 
        $pd.Print() 
        }         
    Else { 
        $capture.CaptureScreen() 
        } 
    } 
#Take screenshot of the active window     
If ($ActiveWindow) { 
    Write-Verbose "Taking screenshot of the active window" 
    #Save to a file 
    If ($file) { 
        If ($file -eq "") { 
            $file = "$pwd\image.bmp" 
            } 
        Write-Verbose "Creating activewindow file: $file with imagetype of $imagetype" 
        $capture.CaptureActiveWindowToFile($file,$imagetype) 
        } 
    ElseIf ($print) { 
        $img = $Capture.CaptureActiveWindow() 
        $pd = New-Object System.Drawing.Printing.PrintDocument 
        $pd.Add_PrintPage({$_.Graphics.DrawImage(([System.Drawing.Image]$img), 0, 0)}) 
        $pd.Print() 
        }         
    Else { 
        $capture.CaptureActiveWindow() 
        }     
    }      
} 

$Save.add_Click({
$TimeStamp = get-date -f MM-dd-yyyy_HH_mm_ss
$File = "Size_" + $TimeStamp +".png"

New-ScreenShot -activewindow -imagetype png -file .\$File

[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMessageAsync($Window, "Information", "The Chart is saved to $File.")

})
$Excel.add_Click({
    $erroractionpreference = "SilentlyContinue"
    $TimeStamp = get-date -f MM-dd-yyyy_HH_mm_ss
    $FileExp = $Global:pathPanel +"\Size_" + $TimeStamp +".xlsx"
    $excel = New-Object -ComObject Excel.Application
    Add-Type -AssemblyName Microsoft.Office.Interop.Excel
    $xlFixedFormat = [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault
    $excel.Visible = $false
    $workbook = $excel.Workbooks.Add()
    $sheet = $workbook.ActiveSheet
    $sheet.cells.item(1,1)= "Directory"
    $sheet.cells.item(1,2)= "Size (Go)"
    $Range = $sheet.UsedRange
    $Range.Interior.ColorIndex = 16
    $Range.Font.ColorIndex = 11
    $Range.Font.Bold= $true
    $intRow = 2
    
    $Global:TabHashTable2 = $Global:TabHashTable | Foreach-Object {
        $name = "$Global:DiskLetter"+":\" + "$_"
        [PscustomObject]@{
            Path = [string]$(Split-Path -Path $name -Leaf)
            Size = (Get-ChildItem -Path $name -File -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB
        }
    } |  Foreach-Object {
        
        $sheet.cells.Item($intRow,1)= $_.Path
        $sheet.cells.Item($intRow,2)= $_.Size
        $intRow++
   
   }
    $excel.ActiveWorkbook.SaveAs("$FileExp" , $xlFixedFormat)
    $excel.Workbooks.Close()
    $excel.Quit()
})
    [void]$Window.ShowDialog()
    


})


$LetterDisk.add_SelectionChanged({
    $BadgeMod_S.Badge = 0
    $Global:DiskLetter =  $LetterDisk.SelectedItem
    $FolderTree.Items.Clear()
    $FolderTree.Refresh
    Start-Scan -DriveLetter $Global:DiskLetter

})

$Clear.add_Click({
    $BadgeMod_S.Badge = 0
    $Global:DiskLetter = "C"
    $FolderTree.Items.Clear()
    $FolderTree.Refresh
    try {
        $Global:TabHashTable2 = @()
        $Global:TabHashTable = @()
    }
    catch {}
    Start-Scan -DriveLetter $Global:DiskLetter

})
#########################################################################
#                        Show window                                    #
#########################################################################

$Form.ShowDialog() | Out-Null
  