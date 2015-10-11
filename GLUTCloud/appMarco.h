//
//  appMarco.h
//  GLUTCloud
//
//  Created by HTC on 14/12/29.
//  Copyright (c) 2014年 HTC. All rights reserved.
//

#ifndef GLUTCloud_appMarco_h
#define GLUTCloud_appMarco_h



const static NSString *APIKey = @"5544dd167fbc99d0368f7cb3d28f0886";


/**
 *  我的测试表
 */
//const static NSString *tableID = @"5472ed86e4b08f472bf565f5";

/**
 *  桂工云图 Rest 服务接口
 */
const static NSString *RestIKey = @"addacff49d77fafc3a2f888fb16de8d7";

/////**
//// *  云图测试 Rest 服务接口
//const static NSString *RestIKey = @"bc7eaceb83a62f9ad5dba2fafee480a0";

/**
 *  桂工云图表
 */
const static NSString *tableID = @"54768b27e4b0f76538b01f88";

/**
 *  全部云图表
 */
const static NSString *allTableID = @"54a269e7e4b053daeaf70fad";

#endif

#ifdef DEBUG
#define debugLog(...) NSLog(__VA_ARGS__)
#define debugMethod() NSLog(@"%s", __func__)
#define debugNSSting(a) NSLog(@"%@", a)
#else
#define debugLog(...)
#define debugMethod()
#endif


#define appMainColor [UIColor colorWithRed:0.000 green:0.502 blue:1.000 alpha:1.000]

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
