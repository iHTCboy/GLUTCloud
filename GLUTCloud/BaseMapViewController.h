//
//  BaseMapViewController.h
//  DevDemo2D
//
//  Created by songjian on 13-8-14.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapNaviKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapCloudKit/AMapCloudAPI.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "appMarco.h"

@interface BaseMapViewController : UIViewController<MAMapViewDelegate,AMapCloudDelegate, AMapSearchDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic, strong) AMapCloudAPI *cloudAPI;


@property (assign, nonatomic) CLLocationCoordinate2D coordinate;


- (void)returnAction;

@end
