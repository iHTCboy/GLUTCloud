//
//  AMapCloudPOIDetailViewController.h
//  AMapCloudDemo
//
//  Created by 刘博 on 14-3-13.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapCloudKit/AMapCloudAPI.h>

@interface AMapCloudPOIDetailViewController : UIViewController

@property (nonatomic, assign) BOOL isCollect;
@property (nonatomic, strong) AMapCloudPOI *cloudPOI;

@end
