//
//  AppDelegate.m
//  GLUTCloud
//
//  Created by HTC on 14-12-29.
//  Copyright (c) 2014年 HTC. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
//#import <MAMapKit/MAMapKit.h>
#import "appMarco.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySetting.h"
#import <AMapNaviKit/AMapNaviKit.h>
//#import <AMapPanoramaKit/AMapPanoramaKit.h>
#import "BaiduMobStat.h"
#import "Utility.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)configureAPIKey
{
    if ([APIKey length] == 0)
    {
#define kMALogTitle @"提示"
#define kMALogContent @"apiKey为空，请检查key是否正确设置"
        
        NSString *log = [NSString stringWithFormat:@"[MAMapKit] %@", kMALogContent];
        NSLog(@"%@", log);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kMALogTitle message:kMALogContent delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
        });
    }
    
    [AMapNaviServices sharedServices].apiKey = (NSString *)APIKey;
    
    [MAMapServices sharedServices].apiKey = (NSString *)APIKey;
    
    //[AMapPanoramaServices sharedServices].apiKey = (NSString *)APIKey;
}



- (void)configIFlySpeech
{
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,timeout=%@",@"53c35b10",@"20000"];
    
    [IFlySpeechUtility createUtility:initString];
    
    [IFlySetting setLogFile:LVL_NONE];
    [IFlySetting showLogcat:NO];
    
    // 设置语音合成的参数
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"50" forKey:[IFlySpeechConstant SPEED]];//合成的语速,取值范围 0~100
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"50" forKey:[IFlySpeechConstant VOLUME]];//合成的音量;取值范围 0~100
    
    // 发音人,默认为”xiaoyan”;可以设置的参数列表可参考个 性化发音人列表;
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"xiaoyan" forKey:[IFlySpeechConstant VOICE_NAME]];
    
    // 音频采样率,目前支持的采样率有 16000 和 8000;
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"8000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    // 当你再不需要保存音频时，请在必要的地方加上这行。
    [[IFlySpeechSynthesizer sharedInstance] setParameter:nil forKey:[IFlySpeechConstant TTS_AUDIO_PATH]];
}


/**
 *  初始化百度统计SDK
 */
- (void)startBaiduMobStat {
    BaiduMobStat* statTracker = [BaiduMobStat defaultStat];
    // 此处(startWithAppId之前)可以设置初始化的可选参数，具体有哪些参数，可详见BaiduMobStat.h文件，例如：
    statTracker.shortAppVersion  = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //    statTracker.enableDebugOn = YES;
    [statTracker startWithAppId:@"7964219cd6"]; // 设置您在mtj网站上添加的app的appkey,此处AppId即为应用的appKey
#if DEBUG
    NSLog(@"Debug Model");
#else
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    df.locale = [NSLocale currentLocale];
    df.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *currentDate = [df stringFromDate:[NSDate new]];
    
    // 自定义事件
    [statTracker logEvent:@"usermodelName" eventLabel:[Utility getCurrentDeviceModel]];
    [statTracker logEvent:@"systemVersion" eventLabel:[[UIDevice currentDevice] systemVersion]];
    [statTracker logEvent:@"Devices" eventLabel:[[UIDevice currentDevice] name]];
    [statTracker logEvent:@"DateAndDeviceName" eventLabel:[NSString stringWithFormat:@"%@ %@", currentDate, [[UIDevice currentDevice] name]]];
    [statTracker logEvent:@"DateSystemVersion" eventLabel:[NSString stringWithFormat:@"%@ %@", currentDate, [[UIDevice currentDevice] systemVersion]]];
#endif
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    application.statusBarHidden = NO;
    application.statusBarStyle = UIStatusBarStyleLightContent;
    
    [self configureAPIKey];
    [self configIFlySpeech];
    //百度统计
    [self startBaiduMobStat];
    
    
    NSString *key = @"CFBundleVersion";
    
    // 取出沙盒中存储的上次使用软件的版本号
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastVersion = [defaults stringForKey:key];
    
    // 获得当前软件的版本号
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[key];
    if ([currentVersion isEqualToString:lastVersion])
    {
        HomeViewController * homeV = [[HomeViewController alloc]init];
        UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:homeV];
        nav.navigationBar.barTintColor = appMainColor;
        self.window.rootViewController = nav;
        
    }
    else
    { // 新版本
        
        //新版本
        NSUserDefaults * defaults =  [NSUserDefaults standardUserDefaults];
        NSDictionary *glutGPS = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"25.063461",@"latitude",
                                 @"110.302375",@"longitude",
                                 nil];
        [defaults setValue:glutGPS forKey:@"glutGPS"];
        //判断用户是否存储了设置，如果没有YES，刚统一NO
        if(![defaults boolForKey:@"glutSwitchIsOn"])
        {
          [defaults setBool:NO forKey:@"glutSwitchIsOn"];
        }
        if (![defaults boolForKey:@"allSwitchIsOn"])
        {
          [defaults setBool:NO forKey:@"allSwitchIsOn"];
        }
        
        
        HomeViewController * homeV = [[HomeViewController alloc]init];
        UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:homeV];
        nav.navigationBar.barTintColor = appMainColor;
        self.window.rootViewController = nav;
    }
    
    
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
