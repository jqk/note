# scoop使用说明

## 一、位置

* [scoop官网](https://scoop.sh/)
* [scoop github](https://github.com/lukesampson/scoop)

## 二、安装scoop

官方要求在`PowerShell`中运行以下各类命令，无需管理员权限。

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

    $env:SCOOP='C:\Scoop'
    [Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')

将需要通过`scoop`安装的应用程序安装到指定目录，例如`C:\ScoopApps`：

    $env:SCOOP_GLOBAL='C:\ScoopApps'
    [Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')

### 2.3安装scoop

运行：

    set-executionpolicy remotesigned -scope currentuser
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')

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

    scoop install aria2

另外应加入bucket:

    scoop bucket add extras
    scoop bucket add nonportable
    scoop bucket add jetbrains
    scoop bucket add ash258 https://github.com/Ash258/scoop-Ash258
    scoop bucket add dorado https://github.com/h404bi/dorado
    scoop bucket add bear https://github.com/AStupidBear/scoop-bear

然后安装`git`，接着再安装其它程序。

## 四、安装应用程序

### 4.1正常安装

执行`scoop install <app>`命令即可安装软件，其中`<app>`是待安装软件的名称。如果不确定软件名称，可以使用`scoop search <app>`命令进行查找。

如果同一个应用程序有多个对应名称，尽量安装名为`<app>-portable`的程序，否则安装`<app>`，最后选择`<app>-np`。

实验证明，以下应用下载成功，文件可打开，但安装不成功：

    eagleget-portable
    IntelliJ-IDEA-Ultimate-portable
    foxit-reader

有一些程序必需换网络或VPN才能下载：

    manictime
    potplayer
    proxifier-portable

有一些程序下载速度很慢：

    vscode
    filezilla
    listary
    foobar2000-portable

`dark`是安装某个程序所需要，虽然安装时一并安装，但最好提前执行。`vcredist2015`是某个程序建议的，但不安装貌似也可以正常运行。`Cmder`需使用`git`，所以`git`应在安装完`aria2`后立即安装。

应用程序安装过后，都是默认语言，也没有任何插件。这些需要启动后设置，并手动安装。

### 4.2安装失败及重试

安装失败原因可能很多，但最见的是下载失败，或下载未完整。此时，应先执行`scoop uninstall <app>`命令，然后删除`cache`目录下刚刚下载的文件，最后再次运行`scoop install <app>`执行安装。

下载在文件名与`<app>`指定的待安装程序的名字有比较直观的逻辑联系。

### 4.3下载缓存cache的处理

安装过程中下载的文件被放置在`cache`目录中，安装之后删除这些文件不会对系统产生任何影响。但如果不删除这些文件，在执行`scoop uninstall <app>`卸载应用后再执行`scoop install <app>`将省略下载文件的过程。

因此，可以备份这些文件，在需要使用`scoop`在其它机器上安装软件时，将这些文件复制到`cache`目录下，即可避免下载安装文件。唯一可虑的是，所需安装的软件版本有更新。

## 五、升级应用程序

通过`scoop status`可以查看所有程序的版本状态。通过`scoop update *`升级所有程序至最新版本，或`scoop update <app>`升级指定的程序。

程序默认安装于`Users\<user>\scoop\apps\<app>`中，其中`user`是用户名，`<app>`是安装时指定的应用程序名称。在该目录下，初始安装时会有一个版本号目录和一个目录链接。

以应用软件`peazip`为例，在用户名为jason的系统中，该程序被安装在`C:\Users\Jason\scoop\apps\peazip`中。在`2020-02-01`时，该目录中有子目录`7.0.1`和软链接`current`。双击`current`会直接进入目录`7.0.1`。

`2020-02-03`该程序有版本更新至`7.1.0`。通过命令升级后，在安装目录中建立了新的目录`7.1.0`，`current`也指向该目录。上一版本的`7.0.1`仍被保留，但手动删除不会对系统产生影响。由于配置信息在`persist\peazip`中，所以升级未影响程序行为。

因此，升级后，旧版程序可以删除。相应的，在`cache`中的旧版安装包也可删除。执行删除的前提是保证新版运行无异常。
