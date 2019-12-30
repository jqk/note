# 雪花算法及优化与自定义

## 一、算法描述

![snowflake结构](snowflake.jpg)

1. 最高位是符号位，始终为0，不可用。
1. 41位的时间序列，精确到毫秒级，41位的长度可以使用69年。时间位还有一个很重要的作用是可以根据时间进行排序。
1. 10位的机器标识，10位的长度最多支持部署1024个节点。
1. 12位的计数序列号，序列号即一系列的自增id，可以支持同一节点同一毫秒生成多个ID序号，12位的计数序列号支持每个节点每毫秒产生4096个ID序号。

## 二、源码

### 2.1 C-Sharp

```C#
using System;

namespace System
{
    /// <summary>
    /// 分布式ID算法（雪花算法）
    /// </summary>
    public class Snowflake
    {
        private static long machineId;          // 机器ID
        private static long datacenterId = 0L;  // 数据ID
        private static long sequence = 0L;      // 计数从零开始
        private static long twepoch = 687888001020L; // 唯一时间随机量
        private static long machineIdBits = 5L;     // 机器码字节数
        private static long datacenterIdBits = 5L;  // 数据字节数

        public static long maxMachineId = -1L ^ -1L << (int)machineIdBits;          // 最大机器ID

        private static long maxDatacenterId = -1L ^ (-1L << (int)datacenterIdBits); // 最大数据ID
        private static long sequenceBits = 12L;                                     // 计数器字节数，12个字节用来保存计数码
        private static long machineIdShift = sequenceBits;                          // 机器码数据左移位数，就是后面计数器占用的位数
        private static long datacenterIdShift = sequenceBits + machineIdBits;
        // 时间戳左移动位数就是机器码+计数器总字节数+数据字节数
        private static long timestampLeftShift = sequenceBits + machineIdBits + datacenterIdBits;
        // 一微秒内可以产生计数，如果达到该值则等到下一微妙在进行生成
        public static long sequenceMask = -1L ^ -1L << (int)sequenceBits;
        private static long lastTimestamp = -1L;        // 最后时间戳

        private static object syncRoot = new object();  // 加锁对象
        static Snowflake snowflake;

        public static Snowflake Instance()
        {
            if (snowflake == null)
                snowflake = new Snowflake();
            return snowflake;
        }

        public Snowflake()
        {
            Snowflakes(0L, -1);
        }

        public Snowflake(long machineId)
        {
            Snowflakes(machineId, -1);
        }

        public Snowflake(long machineId, long datacenterId)
        {
            Snowflakes(machineId, datacenterId);
        }

        private void Snowflakes(long machineId, long datacenterId)
        {
            if (machineId >= 0)
            {
                if (machineId > maxMachineId)
                {
                    throw new Exception("机器码ID非法");
                }
                Snowflake.machineId = machineId;
            }
            if (datacenterId >= 0)
            {
                if (datacenterId > maxDatacenterId)
                {
                    throw new Exception("数据中心ID非法");
                }
                Snowflake.datacenterId = datacenterId;
            }
        }

        /// <summary>
        /// 生成当前时间戳
        /// </summary>
        /// <returns>毫秒</returns>
        private static long GetTimestamp()
        {
            return (long)(DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc)).TotalMilliseconds;
        }

        /// <summary>
        /// 获取下一微秒时间戳
        /// </summary>
        /// <param name="lastTimestamp"></param>
        /// <returns></returns>
        private static long GetNextTimestamp(long lastTimestamp)
        {
            long timestamp = GetTimestamp();
            if (timestamp <= lastTimestamp)
            {
                timestamp = GetTimestamp();
            }
            return timestamp;
        }

        /// <summary>
        /// 获取长整型的ID
        /// </summary>
        /// <returns></returns>
        public long GetId()
        {
            lock (syncRoot)
            {
                long timestamp = GetTimestamp();
                if (Snowflake.lastTimestamp == timestamp)
                {   // 同一微妙中生成ID
                    // 用&运算计算该微秒内产生的计数是否已经到达上限
                    sequence = (sequence + 1) & sequenceMask;
                    if (sequence == 0)
                    {
                        // 一微妙内产生的ID计数已达上限，等待下一微妙
                        timestamp = GetNextTimestamp(lastTimestamp);
                    }
                }
                else
                {
                    // 不同微秒生成ID
                    sequence = 0L;
                }
                if (timestamp < lastTimestamp)
                {
                    throw new Exception("时间戳比上一次生成ID时时间戳还小，故异常");
                }
                Snowflake.lastTimestamp = timestamp;    // 把当前时间戳保存为最后生成ID的时间戳
                long Id = ((timestamp - twepoch) << (int)timestampLeftShift)
                    | (datacenterId << (int)datacenterIdShift)
                    | (machineId << (int)machineIdShift)
                    | sequence;
                return Id;
            }
        }
    }
}
```

