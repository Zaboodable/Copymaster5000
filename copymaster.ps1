Add-Type -AssemblyName PresentationFramework
[System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")

### Load Data ###
[System.Collections.Hashtable] $Global:data = [System.Collections.Hashtable]::new()
$Global:data_path = "$PWD\data.json"

# Set icon
$icon_path = "$PWD\icon.ico"

[System.Collections.Generic.List[[System.Windows.Controls.Control]]]$Global:all_controls = [System.Collections.Generic.List[[System.Windows.Controls.Control]]]::new()
$Global:all_controls.Capacity = 2048


#region Functions
#region WPF

### Functions to create generic controls and add to global list
function CreateWindow([string]$title)
{
    $Window = [System.Windows.Window]::new()
    $Window.Title = $title
    $Global:all_controls.Add($Window)
    return $Window
}
function CreateLabel
{
    $Label = [System.Windows.Controls.Label]::new()
    $Global:all_controls.Add($Label)
    return $Label
}
function CreateButton
{
    $Button = [System.Windows.Controls.Button]::new()
    $Global:all_controls.Add($Button)
    return $Button
}
function CreateBorder
{
    $Border = [System.Windows.Controls.Border]::new()
    #$Global:all_controls.Add($Border)
    return $Border
}
function CreateScrollViewer
{
    $ScrollViewer = [System.Windows.Controls.ScrollViewer]::new()
    $Global:all_controls.Add($ScrollViewer)
    return $ScrollViewer
}
function CreateTextBox
{
    $TextBox = [System.Windows.Controls.TextBox]::new()
    $Global:all_controls.Add($TextBox)
    return $TextBox
}
function CreateDockPanel
{
    $DockPanel = [System.Windows.Controls.DockPanel]::new()
    #$Global:all_controls.Add($DockPanel)
    return $DockPanel
}
function CreateStackPanel
{
    $StackPanel = [System.Windows.Controls.StackPanel]::new()
    #$Global:all_controls.Add($StackPanel)
    return $StackPanel
}
function CreateTabControl
{
    $TabControl = [System.Windows.Controls.TabControl]::new()
    $Global:all_controls.Add($TabControl)
    return $TabControl
}
function CreateTabItem
{
    $TabItem = [System.Windows.Controls.TabItem]::new()
    $Global:all_controls.Add($TabItem)
    return $TabItem
}




#endregion WPF

#region Json

function Parse-JsonFile([string]$file) {
    $text = [IO.File]::ReadAllText($file)
    $parser = New-Object Web.Script.Serialization.JavaScriptSerializer
    $parser.MaxJsonLength = $text.length
    Write-Output -NoEnumerate $parser.DeserializeObject($text)
}


function LoadData
{
    # Ensure strings file exists.
    # Create if not
    $exists = Test-Path $Global:data_path
    if ($exists)
    {
         $Global:data = Parse-JsonFile $Global:data_path
        
    }
    else
    {
        # Create blank json file if one does not exist
        $file = New-Item $Global:data_path
        Write-Output '{' '' '}' >> $file
        LoadStrings        
    }
}


function AddJsonString([string]$identifier, [string]$title,[string]$content,[string]$category,[bool]$favourite)
{
    $data = @($title, $content, $category, $favourite)
    $Global:strings[$identifier] = $data
}
#endregion Json

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
[System.Windows.Window] $window = CreateWindow "CopyMaster 5000"
$window.WindowStartupLocation = [System.Windows.WindowStartupLocation]::CenterScreen
$window.Width = 800
$window.Height = 512
$window.Icon = $icon_path
$window.Add_LostKeyboardFocus({
    $main_header.Content=""
})

$main_dock = CreateDockPanel
$main_dock.Background = "#dddddd"

### LOAD DATA ###
LoadData


### Search Bar ###
$main_searchbar_group = CreateBorder
$main_searchbar_group.CornerRadius = 2
$main_searchbar_group.BorderBrush = "Black"
$main_searchbar_group.BorderThickness = 2
$main_searchbar_group.Margin = "4 1 4 0"         #margin left top right bottom


$main_searchbar_stack = CreateStackPanel
$main_searchbar = CreateTextBox
$main_searchbar_label = CreateLabel
$main_searchbar_stack.Orientation="Horizontal"
$main_searchbar.MinWidth = 128
$main_searchbar.Margin = "2 2 2 2"
$main_searchbar_label.Margin = "2 2 2 2" 
$main_searchbar_label.Content="Search: "
$main_searchbar_stack.AddChild($main_searchbar_label)
$main_searchbar_stack.AddChild($main_searchbar)
$main_searchbar_group.AddChild($main_searchbar_stack)

### TEST ###
$search_style = [System.Windows.Style]::new()
### TEST ###

### TODO ###
### make this less bad ###
$main_searchbar.Add_TextChanged({
    foreach($c in $Global:all_controls)
    {
        $c.Background = "#eeeeee"   
        $c.Foreground = "#000000"      
        if ($c.HasContent)
        {
            $content = $c.Content
            $tooltip = $c.Tooltip
            $type = $content.GetType().Name
            if ($type -eq "String" -or $tooltip -ne $null)
            { 
                $match = $this.Text.ToLower()

                [bool]$isMatch = 0

                # Search tooltip and main content of a control
                # if they exist
                if ($tooltip -ne $null)
                {
                    if ($tooltip.ToLower().Contains($match))
                    {
                        $isMatch = 1
                    }
                }
                if ($content.ToLower().Contains($match))
                {
                    $isMatch = 1
                }


                if ($isMatch)
                {
                    # Mark this control since it matches the query
                    $c.Background = "#aaaaff"

                    # Work upwards and mark any tabs to guide us down
                    $parent = $c.Parent
                    while ($parent -ne $null)
                    {
                        [string]$type = $parent.GetType().Name
                        if ($type.Contains("TabItem"))
                        {
                            # Colour tabs for navigation
                            $parent.Background = "#ccccff"
                            $parent.Foreground = "#800000"
                        }

                        # Move up a level
                        $parent = $parent.Parent
                    }
                } 
            }
        }
    }
})






### CREATE TABS ###
$main_tabs = CreateTabControl

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
$Global:strings = $Global:data["Strings"]
foreach ($0_key in $Global:strings.Keys)
{
    # Create and configure new tab item
    $0_tabitem = CreateTabItem
    $0_tabitem.Header = $0_key.ToString()
    $0_tabitem.Background =$Global:color_maintab_header
    # add tab to panel
    $main_tabs.AddChild($0_tabitem)

    ## dictionary of content from the json data
    $1_dictionary = $Global:strings[$0_key]

    # Dock panel for tab content parent
    $1_dockpanel = CreateDockPanel
    $1_dockpanel.Background = $Global:color_maintab

    # ScrollViewer to allow scrolling when content extends beyond window
    $1_scrollviewer = CreateScrollViewer
    [System.Windows.Controls.DockPanel]::SetDock($1_scrollviewer, [System.Windows.Controls.Dock]::Left)
    $1_scrollviewer.HorizontalAlignment="Stretch"
    $1_scrollviewer.VerticalAlignment="Stretch"
    $1_scrollviewer.HorizontalScrollBarVisibility=[System.Windows.Controls.ScrollBarVisibility]::Visible
    $1_scrollviewer_contentpanel = CreateStackPanel
    $1_scrollviewer.AddChild($1_scrollviewer_contentpanel)
    $1_dockpanel.AddChild($1_scrollviewer)

    ## Loop through each key of the sub-dictionary, these are each individual entries for buttons
    foreach ($1_key in $1_dictionary.Keys)
    {
        # Border for the button
        $1_border = CreateBorder
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
        $button = CreateButton
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
$tab_main_systems = CreateTabItem
$tab_main_systems.Header="Systems"
$tab_main_systems.Background = $Global:color_maintab_header
$tab_systems = CreateTabControl
$dockpanel_systems = CreateDockPanel
$dockpanel_systems.AddChild($tab_systems)
$tab_main_systems.AddChild($dockpanel_systems)
$main_tabs.AddChild($tab_main_systems)

## For each system in the json file
## Create multiple sub-tabs as defined in the file for misc info related to that system
$Global:systems = $Global:data["Systems"]
foreach ($0_key in $Global:systems.Keys)
{
    # Create and configure new tab item
    $0_tabitem = CreateTabItem
    $0_tabitem.Header = $0_key.ToString()
    $0_tabitem.Background =$Global:color_systemtab_header
    # add tab to panel
    $tab_systems.AddChild($0_tabitem)
    
    # Dock panel for tab content parent
    $1_dockpanel = CreateDockPanel
    $1_dockpanel.Background = $Global:color_systemtab
    $0_tabitem.AddChild($1_dockpanel)

    # Create tab control for system information
    $1_tabcontrol_systeminfo = CreateTabControl
    $1_dockpanel.AddChild($1_tabcontrol_systeminfo)
    
    # Get info tabs for the system    
    $system_data = $Global:systems[$0_key]
    ## For each info tab, create content
    foreach ($1_key in $system_data.Keys)
    {
        # Create and configure new tab item
        $2_tabitem = CreateTabItem
        $2_tabitem.Header = $1_key.ToString()
        $2_tabitem.Background =$Global:color_systemtab_subheader
        # add tab to panel
        $1_tabcontrol_systeminfo.AddChild($2_tabitem)

        $2_scrollviewer = CreateScrollViewer
        $2_scrollviewer.HorizontalAlignment="Stretch"
        $2_scrollviewer.VerticalAlignment="Stretch"
        $2_scrollviewer_contentpanel = CreateStackPanel
        $2_scrollviewer.AddChild($2_scrollviewer_contentpanel)
        
        $2_dockpanel = CreateDockPanel
        $2_dockpanel.Background = $Global:color_systemtab_sub

        $2_content_border = CreateBorder
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
                $maincontent_text = CreateTextBox
                $maincontent_text.Margin="4 4 4 4"
                if ($maincontent_bold)
                {
                    $maincontent_label.FontWeight = [System.Windows.FontWeights]::Bold
                }
                $maincontent_text.Text = $maincontent_content
                $2_scrollviewer_contentpanel.AddChild($maincontent_text)
            }
            else
            {
                $maincontent_label = CreateLabel
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
$tab_tips = CreateTabItem
$tab_tips.Header="Useful Tips"
$tab_tips.Background = $Global:color_maintab_header
$tabcontrol_tips = CreateTabControl
$dockpanel_tips = CreateDockPanel
$dockpanel_tips.AddChild($tabcontrol_tips)
$tab_tips.AddChild($dockpanel_tips)
$main_tabs.AddChild($tab_tips)

## For each system in the json file
## Create multiple sub-tabs as defined in the file for misc info related to that system
$Global:tips = $Global:data["Tips"]
foreach ($0_key in $Global:tips.Keys)
{
    # Create and configure new tab item
    $0_tabitem = CreateTabItem
    $0_tabitem.Header = $0_key.ToString()
    $0_tabitem.Background =$Global:color_systemtab_header
    # add tab to panel
    $tabcontrol_tips.AddChild($0_tabitem)
    
    # Dock panel for tab content parent
    $1_dockpanel = CreateDockPanel
    $1_dockpanel.Background = $Global:color_systemtab
    $0_tabitem.AddChild($1_dockpanel)

    # Create tab control for system information
    $1_tabcontrol_systeminfo = CreateTabControl
    $1_dockpanel.AddChild($1_tabcontrol_systeminfo)
    
    # Get info tabs for the system    
    $system_data = $Global:tips[$0_key]
    ## For each info tab, create content
    foreach ($1_key in $system_data.Keys)
    {
        # Create and configure new tab item
        $2_tabitem = CreateTabItem
        $2_tabitem.Header = $1_key.ToString()
        $2_tabitem.Background =$Global:color_systemtab_subheader
        # add tab to panel
        $1_tabcontrol_systeminfo.AddChild($2_tabitem)

        $2_scrollviewer = CreateScrollViewer
        $2_scrollviewer.HorizontalAlignment="Stretch"
        $2_scrollviewer.VerticalAlignment="Stretch"
        $2_scrollviewer_contentpanel = CreateStackPanel
        $2_scrollviewer.AddChild($2_scrollviewer_contentpanel)
        
        $2_dockpanel = CreateDockPanel
        $2_dockpanel.Background = $Global:color_systemtab_sub

        $2_content_border = CreateBorder
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
                $maincontent_text = CreateTextBox
                $maincontent_text.ToolTip = $maincontent_content
                $maincontent_text.Margin="4 4 4 4"
                if ($maincontent_bold)
                {
                    $maincontent_text.FontWeight = [System.Windows.FontWeights]::Bold
                }
                $maincontent_text.Text = $maincontent_content
                $2_scrollviewer_contentpanel.AddChild($maincontent_text)
            }
            else
            {
                $maincontent_label = CreateLabel
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
$main_header = CreateLabel
$main_header.Content = "" 
$main_header_border = CreateBorder
$main_header_border.BorderBrush = "Black"
$main_header_border.BorderThickness = 1
$main_header_border.Margin = "1 1 1 1"
$main_header_border.AddChild($main_header)

# Dock main window elements
[System.Windows.Controls.DockPanel]::SetDock($main_header_border, [System.Windows.Controls.Dock]::Bottom)
[System.Windows.Controls.DockPanel]::SetDock($main_searchbar_group, [System.Windows.Controls.Dock]::Top)
[System.Windows.Controls.DockPanel]::SetDock($main_tabs, [System.Windows.Controls.Dock]::Top)

# Add main elements to the window
$main_dock.AddChild($main_header_border)
$main_dock.AddChild($main_searchbar_group)
$main_dock.AddChild($main_tabs)
$window.AddChild($main_dock)


#endregion Interface


$window.ShowDialog()
