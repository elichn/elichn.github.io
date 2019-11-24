---
title: Java线程池 记录
date: 2018-05-26 13:28:09
tags: java
categories: java
---

# 记在前面
注：源代码基于 Java 1.8。
ThreadPoolExecutor继承了AbstractExecutorService，实现了ExecutorService接口，而ExecutorService接口继承了Executor接口。类图如下：
![](/images/ThreadPoolExecutor-url.png)
<!--more-->

# 线程池
线程池利用的是池化思想，线程放在这个池子中进行重复利用，能够减去了线程的创建和销毁所带来的代价（时间和资源）。

# 线程池的作用
* 复用线程
* 管理线程
* 控制最大并发数（降低资源消耗、提高响应速度）

# ThreadPoolExecutor
ThreadPoolExecutor是线程池的具体实现类，一般所有的线程池都是基于这个类实现的。
```java
// 构造方法
public ThreadPoolExecutor(int corePoolSize,
                          int maximumPoolSize,
                          long keepAliveTime,
                          TimeUnit unit,
                          BlockingQueue<Runnable> workQueue) {
    this(corePoolSize, maximumPoolSize, keepAliveTime, unit, workQueue,
         Executors.defaultThreadFactory(), defaultHandler);
}
```
* corePoolSize：线程池核心线程数量
* maximumPoolSize：线程池允许最大线程数量
* keepAliverTime：当活跃线程数大于核心线程数时，空闲的多余线程最大存活时间
* unit：存活时间的单位，一个枚举
* workQueue：存放任务的阻塞队列
* threadFactory：创建线程的工厂
* handler：超出线程范围和队列容量的任务的处理策略

ThreadPoolExecutor中，有两个重要的成员变量：workQueue和workers
```java
// 存放任务的队列
private final BlockingQueue<Runnable> workQueue;
// 工作线程
private final HashSet<Worker> workers = new HashSet<Worker>();
```
# 常见的Java线程池
生成线程池使用的是Executors类对应的工厂方法，以下是常见的Java线程池：
## FixedThreadPool
FixedThreadPool是固定数量的线程池，只有核心线程。每提交一个任务就是一个线程，直到达到线程池的最大核心数量，然后后面进入等待队列，直到前面的任务完成才继续执行。线程池的大小一旦达到最大值就会保持不变，如果某个线程因为执行异常而结束，那么线程池会补充一个新线程。
```java
// corePoolSize等于maximumPoolSize，实现固定线程数量
public static ExecutorService newFixedThreadPool(int nThreads) {
    return new ThreadPoolExecutor(nThreads, nThreads,
                                  0L, TimeUnit.MILLISECONDS,
                                  new LinkedBlockingQueue<Runnable>());
}
```
## SingleThreadExecutor
SingleThreadExecutor是数量为1的线程池。线程池中每次只有一个线程在运行，单线程串行执行任务。如果这个唯一的线程因为异常结束，那么会有一个新的线程来替代它。
```java
// corePoolSize等于maximumPoolSize等于1，实现线程数量永远为1
public static ExecutorService newSingleThreadExecutor() {
    return new FinalizableDelegatedExecutorService
        (new ThreadPoolExecutor(1, 1,
                                0L, TimeUnit.MILLISECONDS,
                                new LinkedBlockingQueue<Runnable>()));
}
```
## CachedThreadPool
CachedThreadPool是可缓存线程的线程池。如果线程池的大小超过了处理任务所需要的线程，那么就会回收部分空闲（60秒不执行任务）的线程。当任务数增加时，此线程池又可以智能的添加新线程来处理任务。此线程池不会对线程池大小做限制，线程池大小完全依赖于操作系统（或者说JVM）能够创建的最大线程大小。其中，SynchronousQueue是一个是缓冲区为1的阻塞队列。
```java
public static ExecutorService newCachedThreadPool() {
    return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
                                  60L, TimeUnit.SECONDS,
                                  new SynchronousQueue<Runnable>());
}
```
## ScheduledThreadPool
ScheduledThreadPool是核心线程数固定，大小无限制的线程池，支持定时和周期性的执行线程。创建一个周期性执行任务的线程池。
```java
// 调用ScheduledThreadPoolExecutor，ScheduledThreadPoolExecutor调用ThreadPoolExecutor
public static ExecutorService newScheduledThreadPool(int corePoolSize) {
    // 直接跳过ScheduledThreadPoolExecutor构造方法
    return new ThreadPoolExecutor(corePoolSize, Integer.MAX_VALUE,
                              0L, NANOSECONDS,
                              new DelayedWorkQueue());
}
```

# 线程池工作流程
1. 线程池刚创建时，里面没有一个线程；
2. 当添加一个任务（调用execute()）方法时，线程池会做如下判断：
3. 如果正在运行的线程数量小于corePoolSize，那么马上创建线程运行这个任务；
4. 如果正在运行的线程数量大于或等于corePoolSize，那么将这个任务放入队列；
5. 如果这时候队列满了，而且正在运行的线程数量小于maximumPoolSize，那么还是要创建非核心线程立刻运行这个任务；
6. 如果队列满了，而且正在运行的线程数量大于或等于maximumPoolSize，那么线程池会抛出异常RejectExecutionException；
7. 当一个线程完成任务时，它会从队列中取下一个任务来执行；
8. 当一个线程无事可做，超过一定的时间（keepAliveTime）时，线程池会判断，如果当前运行的线程数大于corePoolSize，那么这个线程就被停掉。所以线程池的所有任务完成后，它最终会收缩到 corePoolSize 的大小。

