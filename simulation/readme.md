# 仿真

## 原理

### 模型简介

* 有Alice、Bob、Relay三个节点，Alice和Bob通过Relay实现双向通信。实际上Bob给Alice发的是无用信息message_B，不怕被Relay获取；Alice给Bob发的既包含了有用信息message_A，也包含了用来欺骗Relay的假消息message_fake。
  * 假设B采用4-QAM发送message_B。其星座图为constellation_B，是固定的。
  * 假设A采用16-QAM发送message_A和message_fake，其构成方式为取message_fake的两位构成4bit的前2位，取message_A的两位构成4bit的后两位。其星座图为constellation_real，该星座图由constellation_fake和constellation_real_quadrant相加而成。constellation_fake是固定的，而constellation_real_quadrant是旋转的。
  * B解A的消息时，采用的星座图为constellation_ideal，其与constellation_real构成相似。A解B的消息时星座图constellation_B。
* 涉及星座图旋转和缩放。
  * real_quadrant的旋转和缩放由A解B所得的信息决定。
  * ideal_quadrant的旋转和缩放由B所发信息决定。
* 还设计了Return Zero、Rotation Bits等规则。

## 实现

### 2019-05-18
* 通过edit awgn阅读源码，终于理解了matlab里awgn是如何工作，里面的SNR，功率指什么。sigPower = sum(abs(sig(:)).^2)/numel(sig)