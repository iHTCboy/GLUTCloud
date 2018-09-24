//
//  SearchPanoramaViewController.m
//  officialDemoPanorama
//
//  Created by 刘博 on 14-5-26.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import "SearchPanoramaViewController.h"
#import "SearchPanoramaDetailViewController.h"
#import "SearchPanoramaAnnotation.h"

#define kDefaule_Radius 100.f

@interface SearchPanoramaViewController ()<MAMapViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation SearchPanoramaViewController

@synthesize mapView = _mapView;

#pragma mark - Override

- (void)returnAction
{
    [super returnAction];
    
    [self deleteMapView];
}

#pragma mark - Utility

- (void)deleteMapView
{
    self.mapView.delegate = nil;
    
    self.mapView = nil;
}

- (void)enterPanoramaViewWithPanoramaID:(NSString *)panoramaID
{
    if (panoramaID != nil)
    {
        SearchPanoramaDetailViewController *detailViewController = [[SearchPanoramaDetailViewController alloc] init];
        
        [detailViewController setPanoramaID:panoramaID];
        
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

#pragma mark - Get PanoramaID

- (void)getNearsetPanoramaIDFromCoordinate:(CLLocationCoordinate2D)coordinate radius:(double)radius
{
    __block SearchPanoramaAnnotation *annotation = [[SearchPanoramaAnnotation alloc] init];
    [annotation setCoordinate:coordinate];
    [annotation setTitle:@"检索街景中..."];
    [self.mapView addAnnotation:annotation];
    
    AMapPanoramaGetNearestPanoramaID(coordinate, radius, 20, ^(NSString *panoramaID, NSError *error) {
        
        [annotation setPanoramaID:panoramaID];
        
        if (error)
        {
            [annotation setTitle:[NSString stringWithFormat:@"%@", [error domain]]];
            [annotation setSubtitle:[NSString stringWithFormat:@"%@", [error localizedDescription]]];
        }
        else
        {
            [annotation setTitle:@"PanoramaID:"];
            [annotation setSubtitle:[NSString stringWithFormat:@"%@", panoramaID]];
        }
    });
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MAAnnotationView *view = views[0];
    
    [self.mapView selectAnnotation:view.annotation animated:YES];
}

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[SearchPanoramaAnnotation class]])
    {
        SearchPanoramaAnnotation *ann = (SearchPanoramaAnnotation *)view.annotation;
        if ([ann panoramaID] != nil)
        {
            [self enterPanoramaViewWithPanoramaID:[ann panoramaID]];
        }
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[SearchPanoramaAnnotation class]])
    {
        static NSString *invertGeoIdentifier = @"SearchPanoramaViewAnnotationIdentifier";
        
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:invertGeoIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:invertGeoIdentifier];
        }
        
        poiAnnotationView.draggable      = NO;
        poiAnnotationView.animatesDrop   = YES;
        poiAnnotationView.canShowCallout = YES;
        poiAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return poiAnnotationView;
    }
    
    return nil;
}

#pragma mark - Handle Gesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[longPress locationInView:self.view]
                                                  toCoordinateFromView:self.mapView];
        
        [self getNearsetPanoramaIDFromCoordinate:coordinate radius:kDefaule_Radius];
    }
}

#pragma mark - Initialization

- (void)initGestureRecognizer
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(handleLongPress:)];
    longPress.delegate = self;
    longPress.minimumPressDuration = 0.5;
    
    [self.view addGestureRecognizer:longPress];
}

- (void)initToolBar
{
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil];
    
    UILabel *prompts = [[UILabel alloc] init];
    prompts.text            = @"长按地图检索街景ID";
    prompts.textAlignment   = UITextAlignmentCenter;
    prompts.backgroundColor = [UIColor clearColor];
    prompts.textColor       = [UIColor whiteColor];
    prompts.font            = [UIFont systemFontOfSize:20];
    [prompts sizeToFit];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:prompts];
    self.toolbarItems = [NSArray arrayWithObjects:flexble, item, flexble, nil];
}

- (void)initMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    
    [self.mapView setDelegate:self];
    
    [self.view addSubview:self.mapView];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initMapView];
    
    [self initToolBar];
    
    [self initGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.toolbar.barStyle      = UIBarStyleBlack;
    self.navigationController.toolbar.translucent   = YES;
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.mapView setVisibleMapRect:MAMapRectMake(220880104, 101476980, 272496, 466656)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:animated];
}

@end
