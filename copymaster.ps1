## TODO - clean up a bit

Add-Type -AssemblyName PresentationFramework
[System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions") 
Add-Type -AssemblyName System.Web

$Global:current_user = [System.Environment]::UserName

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
    
    [string] $name = [Environment]::UserName
    [string] $date = (Get-Date).DateTime
    append_log([string]::Format("{0} :: Remote Message from {1} to {2}: {3}{4}",$date, $name, $ComputerName, $Message, [Environment]::NewLine))
}

function append_feedback([string]$content)
{
    echo $content >> feedback.txt
}
function append_log([string]$content)
{
    echo $content >> log.txt
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
    #$TextBox = [System.Windows.Controls.RichTextBox]::new()
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
function CreateCheckBox([string]$label, $checked)
{
    $CheckBox = [System.Windows.Controls.CheckBox]::new()
    $CheckBox.Content = $label
    $CheckBox.IsChecked = $checked


    return $CheckBox
}
function CreateImage([string]$path, [bool]$use_border)
{
    $Image = [System.Windows.Controls.Image]::new()
    $path = [string]::Format("{0}{1}","$PWD",$path)
    $bmp = [System.Windows.Media.Imaging.BitmapImage]::new()
    $bmp.BeginInit()
    $bmp.UriSource = $path
    $bmp.EndInit()
    $Image.Source = $bmp
    if ($use_border)
    {
        $Border = CreateBorder
        $Border.CornerRadius = 2
        $Border.BorderBrush = "Black"
        $Border.BorderThickness = 2
        $Border.Margin = "8"   
        $Border.AddChild($Image)
        return $Border
    }
    $Image.Margin = "8"

    return $Image
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
    $rwin_computername_text.Text = ""
    $rwin_message_text.Text = ""
    $rwin.Hide()
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
        [string] $date = (Get-Date).DateTime
        [string] $output = [string]::Format("{0} :: {1}: {2}{3}",$date, $name, $text,[Environment]::NewLine)
        append_feedback $output
        $box = [System.Windows.MessageBox]::Show("Feedback Submitted", "Success!")
        $fbwin_message_text.Text=""
        $fbwin.Hide()
    }
})

$fbwin_message_text = CreateTextBox
$fbwin_message_text.AcceptsReturn=1
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
$fbwin_TEST = [System.Windows.Controls.RichTextBox]::new();
$fbwin_stack.AddChild($fbwin_TEST)

[System.Windows.Controls.DockPanel]::SetDock($fbwin_infolabel, [System.Windows.Controls.Dock]::Top)
[System.Windows.Controls.DockPanel]::SetDock($fbwin_message_stack, [System.Windows.Controls.Dock]::Top)
[System.Windows.Controls.DockPanel]::SetDock($fbwin_submit_button, [System.Windows.Controls.Dock]::Bottom)
#endregion Feedback

#region PasswordGen
$pwwin = [System.Windows.Window]::new()
$pwwin.Title="Passwordinator 7000"
$pwwin.Width = 320
$pwwin.Height = 320
$pwwin.WindowStartupLocation = [System.Windows.WindowStartupLocation]::CenterScreen

$pwwin_stack = CreateDockPanel
$pwwin.AddChild($pwwin_stack)


$pwwin_infolabel = CreateLabel
$pwwin_infolabel.Content="Create a new random password"


$pwin_message_text = CreateTextBox
$pwin_message_text.VerticalAlignment = [System.Windows.VerticalAlignment]::Top

$pwwin_generate_button = CreateButton
$pwwin_generate_button.Content = "Generate"
$pwwin_generate_button.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
$pwwin_generate_button.Add_Click({
    $pw = [System.Web.Security.Membership]::GeneratePassword(12, 2)
    $pw = $pw.replace('£', '$')
    $pwin_message_text.Text = $pw
})


$pwwin_stack.AddChild($pwwin_infolabel)
$pwwin_stack.AddChild($pwwin_generate_button)
$pwwin_stack.AddChild($pwin_message_text)

[System.Windows.Controls.DockPanel]::SetDock($pwwin_infolabel, [System.Windows.Controls.Dock]::Top)
#endregion PasswordGen


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
$window.Width = 896
$window.Height = 768
$window.Icon = $icon_path
$window.Add_LostKeyboardFocus({
    $main_header.Content=""
})

