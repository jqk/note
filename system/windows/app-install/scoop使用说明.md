# scoop使用说明

- scoop使用说明
  - 一、 位置
  - 二、 安装scoop
    - 2.1 设置运行权限
    - 2.2 安装位置及目录结构
    - 2.3 安装scoop
      - 2.3.1 命令行安装
      - 2.3.2 自行从`github`上下载
      - 2.3.3 从已安装系统复制
  - 三、 初始化scoop
    - 3.1 安装git
    - 3.2 增加bucket
    - 3.3 安装多线程下载
  - 四、 安装应用程序
    - 4.1 正常安装
    - 4.2 安装失败及重试
    - 4.3 处理下载缓存
    - 4.4 保存已下载文件供后续使用
    - 4.5 使用软链接共享已下载文件
  - 五、 升级应用程序
  - 六、 已安装程序列表
  - 七、 安装脚本
    - 7.1 安装scoop
      - 7.1.1 官方安装
      - 7.1.2 非官方安装
      - 7.1.3 准备共享空间
      - 7.1.4 链接共享空间
    - 7.2 初始化
    - 7.3 安装应用软件
      - 7.3.1 安装必备软件
      - 7.3.2 安装全部软件
    - 7.4 右键菜单
    - 7.5 应用程序设置
    - 7.6 最简安装总结
  - 八、 备份与恢复
  - 九、 共享安装总结
    - 9.1 设置权限
    - 9.2 准备共享
    - 9.3 设置环境
    - 9.4 安装基础应用及软件源
  - 十、 参考资料

-----

## 一、 位置

