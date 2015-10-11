//
//  CloudPlaceAroundSearchViewController.m
//  AMapCloudDemo
//
//  Created by 刘博 on 14-3-11.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import "CloudPlaceAroundSearchViewController.h"
#import "AMapCloudPOIDetailViewController.h"
#import "CloudPOIAnnotation.h"
//#import <MAMapKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>

#define GeoPlaceHolder @"桂工云图搜索"

@interface CloudPlaceAroundSearchViewController ()<UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *displayController;

@property (nonatomic, strong) NSMutableArray *tips;

@end

@implementation CloudPlaceAroundSearchViewController

#pragma mark - Life Cycle
- (id)init
{
    if (self = [super init])
    {
        self.tips = [NSMutableArray array];
    }
    
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.circle)
    {
        //移除覆盖层
        [self.mapView removeOverlay:self.circle];


    }
    
    //重新搜索云图数据
    [self cloudPlaceAroundSearch];
    
    self.mapView.delegate = self;


}


-(void)viewDidDisappear:(BOOL)animated
{

    [super viewDidDisappear:animated];
    //移除覆盖层
    [self.mapView removeOverlay:self.circle];

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
    titleLabel.text             = @"桂工云图";
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    
    
    //导航条右栏，选择地址按钮
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"searchBtn"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, 23, 23)];
    [button addTarget:self action:@selector(toSearchLocation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    
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
    

    
    [self initSearchBar];
    
    [self initSearchDisplay];
}

#pragma mark - Initialization 初始化搜索框

- (void)initSearchBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    self.searchBar.barStyle     = UIBarStyleDefault;
    self.searchBar.translucent  = YES;
    self.searchBar.delegate     = self;
    self.searchBar.placeholder  = GeoPlaceHolder;
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    self.searchBar.backgroundColor = [UIColor colorWithRed:1.000 green:0.996 blue:0.988 alpha:0.900];
    self.searchBar.tintColor = [UIColor colorWithRed:0.332 green:0.487 blue:1.000 alpha:1.000];
    self.searchBar.hidden = YES;
    [self.view addSubview:self.searchBar];
}

- (void)initSearchDisplay
{
    self.displayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.displayController.delegate                = self;
    self.displayController.searchResultsDataSource = self;
    self.displayController.searchResultsDelegate   = self;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *key = searchBar.text;
    
    [self cloudPlaceLocalSearchWithKey:key];
    
    [self.displayController setActive:NO animated:YES];
    
    self.searchBar.placeholder = key;
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self cloudPlaceLocalSearchWithKey:searchString];
    return YES;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tips.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tipCellIdentifier = @"tipCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tipCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:tipCellIdentifier];
    }
    
    AMapCloudPOI *cloudPOI = self.tips[indexPath.row];
 
    cell.textLabel.text = cloudPOI.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"【%@】  距离我%ld 米",[cloudPOI.customFields valueForKey:@"type"],(long)cloudPOI.distance];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AMapCloudPOI * cloudPOI = self.tips[indexPath.row];
   
    [self.mapView setZoomLevel:16.0f];
    
    CloudPOIAnnotation *ann = [[CloudPOIAnnotation alloc] initWithCloudPOI:cloudPOI];
    [self.mapView addAnnotation:ann];
    
    [self.mapView selectAnnotation:ann animated:YES];
    
    [self.displayController setActive:NO animated:NO];
    
    self.searchBar.placeholder = cloudPOI.name;
}


#pragma mark - 点击搜索按钮处理事件
-(void)toSearchLocation
{
    self.searchBar.hidden = !self.searchBar.hidden;
    
}

#pragma mark - 用户点击定位按钮处理事件
- (void)locationMyCoordinate:(id)sender
{
    [self.mapView removeOverlay:self.circle];

    //重新搜索云图数据
    [self cloudPlaceAroundSearch];
    
}


#pragma mark - 云图本地关键字搜索
- (void)cloudPlaceLocalSearchWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    
    [self.mapView removeOverlay:self.circle];
    
    AMapCloudPlaceLocalSearchRequest *placeLocal = [[AMapCloudPlaceLocalSearchRequest alloc] init];
    
    [placeLocal setTableID:(NSString *)tableID];
    [placeLocal setCity:@"全国"];
    [placeLocal setKeywords:key];
    
    [self.cloudAPI AMapCloudPlaceLocalSearch:placeLocal];
}

