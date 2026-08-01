---
title: 搭建安装 Gitlab
date: 2018-03-10 22:17:48
tags: gitlab
categories: gitlab
---

# 记在前面
资料记录，关于Gitlab的搭建配置。
<!--more-->
换了个工作，发现版本控制用的是svn，和老大讨论后，后面的项目都用git，但git服务器都还没有搭起来。刚好有时间，我就去弄了下，在此记录下来。服务器是公司配备的一台阿里云服务器，分配有域名。

# 两种安装方法
- 编译安装
   - 优点：可定制性强。数据库既可以选择MySQL，也可以选择PostgreSQL；服务器既可以选择Apache，也可以选择Nginx。
   - 优点：缺点：国外的源不稳定，被墙时，依赖软件包难以下载。配置流程繁琐、复杂，容易出现各种各样的问题。依赖关系多，不容易管理，卸载GitLab相对麻烦。
- 通过rpm包安装
   - 优点：安装过程简单，安装速度快。采用rpm包安装方式，安装的软件包便于管理。
   - 缺点：数据库默认采用PostgreSQL，服务器默认采用Nginx，不容易定制。 
临时充当把运维，本着快速、简单原则采取rpm安装。

# 编辑源
使用[清华大学TUNA镜像源](https://mirror.tuna.tsinghua.edu.cn/help/gitlab-ce/)，选择RHEL/CentOS 用户，将内容复制到/etc/yum.repos.d/gitlab-ce.repo文件中：
``` bash
[gitlab-ce]
name=Gitlab CE Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el$releasever/
gpgcheck=0
enabled=1
```

# 更新本地yum缓存
``` bash
sudo yum makecache
```

# 安装GitLab社区版
``` bash
sudo yum install gitlab-ce-8.8.4-ce.0.el6 #(安装指定版本)
sudo yum install gitlab-ce #(自动安装最新版)
```
gitlab安装目录和所有的工程目录都在/var/opt/gitlab/路径下。

# 配置并启动
更改访问域名和ssh端口 vim /etc/gitlab/gitlab.rb：
``` bash
external_url #换成对应公司git域名
gitlab_rails['gitlab_shell_ssh_port'] = #换成对应的ssh端口号
```
所有的配置在/etc/gitlab/gitlab.rb中修改，修改完配置后执行gitlab-ctl reconfigure生效。

# 登录GitLab
``` bash
username: root 
password: 5iveL!fe
```

# 关闭注册功能
默认注册功能是开启的，公司的Gitlab的话需要考虑关闭注册功能。用管理员账号登录之后，进入”Admin area”，点”settings”，取消”Signup enabled”。

# 备份
利用crontab定时备份，如每周日凌晨2点进行备份。
``` bash
0 2 * * 0 /opt/gitlab/bin/gitlab-rake gitlab:backup:create
```
在/var/opt/gitlab/backups目录下创建一个名称类似为xxxxxxxx_gitlab_backup.tar的压缩包，这个压缩包就是Gitlab整个的完整部分, 其中开头的xxxxxx是备份创建的时间戳。

# 修改备份文件默认目录
vi /etc/gitlab/gitlab.rb修改默认存放备份文件的目录。
``` bash
gitlab_rails['backup_path'] = '/var/backup'
```