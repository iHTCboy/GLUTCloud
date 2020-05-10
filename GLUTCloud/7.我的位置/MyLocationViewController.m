//
//  MyLocationViewController.m
//  GLUTCloud
//
//  Created by HTC on 15/1/3.
//  Copyright (c) 2015年 HTC. All rights reserved.
//

#import "MyLocationViewController.h"
#import "MBProgressHUD+MJ.h"


#define margin 10
#define LabelWidth 100
#define LabelHight 30
#define viewWidth self.view.frame.size.width
#define viewHight self.view.frame.size.height

@interface MyLocationViewController ()<MAMapViewDelegate,AMapSearchDelegate>

@property (strong, nonatomic) AMapSearchAPI * search;

/**
 *  控件
 */
@property (nonatomic, strong) UILabel *  provinceNameLabel;
@property (nonatomic, strong) UILabel *  cityNameLabel;
@property (nonatomic, strong) UILabel *  districtNameLabel;
@property (nonatomic, strong) UILabel *  townshipNameLabel;
@property (nonatomic, strong) UILabel *  streetAndNumberLabel;
@property (nonatomic, strong) UILabel *  locationNameLabel;
@property (nonatomic, strong) UILabel *  citycodeNameLabel;
@property (nonatomic, strong) UILabel *  adcodeNameLabel;
@property (nonatomic, strong) UITextView *  detailedAddressF;
@property (nonatomic, strong) UIButton * reLocatioBtn;


@end

@implementation MyLocationViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.mapView.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
     self.mapView.delegate = nil;
}



#pragma mark - viewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textColor        = [UIColor whiteColor];
    titleLabel.font             = [UIFont boldSystemFontOfSize:18];
    titleLabel.text             = @"我的位置";
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    //添加控件
    [self addContentView];
    
    if (self.mapView == nil) {
        self.mapView=[[MAMapView alloc] initWithFrame:CGRectZero];
    }
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.showsUserLocation = YES;    //YES 为打开定位，NO为关闭定位
    
    if (self.search == nil) {
        
        //设置地图搜索
        self.search = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:nil];
        self.search.delegate = self;
    }
    
}


#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
{
    //取出当前位置的坐标
    self.locationNameLabel.text = [NSString stringWithFormat:@"%f,%f", userLocation.coordinate.longitude,userLocation.coordinate.latitude];
    // [MBProgressHUD showSuccess:@"定位成功"];
    
    //通过坐标查询地址名
    [self searchReGeocodeWithLocation:userLocation.coordinate];
    
    //停止定位
    self.mapView.showsUserLocation = NO;
    
    //NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
    
}


/* 逆地理编码 搜索. */
- (void)searchReGeocodeWithLocation:(CLLocationCoordinate2D )coordinate
{
    AMapReGeocodeSearchRequest *reGeo = [[AMapReGeocodeSearchRequest alloc] init];
    reGeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self.search AMapReGoecodeSearch:reGeo];
}

/* 查询timeout  */
- (void)search:(id)searchRequest error:(NSString*)errInfo{
    NSLog(@"errInfo:%@",errInfo);
    [MBProgressHUD showError:@"定位失败,请重新定位"];
    self.provinceNameLabel.text = @"请重新定位";
    self.reLocatioBtn.enabled = YES;
}

#pragma mark - AMapSearchDelegate
/* 地理编码回调.*/
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    self.reLocatioBtn.enabled = YES;
    NSLog(@"response.regeocode:%@",response.regeocode);
    if (response.regeocode.formattedAddress) {
        
        
        /**
         /**
         广西壮族自治区桂林市雁山区雁山街道鹿鸣会馆, addressComponent: {province: 广西壮族自治区, city: 桂林市, district: 雁山区, township: 雁山街道, neighborhood: , building: , citycode: 0773, adcode: 450311, streetNumber: {street: 雁山街, number: 366, location: {25.058813, 110.308350}, distance: 501, direction: 东}}, roads: [], roadinters: [], pois: []}
         */

        
        [MBProgressHUD showSuccess:@"当前定位成功"];

        self.provinceNameLabel.text = [NSString stringWithFormat:@"%@",response.regeocode.addressComponent.province];
        self.cityNameLabel.text = [NSString stringWithFormat:@"%@",response.regeocode.addressComponent.city];
        self.districtNameLabel.text = [NSString stringWithFormat:@"%@",response.regeocode.addressComponent.district];
        self.townshipNameLabel.text = [NSString stringWithFormat:@"%@",response.regeocode.addressComponent.township];
        self.streetAndNumberLabel.text = [NSString stringWithFormat:@"%@%@号",response.regeocode.addressComponent.streetNumber.street,response.regeocode.addressComponent.streetNumber.number];
        //self.locationNameLabel.text = [NSString stringWithFormat:@"%@",response.regeocode.addressComponent.streetNumber.location];
        self.citycodeNameLabel.text = [NSString stringWithFormat:@"%@",response.regeocode.addressComponent.citycode];
        self.adcodeNameLabel.text = [NSString stringWithFormat:@"%@",response.regeocode.addressComponent.adcode];
        self.detailedAddressF.text = [NSString stringWithFormat:@"%@",response.regeocode.formattedAddress];
        
    }else{
        
    }
    
}


