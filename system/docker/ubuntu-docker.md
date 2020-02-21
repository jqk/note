# 在 Ubuntu 下运行 docker

[TOC]

## 一、安装

### 1.1 执行安装

操作系统均为`Ubuntu桌面版`。

在`18.04`上执行：

```bash
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
```

安装成功。此时源为阿里云。

在`19.10`上执行：

```bash
sudo apt install docker.io
```

也成功安装。没有做交叉尝试。以后所有说明，均在`19.10`下执行。

通过以下第一条命令可检查`docker`是否作为服务自启动，若非自启动，可通过第二条命令设置：

```base
systemctl is-enabled docker
systemctl enable docker
```

**注**，选择`Ubuntu`是因为其界面在`linux`中比较友善，如果命令不熟，可使用图形界面工具。选择`19.10`版是因为在以前的版本中，字体调整大小很困难，在高分屏下，字调到最大也很小，眼睛都要看瞎了；而`19.10`可直接设置`200%`的显示，在高分屏下很正常。

### 1.2 赋予当前用户权限

**此步可省略**！若省略，则每次执行`docker`命令，均需明确管理员权限，即在命令前加`sudo`。

#### 1.2.1 确认 docker 组已建立

若要设置权限，以简便`docker`相关操作，首先需执行以下命令确认`docker`组已建立：

```bash
sudo groupadd docker
```

将返回：

```text
groupadd：“docker”组已存在
```

如果不返回类似以上的结果，则`docker`可能需要重新安装。

#### 1.2.2 向 docker 组添加当前用户

执行：

```bash
$ sudo usermod -aG docker $USER
# 或者使用下面命令，此命令的返回信息明确，而前一命令没任何返回。
# 两个命令都试了，但不知道哪个生效了。
$ sudo gpasswd -a ${USER} docker
```

#### 1.2.3 重启 docker 服务

```bash
$ sudo service docker restart
# 或者使用下面命令。
$ sudo /etc/init.d/docker restart
```

#### 1.2.4 确保权限生效

切换当前会话到新`group`或者重启`X`会话。这一步是必须的，否则因为`groups`命令获取到的是缓存的组信息，刚添加的组信息未能生效，所以`docker images`等命令执行时同样有错。执行：

```bash
# 切换组。
$ newgrp - docker
```

在当前终端窗口，`docker images`等命令无需再加前缀`sudo`。但切换到新终端窗口，会报如下错误，只有重启操作系统才会生效，即使重新登录都不行：

```text
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.39/info: dial unix /var/run/docker.sock: connect: permission denied
```

此时执行：

```bash
# 赋予权限。
$ sudo chmod a+rw /var/run/docker.sock
```

至此，不再需要前缀`sudo`。

### 1.3 更改镜像源

docker 的镜像仓库在国外，下载会很慢，所以启用阿里云加速。在`/etc/docker`目录下创建`daemon.json`文件，添加如下内容：

```json
{
  "registry-mirrors": ["https://almtd3fa.mirror.aliyuncs.com"]
}
```

备用的镜像源还有`https://registry.docker-cn.com`和`http://hub-mirror.c.163.com`等。

修改后，重启 docker：

```bash
systemctl daemon-reload
service docker restart
```

## 二、下载镜像

需要下载`centos`及`java8`镜像。通过下列命令查询相关镜像：

```bash
docker search centos
docker search java:8
```

从结果发现，`centos`镜像是`Offical`的，而`java8`不是。执行：

```bash
docker pull centos
docker pull java:8
```

`centos`默认下载`lastest`。执行：

```bash
docker images
# 或
docker image list
```

得到相同结果：

```text
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              latest              470671670cac        3 weeks ago         237MB
hello-world         latest              fce289e99eb9        13 months ago       1.84kB
java                8                   d23bdf5b1b1b        3 years ago         643MB
java                latest              d23bdf5b1b1b        3 years ago         643MB
learn/tutorial      latest              a7876479f1aa        6 years ago         128MB
```

