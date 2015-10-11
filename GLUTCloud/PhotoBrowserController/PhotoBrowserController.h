//
//  PhotoBrowserController.h
//  图片浏览器
//
//  Created by mj on 13-10-15.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoBrowserController : UIViewController

@property (nonatomic , copy) NSString * title;

@property (nonatomic , strong) NSMutableArray * thumbPhotosUrlArray;

@property (nonatomic , strong) NSMutableArray * origPhotosUrlArray;

@end
