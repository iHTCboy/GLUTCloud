//
//  ZongheShowViewController.m
//  officialDemoNavi
//
//  Created by LiuX on 14-9-1.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import "NavigationViewController.h"
#import "NavPointAnnotation.h"
#import "RouteShowViewController.h"
#import "appMarco.h"
#import "MBProgressHUD+MJ.h"

#define kSetingViewHeight 180
#define margin 10
#define LabelWidth 65
#define LabelHight 30
#define LabelLeft  30
#define viewWidth self.view.frame.size.width
#define viewHight self.view.frame.size.height

typedef NS_ENUM(NSInteger, MapSelectPointState)
{
    MapSelectPointStateNone = 0,
    MapSelectPointStateStartPoint, // 当前操作为选择起始点
    MapSelectPointStateWayPoint,   // 当前操作为选择途径点
    MapSelectPointStateEndPoint,   // 当前操作为选择终止点
};


typedef NS_ENUM(NSInteger, NavigationTypes)
{
    NavigationTypeNone = 0,
    NavigationTypeSimulator, // 模拟导航
    NavigationTypeGPS,       // 实时导航
};


typedef NS_ENUM(NSInteger, TravelTypes)
{
    TravelTypeCar = 0,    // 驾车方式
    TravelTypeWalk,       // 步行方式
};


@interface NavigationViewController () <AMapNaviViewControllerDelegate,UIGestureRecognizerDelegate>
{
    UILabel *_wayPointLabel;
    UIButton *_waySlefPointBtn;
    UIButton *_wayMapPointBtn;
    
    UIButton *_startSlefPointBtn;
    UIButton *_startMapPointBtn;
    UIButton *_endSlefPointBtn;
    UIButton *_endMapPointBtn;
    
    
    UIButton *_routeBtn;
    UIButton *_simuBtn;
    
    MapSelectPointState _selectPointState;
    NavigationTypes     _naviType;
    TravelTypes         _travelType;
    
    BOOL _startCurrLoc;   // 起始点使用当前位置？
    BOOL _hasCurrLoc;
    
    UITapGestureRecognizer *_mapViewTapGesture;
    
    NSDictionary *_strategyMap;
}

@property (nonatomic, strong) AMapNaviViewController *naviViewController;

@property (nonatomic, strong) NavPointAnnotation *beginAnnotation;
@property (nonatomic, strong) NavPointAnnotation *wayAnnotation;
@property (nonatomic, strong) NavPointAnnotation *endAnnotation;

@property (nonatomic, weak) RouteShowViewController *routeShowVC;

@end

@implementation NavigationViewController


#pragma mark - Life Cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        [self initCalRouteStrategyMap];
        [self initTravelType];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initBaseNavigationBar];
    
    [self initNaviViewController];
    
    [self configSettingViews];
    
    [self initGestureRecognizer];
    
//    [self configMapView];
//    
//    [self initSettingState];
    
    [self initUserLocationBtn];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self initNaviViewController];
//    
//    [self initGestureRecognizer];
    
    [self initSettingState];
    
    [self configMapView];
    
    [self didSelectPointBtn:0];
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 去掉手势
    [self.mapView removeGestureRecognizer:_mapViewTapGesture];
    
    self.mapView.delegate = nil;
    //self.mapView = nil;
}



#pragma mark - Utils

- (void)initCalRouteStrategyMap
{
    _strategyMap = @{@"速度优先"   : @0,
                     @"费用优先"   : @1,
                     @"距离优先"   : @2,
                     @"普通路优先"             : @3,
                     @"时间优先(躲避拥堵)"      : @4,
                     @"躲避拥堵且不走收费道路"   : @12};
}


- (void)initTravelType
{
    //默认选择步行
    _travelType = TravelTypeWalk;
}


- (void)configMapView
{
    if (self.mapView == nil) {
        self.mapView=[[MAMapView alloc] init];
    }
    
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    [self.mapView setFrame:CGRectMake(0, kSetingViewHeight,
                                      self.view.bounds.size.width,
                                      self.view.bounds.size.height - kSetingViewHeight)];
    
    
    [self.view insertSubview:self.mapView atIndex:0];
    
    [self.mapView addGestureRecognizer:_mapViewTapGesture];
    
    _hasCurrLoc = NO;
    

}

