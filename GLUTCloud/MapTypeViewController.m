//
//  MapTypeViewController.m
//  Category_demo
//
//  Created by songjian on 13-3-21.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "MapTypeViewController.h"

@interface MapTypeViewController()
{
    BOOL _hasCurrLoc; //是否要定位当前位置
}
@end

@implementation MapTypeViewController

#pragma mark - Action Handlers
- (void)mapTypeAction:(UISegmentedControl *)segmentedControl
{
    self.mapView.mapType = segmentedControl.selectedSegmentIndex;
}

#pragma mark - Initialization
-(void)initNavBar
{
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textColor        = [UIColor whiteColor];
    titleLabel.font             = [UIFont boldSystemFontOfSize:18];
    titleLabel.text             = @"卫星图";
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;


}

- (void)initToolBar
{
    
    UISegmentedControl *mapTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:
                                                   [NSArray arrayWithObjects:
                                                    @"标准图",
                                                    @"卫星图",
                                                    @"黑夜图",
                                                    nil]];
    mapTypeSegmentedControl.frame = CGRectMake(0, 0, 150,30);
    mapTypeSegmentedControl.center = CGPointMake(self.view.frame.size.width /2, self.view.frame.size.height - 79);
    mapTypeSegmentedControl.backgroundColor = [UIColor clearColor];
    mapTypeSegmentedControl.tintColor = appMainColor;
    //    toolView.backgroundColor  = [UIColor whiteColor];
    mapTypeSegmentedControl.selectedSegmentIndex  = self.mapView.mapType;
    //mapTypeSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [mapTypeSegmentedControl addTarget:self action:@selector(mapTypeAction:) forControlEvents:UIControlEventValueChanged];
    mapTypeSegmentedControl.selectedSegmentIndex = 1;
    
    [self.view addSubview:mapTypeSegmentedControl];
    [self.view bringSubviewToFront:mapTypeSegmentedControl];
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
    
    self.mapView.mapType = MAMapTypeSatellite;
    
    self.mapView.zoomLevel = 18;
    
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
    [btnLocation addTarget:self action:@selector(locationBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnLocation];
    [self.view bringSubviewToFront:btnLocation];


}



#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavBar];
    
    [self initMapView];
    
    [self initToolBar];
    
    [self initLocationBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.navigationController.toolbar.barStyle      = UIBarStyleBlack;
//    self.navigationController.toolbar.translucent   = YES;
//    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.mapView.mapType = MAMapTypeStandard;
    self.mapView.delegate = nil;
}


#pragma mark - 定位用户当前坐标按钮点击事件
- (void)locationBtn
{
    _hasCurrLoc = NO;
    //开始定位
    self.mapView.showsUserLocation = YES;
    
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
        [self.mapView setZoomLevel:18 animated:YES];
    }

    if (updatingLocation)
    {
       // [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
    }
    
    
    //NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
}


@end
