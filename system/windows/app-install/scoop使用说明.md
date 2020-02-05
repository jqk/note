# scoop使用说明

## 一、位置

* [scoop官网](https://scoop.sh/)
* [scoop github](https://github.com/lukesampson/scoop)

## 二、安装scoop

从本节开始说明安装scoop及应用软件的过程，在最后有安装脚本总结。该脚本经过优化，其原理基于从本节开始的说明。

官方要求在`PowerShell`中运行以下各类命令，除`set-executionpolicy`相关语句外，无需管理员权限。

### 2.1默认安装位置

`scoop`默认安装在`Users\<user>\scoop\apps\scoop\current`中，`<user>`为用户名。安装后会在该目录下建立以下目录：

|目录|用途|
|------|------|
|app|应用程序安装目录|
|buckets|bucket信息目录|
|cache|下载的安装程序缓存目录|
|persist|所安装程序的配置文件目录|
|shims|链接信息目录|

### 2.2修改安装位置

将`scoop`本身安装到指定目录，例如`C:\Scoop`：

```ps
$env:SCOOP='C:\Scoop'
[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')
```

将需要通过`scoop`安装的应用程序安装到指定目录，例如`C:\ScoopApps`：

```ps
$env:SCOOP_GLOBAL='C:\ScoopApps'
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')
```

### 2.3安装scoop

运行：

```ps
set-executionpolicy remotesigned -scope currentuser
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
```

安装过程基本没有一次直接成功，总是建立连接有问题。最终都是莫名其妙解决的：

1. ping连接地址。
1. 使用浏览器打开连接地址。
1. 将`https`换为`http`。不可以取消协议前缀，否则是找本地文件。
1. 在地址字符串前、后加空格，不成功再改回来。
1. 直接把连接对应的文件`https://raw.githubusercontent.com/lukesampson/scoop/master/bin/install.ps1`下载下来执行。

通过以上手段反复折腾后最终是可以安装成功的。

通过`scoop -help`可以获得命令行参数说明。

## 三、初始化

首先安装多线程下载，在github上有说明：

```ps
scoop install aria2                     # 安装多线程应用。

# 以下为检查或设置是否使用多线程下载功能的命令。
scoop config aria2-enabled              # 显示是否使用多线程下载，默认为true。
scoop config aria2-enabled true         # 启用多线程下载。
scoop config aria2-enabled false        # 关闭多线程下载。
```

另外应加入bucket:

```ps
scoop bucket add extras
scoop bucket add nonportable
scoop bucket add jetbrains
scoop bucket add ash258 https://github.com/Ash258/scoop-Ash258
scoop bucket add dorado https://github.com/h404bi/dorado
scoop bucket add bear https://github.com/AStupidBear/scoop-bear
```

然后安装`git`，接着再安装其它程序。

## 四、安装应用程序

### 4.1正常安装

执行`scoop install <app>`命令即可安装软件，其中`<app>`是待安装软件的名称。如果不确定软件名称，可以使用`scoop search <app>`命令进行查找。

如果同一个应用程序有多个对应名称，尽量安装名为`<app>-portable`的程序，否则安装`<app>`，最后选择`<app>-np`。

实验证明，以下应用下载成功，文件可打开，但安装不成功：

* eagleget-portable
* foxit-reader
* IntelliJ-IDEA-Ultimate-portable

有一些程序必需换网络或VPN才能下载：

* manictime
* potplayer
* proxifier-portable

有一些程序下载速度很慢：

* filezilla
* foobar2000-portable
* listary
* opera
* vscode

`dark`是安装某个程序所需要，虽然安装时一并安装，但最好提前执行。`vcredist2015`是某个程序建议的，但不安装貌似也可以正常运行。`Cmder`需使用`git`，所以`git`应在安装完`aria2`后立即安装。

应用程序安装过后，都是默认语言，也没有任何插件。这些需要启动后设置，并手动安装。

### 4.2安装失败及重试

安装失败原因可能很多，但最常见的是下载失败，或下载未完整。此时，应先执行`scoop uninstall <app>`命令，然后删除`cache`目录下刚刚下载的文件，最后再次运行`scoop install <app>`执行安装。

下载在文件名与`<app>`指定的待安装程序的名字有比较直观的逻辑联系。

有时，下载文件从一开始就失败，且反复重试也无法自动下载，例如`telegram`。通过查看`scoop`安装过程报错信息可以得到两个信息：

1. 待下载安装程序的地址。
2. 保存在`cache`中的文件名。

想办法上网，通过浏览器下载安装程序；将安装程序复制到`cache`并改名；重新安装即可。

### 4.3下载缓存cache的处理

### 4.3.1保存已下载文件供后续使用

安装过程中下载的文件被放置在`cache`目录中，安装之后删除这些文件不会对系统产生任何影响。但如果不删除这些文件，在执行`scoop uninstall <app>`卸载应用后再执行`scoop install <app>`将省略下载文件的过程。

因此，可以备份这些文件，在需要使用`scoop`在其它机器上安装软件时，将这些文件复制到`cache`目录下，即可避免下载安装文件。唯一可虑的是，所需安装的软件版本有更新。如果是这种情况，`cache`中的文件是无效的。以`potplayer`为例，已安装的版本在`cache`中对应的文件是`potplayer#191211#https_t1.daumcdn.net_potplayer_PotPlayer_Version_20191211_PotPlayerSetup64.exe_cosi.7z`，而新版是`potplayer#200204#https_t1.daumcdn.net_potplayer_PotPlayer_Version_20200204_PotPlayerSetup64.exe_dl.7z`。此时，`scoop`会下载新文件，而不使用旧文件。当升级成功后，旧文件可以删除。

同一个程序，可能在不同的`bucket`中都有定义，例如`potplayer`在`ash258`和`extra`中都有定义。如果使用`scoop install potplayer`安装，将使用排序靠前的`ash258`。若要使用`extra`，需在命令行中指定，即`scoop install extras/potplayer`。

注意这两个`bucket`指向的安装文件是相同的，但它们下载结果文件命令不同。`ash258`的文件以`cosi.7z`结尾，而`extra`的文件以`dl.7z`结尾，文件名的其它部分相同，下载的也是相同的文件。

### 4.3.2使用软链接共享已下载文件

在A机上安装好`scoop`后，进入其目录，因为尚未安装任何程序，所以`cache`为空。在Server端(如192.168.0.1)配置好共享目录，需可读写，例如`server_cache`，在A机上执行以下命令：

```ps
rd cache
mklink /d cache \\192.168.0.1\server_cache
```

该操作将空目录`cache`删除，然后建立了一个指向共享目录的软链接，取名仍为`cache`以欺骗`scoop`。经实测，在B机上也做如此操作后，两台机器的`scoop`可共享下载文件。通过该方式，可使多台主机共享一份下载，即提高速度，又节省空间。

**注意**，理论上对`apps`目录也可做相同的处理，因为其配置保存位置与安装目录。但未测试。

## 五、升级应用程序

通过`scoop status`可以查看所有程序的版本状态。通过`scoop update *`升级所有程序至最新版本，或`scoop update <app>`升级指定的程序。

程序默认安装于`Users\<user>\scoop\apps\<app>`中，其中`user`是用户名，`<app>`是安装时指定的应用程序名称。在该目录下，初始安装时会有一个版本号目录和一个目录链接。

以应用软件`peazip`为例，在用户名为`Jason`的系统中，该程序被安装在`C:\Users\Jason\scoop\apps\peazip`中。在`2020-02-01`初次安装后，该目录中有子目录`7.0.1`和软链接`current`。双击`current`会直接进入目录`7.0.1`。

`2020-02-03`该程序有版本更新至`7.1.0`。通过命令升级后，在安装目录中建立了新的目录`7.1.0`，`current`也指向该目录。上一版本的目录`7.0.1`仍被保留，但手动删除该目录不会对系统产生影响。由于配置信息在`persist\peazip`中，所以升级未影响程序行为。

因此，升级后，旧版程序可以删除。相应的，在`cache`中的旧版安装包也可删除。执行删除的前提是保证新版运行无异常，否则若需回退，则要重新下载前一版本。

## 六、已安装程序列表

尽量安装一些相对不太大的应用软件的绿色版。

|软件名称|版本|bucket|用途|初始化任务|原始启动命令|
|------|------:|------|------|------|------|
|7zip|19.00||压缩工具||7z|
|aria2|1.35.0-1||多线程下载||aria2c|
|besttrace|nightly-20200204|dorado|路由跟踪||17monipdb|
|beyondcompare|4.3.3.24545|extras|文件对比|注册码|bcomp|
|calibre|4.9.1|extras|文档阅读||calibre|
|cmder|1.3.14||增强命令行|透明度，特有命令设置|cmder|
|dark|3.11.2||命令行安装工具||dark|
|diskgenius|5.2.0.884|extras|磁盘管理||diskgenius|
|dismplusplus|10.1.1001.10|extras|系统优化||dism++x64|
|ditto|3.22.88.0|extras|多剪裁板|中文及快捷键|ditto|
|dnsjumper|2.1|extras|DNS工具||dnsjumper|
|driverstoreexplorer|0.10.58|extras|驱动管理||rapr|
|dropit|8.5.1|extras|文件分类|分类规则设置||
|everything|1.4.1.935|extras|文件查找||everything|
|filezilla|3.46.3|extras|FTP客户端||filezilla|
|firefox|72.0.2|extras|浏览器|安装必备插件|firefox|
|foobar2000-portable|1.5.1|extras|音乐播放器||foobar2000|
|geekuninstaller|1.4.7.142|extras|程序卸载||geek|
|git|2.25.0.windows.1||版本管理||git|
|GlaryUtilities|5.136|ash258|系统维护|启动项等设置||
|go|1.13.7||GO语言环境|go|
|googlechrome|79.0.3945.130|extras|浏览器|安装必备插件|chrome|
|gradle|6.1.1||依赖管理||gradle|
|graphviz|2.38||用文本画图||gvedit|
|innounp|0.49||程序安装|||
|irfanview|4.54|extras|看图工具||irfanview|
|julia|1.3.0|bear|julia语言环境||julia|
|keepass|2.44|extras|密码管理||keepass|
|lessmsi|1.6.91||MSI文件工具||lessmsi|
|listary|5.00.2843|extras|文件查找|注册码||
|manictime|4.4.7.1|extras|操作用时统计|||
|maven|3.6.3||依赖及打包管理||mvn|
|notepadplusplus|7.8.4|extras|文本编辑器||notepad++|
|opera|66.0.3515.60|extras|浏览器|安装必备插件||
|paint.net|4.2.9|extras|画图工具||paintdotnet|
|peazip|7.1.0|extras|压缩工具|语言|peazip|
|plantuml|1.2020.0|extras|文本画UML||plantuml|
|potplayer|191211|ash258|视频播放器|||
|proxifier-portable|3.42|extras|网络代理|注册码|proxifier|
|python|3.8.1||python语言环境||python|
|quicklook|3.6.5|extras|文件快速预览|office相关插件||
|recuva|1.53.1087|extras|文件恢复||recuva|
|shadowsocks|4.1.9.2|extras|网络代理||shadowsocks|
|shadowsocksr-csharp|4.9.2|extras|网络代理||shadowsocksr-dotnet4.0|
|sharex|13.0.1|extras|截图工具|快捷键|sharex|
|smartgit|19.1.6|extras|GIT客户端|登录|smartgit|
|snipaste|1.16.2|extras|截图工具|快捷键|snipaste|
|sourcetree|3.3.8|extras|GIT客户端|登录|sourcetree|
|switchhosts|3.5.4|extras|DNS工具|||
|teamviewer|15.2.2756|extras|远程管理||teamviewer|
|teracopy-np|3.26|nonportable|复制加速|||
|telegram|1.9.9|extras|即时通讯||telegram|
|thunderbird-portable|68.4.2|extras|邮件客户端||thunderbird|
|TranslucentTB|2019.2|dorado|任务栏透明化|启动设置||
|vcredist2015|14.0.24215|extras|系统运行时|不一定安装||
|vscode|1.41.1|extras|跨平台IDE|基础插件|code|
|xmind8|3.7.8|extras|思维导图|不建议安装Bonjour||

注意`xmind8`、`smartgit`、`plantuml`及`graphviz`等程序需要`Java虚拟机`。前两者自带`JRE`，无需单独下载虚拟机。

由于当前系统要求使用`oracle JDK 8`，而使用`scoop`安装只能安装`oracle JDK 13`，其它`版本8的JDK`均非`oracle`出品，所以`Java虚拟机`需手动安装。

## 七、安装脚本

### 7.1设置权限

需用管理员身份运行`PowerShell`：

```ps
set-executionpolicy remotesigned -scope currentuser
```

### 7.2安装scoop

#### 7.2.1安装

安装`scoop`及应用软件无需管理员权限，直接在`PowerShell`运行：

```ps
$env:SCOOP='C:\Scoop'
[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')

Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
```

#### 7.2.2准备`cache`共享空间

在地址为`192.168.163.1`(本人笔记本`VMware`主地址)的主机上建立虚拟机共享目录`vm_share`，并在该目录下建立专用于共享下载文件的目录`scoop\cache`。确保该目录可读写。

#### 7.2.3

在`命令行`中执行：

```ps
c:
cd \Scoop
del cache
rd cache
mklink /d cache \\192.168.163.1\vm_share\scoop\cache
```

以上过程首先进入`scoop`目录，然后删除`cache`，最后建立软件链接。

### 7.3安装应用软件

在安装应用软件前，应先安装`Java虚拟机`，否则，应在以下脚本中安装，但版本不是`Java8`。

```ps
# the first should be zip tool
scoop install 7zip

# the second is multithread downloading tool
scoop install aria2

# the third is git, storing bucket
scoop install git

# add buckets
scoop bucket add extras
scoop bucket add nonportable
scoop bucket add jetbrains
scoop bucket add ash258 https://github.com/Ash258/scoop-Ash258
scoop bucket add dorado https://github.com/h404bi/dorado
scoop bucket add bear https://github.com/AStupidBear/scoop-bear

# then install package tools, may be used by many others
scoop install dark
scoop install innounp
scoop install lessmsi

# install JDK when required. it's not version 8
# scoop install oraclejdk

# below are alphabet sequence
scoop install besttrace
scoop install beyondcompare         # serial number required
scoop install calibre
scoop install cmder
scoop install diskgenius            # free & pro
scoop install dismplusplus
scoop install ditto
scoop install dnsjumper
scoop install driverstoreexplorer
scoop install dropit
scoop install everything
scoop install filezilla
scoop install firefox
scoop install foobar2000-portable
scoop install geekuninstaller
scoop install GlaryUtilities        # free & pro
scoop install go
scoop install googlechrome
scoop install gradle
scoop install graphviz              # require jre
scoop install irfanview
scoop install julia
scoop install keepass
scoop install listary               # free & pro
scoop install manictime             # free & pro
scoop install maven
scoop install notepadplusplus
scoop install opera
scoop install paint.net
scoop install peazip
scoop install plantuml              # require jre
scoop install potplayer
scoop install proxifier-portable    # serial number required
scoop install python
scoop install quicklook
scoop install recuva
scoop install shadowsocks
scoop install shadowsocksr-csharp
scoop install sharex
scoop install smartgit              # free & pro, include openjdk
scoop install snipaste
scoop install sourcetree
scoop install switchhosts
scoop install teamviewer            # free & pro
scoop install teracopy-np
scoop install telegram
scoop install thunderbird-portable
scoop install TranslucentTB
scoop install vscode
scoop install xmind8                # free & pro, include oracle jre 8
```

以上程序安装后`apps`共约`4.6GB`，`cache`共约`2.4GB`。

### 7.4右键菜单

通过`scoop`安装`notepad++`不会自动在右键菜单中添加使用`Edit with Notepad++`条目，应建立一个文本文件，以`.reg`作为扩展名，包含以下内容：

```registry
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\*\shell\Edit with Notepad++]
"Icon"="\"C:\\Scoop\\apps\\notepadplusplus\\current\\notepad++.exe\""
"MultiSelectMode"="Single"

[HKEY_CLASSES_ROOT\*\shell\Edit with Notepad++\Command]
@="\"C:\\Scoop\\apps\\notepadplusplus\\current\\notepad++.exe\" \"%1\""
```

双击该文件，将会更新注册表，再启动文件管理器，在右键菜单中会增加`Edit with Notepad++`条目。

安装完`vscode`会有提示：

```text
Add Visual Studio Code as a context menu option by running: "C:\Scoop\apps\vscode\current\vscode-install-context.reg"
```

通过文件管理器双击该文件，将会更新注册表，再启动文件管理器，在右键菜单中会增加`open with code`条目。

### 7.5应用程序设置

vscode插件：`中文显示`，`Python`，`Go`，`GitLens`，`Julia`，`PowerShell`，`YAML`，`Rainbow Brackets`，`CodeRunner`，`Visual Studio IntelliCode`。

## 八、参考资料

《[Windows包管理工具：Scoop 介绍](https://blog.csdn.net/Edisonleeee/article/details/94748703)》有对于自建`bucket`的简单说明。
