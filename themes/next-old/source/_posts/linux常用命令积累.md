---
title: linux常用命令积累
date: 2017-03-20 20:23:38
tags: linux
categories: linux
---

## 记在前面
平时工作基本上都是java相关开发工作，但是偶尔会用到shell。用到某个命令都会去查阅相关资料，
不能很好记忆，在这儿做个总结（持续补充）。
<!--more-->
## vim
``` bash
#normal模式下
选中文本  # 直接按键v，进入默认visual模式，使用v+j/k/h/l 进行文本选择 或移动光标键选定

/xxx	从光标开始处向文件尾搜索xxx，按n查找下一个，N查找上一个
?xxx	从光标开始处向文件首搜索xxx

u  # 撤销上一步的操作
Ctrl+r # 恢复上一步被撤销的操作

0  # 光标移到行首(数字0)
$  # 光标移至行尾
h  # 光标左移一个字符
l  # 光标右移一个字符
j  # 光标下移一行
k  # 光标上移一行

gg  # 到第一行（到文件头）
G  # 到最后一行（到文件末尾）

Ctrl+u	# 向文件首翻半屏
Ctrl+d	# 向文件尾翻半屏
Ctrl+f	# 向文件尾翻一屏
Ctrl＋b	# 向文件首翻一屏

y  # 在使用v模式选定了某一块的时候，复制选定块到缓冲区用
yy # 复制整行
y^ # 复制当前到行头的内容
y$ # 复制当前到行尾的内容

d  # 剪切选定块到缓冲区； 
dd # 剪切整行 
d^ # 剪切至行首 
d$ # 剪切至行尾 

p  # 粘贴  小写p代表贴至游标后
P  # 粘贴  大写P代表贴至游标前
```
## scp
``` bash
# 从远程复制文件到本地目录
scp username@192.168.10.127:/var/log/java/rolling.log /var/log/java/

# 从远程复制目录到本地
scp -r username@192.168.10.127:/var/log/ /var/log/
```
## 压缩
``` bash
tar zcvf xxx.tar 需要压缩的目录
zip -r xxx.zip 需要压缩的目录
```
## 解压
``` bash
tar zxvf xxx.tar -C 需要解压到的目录
unzip xxx.zip 
```

## 查看内存
``` bash
free -m
```