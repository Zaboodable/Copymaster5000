Add-Type -AssemblyName PresentationFramework
[System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")

[System.Collections.Hashtable] $Global:strings = [System.Collections.Hashtable]::new()
$Global:strings_path = "$PWD\strings.json"
$icon_path = "$PWD\icon.ico"


#region Functions
#region WPF
function CreateWindow([string]$title)
{
    $window = [System.Windows.Window]::new()
    $window.Title = $title
    return $window
}

function CreateGrid([int]$size_x, [int]$size_y)
{
    $grid = [System.Windows.Controls.Grid]::new()
    for ($x = 0; $x -lt $size_x; $x++)
    {
        $column = [System.Windows.Controls.ColumnDefinition]::new()
        $column.Width = "Auto"
        $grid.ColumnDefinitions.Add($column)
    }
    for ($y = 0; $x -lt $size_y; $y++)
    {
        $row = [System.Windows.Controls.ColumnDefinition]::new()
        $row.Height = "Auto"
        $grid.ColumnDefinitions.Add($row)
    }
    return $grid
}
#endregion WPF
function Parse-JsonFile([string]$file) {
    $text = [IO.File]::ReadAllText($file)
    $parser = New-Object Web.Script.Serialization.JavaScriptSerializer
    $parser.MaxJsonLength = $text.length
    Write-Output -NoEnumerate $parser.DeserializeObject($text)
}
function LoadStrings
{
    # Ensure strings file exists.
    # Create if not
    $exists = Test-Path $Global:strings_path
    if ($exists)
    {
         $Global:strings = Parse-JsonFile $Global:strings_path
        
    }
    else
    {
        # Create blank json file if one does not exist
        $file = New-Item $Global:strings_path
        Write-Output '{' '' '}' >> $file
        LoadStrings        
    }
}

function AddJsonString([string]$identifier, [string]$title,[string]$content,[string]$category,[bool]$favourite)
{
    $data = @($title, $content, $category, $favourite)
    $Global:strings[$identifier] = $data
}
#region UTIL
Function HSLtoRGB ($H,$S,$L) {
    $H = [double]($H / 360)
    $S = [double]($S / 100)
    $L = [double]($L / 100)

     if ($s -eq 0) {
        $r = $g = $b = $l
     }
    else {
        if ($l -lt 0.5){
           $q = $l * (1 + $s) 
        } 
        else {
          $q =  $l + $s - $l * $s
        }
        $p = (2 * $L) - $q
        $r = (Hue2rgb $p $q ($h + 1/3))
        $g = (Hue2rgb $p $q $h )
        $b = (Hue2rgb $p $q ($h - 1/3))
    }

    $r = [Math]::Round($r * 255)
    $g = [Math]::Round($g * 255)
    $b = [Math]::Round($b * 255)

    return ($r,$g,$b)
}


function Hue2rgb ($p, $q, $t) {
    if ($t -lt 0) { $t++ }
    if ($t -gt 1) { $t-- }
    if ($t -lt 1/6) { return ( $p + ($q - $p) * 6 * $t ) }
    if ($t -lt 1/2) { return $q }    
    if ($t -lt 2/3) { return ($p + ($q - $p) * (2/3 - $t) * 6 ) }
    return $p
}

function RGBtoHEX($col)
{
    $r = $col[0]
    $g = $col[1]
    $b = $col[2]
    
    if ($r -lt 0 -or $r -gt 255) { $r = 0 }
    if ($g -lt 0 -or $g -gt 255) { $g = 0 }
    if ($b -lt 0 -or $b -gt 255) { $b = 0 }

    return [string]::Format("#{0:X2}{1:X2}{2:X2}", [int]$r, [int]$g, [int]$b)
}

function HSLtoHEX($values)
{   
    return RGBtoHEX(HSLtoRGB $values[0] $values[1] $values[2])
}
#endregion UTIL
#endregion Functions


#region Interface
$window = CreateWindow "CopyMaster 5000"
$window.WindowStartupLocation = [System.Windows.WindowStartupLocation]::CenterScreen
$window.Width = 360
$window.Height = 512
$window.Icon = $icon_path

$main_dock = [System.Windows.Controls.DockPanel]::new()
$main_dock.Background = "#dddddd"

### LOAD DATA ###
LoadStrings

### CREATE TABS ###
$main_tabs = [System.Windows.Controls.TabControl]::new()

## COLOURS ##
[double]$hue = Get-Random -Minimum 0 -Maximum 360
[double]$hue_step = 4
[double]$sat = 50
[double]$lum= 75

## QUICK COPY TABS [strings.json]##
foreach ($0_key in $Global:strings.Keys)
{
    # Create and configure new tab item
    $0_tabitem = [System.Windows.Controls.TabItem]::new()
    $0_tabitem.Header = $0_key.ToString()
    $0_tabitem.Background ="#ffeeee"
    # add tab to panel
    $main_tabs.AddChild($0_tabitem)

    ## dictionary of content from the json data
    $1_dictionary = $Global:strings[$0_key]

    # Dock panel for tab content parent
    $1_dockpanel = [System.Windows.Controls.DockPanel]::new()
    $1_dockpanel.Background = "#e0e0ff"

    # ScrollViewer to allow scrolling when content extends beyond window
    $1_scrollviewer = [System.Windows.Controls.ScrollViewer]::new()
    [System.Windows.Controls.DockPanel]::SetDock($1_scrollviewer, [System.Windows.Controls.Dock]::Left)
    $1_scrollviewer.HorizontalAlignment="Stretch"
    $1_scrollviewer.VerticalAlignment="Stretch"
    $1_scrollviewer_contentpanel = [System.Windows.Controls.StackPanel]::new()
    $1_scrollviewer.AddChild($1_scrollviewer_contentpanel)
    $1_dockpanel.AddChild($1_scrollviewer)

    ## Loop through each key of the sub-dictionary, these are each individual entries for buttons
    foreach ($1_key in $1_dictionary.Keys)
    {
        # Border for the button
        $1_border = [System.Windows.Controls.Border]::new()
        $1_border.CornerRadius = 2
        $1_border.BorderBrush = "Black"
        $1_border.BorderThickness = 2
        $1_border.Margin = "4 1 4 0"         #margin left top right bottom
        $c = HSLtoRGB $hue $sat $lum
        $hue += $hue_step
        $hc = RGBtoHEX $c
        $1_border.Background = $hc

        # Data for the button
        # Title is shown on the button as a quick reference
        # Copied content is stored in the tooltip
        $button_data = $1_dictionary[$1_key]
        $button_title = $button_data["Title"]
        $button_content = $button_data["Content"]

        # Create and configure the button
        $button = [System.Windows.Controls.Button]::new()
        $button.Content = $button_title
        $button.Padding = "4 4 4 4"
        $button.Tag = $button_id
        $button.Tooltip = $button_content    
        $button.Background = "Transparent"

        # Button click event
        $button.Add_Click({            
            # Copy the tooltip data to the clipboard
            # Update main header for feedback
            Set-Clipboard -Value $this.Tooltip
            $main_header.Content = [string]::Format("Copied:{1}{0}", $this.Tooltip, [Environment]::NewLine)
        })
        
        # Add button to border, and add the whole group to the scrollviewer
        $1_border.AddChild($button)
        $1_scrollviewer_contentpanel.AddChild($1_border)

    }
    # Dont forget to add the dockpanel to the window!
    $0_tabitem.AddChild($1_dockpanel)

}



# Label at the top of the screen for information
$main_header = [System.Windows.Controls.Label]::new()
$main_header.Content = "" 
$main_header_border = [System.Windows.Controls.Border]::new()
$main_header_border.BorderBrush = "Black"
$main_header_border.BorderThickness = 1
$main_header_border.Margin = "1 1 1 1"
$main_header_border.AddChild($main_header)

# Dock main window elements
[System.Windows.Controls.DockPanel]::SetDock($main_header_border, [System.Windows.Controls.Dock]::Bottom)
[System.Windows.Controls.DockPanel]::SetDock($main_tabs, [System.Windows.Controls.Dock]::Top)

# Add main elements to the window
$main_dock.AddChild($main_header_border)
$main_dock.AddChild($main_tabs)
$window.AddChild($main_dock)


#endregion Interface


$window.ShowDialog()
