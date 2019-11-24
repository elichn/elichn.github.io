---
title: Java8 Lambda 表达式
date: 2019-03-10 20:48:08
tags: java
categories: java
---

# 记在前面
使用Java8已有一段时间，工作中会用到Lambda 表达式，给人的直观感受是代码更加清晰简洁。在此做个记录。
<!--more-->

# 概念

## Lambda 表达式
Lambda表达式可以理解为一种匿名函数：它没有名称，但有参数列表、函数主体、返回类型，可能还有一个可以抛出的异常的列表。基本语法如下：

(参数列表 parameters) -> 表达式 expression)   或者

(参数列表 parameters) -> { 语句 statements;  }

## 函数式接口

函数式接口就是仅仅声明了一个抽象方法的接口。

## 方法引用

::方法引用基本思想是：如果一个Lambda代表的只是直接调用这个方法，那最好还是用名称来调用它，而不是去描述如何调用它。

可以看做式仅仅调用特定方法的Lambda的一种快捷写法。可以看作是针对仅仅涉及单一方法的Lambda的**语法糖**，因为你表达同样的事情时要写的代码更少了。

eg：Apple::getWeight  就是  (Apple a) -> a.getWeight() 的快捷写法。

## 类型推断

Java编译器会从上下文推断出用什么函数式接口来配合Lambda表达式。意味着Lambda语法中可以省去标注参数类型。

**注意：**有时候显式写出类型更易读，有时候去掉他们更易读。没有什么法则说哪种更好，对于如何让代码更易读，我们必须做出自己的选择。

## 流

流允许以声明性方式处理数据集合。你只需要表达你需要什么。而不是像传统那样关心如何实现。

# 使用

## list转map
```java
// 查询获取list
List<BankQueryStat> waitList = bankQueryStatDao.queryWaitStatInfo(statDate);
// list转map
Map<Long, BankQueryStat> waitMap = waitList.stream()
    .collect(Collectors.toMap(BankQueryStat::getBankOperatorId, Function.identity()));
```
## 列表中是否包含
``` java
// 列表中是否包含QAV资料
boolean isUploadQAV = videoList != null && videoList.stream()
	.anyMatch(m -> StringUtils.equals(m.getCode(), QAV));
```
## 列表中过移除掉元素

```java
// 列表中移除QAV资料
List<String> codeList = codeList.stream()
	.filter(m -> !StringUtils.equals(m, QAV)).collect(Collectors.toList());
```

## 列表单列求和

```java
// 查询获取列表
List<VideoStatVo> statList = cloudroomStatusStatDao.queryList(queryVo);
VideoStatVo totalVo = new VideoStatVo();
if (!statList.isEmpty()) {
    // 对statList单列totalNum求和
	totalVo.setTotalNum(statList.stream().mapToLong(VideoStatVo::getTotalNum).sum());  
}
```