$main_dock = CreateDockPanel
$main_dock.Background = "#dddddd"

### LOAD DATA ###
LoadData



#region TopBars
## Search Bar
$main_topbars_dock = CreateDockPanel

$main_searchbar_group = CreateBorder
$main_searchbar_group.CornerRadius = 2
$main_searchbar_group.BorderBrush = "Black"
$main_searchbar_group.BorderThickness = 2
$main_searchbar_group.Margin = "4 1 4 0"         #margin left top right bottom


$main_searchbar_stack = CreateStackPanel
$main_searchbar_group.MaxHeight = 28
$main_searchbar_stack.MaxHeight = 28
$main_searchbar = CreateTextBox
$main_searchbar.Height = 20
$main_searchbar.VerticalAlignment = [System.Windows.VerticalAlignment]::Top
$main_searchbar_label = CreateLabel
$main_searchbar_stack.Orientation="Horizontal"
$main_searchbar.MinWidth = 128
$main_searchbar.Margin = "2 2 2 2"
$main_searchbar_label.Margin = "1 1 1 1"
$main_searchbar_label.Padding = "3 3 1 0" 
$main_searchbar_label.Content="Search: "

$main_searchbar_stack.AddChild($main_searchbar_label)
$main_searchbar_stack.AddChild($main_searchbar)
$main_searchbar_group.AddChild($main_searchbar_stack)


$main_accountbar_group = CreateBorder
$main_accountbar_group.Tooltip="Default password to put in copied text with a password"
$main_accountbar_group.CornerRadius = 2
$main_accountbar_group.BorderBrush = "Black"
$main_accountbar_group.BorderThickness = 2
$main_accountbar_group.Margin = "4 1 4 0"         #margin left top right bottom

$main_accountbar_stack = CreateStackPanel
$main_accountbar_group.AddChild($main_accountbar_stack)

#region PasswordBar
## Password Bar ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- Password Bar
$main_passwordbar = CreateTextBox
$main_passwordbar.AcceptsReturn=0
$main_passwordbar.Height = 20
$main_passwordbar_label = CreateLabel
$main_passwordbar_label_current = CreateLabel
$main_passwordbar.MinWidth = 128
$main_passwordbar.MaxWidth = 188
$main_passwordbar.MaxLength=32
$main_passwordbar.Margin = "2 2 2 2"
$main_passwordbar_label.Margin = "2 2 2 2" 
$main_passwordbar_label.Content="Default Password: "
$main_passwordbar_label_current.Margin = "2 2 2 2" 
$Global:default_password="Sprinter23"
$main_passwordbar.Text = $Global:default_password


$main_passwordbar_stack = CreateStackPanel
$main_passwordbar_stack.Orientation="Horizontal"
$main_passwordbar_stack.HorizontalAlignment="Stretch"
$main_passwordbar_stack.AddChild($main_passwordbar_label)
$main_passwordbar_stack.AddChild($main_passwordbar)
$main_passwordbar_stack.AddChild($main_passwordbar_label_current)
$main_accountbar_stack.AddChild($main_passwordbar_stack)

## craigs password button
$main_passwordbar_genericreset_button = CreateButton
$main_passwordbar_stack.AddChild($main_passwordbar_genericreset_button)
$main_passwordbar_genericreset_button.HorizontalAlignment="Right"
$main_passwordbar_genericreset_button.Content = "Craigs Generic Password Response"
$main_passwordbar_genericreset_button.Padding = "2 2 2 2"
$main_passwordbar_genericreset_button.Margin = "2 2 2 2"
$main_passwordbar_genericreset_button.Add_Click({
[string] $clipboard_text = @"
We have reset your password for the requested system.

Your new password is: %DEFAULT_PASSWORD%
You will be prompted to change this on your next login.

If you have any further issues, please get in touch on webchat on the Get IT Help pages on the Intranet or your issue is urgent and you require an urgent response, please contact us via 01609 532020 option 3, option 2. You may experience a delay as our phone lines are very busy at the moment, please bear with us and we will connect as soon as we can.

Many thanks,
T&C Service Desk"
"@
    if ($clipboard_text.Contains("%DEFAULT_PASSWORD%"))
    {
        $clipboard_text = $clipboard_text.Replace("%DEFAULT_PASSWORD%", $Global:default_password)
    }
    Set-Clipboard -Value $clipboard_text
    $main_header.Content = [string]::Format("Copied:{1}{0}", $clipboard_text, [Environment]::NewLine)
})



