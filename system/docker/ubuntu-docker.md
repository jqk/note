# 在Ubuntu下运行docker

[Ubuntu18.04安装Docker](https://blog.csdn.net/u010889616/article/details/80170767)

[Ubuntu18.04下Docker CE安装](https://www.jianshu.com/p/07e405c01880)

使用其第一种方法，即`curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun`安装成功。此时源为阿里云。

使用`systemctl is-enabled docker`可检查docker是否作为服务自启动。如果不是，可使用`systemctl enable docker`进行设置。

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
