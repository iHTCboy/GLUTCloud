//
//  LZSelectLocationMapViewController.m
//  maidaojia
//
//  Created by bailin on 14-6-21.
//  Copyright (c) 2014年 BaiLin. All rights reserved.
//

#import "ReSelectLocationMapViewController.h"
#import "ReselectCoordinateView.h"
#import "appMarco.h"


@interface ReSelectLocationMapViewController ()


/**
 *  这个中心点是地国的中心点，比逆编码返回的GPS值精度更高
 */
@property (strong, nonatomic) MAPointAnnotation * centerAnnotation;
@property (strong, nonatomic) ReselectCoordinateView * coordinateView;
/**
 *  逆地理编码结果
 */
@property (strong, nonatomic) AMapReGeocodeSearchResponse * responseAdds;

@end

@implementation ReSelectLocationMapViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.mapView.delegate = nil;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textColor        = [UIColor whiteColor];
    titleLabel.font             = [UIFont boldSystemFontOfSize:18];
    titleLabel.text             = @"添加当前位置";
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    

    //设置地图搜索
    self.search = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:nil];
    self.search.delegate = self;
    
    
    //配置地图视图
    if (self.mapView == nil)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    }
    self.mapView.frame = self.view.bounds;
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.showsCompass = NO;
    self.mapView.showsScale = NO;