$main_passwordbar_label_current.Content=[string]::format("Current: {0}", $Global:default_password)

$main_passwordbar.Add_TextChanged({
    if ($this.Text.Length -gt 0)
    {        
        [string]$pw = $this.Text
        $Global:default_password=$pw
        $main_passwordbar_label_current.Content=[string]::format("Current: {0}", $Global:default_password)
    }
})
## Password Bar -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- Password Bar end
#endregion PasswordBar

#region EmployeeBar
## Employee Number Bar ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- Employee Number Bar
$main_employeenumberbar = CreateTextBox
$main_employeenumberbar.AcceptsReturn=0
$main_employeenumberbar.Height = 20
$main_employeenumberbar_label = CreateLabel
$main_employeenumberbar_label_current = CreateLabel
$main_employeenumberbar.MinWidth = 128
$main_employeenumberbar.MaxWidth = 188
$main_employeenumberbar.MaxLength=10
$main_employeenumberbar.Margin = "2 2 2 2"
$main_employeenumberbar_label.Margin = "2 2 2 2" 
$main_employeenumberbar_label.Content="Employee Number: "
$main_employeenumberbar_label_current.Margin = "2 2 2 2" 
$Global:default_employeenumber="HARR123456"
$main_employeenumberbar.Text = $Global:default_employeenumber

$main_employeenumberbar_stack = CreateStackPanel
$main_employeenumberbar_stack.Orientation="Horizontal"
$main_employeenumberbar_stack.HorizontalAlignment="Stretch"
$main_employeenumberbar_stack.AddChild($main_employeenumberbar_label)
$main_employeenumberbar_stack.AddChild($main_employeenumberbar)
$main_employeenumberbar_stack.AddChild($main_employeenumberbar_label_current)
$main_accountbar_stack.AddChild($main_employeenumberbar_stack)


$main_employeenumberbar_label_current.Content=[string]::format("Current: {0}", $Global:default_employeenumber)

$main_employeenumberbar.Add_TextChanged({
    if ($this.Text.Length -gt 0)
    {        
        [string]$pw = $this.Text
        $Global:default_employeenumber=$pw
        $main_employeenumberbar_label_current.Content=[string]::format("Current: {0}", $Global:default_employeenumber)
    }
})


