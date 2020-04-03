# Windows系统及scoop安装后的软件设置

## 一、 安装scoop中没有的软件

1. TIM
1. 小鱼易连
1. welink
1. ea

## 二、 设置免费软件

### 2.1 eagleget

1. 关闭所有浏览器，运行一遍`eagleget`，以便其安装插件。
1. 设置默认下载目录。
1. 设置多线程下载。

### 2.2 浏览器插件安装

1. chrome
2. firefox
3. opera

### 2.3 为知笔记

通过以下命令修改数据存储路径：

```cmd
c:
cd \Scoop\apps\wiznote\current
rd "My Knowledge"
mklink /J "My Knowledge" E:\Data\Wiz
```

修改之后再运行`wizNote`设置登录信息。

### 2.4 keepass

打开数据文件。

### 2.5 登录信息及启动

#### 2.5.1 teamviewer

设置登录信息。

#### 2.5.2 foxmail

设置自启动。

#### 2.5.3 即时通讯

登录`微信`，然后登录`企业微信`，设置为自启动。
登录`TIM`及`钉钉`，设置为自启动。

### 2.6 vscode

#### 2.6.1 使用已安装的扩展

在`C:\Users\Jason`下建立链接.vscode，指向实际路径：

```dos
mklink /J .vscode E:\Data\Jason\.vscode
```

#### 2.6.2 设置python环境

#### 2.6.3 设置golang环境

### 2.7 cmder

使用备份的`user-ConEmu.xml`、`user_aliases.cmd`和`user_profile.cmd`替换`C:\Scoop\apps\cmder\current\config`中的同名文件。

## 三、 注册软件

### 3.1 Listary

### 3.2 BeyondCompare

执行以下命令复位试用时间：

```dos
reg delete "HKEY_CURRENT_USER\Software\Scooter Software\Beyond Compare 4" /v CacheID /f
```

### 3.3 VMware

注册并打开已建立的虚拟机。

### 3.4 IntelliJ Idea

首先注册，然后执行以下操作，使用已安装的插件：

```dos
C:
cd \Scoop\apps\intellij-idea-ultimate-portable\current\profile

rd config
mklink /J config E:\Data\idea_config
```

### 3.5 EA

注册EA。

## 四、 系统设置

### 4.1 打印机

Canon激光打印机`iR2202_2002`。

### 4.2 快捷面板

### 4.3 文件管理器

显示所有文件。