//    self.mapView.visibleMapRect = MAMapRectMake(110880104, 251476980, 272496, 466656);
    
    
    //默认桂林坐标
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(25.2568222416, 110.2544278592) animated:YES];
    [self.mapView setZoomLevel:16.0f];
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];

    //地图中心的annotation
    _centerAnnotation = [[MAPointAnnotation alloc] init];
    _centerAnnotation.coordinate = self.mapView.centerCoordinate;
    //[self.mapView addAnnotation:_centerAnnotation];
    
    
    //gps坐标显示视图
    _coordinateView = [[ReselectCoordinateView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 300)/2, 10, 300, 70)];
    _coordinateView.layer.cornerRadius = 3.0f;
    _coordinateView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _coordinateView.layer.borderWidth = 1.0f;
    _coordinateView.clipsToBounds = YES;
    [_coordinateView.btnOk addTarget:self action:@selector(confirmCurrtentGpsLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_coordinateView];
    [self.view bringSubviewToFront:_coordinateView];
    
    //如果没有初始位置，定位自己当前位置
    if (_initialLocation==nil) {
        [self relocationMyCoordinate];
    }else{
        [_coordinateView.lblGpsCoordinate setText:[NSString stringWithFormat:@"(%f,%f)",_initialLocation.coordinate.longitude,_initialLocation.coordinate.latitude]];
        [self.mapView setCenterCoordinate:_initialLocation.coordinate];
        //通过坐标查询地址名
        [self searchReGeocodeWithLocation:_initialLocation.coordinate];
    }
    
    //定位用户当前坐标按钮
    UIButton * btnLocation = [UIButton buttonWithType:UIButtonTypeCustom];
    //btnLocation.autoresizingMask = UIViewAutoresizingFlexibleTopMargin || UIViewAutoresizingFlexibleLeftMargin;
    [btnLocation setBackgroundColor:[UIColor clearColor]];
    [btnLocation setBackgroundImage:[UIImage imageNamed:@"default_main_gpsbutton_background_normal"] forState:UIControlStateNormal];
    //[btnLocation setBackgroundImage:[UIImage imageNamed:@"default_main_gpsbutton_background_normal"] forState:UIControlStateHighlighted];
    [btnLocation setImage:[UIImage imageNamed:@"default_main_gpsnormalbutton_image_normal"] forState:UIControlStateNormal];
    [btnLocation setImage:[UIImage imageNamed:@"default_main_gpsnormalbutton_image_disabled"] forState:UIControlStateHighlighted];
    [btnLocation setContentMode:UIViewContentModeCenter];
    [btnLocation setFrame:CGRectMake(self.view.bounds.size.width-75, self.view.bounds.size.height-75, 55, 55)];
    [btnLocation setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin];
    [btnLocation addTarget:self action:@selector(relocationMyCoordinate) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnLocation];
    [self.view bringSubviewToFront:btnLocation];
    
    //中心点位置视图
    CGPoint centerPoint = [self.mapView center];
    centerPoint = [self.mapView convertPoint:centerPoint toView:self.view];
    UIImage * anImg = [UIImage imageNamed:@"newpoi_normal"];
    UIImageView *centerImageView = [[UIImageView alloc]initWithImage:anImg];
    [centerImageView setFrame:CGRectMake(centerPoint.x-anImg.size.width/2, centerPoint.y-anImg.size.height-22, anImg.size.width, anImg.size.height)];
    [self.view addSubview:centerImageView];
    [self.view bringSubviewToFront:centerImageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 定位用户当前坐标按钮点击事件
- (void)relocationMyCoordinate
{
    //开始定位
   self.mapView.showsUserLocation = YES;
   
}

#pragma mark - 返回按钮点击事件
- (void)jumpBack:(id)sender{
    //
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Gps显示视图确定按钮点击事件
- (void)confirmCurrtentGpsLocation:(id)sender{

    //执行委托方法
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(selectLocationDidResponse:WithSelectLocation:)]) {
            [self.delegate selectLocationDidResponse:self.responseAdds WithSelectLocation:_centerAnnotation.coordinate];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

/* 逆地理编码 搜索. */
- (void)searchReGeocodeWithLocation:(CLLocationCoordinate2D )coordinate
{
    //更新gps显示视图
    [_coordinateView.lblGpsCoordinate setText:@"正在搜索中..."];
    
    AMapReGeocodeSearchRequest *reGeo = [[AMapReGeocodeSearchRequest alloc] init];
    reGeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];

    [self.search AMapReGoecodeSearch:reGeo];
}

/*查询timeout*/
- (void)search:(id)searchRequest error:(NSString*)errInfo{
    //NSLog(@"errInfo:%@",errInfo);
    [self.coordinateView.lblGpsCoordinate setText:[NSString stringWithFormat:@"(%f,%f)",self.mapView.centerCoordinate.longitude,self.mapView.centerCoordinate.latitude]];
}

#pragma mark - AMapSearchDelegate
/* 地理编码回调.*/
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    
    self.responseAdds = response;
    
    NSLog(@"response:%@",response);
    if (response.regeocode.formattedAddress) {
        [self.coordinateView.lblGpsCoordinate setText:[NSString stringWithFormat:@"%@(%f,%f)",response.regeocode.formattedAddress,self.mapView.centerCoordinate.longitude,self.mapView.centerCoordinate.latitude]];

    }else{
        [self.coordinateView.lblGpsCoordinate setText:[NSString stringWithFormat:@"(%f,%f)",self.mapView.centerCoordinate.longitude,self.mapView.centerCoordinate.latitude]];
    }
    
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation{
    //停止定位
    self.mapView.showsUserLocation = NO;
    //定位到用户当前位置
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];

}

- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    [self.coordinateView.lblGpsCoordinate setText:@"拖动地图选择位置"];
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    //NSLog(@"self.mapView.center:%@",NSStringFromCGPoint(self.mapView.center));
    
    //搜索新地址
    [self searchReGeocodeWithLocation:self.mapView.centerCoordinate];
    
    [UIView animateWithDuration:0.3 animations:^{
        _centerAnnotation.coordinate = self.mapView.centerCoordinate;
    }];
    
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
//    //如果是用户当前位置的点，返回nil,即不显示用户小蓝点
//    if (annotation isKindOfClass:[MAAnnotation class]]){
//        return nil;
//    }
//    if (annotation == self.mapView.userLocation){
//        return nil;
//    }
    
//    if ([annotation isKindOfClass:[MAPointAnnotation class]]){
        static NSString *geoCellIdentifier = @"locationCellIdentifier";
        
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:geoCellIdentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:geoCellIdentifier];
        }
        
        annotationView.image = [UIImage imageNamed:@"newpoi_normal"];
        
        return annotationView;
//    }
//    
//    return nil;
}



@end