## alecs myview button
$main_employeenumberbar_genericreset_button = CreateButton
$main_employeenumberbar_stack.AddChild($main_employeenumberbar_genericreset_button)
$main_employeenumberbar_genericreset_button.HorizontalAlignment="Right"
$main_employeenumberbar_genericreset_button.Content = "MyView Password Email"
$main_employeenumberbar_genericreset_button.Padding = "2 2 2 2"
$main_employeenumberbar_genericreset_button.Margin = "2 2 2 2"
$main_employeenumberbar_genericreset_button.Add_Click({
[string] $clipboard_text = @"
Thank you for those details.
    I have reset the password for %DEFAULT_EMPLOYEE% to: %DEFAULT_PASSWORD%
    Please go to Self Service - MyView Dashboard ( https://selfservice.northyorks.gov.uk ) and follow these steps:
    
    1.            Input employee number and password %DEFAULT_PASSWORD%, click sign in
    2.            Now input your DOB in the full format e.g. 24/10/2018
    3.            On the next page it will ask for a pin, this is where you can enter a new one now the password has been reset.
    4.            On the next page it will ask to change your password, your current password is %DEFAULT_PASSWORD%. There are instructions on top of this page that tell you what values your new password should have.
    5.            You should now be logged in.
    
    Please Note: This temporary password will expire after 24 hours.
    
Many thanks,
T&C Service Desk
"@
    if ($clipboard_text.Contains("%DEFAULT_PASSWORD%"))
    {
        $clipboard_text = $clipboard_text.Replace("%DEFAULT_PASSWORD%", $Global:default_password)
    }    
    if ($clipboard_text.Contains("%DEFAULT_EMPLOYEE%"))
    {
        $clipboard_text = $clipboard_text.Replace("%DEFAULT_EMPLOYEE%", $Global:default_employeenumber)
    }
    Set-Clipboard -Value $clipboard_text
    $main_header.Content = [string]::Format("Copied:{1}{0}", $clipboard_text, [Environment]::NewLine)
})



$main_passwordbar_label_current.Content=[string]::format("Current: {0}", $Global:default_password)

$main_passwordbar.Add_TextChanged({
    if ($this.Text.Length -gt 0)
    {        
        [string]$pw = $this.Text
        $Global:default_password=$pw
        $main_passwordbar_label_current.Content=[string]::format("Current: {0}", $Global:default_password)
    }
})

## Employee Number Bar -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- Employee Number Bar end
#endregion EmployeeBar


#region AccountBarConfig
## Account Bar Check boxes---------------------------------------------------------------------------------------------------------------------------------------------------------------------- Account Bar Check boxes
$main_topbars_account_border = CreateBorder
$main_topbars_account_border.BorderThickness=1
$main_topbars_account_border.CornerRadius=2
$main_topbars_account_border.BorderBrush="Black"
$main_topbars_account_scroll_stack = CreateStackPanel
$main_topbars_account_border.AddChild($main_topbars_account_scroll_stack)

# employee number / my view
$main_topbars_account_check_employeenumber = CreateCheckBox "MyView" 0
$main_topbars_account_check_employeenumber.Margin = "2 2 2 2"
$main_topbars_account_check_employeenumber.Add_Unchecked({
    $main_passwordbar_genericreset_button.Visibility= [System.Windows.Visibility]::Visible
    $main_employeenumberbar_stack.Visibility = [System.Windows.Visibility]::Hidden
    $main_topbars_dock.MaxHeight = 36
})
$main_topbars_account_check_employeenumber.Add_Checked({
    $main_passwordbar_genericreset_button.Visibility= [System.Windows.Visibility]::Hidden
    $main_employeenumberbar_stack.Visibility = [System.Windows.Visibility]::Visible
    $main_topbars_dock.MaxHeight = 72
})


#$main_topbars_account_scroll_stack.AddChild($main_topbars_account_check_password)
$main_topbars_account_scroll_stack.AddChild($main_topbars_account_check_employeenumber)
## Account Bar Check boxes---------------------------------------------------------------------------------------------------------------------------------------------------------------------- Account Bar Check boxes end
#endregion AccountBarConfig

$main_topbars_dock.AddChild($main_searchbar_group)
$main_topbars_dock.AddChild($main_accountbar_group)
$main_topbars_dock.AddChild($main_topbars_account_border)
$main_topbars_dock.MaxHeight = 36
$main_topbars_dock.VerticalAlignment=[System.Windows.VerticalAlignment]::Top

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

#endregion TopBars

### CREATE TABS ###
$main_tabs = CreateTabControl

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
            $2_scrollviewer.Padding="0 4 0 0"
        
            $2_dockpanel = CreateDockPanel

            $2_content_border = CreateBorder
            $2_content_border.CornerRadius = 2
            $2_content_border.BorderBrush = "#708090"
            $2_content_border.BorderThickness = 2
            $2_content_border.Margin = "2 2 2 2"         #margin left top right bottom
            $2_content_border.AddChild($2_scrollviewer)

            $2_tabitem.AddChild($2_dockpanel)
            $2_dockpanel.AddChild($2_content_border)
        
            ## Add content to the information tab
            $info_tab_data = $1_infodata[$1_key]
            for ($ci = 0; $ci -lt $info_tab_data.Length; $ci++)
            {
                $maincontent_object = $info_tab_data[$ci]
                $maincontent_bold = $maincontent_object["Bold"]
                $maincontent_hasTitle = $maincontent_object["Title"]
                $maincontent_content = $maincontent_object["Content"]
                $maincontent_isCopyable = $maincontent_object["Copyable"]
                $maincontent_isButton = $maincontent_object["Button"]

                # image
                $maincontent_isImage = $maincontent_object["Image"]
                $maincontent_hasPath = $maincontent_object["Path"]
                if($maincontent_isImage)
                {
                    if($maincontent_hasPath)
                    {
                    $image = CreateImage $maincontent_hasPath 1
                    $2_scrollviewer_contentpanel.AddChild($image)
                    }
                }
                elseif($maincontent_isButton)
                {
                    $button_copy = CreateButton
                    $button_copy.Content = $maincontent_content
                    if ($maincontent_hasTitle)
                    {
                        $button_copy.Content = $maincontent_hasTitle
                    }
                    $button_copy.Margin = "8 2 8 2"
                    $button_copy.Tag = $button_id
                    $button_copy.Tooltip = $maincontent_content    
                    $button_copy.Background = "Transparent"

                    # Button click event
                    $button_copy.Add_Click({            
                        # Copy the tooltip data to the clipboard
                        # Update main header for feedback
                        [string]$clipboard_text = $this.Tooltip

                        #region TODO_MOVE

                        # Autofill date for +48h CCP response
                        if ($clipboard_text.Contains("DD/MM/YYYY"))
                        {
                            $date = (Get-Date).AddDays(2)
                            $dayofweek = $date.DayOfWeek
                            if ($dayofweek -eq "Saturday")
                            {
                                $date = $date.AddDays(2)
                            }
                            if ($dayofweek -eq "Sunday")
                            {
                                $date = $date.AddDays(1)
                            }
                            $day = $date.Day
                            $month = $date.Month
                            $year = $date.Year
                            $ddmmyyyy = [string]::format("{0}/{1}/{2}", $day, $month, $year)
                            $clipboard_text = $clipboard_text.Replace("DD/MM/YYYY", $ddmmyyyy)
                        }

                        # Replace password with default in copied text
                        if ($clipboard_text.Contains("%DEFAULT_PASSWORD%"))
                        {
                            $clipboard_text = $clipboard_text.Replace("%DEFAULT_PASSWORD%", $Global:default_password)
                        }
                        if ($clipboard_text.Contains("%DEFAULT_EMPLOYEE%"))
                        {
                            $clipboard_text = $clipboard_text.Replace("%DEFAULT_EMPLOYEE%", $Global:default_employeenumber)
                        }
                        #endregion TODO_MOVE


                        Set-Clipboard -Value $clipboard_text
                        $main_header.Content = [string]::Format("Copied:{1}{0}", $clipboard_text, [Environment]::NewLine)
                    })
                    $2_scrollviewer_contentpanel.AddChild($button_copy)
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
$menu_action_password = CreateMenuItem("Generate Password")
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
$menu_action_password.Add_Click({
    $pwwin.ShowDialog()
})


$menu_actions.AddChild($menu_action_refresh)
$menu_actions.AddChild($menu_action_remotemessage)
$menu_actions.AddChild($menu_action_feedback)
$menu_actions.AddChild($menu_action_password)

# Dock main window elements
[System.Windows.Controls.DockPanel]::SetDock($top_menu, [System.Windows.Controls.Dock]::Top)
[System.Windows.Controls.DockPanel]::SetDock($main_header_border, [System.Windows.Controls.Dock]::Bottom)
[System.Windows.Controls.DockPanel]::SetDock($main_topbars_dock, [System.Windows.Controls.Dock]::Top)
[System.Windows.Controls.DockPanel]::SetDock($main_tabs, [System.Windows.Controls.Dock]::Top)

# Add main elements to the window
$main_dock.AddChild($top_menu)
$main_dock.AddChild($main_header_border)
$main_dock.AddChild($main_topbars_dock)
$main_dock.AddChild($main_tabs)

$main_side_dock = CreateDockPanel
$main_main_dock = CreateDockPanel
$main_main_dock.AddChild($main_dock)
[System.Windows.Controls.DockPanel]::SetDock($main_dock, [System.Windows.Controls.Dock]::Left)

# TODO - add the side panel for search results
#$main_main_dock.AddChild($main_side_dock)
#[System.Windows.Controls.DockPanel]::SetDock($main_side_dock, [System.Windows.Controls.Dock]::Right)
#$main_side_dock_stack = CreateStackPanel
#$main_side_dock_stack.Width = 128
#$main_side_dock.AddChild($main_side_dock_stack)
#$main_side_dock_button = CreateButton
#$main_side_dock_button.Content = "test button"
#$main_side_dock_stack.AddChild($main_side_dock_button)

$window.AddChild($main_main_dock)

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