#pragma mark - init初始化 所以控件
/**
 *  init初始化 所以控件
 */
-(void)addContentView
{
    
    /**
     广西壮族自治区桂林市雁山区雁山街道鹿鸣会馆, addressComponent: {province: 广西壮族自治区, city: 桂林市, district: 雁山区, township: 雁山街道, neighborhood: , building: , citycode: 0773, adcode: 450311, streetNumber: {street: 雁山街, number: 366, location: {25.058813, 110.308350}, distance: 501, direction: 东}}, roads: [], roadinters: [], pois: []}
     */
    
    UILabel * provinceName = [self createTitleLabel:@"省(自治区)：" withFontOfSize:16.0 withextAlignment:NSTextAlignmentRight];
    provinceName.frame = CGRectMake(margin, 0, LabelWidth, LabelHight);
    [self.view addSubview:provinceName];
    
    UILabel * provinceNameLabel = [self createTitleLabel:@"省(自治区市)" withFontOfSize:18.0 withextAlignment:NSTextAlignmentLeft];
    provinceNameLabel.frame = CGRectMake(LabelWidth + margin, 0, viewWidth - LabelWidth - margin, LabelHight);
    [self.view addSubview:provinceNameLabel];
    self.provinceNameLabel = provinceNameLabel;
    
    
    
    UILabel * cityName = [self createTitleLabel:@"所在城市：" withFontOfSize:16.0 withextAlignment:NSTextAlignmentRight];
    cityName.frame = CGRectMake(margin, LabelHight + margin  , LabelWidth, LabelHight);
    [self.view addSubview:cityName];
    
    UILabel * cityNameLabel = [self createTitleLabel:@"城市" withFontOfSize:18.0 withextAlignment:NSTextAlignmentLeft];
    cityNameLabel.frame = CGRectMake(LabelWidth + margin, LabelHight + margin  , viewWidth - LabelWidth - margin, LabelHight);
    [self.view addSubview:cityNameLabel];
    self.cityNameLabel = cityNameLabel;
    
 

    UILabel * districtName = [self createTitleLabel:@"所在区(县)：" withFontOfSize:16.0 withextAlignment:NSTextAlignmentRight];
    districtName.frame = CGRectMake(margin, LabelHight * 2 + margin * 2 , LabelWidth, LabelHight);
    [self.view addSubview:districtName];
    
    UILabel * districtNameLabel = [self createTitleLabel:@"所在区(县)" withFontOfSize:18.0 withextAlignment:NSTextAlignmentLeft];
    districtNameLabel.frame = CGRectMake(LabelWidth + margin, LabelHight * 2 + margin * 2 , viewWidth - LabelWidth - margin, LabelHight);
    [self.view addSubview:districtNameLabel];
    self.districtNameLabel = districtNameLabel;
    
    
    UILabel * townshipName = [self createTitleLabel:@"所在乡镇：" withFontOfSize:16.0 withextAlignment:NSTextAlignmentRight];    townshipName.frame = CGRectMake(margin, LabelHight * 3 + margin * 3 , LabelWidth, LabelHight);
    [self.view addSubview:townshipName];
    
    UILabel * townshipNameLabel = [self createTitleLabel:@"所在乡镇" withFontOfSize:18.0 withextAlignment:NSTextAlignmentLeft];
    townshipNameLabel.frame = CGRectMake(LabelWidth + margin, LabelHight * 3 + margin * 3 , viewWidth - LabelWidth - margin, LabelHight);
    [self.view addSubview:townshipNameLabel];
    self.townshipNameLabel = townshipNameLabel;
    
    
    UILabel * streetAndNumber = [self createTitleLabel:@"街道号：" withFontOfSize:16.0 withextAlignment:NSTextAlignmentRight];
    streetAndNumber.frame = CGRectMake(margin, LabelHight * 4 + margin * 4 , LabelWidth, LabelHight);
    [self.view addSubview:streetAndNumber];
    
    UILabel * streetAndNumberLabel = [self createTitleLabel:@"街道号" withFontOfSize:18.0 withextAlignment:NSTextAlignmentLeft];
    streetAndNumberLabel.frame = CGRectMake(LabelWidth + margin, LabelHight * 4 + margin * 4 , viewWidth - LabelWidth - margin, LabelHight);
    [self.view addSubview:streetAndNumberLabel];
    self.streetAndNumberLabel = streetAndNumberLabel;
    
    
    
    UILabel * locationName = [self createTitleLabel:@"经纬度：" withFontOfSize:16.0 withextAlignment:NSTextAlignmentRight];
    locationName.frame = CGRectMake(margin, LabelHight * 5 + margin * 5 , LabelWidth, LabelHight);
    [self.view addSubview:locationName];
    
    UILabel * locationNameLabel = [self createTitleLabel:@"经纬度" withFontOfSize:18.0 withextAlignment:NSTextAlignmentLeft];
    locationNameLabel.frame = CGRectMake(LabelWidth + margin, LabelHight * 5 + margin * 5 , viewWidth - LabelWidth - margin, LabelHight);
    [self.view addSubview:locationNameLabel];
    self.locationNameLabel = locationNameLabel;
    

    
    UILabel * citycodeName = [self createTitleLabel:@"城市代码：" withFontOfSize:16.0 withextAlignment:NSTextAlignmentRight];
    citycodeName.frame = CGRectMake(margin, LabelHight * 6 + margin * 6 , LabelWidth, LabelHight);
    [self.view addSubview:citycodeName];
    
    UILabel * citycodeNameLabel = [self createTitleLabel:@"城市代码" withFontOfSize:18.0 withextAlignment:NSTextAlignmentLeft];
    citycodeNameLabel.frame = CGRectMake(LabelWidth + margin, LabelHight * 6 + margin * 6 , viewWidth - LabelWidth - margin, LabelHight);
    [self.view addSubview:citycodeNameLabel];
    self.citycodeNameLabel = citycodeNameLabel;
    
    
    
    UILabel * adcodeName = [self createTitleLabel:@"行政代码：" withFontOfSize:16.0 withextAlignment:NSTextAlignmentRight];
    adcodeName.frame = CGRectMake(margin, LabelHight * 7 + margin * 7 , LabelWidth, LabelHight);
    [self.view addSubview:adcodeName];
    
    UILabel * adcodeNameLabel = [self createTitleLabel:@"行政代码" withFontOfSize:18.0 withextAlignment:NSTextAlignmentLeft];
    adcodeNameLabel.frame = CGRectMake(LabelWidth + margin, LabelHight * 7 + margin * 7 , viewWidth - LabelWidth - margin, LabelHight);
    [self.view addSubview:adcodeNameLabel];
    self.adcodeNameLabel = adcodeNameLabel;

    
    
    UILabel * detailedAddressName = [self createTitleLabel:@"详细地址：" withFontOfSize:16.0 withextAlignment:NSTextAlignmentRight];
    detailedAddressName.frame = CGRectMake(margin, LabelHight * 8 + margin * 8 , LabelWidth, LabelHight);
    [self.view addSubview:detailedAddressName];
    
    UITextView * detailedAddressF = [[UITextView alloc]initWithFrame:CGRectMake(LabelWidth + margin, LabelHight * 8 + margin * 8 , viewWidth - LabelWidth - 2 * margin, LabelHight * 3  - margin)];
    detailedAddressF.layer.borderWidth = 1;
    detailedAddressF.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    detailedAddressF.layer.cornerRadius = 3;
    detailedAddressF.layer.masksToBounds = YES;
    detailedAddressF.alwaysBounceVertical = YES;
    detailedAddressF.showsVerticalScrollIndicator = YES;
    detailedAddressF.font = [UIFont systemFontOfSize:16];
    if (@available(iOS 13.0, *)) {
        detailedAddressF.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
        detailedAddressF.textColor = UIColor.labelColor;
    }
    
    detailedAddressF.editable = NO;
    [self.view addSubview:detailedAddressF];
    self.detailedAddressF = detailedAddressF;
    
#pragma mark - 创建 定位按钮
    
    UIButton * reLocationBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0, viewWidth / 1.7, LabelHight + margin)];
    reLocationBtn.center = CGPointMake(viewWidth / 2, LabelHight * 11 +  margin * 11 );
    [reLocationBtn setTitle:@"重新定位" forState:UIControlStateNormal];
    [reLocationBtn setBackgroundColor:[UIColor colorWithRed:0.270 green:0.633 blue:1.000 alpha:1]];
    reLocationBtn.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    reLocationBtn.layer.cornerRadius = 3;
    reLocationBtn.layer.masksToBounds = YES;
    [reLocationBtn addTarget:self action:@selector(reLocationAddress) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:reLocationBtn];
    self.reLocatioBtn = reLocationBtn;
}


- (UILabel *)createTitleLabel:(NSString *)title withFontOfSize:(CGFloat)fontSize withextAlignment: (NSTextAlignment)textAlignment
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = textAlignment;
    titleLabel.font          = [UIFont systemFontOfSize:fontSize];
    titleLabel.text          = title;
    [titleLabel sizeToFit];
    
    return titleLabel;
}


#pragma mark - 重新定位处理事件
-(void)reLocationAddress
{
    self.reLocatioBtn.enabled = NO;
    //开始定位
    self.mapView.showsUserLocation = YES;
}
@end
