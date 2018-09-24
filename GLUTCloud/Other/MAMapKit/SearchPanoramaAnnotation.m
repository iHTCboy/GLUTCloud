//
//  SearchPanoramaAnnotation.m
//  officialDemoPanorama
//
//  Created by 刘博 on 14-5-26.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import "SearchPanoramaAnnotation.h"

@implementation SearchPanoramaAnnotation

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize panoramaID = _panoramaID;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    if (self = [super init])
    {
        self.coordinate = coordinate;
    }
    return self;
}

@end
