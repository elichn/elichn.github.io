---
title: Git回滚到特定版本
date: 2019-07-15 17:36:08
tags: git
categories: git
---

# 记在前面
生产环境上线，运维合代码时，把不该上线的分支合到master了。不该上线的分支测试都没有测，肯定是不符合要求的，需要回滚到特定的版本。<!--more-->当时要着急上线，还好上线前打了tag，我首先从tag新拉了一个分支，让运维用新拉的分支发了个版。保证先上线。具体回滚操作步骤如下：

# 操作步骤

## 查找commitId

可以通过命令行或者图形化界面SourceTree查看commitId，找到上一次正常版本里的最后一次提交记录。

### Git 命令行

```java
$ git log
```

git log执行后如下图：

![](/images/git/git-log.png)

git log命令行显示不大友好。利用配置git bash命令行可以达到分支图谱可视化的效果，配置如下：

```java
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
```

配置好后，执行git lg，如下图：

![](/images/git/git-lg.png)

### SourceTree

第二种方法可以利用图形化界面SourceTree（自己用的SourceTree，可以利用其它工具），找到对应图谱，如下图：

![](/images/git/source-tree.png)


通过上面的两种方式都可以得到要的commit

```java
57d6c162ff
```

## 本地回滚

找到需要回滚的commit，输入git reset --hard {commitId}，将本地文件回滚：

```java
git reset --hard 57d6c162ff

// 因为每次上线都会打tag，也可以通过tag本地回滚（前提是打好了tag）
git reset --hard tag-20170711 
```

## 远程回滚

此时本地文件已经回滚到刚刚commit 57d6c162ff之前的状态，但是服务器仍然没有改变，需要继续远程回滚：

```
git push -f
```

要把本地的修改强制推送到远程分支上，在强推master时报错，意思是没有权限之类的错误。原因是master分支是保护分支，所以首先要去除master保护分支，才可以强推。

GitLab修改步骤如下：管理员进入-->进入对应项目-->Settings-->Protected Branches  -->修改。如下图：

![](/images/git/git-lab.png)

执行 git push -f 远程回滚成功。

运维拿着回滚后的master分支再次发版，解决问题。

