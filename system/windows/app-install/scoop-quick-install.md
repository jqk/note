# Scoop快速安装

## 一、 设置运行权限

以管理员身份在`PowerShell`运行以下命令：

```ps
set-executionpolicy remotesigned -scope currentuser
```

得到提示，选择`A`即可。

## 二、 复制已安装的Scoop

建立`scoop1-setup-dir.bat`，内容如下：

```cmd
%2:
cd \
md Scoop
cd Scoop
xcopy %1\scoop\apps apps /E
xcopy %1\scoop\shims shims /E
mklink /d cache %1\scoop\cache
mklink /d buckets %1%\scoop\buckets
dir
```

必须以管理员身份在`Cmd`窗口，而不是`PowerShell`中执行，示例如下：

```cmd
scoop1-setup-dir E:\vm_share E
```

第一个参数是已安装好的`scoop`模板所在位置，第二个参数是将要安装`scoop`的目标盘符。

执行过程中会两次提问复制的是文件还是目录，选择`D`，即目录。最近的执行结果列表新建立的目录内容：

```cmd
2020/07/09  09:24    <DIR>          .
2020/07/09  09:24    <DIR>          ..
2020/07/09  09:24    <DIR>          apps
2020/07/09  09:24    <SYMLINKD>     buckets [e:\vm_share\scoop\buckets]
2020/07/09  09:24    <SYMLINKD>     cache [e:\vm_share\scoop\cache]
2020/07/09  09:24    <DIR>          shims
```

如果返回不是以上内容，说明执行出错。

## 三、 设置环境变量

建立`scoop2-setup-env.ps1`，内容如下：

```ps
$env:SCOOP='E:\Scoop'
[Environment]::SetEnvironmentVariable('SCOOP', $env:SCOOP, 'User')
$env:SCOOP_GLOBAL='E:\ScoopApps'
[Environment]::SetEnvironmentVariable('SCOOP_GLOBAL', $env:SCOOP_GLOBAL, 'Machine')
[environment]::SetEnvironmentvariable("Path", $env:Path + ";E:\Scoop\shims", "User")
```

虽然不打算用`SCOOP_GLOBAL`，但仍保留。

## 四、 添加bucket

添加`bucket`之前，要安装`git`。建立`scoop3-add-bucket.ps1`，内容如下：

```ps
scoop install git

scoop bucket add ash258 https://github.com/Ash258/scoop-Ash258
scoop bucket add bear https://github.com/AStupidBear/scoop-bear
scoop bucket add dorado https://github.com/h404bi/dorado
scoop bucket add dodorz https://github.com/dodorz/scoop-bucket
scoop bucket add extras
scoop bucket add Java
scoop bucket add jetbrains
scoop bucket add nonportable

scoop update
```

## 五、 4.1 安装应用程序

执行通过如下语句生成的文件`scoop4-install-apps.ps1`：

```ps
scoop list | grep -o -E "^[ ]+\w+(\-\w+)*" | sed 's/^\s*\(.*\)/scoop install \1/' > scoop4-install-apps.ps1
```

以上命令必须在`Cmder`中执行。生成的文件需在`PowerShell`中执行。

## 六、 4.2 配置应用程序

### 6.1 注册菜单

需要注册菜单的应用有`notepad++`、`vim`、`vscode`和`windows terminal`。在`cmd`窗口执行`scoop5-shortcut.reg`，内容如下：

```cmd
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\*\shell\Edit with Notepad++]
"Icon"="\"E:\\Scoop\\apps\\notepadplusplus\\current\\notepad++.exe\""
"MultiSelectMode"="Single"
[HKEY_CLASSES_ROOT\*\shell\Edit with Notepad++\Command]
@="\"E:\\Scoop\\apps\\notepadplusplus\\current\\notepad++.exe\" \"%1\""



[HKEY_CURRENT_USER\Software\Classes\*\shell\Edit with &Vim]
@="Edit with &Vim"
"Icon"="$vim"
[HKEY_CURRENT_USER\Software\Classes\*\shell\Edit with &Vim\command]
@="\"$vim\" \"%1\""



[HKEY_CURRENT_USER\Software\Classes\*\shell\Open with &Code]
@="Open with &Code"
"Icon"="$code"
[HKEY_CURRENT_USER\Software\Classes\*\shell\Open with &Code\command]
@="\"$code\" \"%1\""

[HKEY_CURRENT_USER\Software\Classes\Directory\shell\Open with &Code]
@="Open with &Code"
"Icon"="$code"
[HKEY_CURRENT_USER\Software\Classes\Directory\shell\Open with &Code\command]
@="\"$code\" \"%1\""

[HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\Open with &Code]
@="Open with &Code"
"Icon"="$code"
[HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\Open with &Code\command]
@="\"$code\" \"%V\""



[HKEY_CLASSES_ROOT\Directory\Background\shell\WindowsTerminal]
@="Windows Terminal Here"
"Icon"="E:\\Scoop\\apps\\WindowsTerminal\\current\\Images\\Square44x44Logo.targetsize-32.png"
[HKEY_CLASSES_ROOT\Directory\Background\shell\WindowsTerminal\command]
@="E:\\Scoop\\apps\\WindowsTerminal\\current\\WindowsTerminal.exe"
```

### 建立软件链接

使用管理员身份，在`cmd`窗口执行`scoop6-makelink.bat`，内容如下：

```cmd
c:
cd \Users\Jason

mklink /J .gradle E:\Data\Jason\.gradle
mklink /J .m2 E:\Data\Jason\.m2
mklink /J .nuget E:\Data\Jason\.nuget
mklink /J .SwitchHosts E:\Data\Jason\.SwitchHosts
mklink /J .vscode E:\Data\Jason\.vscode

e:
cd \Scoop\apps\wiznote\current
rd "My Knowledge"
mklink /J "My Knowledge" E:\Data\Wiz
```

### 6.2 应用注册

### 6.3 登录信息
