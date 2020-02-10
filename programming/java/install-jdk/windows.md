# Windows 10下安装JDK

## OracleJDK

从[Oralce官网](http://www.oracle.com/technetwork/java/javase/downloads/index.html)可以下载OralceJDK。要正确选择是32位还是64位。因为Windows 10一般安装64位版，所以JDK也应该选择64位版本。

运行下载后的安装程序，2020年2月10日，最新64位版本名称为`jdk-8u241-windows-x64.exe`。一路选择`下一步`，直到结束。

以`管理员`身份打开`PowerShell`，逐条执行以下命令：

```ps
$env:JAVA_HOME='C:\Program Files\Java\jdk1.8.0_241'
[Environment]::SetEnvironmentVariable('JAVA_HOME', $env:JAVA_HOME, 'Machine')
$env:CLASSPATH='.;' + $env:JAVA_HOME + '\lib\dt.jar;' + $env:JAVA_HOME + '\lib\tools.jar;'
[Environment]::SetEnvironmentVariable('CLASSPATH', $env:CLASSPATH, 'Machine')
$env:JAVA_PATH=';' + $env:JAVA_HOME + '\bin;' + $env:JAVA_HOME + '\jre\bin'
[Environment]::SetEnvironmentVariable('PATH', $env:PATH + $env:JAVA_PATH, 'Machine')
```

**注意**，`jdk1.8.0_241`中的`241`与安装的具体的小版本号相关，需根据实际情况修改。

参考：

[window系统安装java](https://www.runoob.com/java/java-environment-setup.html)
