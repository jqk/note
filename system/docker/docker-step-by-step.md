# 1. 在 docker 中使用 jdk8 详细说明

## 1.1. 目标说明及环境准备

### 1.1.1. 目标说明

通过完成以下实验操作，对`docker`镜像构建、容器运行有相对深入的了解，能够初步地使用`docker`及`java`程序部署。

不包含`docker`安装后的配置及容器编排。

`docker`的基本概念，如`镜像`、`容器`、`仓库`以及各类命令具体参数的意义请自行百度。

### 1.1.2. 操作系统

操作系统选择`Ubuntu 19.10`。选择`Ubuntu`是因为其界面在`linux`中比较友善，如果命令不熟，可使用图形界面工具。选择`19.10`版是因为在以前的版本中，字体调整大小很困难，在高分屏下，字调到最大也很小，眼睛都要看瞎了；而`19.10`可直接设置`200%`的显示比例，在高分屏下很正常。

在安装`docker`后，大部分操作均为`docker`命令，与`linux`不同的发行版已经没有太多关系了。

操作系统安装在`VMware Workstation 15`中。

### 1.1.3. 工作用户及目录

本文均以用户`jason`执行实验，若实验时用户不同，请自行替换。

建立目录`/home/jason/docker-demo`，所有实验均在此目录下执行，在以后的说明中称为`实验目录`。

## 1.2. 安装 docker

### 1.2.1. 在线安装

执行：

```bash
# 以下两种方法均可。第一种方法曾在Ubuntu 18.04上执行成功，源为阿里云：
$ curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
# 或以下第二种方法，在19.10上成功：
$ sudo apt install docker.io
# 以上两条命令均可在线安装，并不是说在某个版本下只能使用某条命令安装。
```

执行：

```bash
$ docker --version
Docker version 18.09.7, build 2d0083d
```

通过以下第一条命令可检查`docker`是否作为服务自启动，若非自启动，可通过第二条命令设置：

```base
$ systemctl is-enabled docker
enabled

$ sudo systemctl enable docker
Synchronizing state of docker.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable docker
```

### 1.2.2. 更改镜像源

`docker`的镜像仓库在国外，下载会很慢，所以启用阿里云加速。在`/etc/docker`目录下创建`daemon.json`文件，添加如下内容：

```json
{
  "registry-mirrors": ["https://almtd3fa.mirror.aliyuncs.com"]
}
```

备用的镜像源还有`https://registry.docker-cn.com`和`http://hub-mirror.c.163.com`等。

修改后，重启`docker`：

```bash
# 必须使用管理员权限。
$ sudo systemctl daemon-reload
$ sudo service docker restart
```

### 1.2.3. 赋予当前用户权限

**此步可省略**！若省略，则每次执行`docker`命令，均需明确管理员权限，即在命令前加`sudo`。

#### 1.2.3.1. 确认 docker 组已建立

若要设置权限，以简便`docker`相关操作，首先需执行以下命令确认`docker`组已建立：

```bash
$ sudo groupadd docker
groupadd：“docker”组已存在
```

如果不返回类似以上的结果，则`docker`可能需要重新安装。

#### 1.2.3.2. 向 docker 组添加当前用户

以下两条命令均可向`docker`组添加用户：

```bash
$ sudo usermod -aG docker jason
# 或者使用下面命令，此命令的返回信息明确，而前一命令没任何返回。
$ sudo gpasswd -a jason docker
```

若用户名不同请自行替换。

#### 1.2.3.3. 重启 docker 服务

使用以下两条命令之一，可重启`docker`服务：

```bash
$ sudo service docker restart
# 或者使用下面命令。
$ sudo /etc/init.d/docker restart
```

#### 1.2.3.4. 确保权限生效

切换当前会话到新`group`或者重启`X`会话。这一步是必须的，否则因为`groups`命令获取到的是缓存的组信息，刚添加的组信息未能生效，所以`docker images`等命令执行时同样有错。执行：

```bash
# -与docker之间必须有空格。
$ newgrp - docker
```

此时，在当前终端窗口，`docker images`等命令无需再加前缀`sudo`。但切换到新终端窗口，会报如下错误，只有重启操作系统后才会生效，即使重新登录都不行：

```text
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.39/info: dial unix /var/run/docker.sock: connect: permission denied
```

此时执行：

```bash
# 赋予权限。
$ sudo chmod a+rw /var/run/docker.sock
```

至此，不再需要前缀`sudo`。以后所有实验均假设`docker`执行权限已正确设置，无需加前缀`sudo`。

## 1.3. 操作镜像

### 1.3.1. 下载镜像

**注意**，如果已有经过备份的镜像，可以直接恢复，而不用下载。

需要下载`centos`及`java8`镜像。通过下列命令查询相关镜像：

```bash
# 搜索镜像。
$ docker search centos
$ docker search java:8
```

从结果发现，`centos`镜像是`Offical`的，而`java8`不是。执行：

```bash
# 摘取镜像。
$ docker pull centos
$ docker pull java:8
```

