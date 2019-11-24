---
title: ArrayList 记录
date: 2018-04-21 18:30:08
tags: java
categories: java
---

# 记在前面
注：源代码基于 Java 1.8。
ArrayList继承了AbstractList，实现了List接口。ArrayList在工作中经常用到，类图如下：
![](/images/java/collection/arraylist-url.png)
<!--more-->

# 动态扩容
如何做到动态扩容的？

## 构造方法
三种方式实现如下：
其中重要一点无参构造方法，延迟分配对象数组空间大小为10
```java
// 构造方法一：指定容量大小
public ArrayList(int initialCapacity) {
    if (initialCapacity > 0) {
        this.elementData = new Object[initialCapacity];
    } else if (initialCapacity == 0) {
        this.elementData = EMPTY_ELEMENTDATA;
    } else {
        throw new IllegalArgumentException("Illegal Capacity: "+
                                           initialCapacity);
    }
}

// 构造方法二：使用延迟分配对象数组空间，当第一次插入元素时才分配10（默认）个对象空间
public ArrayList() {
    this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
}

// 构造方法三：构造一个包含指定元素的list，这些元素的是按照Collection的迭代器返回的顺序排列的
public ArrayList(Collection<? extends E> c) {
    elementData = c.toArray();
    if ((size = elementData.length) != 0) {
        // c.toArray might (incorrectly) not return Object[] (see 6260652)
        if (elementData.getClass() != Object[].class)
            elementData = Arrays.copyOf(elementData, size, Object[].class);
    } else {
        // replace with empty array.
        this.elementData = EMPTY_ELEMENTDATA;
    }
}
```
## 动态扩容
``` java
private void grow(int minCapacity) {
    // 每次扩容增加原来的50%（即原容量的1.5倍）  
    int oldCapacity = elementData.length;
    int newCapacity = oldCapacity + (oldCapacity >> 1);
    if (newCapacity - minCapacity < 0)
        newCapacity = minCapacity;
    if (newCapacity - MAX_ARRAY_SIZE > 0)
        newCapacity = hugeCapacity(minCapacity);
    // 调用Arrays.copyOf静态方法, 本质是调用System.arraycopy静态方法
    elementData = Arrays.copyOf(elementData, newCapacity);
}
```
动态扩容有利于资源的合理利用。

# 线程不安全
比如add方法
``` java
public boolean add(E e) {
    ensureCapacityInternal(size + 1);  // Increments modCount!!
    elementData[size++] = e;           // 此操作不是原子操作
    return true;
}
```
elementData[size++] = e，不是原子操作，当多线程添加的情况下，假如size=0时，添加第一个元素的线程添加成功，同时在size没有及时写到内存中时，这时另一个线程继续添加就覆盖了原来的值，要保证线程安全，可以如下使用：
``` java
// 本质是给ArrayList的每个方法加synchronized关键字，利用Object来上锁
Collections.synchronizedList(new ArrayList<>());
```

# Arraylist与LinkedList异同
* 是否保证线程安全：ArrayList和 LinkedList都是不同步的，也就是不保证线程安全；
* 底层数据结构：Arraylist 底层使用的是Object数组。LinkedList底层使用的是双向循环链表数据结构；
* 插入和删除是否受元素位置的影响：① ArrayList采用数组存储，所以插入和删除元素的时间复杂度受元素位置的影响。 比如：执行add(E e)方法的时候，ArrayList会默认在将指定的元素追加到此列表的末尾，这种情况时间复杂度就是O(1)。但是如果要在指定位置i插入和删除元素的话（add(int index, E element)）时间复杂度就为 O(n-i)。因为在进行上述操作的时候集合中第i和第i个元素之后的(n-i)个元素都要执行向后位/向前移一位的操作。② LinkedList采用链表存储，所以插入，删除元素时间复杂度不受元素位置的影响，都是近似 O（1）而数组为近似 O（n）；
* 内存空间占用：ArrayList的空 间浪费主要体现在在list列表的结尾会预留一定的容量空间，而LinkedList的空间花费则体现在它的每一个元素都需要消耗比ArrayList更多的空间（因为要存放直接后继和直接前驱以及数据）。
* 是否支持快速随机访问：LinkedList不支持高效的随机元素访问，而ArrayList支持。快速随机访问就是通过元素的序号快速获取元素对象(对应于get(int index)方法)；
* 实现了RandomAccess接口的ArrayList遍历优先使用for循环，未实现RadmoAcces接口优先使用foreach（底层也是通过iterator实现的）。


# 总结
* ArrayList底层是基于数组来实现的，因此在get的时候效率高，而remove的时候，效率低（后面的元素都涉及移动）；
* 调用默认的ArrayList无参构造方法的话，数组的初始容量为10 ,其实是延迟分配对象；
* ArrayList会自动扩容，扩容的时候，会将容量扩至原来的1.5倍；
* ArrayList不是线程安全的
