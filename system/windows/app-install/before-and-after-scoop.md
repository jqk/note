# Windows系统及scoop安装前后的软件设置

## 一、 备份

### 1.1 ShadowSocksR配置

备份`C:\Scoop\apps\shadowsocksr-csharp\current\gui-config.json`。

该文件是程序使用的服务器列表。

### 1.2 浏览器书签

包含已保存的书签及打开未关闭的，需要保留的网址。

## 二、 安装scoop中没有的软件

1. TIM
1. 小鱼易连
1. welink
1. ea
1. 知之阅读
1. Visual Studio Team Explorer

## 三、 设置免费软件

### 3.1 eagleget

1. 关闭所有浏览器，运行一遍`eagleget`，以便其安装插件。
1. 设置默认下载目录。
1. 设置多线程下载。

### 3.2 浏览器插件安装

1. chrome
2. firefox
3. opera

### 3.3 为知笔记

通过以下命令修改数据存储路径：

```cmd
c:
cd \Scoop\apps\wiznote\current
rd "My Knowledge"
mklink /J "My Knowledge" E:\Data\Wiz
```

修改之后再运行`wizNote`设置登录信息。

### 3.4 keepass

运行`keepasss`打开数据文件`E:\Data\Keepass\JJ.kdbx`。

### 3.5 登录信息及启动

#### 3.5.1 teamviewer

设置登录信息。

#### 3.5.2 foxmail

设置自启动。

#### 3.5.3 即时通讯

登录`微信`，然后登录`企业微信`，设置为自启动。
登录`TIM`及`钉钉`，设置为自启动。

### 3.6 vscode

#### 3.6.1 使用已安装的扩展

在`C:\Users\Jason`下建立链接.vscode，指向实际路径：

```dos
mklink /J .vscode E:\Data\Jason\.vscode
```

#### 3.6.2 设置python环境

确保以下两件事：

1. `Python`语言环境已通过`Scoop`安装。
2. `vscode`已通过`Scoop`安装。

执行以下脚本，可能需要科学上网：

```dos
pip install flake8
pip install yapf
```

运行`vscode`并安装微软官方`python`插件。

最后建立`lauch.json`，内容如下，可运行，但尚未探索：

```json
    "python.linting.flake8Enabled": true,
    "python.formatting.provider": "yapf",
    "python.linting.flake8Args": ["--max-line-length=248"],
    "python.linting.pylintEnabled": false
```

#### 3.6.3 设置golang环境

确保以下两件事：

1. `Go`语言环境已通过`Scoop`安装。
2. `vscode`已通过`Scoop`安装。

执行以下脚本：

```ps
$env:GOPATH='E:\vm_share\go'
[Environment]::SetEnvironmentVariable('GOPATH', $env:GOPATH, 'User')

go env -w GO111MODULE=on
go env -w GOPROXY=https://goproxy.cn,direct
```

**注**：设置`GOPROXY`为`https://goproxy.io,direct`亦可。

运行`vscode`，安装微软官方的`Go`插件。

建立一个`.go`文件。此时`vscode`会提示安装`Go`的依赖工具，选择`Install All`。等待其安装完毕。然后执行：

```ps
go env -w GO111MODULE=auto
```

目前看，设置其为`off`也可以，但使用`on`，总报找不到`module`错误。

最后建立`lauch.json`，使用默认值即可。其它开关尚未探索。

### 3.7 cmder

使用备份的`user-ConEmu.xml`、`user_aliases.cmd`和`user_profile.cmd`替换`C:\Scoop\apps\cmder\current\config`中的同名文件。

## 四、 注册软件

### 4.1 Listary

### 4.2 BeyondCompare

执行以下命令复位试用时间：

```dos
reg delete "HKEY_CURRENT_USER\Software\Scooter Software\Beyond Compare 4" /v CacheID /f
```

根据该原理，可建立以下内容的批处理文件并放入可执行路径中：

```dos
@echo off
bcomp
reg delete "HKEY_CURRENT_USER\Software\Scooter Software\Beyond Compare 4" /v CacheID /f
```

其中的`bcomp`是`scoop`安装后指定的启动命令。

### 4.3 VMware

注册并打开已建立的虚拟机。

```text
VZ182-0NDE6-0817Y-KMMZZ-YKAC4
ZC75R-0YW5P-H809Y-QYWQZ-NZ8G8
ZV7XK-02D56-480JZ-ENZEX-YF8XD
YC588-FTDDL-H852Y-UXYGE-YZKE2
```

### 4.4 IntelliJ Idea

首先注册，然后执行以下操作，使用已安装的插件：

```dos
C:
cd \Scoop\apps\intellij-idea-ultimate-portable\current\profile

rd config
mklink /J config E:\Data\idea_config
```

### 4.5 EA

注册EA。

## 五、 系统设置

### 5.1 打印机

Canon激光打印机`iR2202_2002`。

### 5.2 快捷面板

### 5.3 文件管理器

显示所有文件。

### 5.4 开始菜单

使用[Backup Start Menu Layout](https://www.sordum.org/10997/backup-start-menu-layout-v1-3/)对开始菜单的布局进行恢复。恢复所依赖的数据是使用该工具提前导出并备份的。

默认的导出目录为`C:\Scoop\apps\backupstartmenulayout\current\MenuLayouts\年月日_时分秒`。该目录中是导出的2个文件，分别是`DefaultAccount.reg`和`Info.ini`。

恢复前可以将备份的文件按以上规则放好，然后通过程序界面执行恢复。

该程序没有提供选择文件进行恢复的功能。但是有命令行，未尝试。

另外，也可以参考[2 Ways to Backup and Restore Start Menu Layout in Windows 10](https://www.top-password.com/blog/backup-and-restore-start-menu-layout-in-windows-10/)进行人工备份及恢复。

### 5.5 ShadowSocksR设置

使用备份的`gui-config.json`替换`C:\Scoop\apps\shadowsocksr-csharp\current\gui-config.json`。然后重新启动`ShadowSocksR`，设置其自启动，且进入后`系统代理模式`为`直接连接`。
