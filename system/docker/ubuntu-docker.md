# 在Ubuntu下运行docker

## 一、安装

### 1.1执行安装

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

### 1.2赋予当前用户权限

**此步可省略！！！**

若省略，则每次执行`docker`命令，均需明确管理员权限，即在命令前加`sudo`。

#### 1.2.1确认docker组已建立

若要设置权限，以简便`docker`相关操作，可执行以下命令确认`docker`组已建立：

```bash
sudo groupadd docker
```

将返回：

```text
groupadd：“docker”组已存在
```

如果不返回类似以上的结果，则`docker`可能需要重新安装。

#### 1.2.2向docker组添加当前用户

执行：

```bash
$ sudo usermod -aG docker $USER
# 或者使用下面命令，此命令的返回信息明确，而前一命令没任何返回。
# 两个命令都试了，但不知道哪个生效了。
$ sudo gpasswd -a ${USER} docker
```

#### 1.2.3重启docker服务

```bash
$ sudo service docker restart
# 或者使用下面命令。
$ sudo /etc/init.d/docker restart
```

#### 1.2.4确保权限生效

切换当前会话到新`group`或者重启`X`会话。这一步是必须的，否则因为`groups`命令获取到的是缓存的组信息，刚添加的组信息未能生效，所以`docker images`等命令执行时同样有错。执行：

```bash
newgrp - docker
```

打开新的终端窗口，`docker images`等命令无需再加前缀`sudo`。

实际执行过程中，完成以上步骤后，一会要求`sudo`，一会无需`sudo`。最后重启系统，一切OK。

### 1.3更改镜像源

docker的镜像仓库在国外，下载会很慢，启用阿里云加速。在/etc/docker目录下创建daemon.json文件，添加如下内容：

```json
{
  "registry-mirrors": ["https://almtd3fa.mirror.aliyuncs.com"]
}
```

修改后，重启docker：

```bash
systemctl daemon-reload
service docker restart
```

## 二、下载镜像

需要下载`centos`及`java8`镜像。通过下列命令查询相关镜像：

```bash
sudo docker search centos
sudo docker search java:8
```

从结果发现，`centos`镜像是`Offical`的，而`java8`不是。
执行：

```bash
sudo docker pull centos
sudo docker pull java:8
```

`centos`默认下载`lastest`。执行：

```bash
sudo docker images
# 或
sudo docker image list
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

与我方实际生产环境中不同。实际生产环境是`oracle jre 8`，截止`2020-02-14`的最新版是`241`。所以，应使用`centos`建立新的镜像。但使用`java8`可以做实验。

通过`docker inspect`命令可以查看镜像的详细信息，会以`json`格式显示。

## 三、备份及恢复镜像

执行命令：

```bash
sudo docker save -o centos-8.1.1911.tar centos
sudo docker save -o java-8.111.tar d23bdf
```

对`centos`使用了镜像名称；对`java`使用镜像ID的一部分。保存镜像后执行`ll`命令得到如下返回：

```text
drwxr-xr-x 2 jason jason      4096 2月  13 23:31 ./
drwxr-xr-x 3 jason jason      4096 2月  13 21:08 ../
-rw------- 1 root  root  244953088 2月  13 23:30 centos-8.1.1911.tar
-rw------- 1 root  root  659248640 2月  13 23:31 java-8.111.tar
```

使用`sudo tar -xf <filename>`命令可以解压这些包。

备份后的镜像`tar`包可以通过如下命令恢复，以`java8`镜像为例：

```bash
sudo docker load -i java-8.111.tar
```

备注：删除镜像的命令是`sudo docker rmi -f <镜像名称或ID>`。

## 四、制作JDK镜像

### 4.1下载JDK并解压

以`centos`镜像为基础，制作`oracle jdk 8u241`的镜像。

从[Oralce](https://www.java.com/en/download/manual.jsp)下载`JDK`到当前目录并解压：

```bash
tar -zxvf jdk-8u241-linux-x64.tar.gzip
```

### 4.2Dockerfile

在当前目录编写`Dockerfile`，使用默认名称即可：

```dockerfile
FROM centos

MAINTAINER FuHongJie jasson.freeemail@126.com

# 复制java8到镜像
COPY jdk1.8.0_241 /usr/java/jdk1.8.0_241

# 设置jdk环境变量
ENV JAVA_HOME=/usr/java/jdk1.8.0_241
ENV JRE_HOME=/usr/java/jdk1.8.0_241/jre

ENV PATH=$PATH:$JAVA_HOME/bin:$JRE_HOME/bin
ENV CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib

# 这个指令表示，我们运行容器时，容器默认的工作目录
WORKDIR /opt
```

### 4.3构建及检查

运行：

```bash
# 使用默认文件名`Dockerfile`
sudo docker build -t yxy/centos/java8 .
# 通过`-f`指定`Dockerfile`文件名
sudo docker build -f <文件名> -t yxy/centos/java8 .
```

将建立名为`yxy/centos/java8:latest`的镜像。

完成后执行：

```bash
docker images
docker run yxy/centos/java8 java -version
# 或以下命令进入镜像命令行后执行`java -version`，再执行`exit`退出
docker run -it yxy/centos/java8
```

第一个命令返回以下内容，说明镜像建立成功：

```text
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
yxy/centos/java8    latest              c62c38c2d26b        3 minutes ago       641MB
centos              latest              470671670cac        3 weeks ago         237MB
hello-world         latest              fce289e99eb9        13 months ago       1.84kB
java                8                   d23bdf5b1b1b        3 years ago         643MB
java                latest              d23bdf5b1b1b        3 years ago         643MB
learn/tutorial      latest              a7876479f1aa        6 years ago         128MB
```

镜像仍有些大，应进下优化，例如删除不必要的包，以及只安装`jre`等。

第二个命令返回，说明所建镜像中`java`安装有效：

```text
java version "1.8.0_241"
Java(TM) SE Runtime Environment (build 1.8.0_241-b07)
Java HotSpot(TM) 64-Bit Server VM (build 25.241-b07, mixed mode)
```

### 4.4网络信息

以上所有操作在`VMware`中执行。以下为产生的IP地址：

|地址所属|IPv4|
|------|------|
|物理机在`VMware`中的地址|192.168.163.1|
|`Ubuntu 19.10`的地址|192.168.163.138|
|`docker0`地址|172.17.0.1|
|`yxy/centos/java8`运行时的地址|172.17.0.2|

物理机在`VMware`中的地

## 附件：参考资料

1. [Ubuntu18.04安装Docker](https://blog.csdn.net/u010889616/article/details/80170767)
1. [Ubuntu18.04下Docker CE安装](https://www.jianshu.com/p/07e405c01880)
1. [Docker镜像的备份和恢复](https://blog.csdn.net/k21325/article/details/70184253)
1. [备份Docker镜像容器和数据](http://einverne.github.io/post/2018/03/docker-related-backup.html)
1. [Docker容器之最小JDK基础镜像](https://cloud.tencent.com/developer/article/1188404)：`Dockerfile`中设置了工作目录，使用`镜像`为基础，最终生成的镜像大小仅`122M`。包含去除无用的jar包。
1. [docker java8 image](https://www.jianshu.com/p/d4e93bc86455)：以`centos`镜像为基础构建，其`Dockerfile`还包含时区设置和网络工具安装，以及向私服推送镜像。
1. [基于centos构建java8 docker镜像](https://github.com/xfdocker/java8)：`github`上有`Dockerfile`源码。所有东西都在构建时从网上下载。中文说明，但不细。其中，关于在镜像中设置中文的操作尝试未成功。
