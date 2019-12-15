# chat


### 1. 客户端 
HTML + websocket + vue
#### 1.1 匹配1个聊天对象
匹配1个client
界面上需要显示对应的会话窗口
可能会有多个会话窗口
多个会话窗口共享一个连接
#### 1.2 发送消息
userId/sessionId/msg_content/createdAt
user1 -> session1
#### 1.3 接收消息
userId/sessionId/msg_content/createdAt
user1 -> session1
#### 1.4 主动logout

#### 1.5 处理session终止消息

### 2. 接入层 broker
websocket
#### 2.1 创建用户
仅需要用户名

#### 2.2 [TCP]维持和客户端的心跳
记录用户所在的位置 user1 -> broker1
报告user已经下线

#### 2.3 [TCP] 匹配1个聊天对象
创建一个session
session1 -> user1/user2

#### 2.4 [TCP] 发送消息
user1 -> session1

#### 2.5 [TCP]推送消息
**需要处理客户端回复的ACK消息** 2期

#### 2.6 [TCP]logout

### 3. 逻辑层 logic 
grpc
#### 3.1 [接口] 创建用户
#### 3.2 [接口] 匹配用户
创建session
#### 3.3 [接口] 发送消息
1. 保存msg
2. 把msg推送至session的收件箱保存后，返回

#### 3.4 后台逻辑-从收件箱取出数据完成实际推送
查看session与users的对应关系
查看session中每个用户所在broker
将消息发送给user对应的broker

#### 3.5 [接口] 用户下线
将用户从路由层清理，
如果session中只有2个用户，需要向session的其它参与者发送，session参与者有退出，发送session终止消息

### 4. 路由层/DB
维护session中的参与者
维护user所在broker


### 5. 发号器
实现session内部msgId唯一

## 通讯协议
### 1. 创建用户
#### request
```
{
	"cmd": "CRT_ACCOUNT",
	"nickName": "XXXX"
}
```
#### response
```
{
	"cmd": "CRT_ACCOUNT",
	"nickName": "XXXX",
	"accountId": 1111
}
```

### 2. 请求匹配
发送方是client
#### request
```
{
	"cmd": "MATCH",
	"accountId": 1111
}
```
#### response
```
{
	"cmd": "MATCH",
	"partnerId": 1111,
	"partnerName": "xxxx",
	"sessionId": 10000
	"code": 0
}
```
### 3.发送消息
发送方是client
#### request
```
{
    
	"cmd": "DIALOGUE",
	"requestId": "1111:20000", // 新增
    "senderId": 1111,
    "sessionId": 10000,
    "content": "hello world"
}
```
#### response
```
{
    "cmd": "DIALOGUE",
    "requestId": "1111:20000", // 新增
    "msgId": 20000, // 新增
	"code": 0
}
```


### 4. 推送消息
发送方是broker
#### request
```
{
	"cmd": "PUSH_DIALOGUE",
	"msgId": 20000, // 新增
    "senderId": 1111,
    "sessionId": 10000,
    "content": "hello world"
}
```
#### response
无

### 5. 推送信令
发送方是broker

#### 5.1 有新会话
#### request
```
{
	"cmd": "PUSH_SIGNAL",
	"signalType: "NewSession"
    "senderId": 1111,
    "sessionId": 10000,
    "receiverId": 12000,
    "data":{
        "accountId":  100,
        "nickName": "zhangsan"
    }
}
```
#### response
无

#### 5.2 用户退出或掉线
```
{
	"cmd": "PUSH_SIGNAL",
	"signalType: "PartnerExit"
	// 都是由系统发出
    "senderId": 0,
    "sessionId": 10000,
    "receiverId": 12000,
    "data":{
        "accountId":  1000,
    }
}
```


#### response
无


### 6. PING
由broker发起
#### request
```
{
	"cmd": "PING",
	"accountId": 12000
}
```
#### response
```
{
	"cmd": "PONG"
	"accountId": 12000
}
```
### 7. VIEWED_ACK
由Client发起
#### request
```
{
	"cmd": "VIEWED_ACK",
	"sessionId": 1000,
	"accountId":11000,
	"msgId": 12000
}
```
#### response
```
{
	"cmd": "VIEWED_ACK",
	"code": 0
}
```

### 7. PUSH_VIEWED_ACK
由broker发起
#### request
```
{
	"cmd": "PUSH_VIEWED_ACK",
	"sessionId": 1000,
	"accountId":11000,
	"msgId": 12000
}
```
#### response
无



### build
```
env GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o chat 
```

### start
**broker**
```
./chat broker --config config.broker.yaml

```
**logic**
```
./chat logic --config config.logic.yaml

```

 