- [scoop官网](https://scoop.sh/)
- [scoop github](https://github.com/lukesampson/scoop)

## 二、 安装scoop

**从本节开始说明安装scoop及应用软件的过程，在最后有共享安装脚本总结。该脚本经过优化，其原理基于从本节开始的说明**。初次安装请逐节阅读。

官方要求在`PowerShell`中运行以下各类命令，除设置运行权限相关语句外，无需管理员权限。如未做特殊说明，则所有命令运行于`PowerShell`，无管理员权限。

### 2.1 设置运行权限

需以管理员身份在`PowerShell`运行以下命令：

```ps
set-executionpolicy remotesigned -scope currentuser
```

得到如下提示，选择`A`即可。

```text
执行策略更改
执行策略可帮助你防止执行不信任的脚本。更改执行策略可能会产生安全风险，如 https:/go.microsoft.com/fwlink/?LinkID=135170
中的 about_Execution_Policies 帮助主题所述。是否要更改执行策略?
[Y] 是(Y)  [A] 全是(A)  [N] 否(N)  [L] 全否(L)  [S] 暂停(S)  [?] 帮助 (默认值为"N"): a
```

### 2.2 安装位置及目录结构

`scoop`默认安装在`Users\<user>\scoop\apps\scoop\current`中，`<user>`为用户名，本文示例中为`Jason`。也可以指定安装目录，本文此后均以安装到`C:\Scoop`为示例。指定安装目录时运行：

```ps
$env:SCOOP='C:\Scoop'
[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')
```

该命令会在`用户环境变量`中增加`SCOOP=C:\Scoop`。指定安装目录**不是必须的**。

安装`scoop`并安装`git`后目录结构如下：

```text
C:\SCOOP
+---apps
|   +---7zip
|   |   +---19.00
|   |   \---current
|   +---git
|   |   +---2.25.0.windows.1
|   |   \---current
|   \---scoop
|       \---current
+---buckets
|   +---ash258
|   +---bear
|   +---dorado
|   +---extras
|   +---java
|   +---jetbrains
|   +---main
|   \---nonportable
+---cache
+---persist
\---shims
```

|目录|用途|
|------|------|
|apps|应用程序安装目录，刚安装时只有`scoop`自身|
|buckets|程序源信息目录，刚安装时只有`main`|
|cache|下载的安装程序缓存目录，刚安装时为空|
|persist|所安装程序的配置文件目录，刚安装时为空|
|shims|链接信息目录，提供快捷方式等文件，刚安装时只有指向`scoop`自身的3个文件|

应用程序默认安装在`C:\Scoop\apps`中，也可以指定专门应用程序安装目录。以`C:\ScoopApps`为例，设置应用程序安装目录应以管理员身份运行如下命令：

```ps
$env:SCOOP_GLOBAL='C:\ScoopApps'
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')
```

该命令会在`主机环境变量`中增加`SCOOP_GLOBAL=C:\ScoopApps`。指定应用程序安装目录**不是必须的**。

如果指定了应用程序安装目录，安装`scoop`后目录结构如下：

```text
C:\SCOOP
+---apps
|   \---scoop
|       \---current
+---buckets
|   \---main
\---shims
        scoop
        scoop.cmd
        scoop.ps1
```

安装完成后未建立`C:\ScoopApps`目录。该目录应该在首次下载并安装全局性应用时建立。**至于全局性应用是什么，至今还未搞清楚。应该是使用`scoop install -g <app>`时的目标目录，但未尝试**。

无论以何种方式安装，均会在`用户环境变量`的`PATH`中增加`C:\Scoop\shims`，并增加`GIT_INSTALL_ROOT=C:\Scoop\apps\git\current`。

### 2.3 安装scoop

如果网络环境中没有已安装`scoop`的主机，则建议通过命令行安装，否则从已安装主机复制`scoop`系统比较方便。

#### 2.3.1 命令行安装

运行：

```ps
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
```

安装多次，只有一次直接成功，其它的总是建立连接有问题。最终都是莫名其妙解决的：

1. ping连接地址。
1. 使用浏览器打开连接地址。
1. 将`https`换为`http`。不可以取消协议前缀，否则是找本地文件。
1. 在地址字符串前、后加空格，不成功再改回来。
1. 直接把连接对应的文件`https://raw.githubusercontent.com/lukesampson/scoop/master/bin/install.ps1`下载下来执行。
1. 先科学上网，再运行以上命令，这个最有效。

通过以上手段反复折腾后最终是可以安装成功的。

#### 2.3.2 自行从`github`上下载

该方案操作相当麻烦，基本上是把命令行安装的事做一遍：

1. 建立目录结构。
2. 下载`scoop`及软件源`main`。
3. 配置环境变量。

不推荐此方案。

#### 2.3.3 从已安装系统复制

如果指定了应用程序安装目录，则执行如下操作，设已安装`scoop`的主机为A，将要安装`scoop`的主机为B：

1. 在B上建立目录C:\Scoop
2. 从A上复制C:\Scoop\apps\scoop，保留目录结构
3. 从A上复制C:\Scoop\shims中3个与`scoop`相关的文件，保留目录结构
4. B上将C:\Scoop\shims加入PATH
5. 设置B上`用户环境变量`SCOOP=C:\Scoop
6. 设置B上`主机环境变量`SCOOP_GLOBAL=C:\ScoopApps
7. 建立C:\ScoopApps目录

如果未指定应用程序安装目录，无需执行最后两步。**本文最后有关于共享安装的总结**。

## 三、 初始化scoop

通过`scoop -help`可以获得命令行参数说明。

### 3.1 安装git

`scoop`的许多内部操作，包含获取`bucket`等，均`git`支持，所以需首先安装。

```ps
scoop install git
```

正常执行后结果如下：

```text
Installing '7zip' (19.00) [64bit]
7z1900-x64.msi (1.7 MB) [========================================] 100%
Checking hash of 7z1900-x64.msi ... ok.
Extracting 7z1900-x64.msi ... done.
Linking C:\Scoop\apps\7zip\current => C:\Scoop\apps\7zip\19.00
Creating shim for '7z'.
Creating shortcut for 7-Zip (7zFM.exe)
'7zip' (19.00) was installed successfully!
Installing 'git' (2.25.0.windows.1) [64bit]
PortableGit-2.25.0-64-bit.7z.exe (41.1 MB) [=====================] 100%
Checking hash of PortableGit-2.25.0-64-bit.7z.exe ... ok.
Extracting dl.7z ... done.
Linking C:\Scoop\apps\git\current => C:\Scoop\apps\git\2.25.0.windows.1
Creating shim for 'git'.
Creating shim for 'gitk'.
Creating shim for 'git-gui'.
Creating shim for 'tig'.
Creating shim for 'git-bash'.
Creating shortcut for Git Bash (git-bash.exe)
Creating shortcut for Git GUI (git-gui.exe)
Creating shortcut for gitk (gitk.exe)
Running post-install script...
'git' (2.25.0.windows.1) was installed successfully!
```

安装`git`会先安装解压缩工具`7zip`。

如果使用共享的下载文件，则前面结果中的下载过程将直接跳过。

### 3.2 增加bucket

```ps
scoop bucket add extras
scoop bucket add nonportable
scoop bucket add jetbrains
scoop bucket add ash258 https://github.com/Ash258/scoop-Ash258
scoop bucket add dorado https://github.com/h404bi/dorado
scoop bucket add bear https://github.com/AStupidBear/scoop-bear
```

### 3.3 安装多线程下载

安装多线程下载，在github上有说明：

```ps
scoop install aria2                     # 安装多线程应用。

# 以下为检查或设置是否使用多线程下载功能的命令。
scoop config aria2-enabled              # 显示是否使用多线程下载，默认为true。
scoop config aria2-enabled true         # 启用多线程下载。
scoop config aria2-enabled false        # 关闭多线程下载。

scoop config aria2-max-connection-per-server 16
scoop config aria2-split 16
scoop config aria2-min-split-size 1M
```

有时多线程下载并不好用，可以通过开关来回切换尝试下载。

## 四、 安装应用程序

### 4.1 正常安装

执行`scoop install <app>`命令即可安装软件，其中`<app>`是待安装软件的名称。如果不确定软件名称，可以使用`scoop search <app>`命令进行查找，该命令会返回哪个`bucket`包含所查找的软件。当然这些`bucket`需事先添加好。

如果同一个应用程序有多个对应名称，尽量安装名为`<app>-portable`的程序，否则安装`<app>`，最后选择`<app>-np`。

实验证明，有许多应用软件下载成功，文件可打开，但安装不成功：

- eagleget-portable
- foxit-reader
- IntelliJ-IDEA-Ultimate-portable

有一些程序必需科学上网才能下载：

- manictime
- potplayer
- proxifier-portable

有一些程序下载速度很慢：

- filezilla
- foobar2000-portable
- listary
- opera
- vscode

`dark`是安装某个程序所需要，虽然安装时一并安装，但最好提前执行。`vcredist2015`是某个程序建议的，但不安装貌似也可以正常运行。`Cmder`需使用`git`，所以`git`应在安装完`aria2`后立即安装。

应用程序安装过后，都是默认语言，也没有任何插件。这些需要启动后设置，并手动安装。

### 4.2 安装失败及重试

安装失败原因可能很多，但最常见的是下载失败，或下载未完整。此时，应先执行`scoop uninstall <app>`命令，然后删除`cache`目录下刚刚下载的文件，最后再次运行`scoop install <app>`执行安装。

下载在文件名与`<app>`指定的待安装程序的名字有比较直观的逻辑联系。

有时，下载文件从一开始就失败，且反复重试也无法自动下载，例如`telegram`。通过查看`scoop`安装过程报错信息可以得到两个信息：

1. 待下载安装程序的地址。
2. 保存在`cache`中的文件名。

想办法上网，通过浏览器下载安装程序；将安装程序复制到`cache`并改名；重新安装即可。

### 4.3 处理下载缓存

### 4.4 保存已下载文件供后续使用

安装过程中下载的文件被放置在`cache`目录中，安装之后删除这些文件不会对系统产生任何影响。但如果不删除这些文件，在执行`scoop uninstall <app>`卸载应用后再执行`scoop install <app>`将省略下载文件的过程。

因此，可以保留这些文件，在需要使用`scoop`在其它机器上安装软件时，将这些文件复制到新主机的`cache`目录下或远程共享，即可避免下载安装文件。唯一可虑的是，若所需安装的软件版本有更新，则`cache`中的文件是无效的。以`potplayer`为例，已安装的版本在`cache`中对应的文件是`potplayer#191211#https_t1.daumcdn.net_potplayer_PotPlayer_Version_20191211_PotPlayerSetup64.exe_cosi.7z`，而新版是`potplayer#200204#https_t1.daumcdn.net_potplayer_PotPlayer_Version_20200204_PotPlayerSetup64.exe_dl.7z`。此时，`scoop`会下载新文件，而不使用旧文件。当升级成功后，旧文件可以删除。

同一个程序，可能在不同的`bucket`中都有定义，例如`potplayer`在`ash258`和`extra`中都有定义。如果使用`scoop install potplayer`安装，将使用排序靠前的`ash258`。若要使用`extra`，需在命令行中指定，即`scoop install extras/potplayer`。

注意这两个`bucket`指向的安装文件是相同的，但它们下载结果文件命令不同。`ash258`的文件以`cosi.7z`结尾，而`extra`的文件以`dl.7z`结尾，文件名的其它部分相同，下载的也是相同的文件。

### 4.5 使用软链接共享已下载文件

已下载文件包含应用程序的安装包以及程序源`bucket`信息。

在A机上安装好`scoop`后，先不进行初始化，所以`cache`和`buckets`均为空。

在名为server的主机上，将其它主机已安装好的`cache`和`buckets`目录复制过来，建立好**可读写共享目录**，装好的例如`vm_share\scoop\cache`和`vm_share\scoop\buckets`，在A机上以管理员身份在`命令行`下执行：

```cmd
rd cache
mklink /d cache \\server\vm_share\scoop\cache
rd buckets
mklink /d buckets \\server\vm_share\scoop\buckets
```

**注意**：该操作即使目标不可用，也不报错。建立软链接后应执行`dir`等命令确认链接可用。如不可用，可使用`rd`命令删除已建链接，然后重新建立。

该操作将空目录`cache`删除，然后建立了一个指向共享目录的软链接，取名仍为`cache`以欺骗`scoop`。`buckets`目录同理。经实测，在B机上也做如此操作后，两台机器的`scoop`可共享下载文件及`buckets`信息。通过该方式，可使多台主机共享一份下载，即提高速度，又节省空间。

执行以上命令后执行`dir`，得到如下结果：

```text
C:\Scoop 的目录

2020/02/06  07:07    <DIR>          .
2020/02/06  07:07    <DIR>          ..
2020/02/06  06:37    <DIR>          apps
2020/02/06  07:07    <SYMLINKD>     buckets [\\server\vm_share\scoop\buckets]
2020/02/06  07:06    <SYMLINKD>     cache [\\server\vm_share\scoop\cache]
2020/02/06  06:37    <DIR>          shims
```

**注意**：理论上对`apps`目录也可做相同的处理，因为其配置保存位置与安装目录。虽未进行过测试，但原理上，大多数`portable`程序均应能正常执行。不过在系统启动时自启动的程序，或非`portable`程序可能会出问题。所以建议应用程序仍安装在本机，不进行共享。

## 五、 升级应用程序

通过`scoop status`可以查看所有程序的版本状态。通过`scoop update *`升级所有程序至最新版本，或`scoop update <app>`升级指定的程序。

程序默认安装于`Users\<user>\scoop\apps\<app>`中，其中`user`是用户名，`<app>`是安装时指定的应用程序名称。在该目录下，初始安装时会有一个版本号目录和一个目录链接。

以应用软件`peazip`为例，在用户名为`Jason`的系统中，该程序默认被安装在`C:\Users\Jason\scoop\apps\peazip`中。在`2020-02-01`初次安装后，该目录中有子目录`7.0.1`和软链接`current`。双击`current`会直接进入目录`7.0.1`。

`2020-02-03`该程序有版本更新至`7.1.0`。通过命令升级后，在安装目录中建立了新的目录`7.1.0`，`current`也指向该目录。上一版本的目录`7.0.1`仍被保留，但手动删除该目录不会对系统产生影响。由于配置信息在`persist\peazip`中，所以升级未影响程序行为。其目录结构升级后如下，省略了许多其它程序：

```text
C:\Users\Jason\scoop
+---apps
|   +---peazip
|   |   +---7.0.1
|   |   +---7.1.0
|   |   \---current
|   +---git
|   |   +---2.25.0.windows.1
|   |   \---current
|   \---scoop
|       \---current
+---buckets
+---cache
+---persist
\---shims
```

因此，升级后，旧版程序可以删除。相应的，在`cache`中的旧版安装包也可删除。执行删除的前提是保证新版运行无异常，否则若需回退，则要重新下载前一版本。

升级之后，应清理旧版本程序，以释放空间：

```ps
scoop cleanup *
```

## 六、 已安装程序列表

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

## 七、 安装脚本

### 7.1 安装scoop

#### 7.1.1 官方安装

安装`scoop`及应用软件无需管理员权限，直接在`PowerShell`运行：

```ps
$env:SCOOP='C:\Scoop'
[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')

Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
```

前面两条命令指定了`scoop`的安装目录，而不是默认的`Users\<user>\scoop`。如果不需要单独建立目录，可以选择不运行。

#### 7.1.2 非官方安装

直接将已安装好的`scoop`复制过来，或从`githut`下载。然后设置路径即可。

#### 7.1.3 准备共享空间

**不采用共享方式安装可略过此步。**

在地址为`192.168.163.1`(本人笔记本`VMware`主地址)的主机上建立虚拟机共享目录`vm_share`，并在该目录下建立专用于共享下载文件的目录`scoop\cache`，将已安装好的`buckets`复制过来，成为`scoop\buckets`。确保这两个目录可读写。

#### 7.1.4 链接共享空间

**不采用共享方式安装可略过此步。**

以管理员身份在`命令行`中执行：

```cmd
c:
cd \Scoop

rd cache
mklink /d cache \\ssd_win10\vm_share\scoop\cache

rd buckets
mklink /d buckets \\ssd_win10\vm_share\scoop\buckets
```

以上过程首先进入`scoop`目录，然后删除`cache`，最后建立软件链接。接着对`buckets`做相同处理。

### 7.2 初始化

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
```

### 7.3 安装应用软件

#### 7.3.1 安装必备软件

```ps
# below are alphabet sequence
scoop install dismplusplus
scoop install everything
scoop install firefox
scoop install googlechrome
scoop install notepadplusplus
scoop install opera
scoop install peazip
scoop install shadowsocks
scoop install shadowsocksr-csharp
```

#### 7.3.2 安装全部软件

在安装应用软件前，应先安装`Java虚拟机`，否则，应在以下脚本中安装，但版本不是`Java8`。

```ps
# install package tools, may be used by many others
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
scoop install ffmpeg
scoop install filezilla
scoop install firefox
scoop install foobar2000-portable
scoop install foxit-reader
scoop install geekuninstaller
scoop install GlaryUtilities        # free & pro
scoop install go
scoop install googlechrome
scoop install gradle
scoop install graphviz              # require jre
scoop install irfanview
scoop install IntelliJ-IDEA-Ultimate-portable
scoop install julia
scoop install keepass
scoop install listary               # free & pro
scoop install manictime             # free & pro
scoop install maven
scoop install nodejs
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
scoop install simplefirefoxbackup
scoop install smartgit              # free & pro, include openjdk
scoop install snipaste
scoop install sourcetree
scoop install switchhosts
scoop install teamviewer            # free & pro
# scoop install teracopy-np
scoop install telegram
scoop install thunderbird-portable
scoop install TranslucentTB
scoop install typora
scoop install vim
scoop install vscode
scoop install wget
scoop install wireshark
scoop install xmind8                # free & pro, include oracle jre 8
```

以上程序安装后`apps`共约`5.1GB`，`cache`共约`2.5GB`。

### 7.4 右键菜单

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

### 7.5 应用程序设置

vscode插件：`中文显示`，`Python`，`Go`，`GitLens`，`Julia`，`PowerShell`，`YAML`，`Rainbow Brackets`，`CodeRunner`，`Visual Studio IntelliCode`。

### 7.6 最简安装总结

最简安装只安装最基本的`scoop`组成及系统所需的应用程序。同时，最简安装假设`scoop`已经在其它主机安装过，并在`\\ssd-win10\vm_share\scoop`下建立好了共享。

以`管理员`身份打开`PowerShell`和`命令行`，然后依次执行

1. 以`管理员`身份打开`命令行`，执行[scoop1-run-admin.bat](scoop\scoop1-run-admin.bat)。遇到命令行提问选择`D`，即目录。
2. 以`管理员`身份打开`PowerShell`，手工逐条执行[scoop2-run-admin-manual.ps1](scoop/scoop2-run-admin-manual.ps1)中的命令。对第一条设置权限命令选择`A`作为应答。
3. 在打开的`PowerShell`中直接运行[scoop3-install-apps](scoop/scoop3-install-apps.ps1)。
4. 在打开的`命令行`中直接运行[scoop4-notepad++.reg](scoop/scoop4-notepad++.reg)。该操作调起注册表编辑器并询问是否导入注册表信息，选择`是`。

## 八、 备份与恢复

在安装所有软件后，可通过以下命令导出已装软件列表：

```ps
scoop list
# 将其保存入文件可用
scoop list > scoop-list.txt
```

但其内容如下：

```text
7zip (v:19.00) [main]
aria2 (v:1.35.0-1) [main]
besttrace (v:nightly-20200227) [dorado]
beyondcompare (v:4.3.4.24657) [extras]
cacert (v:2020-01-01) [main]
calibre (v:4.12.0) [extras]
cmder (v:1.3.14) [main]
dark (v:3.11.2) [main]
diskgenius (v:5.2.0.884) [extras]
...
```

以上内容只是说明通过`scoop`安装了哪些软件，无法执行批处理安装。可以在`Cmder`中通过以下命令直接生成安装脚本：

```ps
scoop list | grep -o -E "^\w+" | sed 's/^\(\w*\).*/scoop install \1/' > scoop-install-apps.ps1
```

以上命令的过程是先使用`scoop list`列出已装软件信息；然后传递给`grep`，只选第一个单词，即软件名称；再传给`sed`在软件名称前插入`scoop install`，组成安装命令；最后保存为文件。上述命令可简化为：

```ps
scoop list | sed 's/^\(\w*\).*/scoop install \1/' > scoop-install-apps.ps1
```

得到的文件内容是：

```text
scoop install 7zip
scoop install aria2
scoop install besttrace
scoop install beyondcompare
scoop install cacert
scoop install calibre
scoop install cmder
scoop install dark
scoop install diskgenius
scoop install dismplusplus
...
```

在安装好`scoop`后可以使用该脚本直接安装所有应用。

## 九、 共享安装总结

### 9.1 设置权限

```ps
# 官方建议只设置remotesigned，但由于要执行批量脚本，所以设置为unrestrict。
# set-executionpolicy remotesigned -scope currentuser
set-executionpolicy unrestrict -scope currentuser
```

### 9.2 准备共享

将已安装`scoop`的主机作为程序源进行安装是最方便的。假设已有主机`ssd-win10`在其共享目录`vm_share`下准备了`scoop`共享。该共享是刚刚安装完`scoop`，未安装任何应用时的状态，目录结构如下：

```text
\\ssd-win101\vm_share\scoop
+---apps
|   \---scoop
|       \---current
+---buckets
+---cache
+---persist
\---shims
```

在需要安装`scoop`的主机上准备共享数据的环境，以共享路径名为参数执行以下脚本，设脚本名为`scoop1-setup-dir.bat`，内容为：

```bat
c:
cd \
md Scoop
cd Scoop
xcopy %1\scoop\apps apps /E
xcopy %1\scoop\shims shims /E
mklink /d cache %1\scoop\cache
mklink /d buckets %1%\scoop\buckets
dir
```

在上例中，执行的命令是`scoop1-setup-dir.bat \\ssd-win10\vm_share`。命令成功后应验证软连接目录的有效性。

### 9.3 设置环境

执行名为`scoop2-setup-env.ps1`的脚本，内容为：

```ps
set-executionpolicy remotesigned -scope currentuser
$env:SCOOP='C:\Scoop'
[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')
$env:SCOOP_GLOBAL='C:\ScoopApps'
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')
[environment]::SetEnvironmentvariable("Path", $env:Path + ";C:\Scoop\shims", "User")
```

### 9.4 安装基础应用及软件源

安装前最好设置好科学上网。先在关闭科学上网时执行以下脚本，若有错误发生，打开网络，再次执行一般均能通过。

打开新的`PowerShell`，使刚刚设置的环境变量生效。执行名为`scoop3-basic-apps.ps1`的脚本安装最基础的应用程序，内容为：

```ps
scoop install git
scoop install aria2
scoop install cmder
scoop install notepadplusplus
scoop install peazip
scoop install shadowsocks
scoop install shadowsocksr-csharp

scoop bucket add extras
scoop bucket add nonportable
scoop bucket add jetbrains
scoop bucket add ash258 https://github.com/Ash258/scoop-Ash258
scoop bucket add dorado https://github.com/h404bi/dorado
scoop bucket add bear https://github.com/AStupidBear/scoop-bear

scoop update
```

安装`git`和`cmder`可以在`Windows`环境下执行`linux`中的命令，可用于以后软件列表的备份及恢复，是必须的。

应查看哪些程序需运行额外的`.reg`文件，例如`notepadplusplus`和`vscode`都需导入注册表信息以添加右键菜单。

## 十、 参考资料

《[Windows包管理工具：Scoop 介绍](https://blog.csdn.net/Edisonleeee/article/details/94748703)》有对于自建`bucket`的简单说明。
