//
//  LZSelectLocationMapViewController.h
//  maidaojia
//
//  Created by bailin on 14-6-21.
//  Copyright (c) 2014年 BaiLin. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import <AMapNaviKit/AMapNaviKit.h>

@protocol ReSelectLocationMapViewControllerDelegate;

@interface ReSelectLocationMapViewController : UIViewController<MAMapViewDelegate,AMapSearchDelegate>
@property (strong, nonatomic) MAMapView * mapView;
@property (strong, nonatomic) AMapSearchAPI * search;
@property (assign, nonatomic) id<ReSelectLocationMapViewControllerDelegate>  delegate;
@property (strong, nonatomic) CLLocation * initialLocation;
@end

@protocol ReSelectLocationMapViewControllerDelegate <NSObject>

@optional
- (void)selectLocationDidResponse:(AMapReGeocodeSearchResponse *)response WithSelectLocation:(CLLocationCoordinate2D)location;

@end