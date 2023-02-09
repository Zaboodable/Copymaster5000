Add-Type -AssemblyName PresentationFramework
[System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")

### Load Data ###
[System.Collections.Hashtable] $Global:data = [System.Collections.Hashtable]::new()
$Global:data_path = "N:\fcs-data\ITSHARED\Copymaster5000\data.json"

# Set icon
$icon_path = "$PWD\icon.ico"

[System.Collections.Generic.List[[System.Windows.Controls.Control]]]$Global:all_controls = [System.Collections.Generic.List[[System.Windows.Controls.Control]]]::new()
$Global:all_controls.Capacity = 10240


#region Functions
Function remote_message([string]$ComputerName, [string] $Message)
{
    Invoke-WmiMethod -Class win32_process -ComputerName $ComputerName -Name create -ArgumentList  "c:\windows\system32\msg.exe * $Message" 
}

function append_feedback([string]$content)
{
    echo $content >> feedback.txt
}

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
function CreateMenu([string]$title)
{
    $Menu = [System.Windows.Controls.Menu]::new()    
    return $Menu
}
function CreateMenuItem([string]$title)
{
    $MenuItem = [System.Windows.Controls.MenuItem]::new()    
    $MenuItem.Header=$title
    return $MenuItem
}


#region RemoteMessage
$rwin = [System.Windows.Window]::new()
$rwin.Title="Remote Messagerino"
$rwin.Width = 320
$rwin.Height = 320
$rwin.WindowStartupLocation = [System.Windows.WindowStartupLocation]::CenterScreen

$rwin_stack = CreateDockPanel
$rwin.AddChild($rwin_stack)

$rwin_computername_stack = CreateStackPanel
$rwin_message_stack = CreateStackPanel
$rwin_computername_stack.Orientation="Horizontal"
$rwin_computername_stack.HorizontalAlignment="Stretch"
$rwin_message_stack.Orientation="Horizontal"
$rwin_message_stack.HorizontalAlignment="Stretch"
$rwin_submit_button = CreateButton
$rwin_submit_button.Content = "Send"
$rwin_submit_button.Add_Click({
    remote_message $rwin_computername_text.Text $rwin_message_text.Text
})

$rwin_computername_text = CreateTextBox
$rwin_computername_text.Width = 200
$rwin_message_text = CreateTextBox
$rwin_message_text.Width = 200

$rwin_infolabel = CreateLabel
$rwin_computername_label = CreateLabel
$rwin_message_label = CreateLabel
$rwin_infolabel.Content="Be wary of using this as it causes a popup on the remote machine."
$rwin_computername_label.Content="Computer Name:"
$rwin_message_label.Content="Message:"

$rwin_computername_stack.AddChild($rwin_computername_label)
$rwin_message_stack.AddChild($rwin_message_label)
$rwin_computername_stack.AddChild($rwin_computername_text)
$rwin_message_stack.AddChild($rwin_message_text)

$rwin_stack.AddChild($rwin_infolabel)
$rwin_stack.AddChild($rwin_computername_stack)
$rwin_stack.AddChild($rwin_message_stack)
$rwin_stack.AddChild($rwin_submit_button)


[System.Windows.Controls.DockPanel]::SetDock($rwin_infolabel, [System.Windows.Controls.Dock]::Top)
[System.Windows.Controls.DockPanel]::SetDock($rwin_computername_stack, [System.Windows.Controls.Dock]::Top)
[System.Windows.Controls.DockPanel]::SetDock($rwin_message_stack, [System.Windows.Controls.Dock]::Top)
[System.Windows.Controls.DockPanel]::SetDock($rwin_submit_button, [System.Windows.Controls.Dock]::Bottom)
#endregion RemoteMessage

#region Feedback
$fbwin = [System.Windows.Window]::new()
$fbwin.Title="Feedback"
$fbwin.Width = 320
$fbwin.Height = 320
$fbwin.WindowStartupLocation = [System.Windows.WindowStartupLocation]::CenterScreen

$fbwin_stack = CreateDockPanel
$fbwin.AddChild($fbwin_stack)

$fbwin_message_stack = CreateStackPanel
$fbwin_message_stack.Orientation="Horizontal"
$fbwin_message_stack.HorizontalAlignment="Stretch"
$fbwin_submit_button = CreateButton
$fbwin_submit_button.Content = "Send"
$fbwin_submit_button.Add_Click({
    $text = $fbwin_message_text.Text
    if ($text.Length -gt 1)
    {
        [string] $name = [Environment]::UserName


        [string] $output = [string]::Format("{0}: {1}", $name, $text)
        append_feedback $output
    }
})

$fbwin_message_text = CreateTextBox
$fbwin_message_text.Width = 200

$fbwin_infolabel = CreateLabel
$fbwin_message_label = CreateLabel
$fbwin_infolabel.Content="Send suggestions or feedback"
$fbwin_message_label.Content="Message:"

$fbwin_message_stack.AddChild($fbwin_message_label)
$fbwin_message_stack.AddChild($fbwin_message_text)

$fbwin_stack.AddChild($fbwin_infolabel)
$fbwin_stack.AddChild($fbwin_message_stack)
$fbwin_stack.AddChild($fbwin_submit_button)

[System.Windows.Controls.DockPanel]::SetDock($fbwin_infolabel, [System.Windows.Controls.Dock]::Top)
[System.Windows.Controls.DockPanel]::SetDock($fbwin_message_stack, [System.Windows.Controls.Dock]::Top)
[System.Windows.Controls.DockPanel]::SetDock($fbwin_submit_button, [System.Windows.Controls.Dock]::Bottom)
#endregion Feedback




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
$main_searchbar.Name = "MainSearch"
$main_searchbar_label = CreateLabel
$main_searchbar_stack.Orientation="Horizontal"
$main_searchbar.MinWidth = 128
$main_searchbar.Margin = "2 2 2 2"
$main_searchbar_label.Margin = "2 2 2 2" 
$main_searchbar_label.Content="Search: "
$main_searchbar_stack.AddChild($main_searchbar_label)
$main_searchbar_stack.AddChild($main_searchbar)
$main_searchbar_group.AddChild($main_searchbar_stack)


$Global:control_colours = @{}                   # Default Colours          # Searched Colours
$Global:control_colours.Add("TextBox",          @(@("#ffffff", "#000000"), @("#ffffff", "#000000")));
$Global:control_colours.Add("TabItem",          @(@("#cccccc", "#000000"), @("#c0ffc0", "#000000")));
$Global:control_colours.Add("ScrollViewer",     @(@("#eeeeee", "#000000"), @("#ffffff", "#000000")));
$Global:control_colours.Add("Label",            @(@("#eeeeee", "#000000"), @("#aaffaa", "#000000")));
$Global:control_colours.Add("Button",           @(@("#c0e0e0", "#000000"), @("#c0ffc0", "#000000")));


$main_searchbar.Add_TextChanged({
    foreach($c in $Global:all_controls)
    {

        [string]$control_type = $c.GetType().Name
        if ($Global:control_colours.ContainsKey($control_type))
        {
            $c.Background = $Global:control_colours[$control_type][0][0]
            $c.Foreground = $Global:control_colours[$control_type][0][1]
        }
        else
        {
            $c.Background = "#eeeeee"   
            $c.Foreground = "#000000"   
        }  
        
        $match = $this.Text.ToLower()
        if ($match.Length -lt 1)
        {
            continue;
        }


        if ($c.HasContent)
        {
            $content = $c.Content    # Labels use content for text
            $tooltip = $c.Tooltip    # Buttons store copyable data in tooltip
            $header = $c.Header      # Tabs use the header field for their title
            $content_type = $content.GetType().Name

            if ($content_type -eq "String" -or $control_type -eq "TabItem")
            { 

                [bool]$isMatch = 0

                # Search tooltip and main content of a control
                # if they exist
                if ($tooltip -ne $null)
                {
                    if ($tooltip.ToLower().Contains($match))
                    {
                        $isMatch = 1
                        if ($match -eq "ess")
                        {
                            if ($tooltip.ToLower().Contains("ness") -or $tooltip.ToLower().Contains("ress") -or $tooltip.ToLower().Contains("cess") -or $tooltip.ToLower().Contains("sess") -or $tooltip.ToLower().Contains("fess"))
                            {
                                $isMatch=0
                            }
                        }
                    }
                }                                
                if ($header -ne $null)
                {
                    if ($header.ToLower().Contains($match))
                    {
                        $isMatch = 1
                        if ($match -eq "ess")
                        {
                            if ($header.ToLower().Contains("ness") -or $header.ToLower().Contains("ress") -or $header.ToLower().Contains("cess") -or $header.ToLower().Contains("sess") -or $header.ToLower().Contains("fess"))
                            {
                                $isMatch=0
                            }
                        }
                    }
                }
                if ($content_type -eq "String")
                {
                    if ($content.ToLower().Contains($match))
                    {
                        $isMatch = 1
                        if ($match -eq "ess")
                        {
                            if ($content.ToLower().Contains("ness") -or $content.ToLower().Contains("ress") -or $content.ToLower().Contains("cess") -or $content.ToLower().Contains("sess") -or $content.ToLower().Contains("fess"))
                            {
                                $isMatch=0
                            }
                        }
                    }
                }

                if ($isMatch)
                {
                    # Mark this control since it matches the query
                    if ($Global:control_colours.ContainsKey($control_type))
                    {
                        $c.Background = $Global:control_colours[$control_type][1][0]
                        $c.Foreground = $Global:control_colours[$control_type][1][1]
                    }
                    else
                    {
                        $c.Background = "#ccccff"
                        $c.Foreground = "#800000"
                    }  


                    # Work upwards and mark any tabs to guide us down
                    $parent = $c.Parent
                    while ($parent -ne $null)
                    {
                        [string]$type = $parent.GetType().Name
                        if ($type.Contains("TabItem"))
                        {
                            # Colour tabs for navigation
                            $parent.Background = $Global:control_colours["TabItem"][1][0]
                            $parent.Foreground = $Global:control_colours["TabItem"][1][1]
                        }

                        # Move up a level
                        $parent = $parent.Parent
                    }
                } 
            }
        }
    }
}) # end of searchbar text event


### CREATE TABS ###
$main_tabs = CreateTabControl

## QUICK COPY TABS [strings.json]##
#region Strings
$Global:strings = $Global:data["Strings"]

$tab_main_strings = CreateTabItem
$tab_main_strings.Header="Quick Copy"
$tab_strings = CreateTabControl
$dockpanel_strings = CreateDockPanel
$dockpanel_strings.AddChild($tab_strings)
$tab_main_strings.AddChild($dockpanel_strings)
$main_tabs.AddChild($tab_main_strings)

foreach ($0_key in $Global:strings.Keys)
{
    # Create and configure new tab item
    $0_tabitem = CreateTabItem
    $0_tabitem.Header = $0_key.ToString()
    # add tab to panel
    $tab_strings.AddChild($0_tabitem)

    ## dictionary of content from the json data
    $1_dictionary = $Global:strings[$0_key]

    # Dock panel for tab content parent
    $1_dockpanel = CreateDockPanel

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
## For each system in the json file
## Create multiple sub-tabs as defined in the file for misc info related to that system
$Global:information = $Global:data["Information"]

foreach ($info_key in $Global:information.Keys)
{
    $tab_info = CreateTabItem
    $tab_info.Header=$info_key.ToString()
    $tabcontrol_info = CreateTabControl
    $dockpanel_info = CreateDockPanel
    $dockpanel_info.AddChild($tabcontrol_info)
    $tab_info.AddChild($dockpanel_info)
    $main_tabs.AddChild($tab_info)

    ## For each system in the json file
    ## Create multiple sub-tabs as defined in the file for misc info related to that system
    $info_data = $Global:information[$info_key]
    foreach ($0_key in $info_data.Keys)
    {
        # Create and configure new tab item
        $0_tabitem = CreateTabItem
        $0_tabitem.Header = $0_key.ToString()
        # add tab to panel
        $tabcontrol_info.AddChild($0_tabitem)
    
        # Dock panel for tab content parent
        $1_dockpanel = CreateDockPanel
        $0_tabitem.AddChild($1_dockpanel)

        # Create tab control for system information
        $1_tabcontrol_info = CreateTabControl
        $1_dockpanel.AddChild($1_tabcontrol_info)
    
        # Get info tabs for the system    
        $1_infodata = $info_data[$0_key]
        ## For each info tab, create content
        foreach ($1_key in $1_infodata.Keys)
        {
            # Create and configure new tab item
            $2_tabitem = CreateTabItem
            $2_tabitem.Header = $1_key.ToString()
            # add tab to panel
            $1_tabcontrol_info.AddChild($2_tabitem)

            $2_scrollviewer = CreateScrollViewer
            $2_scrollviewer.HorizontalAlignment="Stretch"
            $2_scrollviewer.VerticalAlignment="Stretch"
            $2_scrollviewer_contentpanel = CreateStackPanel
            $2_scrollviewer.AddChild($2_scrollviewer_contentpanel)
        
            $2_dockpanel = CreateDockPanel

            $2_content_border = CreateBorder
            $2_content_border.CornerRadius = 2
            $2_content_border.BorderBrush = "#708090"
            $2_content_border.BorderThickness = 2
            $2_content_border.Margin = "1 1 1 1"         #margin left top right bottom
            $2_content_border.AddChild($2_scrollviewer)

            $2_tabitem.AddChild($2_dockpanel)
            $2_dockpanel.AddChild($2_content_border)
        
            ## Add content to the information tab
            $info_tab_data = $1_infodata[$1_key]
            for ($ci = 0; $ci -lt $info_tab_data.Length; $ci++)
            {
                $maincontent_object = $info_tab_data[$ci]
                $maincontent_bold = $maincontent_object["Bold"]
                $maincontent_content = $maincontent_object["Content"]
                $maincontent_isCopyable = $maincontent_object["Copyable"]
                $maincontent_isLink = $maincontent_object["Link"]
                $maincontent_hasLinkTitle = $maincontent_object["Title"]
                if($maincontent_isLink)
                {
                    $button_copy_link = CreateButton
                    $button_copy_link.Content = $maincontent_content
                    if ($maincontent_hasLinkTitle)
                    {
                        $button_copy_link.Content = $maincontent_hasLinkTitle
                    }
                    $button_copy_link.Margin = "8 4 8 4"
                    $button_copy_link.Tag = $button_id
                    $button_copy_link.Tooltip = $maincontent_content    
                    $button_copy_link.Background = "Transparent"

                    # Button click event
                    $button_copy_link.Add_Click({            
                        # Copy the tooltip data to the clipboard
                        # Update main header for feedback
                        Set-Clipboard -Value $this.Tooltip
                        $main_header.Content = [string]::Format("Copied:{1}{0}", $this.Tooltip, [Environment]::NewLine)
                    })
                    $2_scrollviewer_contentpanel.AddChild($button_copy_link)
                }
                elseif($maincontent_isCopyable)
                {
                    ### TextBox / Copyable Text ###
                    $maincontent_textbox = CreateTextBox
                    $maincontent_textbox.Text = $maincontent_content
                    $maincontent_textbox.IsReadOnly = 1
                    $maincontent_textbox.BorderThickness = 0
                    $maincontent_textbox.Padding = "0 0 0 0"
                    $maincontent_textbox.Margin = "8 4 8 0"
                    $2_scrollviewer_contentpanel.AddChild($maincontent_textbox)
                }
                else
                {
                    ### Standard text ###
                    $maincontent_label = CreateLabel
                    if ($maincontent_bold)
                    {
                        $maincontent_label.FontWeight = [System.Windows.FontWeights]::Bold
                        $maincontent_label.Padding = "0 0 0 0"
                        $maincontent_label.Margin = "4 4 4 0"
                    }
                    else
                    {
                        $maincontent_label.Padding = "0 0 0 0"
                        $maincontent_label.Margin = "8 4 8 0"

                    }
                    $maincontent_label.Content = $maincontent_content
                    $2_scrollviewer_contentpanel.AddChild($maincontent_label)
                }
            }
        }    
    }
}

# Label at the top of the screen for information
$main_header = CreateLabel
$main_header.Content = "" 
$main_header_border = CreateBorder
$main_header_border.BorderBrush = "Black"
$main_header_border.BorderThickness = 1
$main_header_border.Margin = "1 1 1 1"
$main_header_border.AddChild($main_header)

### TOP MENU ###
$top_menu = CreateMenu
$menu_actions = CreateMenuItem("Actions")
$menu_action_refresh = CreateMenuItem("Refresh")
$menu_action_remotemessage = CreateMenuItem("Remote Message")
$menu_action_feedback = CreateMenuItem("Send Feedback")
$top_menu.AddChild($menu_actions)
$menu_action_refresh.Add_Click({
    $window.Close()
    .\copymaster.ps1
})
$menu_action_remotemessage.Add_Click({
    $rwin.ShowDialog()
})
$menu_action_feedback.Add_Click({
    $fbwin.ShowDialog()
})


$menu_actions.AddChild($menu_action_refresh)
$menu_actions.AddChild($menu_action_remotemessage)
$menu_actions.AddChild($menu_action_feedback)

# Dock main window elements
[System.Windows.Controls.DockPanel]::SetDock($top_menu, [System.Windows.Controls.Dock]::Top)
[System.Windows.Controls.DockPanel]::SetDock($main_header_border, [System.Windows.Controls.Dock]::Bottom)
[System.Windows.Controls.DockPanel]::SetDock($main_searchbar_group, [System.Windows.Controls.Dock]::Top)
[System.Windows.Controls.DockPanel]::SetDock($main_tabs, [System.Windows.Controls.Dock]::Top)

# Add main elements to the window
$main_dock.AddChild($top_menu)
$main_dock.AddChild($main_header_border)
$main_dock.AddChild($main_searchbar_group)
$main_dock.AddChild($main_tabs)
$window.AddChild($main_dock)

### Set all colours
foreach($c in $Global:all_controls)
{

    [string]$control_type = $c.GetType().Name
    if ($Global:control_colours.ContainsKey($control_type))
    {
        $c.Background = $Global:control_colours[$control_type][0][0]
        $c.Foreground = $Global:control_colours[$control_type][0][1]
    }
    else
    {
        $c.Background = "#eeeeee"   
        $c.Foreground = "#000000"   
    }  
}

### Default focus to search bar
[System.Windows.Input.FocusManager]::SetFocusedElement($window, $main_searchbar)

#endregion Interface

# Display the window

$window.ShowDialog()
