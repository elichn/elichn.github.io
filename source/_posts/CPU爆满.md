---
title: CPU爆满处理
date: 2019-11-12 16:32:16
tags: java
categories: java
---

# 记在前面
记录一次生产环境服务器CPU爆满的排查和处理过程。<!--more-->


# 收到问题

2019.11.12 10:50左右钉钉接到运维说生产服务器×××1，内存爆了；紧接着业务前端反馈系统卡顿，页面加载不出来，日志钉钉报警和短信报警接踵而来。

![](/images/cpu/server-monitor.png)


通过阿里云ecs查看cpu监控

![](/images/cpu/cpu-ecs.jpg)

通过阿里云rds查看mysql链接

![](/images/cpu/mysql-session.jpg)

# 保证服务可用
2019.11.12 10:52 联系运维，把×××1流量打到备用×××2服务器上，保证服务可用，业务不停。业务基本恢复。

# 排查
业务恢复后，立即展开排查，首先定位问题。

## 定位
- 首选缩小定位范围，×××1服务器就部署了 一个jvm实例，jvm出问题。
- 开发没有线上生产环境权限，去运维工位排查，在运维机器上输入指令**jstat -gcutil 21257 10000**，观察GC情况，发现fullgc频繁，应该有oom。
- 告知运维dump，给运维发送指令。从**jmap -heap 21257** 如下 看出老年代内存已耗尽
Heap Usage:
PS Young Generation
Eden Space:
   capacity = 1673527296 (1596.0MB)
   used     = 1673527296 (1596.0MB)
   free     = 0 (0.0MB)
   100.0% used
From Space:
   capacity = 185073664 (176.5MB)
   used     = 0 (0.0MB)
   free     = 185073664 (176.5MB)
   0.0% used
To Space:
   capacity = 199753728 (190.5MB)
   used     = 0 (0.0MB)
   free     = 199753728 (190.5MB)
   0.0% used
PS Old Generation
   capacity = 4194304000 (4000.0MB)
   used     = 4193795072 (3999.5146484375MB)
   free     = 508928 (0.4853515625MB)
   99.9878662109375% used
- 结合 **jmap -histo 21257** 如下 看出应该是业务在大量导出数据导致oom 
 num       #instances          #bytes      class name</br> 
   1:      18694429     1794665184  org.apache.xmlbeans.impl.store.Xobj$AttrXobj 
   2:      12262097     1177161312  org.apache.xmlbeans.impl.store.Xobj$ElementXobj 
   3:      18841022      641741264  [C
   4:      18862556      452701344  java.lang.String
   5:       6249347      249973880  java.util.TreeMap$Entry
   6:       6198572      247942880  org.apache.xmlbeans.impl.values.XmlUnsignedIntImpl
   7:       6061782      193977024  org.apache.poi.xssf.usermodel.XSSFCell
   8:       6061656      193972992  org.openxmlformats.schemas.spreadsheetml.x2006.main.impl.STCellRefImpl
  10:       6029665      192949280  org.openxmlformats.schemas.spreadsheetml.x2006.main.impl.STCellTypeImpl
  11:       6061782      145482768  org.openxmlformats.schemas.spreadsheetml.x2006.main.impl.CTCellImpl
  12:       7009050      112144800  java.lang.Integer

- dump文件太大8个多G，当时dump文件分析,其中审核导出的对象数有20多万。

![](/images/cpu/dump-thread.png)

## 查日志
通过内存分析，初步定位就是业务在大量导出数据导致oom，通过阿里云日志sls去证明业务有人在大量导出数据，通过日志查询，如下审核导出查询，时间范围是一年多

2019.11.12 11:20  查到对应日志如下：

![](/images/cpu/sls-log.png)

其中期间涉及大数据量导出主要有两个，一个是××导出×.web.work.ExportController#downLoadEStage，另一个是××导出×.web.work.ExportController#downloadAuditor

其中还有oom日志如下：

![](/images/cpu/oom-sls.png)

## 处理
2019.11.12 11:53  给运维相关导出流量打到××× heavy那台服务器，解决分流问题，运维配置nginx。

## 下午CPU又爆满
下午×××2服务器又出现了CPU爆满情况，排查发现上午分流配置根本没有生效。之前线上导出是有分流的（即导出单独打到一台服务器），**进一步排查是运维在Jenkins，前端项目Jenkins配置有问题**，导出相关没有打到对应的导出服务器上。联系运维配置好。彻底解决分流问题。


# 总结
## 运维层面
生产环境×××流量是有分流的，但运维在Quickbuild迁移到Jenkins中，×××前端项目Jenkins配置有问题，导致流量都打在×××1上。后续运维配置需要验证。

## 研发层面
模板导出换成其他方式导出，或者升级jxls的jar包，现在用的jar包太老，sql有优化地方，该优化。

## 产品层面
后续可以考虑业务系统逐渐屏蔽掉相关业务。