其中，`centos`和`java`都是刚刚下载的。两个`java`实际上是同一个镜像。执行命令：

```bash
sudo docker run centos cat /etc/centos-release
```

可以得到下载镜像的版本信息：

```text
CentOS Linux release 8.1.1911 (Core)
```

执行命令：

```bash
sudo docker run java java -version
```

得到如下结果：

```text
openjdk version "1.8.0_111"
OpenJDK Runtime Environment (build 1.8.0_111-8u111-b14-2~bpo8+1-b14)
OpenJDK 64-Bit Server VM (build 25.111-b14, mixed mode)
```

该镜像中的`JDK`与实际生产环境中不同。实际生产环境是`oracle jdk 8`，截止`2020-02-14`的最新版是`241`。所以，应使用`centos`建立新的镜像。现在下载的`java8`仍可用于实验。

通过`docker inspect`命令可以查看镜像的详细信息，会以`json`格式显示。

## 三、备份及恢复镜像

### 3.1 备份

当前目录为`/home/jason/桌面/docker`。执行命令：

```bash
sudo docker save -o centos-8.1.1911.tar centos
sudo docker save -o java-8.111.tar d23bdf
```

对`centos`使用了镜像名称；对`java`使用镜像 ID 的一部分。保存镜像后执行`ll`命令得到如下返回：

```text
drwxr-xr-x 2 jason jason      4096 2月  13 23:31 ./
drwxr-xr-x 3 jason jason      4096 2月  13 21:08 ../
-rw------- 1 root  root  244953088 2月  13 23:30 centos-8.1.1911.tar
-rw------- 1 root  root  659248640 2月  13 23:31 java-8.111.tar
```

使用`sudo tar -xf <filename>`命令可以解压这些包。

### 3.2 恢复

备份后的镜像`tar`包可以通过如下命令恢复，以`java8`镜像为例：

```bash
sudo docker load -i java-8.111.tar
```

备注：删除镜像的命令是`sudo docker rmi -f <镜像名称或ID>`。

## 四、制作 JDK 镜像

### 4.1 下载 JDK 并解压

以`centos`镜像为基础，制作`oracle jdk 8u241`的镜像。