- (void)initBaseNavigationBar
{
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textColor        = [UIColor whiteColor];
    titleLabel.font             = [UIFont boldSystemFontOfSize:18];
    titleLabel.text             = @"导航图";
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}


- (void)initNaviViewController
{
    if (_naviViewController == nil)
    {
        _naviViewController = [[AMapNaviViewController alloc] initWithMapView:self.mapView delegate:self];
    }
}

- (void)configSettingViews
{
    UIView * settingViews = [[UIView alloc]initWithFrame:CGRectMake(0, 0, viewWidth, kSetingViewHeight)];
    [self.view addSubview:settingViews];
    
    UISegmentedControl *segCtrl = [[UISegmentedControl alloc] initWithItems:@[@"步行", @"驾车"]];
    segCtrl.tintColor = appMainColor;
    [segCtrl setFrame:CGRectMake ((viewWidth - 180) /2 , margin ,180 ,LabelHight)];
    [segCtrl addTarget:self action:@selector(segCtrlClick:) forControlEvents:UIControlEventValueChanged];
    [segCtrl setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}
                           forState:UIControlStateNormal];
    segCtrl.selectedSegmentIndex = 0;
    [settingViews addSubview:segCtrl];
    
    UILabel *startPointLabel = [self createTitleLabel:@"起   点"];
    startPointLabel.frame = CGRectMake(LabelLeft,margin *2 + LabelHight , LabelWidth, LabelHight);
    [settingViews addSubview:startPointLabel];
    
    
    CGFloat BtnH = 30;
    
    CGFloat allW = viewWidth - LabelLeft - LabelWidth;
    
    CGFloat BtnW = (allW - margin * 2) /2;
    
    
    UIButton * startSelfLocationBtn = [self createSelectPointStateButton:@"当前位置" withTag:1];
    startSelfLocationBtn.frame = CGRectMake(LabelLeft + LabelWidth, margin *2 + LabelHight , BtnW, BtnH);
    [settingViews addSubview:startSelfLocationBtn];
    _startSlefPointBtn = startSelfLocationBtn;
    
    UIButton * startMapLocationBtn = [self createSelectPointStateButton:@"地图选点" withTag:2];
    startMapLocationBtn.frame = CGRectMake(LabelLeft + LabelWidth + BtnW + margin, margin *2 + LabelHight , BtnW , BtnH);
    [settingViews addSubview:startMapLocationBtn];
    _startMapPointBtn = startMapLocationBtn;
    
    
    
    UILabel *endPointLabel = [self createTitleLabel:@"终   点"];
    endPointLabel.frame = CGRectMake(LabelLeft, margin * 2 + LabelHight * 2 , LabelWidth, LabelHight);
    [settingViews addSubview:endPointLabel];
    
//    UIButton * endSelfLocationBtn = [self createSelectPointStateButton:@"当前位置" withTag:3];
//    endSelfLocationBtn.frame = CGRectMake(LabelLeft + LabelWidth, margin * 2 + LabelHight * 2 , BtnW, BtnH);
//    [settingViews addSubview:endSelfLocationBtn];
//    _endSlefPointBtn = endSelfLocationBtn;
    
    UIButton * endMapLocationBtn = [self createSelectPointStateButton:@"地图选点" withTag:4];
    endMapLocationBtn.frame = CGRectMake(LabelLeft + LabelWidth, margin * 2 + LabelHight * 2 , BtnW, BtnH);
    [settingViews addSubview:endMapLocationBtn];
    _endMapPointBtn = endMapLocationBtn;
    

    
    
    UILabel *wayPointLabel = [self createTitleLabel:@"途径点"];
    wayPointLabel.frame = CGRectMake(LabelLeft, margin * 2 + LabelHight * 3  , LabelWidth, LabelHight);
    [settingViews addSubview:wayPointLabel];
    _wayPointLabel = wayPointLabel;
    _wayPointLabel.userInteractionEnabled = NO;
   [_wayPointLabel setAlpha:0.3];

