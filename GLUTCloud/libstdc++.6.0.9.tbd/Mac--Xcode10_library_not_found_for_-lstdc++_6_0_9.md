## Xcode10：library not found for -lstdc++.6.0.9 临时解决 

### 下载stdc++.6.0.9

提取自Xcode9

[**百度云链接：stdc++.6.0.9**](https://pan.baidu.com/s/1zCagMy42HGPdZj8XMfOf_Q)

部分项目依赖 libstdc++.6.0.9 的会在Xcode 10无法运行

其原因是Xcode 10中将libstdc++.6.0.9库文件删除，原本功能迁移至其他库


<!--more-->


### 真机运行库

在终端输入以下命令打开Xcode的lib库目录（此目录位安装的默认目录）

```
open /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib
```

如果安装在其他目录 或者Xcode改名的建议右键Xcode显示报内容，进入

```
Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib
```


把刚刚下载的zip文件解压

获取到的 真机的 libstdc++.6.0.9.tbd 文件，扔进去


### 模拟器运行库

在终端输入以下命令打开Xcode的lib库目录（此目录位安装的默认目录）

```
open  /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/usr/lib
```


如果安装在其他目录 或者Xcode改名的建议右键Xcode显示报内容，进入

```
Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/usr/lib
```


把刚刚下载的zip文件解压

获取到的 模拟器的 libstdc++.6.0.9.tbd 文件，扔进去

### 下一步

重启Xcode

### 相关链接

* [简书：](https://www.jianshu.com/p/76bd060bab34) https://www.jianshu.com/p/76bd060bab34

* [CSDN：](https://blog.csdn.net/ZuoWeiXiaoDuZuoZuo/article/details/82756116)https://blog.csdn.net/ZuoWeiXiaoDuZuoZuo/article/details/82756116