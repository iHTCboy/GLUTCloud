2020-05-10 更新

## Xcode 11

Xcode11的 CoreSimulator 文件夹被移至到:

```
/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/usr/lib/
```


| 平台 | 文件夹 | 文件 | 大小 | 路径 |
|---|---|---|---|---|
| 模拟器运行需要 | CoreSimulator | libstdc++.6.0.9.dylib  | 766,624B | /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot/usr/lib/ |
|  模拟器编译需要 | iPhoneSimulator | libstdc++.6.0.9.tbd  | 206,800B | /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk/usr/lib/ |
| iOS真机 | iPhoneOS | libstdc++.6.0.9.tbd | 209,673B | /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/usr/lib/ |
|  macOS APP | MacOSX | libstdc++.6.0.9.tbd | 206,751B | /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/lib/ |      


注：替换文件路径：`/GLUTCloud/libstdc++.6.0.9.tbd/Xcode11/libstdc++6.zip`


- [Xcode 11 缺少libstdc++.6.0.9的解决方案、运行模拟器时报错问题_移动开发_u014228527的专栏-CSDN博客](https://blog.csdn.net/u014228527/article/details/102639188)


## Xcode 10：library not found for -lstdc++.6.0.9 临时解决 

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