### 2.2 golang

```go
package snowflake
// twitter 雪花算法
// 把时间戳,工作机器ID, 序列号组合成一个 64位 int
// 第一位置零, [2,42]这41位存放时间戳,[43,52]这10位存放机器id,[53,64]最后12位存放序列号

import "time"
var (
    machineID    int64 // 机器 id 占10位, 十进制范围是 [ 0, 1023 ]
    sn            int64 // 序列号占 12 位,十进制范围是 [ 0, 4095 ]
    lastTimeStamp int64 // 上次的时间戳(毫秒级), 1秒=1000毫秒, 1毫秒=1000微秒,1微秒=1000纳秒
)

func init() {
    lastTimeStamp = time.Now().UnixNano() / 1000000
}

func SetMachineId(mid int64) {
    // 把机器 id 左移 12 位,让出 12 位空间给序列号使用
    machineID = mid << 12
}

func GetSnowflakeId() int64 {
    curTimeStamp := time.Now().UnixNano() / 1000000
    // 同一毫秒
    if curTimeStamp == lastTimeStamp {
        sn++
        // 序列号占 12 位,十进制范围是 [ 0, 4095 ]
        if sn > 4095 {
            time.Sleep(time.Millisecond)
            curTimeStamp = time.Now().UnixNano() / 1000000
            lastTimeStamp = curTimeStamp
            sn = 0
        }

        // 取 64 位的二进制数 0000000000 0000000000 0000000000 0001111111111 1111111111 1111111111  1
        // ( 这里共 41 个 1 )和时间戳进行并操作
        // 并结果( 右数 )第 42 位必然是 0,  低 41 位也就是时间戳的低 41 位
        rightBinValue := curTimeStamp & 0x1FFFFFFFFFF
        // 机器 id 占用10位空间,序列号占用12位空间,所以左移 22 位; 经过上面的并操作,左移后的第 1 位,必然是 0
        rightBinValue <<= 22
        id := rightBinValue | machineID | sn
        return id
    }
    if curTimeStamp > lastTimeStamp {
        sn = 0
        lastTimeStamp = curTimeStamp
        // 取 64 位的二进制数 0000000000 0000000000 0000000000 0001111111111 1111111111 1111111111  1
        // ( 这里共 41 个 1 )和时间戳进行并操作
        // 并结果( 右数 )第 42 位必然是 0,  低 41 位也就是时间戳的低 41 位
        rightBinValue := curTimeStamp & 0x1FFFFFFFFFF
        // 机器 id 占用10位空间,序列号占用12位空间,所以左移 22 位; 经过上面的并操作,左移后的第 1 位,必然是 0
        rightBinValue <<= 22
        id := rightBinValue | machineID | sn
        return id
    }
    if curTimeStamp < lastTimeStamp {
        return 0
    }
    return 0
}
```

### 2.3 java

