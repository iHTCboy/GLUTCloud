//
//  PoiViewController.m
//  SearchV3Demo
//
//  Created by songjian on 13-8-14.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "PoiViewController.h"
#import "POIAnnotation.h"
#import "PoiDetailViewController.h"
#import "CommonUtility.h"
#import "TCSearchResultsVC.h"

#define GeoPlaceHolder @"周边搜索"

@interface PoiViewController ()<UISearchBarDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>

{

     BOOL _hasCurrLoc; //是否要定位当前位置

}

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchController *displayController;
@property (nonatomic, strong) NSMutableArray *searchResultAnnos;

@property (nonatomic, assign)  CLLocationCoordinate2D center2D;

@end

@implementation PoiViewController



#pragma mark - Initialization 初始化搜索框

- (void)initSearchBar
{

}

- (void)initSearchDisplay
{
    TCSearchResultsVC *sr = [[TCSearchResultsVC alloc] init];
    sr.tableView.delegate = self;
    sr.tableView.dataSource = self;
    
    self.displayController = [[UISearchController alloc] initWithSearchResultsController:sr];

    self.displayController.searchResultsUpdater = self;

    self.displayController.dimsBackgroundDuringPresentation = NO;

    [self.displayController.searchBar sizeToFit];

    
    self.displayController.searchBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44);
    self.searchBar = self.displayController.searchBar;
    [self.view addSubview:self.searchBar];

}

#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self aroundLocalSearchWithKey:searchController.searchBar.text];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResultAnnos.count;
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
    
    AMapPOI * aPOI = self.searchResultAnnos[indexPath.row];
    
    cell.textLabel.text = aPOI.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ 【距离我:%ld米】",aPOI.address,(long)aPOI.distance];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //1.关闭搜索框
    [self.displayController dismissViewControllerAnimated:YES completion:nil];
    
    //2、设置为中心点
    AMapPOI * aPOI = self.searchResultAnnos[indexPath.row];
    POIAnnotation *ann = [[POIAnnotation alloc]initWithPOI:aPOI];
    CLLocationCoordinate2D centerCoordinate;
    centerCoordinate.latitude = aPOI.location.latitude;
    centerCoordinate.longitude = aPOI.location.longitude;
    
    [self.mapView setZoomLevel:16.0f animated:YES];
    [self.mapView setCenterCoordinate:centerCoordinate];
    
    //3、显示标题
    [self performSelector:@selector(beSelectAnnotation:) withObject:ann afterDelay:0.4];
    //[self.mapView selectAnnotation:ann animated:YES];
    
     self.searchBar.placeholder = aPOI.name;
}

//显示Annotation
-(void)beSelectAnnotation:(POIAnnotation *)obj
{
    [self.mapView addAnnotation:obj];
    [self.mapView selectAnnotation:obj animated:YES];

}


#pragma mark - 点击搜索按钮隐藏
-(void)toSearchLocation
{
    self.searchBar.hidden = !self.searchBar.hidden;
    
}

#pragma mark - 定位用户当前坐标按钮点击事件
- (void)locationBtn
{
    
    _hasCurrLoc = NO;
    //开始定位
    self.mapView.showsUserLocation = YES;
}

#pragma mark - 本地关键字搜索
- (void)aroundLocalSearchWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    
    request.searchType          = AMapSearchType_PlaceAround;
    request.radius              = 5000; //默认3000
    //request.location            = [AMapGeoPoint locationWithLatitude:25.063072 longitude:110.303577];
    //如果定位成功，就以定位点为中心
    if (_hasCurrLoc) {
        
       request.location         = [AMapGeoPoint locationWithLatitude:self.center2D.latitude longitude:self.center2D.longitude];
    
    }
    else
    {
       request.location         = [AMapGeoPoint locationWithLatitude:39.990459 longitude:116.481476];
    }


    request.keywords            = key;
    /* 按照距离排序. */
    request.sortrule            = 1;
    request.offset              = 200;
    request.page                = 1;
    request.requireExtension    = YES;
    
    /* 添加搜索结果过滤 */
    //    AMapPlaceSearchFilter *filter = [[AMapPlaceSearchFilter alloc] init];
    //    filter.costFilter = @[@"0", @"10000"];
    //    filter.requireFilter = AMapRequireGroupbuy;
    //    request.searchFilter = filter;
    //
    [self.search AMapPlaceSearch:request];

}

#pragma mark - 初始化大头针

//初始化大头针
- (void)addAnnotationsWithPOIs:(NSArray *)pois
{
    
    for (id<MAAnnotation> annotation in  self.mapView.annotations)
    {
        
        //如果不是用户当前位置的点，即不是用户的小蓝点，就删除
        if ([annotation isKindOfClass:[POIAnnotation class]])
        {
            [self.mapView removeAnnotation:annotation];
        }
    }
    
    
    for (AMapPOI *aPOI in pois)
    {
        // NSLog(@"%@",aPOI);

        POIAnnotation *ann = [[POIAnnotation alloc]initWithPOI:aPOI];
        [self.mapView addAnnotation:ann];
    }
    
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];
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
        self.center2D = userLocation.coordinate;
        [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
        [self.mapView setZoomLevel:16 animated:YES];
    }
    
    
}


- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id<MAAnnotation> annotation = view.annotation;
    
    if ([annotation isKindOfClass:[POIAnnotation class]])
    {
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationItem.backBarButtonItem = backItem;
        
        
        POIAnnotation *poiAnnotation = (POIAnnotation*)annotation;
        PoiDetailViewController *detail = [[PoiDetailViewController alloc] init];
        detail.poi = poiAnnotation.poi;
        
        /* 进入POI详情页面. */
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[POIAnnotation class]])
    {
        static NSString *poiIdentifier = @"poiIdentifier";
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:poiIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                                reuseIdentifier:poiIdentifier];
        }
        
        poiAnnotationView.canShowCallout            = YES;
        poiAnnotationView.image = [UIImage imageNamed:@"cloudPoint"];
        UIButton * rightAccessoryView= [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        rightAccessoryView.tintColor = [UIColor colorWithRed:0.270 green:0.633 blue:1.000 alpha:1];
        poiAnnotationView.rightCalloutAccessoryView = rightAccessoryView;
        
        return poiAnnotationView;
    }
    
    return nil;
}

#pragma mark - AMapSearchDelegate

/* POI 搜索回调. */
- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)respons
{
    
    [self.searchResultAnnos setArray:respons.pois];
    
    [self addAnnotationsWithPOIs:[respons pois]];
    
    UITableView *tbv = [(UITableViewController *)self.displayController.searchResultsController tableView];
    [tbv reloadData];
    
    
    UILabel * counts = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    
    counts.textAlignment = NSTextAlignmentCenter;
    counts.textColor = appMainColor;
    counts.text = [NSString stringWithFormat:@"共搜索到%ld条",respons.count];
    
    tbv.tableHeaderView = counts;
}

- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{

    NSLog(@"search Error");


}

#pragma mark - Utility

/* 根据中心点坐标来搜周边的POI. */
- (void)searchPoiByCenterCoordinate
{
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    
    request.searchType          = AMapSearchType_PlaceAround;
    request.location            = [AMapGeoPoint locationWithLatitude:25.063072 longitude:110.303577];
    //request.location            = [AMapGeoPoint locationWithLatitude:39.990459 longitude:116.481476];
    request.keywords            = @"ATM";
    /* 按照距离排序. */
    request.sortrule            = 1;
    request.requireExtension    = YES;
    
    /* 添加搜索结果过滤 */
//    AMapPlaceSearchFilter *filter = [[AMapPlaceSearchFilter alloc] init];
//    filter.costFilter = @[@"0", @"10000"];
//    filter.requireFilter = AMapRequireGroupbuy;
//    request.searchFilter = filter;
//    
    [self.search AMapPlaceSearch:request];
}



/* 根据ID来搜索POI. */
//- (void)searchPoiByID
//{
//    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
//    //    B000A80WBJ    hotel
//    //    B00141IEZK    dining
//    //    B000A876EH    cinema
//    //    B000A7O1CU    scenic
//    request.searchType          = AMapSearchType_PlaceID;
//    request.uid                 = @"B000A07060";
//    request.requireExtension    = YES;
//
//    [self.search AMapPlaceSearch:request];
//
//}

/* 根据关键字来搜索POI. */
//- (void)searchPoiByKeyword
//{
//    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
//
//    request.searchType          = AMapSearchType_PlaceKeyword;
//    request.keywords            = @"肯德基";
//    request.city                = @[@"桂林"];
//    request.requireExtension    = YES;
//    [self.search AMapPlaceSearch:request];
//}


///* 在指定的范围内搜索POI. */
//- (void)searchPoiByPolygon
//{
//    NSArray *points = [NSArray arrayWithObjects:
//                       [AMapGeoPoint locationWithLatitude:39.990459 longitude:116.481476],
//                       [AMapGeoPoint locationWithLatitude:39.890459 longitude:116.581476],
//                       nil];
//    AMapGeoPolygon *polygon = [AMapGeoPolygon polygonWithPoints:points];
//    
//    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
//    
//    request.searchType          = AMapSearchType_PlacePolygon;
//    request.polygon             = polygon;
//    request.keywords            = @"Apple";
//    request.requireExtension    = YES;
//    
//    [self.search AMapPlaceSearch:request];
//}

- (void)clearSearchPois
{
    /* 清除存在的annotation. */
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    //移除覆盖层
    [self.mapView removeOverlays:self.mapView.overlays];
    
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
    titleLabel.text             = @"周边搜索";
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    //导航条右栏，选择地址按钮
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"searchBtn"] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, 23, 23)];
    [button addTarget:self action:@selector(toSearchLocation) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
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



#pragma mark - Life Cycle

- (id)init
{
    if (self = [super init])
    {
        self.searchResultAnnos = [NSMutableArray array];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavBar];
    
    [self clearSearchPois];
    
    [self initMapView];
    
    [self initLocationBtn];
    
    [self initSearchBar];
    
    [self initSearchDisplay];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.mapView.delegate = self;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    self.mapView.delegate = nil;
}

@end