#pragma mark - AMapCloudSearchDelegate
//云图搜索结果返回
- (void)onCloudPlaceAroundSearchDone:(AMapCloudPlaceAroundSearchRequest *)request response:(AMapCloudSearchResponse *)response
{
    // NSLog(@"status:%ld ,info:%@ ,count:%ld",(long)response.status, response.info, (long)response.count);
    
    [self addAnnotationsWithPOIs:[response POIs]];
    
}


//本地搜索结果
- (void)onCloudPlaceLocalSearchDone:(AMapCloudPlaceLocalSearchRequest *)request response:(AMapCloudSearchResponse *)response
{
    //NSLog(@"status:%ld ,info:%@ ,count:%ld",(long)response.status, response.info, (long)response.count);
    
    [self.tips setArray:response.POIs];
    
    [self addAnnotationsWithPOIs:[response POIs]];
    
    [self.displayController.searchResultsTableView reloadData];
    
    UILabel * counts = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    
    counts.textAlignment = NSTextAlignmentCenter;
    counts.textColor = appMainColor;
    counts.text = [NSString stringWithFormat:@"共搜索到%ld条",response.count];
    
    self.displayController.searchResultsTableView.tableHeaderView = counts;
}



#pragma mark - 初始化大头针

//初始化大头针
- (void)addAnnotationsWithPOIs:(NSArray *)pois
{
    

    for (id<MAAnnotation> annotation in  self.mapView.annotations)
    {
        
        //如果不是用户当前位置的点，即不显示用户小蓝点，就删除
         if ([annotation isKindOfClass:[CloudPOIAnnotation class]])
         {
             [self.mapView removeAnnotation:annotation];
         }
    }
    
    
    for (AMapCloudPOI *aPOI in pois)
    {
       // NSLog(@"%@",aPOI);
        
        CloudPOIAnnotation *ann = [[CloudPOIAnnotation alloc] initWithCloudPOI:aPOI];
        [self.mapView addAnnotation:ann];
    }
    
  
    
    //判断GPS数据来源
    NSUserDefaults * defaults =  [NSUserDefaults standardUserDefaults];
    //判断用户是否存储了设置，如果YES，则使用定位点，否则使用glutGPS
    if(![defaults boolForKey:@"glutSwitchIsOn"])
    {
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(25.063072,110.303577);
    }
    
    
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
}


#pragma mark - 跳转到详细页
- (void)gotoDetailForCloudPOI:(AMapCloudPOI *)cloudPOI
{
    if (cloudPOI != nil)
    {
        AMapCloudPOIDetailViewController *cloudPOIDetailViewController = [[AMapCloudPOIDetailViewController alloc] init];
        cloudPOIDetailViewController.cloudPOI = cloudPOI;
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationItem.backBarButtonItem = backItem;
        
        [self.navigationController pushViewController:cloudPOIDetailViewController animated:YES];
    }
}


#pragma mark - 增加覆盖层
- (void)addMACircleViewWithCenter:(CLLocationCoordinate2D)center radius:(double)radius
{
    MACircle *circle = [MACircle circleWithCenterCoordinate:center radius:radius];
    
    self.circle = circle;
    
    [self.mapView addOverlay:self.circle];
}

