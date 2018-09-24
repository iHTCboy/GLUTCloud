//
//  InvertGeoViewController.m
//  SearchV3Demo
//
//  Created by songjian on 13-8-14.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "InvertGeoViewController.h"
#import "InvertGeoDetailViewController.h"
#import "ReGeocodeAnnotation.h"
#import "CommonUtility.h"

@interface InvertGeoViewController ()
{
    BOOL _hasCurrLoc; //是否要定位当前位置
}
@end

@implementation InvertGeoViewController

- (void)gotoDetailForReGeocode:(AMapReGeocode *)reGeocode
{
    if (reGeocode != nil)
    {
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationItem.backBarButtonItem = backItem;
        
        
        InvertGeoDetailViewController *invertGeoDetailViewController = [[InvertGeoDetailViewController alloc] init];
        
        invertGeoDetailViewController.reGeocode = reGeocode;
        
        [self.navigationController pushViewController:invertGeoDetailViewController animated:YES];
    }
}

- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension = YES;
    
    [self.search AMapReGoecodeSearch:regeo];
}

#pragma mark - MAMapViewDelegate

//此方法调用频率高
/**
 *  位置改变时更新
 */
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    
    if (!_hasCurrLoc)
    {
        _hasCurrLoc = YES;
        [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
        [self.mapView setZoomLevel:16 animated:YES];
    }
    
    //NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
}


- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[ReGeocodeAnnotation class]])
    {
        [self gotoDetailForReGeocode:[(ReGeocodeAnnotation*)view.annotation reGeocode]];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[ReGeocodeAnnotation class]])
    {
        static NSString *invertGeoIdentifier = @"invertGeoIdentifier";
        
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:invertGeoIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                                reuseIdentifier:invertGeoIdentifier];
        }
        
        poiAnnotationView.animatesDrop              = YES;
        poiAnnotationView.canShowCallout            = YES;
        poiAnnotationView.image = [UIImage imageNamed:@"cloudPoint"];
        UIButton * rightAccessoryView= [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        rightAccessoryView.tintColor = [UIColor colorWithRed:0.270 green:0.633 blue:1.000 alpha:1];
        poiAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return poiAnnotationView;
    }
    
    return nil;
}

#pragma mark - AMapSearchDelegate

/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
        ReGeocodeAnnotation *reGeocodeAnnotation = [[ReGeocodeAnnotation alloc] initWithCoordinate:coordinate reGeocode:response.regeocode];
        
        [self.mapView addAnnotation:reGeocodeAnnotation];
        [self.mapView selectAnnotation:reGeocodeAnnotation animated:YES];
    }
}


#pragma mark - Handle Gesture

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[longPress locationInView:self.view] toCoordinateFromView:self.mapView];
        
        [self searchReGeocodeWithCoordinate:coordinate];
    }
}



#pragma mark - Initialization

- (void)initGestureRecognizer
{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.3;
    
    [self.view addGestureRecognizer:longPress];
}

- (void)initToolBar
{
//    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
//                                                                             target:nil
//                                                                             action:nil];
//    
//    UILabel *prompts = [[UILabel alloc] init];
//    prompts.text            = @"长按查看地点信息";
//    prompts.textAlignment   = UITextAlignmentCenter;
//    prompts.backgroundColor = [UIColor clearColor];
//    prompts.textColor       = [UIColor whiteColor];
//    prompts.font            = [UIFont systemFontOfSize:20];
//    [prompts sizeToFit];
//    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:prompts];
//    self.toolbarItems = [NSArray arrayWithObjects:flexble, item, flexble, nil];
    
//    UIView * toolView = [[UIView alloc]init];
//    toolView.frame = CGRectMake(0, 0, 150,30);
//    toolView.center = CGPointMake(self.view.frame.size.width /2, self.view.frame.size.height - 179);
//    toolView.backgroundColor = appMainColor;
//    
//    [self.view addSubview:toolView];
//    [self.view bringSubviewToFront:toolView];
    
}


-(void)initNavBar
{
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textColor        = [UIColor whiteColor];
    titleLabel.font             = [UIFont boldSystemFontOfSize:18];
    titleLabel.text             = @"信息图";
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
}

-(void)initMapView
{
    
    if (self.mapView == nil)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    }
    
    self.mapView.frame = self.view.bounds;
    
    self.mapView.delegate = self;
    
    self.mapView.showsUserLocation = YES;
    
    self.mapView.showsCompass = YES;
    
    self.mapView.showsScale = NO;
    
    self.mapView.zoomLevel = 16;
    
    [self.view addSubview:self.mapView];
    
    _hasCurrLoc = NO;
    
    
}

-(void)initLocationBtn
{
    //定位用户当前坐标按钮
    UIButton * btnLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    //btnLocation.autoresizingMask = UIViewAutoresizingFlexibleTopMargin || UIViewAutoresizingFlexibleLeftMargin;
    [btnLocation setBackgroundColor:[UIColor clearColor]];
    [btnLocation setBackgroundImage:[UIImage imageNamed:@"default_main_gpsbutton_background_normal"] forState:UIControlStateNormal];
    //[btnLocation setBackgroundImage:[UIImage imageNamed:@"default_main_gpsbutton_background_normal"] forState:UIControlStateHighlighted];
    [btnLocation setImage:[UIImage imageNamed:@"default_main_gpsnormalbutton_image_normal"] forState:UIControlStateNormal];
    [btnLocation setImage:[UIImage imageNamed:@"default_main_gpsnormalbutton_image_disabled"] forState:UIControlStateHighlighted];
    [btnLocation setContentMode:UIViewContentModeCenter];
    [btnLocation setFrame:CGRectMake(self.view.bounds.size.width-65, self.view.bounds.size.height-65, 45, 45)];
    [btnLocation setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin];
    [btnLocation addTarget:self action:@selector(mylocationBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnLocation];
    [self.view bringSubviewToFront:btnLocation];
    
    
}

#pragma mark - 定位用户当前坐标按钮点击事件
- (void)mylocationBtn
{
    
    _hasCurrLoc = NO;
    //开始定位
    self.mapView.showsUserLocation = YES;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self initToolBar];
    
    [self initNavBar];
    
    [self initGestureRecognizer];
    
    [self initMapView];
    
    [self initLocationBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.navigationController.toolbar.barStyle      = UIBarStyleBlack;
//    self.navigationController.toolbar.translucent   = YES;
//    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [self.navigationController setToolbarHidden:YES animated:animated];
}

@end
