# Windows系统及scoop安装前后的软件设置

## 一、 备份

### 1.1 ShadowSocksR配置

备份`C:\Scoop\apps\shadowsocksr-csharp\current\gui-config.json`。

该文件是程序使用的服务器列表。

### 1.2 浏览器书签

包含已保存的书签及打开未关闭的，需要保留的网址。

### 1.3 备份Scoop安装列表

必须在`Cmder`下才能执行如下命令自动生成安装列表：

```ps
scoop list | grep -o -E "^[ ]+\w+(\-\w+)*" | sed 's/^\s*\(.*\)/scoop install \1/' > scoop-install-apps.ps1
```

可考虑加`-g`参数，以将程序安装到指定目录。

### 1.4 备份vscode

一是`Shift+Alt+U`上传到`Github Gist`，另一个是备份`C:\Users<你的用户名>\AppData\Roaming\Code\User\syncLocalSettings.json`，该文件中有`Gist`使用的`token`。

### 1.5 java依赖库

`C:\Users\Jason\.m2`和`C:\Users\Jason\.gradle`。貌似前者是`maven`库文件，后者只是`gradle`程序。

## 二、 安装scoop中没有的软件

1. TIM
2. 小鱼易连
3. welink
4. ea
5. 知之阅读
6. Visual Studio Team Explorer或Visual Studio
7. 腾讯会议
8. FxPro cTrader
9. BookXNote
10. EasyBCD

## 三、 设置免费软件

### 3.1 eagleget

1. 关闭所有浏览器，运行一遍`eagleget`，以便其安装插件。
1. 设置默认下载目录。
1. 设置多线程下载。

### 3.2 浏览器插件安装

1. chrome
2. firefox
3. opera

`Chrome`主要插件有：

`AdblokcPlus`、`WizClipper`、`Print friendly & PDF`、`IE Tab`、`sourcegraph`

### 3.3 为知笔记

通过以下命令修改数据存储路径：

```cmd
c:
cd \Scoop\persist\wiznote\current
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

VSCODE settings sync plugin: `sync.gist`: `9a4dff6cfe81c64a10f279dca62ce7ba0a567d`

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

最后建立`launch.json`，内容如下，可运行，但尚未探索：

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

### 3.8 Windows Terminal

```registry
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\Directory\Background\shell\WindowsTerminal]
@="Windows Terminal Here"
"Icon"="D:\\Program Files\\Scoop\\apps\\WindowsTerminal\\current\\Images\\Square44x44Logo.targetsize-32.png"

[HKEY_CLASSES_ROOT\Directory\Background\shell\WindowsTerminal\command]
@="D:\\Program Files\\Scoop\\apps\\WindowsTerminal\\current\\WindowsTerminal.exe"
```

当前目录打开时，Terminal 里的路径不是当前目录。检查一下配置文件，看下是否有以下内容，删除之后就可以了。

```json
{
    "profiles": [
        {
            "startingDirectory" : "%USERPROFILE%"
        }
    ]
}
```

需要修改为：

```json
{
    "profiles": [
        {
            "startingDirectory" : null,
            "backgroundImage":"E:\\Data\\Jason\\Pictures\\爱壁纸UWP\\风景\\风景 - 9.jpg",
            "backgroudImageOpacity":0.5
        }
    ]
}
```

配置文件路径：

`C:\Users\jason\AppData\Local\Microsoft\Windows Terminal\profiles.json`

## 四、 注册软件

### 4.1 Listary

姓    名（Name）：Vovan
邮    箱（Email）：vovan666@6n8d7oa
序 列 号（Code）：

```text
66666666666666666666666666666666
66666666666666666666666666666666
66666666666666666666666666666666
66666666666666666666666666666666
66666666666666666666666666666666
66666666666666666666666666666666
```

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

### 4.5 Visual Studio

* Visual Studio 2019 Enterprise（企业版） KEY：`BF8Y8-GN2QH-T84XB-QVY3B-RC4DF`
* Visual Studio 2019 Professional（专业版） KEY：`NYWVH-HT4XC-R2WYW-9Y3CM-X4V3Y`
* Visual Studio 2017 Enterprise（企业版） KEY：`NJVYC-BMHX2-G77MM-4XJMR-6Q8QF`
* Visual Studio 2017 Professional（专业版） KEY：`KBJFW-NXHK6-W4WJM-CRMQB-G3CDH`
* Visual Studio 2013 Ultimate（旗舰版） KEY：`BWG7X-J98B3-W34RT-33B3R-JVYW9`
* Visual Studio 2013 Premium（高级版） KEY：`FBJVC-3CMTX-D8DVP-RTQCT-92494`
* Visual Studio 2013 Professional （专业版） KEY： `XDM3T-W3T3V-MGJWK-8BFVD-GVPKY`

### 4.6 EA

注册EA。

## 五、 系统设置

### 5.1 打印机

Canon激光打印机`iR2202_2002`。地址是`172.35.4.202`。

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