#pragma mark - Cloud Search 周边检索
//定义云图搜索的条件
- (void)cloudPlaceAroundSearch
{
    AMapCloudPlaceAroundSearchRequest *placeAround = [[AMapCloudPlaceAroundSearchRequest alloc] init];
    [placeAround setTableID:(NSString *)tableID];
    
    //检索圈为1000米
    double radius = 1000;
    
    //判断GPS数据来源
    NSUserDefaults * defaults =  [NSUserDefaults standardUserDefaults];
    
    AMapCloudPoint * centerPoint;
    
    //判断用户是否存储了设置，如果YES，则使用定位点，否则使用glutGPS
    if([defaults boolForKey:@"glutSwitchIsOn"])
    {
        self.mapView.showsUserLocation = YES;
        centerPoint = [AMapCloudPoint locationWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
       
    }
    else
    {
        self.mapView.showsUserLocation = NO;
        
        NSDictionary *glutGPS =  [defaults valueForKey:@"glutGPS"];
        
        centerPoint = [AMapCloudPoint locationWithLatitude:[[glutGPS valueForKey:@"latitude"]floatValue] longitude:[[glutGPS valueForKey:@"longitude"] floatValue]];
        
    }

    //设置中心点和半径
    [placeAround setRadius:radius];
    [placeAround setCenter:centerPoint];
    
    
    
     //NSLog(@"latitude : %f,longitude: %f",self.coordinate.latitude,self.coordinate.longitude);
    //设置关键字
    //[placeAround setKeywords:@"桂林"];

    //过滤条件数组filters的含义等同于SQL语句:WHERE _address = "文津街1" AND _id BETWEEN 20 AND 40
    //NSArray *filters = [[NSArray alloc] initWithObjects:@"_id:[0,70]", @"_address:桂林", nil];
    //[placeAround setFilter:filters];
    
    //设置排序方式
//    [placeAround setSortFields:@"_id"];
//    [placeAround setSortType:AMapCloudSortType_DESC];
    
    //设置每页记录数和当前页数
    [placeAround setOffset:100];
//    [placeAround setPage:2];
    
    /*!
     @brief 周边查询接口函数，即根据参数选项进行周边查询。
     @param request 查询选项。具体属性字段请参考 AMapCloudPlaceAroundSearchRequest 类。
     */
    [self.cloudAPI AMapCloudPlaceAroundSearch:placeAround];
    
    //设置覆盖层的中心点
    [self addMACircleViewWithCenter:CLLocationCoordinate2DMake(centerPoint.latitude, centerPoint.longitude) radius:radius];
}



#pragma mark - MAMapViewDelegate
//点击大头针时，根据anntation生成对应的View
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{

    
    if ([annotation isKindOfClass:[CloudPOIAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"PlaceAroundSearchIndetifier";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout   = YES;
        annotationView.animatesDrop     = NO;
        annotationView.image = [UIImage imageNamed:@"cloudPoint"];
        UIButton * rightAccessoryView= [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        rightAccessoryView.tintColor = [UIColor colorWithRed:0.270 green:0.633 blue:1.000 alpha:1];
        
        annotationView.rightCalloutAccessoryView = rightAccessoryView;
        
        return annotationView;
    }
    
    return nil;
}

#pragma mark - 定义覆盖圈的范围
//- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
//{
//    if ([overlay isKindOfClass:[MACircle class]])
//    {
//        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
//        
//        circleRenderer.lineWidth        = 1.f;
//        circleRenderer.lineDashPattern  = @[@"5", @"5"];
//        circleRenderer.strokeColor      = [UIColor redColor];
//        circleRenderer.fillColor        = [UIColor colorWithRed:1.000 green:0.713 blue:0.096 alpha:0.300];
//        
//        return circleRenderer;
//    }
//    
//    return nil;
//}
#pragma mark - 定义覆盖圈的范围
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id <MAOverlay>)overlay
{

        if ([overlay isKindOfClass:[MACircle class]])
        {
            MACircleView *circleView = [[MACircleView alloc] initWithCircle:overlay];
    
            circleView.lineWidth        = 2.f;
//            circleView.lineJoin     = kCALineCapRound;
//            circleView.lineCapType      = kCALineCapRound;
            circleView.miterLimit       = 1.0f;
            circleView.strokeColor      = [UIColor colorWithRed:0.183 green:0.343 blue:0.936 alpha:0.710];
            circleView.fillColor        = [UIColor whiteColor];
    
            return circleView;
        }
        
        return nil;


}

#pragma mark - 点击标注view的accessory view(必须继承自UIControl)，触发该回调
- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[CloudPOIAnnotation class]])
    {
        [self gotoDetailForCloudPOI:[(CloudPOIAnnotation *)view.annotation cloudPOI]];
    }
}

@end
