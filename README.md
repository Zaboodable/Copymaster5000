<img src="/icon.ico"> 
<h1>Copy Master 5000</h1>
An all in one solution for your service desk needs.
<h2>Installation Instructions</h2>
<ol>
<li>Download files from repository to a folder -> (Code - Download ZIP) -> extract the folder somewhere</li>
<li>You may need to copy the content of <b>copymaster.ps1</b> into a new text file and save it as a new .ps1 file. (Downloaded one might not work due to execution policies)</li>
<li>Right click your new .ps1 file -> Send to -> Desktop (create shortcut)</li>
<li>Edit the new desktop shortcut by right clicking -> Properties -> <br><b>Target: </b>powershell.exe -NoP -W Hidden "Path\To\Copymaster\copymaster.ps1"<br><b>Start in:</b> Path\To\Copymaster</li>
<li>The shortcut should now launch CopyMaster3000</li>
<li>(Optional) Set shortcut icon: Right click -> Properties -> Change Icon -> Navigate to copymaster folder and select "img\icon.ico"</li>
</ol>
<b>You will need the data files, these are not stored on the repository. Copy them into the same folder as copymaster.ps1<b>

<h2>Features</h2>
<ul>
   <li style="list-style-type:disc">Categorized and searchable knowledgebase</li>
   <li style="list-style-type:disc">Tips and Tricks for common issues</li>
   <li style="list-style-type:disc">Information about systems</li>
   <li style="list-style-type:disc">Quick buttons for copying common replies/responses</li>
</ul>
<img src="/copymaster_preview.png"> 
   
<h2>Known Issues</h2>
Currently the search function will remove colours from the application, this is fixable but not a high priority at the moment.
