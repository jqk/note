# Ubuntu安装优化

## 安装

请参考[ubuntu19.10安装教程](https://blog.csdn.net/Thanlon/article/details/100072462)。该文图文并貌，写得很详细。此处注意，使用`VMware`默认的快速安装，将安装上英文版。换成中文要求下载一堆东西，很麻烦。所以还是不要太自动化，一步步来的好。

## 修改软件更新源

使用默认的软件更新源比较慢，参考[Ubuntu 19.04 国内更新源](https://blog.csdn.net/wy_bk/article/details/89473921)换源成功。但在源服务器顺序上与该文不同，而是先`ping`过各个服务器，然后根据响应时间，短的在前，长的在后。

执行以下命令：

```bash
cd /etc/apt

# 备份原有软件更新源地址文件。
sudo cp -p sources.list sources.list.bak

# 建立新软件更新源地址文件。
sudo vi sources.list
```

以下为换源后的`sources.list`内容：

```bash
#清华源
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ disco main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ disco main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ disco-updates main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ disco-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ disco-backports main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ disco-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ disco-security main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ disco-security main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ disco-proposed main restricted universe multiverse
deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ disco-proposed main restricted universe multiverse

#163源
deb http://mirrors.163.com/ubuntu/ disco main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ disco-security main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ disco-updates main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ disco-proposed main restricted universe multiverse
deb http://mirrors.163.com/ubuntu/ disco-backports main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ disco main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ disco-security main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ disco-updates main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ disco-proposed main restricted universe multiverse
deb-src http://mirrors.163.com/ubuntu/ disco-backports main restricted universe multiverse

#中科大源
deb https://mirrors.ustc.edu.cn/ubuntu/ disco main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ disco main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ disco-updates main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ disco-updates main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ disco-backports main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ disco-backports main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ disco-security main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ disco-security main restricted universe multiverse
deb https://mirrors.ustc.edu.cn/ubuntu/ disco-proposed main restricted universe multiverse
deb-src https://mirrors.ustc.edu.cn/ubuntu/ disco-proposed main restricted universe multiverse

#阿里云源
deb http://mirrors.aliyun.com/ubuntu/ disco main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ disco main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ disco-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ disco-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ disco-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ disco-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ disco-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ disco-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ disco-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ disco-proposed main restricted universe multiverse
```

换源后，执行以下命令更新系统：

```bash
sudo apt-get update
sudo apt-get upgrade

sudo apt autoremove
```

## 清理磁盘

先卸载已无用的软件。不是人工卸载不想要的，而是由于系统更新，有些软件已经没有引用。执行：

```bash
sudo apt autoremove
sudo apt autoclean
sudo apt clean
```

时一步清理磁盘请参考[Ubuntu系统释放磁盘空间的7种简单方法](https://www.linuxidc.com/Linux/2017-10/148117.htm)、[Ubuntu 16.04安装Stacer系统优化工具](https://www.linuxidc.com/Linux/2017-07/145517.htm)和[Ubuntu常用磁盘工具Disks、GParted和系统清理应用Cleaner](https://blog.csdn.net/ZhangRelay/article/details/84671441)。
