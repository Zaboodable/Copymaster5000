Add-Type -AssemblyName PresentationFramework
[System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")

#### TODO ####
# Merge all json into a single file
#### TODO ####
[System.Collections.Hashtable] $Global:strings = [System.Collections.Hashtable]::new()
[System.Collections.Hashtable] $Global:systems = [System.Collections.Hashtable]::new()
[System.Collections.Hashtable] $Global:tips = [System.Collections.Hashtable]::new()
$Global:strings_path = "$PWD\strings.json"
$Global:systems_path = "$PWD\systems.json"
$Global:tips_path = "$PWD\tips.json"
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

#### TODO ####
# Merge all json into a single file
#### TODO ####
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

#### TODO ####
# Merge all json into a single file
#### TODO ####
function LoadSystems
{
    # Ensure system file exists.
    # Create if not
    $exists = Test-Path $Global:systems_path
    if ($exists)
    {
         $Global:systems = Parse-JsonFile $Global:systems_path
        
    }
    else
    {
        # Create blank json file if one does not exist
        $file = New-Item $Global:systems_path
        Write-Output '{' '' '}' >> $file
        LoadStrings        
    }
}

#### TODO ####
# Merge all json into a single file
#### TODO ####
function LoadSystems
{
    # Ensure system file exists.
    # Create if not
    $exists = Test-Path $Global:tips_path
    if ($exists)
    {
         $Global:tips = Parse-JsonFile $Global:tips_path
        
    }
    else
    {
        # Create blank json file if one does not exist
        $file = New-Item $Global:tips_path
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
$window.Width = 800
$window.Height = 512
$window.Icon = $icon_path

$main_dock = [System.Windows.Controls.DockPanel]::new()
$main_dock.Background = "#dddddd"

### LOAD DATA ###
LoadStrings
LoadSystems

### CREATE TABS ###
$main_tabs = [System.Windows.Controls.TabControl]::new()

## COLOURS ##
[double]$hue = Get-Random -Minimum 0 -Maximum 360
[double]$hue_step = 4
[double]$sat = 50
[double]$lum= 75

$Global:color_maintab_header = "#ffffc0"
$Global:color_systemtab_header = "#c0ffff"
$Global:color_systemtab_subheader = "#ffc0ff"
$Global:color_maintab = "#ffffe0"
$Global:color_systemtab= "#e0ffff"
$Global:color_systemtab_sub = "#ffe0ff"

## QUICK COPY TABS [strings.json]##
#region Strings
foreach ($0_key in $Global:strings.Keys)
{
    # Create and configure new tab item
    $0_tabitem = [System.Windows.Controls.TabItem]::new()
    $0_tabitem.Header = $0_key.ToString()
    $0_tabitem.Background =$Global:color_maintab_header
    # add tab to panel
    $main_tabs.AddChild($0_tabitem)

    ## dictionary of content from the json data
    $1_dictionary = $Global:strings[$0_key]

    # Dock panel for tab content parent
    $1_dockpanel = [System.Windows.Controls.DockPanel]::new()
    $1_dockpanel.Background = $Global:color_maintab

    # ScrollViewer to allow scrolling when content extends beyond window
    $1_scrollviewer = [System.Windows.Controls.ScrollViewer]::new()
    [System.Windows.Controls.DockPanel]::SetDock($1_scrollviewer, [System.Windows.Controls.Dock]::Left)
    $1_scrollviewer.HorizontalAlignment="Stretch"
    $1_scrollviewer.VerticalAlignment="Stretch"
    $1_scrollviewer.HorizontalScrollBarVisibility=[System.Windows.Controls.ScrollBarVisibility]::Visible
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
    # Dont forget to add the dockpanel to the tab!
    $0_tabitem.AddChild($1_dockpanel)

}
#endregion Strings

#region Systems
$tab_main_systems = [System.Windows.Controls.TabItem]::new()
$tab_main_systems.Header="Systems"
$tab_main_systems.Background = $Global:color_maintab_header
$tab_systems = [System.Windows.Controls.TabControl]::new()
$dockpanel_systems = [System.Windows.Controls.DockPanel]::new()
$dockpanel_systems.AddChild($tab_systems)
$tab_main_systems.AddChild($dockpanel_systems)
$main_tabs.AddChild($tab_main_systems)

## For each system in the json file
## Create multiple sub-tabs as defined in the file for misc info related to that system
foreach ($0_key in $Global:systems.Keys)
{
    # Create and configure new tab item
    $0_tabitem = [System.Windows.Controls.TabItem]::new()
    $0_tabitem.Header = $0_key.ToString()
    $0_tabitem.Background =$Global:color_systemtab_header
    # add tab to panel
    $tab_systems.AddChild($0_tabitem)
    
    # Dock panel for tab content parent
    $1_dockpanel = [System.Windows.Controls.DockPanel]::new()
    $1_dockpanel.Background = $Global:color_systemtab
    $0_tabitem.AddChild($1_dockpanel)

    # Create tab control for system information
    $1_tabcontrol_systeminfo = [System.Windows.Controls.TabControl]::new()
    $1_dockpanel.AddChild($1_tabcontrol_systeminfo)
    
    # Get info tabs for the system    
    $system_data = $Global:systems[$0_key]
    ## For each info tab, create content
    foreach ($1_key in $system_data.Keys)
    {
        # Create and configure new tab item
        $2_tabitem = [System.Windows.Controls.TabItem]::new()
        $2_tabitem.Header = $1_key.ToString()
        $2_tabitem.Background =$Global:color_systemtab_subheader
        # add tab to panel
        $1_tabcontrol_systeminfo.AddChild($2_tabitem)

        $2_scrollviewer = [System.Windows.Controls.ScrollViewer]::new()
        $2_scrollviewer.HorizontalAlignment="Stretch"
        $2_scrollviewer.VerticalAlignment="Stretch"
        $2_scrollviewer_contentpanel = [System.Windows.Controls.StackPanel]::new()
        $2_scrollviewer.AddChild($2_scrollviewer_contentpanel)
        
        $2_dockpanel = [System.Windows.Controls.DockPanel]::new()
        $2_dockpanel.Background = $Global:color_systemtab_sub

        $2_content_border = [System.Windows.Controls.Border]::new()
        $2_content_border.CornerRadius = 2
        $2_content_border.BorderBrush = "#708090"
        $2_content_border.BorderThickness = 2
        $2_content_border.Margin = "1 1 1 1"         #margin left top right bottom
        $2_content_border.AddChild($2_scrollviewer)

        $2_tabitem.AddChild($2_dockpanel)
        $2_dockpanel.AddChild($2_content_border)
        
        ## Add content to the information tab
        $system_tab_data = $system_data[$1_key]
        for ($ci = 0; $ci -lt $system_tab_data.Length; $ci++)
        {
            $maincontent_object = $system_tab_data[$ci]
            $maincontent_bold = $maincontent_object["Bold"]
            $maincontent_content = $maincontent_object["Content"]
            $maincontent_textbox = $maincontent_object["TextBox"]
            if ($maincontent_textbox)
            {
                $maincontent_text = [System.Windows.Controls.TextBox]::new()
                if ($maincontent_bold)
                {
                    $maincontent_label.FontWeight = [System.Windows.FontWeights]::Bold
                }
                $maincontent_text.Text = $maincontent_content
                $2_scrollviewer_contentpanel.AddChild($maincontent_text)
            }
            else
            {
                $maincontent_label = [System.Windows.Controls.Label]::new()
                if ($maincontent_bold)
                {
                    $maincontent_label.FontWeight = [System.Windows.FontWeights]::Bold
                }
                $maincontent_label.Content = $maincontent_content
                $2_scrollviewer_contentpanel.AddChild($maincontent_label)
            }

        }

    }

    
}
#endregion Systems

#region Quick Tips
$tab_tips = [System.Windows.Controls.TabItem]::new()
$tab_tips.Header="Useful Tips"
$tab_tips.Background = $Global:color_maintab_header
$tabcontrol_tips = [System.Windows.Controls.TabControl]::new()
$dockpanel_tips = [System.Windows.Controls.DockPanel]::new()
$dockpanel_tips.AddChild($tabcontrol_tips)
$tab_tips.AddChild($dockpanel_tips)
$main_tabs.AddChild($tab_tips)

## For each system in the json file
## Create multiple sub-tabs as defined in the file for misc info related to that system
foreach ($0_key in $Global:tips.Keys)
{
    # Create and configure new tab item
    $0_tabitem = [System.Windows.Controls.TabItem]::new()
    $0_tabitem.Header = $0_key.ToString()
    $0_tabitem.Background =$Global:color_systemtab_header
    # add tab to panel
    $tabcontrol_tips.AddChild($0_tabitem)
    
    # Dock panel for tab content parent
    $1_dockpanel = [System.Windows.Controls.DockPanel]::new()
    $1_dockpanel.Background = $Global:color_systemtab
    $0_tabitem.AddChild($1_dockpanel)

    # Create tab control for system information
    $1_tabcontrol_systeminfo = [System.Windows.Controls.TabControl]::new()
    $1_dockpanel.AddChild($1_tabcontrol_systeminfo)
    
    # Get info tabs for the system    
    $system_data = $Global:tips[$0_key]
    ## For each info tab, create content
    foreach ($1_key in $system_data.Keys)
    {
        # Create and configure new tab item
        $2_tabitem = [System.Windows.Controls.TabItem]::new()
        $2_tabitem.Header = $1_key.ToString()
        $2_tabitem.Background =$Global:color_systemtab_subheader
        # add tab to panel
        $1_tabcontrol_systeminfo.AddChild($2_tabitem)

        $2_scrollviewer = [System.Windows.Controls.ScrollViewer]::new()
        $2_scrollviewer.HorizontalAlignment="Stretch"
        $2_scrollviewer.VerticalAlignment="Stretch"
        $2_scrollviewer_contentpanel = [System.Windows.Controls.StackPanel]::new()
        $2_scrollviewer.AddChild($2_scrollviewer_contentpanel)
        
        $2_dockpanel = [System.Windows.Controls.DockPanel]::new()
        $2_dockpanel.Background = $Global:color_systemtab_sub

        $2_content_border = [System.Windows.Controls.Border]::new()
        $2_content_border.CornerRadius = 2
        $2_content_border.BorderBrush = "#708090"
        $2_content_border.BorderThickness = 2
        $2_content_border.Margin = "1 1 1 1"         #margin left top right bottom
        $2_content_border.AddChild($2_scrollviewer)

        $2_tabitem.AddChild($2_dockpanel)
        $2_dockpanel.AddChild($2_content_border)
        
        ## Add content to the information tab
        $system_tab_data = $system_data[$1_key]
        for ($ci = 0; $ci -lt $system_tab_data.Length; $ci++)
        {
            $maincontent_object = $system_tab_data[$ci]
            $maincontent_bold = $maincontent_object["Bold"]
            $maincontent_content = $maincontent_object["Content"]
            $maincontent_textbox = $maincontent_object["TextBox"]
            if ($maincontent_textbox)
            {
                $maincontent_text = [System.Windows.Controls.TextBox]::new()
                if ($maincontent_bold)
                {
                    $maincontent_label.FontWeight = [System.Windows.FontWeights]::Bold
                }
                $maincontent_text.Text = $maincontent_content
                $2_scrollviewer_contentpanel.AddChild($maincontent_text)
            }
            else
            {
                $maincontent_label = [System.Windows.Controls.Label]::new()
                if ($maincontent_bold)
                {
                    $maincontent_label.FontWeight = [System.Windows.FontWeights]::Bold
                }
                $maincontent_label.Content = $maincontent_content
                $2_scrollviewer_contentpanel.AddChild($maincontent_label)
            }

        }

    }

    
}
#endregion Quick Tips



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