# 运用
## 提交
创建线程池通过Executors的工厂方法，执行任务有两种方式execute和submit来提交一个任务到线程池中，如下：
* execute
```java
ExecutorService.execute(Runnable command);
```
* submit
```java
// 本质还是调用execute
Future<T> futureTask = ExecutorService.submit(Callable<T> task);	
Future futureTask = ExecutorService.submit(Runnable task);
Future<T> futureTask = ExecutorService.submit(Runnable task, T Result);
```
## execute()
所以核心的逻辑就是execute()方法了，如下：
```java
public void execute(Runnable command) {
    if (command == null)
        throw new NullPointerException();
	// 获取当前线程数
	int c = ctl.get();
	// 当前线程数量小于coreSize 时
	if (workerCountOf(c) < corePoolSize) {
		// 直接启动新的线程
		if (addWorker(command, true))
			return;
		c = ctl.get();
	}
	// 当前线程数量大于等 coreSize 时
	// runState为RUNNING && 队列未满
	if (isRunning(c) && workQueue.offer(command)) {
		int recheck = ctl.get();
		// 再次检验是否为RUNNING状态
		// 非RUNNING状态 则从workQueue中移除任务并拒绝
		if (! isRunning(recheck) && remove(command))
			reject(command);
		// 防止了SHUTDOWN状态下没有活动线程了，但是队列里还有任务没执行这种特殊情况。
		// 添加一个null任务是因为SHUTDOWN状态下，线程池不再接受新任务
		else if (workerCountOf(recheck) == 0)
			addWorker(null, false);
	}
	// 如果队列满了或者是非运行的任务都拒绝执行
	else if (!addWorker(command, false))
		reject(command);
}
```
## Worker
Worker类，Worker 实现了Runnable接口，当Thread的start()方法得到调用时，执行的其实是Worker的run()方法，即runWorker()方法。runWorker()方法之中有一个 while 循环，使用getTask()来获取任务，并执行。getTask()是从 workQueue中获取的

## runWorker()
```java
final void runWorker(Worker w) {
    Thread wt = Thread.currentThread();
    Runnable task = w.firstTask;
    w.firstTask = null;
    w.unlock(); // allow interrupts
    boolean completedAbruptly = true;
    try {
	    // 
        while (task != null || (task = getTask()) != null) {
            w.lock();
            // If pool is stopping, ensure thread is interrupted;
            // if not, ensure thread is not interrupted.  This
            // requires a recheck in second case to deal with
            // shutdownNow race while clearing interrupt
            if ((runStateAtLeast(ctl.get(), STOP) ||
                 (Thread.interrupted() &&
                  runStateAtLeast(ctl.get(), STOP))) &&
                !wt.isInterrupted())
                wt.interrupt();
            try {
                beforeExecute(wt, task);
                Throwable thrown = null;
                try {
                    task.run();
                } catch (RuntimeException x) {
                    thrown = x; throw x;
                } catch (Error x) {
                    thrown = x; throw x;
                } catch (Throwable x) {
                    thrown = x; throw new Error(x);
                } finally {
                    afterExecute(task, thrown);
                }
            } finally {
                task = null;
                w.completedTasks++;
                w.unlock();
            }
        }
        completedAbruptly = false;
    } finally {
        processWorkerExit(w, completedAbruptly);
    }
}
```
## getTask()
```java
// 是从 workQueue中获取的
private Runnable getTask() {
    boolean timedOut = false; // Did the last poll() time out?

    for (;;) {
        int c = ctl.get();
        int rs = runStateOf(c);

        // Check if queue empty only if necessary.
        if (rs >= SHUTDOWN && (rs >= STOP || workQueue.isEmpty())) {
            decrementWorkerCount();
            return null;
        }

        int wc = workerCountOf(c);

        // Are workers subject to culling?
        boolean timed = allowCoreThreadTimeOut || wc > corePoolSize;

        if ((wc > maximumPoolSize || (timed && timedOut))
            && (wc > 1 || workQueue.isEmpty())) {
            if (compareAndDecrementWorkerCount(c))
                return null;
            continue;
        }

        try {
            Runnable r = timed ?
                workQueue.poll(keepAliveTime, TimeUnit.NANOSECONDS) :
                workQueue.take();
            if (r != null)
                return r;
            timedOut = true;
        } catch (InterruptedException retry) {
            timedOut = false;
        }
    }
}
```
# 拒绝策略
当线程池的任务缓存队列已满并且线程池中的线程数目达到maximumPoolSize，如果还有任务提交就会采取任务拒绝策略，有以下四种策略：
* AbortPolicy：抛RejectedExecutionException异常，默认的拒绝策略
* DiscardPolicy：直接丢弃，但是不抛出异常
* DiscardOldestPolicy：丢弃队列最前面的任务，然后重新尝试执行任务（重复此过程）
* CallerRunsPolicy：由调用线程处理该任务
```java
ThreadPoolExecutor.AbortPolicy：抛RejectedExecutionException异常
ThreadPoolExecutor.DiscardPolicy：直接丢弃，但是不抛出异常
ThreadPoolExecutor.DiscardOldestPolicy：丢弃队列最前面的任务，然后重新尝试执行任务
ThreadPoolExecutor.CallerRunsPolicy：由调用线程处理该任务
```