`centos`默认下载`lastest`。执行：

```bash
$ docker images
# 或
$ docker image list
# 得到相同结果：
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              latest              470671670cac        3 weeks ago         237MB
java                8                   d23bdf5b1b1b        3 years ago         643MB
```

其中，`centos`和`java`都是刚刚下载的。执行命令得到所下载镜像的版本信息：

```bash
$ docker run centos cat /etc/centos-release
CentOS Linux release 8.1.1911 (Core)

$ docker run java java -version
openjdk version "1.8.0_111"
OpenJDK Runtime Environment (build 1.8.0_111-8u111-b14-2~bpo8+1-b14)
OpenJDK 64-Bit Server VM (build 25.111-b14, mixed mode)
```

`centos`是最新的镜像，而`jave:8`中的`JDK`与实际生产环境中不同。实际生产环境是`oracle jdk 8`，截止`2020-02-14`的最新版是`241`。所以，应使用`centos`建立新的镜像。镜像`java:8`仍可用于其它实验。以后的实验，均以`centos`为基础镜像。

通过`docker inspect`命令可以查看镜像的详细信息，会以`json`格式显示。

### 1.3.2. 备份镜像

在`实验目录`中建立目录`images`并进入，然后执行命令：

```bash
# 保存镜像到本地文件。对centos镜像的指定，使用的是镜像名称。
$ docker save -o centos-8.1.1911.tar centos
# 对java:8镜像的指定，使用的是镜像ID的一部分。
$ docker save -o open-java-8.111.tar d23bdf
$ ls -a
drwxr-xr-x 2 jason jason      4096 2月  13 23:31 ./
drwxr-xr-x 3 jason jason      4096 2月  13 21:08 ../
-rw------- 1 root  root  244953088 2月  13 23:30 centos-8.1.1911.tar
-rw------- 1 root  root  659248640 2月  13 23:31 open-java-8.111.tar
```

使用`sudo tar -xf <filename>`命令可以解压这些包。

### 1.3.3. 恢复镜像

备份后的镜像`tar`包可以通过如下命令恢复，以`java:8`镜像为例：

```bash
# 恢复镜像。
$ docker load -i open-java-8.111.tar
```

备注：删除镜像的命令是`sudo docker rmi -f <镜像名称或ID>`。加上`-f`表示连使用该镜像的容器一并删除。

## 1.4. 制作 JDK 镜像

### 1.4.1. 下载 JDK 并解压

以`centos`镜像为基础，制作`oracle jdk 8u241`的镜像。在`实验目录`中建立目录`build-jdk`并进入。

