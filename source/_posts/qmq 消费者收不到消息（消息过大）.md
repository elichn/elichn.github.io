---
title: qmq 消费者收不到消息（消息过大）
date: 2020-11-12 14:15:40
tags: mq
categories: mq
---
## 问题描述

导课是通过qmq异步处理然后http导入到私有化公司的。
<!--more-->
- 2020-11-10 15:58:08，客户成功给私有化公司美术宝导课，反馈没有导入成功，排查日志后生产者发送mq成功，消费者未收到消息，以为是qmq丢消息，继续观察（此时没有注意mq的消息体的大小，导课一次导入了30门课）
- 2020-11-11 10:06:41，客户成功反馈又导入了10门课，让我核对下是不是都导入成功的，经查询，消费者成功收到了消息，导课是成功的。纳闷为啥昨天丢消息了
- 2020-11-11 10:25:17，客户成功再次给私有化公司美术宝导课，让我核对下，总共导了42门课，发现没有导入成功，还是同一个原因，消费者没有收到消息。又复现了，应该不是qmq本身丢消息的问题，3次不可能丢2次，排查日志，结合客户成功导课的数量，猜测应该是消息过大导致的问题，先让客户成功，分批次导课，一次导入10门课，尝试。当天13:57-14：40，42门课分4次导入，成功，没有丢消息。业务正常，美术宝可以使用三节课提供的课程，可以使用学习功能。
- 2020-11-11 13:57-14：40，总共导课4次，均导课成功

## 问题定位

从表象看，已经很明显，就是一次导课的数量太多，一次mq的消息体太大，导致丢消息。学习支持私有化刚上线，为保证业务正常，让客户成功一次导课的数量控制下，控制在10门。

排查代码，代码中没有对消息过大做处理，代码如下：

```java
    Message message = producer.﻿generateMessage﻿(﻿CopyCourseToPrivatizationConst﻿.SUBJECT_CONST)﻿;
    message.﻿setProperty﻿(﻿CopyCourseToPrivatizationConst﻿.PROPERTY_KEYS_CONST, JSON.﻿toJSONString﻿(toPrivatizationDTO)﻿)﻿;
    message.﻿setMaxRetryNum﻿(﻿MQCommonConst﻿.MAX_RETRY_TIMES)﻿;
    producer.﻿sendMessage﻿(message, new MessageSendStateListener﻿(﻿) {
        @Override
        public void onSuccess﻿(﻿Message message) {
            log.﻿info﻿(﻿"导入课程到私有化公司发送qmq成功: [{}]"﻿, JSON.﻿toJSONString﻿(message)﻿)﻿;
        }
        @Override
        public void onFailed﻿(﻿Message message) {
            log.﻿error﻿(﻿"导入课程到私有化公司发送qmq失败:[{}]"﻿, JSON.﻿toJSONString﻿(message)﻿)﻿;
        }
    }﻿)﻿;
}
```

﻿
查询qmq官网已对这种情况做了[说明](https://github.com/qunarcorp/qmq/blob/master/docs/cn/producer.md)﻿

QMQ的Message.setProperty(key, value)如果value是字符串，**则value的大小默认不能超过32K**，如果你需要传输超大的字符串，请务必使用message.setLargeString(key, value)，这样你甚至可以传输十几兆的内容了，但是消费消息的时候也需要使用message.getLargeString(key)。

![](/images/mq/qmq-01.png)

﻿

查看qmq源码得到的结论一样：

![](/images/mq/qmq-02-code.png)
![](/images/mq/qmq-05.jpg)
**本质还是消息体超过32k，生产者发送消息就失败了**

## 问题修复

按提示当消息体大于32k（value长度大于8192），用message.setLargeString(key, value)，消费者则使用message.getLargeString(key)获取，该修改在下一个迭代上线，不影响业务。

![](/images/mq/qmq-03-producer.png)

﻿

![](/images/mq/qmq-04-consumer.png)


## 问题总结

在看其他项目中，用qmq的地方已经有对消息过大有做处理。其他同学应该遇到过这个坑。

qmq的Message.setProperty(key, value)，如果value是字符串，则value的大小默认不能超过32K，如果你需要传输超大的字符串，请务必使用message.setLargeString(key, value)，这样你甚至可以传输十几兆的内容了，但是消费消息

的时候也需要使用message.getLargeString(key)。


