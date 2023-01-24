<img src="/img/icon.ico"> 
<h1>Copy Master 5000</h1>
An all in one solution for your service desk needs.
<h2>Installation Instructions</h2>
<b>You will need the data files, these are not stored on the repository</b>
<ol>
<li>Download files from repository to a folder</li>
<li>You may need to copy the content of <b>copymaster.ps1</b> into a new text file and save it as a new .ps1 file. (Downloaded one might not work due to execution policies)</li>
<li>Right click your new .ps1 file -> Send to -> Desktop (create shortcut)</li>
<li>Edit the new desktop shortcut by right clicking -> Properties -> <br><b>Target: </b>powershell.exe -NoP -W Hidden "Path\To\Copymaster\copymaster.ps1"<br><b>Start in:</b> Path\To\Copymaster</li>
<li>The shortcut should now launch CopyMaster3000</li>
<li>(Optional) Set shortcut icon: Right click -> Properties -> Change Icon -> Navigate to copymaster folder and select "img\icon.ico"</li>
</ol>

<h2>Settings</h2>
You can change some values in settings.ini
<ul>
<li>USE_COLOURED_BUTTONS [1 | 0]: 1 = yes, otherwise buttons will be gray</li>
<li>USE_RANDOM_HUE [1 | 0]: 1 = yes, spice up your day with a random colour theme every time you launch</li>
<li>HUE_PREFERRED [0-360]: If not random, use this hue as a baseline colour for buttons</li>
<li>HUE_STEP : Increment the hue by this value on each button for a smooth and eye catching gradient, set to 0 to keep one colour</li>
<li>SAT_PREFERRED [0-100]: Colour saturation, 100 = vibrant, 0 = gray</li>
<li>LUM_PREFERRED [0-100]: Colour lightness, 100 = white, 0 = black</li>
</ul>