从[Oralce](https://www.java.com/en/download/manual.jsp)下载`JDK`到当前目录并解压：

```bash
# 解压JDK。
$ tar -zxvf jdk-8u241-linux-x64.tar.gzip
```

解压后，在当前目录会建立目录`jdk1.8.0_241`。构建镜像要求所需的所有文件都在当前目录下。

### 1.4.2. Dockerfile

在当前目录中编写`Dockerfile`，使用默认名称`Dockerfile`即可。如果使用默认文件名，则构建镜像时不必指明`Dockerfile`，否则在运行`docker build`命令时需加上`-f`参数进行指定。`Dockerfile`内容为：

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

### 1.4.3. 构建及检查

在当前目录中运行：

```bash
# 使用默认文件名`Dockerfile`
$ docker build -t centos-jdk8 .
# 或通过`-f`指定`Dockerfile`文件名
$ docker build -f <Dockerfile文件名> -t centos-jdk8 .
```

将建立名为`centos-jdk8:latest`的镜像。**注意**，命令中的`.`不能缺。

完成后执行：

```bash
$docker images
REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
centos-jdk8         latest              f73cb005904c        About a minute ago   679MB
centos              latest              470671670cac        4 weeks ago          237MB
java                8                   d23bdf5b1b1b        3 years ago          643MB

$docker run centos-jdk8 java -version
# 或以下命令进入镜像命令行后执行`java -version`，再执行`exit`退出
$docker run -it centos-jdk8
java version "1.8.0_241"
Java(TM) SE Runtime Environment (build 1.8.0_241-b07)
Java HotSpot(TM) 64-Bit Server VM (build 25.241-b07, mixed mode)
```

第一个命令返回以上内容，说明镜像建立成功。镜像仍有些大，应进行优化，例如删除不必要的包，以及只安装`jre`等。

第二个命令返回正确的`JDK`版本信息，说明所建镜像中`oracle jdk 8`安装有效。

### 1.4.4. 直接以压缩包构建

如果对`Dockerfile`进行以下修改，将：

```dockerfile
# 复制jdk8
COPY jdk1.8.0_241 /usr/java/jdk1.8.0_241
```

改为：

```dockerfile
# 解压并复制jdk8
ADD jdk-8u241-linux-x64.tar.gzip /usr/java
```

两者效果一样，说明`ADD`命令可以解压压缩包，比`COPY`命令省去手动解压缩过程。

### 1.4.5. 网络信息

以上所有操作在`VMware`中执行。以下为产生的 IP 地址：

| 地址所属                      | IPv4            |
| ----------------------------- | --------------- |
| 物理机在`VMware`中的地址      | 192.168.163.1   |
| `Ubuntu 19.10`虚拟机地址      | 192.168.163.138 |
| 虚拟机上`docker0`地址         | 172.17.0.1      |
| 容器`centos-jdk8`运行时的地址 | 172.17.0.2      |

## 1.5. 制作及运行应用镜像

### 1.5.1. 内容

所有应用均以`centos-jdk8`为基础镜像。实验三种应用程序的镜像构建及运行。

#### 1.5.1.1. 最简单的单体程序 yxy-simple

`yxy-simple`没有任何外部依赖，不读取配置文件，也不将输出写入任何文件，属于最简单的示例性应用。如果该应用无法成功构建镜像，更复杂应用的镜像构建也就无从谈起了。

如果有依赖的项目在生成`jar`包时产生的是`fat`包，即一个`jar`包包含所有依赖，其打包方式与`yxy-simple`类似。

`yxy-simple`的源码如下：

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

`yxy-simple`接收最多两个参数，第一个参数是循环次数，第二个可选参数是需要输出的信息字符串。如果不提供参数，则打印一条信息后直接返回。`yxy-simple`项目只有一个`jar`包，即`simple-1.0.jar`。

通过对`yxy-simple`的实验，可以了解以下方面：

1. 如何为简单应用构建镜像。
2. 如何启动、停止、删除容器。
3. 如何命名容器。
4. 如何连接并进入正在运行的容器。

#### 1.5.1.2. 有依赖及文件输入输出的程序 yxy-log

`yxy-log`以`yxy-simple`为基础，在其上增加了日志输出，并列出可选的第三个参数所指定目录的内容。日志框架使用`log4j2`。因此，`yxy-log`包含如下文件：

| 文件名称              | 用途                                           |
| --------------------- | ---------------------------------------------- |
| simpleLog-1.0.jar     | 主程序包                                       |
| log4j-api-2.13.0.jar  | 日志库 API 接口文件                            |
| log4j-core-2.13.0.jar | 日志库核心功能实现文件                         |
| log4j2.xml            | 日志配置文件，配置输出至当前目录下的`logs`目录 |

通过对`yxy-log`的实验，可以了解以下方面：

1. 如何为有依赖的应用构建镜像。
2. 如何在宿主机和容器之间建立存储联系。
3. 如何指定配置文件。

`yxy-log`主要源码如下：

```java
public class SimpleLog {
    private static final Logger logger = LogManager.getLogger();

    public static void main(String[] args) throws InterruptedException {
        final int maxArgs = 3;
        final int argsCount = args.length;

        if (argsCount == 0 || argsCount > maxArgs) {
            logger.info("Usage: java -jar simple-log-1.0.jar loopCount [, message [, pathToCheck]]");
            return;
        }

        final boolean showDirEnabled = argsCount == maxArgs && showDir(args[maxArgs - 1]);
        final String message = argsCount > 1 ? args[1] : "";

        // 可能抛出异常，从而可以测试显示异常信息。
        int loopCount = Integer.parseInt(args[0]);

        if (loopCount < 0) {
            loopCount = 1;
        } else if (loopCount == 0) {
            loopCount = Integer.MAX_VALUE;
        }

        if (showDirEnabled) {
            logger.info("====================");
        }

        int count = 0;
        do {
            logger.info("Loop[{}]: {}", count, message);
            Thread.sleep(1000);
        } while (++count < loopCount);

        if (showDirEnabled) {
            logger.info("====================");
            showDir(args[maxArgs - 1]);
        }

        logger.info("SIMPLE-LOG is finished.");
    }

    /**
     * 显示指定目录中的文件名。
     *
     * @param path 待显示的目录。
     * @return 目录是否有效。
     */
    private static boolean showDir(@NotNull final String path) {
        // 忽略。
    }
}
```

#### 1.5.1.3. 网络服务程序 yxy-web

通过对`yxy-web`的实验，可以了解以下方面：

1. 如何在构建时设置端口映射。
2. 如何在构建时指定更多的参数。
3. 如何在运行时指定容器内存等参数。

~~待续~~。

### 1.5.2. yxy-simple

#### 1.5.2.1. 构建镜像

在`实验目录`中建立目录`build-yxy-simple`并进入。复制应用程序`simple-1.0.jar`到当前目录，然后建立名为`yxy-simple.dockerfile`的`Dockerfile`：

```docker
# 指定基础镜像。
FROM centos-jdk8

MAINTAINER FuHongJie jasson.freeemail@126.com

# 复制应用文件。现在复制的只是一个文件。可以在复制过程中改名。用COPY亦可。
ADD simple-1.0.jar /opt/app.jar

# 设置镜像入口。一旦设置，使用docker run -it将不会进入container
ENTRYPOINT  ["java","-jar","app.jar"]
```

执行命令构建镜像：

```bash
$ docker build -f yxy-simple.dockerfile -t yxy/simple .
# 构建成功列出镜像。
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
yxy/simple          latest              c5d6e6d8f7fa        8 seconds ago       679MB
centos-jdk8         latest              f73cb005904c        About an hour ago   679MB
centos              latest              470671670cac        4 weeks ago         237MB
java                8                   d23bdf5b1b1b        3 years ago         643MB
```

相比构建`centos-jdk8`，构建新建镜像`yxy/simple`秒回。虽然`SIZE`也将近 700M，但其所耗时间远少于复制类似大小的文件。这是因为镜像构建是分层的，分层的镜像之间是引用关系。如果基础镜像存在，则不会将其全部复制一份。实际也不会占用这么大的空间。只有单独保存新镜像到本地时才会占用这么大的空间。

#### 1.5.2.2. 验证运行容器

执行：

```bash
$ docker run yxy/simple
Usage: java -jar simple-1.0.jar loopCount [, message]
```

执行：

```bash
$ docker run yxy/simple 2 abc
Loop[0]: abc
Loop[1]: abc
SIMPLE is finished.
```

以上结果均符合预期。将`abc`替换为中文`为什么`再次运行，得到：

```bash
$ docker run yxy/simple 2 为什么
Loop[0]: 为什么
Loop[1]: 为什么
SIMPLE is finished.
```

中文输出正确。如果在建立`centos-jdk8`镜像时指定了`en_US.utf8`而不是`C.UTF-8`，则返回如下信息：

```bash
$ docker run yxy/simple 2 为什么
Loop[0]: ?????????
Loop[1]: ?????????
SIMPLE is finished.
```

无法显示中文。是否设置`LC_ALL`对输出中文无影响。

#### 1.5.2.3. 不指定名称运行容器

执行：

```bash
# 先清理一下容器。该命令删除所有容器，而不是镜像。
$ docker container prune
# 创建并运行一个容器。
$ docker run yxy/simple 2 abc
# 最后使用以一两条命令之一列出镜像信息。
$ docker ps
# 或
$ docker container list
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                     PORTS               NAMES
```

结果没有返回任何容器信息。此时执行：

```bash
$ docker ps -a
# 或
$ docker container list -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                     PORTS               NAMES
e46272bf42af        yxy/simple          "java -jar app.jar 2…"   4 minutes ago       Exited (0) 4 minutes ago                       sleepy_golick
```

得到结果中`STATUS`为`Exited (0)`说明刚刚运行的容器已经结束了。

再次运行镜像`yxy/simple`并尝试列出容器，会发现增加了一条记录，只有`NAMES`不同：

```bash
# 创建并运行一个容器。
$ docker run yxy/simple 2 abc
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                      PORTS               NAMES
d4cc9c3cac5d        yxy/simple          "java -jar app.jar 2…"   5 seconds ago       Exited (0) 2 seconds ago                        admiring_euclid
e46272bf42af        yxy/simple          "java -jar app.jar 2…"   11 minutes ago      Exited (0) 11 minutes ago                       sleepy_golick
```

**如果不指定容器名称，`docker`会为每次建立新的容器并为其生成一个毫无规律的名字**。

#### 1.5.2.4. 指定名称运行容器

首先指定容器名称并创建运行：

```bash
# 指定容器名称运行。
$ docker run --name yxy-simple yxy/simple 2 why
# 列出所有容器。
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                      PORTS               NAMES
e6eac2380680        yxy/simple          "java -jar app.jar 2…"   7 seconds ago       Exited (0) 3 seconds ago                        yxy-simple
d4cc9c3cac5d        yxy/simple          "java -jar app.jar 2…"   6 minutes ago       Exited (0) 6 minutes ago                        admiring_euclid
e46272bf42af        yxy/simple          "java -jar app.jar 2…"   17 minutes ago      Exited (0) 17 minutes ago                       sleepy_golick
```

刚刚指定名称运行的容器也在列表中。

通过名称，可以直接运行容器，而不是从镜像创建：

```bash
$ docker container start -i yxy-simple
# 以下命令的返回列表中没有增加新的内容。
$ docker container list -a
```

结果发现应用程序输出与前面的操作相同。如果启动容器时不加参数`-i`或`-a`，则应用程序运行是不会输出到终端窗口的，因为其输出直接落于容器内部。

容器执行时的参数使用的是其被创建时的参数。**执行已存在的容器，无法改变应用程序参数**。

执行：

```bash
# 执行以下命令将返容器前面一系列运行的输出内容。此处忽略。
$ docker container logs yxy-simple
```

**注**，`docker container logs`命令可简写为`docker logs`。加上参数`-f`可持续输出。

#### 1.5.2.5. 连接正在运行的容器

加大循环次数，使容器长时间执行，此处循环 200 次，约 200 秒：

```bash
# 循环约200秒结束。
$ docker run --name yxy-simple-long yxy/simple 200 longtime
```

**注意**，如果仍以名称`yxy-simple`运行镜像`yxy/simple`，系统会警告同名容器存在。此时，需通过`docker rm yxy-simple`命令删除指定容器或`docker container prune`清理全部容器后方能执行。

在刚刚启动的容器结束运行前，建立新终端窗口，然后执行：

```bash
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS               NAMES
79bc9d18d624        yxy/simple          "java -jar app.jar 2…"   About a minute ago   Up About a minute                       yxy-simple-long
$ docker exec -it yxy-simple-long /bin/bash
[root@ca3062ec852e opt]# ls -a
.  ..  app.jar
[root@ca3062ec852e opt]#
```

第一条命令不用`-a`参数即可等到容器信息。其`STATUS`说明容器正在运行，尚未退出。

第二条命令进入了正在运行的容器，执行`ls`命令可行到`app.jar`，即构建镜像时设定的应用程序名。若想退出运行中的容器，执行`exit`命令即可。但此时应先保持连接状态，等待容器`yxy-simple`运行结束。当`yxy-simple`运行结束后，刚刚仍处于保持状态的连接将被强制退出。此时再执行`docker ps`命令将无法得到容器`yxy-simple-long`的信息，只能执行`docker ps -a`方可。

如果不等待容器运行结束，而是直接关闭运行容器的终端窗口，其结果与容器运行结束相同：与运行中容器建立的连接被直接关闭。

以上事实说明，**服务程序不能在终端窗口直接运行，否则一旦终端关闭，则包含服务的容器也同时关闭**。

#### 1.5.2.6. 后台运行容器

服务程序不能在前台，即终端窗口直接运行，否则一旦终端关闭，则包含服务的容器也同时关闭。包含服务程序的容器应该在后台运行。前台运行应仅应用于调试或执行一次性任务。后台运行加入参数`-d`即可：

```bash
# 先清理停止的容器，否则又得指定新名称。
$ docker rm yxy-simple-long
yxy-simple-long
$ docker run -d --name yxy-simple-long yxy/simple 200 longtime
```

或者不删除容器，直接启动指定名称的容器：

```bash
# 指定名称运行容器。
$ docker start yxy-simple-long
```

此时，即使立即关闭启动容器的终端窗口，也可以在新窗口中连接到运行中的容器`yxy-simple-long`。但是，在容器内的应用程序循环结束后，容器运行结束，连接仍然会被关闭。

所以，**服务程序应在逻辑上永不结束，且以后台方式运行**。

#### 1.5.2.7. 停止容器及删除容器和镜像

删除容器命令只能删除已停止的容器。正在运行的容器必须先停止，再删除。**删除容器命令**如下：

1. `docker container prune`：删除所有已停止的容器。
2. `docker rm <容器名称或ID＞`：删除指定的已停止的容器。

**停止容器命令**如下：

1. `docker container stop <容器名称或ID>`：停止指定的容器。
2. `docker stop <容器名称或ID>`：前一条命令的简写。
3. `docker container kill <容器名称或ID>`：强行停止指定的容器。
4. `docker kill <容器名称或ID>`：前一条命令的简写。

`stop`命令和`kill`命令的区别是前者先发一条`SIGTERM`信号，默认 10 秒后再发一条`SIGKILL`信号；后者直接发送`SIGKILL`信号。容器内部的应用程序可以接收`SIGTERM`信号，然后做一些退出前工作，比如保存状态、处理当前请求等。

用`docker kill`命令，可以简单粗暴的终止容器中运行的程序，但是想要优雅的终止掉的话，需要使用`docker stop`命令，并且在程序中多花一些功夫来处理系统信号，这样能保证程序不被粗暴的终止掉，从而实现 gracefully shutdown。

**在`java`程序中如何接收处理`SIGTERM`信号尚未验证**。

**删除镜像命令**如下：

1. `docker image rmi <镜像名称或ID>`：删除没有任何容器或镜像关联的镜像。
2. `docker rmi <镜像名称或ID>`：前一条命令的简写。
3. `docker image rmi -f <镜像名称或ID>`：强制删除镜像及与其关联的所有容器或镜像镜像。
4. `docker rmi -f <镜像名称或ID>`：前一条命令的简写。

以下命令组合删除所有镜像，若强制需加参数`-f`，**该命令极为危险**：

```bash
# 删除所有镜像
$ docker rm $(docker image ls -q)
```

### 1.5.3. yxy-log

#### 1.5.3.1. 构建镜像

在`实验目录`中建立目录`build-yxy-log`并进入。再建立目录`simpleLog`，然后复制以下文件到该目录中：

- simpleLog-1.0.jar
- log4j-api-2.13.0.jar
- log4j-core-2.13.0.jar
- log4j2.xml

在`build-yxy-log`中为新建目录建立压缩包：

```bash
# 建立应用程序压缩包，不包含日志配置文件。
$ tar -zcvf simpleLog.tar.gz simpleLog/*.jar
$ ls -a
drwxr-xr-x 2 jason jason    4096 2月  21 09:59 simpleLog/
-rw-r--r-- 1 jason jason 1768249 2月  21 10:20 simpleLog.tar.gz
```

将为`yxy-log`构建两个不同的镜像：

| 镜像名称    | Dockerfile             | 内容及目的                                          |
| ----------- | ---------------------- | --------------------------------------------------- |
| yxy/log-dir | yxy-log-dir.dockerfile | 通过复制文件目录构建，包含日志配置文件              |
| yxy/log-tar | yxy-log-tar.dockerfile | 通过压缩文件构建，只包含 jar 包，不包含日志配置文件 |

根据以上文件名为建立`Dockerfile`：

```docker
# 指定基础镜像。
FROM centos-jdk8:latest

MAINTAINER FuHongJie jasson.freeemail@126.com

# ===========================================
# 以下两部分内容对应不同的文件，请自行替换或注释掉。

# 1. 以下为yxy-log-dir.dockerfile内容
# 复制应用文件。现在复制的是一个目录。
ADD simpleLog /opt/simpleLog

# 2. 以下为yxy-log-tar.dockerfile内容
# ADD simpleLog.tar.gz /opt

# 替换结束。
# ===========================================

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
# 构建两个镜像。
$ docker build -f yxy-log-dir.dockerfile -t yxy/log-dir .
$ docker build -f yxy-log-tar.dockerfile -t yxy/log-tar .
$ docker image list
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
yxy/log-tar         latest              da651164ecd4        30 seconds ago      681MB
yxy/log-dir         latest              3087eca2d75d        41 seconds ago      681MB
yxy/simple          latest              c5d6e6d8f7fa        20 hours ago        679MB
centos-jdk8         latest              f73cb005904c        22 hours ago        679MB
centos              latest              470671670cac        4 weeks ago         237MB
hello-world         latest              fce289e99eb9        13 months ago       1.84kB
java                8                   d23bdf5b1b1b        3 years ago         643MB
```

#### 1.5.3.2. 验证运行容器

执行：

```bash
$ docker run --name yxy-log-dir yxy/log-dir 3 abc一二三def
11:13:50.863 I com.yxy.docker.SimpleLog [main] - Loop[0]: abc一二三def
11:13:51.867 I com.yxy.docker.SimpleLog [main] - Loop[1]: abc一二三def
11:13:52.868 I com.yxy.docker.SimpleLog [main] - Loop[2]: abc一二三def
11:13:53.869 I com.yxy.docker.SimpleLog [main] - SIMPLE-LOG is finished.
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS                          PORTS               NAMES
06d5783936bd        yxy/log-dir         "java -jar /opt/simp…"   About a minute ago   Exited (0) About a minute ago                       yxy-log-dir
6647082aee77        yxy/simple          "java -jar app.jar 2…"   2 hours ago          Exited (0) 2 hours ago                              yxy-simple-long
```

通过复制目录并包含日志配置文件创建的镜像生成容器运行良好。

执行：

```bash
$ docker run --name yxy-log-tar yxy/log-tar 3 no_output
# 没有任何输出，但运行时间与运行yxy-log-dir相等。
```

虽然没有任何输出，但运行时间与运行`yxy-log-dir`相等。没有输出是因为没有日志配置文件，所有输出全部打印到容器内部了。如何设置将在后面说明。

#### 1.5.3.3. 挂载目录运行

在`/home/jason/docker-demo/build-yxy-log`中建立目录`logs`并进入。

执行：

```bash
$ docker run -v /home/jason/docker-demo/build-yxy-log/logs:/opt/simpleLog/logs yxy-log 2 abc .
11:29:49.356 I com.yxy.docker.SimpleLog [main] - Absolute path of [.] is [/opt/simpleLog/.].
11:29:49.360 I com.yxy.docker.SimpleLog [main] - Path [.] contains [5] files.
11:29:49.360 I com.yxy.docker.SimpleLog [main] - ---- [0]: log4j2.xml
11:29:49.360 I com.yxy.docker.SimpleLog [main] - ---- [1]: simpleLog-1.0.jar
11:29:49.361 I com.yxy.docker.SimpleLog [main] - ---- [2]: log4j-api-2.13.0.jar
11:29:49.361 I com.yxy.docker.SimpleLog [main] - ---- [3]: log4j-core-2.13.0.jar
11:29:49.362 I com.yxy.docker.SimpleLog [main] - ---- [4]: logs
11:29:49.362 I com.yxy.docker.SimpleLog [main] - ====================
11:29:49.363 I com.yxy.docker.SimpleLog [main] - Loop[0]: abc
11:29:50.363 I com.yxy.docker.SimpleLog [main] - Loop[1]: abc
11:29:51.364 I com.yxy.docker.SimpleLog [main] - ====================
11:29:51.365 I com.yxy.docker.SimpleLog [main] - Absolute path of [.] is [/opt/simpleLog/.].
11:29:51.366 I com.yxy.docker.SimpleLog [main] - Path [.] contains [5] files.
11:29:51.366 I com.yxy.docker.SimpleLog [main] - ---- [0]: log4j2.xml
11:29:51.366 I com.yxy.docker.SimpleLog [main] - ---- [1]: simpleLog-1.0.jar
11:29:51.366 I com.yxy.docker.SimpleLog [main] - ---- [2]: log4j-api-2.13.0.jar
11:29:51.367 I com.yxy.docker.SimpleLog [main] - ---- [3]: log4j-core-2.13.0.jar
11:29:51.367 I com.yxy.docker.SimpleLog [main] - ---- [4]: logs
11:29:51.367 I com.yxy.docker.SimpleLog [main] - SIMPLE-LOG is finished.

$ ll
-rw-r--r-- 1 root  root  2696 2月  21 11:29 app.log
-rw-r--r-- 1 root  root     0 2月  21 11:29 error.log

$ cat app.log
2020-02-21 11:29:49.356 INFO  com.yxy.docker.SimpleLog                           [main                          ] - Absolute path of [.] is [/opt/simpleLog/.].
2020-02-21 11:29:49.360 INFO  com.yxy.docker.SimpleLog                           [main                          ] - Path [.] contains [5] files.
2020-02-21 11:29:49.360 INFO  com.yxy.docker.SimpleLog                           [main                          ] - ---- [0]: log4j2.xml
2020-02-21 11:29:49.360 INFO  com.yxy.docker.SimpleLog                           [main                          ] - ---- [1]: simpleLog-1.0.jar
2020-02-21 11:29:49.361 INFO  com.yxy.docker.SimpleLog                           [main                          ] - ---- [2]: log4j-api-2.13.0.jar
2020-02-21 11:29:49.361 INFO  com.yxy.docker.SimpleLog                           [main                          ] - ---- [3]: log4j-core-2.13.0.jar
2020-02-21 11:29:49.362 INFO  com.yxy.docker.SimpleLog                           [main                          ] - ---- [4]: logs
2020-02-21 11:29:49.362 INFO  com.yxy.docker.SimpleLog                           [main                          ] - ====================
2020-02-21 11:29:49.363 INFO  com.yxy.docker.SimpleLog                           [main                          ] - Loop[0]: abc
2020-02-21 11:29:50.363 INFO  com.yxy.docker.SimpleLog                           [main                          ] - Loop[1]: abc
2020-02-21 11:29:51.364 INFO  com.yxy.docker.SimpleLog                           [main                          ] - ====================
2020-02-21 11:29:51.365 INFO  com.yxy.docker.SimpleLog                           [main                          ] - Absolute path of [.] is [/opt/simpleLog/.].
2020-02-21 11:29:51.366 INFO  com.yxy.docker.SimpleLog                           [main                          ] - Path [.] contains [5] files.
2020-02-21 11:29:51.366 INFO  com.yxy.docker.SimpleLog                           [main                          ] - ---- [0]: log4j2.xml
2020-02-21 11:29:51.366 INFO  com.yxy.docker.SimpleLog                           [main                          ] - ---- [1]: simpleLog-1.0.jar
2020-02-21 11:29:51.366 INFO  com.yxy.docker.SimpleLog                           [main                          ] - ---- [2]: log4j-api-2.13.0.jar
2020-02-21 11:29:51.367 INFO  com.yxy.docker.SimpleLog                           [main                          ] - ---- [3]: log4j-core-2.13.0.jar
2020-02-21 11:29:51.367 INFO  com.yxy.docker.SimpleLog                           [main                          ] - ---- [4]: logs
2020-02-21 11:29:51.367 INFO  com.yxy.docker.SimpleLog                           [main                          ] - SIMPLE-LOG is finished.
```

容器中的日志被保存在了指定的目录`/home/jason/docker-demo/build-yxy-log/logs`中了，内容正确。

容器上当前目录是`/opt/simpleLog`。运行程序时在其下会建立日志目录`logs`。如果构建镜像时，未明确指定工作目录，则以上返回中，当前目录将是从基础镜像继承而来的`/opt`，而其下将有`/opt/logs`和`/opt/simpleLog`两个目录。此时，由于命令指定的容器目录`/opt/simpleLog/logs`不存在，目录挂载将失败，但**不会报错**！以上试错过程请自行构建镜像尝试。

在宿主机目录与容器目录均正确时，挂载生效。宿主机`/home/jason/docker-demo/build-yxy-log/logs`下将产生文件`app.log`和`error.log`，与日志配置相符。`app.log`内容也正确。控制台输出内容与日志文件格式稍有不同，这是在日志配置文件中定义的。

**注**，目录名中有中文可正常运行。

#### 1.5.3.4. 挂载目录指向程序目录

当挂载目录指向的是容器中程序所在目录时，有两种情况会发生。**第一种**，宿主机挂载目录中没有容器所需的程序，例如挂载目录`/home/jason/docker-demo/build-yxy-log`中没有`simpleLog-1.0.jar`及其依赖的所有包，运行：

```bash
$ docker run -v /home/jason/docker-demo/build-yxy-log:/opt/simpleLog yxy/log-dir 2 error .
Error: Unable to access jarfile /opt/simpleLog/simpleLog-1.0.jar
```

执行失败，返回了错误信息。

因为容器中的`/opt/simpleLog`映射到了宿主机的`/home/jason/docker-demo/build-yxy-log`，而宿主机的目录中没有相应的`jar`包，相当于在没有相应`jar`包的目录中执行了`java -jar simpleLog-1.0.jar`，所以报上述错误。

**第二种**，如果在挂载目录中有全套的应用程序，执行前述命令相当于用容器内的`jdk`运行了宿主机上的应用程序，在挂载目录中会按日志配置建立`logs`目录及相应的日志文件。

#### 1.5.3.5. 挂载配置文件

挂载操作不仅可以挂载目录，还可以直接挂载文件，从而解决配置文件的问题。

首先删除`/home/jason/docker-demo/build-yxy-log/logs`中的日志文件，以备测试。然后在该目录中执行：

```bash
$ ls -a
# 此时目录为空。
$ docker run -v /home/jason/docker-demo/build-yxy-log/simpleLog/log4j2.xml:/opt/simpleLog/log4j2.xml -v /home/jason/docker-demo/build-yxy-log/logs:/opt/simpleLog/logs yxy/log-tar 2 ok .
12:28:41.565 I com.yxy.docker.SimpleLog [main] - Absolute path of [.] is [/opt/simpleLog/.].
12:28:41.569 I com.yxy.docker.SimpleLog [main] - Path [.] contains [5] files.
...
12:28:41.571 I com.yxy.docker.SimpleLog [main] - ====================
12:28:41.571 I com.yxy.docker.SimpleLog [main] - Loop[0]: ok
12:28:42.572 I com.yxy.docker.SimpleLog [main] - Loop[1]: ok
12:28:43.574 I com.yxy.docker.SimpleLog [main] - ====================
...
12:28:43.579 I com.yxy.docker.SimpleLog [main] - SIMPLE-LOG is finished.

$ ls
app.log  error.log

$ cat app.log
# 显示正确的日志内容，与前面的实验相同。
```

镜像`yxy/log-tar`中不包含日志配置文件，所以直接运行没有任何输出。此处通过两次使用`-v`参数指定了配置文件及日志输出目录的映射，容器正常运行。结果与日志配置文件在容器中时完全一样。

**注意**，即使在`yxy/log-dir`中已包含日志配置文件，也以使用以上方法强制使用外部的配置文件。

打开`/home/jason/docker-demo/build-yxy-log/simpleLog/log4j2.xml`，将配置内容中指定的输出目录从`logs`改为`logsNew`：

```xml
<!-- 对以下值进行修改 -->
<property name="LOG_HOME">logs</property>
<!-- 改为 -->
<property name="LOG_HOME">logsNew</property>
```

此时执行

```bash
$ docker run -v /home/jason/docker-demo/build-yxy-log/simpleLog/log4j2.xml:/opt/simpleLog/log4j2.xml -v /home/jason/docker-demo/build-yxy-log/logs:/opt/simpleLog/logsNew yxy/log-dir 2 new_log_path
12:44:06.268 I com.yxy.docker.SimpleLog [main] - Loop[0]: new_log_path
12:44:07.272 I com.yxy.docker.SimpleLog [main] - Loop[1]: new_log_path
12:44:08.275 I com.yxy.docker.SimpleLog [main] - SIMPLE-LOG is finished.

$ cat app.log
2020-02-21 12:45:05.693 INFO  com.yxy.docker.SimpleLog                           [main                          ] - Loop[0]: new_log_path
2020-02-21 12:45:06.697 INFO  com.yxy.docker.SimpleLog                           [main                          ] - Loop[1]: new_log_path
2020-02-21 12:45:07.699 INFO  com.yxy.docker.SimpleLog                           [main                          ] - SIMPLE-LOG is finished.
```

如果应用程序在其当前路径下有多个配置文件，目前只有两种方法：

1. 在`docker run`命令中使用`-v`参数逐一挂载配置文件。此方法比较麻烦。
2. 修改程序，将所有配置文件移至单独的目录，然后挂载该配置文件目录。此方法配置`docker`命令简单，但需对程序做调整。

### 1.5.4. yxy-web

~~待续~~

## 1.6. 在 Intellij Idea 使用 docker

~~待续~~

## 1.7. 参考资料

### 1.7.1. 参考文章

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
1. [IntelliJ IDEA 快速实现 Docker 镜像部署](https://my.oschina.net/wuweixiang/blog/2874064)：图文并茂，很详细，尚未实验。
1. [优雅的终止 docker 容器](https://xiaozhou.net/stop-docker-container-gracefully-2016-09-08.html)：对如何结束容器的说明很细，有`go`语言获取`SIGTERM`信号的示例。

### 1.7.2. 教程

1. [RIP Tutorial](https://riptutorial.com/zh-CN/docker/)：稍显老旧的教程，机器翻译得不太好，内容尚可。
2. [Docker 入门教程](http://www.docker.org.cn/book/docker)：极为精简的教程，可在 15 分钟内看完、练完，初步感觉`docker`是咋回事。