从[Oralce](https://www.java.com/en/download/manual.jsp)下载`JDK`到当前目录并解压：

```bash
tar -zxvf jdk-8u241-linux-x64.tar.gzip
```

解压后，在当前目录会建立目录`jdk1.8.0_241`。

### 4.2Dockerfile

在当前目录编写`Dockerfile`，使用默认名称`Dockerfile`即可：

```dockerfile
# 指定基础镜像
FROM centos

MAINTAINER FuHongJie jasson.freeemail@126.com

# 复制jdk8
COPY jdk1.8.0_241 /usr/java/jdk1.8.0_241

# 设置镜像中的jdk环境变量
ENV JAVA_HOME=/usr/java/jdk1.8.0_241
ENV JRE_HOME=/usr/java/jdk1.8.0_241/jre

ENV PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
ENV CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib

# 设置字符集，防止乱码，但LC_ALL设置总是不成功
# en_US.utf8无法正常显示中文
# ENV LANG en_US.utf8

# 使用C.UTF-8运行java程序可以正确输出中、英文
ENV LANG C.UTF-8

# 以下设置LC_ALL总是不成功，返回的错误信息是：
# /bin/sh: warning: setlocale: LC_ALL: cannot change locale (en_US.utf8): No such file or directory
# ENV LC_ALL en_US.utf8

# 设置时区
RUN rm -rf /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 安装telnet/ifconfig（用于调测网络使用，不是必须的）
RUN yum install telnet net-tools -y

# 这个指令表示，我们运行容器时，容器默认的工作目录
# 也就是以docker run -it <镜像名>运行时，自动进入的目录
WORKDIR /opt
```

**注意**编码类型设置为`C.UTF-8`，否则不支持中文。是否设置`LC_ALL`对输出中文无影响。

### 4.3 构建及检查

运行：

```bash
# 使用默认文件名`Dockerfile`
docker build -t yxy/centos/jdk8 .
# 通过`-f`指定`Dockerfile`文件名
docker build -f <Dockerfile文件名> -t yxy/centos/jdk8 .
```

将建立名为`yxy/centos/jdk8:latest`的镜像。

完成后执行：

```bash
docker images
docker run yxy/centos/jdk8 java -version
# 或以下命令进入镜像命令行后执行`java -version`，再执行`exit`退出
docker run -it yxy/centos/jdk8
```

第一个命令返回以下内容，说明镜像建立成功：

```shell
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
yxy/centos/jdk8     latest              c62c38c2d26b        3 minutes ago       641MB
centos              latest              470671670cac        3 weeks ago         237MB
hello-world         latest              fce289e99eb9        13 months ago       1.84kB
java                8                   d23bdf5b1b1b        3 years ago         643MB
java                latest              d23bdf5b1b1b        3 years ago         643MB
learn/tutorial      latest              a7876479f1aa        6 years ago         128MB
```

镜像仍有些大，应进行优化，例如删除不必要的包，以及只安装`jre`等。

第二个命令返回，说明所建镜像中`java`安装有效：

```text
java version "1.8.0_241"
Java(TM) SE Runtime Environment (build 1.8.0_241-b07)
Java HotSpot(TM) 64-Bit Server VM (build 25.241-b07, mixed mode)
```

### 4.4 网络信息

以上所有操作在`VMware`中执行。以下为产生的 IP 地址：

| 地址所属                          | IPv4            |
| --------------------------------- | --------------- |
| 物理机在`VMware`中的地址          | 192.168.163.1   |
| `Ubuntu 19.10`虚拟机地址          | 192.168.163.138 |
| 虚拟机上`docker0`地址             | 172.17.0.1      |
| 容器`yxy/centos/jdk8`运行时的地址 | 172.17.0.2      |

## 五、制作应用程序镜像

### 5.1 最简单的程序 simple

#### 5.1.1 功能及组成

该程序只有一个`jar`包，没有任何依赖，即不需要配置文件，也无文件输出。程序接收最多两个参数，第一个参数是循环次数，第二个参数是需要输出的信息字符串。如果不提供参数，则打印一条信息后直接返回。

#### 5.1.2 源代码

```java
public class Simple {
    public static void main(String[] args) throws InterruptedException {
        final int maxArgs = 2;
        final int argsCount = args.length;

        if (argsCount == 0 || argsCount > maxArgs) {
            System.out.println("Usage: java -jar simple-1.0.jar loopCount [, message]");
            return;
        }

        final String message = argsCount > 1 ? args[1] : "";
        // 可能抛出异常，从而可以测试显示异常信息。
        int loopCount = Integer.parseInt(args[0]);

        if (loopCount < 0) {
            loopCount = 1;
        } else if (loopCount == 0) {
            loopCount = Integer.MAX_VALUE;
        }

        int count = 0;
        do {
            System.out.println("Loop[" + count + "]: " + message);
            Thread.sleep(1000);
        } while (++count < loopCount);

        System.out.println("SIMPLE is finished.");
    }
}
```

#### 5.1.3Dockerfile 及构建

`Dockerfile`命名为`yxy-simple.dockerfile`：

```docker
# 指定基础镜像。
FROM yxy/centos/jdk8

MAINTAINER FuHongJie jasson.freeemail@126.com

# 复制应用文件。现在复制的只是一个文件。可以在复制过程中改名。用COPY亦可。
ADD simple-1.0.jar /opt/app.jar

# 设置镜像入口。一旦设置，使用docker run -it将不会进入container
ENTRYPOINT  ["java","-jar","app.jar"]
```

执行命令构建镜像：

```bash
docker build -f yxy-simple.dockerfile -t yxy/simple .
docker images
```

构建成功并检查后得到如下结果：

```text
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
yxy/simple          latest              9d2814869cec        6 seconds ago       678MB
yxy/centos/java8    latest              ac1c31bde659        47 hours ago        678MB
centos              latest              470671670cac        4 weeks ago         237MB
......
```

#### 5.1.4 运行镜像

执行：

```bash
docker run yxy/simple
```

得到默认返回：

```text
Usage: java -jar simple-1.0.jar loopCount [, message]
```

执行：

```bash
docker run yxy/simple 2 abc
```

得到结果：

```text
Loop[0]: abc
Loop[1]: abc
SIMPLE is finished.
```

以上结果均符合预期。将`abc`替换为中文`为什么`再次运行，得到：

```text
Loop[0]: 为什么
Loop[1]: 为什么
SIMPLE is finished.
```

中文输出正确。如果在建立`yxy/centos/jdk8`镜像时指定了`en_US.utf8`而不是`C.UTF-8`，则返回如下信息：

```text
Loop[0]: ?????????
Loop[1]: ?????????
SIMPLE is finished.
```

无法显示中文。是否设置`LC_ALL`对输出中文无影响。

### 5.2 带依赖及文件操作的程序 simpleLog

#### 5.2.1 功能及组成

增加了对`log4j2`的依赖，将直接打印到控制台的输出转为日志输出，增加了列出指定目录下的文件名的功能，其它与上一节中的`simple-1.0.jar`没有区别。

`simpleLog`目录中包含 4 个文件，即`simpleLog-1.0.jar`，两个`log4j2`的`jar`包，以及`log4j2`的配置文件`log4j2.xml`。

#### 5.2.2 源码

仅将`System.out.println()`替换为`logger.info()`，增加列出指定目录下文件的功能，没有其它改动。

#### 5.2.3Dockerfile 及构建

将`simpleLog`目录复制到当前目录。

`Dockerfile`命名为`yxy-simple-log.dockerfile`：

```docker
# 指定基础镜像。
FROM yxy/centos/jdk8:latest

MAINTAINER FuHongJie jasson.freeemail@126.com

# 复制应用文件。现在复制的是一个目录。
ADD simpleLog /opt/simpleLog

# 如果不设置默认工作目录，将会从基础镜像继承，即/opt。
# 设置工作目录的作用是，外部检查当前目录（.或./），得到的就是工作目录。
# 另外，log4j2配置文件如果使用相对路径，例如logs存储日志文件，则logs目录将在工作目录下建立。
# 如本例，若不设置工作目录，则日志保存于/opt/logs；
# 而进行以下设置后，日志保存于/opt/simpeLog/logs。
# 弄清容器内目录的位置，对于与宿主机目录挂载是非常关键的。
WORKDIR /opt/simpleLog

# 设置镜像入口。一旦设置，使用docker run -it将不会进入container。
ENTRYPOINT  ["java","-jar","/opt/simpleLog/simpleLog-1.0.jar"]
```

执行命令构建镜像：

```bash
docker build -f yxy-simple-log.dockerfile -t yxy/simple-log .
```

在构造文件中，指明的是复制目录到容器。目录中包含 4 个文件，即`simpleLog-1.0.jar`，两个`log4j2`的`jar`包，以及`log4j2`的配置文件。

#### 5.2.4 运行镜像及目录挂载

##### 5.2.4.1 简单运行镜像

执行：

```bash
docker run yxy/simple-log 2 abc一二三def
```

得到返回：

```text
10:04:11.608 I com.yxy.docker.SimpleLog [main] - Loop[0]: abc一二三def
10:04:12.611 I com.yxy.docker.SimpleLog [main] - Loop[1]: abc一二三def
10:04:13.614 I com.yxy.docker.SimpleLog [main] - SIMPLE_LOG is finished.
```

一切正常，返回信息格式是日志配置文件所定义的。

##### 5.2.4.2 挂载目录运行

执行命令，显示容器中的当前目录，同时将日志输出目录指向宿主机的`/home/jason/docker/logs`：

```bash
# 进入宿主机为容器运行日志准备的输出目录。
cd /home/jason/docker/logs

# 清除该目录。
rm -f *.*

# 指定日志输出目录并运行程序。希望日志被记录到当前目录，而非容器内的目录中。
docker run -v /home/jason/docker/logs:/opt/simpleLog/logs yxy/simple-log 2 abc .
```

得到返回：

```text
14:29:15.453 I com.yxy.docker.SimpleLog [main] - Absolute path of [.] is [/opt/simpleLog/.].
14:29:15.457 I com.yxy.docker.SimpleLog [main] - Path [.] contains [5] files.
14:29:15.458 I com.yxy.docker.SimpleLog [main] - ---- [0]: log4j2.xml
14:29:15.458 I com.yxy.docker.SimpleLog [main] - ---- [1]: simpleLog-1.0.jar
14:29:15.458 I com.yxy.docker.SimpleLog [main] - ---- [2]: log4j-api-2.13.0.jar
14:29:15.458 I com.yxy.docker.SimpleLog [main] - ---- [3]: log4j-core-2.13.0.jar
14:29:15.458 I com.yxy.docker.SimpleLog [main] - ---- [4]: logs
14:29:15.459 I com.yxy.docker.SimpleLog [main] - ====================
14:29:15.460 I com.yxy.docker.SimpleLog [main] - Loop[0]: abc
14:29:16.460 I com.yxy.docker.SimpleLog [main] - Loop[1]: abc
14:29:17.461 I com.yxy.docker.SimpleLog [main] - ====================
14:29:17.462 I com.yxy.docker.SimpleLog [main] - Absolute path of [.] is [/opt/simpleLog/.].
14:29:17.463 I com.yxy.docker.SimpleLog [main] - Path [.] contains [5] files.
14:29:17.464 I com.yxy.docker.SimpleLog [main] - ---- [0]: log4j2.xml
14:29:17.465 I com.yxy.docker.SimpleLog [main] - ---- [1]: simpleLog-1.0.jar
14:29:17.466 I com.yxy.docker.SimpleLog [main] - ---- [2]: log4j-api-2.13.0.jar
14:29:17.466 I com.yxy.docker.SimpleLog [main] - ---- [3]: log4j-core-2.13.0.jar
14:29:17.467 I com.yxy.docker.SimpleLog [main] - ---- [4]: logs
```

容器上当前目录是`/opt/simpleLog`。运行程序时在其下会建立日志目录`logs`。如果构建镜像时，未明确指定工作目录，则以上返回中，当前目录将是从基础镜像继承而业的`/opt`，而其下将有`/opt/logs`和`/opt/simpleLog`两个目录。此时，由于命令指定的容器目录`/opt/simpleLog/logs`不存在，目录挂载将失败，但**不会报错！**

在宿主机目录与容器目录均正确时，挂载生效。宿主机`/home/jason/docker/logs`下将产生文件`app.log`和`error.log`，与日志配置相符。`app.log`内容也正确，此处忽略。

##### 5.2.4.3 挂载目录指向程序目录

当挂载目录指向的是容器中程序所在目录时，有两种情况会发生。**第一种**，宿主机挂载目录中没有容器所需的程序，例如挂载目录`/home/jason/桌面/docker/simpleLog`中没有`simpleLog-1.0.jar`及其依赖的所有包，运行：

```bash
docker run -v /home/jason/桌面/docker/simpleLog:/opt/simpleLog yxy/simple-log 2 msg .
```

会返回错误信息：

```text
Error: Unable to access jarfile /opt/simpleLog/simpleLog-1.0.jar
```

因为容器中的`/opt/simpleLog`映射到了宿主机的`/home/jason/桌面/docker/simpleLog`，而宿主机的目录中没有 jar 包，相当于在没有相应 jar 包时执行了`java -jar simpleLog-1.0.jar`，所以报上述错误。

**第二种**，如果在挂载目录中有全套的应用程序，执行前述命令相当于用容器内的`jdk`运行了宿主机上的应用程序，在挂载目录中会按日志配置建立`logs`目录及相应的日志文件。

**注**，此处示例中，挂载目录包含了中文路径名，系统运行正常。

##### 5.2.4.4 挂载配置文件

挂载操作不仅可以挂载目录，还可以直接挂载文件，从而解决配置文件的问题。

仍以`simpleLog`为例，其目录中包含 4 个文件，即`simpleLog-1.0.jar`，两个`log4j2`的`jar`包，以及`log4j2.xml`。如果在构建镜像前将`log4j2.xml`删除，则不包含日志配置文件的镜像仍能正常运行，但不会有任何输出，因为默认输出是容器内的控制台。

此时，保证`home/jason/docker`目录为空，然后复制`log4j2.xml`到该目录，最后执行：

```bash
docker run -v /home/jason/docker/log4j2.xml:/opt/simpleLog/log4j2.xml yxy/simple-log2 2 abc .
```

结果与日志配置文件在容器中时完全一样。

如果应用程序在其当前路径下有多个配置文件，目前只有两种方法：

1. 在`docker run`命令中使用`-v`参数逐一挂载配置文件。此方法比较麻烦。
2. 修改程序，将所有配置文件移至单独的目录，然后挂载该配置文件目录。此方法配置`docker`命令简单，但需对程序做调整。

### 5.3 指定网络服务端口的程序 simpleNet

#### 5.3.1 功能及构成

## 六、docker 设置

## 附件：参考资料

### 参考文章

1. [Ubuntu18.04 安装 Docker](https://blog.csdn.net/u010889616/article/details/80170767)
1. [Ubuntu18.04 下 Docker CE 安装](https://www.jianshu.com/p/07e405c01880)
1. [Docker 镜像的备份和恢复](https://blog.csdn.net/k21325/article/details/70184253)
1. [备份 Docker 镜像容器和数据](http://einverne.github.io/post/2018/03/docker-related-backup.html)
1. [Docker 容器之最小 JDK 基础镜像](https://cloud.tencent.com/developer/article/1188404)：`Dockerfile`中设置了工作目录，使用`alpine-glibc`镜像为基础，最终生成的镜像大小仅`122M`。包含去除无用的 jar 包。
1. [docker java8 image](https://www.jianshu.com/p/d4e93bc86455)：以`centos`镜像为基础构建，其`Dockerfile`还包含时区设置和网络工具安装，以及向私服推送镜像。
1. [基于 centos 构建 java8 docker 镜像](https://github.com/xfdocker/java8)：`github`上有`Dockerfile`源码。所有东西都在构建时从网上下载。中文说明，但不细。其中，关于在镜像中设置中文的操作尝试未成功。
1. [Docker run 命令参数及使用](https://www.jianshu.com/p/ea4a00c6c21c)：整理了中英文翻译，相对清楚。
1. [docker 学习笔记-启动镜像输入参数](https://juejin.im/post/5b405c96e51d45194a51f842)：重点讨论了`docker run`命令的`ENTRYPOINT`、`--env-file`、`-e`等参数。
1. [关于 Docker 目录挂载的总结](https://www.cnblogs.com/ivictor/p/4834864.html)：对目录挂载比较细致的总结。
1. [IntelliJ IDEA快速实现Docker镜像部署](https://my.oschina.net/wuweixiang/blog/2874064)：图文并茂，很详细，尚未实验。

### 教程

1. [RIP Tutorial](https://riptutorial.com/zh-CN/docker/)：稍显老旧的教程，机器翻译得不太好，内容尚可。
2. [Docker 入门教程](http://www.docker.org.cn/book/docker)：极为精简的教程，可在 15 分钟内看完、练完，初步感觉`docker`是咋回事。
