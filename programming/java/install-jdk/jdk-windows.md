# Windows 10下安装JDK

## OracleJDK

从[Oralce官网](http://www.oracle.com/technetwork/java/javase/downloads/index.html)可以下载OralceJDK。要正确选择是32位还是64位。因为Windows 10一般安装64位版，所以JDK也应该选择64位版本。

运行下载后的安装程序，2020年2月10日，最新64位版本名称为`jdk-8u241-windows-x64.exe`。一路选择`下一步`，直到结束。

以`管理员`身份打开`PowerShell`，执行以下命令：

```ps
get-executionpolicy
```

获得当前的权限设置，记录该值用于恢复设置。如果是默认值`Restricted`，就不能执行批量的脚本，此时执行：

```ps
set-executionpolicy Unrestricted
```

在提示是选择`A`，使设置生效。

将以下语句保存为脚本，例如`set-jdk.ps1`：

```ps
if ($args.Count -eq 0) {
    Write-Host "Please provide JDK home path!"
} else {
    Write-Host "args[0] = '$($args[0])'"

    $env:JAVA_HOME = $args[0]
    [Environment]::SetEnvironmentVariable('JAVA_HOME', $env:JAVA_HOME, 'Machine')
    Write-Host "set JAVA_HOME = '$env:JAVA_HOME'"

    $env:CLASSPATH = '.;' + $env:JAVA_HOME + '\lib\dt.jar;' + $env:JAVA_HOME + '\lib\tools.jar;'
    [Environment]::SetEnvironmentVariable('CLASSPATH', $env:CLASSPATH, 'Machine')
    Write-Host "set CLASSPATH = '$env:CLASSPATH'"

    $env:JAVA_PATH = ';' + $env:JAVA_HOME + '\bin;' + $env:JAVA_HOME + '\jre\bin'
    [Environment]::SetEnvironmentVariable('PATH', $env:PATH + $env:JAVA_PATH, 'Machine')
    Write-Host "add JAVA_PATH = '$env:JAVA_PATH'"
}
```

执行该脚本，注意提供已安装好的java路径，例如：

```ps
.\set-jdk "C:\Program Files\Java\jdk1.8.0_241"
```

**注意**，java路径必须使用双引号包围方能成功。

打开`命令行`，执行：

```ps
set
```

可以显示环境变量，注意`JAVA_HOME`、`CLASSPATH`及`PATH`的设置是否正确。

最后，通过`set-executionpolicy`命令将脚本运行权限恢复为本次操作之前的值。本步可省。

参考：

[window系统安装java](https://www.runoob.com/java/java-environment-setup.html)