```java
/**
 * Twitter的分布式自增ID雪花算法snowflake
 * @author MENG
 * @create 2018-08-23 10:21
 **/
public class SnowFlake {

    /**
     * 起始的时间戳
     */
    private final static long START_STMP = 1480166465631L;

    /**
     * 每一部分占用的位数
     */
    private final static long SEQUENCE_BIT = 12;    // 序列号占用的位数
    private final static long MACHINE_BIT = 5;      // 机器标识占用的位数
    private final static long DATACENTER_BIT = 5;   // 数据中心占用的位数

    /**
     * 每一部分的最大值
     */
    private final static long MAX_DATACENTER_NUM = -1L ^ (-1L << DATACENTER_BIT);
    private final static long MAX_MACHINE_NUM = -1L ^ (-1L << MACHINE_BIT);
    private final static long MAX_SEQUENCE = -1L ^ (-1L << SEQUENCE_BIT);

    /**
     * 每一部分向左的位移
     */
    private final static long MACHINE_LEFT = SEQUENCE_BIT;
    private final static long DATACENTER_LEFT = SEQUENCE_BIT + MACHINE_BIT;
    private final static long TIMESTMP_LEFT = DATACENTER_LEFT + DATACENTER_BIT;

    private long datacenterId;      // 数据中心
    private long machineId;         // 机器标识
    private long sequence = 0L;     // 序列号
    private long lastStmp = -1L;    // 上一次时间戳

    public SnowFlake(long datacenterId, long machineId) {
        if (datacenterId > MAX_DATACENTER_NUM || datacenterId < 0) {
            throw new IllegalArgumentException(
                "datacenterId can't be greater than MAX_DATACENTER_NUM or less than 0");
        }
        if (machineId > MAX_MACHINE_NUM || machineId < 0) {
            throw new IllegalArgumentException(
                "machineId can't be greater than MAX_MACHINE_NUM or less than 0");
        }
        this.datacenterId = datacenterId;
        this.machineId = machineId;
    }

    /**
     * 产生下一个ID
     *
     * @return
     */
    public synchronized long nextId() {
        long currStmp = getNewstmp();
        if (currStmp < lastStmp) {
            throw new RuntimeException("Clock moved backwards.  Refusing to generate id");
        }

        if (currStmp == lastStmp) {
            // 相同毫秒内，序列号自增
            sequence = (sequence + 1) & MAX_SEQUENCE;
            // 同一毫秒的序列数已经达到最大
            if (sequence == 0L) {
                currStmp = getNextMill();
            }
        } else {
            // 不同毫秒内，序列号置为0
            sequence = 0L;
        }

        lastStmp = currStmp;

        return (currStmp - START_STMP) << TIMESTMP_LEFT // 时间戳部分
                | datacenterId << DATACENTER_LEFT       // 数据中心部分
                | machineId << MACHINE_LEFT             // 机器标识部分
                | sequence;                             // 序列号部分
    }

    private long getNextMill() {
        long mill = getNewstmp();
        while (mill <= lastStmp) {
            mill = getNewstmp();
        }
        return mill;
    }

    private long getNewstmp() {
        return System.currentTimeMillis();
    }

    public static void main(String[] args) {
        SnowFlake snowFlake = new SnowFlake(1, 1);

        long start = System.currentTimeMillis();
        for (int i = 0; i < 1000000; i++) {
            System.out.println(snowFlake.nextId());
        }

        System.out.println(System.currentTimeMillis() - start);
    }
}
```

## 三、算法优化及自定义

### 3.1 标准算法之不足

标准雪花算法未考虑以下因素：

1. 多线程
1. 时间经NTP等同步后向回调整
1. 机器标识的定义
1. 计数序号的数量

一个典型的应用场景是：有多台主机，每一台主机上，同一个程序需启动多个实例（进程）。每一个进程会使用多个线程同时工作。这些工作均需生成唯一ID。需要同时考虑系统对时服务可能将本地时间向回调整的情况。

### 3.2 自定义算法

#### 3.2.1 时间