//    UIButton * waySelfLocationBtn = [self createSelectPointStateButton:@"当前位置" withTag:5];
//    waySelfLocationBtn.frame = CGRectMake(LabelLeft + LabelWidth, margin * 2 + LabelHight * 2 , BtnW, BtnH);
//    [settingViews addSubview:waySelfLocationBtn];
//    _waySlefPointBtn = waySelfLocationBtn;
//    _waySlefPointBtn.userInteractionEnabled = NO;
//    [_waySlefPointBtn setAlpha:0.3];
    
    UIButton * wayMapLocationBtn = [self createSelectPointStateButton:@"地图选点" withTag:6];
    wayMapLocationBtn.frame = CGRectMake(LabelLeft + LabelWidth, margin * 2 + LabelHight * 3 , BtnW, BtnH);
    [settingViews addSubview:wayMapLocationBtn];
    _wayMapPointBtn = wayMapLocationBtn;
    _wayMapPointBtn.userInteractionEnabled = NO;
    [_wayMapPointBtn setAlpha:0.3];
    

    
    
    

//    UILabel *strategyLabel = [self createTitleLabel:@"策   略"];
//    strategyLabel.frame = CGRectMake(LabelLeft,margin * 2 + LabelHight * 4, LabelWidth, LabelHight);
//        [settingViews addSubview:strategyLabel];
//  
    

    CGFloat btnW = 70;
    CGFloat btnH = 30;
    CGFloat Xwidth = (viewWidth - 2 * btnW - LabelWidth) /2 ;
    
    UIButton *routeBtn = [self createToolButton];
    [routeBtn setTitle:@"路径规划" forState:UIControlStateNormal];
    [routeBtn addTarget:self action:@selector(gpsNavi:) forControlEvents:UIControlEventTouchUpInside];
     routeBtn.frame = CGRectMake(Xwidth ,margin * 2 + LabelHight * 4 + 5, btnW, btnH);
    [settingViews addSubview:routeBtn];
    _routeBtn = routeBtn;
    
    UIButton *simuBtn = [self createToolButton];
    [simuBtn setTitle:@"模拟导航" forState:UIControlStateNormal];
    [simuBtn addTarget:self action:@selector(simulatorNavi:) forControlEvents:UIControlEventTouchUpInside];
    simuBtn.frame = CGRectMake(viewWidth - Xwidth - btnW, margin * 2 + LabelHight * 4 + 5, btnW, btnH);
    [settingViews addSubview:simuBtn];
    _simuBtn = simuBtn;
    
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, kSetingViewHeight -1, viewWidth, 1)];
    line.backgroundColor = [UIColor blackColor];
    [settingViews addSubview:line];
    
}



- (void)initGestureRecognizer
{
    _mapViewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                 action:@selector(handleSingleTap:)];
}


- (UILabel *)createTitleLabel:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] init];
    
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font          = [UIFont systemFontOfSize:15];
    titleLabel.text          = title;
    [titleLabel sizeToFit];
    
    return titleLabel;
}


