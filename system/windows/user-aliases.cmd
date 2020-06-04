;= @echo off
;= rem Call DOSKEY and use this file as the macrofile
;= %SystemRoot%\system32\doskey /listsize=1000 /macrofile=%0%
;= rem In batch mode, jump to the end of the file
;= goto:eof
;= Add aliases below here
e.=explorer .
gl=git log --oneline --all --graph --decorate  $*
ls=ls --show-control-chars -F --color $*
pwd=cd
clear=cls
history=cat "%CMDER_ROOT%\config\.history"
unalias=alias /d $1
vi=vim $*
cmderr=cd /d "%CMDER_ROOT%"

;= free green programs
mc.="%GreenPrograms%\Free\MultiCommander\MultiCommander.exe"
te.="%GreenPrograms%\Free\TablacusExplorer\TE64.exe"
anydesk="%GreenPrograms%\Free\AnyDesk\AnyDesk.exe"
bootice="%GreenPrograms%\Free\Bootice\BOOTICEx64_2016.06.17_v1.3.4.0.exe"
diskgenius="%GreenPrograms%\Free\DiskGenius\DiskGenius.exe"
dism="%GreenPrograms%\Free\Dism\Dism++x64.exe"
dms="%GreenPrograms%\Free\treeDMS\bin\startup.bat"
docfetcher="%GreenPrograms%\Free\DocFetcher-1.1.21\DocFetcher.exe"
eagleget="%GreenPrograms%\Free\EagleGet\EagleGet.exe"
everything="%GreenPrograms%\Free\Everything\Everything.exe"
foobar="%GreenPrograms%\Free\foobar2000\foobar2000.exe"
geek="%GreenPrograms%\Free\GeekUninstaller\geek"
gradle="%GreenPrograms%\Free\gradle\bin\gradle.bat"
keepass="%GreenPrograms%\Free\keepass\KeePass.exe"
manic="%GreenPrograms%\Free\ManicTime4.3.4\ManicTime.exe"
markdown="%GreenPrograms%\Free\CmdMarkdown\Cmd Markdown.exe"
mvn="%GreenPrograms%\Free\apache-maven\bin\mvn.cmd"
nms="%GreenPrograms%\Free\treeNMS\bin\startup.bat"
npp="%GreenPrograms%\Free\Notepad++\notepad++.exe"
pdf="%GreenPrograms%\Free\SumatraPDF\SumatraPDF.exe"
romviewer="%GreenPrograms%\Free\ROMViewer\ROMViewer.exe"
rutviewer="%GreenPrograms%\Free\ru.viewer.portable\rutview.exe"
shadowsocks="%GreenPrograms%\Free\ShadowSocks\ShadowsocksR-dotnet4.0.exe"
sharex="%GreenPrograms%\Free\ShareX\ShareX.exe"
sharp="%GreenPrograms%\Free\SharpDevelop\bin\SharpDevelop.exe"
speedpan="%GreenPrograms%\Free\SpeedPan\SpeedPan.exe"
teamviewer="%GreenPrograms%\Free\TeamViewer\TeamViewer_Setup.exe"
viz="%GreenPrograms%\Free\graphviz\bin\gvedit.exe"
wenku="%GreenPrograms%\Free\Fish-v326\Fish.exe"
wtg="%GreenPrograms%\Free\WTGA\wintogo.exe"
xmind="%GreenPrograms%\Free\XMind 8 Update 8\XMind.exe"
xterm="%GreenPrograms%\Free\moboXterm\MobaXterm_Personal_12.3.exe"

foxmail="E:\Data\Foxmail\foxmail.exe"
mt4hantec="E:\Data\MT4 Hantec Markets\terminal.exe"
mt4oanda="E:\Data\OANDA - MetaTrader\terminal.exe"

;=cracked programs
bcompare="%GreenPrograms%\Cracked\Beyond Compare 4\BCompare.exe"
xmlspy="%GreenPrograms%\Cracked\XMLSpy2013\XMLSpy2013\XMLSpy.exe"
sqldbx="%GreenPrograms%\Cracked\sqldbx\SqlDbx_V4.17_C.exe"
bcompare="%GreenPrograms%\Cracked\Beyond Compare 4\BCompare.exe"
xmanager="%GreenPrograms%\Cracked\Xmanager_xp510.com\Xmanager.exe"
vmware="C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe"
word="C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE"
excel="C:\Program Files (x86)\Microsoft Office\root\Office16\EXCEL.EXE"
ppt="C:\Program Files (x86)\Microsoft Office\root\Office16\POWERPNT.EXE"
visio="C:\Program Files (x86)\Microsoft Office\root\Office16\VISIO.EXE"
project="C:\Program Files (x86)\Microsoft Office\root\Office16\WINPROJ.EXE"
ea="C:\Program Files (x86)\Sparx Systems\EA Trial\EA.exe"
dbv="C:\Program Files (x86)\DbVisualizer\dbvis.exe"

;=installed programs that no need to crack.
paint="C:\Program Files\paint.net\PaintDotNet.exe"
firefox="C:\Program Files\Mozilla Firefox\firefox.exe"
chrome="C:\Users\Jason\AppData\Local\Google\Chrome\Application\chrome.exe"
glary="C:\Program Files (x86)\Glary Utilities 5\Integrator.exe"
opera="C:\Program Files\Opera\launcher.exe"
sysexplorer="C:\Program Files (x86)\System Explorer\SystemExplorer.exe"
7zip="C:\Program Files\7-Zip\7zFM.exe"
ccleaner="C:\Program Files\CCleaner\CCleaner64.exe"
ftp="C:\Program Files\FileZilla FTP Client\filezilla.exe"
potplayer="C:\Program Files\DAUM\PotPlayer\PotPlayerMini64.exe"
fastviewer="C:\Program Files (x86)\FastStone Image Viewer\FSViewer.exe"
xsj="C:\Program Files\Story\Story-writer.exe"
wiz="C:\Program Files (x86)\WizNote\Wiz.exe"
rdp=%windir%\system32\mstsc.exe
ij="C:\Program Files\JetBrains\IntelliJ IDEA 2018.3.1\bin\idea64.exe"
