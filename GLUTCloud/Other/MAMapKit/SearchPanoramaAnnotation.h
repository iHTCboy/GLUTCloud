//
//  SearchPanoramaAnnotation.h
//  officialDemoPanorama
//
//  Created by 刘博 on 14-5-26.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import <AMapNaviKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>

@interface SearchPanoramaAnnotation : NSObject<MAAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, strong) NSString *panoramaID;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
