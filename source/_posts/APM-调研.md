---
title: APM-调研
date: 2019-09-20 10:22:46
tags: apm
categories: apm
---

# 记在前面      
应用性能管理（Application Performance Management）是一个比较新的应用管理方向<!--more-->，主要指对企业的关键业务应用进行全方位监控、告警，提高企业应用的可靠性和质量，保证用户得到良好的服务，降低整体运维成本。

## 作用
- 应用系统存活检测
- 应用程序性能指标检测（CPU利用率、内存利用率等）
- 应用程序关键事件检测
- 检测数据持久化存储并能够多维度查询
- 服务调用跟踪
- 监控告警

# 选型方案

方案 | 名称 | 介绍 | 备注
---|----|----|---
方案一 | Spring Boot Admin | Spring Boot Admin 用于监控基于 Spring Boot 的应用，它是在 Spring Boot Actuator 的基础上提供简洁的可视化 WEB UI。 | 无
方案二 | SkyWalking | SkyWalking 是观察性分析平台和应用性能管理系统。提供分布式追踪、服务网格遥测分析、度量聚合和可视化一体化解决方案。 | 无
方案三	| Pinpoint |Pinpoint是一个开源的APM(应用程序性能管理)工具，用于用Java编写的大型分布式系统。 | 搭建、维护困难
方案四	| CAT | CAT基于Java开发的实时监控平台，主要包括移动端监控，应用侧监控，核心网络层监控，系统层监控等。 | 由于对代码入侵较高，接入困难，暂时废弃

# 方案对比

## 功能对比
功能 | Spring Boot Admin | SkyWalking | Pinpoint
---|----|----|---
数据持久化 | 不支持 | 支持（包括历史数据检索）| 支持（包括历史数据检索）
JVM信息	| 支持 | 支持 | 支持
线程信息 | 支持 | 不支持 | 支持
GC信息 | 支持 | 支持 | 支持
API调用信息 | 支持（较详细） | 支持 | 支持（较详细）
TOP指标 | 不支持 | TOP耗时 | TOP耗时
接口成功率 | 不支持 | 支持 | 支持
告警 | 支持 | 支持 | 支持
链路追踪 | 不支持 | 支持 | 支持
Dashboard | 较简单 | 较丰富 | 较丰富


## 非功能对比
功能 | Spring Boot Admin | SkyWalking | Pinpoint
---|----|----|---
高并发下对性能影响 |  | 小 | 大
代码侵入 | 低 | 无 | 无
接入难度 | 简单 | 简单 | 简单
搭建难度 | 简单 | 较复杂（可使用ES、MySQL、H2等） | 复杂（只能使用HBase）

### 接入方式

①. Spring Boot Admin需在应用添加相应依赖（依赖版本和Spring Boot版本对应）及设置相应配置项，示例如下：<br>

```
<dependency>
    <groupId>de.codecentric</groupId>
    <artifactId>spring-boot-admin-starter-client</artifactId>
    <version>2.1.6</version>
</dependency>
```


```
spring:
  application:
    name: admin-client
  boot:
    admin:
      client:
        url: http://localhost:8769
        #username: admin
        #password: 123456
server:
  port: 8768
 
management:
  endpoints:
    web:
      exposure:
        include: '*'
  endpoint:
    health:
      show-details: ALWAYS
```


②.Skywalking需打包相应agent包，并设置启动参数，示例如下：<br>

```
# 设置Skywalking agent路径
-javaagent:D:\works\codes\agent\skywalking-agent.jar
# Skywalking UI上展示名字
-Dskywalking.agent.service_name=apm-client-demo
# Skywalking 服务器地址
-Dskywalking.collector.backend_service=192.168.77.128:11800
```

## 体验总结

**Spring Boot Admin：**

- 不支持数据持久化（也就不支持历史数据查看）
-  httptrace默认只保存最近100次请求数据
- 不支持指标Top展示
- API错误率指标没有直观展示出来
- 应用接入会增加相关依赖
- 能监控线程信息
- 能查看Bean信息
- 能下载Heap Dump

**SkyWalking：**

- 搭建、维护难度较大
- 稳定程度有待提高
- 能显示可用性（成功率）
- 能监控到DB连接信息
- 能显示TOP耗时请求
- 能显示整个系统调用拓扑图
- 告警可以在服务端进行配置


**Pinpoint：**

- 搭建、维护难度大（依赖HBase）

## 展示

Spring Boot Admin-实例信息：
![](/images/apm/apm-01-01.png)

Skywalking-实例信息：
![](/images/apm/apm-01-02.png)

Spring Boot Admin-接口信息：
![](/images/apm/apm-01-03.png)

Skywalking-Trace信息：
![](/images/apm/apm-01-04.png)

Skywalking-拓扑图：
![](/images/apm/apm-01-05.png)