- (UIButton *)createToolButton
{
    UIButton *toolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    toolBtn.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    toolBtn.layer.borderWidth  = 0.5;
    toolBtn.layer.cornerRadius = 5;
    
    [toolBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBtn.titleLabel.font = [UIFont systemFontOfSize: 13.0];
    
    return toolBtn;
}


- (UIButton *)createSelectPointStateButton:(NSString *)title withTag:(int)tag
{

    UIButton * selectPointStateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectPointStateButton setTitle:title forState:UIControlStateNormal];
    [selectPointStateButton setTitle:title forState:UIControlStateSelected];
    selectPointStateButton.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    selectPointStateButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    selectPointStateButton.tag = tag;
    [selectPointStateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [selectPointStateButton setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [selectPointStateButton setImage:[UIImage imageNamed:@"checkbtn_normal"] forState:UIControlStateNormal];
    [selectPointStateButton setImage:[UIImage imageNamed:@"checkbtn_selected"] forState:UIControlStateSelected];
    [selectPointStateButton addTarget:self action:@selector(selectPointState:) forControlEvents:UIControlEventTouchUpInside];

    return selectPointStateButton;

}


-(void)initUserLocationBtn
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
    [btnLocation addTarget:self action:@selector(locationMyCoordinate:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnLocation];
    [self.view bringSubviewToFront:btnLocation];

}

- (void)initSettingState
{
    _beginAnnotation = nil;
    _wayAnnotation   = nil;
    _endAnnotation   = nil;
    
    
    //        //如果是用户的小蓝点
   for (id<MAAnnotation> annotation in  self.mapView.annotations)
   {
         if (annotation  != self.mapView.userLocation)
         {
            [self.mapView removeAnnotation:annotation];
         }
    }
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    _selectPointState = MapSelectPointStateNone;
    _naviType = NavigationTypeNone;
}


#pragma mark - 定位用户当前坐标按钮点击事件
- (void)locationMyCoordinate:(id)sender{
    
    _hasCurrLoc = NO;
    //开始定位
    self.mapView.showsUserLocation = YES;
    
}


#pragma mark - Gesture Action  地图选点
/**
 *  点击手势，地图选点
*/
- (void)handleSingleTap:(UITapGestureRecognizer *)theSingleTap
{
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:[theSingleTap locationInView:self.mapView]
                                              toCoordinateFromView:self.mapView];
    
    if (_selectPointState == MapSelectPointStateStartPoint)
    {
        if (_beginAnnotation)
        {
            _beginAnnotation.coordinate = coordinate;
        }
        else
        {
            _beginAnnotation = [[NavPointAnnotation alloc] init];
            [_beginAnnotation setCoordinate:coordinate];
            _beginAnnotation.title        = @"起始点";
            _beginAnnotation.navPointType = NavPointAnnotationStart;
            [self.mapView addAnnotation:_beginAnnotation];
        }
    }
    else if (_selectPointState == MapSelectPointStateWayPoint)
    {
        if (_wayAnnotation)
        {
            _wayAnnotation.coordinate = coordinate;
        }
        else
        {
            _wayAnnotation = [[NavPointAnnotation alloc] init];
            [_wayAnnotation setCoordinate:coordinate];
            _wayAnnotation.title        = @"途径点";
            _wayAnnotation.navPointType = NavPointAnnotationWay;
            [self.mapView addAnnotation:_wayAnnotation];
        }
    }
    else if (_selectPointState == MapSelectPointStateEndPoint)
    {
        if (_endAnnotation)
        {
            _endAnnotation.coordinate = coordinate;
        }
        else
        {
            _endAnnotation = [[NavPointAnnotation alloc] init];
            [_endAnnotation setCoordinate:coordinate];
            _endAnnotation.title        = @"终 点";
            _endAnnotation.navPointType = NavPointAnnotationEnd;
            [self.mapView addAnnotation:_endAnnotation];
        }
    }
}


#pragma mark - Button Actions
/**
 *  模拟导航
 */
- (void)simulatorNavi:(id)sender
{
    
    _simuBtn.enabled = NO;
    
    _naviType = NavigationTypeSimulator;
    
    [self calRoute];
}

/**
 *  路径规划
 */
- (void)gpsNavi:(id)sender
{
    _routeBtn.enabled = NO;
    
    _naviType = NavigationTypeGPS;
    
    [self calRoute];
}


-(void)didSelectPointBtn:(int)tag
{
    switch (tag) {

        case 0:
            _startSlefPointBtn.selected = _startMapPointBtn.selected = _wayMapPointBtn.selected = _endMapPointBtn.selected = NO;
            break;
            
        case 1:
            
            _wayMapPointBtn.selected = _endMapPointBtn.selected = NO;
            break;
            
        default:
            break;
    }



}


//选择起、经、终点
- (void)selectPointState:(UIButton *)Btn
{
 
 
    
    if (Btn.tag == 1 || Btn.tag == 2)
    {
        Btn.selected = YES;
        
       //判断选中的点，是否在地图中，如果不在，则取消点
        if (!_wayAnnotation && _wayMapPointBtn.isSelected)
        {
            _wayMapPointBtn.selected = NO;
        }
        
        if (!_endAnnotation && _endMapPointBtn.isSelected)
        {
            _endMapPointBtn.selected = NO;
        }
        
        if ([Btn.currentTitle isEqualToString:@"地图选点"])
        {
            _startSlefPointBtn.selected = NO;
            
            _selectPointState = MapSelectPointStateStartPoint;
            _startCurrLoc = NO;
        }
        else if ([Btn.currentTitle isEqualToString:@"当前位置"])
        {
            _startMapPointBtn.selected = NO;
            
            if (_beginAnnotation)
            {
                [self.mapView removeAnnotation:_beginAnnotation];
                _beginAnnotation = nil;
            }
            _startCurrLoc = YES;
            if (_selectPointState == MapSelectPointStateStartPoint)
            {
                _selectPointState = MapSelectPointStateNone;
            }
        }
        else
        {
            _startCurrLoc = NO;
            if (_selectPointState == MapSelectPointStateStartPoint)
            {
                _selectPointState = MapSelectPointStateNone;
            }
        }
    }
    else if (Btn.tag == 6)
    {
        //判断选中的点，是否在地图中，如果不在，则取消点
        if(!_startCurrLoc && !_beginAnnotation && _startMapPointBtn.isSelected )
        {
            _startMapPointBtn.selected = NO;
            
        }
        
        if (!_endAnnotation && _endMapPointBtn.isSelected)
        {
            _endMapPointBtn.selected = NO;
        }
        
        
        if ( !Btn.isSelected)
        {
            Btn.selected = YES;
           _selectPointState = MapSelectPointStateWayPoint;

        }
        else  //删除途经点
        {

            Btn.selected = NO;
            
            [self.mapView removeAnnotation:_wayAnnotation];
  
            _wayAnnotation = nil;
            
            if (_selectPointState == MapSelectPointStateWayPoint)
            {
                _selectPointState = MapSelectPointStateNone;
            }
        }
    }
    else if (Btn.tag == 4)
    {
        
        //判断选中的点，是否在地图中，如果不在，则取消点
        if(!_startCurrLoc && !_beginAnnotation && _startMapPointBtn.isSelected )
        {
            _startMapPointBtn.selected = NO;
            
        }
        if (!_wayAnnotation && _wayMapPointBtn.isSelected)
        {
            _wayMapPointBtn.selected = NO;
        }
        
        
        if ( !Btn.isSelected)
        {
            Btn.selected = YES;
            _selectPointState = MapSelectPointStateEndPoint;
        }
        else  //删除终点
        {
            Btn.selected = NO;
            
            [self.mapView removeAnnotation:_endAnnotation];
            
            _endAnnotation = nil;
            
            if (_selectPointState == MapSelectPointStateEndPoint)
            {
                _selectPointState = MapSelectPointStateNone;
            }
        }
    }


}



- (void)calRoute
{
    NSArray *startPoints;
    NSArray *wayPoints;
    NSArray *endPoints;
    
    if (_wayAnnotation)
    {
        wayPoints = @[[AMapNaviPoint locationWithLatitude:_wayAnnotation.coordinate.latitude
                                                longitude:_wayAnnotation.coordinate.longitude]];
    }
    
    if (_endAnnotation)
    {
        endPoints = @[[AMapNaviPoint locationWithLatitude:_endAnnotation.coordinate.latitude
                                                longitude:_endAnnotation.coordinate.longitude]];
    }
    
    if (_beginAnnotation)
    {
        startPoints = @[[AMapNaviPoint locationWithLatitude:_beginAnnotation.coordinate.latitude
                                                  longitude:_beginAnnotation.coordinate.longitude]];
    }
    
    if (_startCurrLoc)//以当前位置为起点
    {
        if (endPoints.count > 0)
        {
            if (_travelType == TravelTypeCar)//驾车
            {
                [MBProgressHUD showMessage:@"正在规划路线..."];
                [self.naviManager calculateDriveRouteWithEndPoints:endPoints
                                                         wayPoints:wayPoints
                                                   drivingStrategy:AMapNaviDrivingStrategyDefault];
            }
            else if (_travelType == TravelTypeWalk)//走路
            {
                [MBProgressHUD showMessage:@"正在规划路线..."];
                [self.naviManager calculateWalkRouteWithEndPoints:endPoints];
            }
            return;
        }
    }
    else
    {
        if (startPoints.count > 0 && endPoints.count > 0) //起点从地图中选点
        {
            if (_travelType == TravelTypeCar)//驾车
            {
                [MBProgressHUD showMessage:@"正在规划路线..."];
                [self.naviManager calculateDriveRouteWithStartPoints:startPoints
                                                           endPoints:endPoints
                                                           wayPoints:wayPoints
                                                     drivingStrategy:AMapNaviDrivingStrategyDefault];
            }
            else if (_travelType == TravelTypeWalk) //步行
            {
                [MBProgressHUD showMessage:@"正在规划路线..."];
                [self.naviManager calculateWalkRouteWithStartPoints:startPoints endPoints:endPoints];
            }
            
            return;
        }
    }
    
    _routeBtn.enabled = YES;
    _simuBtn.enabled = YES;
    
    [MBProgressHUD showError:@"请选择完整的起始点"];
    
//    [self.view makeToast:@"请先在地图上选点"
//                duration:2.0
//                position:[NSValue valueWithCGPoint:CGPointMake(160, 240)]];

 //   [self viewWillAppear:YES];
    
}


#pragma mark - MAMapView Delegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[NavPointAnnotation class]])
    {
        static NSString *annotationIdentifier = @"annotationIdentifier";
        
        MAPinAnnotationView *pointAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (pointAnnotationView == nil)
        {
            pointAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                                  reuseIdentifier:annotationIdentifier];
        }
        
        pointAnnotationView.animatesDrop   = YES;
        pointAnnotationView.canShowCallout = NO;
        pointAnnotationView.draggable      = NO;
        
        NavPointAnnotation *navAnnotation = (NavPointAnnotation *)annotation;
        
        if (navAnnotation.navPointType == NavPointAnnotationStart)
        {
            pointAnnotationView.image = [UIImage imageNamed:@"navi_route_startpoint"];
        }
        else if (navAnnotation.navPointType == NavPointAnnotationWay)
        {
            pointAnnotationView.image = [UIImage imageNamed:@"navi_route_waypoint"];
        }
        else if (navAnnotation.navPointType == NavPointAnnotationEnd)
        {
            //[pointAnnotationView setPinColor:MAPinAnnotationColorRed]; 
            pointAnnotationView.image = [UIImage imageNamed:@"navi_route_endpoint"];
            
        }
        return pointAnnotationView;
    }
    
    return nil;
}


- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        polylineView.lineWidth = 5.0f;
        polylineView.strokeColor = [UIColor redColor];
        
        return polylineView;
    }
    return nil;
}


//此方法调用频率高
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation{
    
    //停止定位
    //self.mapView.showsUserLocation = NO;
    // 第一次定位时才将定位点显示图中心
    if (!_hasCurrLoc)
    {
        _hasCurrLoc = YES;
        
        [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
        [self.mapView setZoomLevel:15 animated:YES];
    }

}


//- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
//{
//    // 第一次定位时才将定位点显示图中心
//    if (!_hasCurrLoc)
//    {
//        _hasCurrLoc = YES;
//    
//        [self.mapView setCenterCoordinate:userLocation.coordinate];
//        [self.mapView setZoomLevel:15 animated:YES];
//    }
////
//        NSLog(@"dddd");
//}


#pragma mark - AMapNaviManager Delegate

- (void)AMapNaviManager:(AMapNaviManager *)naviManager didPresentNaviViewController:(UIViewController *)naviViewController
{
    [super AMapNaviManager:naviManager didPresentNaviViewController:naviViewController];
    
    // 初始化语音引擎
    [self initIFlySpeech];
    
    if (_naviType == NavigationTypeGPS)
    {
        [self.naviManager startGPSNavi];
    }
    else if (_naviType == NavigationTypeSimulator)
    {
        [self.naviManager startEmulatorNavi];
    }
}


- (void)AMapNaviManagerOnCalculateRouteSuccess:(AMapNaviManager *)naviManager
{
    [super AMapNaviManagerOnCalculateRouteSuccess:naviManager];
    
    if (_naviType == NavigationTypeGPS)
    {
        [MBProgressHUD hideHUD];
        _routeBtn.enabled = YES;
        
        // 如果_routeShowVC不为nil，说明是偏航重算导致的算路，什么也不做
        if (!_routeShowVC)
        {
            RouteShowViewController *routeShowVC = [[RouteShowViewController alloc] initWithNavManager:naviManager
                                                                naviController:_naviViewController
                                                                       mapView:self.mapView];
            
            
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
            self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
            self.navigationItem.backBarButtonItem = backItem;
            
            
            [self.navigationController pushViewController:routeShowVC animated:YES];
            
            self.routeShowVC = routeShowVC;
        }
    }
    else if (_naviType == NavigationTypeSimulator)
    {
        _simuBtn.enabled = YES;
        [MBProgressHUD hideHUD];
        
        [self.naviManager presentNaviViewController:self.naviViewController animated:YES];
    }
}


- (void)AMapNaviManager:(AMapNaviManager *)naviManager onCalculateRouteFailure:(NSError *)error
{
    [MBProgressHUD hideHUD];
    
    _routeBtn.enabled = YES;
    _simuBtn.enabled = YES;
    
    //算路失败
    [super AMapNaviManager:naviManager onCalculateRouteFailure:error];
    
    [self configMapView];
    [self initSettingState];
    [self didSelectPointBtn:0];
}



#pragma mark - AManNaviViewController Delegate


- (void)AMapNaviViewControllerCloseButtonClicked:(AMapNaviViewController *)naviViewController
{
    [self.iFlySpeechSynthesizer stopSpeaking];
    
    self.iFlySpeechSynthesizer.delegate = nil;
    self.iFlySpeechSynthesizer          = nil;
    
    [self.naviManager stopNavi];
    [self.naviManager dismissNaviViewControllerAnimated:YES];
    
    if (_naviType == NavigationTypeGPS)
    {
        [self.mapView setDelegate:self];
        
        [_routeShowVC configMapView];
    }
    else
    {
        [self configMapView];
        [self initSettingState];
        [self didSelectPointBtn:0];
    }
}


- (void)AMapNaviViewControllerMoreButtonClicked:(AMapNaviViewController *)naviViewController
{
    if (self.naviViewController.viewShowMode == AMapNaviViewShowModeCarNorthDirection)
    {
        self.naviViewController.viewShowMode = AMapNaviViewShowModeMapNorthDirection;
    }
    else
    {
        self.naviViewController.viewShowMode = AMapNaviViewShowModeCarNorthDirection;
    }
}


- (void)AMapNaviViewControllerTrunIndicatorViewTapped:(AMapNaviViewController *)naviViewController
{
    [self.naviManager readNaviInfoManual];
}


#pragma mark - SegCtrl Event

- (void)segCtrlClick:(id)sender
{
    UISegmentedControl *segCtrl = (UISegmentedControl *)sender;
    
    TravelTypes travelType = segCtrl.selectedSegmentIndex == 0 ? TravelTypeWalk : TravelTypeCar;
    
    if (travelType != _travelType)
    {
        _travelType = travelType;
        
        [self initSettingState];
        [self didSelectPointBtn:0];
        
        if (_travelType == TravelTypeWalk)
        {
            _wayPointLabel.userInteractionEnabled = NO;
            _wayMapPointBtn.userInteractionEnabled = NO;
            
            [_wayPointLabel setAlpha:0.3];
            [_wayMapPointBtn setAlpha:0.3];
            
        }
        else
        {
            _wayPointLabel.userInteractionEnabled = YES;
            _wayMapPointBtn.userInteractionEnabled = YES;
            
            [_wayPointLabel setAlpha:1];
            [_wayMapPointBtn setAlpha:1];
        }
    }
}

@end
