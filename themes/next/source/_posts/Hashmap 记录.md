---
title: Hashmap 记录
date: 2018-07-29 09:25:43
tags: java
categories: java
---

# 记在前面
注：源代码基于 Java 1.8。
Hashmap继承了AbstractMap，实现了Map接口。Hashmap在工作中经常用到，类图如下：
![](/images/hashmap-uml.png)
<!--more-->

# put方法
put过程如图：![](/images/hashmap-put.png)
①.判断键值对数组table[i]是否为空或为null，否则执行resize()进行扩容；
②.根据键值key计算hash值得到插入的数组索引i，如果table[i]==null，直接新建节点添加，转向⑥，如果table[i]不为空，转向③；
③.判断\table[i]的首个元素是否和key一样，如果相同直接覆盖value，否则转向④，这里的相同指的是hashCode以及equals；
④.判断table[i] 是否为treeNode，即table[i] 是否是红黑树，如果是红黑树，则直接在树中插入键值对，否则转向⑤；
⑤.遍历table[i]，判断链表长度是否大于8，大于8的话把链表转换为红黑树，在红黑树中执行插入操作，否则进行链表的插入操作；\遍历过程中若发现key已经存在直接覆盖value即可；
⑥.插入成功后，判断实际存在的键值对数量size是否超多了最大容量threshold，如果超过，进行扩容。

# 1.7和1.8有哪些区别
* JDK1.7用的是头插法，而JDK1.8及之后使用的都是尾插法。原因，JDK1.7是用单链表进行的纵向延伸，当采用头插法就是能够提高插入的效率，新插入的元素总是在链表的头部；JDK1.8之后是因为加入了红黑树使用尾插法，能够避免出现逆序且链表死循环的问题。
* 扩容后数据存储位置的计算方式也不一样
* JDK1.7的时候使用的是数组+ 单链表的数据结构。但是在JDK1.8及之后时，使用的是数组+链表+红黑树的数据结构（当链表的深度达到8的时候，也就是默认阈值，就会自动扩容把链表转成红黑树的数据结构来把时间复杂度从O（n）变成O（nlogN）提高了效率）

# 常规问题
## keySet
HashMap的操作中，直接使用keySet()遍历有什么问题？
keySet()遍历更慢，entrySet 会更快，直接遍历iterator所以对象，取出value。keySet()会多一次遍历，先遍历iterator所以对象，后面再多一步操作hashmap.get(), 第二次遍历只是针对一个bucket的遍历，可以理解在hash碰撞不多的情况下性能并不会有大影响。
直接输出keySet时，其实keySet继承自AbstractSet，而AbstractSet又继承自AbstractCollection，bstractCollection又重写了Object类的toString()方法，会用iterator。因此在输出时调用了AbstractCollection.java类中的toString方法，重写的toString()方法又调用了iterator，从而迭代取出结果拼接成字符串。
## key能否为null
key可以为空，因为当key为空时，hash指默认为0，只能有一个key为null
```java
static final int hash(Object key) {
    int h;
    return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
}
```
## 两个key的hashcode相同，如何获取对象
当我们调用get()方法，HashMap会使用键对象的hashcode找到bucket位置，找到bucket位置之后，会调用keys.equals()方法去找到链表中正确的节点，最终找到要找的值对象。