* UNIX时间截以1970年1月1日0分0秒为0，即`时间基准`。UNIX时间截以当前时间与`时间基准`相差的秒数表示当前时间。
* 与这个思路相同，可以预设系统真正启用之前的某一时间点为`时间基准`。当前时间以与该`时间基准`相差的`时间单位`数量表示。
* `时间单位`可以是`日`、`时`、`分`、`秒`、`毫秒`等，按具体的需求定义。建议使用`秒`或`毫秒`。

通过这种方式，可以使用更少的bit表示时间。一个系统不可能永远运行，因此不必考虑运行期过长，20至30年足够。

以`秒`为例，以2020年1月1日0时0分0秒为`基准时间`，10年后的时间（为计算简单，不考虑润年，后同）为`86400 * 365 * 10 = 315360000`。以16进制表示为`12CC0300`，2进制是29位。29位2进制填满后是`1FFFFFFF`，对应6213天，相当于17年。若系统最多只运行17年而不改ID算法（大多数系统将在运行后反复升级，甚至替换掉，都可以修改生成唯一键的规则），则时间位长度，从`41`位，变为了`29`位。如果不考虑符号位，则是从`42`位变为`29`位。节省出来的`12`或`13`位可用于机器标识及计数序号。

#### 3.2.2 机器标识/进行标识

标准算法中的`机器标识`在自定义算法中应称为`进程标识`。即区分所有机器上运行的不同进程。
`进程标识`应在区分不同进程，并比较清晰表达身份的前提下，尽可能短。标准雪花算法使用`10`位，建议不超过`16`位。

#### 3.2.3 计数序号

因为不同的进程（即使在同一主机上运行）已通过`进程标识`区分，所以唯一ID只与时间及`计数序号`相关。因此，对`计数序号`有如下要求：

1. 可用范围越大越好。
1. 时间单位切换后，计数序号不复位至0，而是直到到达上边界，才进行复位。
1. 必须保证多线程安全。

多线程安全不必多说。前两点是对于时间同步后，系统时间向回调整而不产生重复ID的最大保障，虽然理论上不能完全去除重复。
同一进程，每一时间单位内产生的ID数量越少，`计数序号`范围越大，发生重复的可能性越小。

假设`时间单位`为`秒`，每时间单位内的平均ID生成数量为`1千`，`计数序号`可用范围`1百万`（20位），则只有当时钟被恰巧回调`1000`秒时才有可能重复，而且不一定必然重复。

### 3.3 java伪代码

以下以20位`计数序号`，`秒`为`时间单位`为例，说明算法流程。

```java
// 以下为类变量定义部分。
// 不必非到1,048,575再执行复位。
final static int MAX_COUNTER = 1000000;
// 提供多线程安全的序号计数器。
final AtomicInteger counter = new AtomicInteger(0);

// 以下为类函数定义。只演示如何产生序号。
public int getSequence() {
    final int count = counter.getAndIncrease();

    // 每个线程不再是每到新的一秒就将counter置为0，而是继续使用，直到预设的上边界。
    // 此方法仍不能避免由于对时服务将本地时钟向回调可能造成的ID重复。
    // 但序号范围越大，每秒内事件数量越少，重复的可能性越小。
    if (count >= MAX_COUNTER {
        syncronized(counter) {
            if (count >= MAX_COUNTER {
                counter.set(0);
            }
        }
    }

    return count;
}
```

## 四、其它

按标准算法定义，最高位为时间，所以设为0，使整个值始终为正数。这样，在不考虑时钟回调的前提下，后生成的ID始终比前面的大。如果考虑到时间回调因素，就不能保证如此了。
因此，不能建立以ID大小为条件的处理逻辑。所以，最高位是否设置为0无关紧要。

雪花算法提供了生成分布式ID的思路，其组合方式不一定非按其定义排列，可根据实际情况处理。

无论以`秒`或`毫秒`作为`时间单位`，重复的可能性仅存在于时钟回调。时种向后调肯定不会产生重复。因此，如果发现时钟回调很长，则应停止程序运行，等待系统空运行回调时长后再启动程序。但如果经常发生这类长时间段回调，则是系统问题，用软件无论如何是无法解决的。
