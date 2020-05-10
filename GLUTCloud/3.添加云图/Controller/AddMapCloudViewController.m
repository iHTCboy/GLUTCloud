//
//  AddMapCloudViewController.m
//  GLUTCloud
//
//  Created by HTC on 14-12-31.
//  Copyright (c) 2014年 HTC. All rights reserved.
//

#import "AddMapCloudViewController.h"
#import "IQKeyboardManager.h"
#import "appMarco.h"
#import "ReSelectLocationMapViewController.h"
#import "JSONKit.h"
#import "AFNetworking.h"
#import "MBProgressHUD+MJ.h"

#define margin 10
#define LabelWidth 85
#define LabelHight 30
#define viewWidth self.view.frame.size.width
#define viewHight self.view.frame.size.height

@interface AddMapCloudViewController ()<MAMapViewDelegate,AMapSearchDelegate,ReSelectLocationMapViewControllerDelegate>

@property (strong, nonatomic) AMapSearchAPI * search;

@property (nonatomic, strong) NSString * addressType;

@property (nonatomic, strong) NSString * adcode; // 区域编码

@property (nonatomic, strong) NSString * citycode; //城市编码

/**
 *  控件
 */
@property (nonatomic, strong) UITextField * addressNameF;
@property (nonatomic, strong) UITextField * areaNameF;
@property (nonatomic, strong) UIButton * teachBuildBtn;
@property (nonatomic, strong) UIButton * dormitoryBuildBtn;
@property (nonatomic, strong) UIButton * officeBuildBtn;
@property (nonatomic, strong) UIButton * otherBuildBtn;
@property (nonatomic, strong) UILabel * coordinatesF;
@property (nonatomic, strong) UITextField * phoneF;
@property (nonatomic, strong) UITextView * detailedAddressF;
@property (nonatomic, strong) UITextView * explainAddressF;


@end

@implementation AddMapCloudViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setShouldToolbarUsesTextFieldTintColor:YES];
    
    self.mapView.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setShouldToolbarUsesTextFieldTintColor:NO];
    
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
    titleLabel.text             = @"添加云图";
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
    //添加控件
    [self addContentView];
    
    if (self.mapView == nil) {
        self.mapView=[[MAMapView alloc] initWithFrame:self.view.bounds];
    }
    self.mapView.delegate = self;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.showsUserLocation = YES;    //YES 为打开定位，NO为关闭定位

    if (self.search == nil) {
        
        //设置地图搜索
        self.search = [[AMapSearchAPI alloc] initWithSearchKey:[MAMapServices sharedServices].apiKey Delegate:nil];
        self.search.delegate = self;
    }
    
//    //默认选择地点类型为教学楼
//    self.teachBuildBtn.selected = YES;
//    self.addressType = @"1";
//    
    
}


#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
{
    //取出当前位置的坐标
    self.coordinatesF.text = [NSString stringWithFormat:@"%f,%f", userLocation.coordinate.longitude,userLocation.coordinate.latitude];
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
    self.coordinatesF.text = @"请重新定位";
    self.detailedAddressF.text = @"广西壮族自治区桂林市";
}

#pragma mark - AMapSearchDelegate
/* 地理编码回调.*/
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    // NSLog(@"response.regeocode:%@",response.regeocode);
    if (response.regeocode.formattedAddress) {
        
        [MBProgressHUD showSuccess:@"当前定位成功"];
        self.detailedAddressF.text = [NSString stringWithFormat:@"%@",response.regeocode.formattedAddress];
        self.areaNameF.text = [NSString stringWithFormat:@"%@",response.regeocode.addressComponent.district];
        
        self.adcode = response.regeocode.addressComponent.adcode;
        self.citycode =  response.regeocode.addressComponent.citycode;
        
    }else{
        
    }
    
}


#pragma mark - 选择地点类型处理事件
/**
 *  选择地点类型处理事件
 */
-(void)selectedType:(UIButton *)selectBtn
{
    selectBtn.selected = !selectBtn.selected;
    
    switch (selectBtn.tag) {
        case 1:
            self.dormitoryBuildBtn.selected = NO;
            self.officeBuildBtn.selected = NO;
            self.otherBuildBtn.selected = NO;
            self.addressType = @"教学楼";
            break;
            
        case 2:
            self.teachBuildBtn.selected = NO;
            self.officeBuildBtn.selected = NO;
            self.otherBuildBtn.selected = NO;
            self.addressType = @"宿舍楼";
            break;
        case 3:
            self.teachBuildBtn.selected = NO;
            self.dormitoryBuildBtn.selected = NO;
            self.otherBuildBtn.selected = NO;
            self.addressType = @"办公楼";
            break;
        case 4:
            self.teachBuildBtn.selected = NO;
            self.dormitoryBuildBtn.selected = NO;
            self.officeBuildBtn.selected = NO;
            self.addressType = @"其它类型";
            break;
            
        default:
            break;
    }
    

}


#pragma mark - 重新从地图中选择地点
/**
 *  重新从地图中选择地点
 */
-(void)reSelectAddress
{
    
//    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    LZSelectLocationMapViewController * slmvc = [board instantiateViewControllerWithIdentifier:@"LZSelectLocationMapViewController"];
    
    
    ReSelectLocationMapViewController * selectMap = [[ReSelectLocationMapViewController alloc]init];
    selectMap.mapView = self.mapView;
    selectMap.delegate = self;
 
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backItem;
    
    [self.navigationController pushViewController:selectMap animated:YES];
    

}


#pragma mark - 提交地点按钮处理
/**
 *  提交地点
 */
-(void)submitAddress
{
    
    
    if (!self.addressNameF.text.length)
    {
        
        [self.addressNameF becomeFirstResponder];
        [MBProgressHUD showError:@"地名不能为空"];
        return;
    }
    
    if (!self.areaNameF.text.length)
    {
        [self.areaNameF becomeFirstResponder];
        [MBProgressHUD showError:@"区名不能为空"];
        return;
    }
    if(!self.coordinatesF.text.length)
    {
        [self.coordinatesF becomeFirstResponder];
        [MBProgressHUD showError:@"经纬度不能为空"];
        return;
    }
    if(!self.detailedAddressF.text.length)
    {
        [self.detailedAddressF becomeFirstResponder];
        [MBProgressHUD showError:@"详细地址不能为空"];
        return;
    }
    

    if (!self.teachBuildBtn.isSelected && !self.dormitoryBuildBtn.isSelected && !self.officeBuildBtn.isSelected && !self.otherBuildBtn.isSelected)
    {
        [MBProgressHUD showError:@"请选择地点类型"];
        return;
    }

    [self createCloundAddress];
}

         
#pragma mark -  创建单条地点数据
 -(void)createCloundAddress
{
    
    [MBProgressHUD showMessage:@"正在提交..."];
    
    
    // 1.创建请求管理对象
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];

    // 2.封装请求参数
    NSDictionary *dataDic = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.addressNameF.text,@"_name",
                             self.coordinatesF.text,@"_location",
                             self.detailedAddressF.text,@"_address",
                             self.areaNameF.text,@"area",
                             self.addressType,@"type",
                             self.explainAddressF.text,@"detail",
                             self.phoneF.text,@"telephone",
                             self.adcode,@"adcode",
                             self.citycode,@"citycode",
                             nil];
    
    
    NSDictionary *dataAllDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                RestIKey,@"key",
                                allTableID,@"tableid",
                                @"1",@"loctype", //使用GPS坐标方式存储
                                [self stringFromJson:dataDic],@"data",
                                nil];
    
    
    
    //NSLog(@"-------\n %@",dataAllDic);
    
    // 3.发送请求
    [mgr POST:@"http://yuntuapi.amap.com/datamanage/data/create" parameters:dataAllDic
      success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         
         NSString * status = [responseObject objectForKey:@"status"];
         // NSLog(@"-------\n %@  %@",responseObject,status);
         
         if ([status intValue])
         {
             
              [MBProgressHUD hideHUD];
              [MBProgressHUD showSuccess:@"地点提交成功"];
             
         }
         else
         {
             //NSString * dinfo =  [responseObject objectForKey:@"info"];
             [MBProgressHUD hideHUD];
             [MBProgressHUD showError:@"地点有误，请重新选择定位"];
             
         }
         
     }
      failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [MBProgressHUD hideHUD];
         [MBProgressHUD showError:@"提交失败，请重新提交"];
     }];
    
}


- (NSString *)stringFromJson:(NSDictionary *)JSONDic
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:JSONDic
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (error) {
        return @"";
    } else {
        return jsonString;
    }
}

#pragma mark - ReSelectLocationMapViewControllerDelegate
-(void)selectLocationDidResponse:(AMapReGeocodeSearchResponse *)response WithSelectLocation:(CLLocationCoordinate2D)location
{

//    @property (nonatomic, strong) NSString *province; // 省
//    @property (nonatomic, strong) NSString *city; // 市
//    @property (nonatomic, strong) NSString *district; // 区
//    @property (nonatomic, strong) NSString *township; // 乡镇
//    @property (nonatomic, strong) NSString *neighborhood; // 社区
//    @property (nonatomic, strong) NSString *building; // 建筑
//    @property (nonatomic, strong) NSString *citycode; // 城市编码
//    @property (nonatomic, strong) NSString *adcode; // 区域编码
    
//    response:AMapReGeocodeSearchResponse - regeocode: {address: 广西壮族自治区桂林市雁山区雁山街道鹿鸣会馆, addressComponent: {province: 广西壮族自治区, city: 桂林市, district: 雁山区, township: 雁山街道, neighborhood: , building: , citycode: 0773, adcode: 450311, streetNumber: {street: 雁山街, number: 366, location: {25.058813, 110.308350}, distance: 500, direction: 东}}, roads: [], roadinters: [], pois: []}
    
    [self.coordinatesF setText:[NSString stringWithFormat:@"%f,%f",location.longitude,location.latitude]];
    [self.detailedAddressF setText:response.regeocode.formattedAddress];
    [self.areaNameF setText:response.regeocode.addressComponent.district];
    
    self.adcode = response.regeocode.addressComponent.adcode;
    self.citycode =  response.regeocode.addressComponent.citycode;
}



#pragma mark - init初始化 所以控件
/**
 *  init初始化 所以控件
 */
-(void)addContentView
{
    
    UILabel * addressNameL = [[UILabel alloc]initWithFrame:CGRectMake(margin, margin, LabelWidth, LabelHight)];
    addressNameL.text = @"地点名称:";
    
    UITextField * addressNameF = [[UITextField alloc]initWithFrame:CGRectMake(LabelWidth + margin, margin, viewWidth - LabelWidth - 2 * margin, LabelHight)];
    addressNameF.placeholder = @"地点名称";
    addressNameF.layer.borderWidth = 1;
    addressNameF.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    addressNameF.layer.cornerRadius = 3;
    addressNameF.layer.masksToBounds = YES;
    addressNameF.clearButtonMode = UITextFieldViewModeWhileEditing;
    UILabel *addressNameLV = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, LabelHight)];
    addressNameF.leftView = addressNameLV;
    addressNameF.leftViewMode = UITextFieldViewModeAlways;
    
    
    
    UILabel * areaNameL = [[UILabel alloc]initWithFrame:CGRectMake(margin, LabelHight + margin * 2 , LabelWidth, LabelHight)];
    areaNameL.text = @"所在区域:";
    
    UITextField * areaNameF = [[UITextField alloc]initWithFrame:CGRectMake(LabelWidth + margin, LabelHight + margin * 2 , viewWidth - LabelWidth - 2 * margin, LabelHight)];
    areaNameF.placeholder = @"区域名称";
    areaNameF.layer.borderWidth = 1;
    areaNameF.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    areaNameF.layer.cornerRadius = 3;
    areaNameF.layer.masksToBounds = YES;
    areaNameF.clearButtonMode = UITextFieldViewModeWhileEditing;
    UILabel *areaNameLV = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, LabelHight)];
    areaNameF.leftView = areaNameLV;
    areaNameF.leftViewMode = UITextFieldViewModeAlways;
    
    
    
    UILabel * addressType = [[UILabel alloc]initWithFrame:CGRectMake(margin, LabelHight * 2 + margin * 3 , LabelWidth, LabelHight)];
    addressType.text = @"地点类型:";
    
    CGFloat BtnWH = 30;
    
    CGFloat allW = viewWidth - LabelWidth - margin;
    
    CGFloat LableW = (allW - margin * 2 - BtnWH * 2) /2;
    
    
    
    UIButton * teachBuildBtn = [[UIButton alloc]initWithFrame:CGRectMake(LabelWidth + margin, LabelHight * 2 + margin * 3 , BtnWH , BtnWH)];
    [teachBuildBtn setImage:[UIImage imageNamed:@"checkbtn_normal"] forState:UIControlStateNormal];
    [teachBuildBtn setImage:[UIImage imageNamed:@"checkbtn_selected"] forState:UIControlStateSelected];
    [teachBuildBtn addTarget:self action:@selector(selectedType:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel * teachBuildLabel = [[UILabel alloc]initWithFrame:CGRectMake(LabelWidth + margin + BtnWH,  LabelHight * 2 + margin * 3 , LableW, BtnWH)];
    teachBuildLabel.text = @"教学楼";
    teachBuildBtn.tag = 1;
    teachBuildLabel.textAlignment = NSTextAlignmentLeft;
    
    
    UIButton * dormitoryBuildBtn = [[UIButton alloc]initWithFrame:CGRectMake(LabelWidth + margin * 2 + BtnWH + LableW ,  LabelHight * 2 + margin * 3 , BtnWH , BtnWH)];
    [dormitoryBuildBtn setImage:[UIImage imageNamed:@"checkbtn_normal"] forState:UIControlStateNormal];
    [dormitoryBuildBtn setImage:[UIImage imageNamed:@"checkbtn_selected"] forState:UIControlStateSelected];
    [dormitoryBuildBtn addTarget:self action:@selector(selectedType:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel * dormitoryBuildLabel = [[UILabel alloc]initWithFrame:CGRectMake(LabelWidth + margin * 2 + BtnWH * 2 + LableW ,  LabelHight * 2 + margin * 3 , LableW, BtnWH)];
    dormitoryBuildLabel.text = @"宿舍楼";
    dormitoryBuildBtn.tag =2;
    dormitoryBuildLabel.textAlignment = NSTextAlignmentLeft;
    
    
    
    
    UIButton * officeBuildBtn = [[UIButton alloc]initWithFrame:CGRectMake(LabelWidth + margin, LabelHight * 2 + margin * 3.5 + BtnWH , BtnWH , BtnWH)];
    [officeBuildBtn setImage:[UIImage imageNamed:@"checkbtn_normal"] forState:UIControlStateNormal];
    [officeBuildBtn setImage:[UIImage imageNamed:@"checkbtn_selected"] forState:UIControlStateSelected];
    [officeBuildBtn addTarget:self action:@selector(selectedType:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel * officeBuildLabel = [[UILabel alloc]initWithFrame:CGRectMake(LabelWidth + margin + BtnWH,  LabelHight * 2 + margin * 3.5 + BtnWH , LableW, BtnWH)];
    officeBuildLabel.text = @"办公楼";
    officeBuildBtn.tag = 3;
    officeBuildLabel.textAlignment = NSTextAlignmentLeft;
    
    
    
    UIButton * otherBuildBtn = [[UIButton alloc]initWithFrame:CGRectMake(LabelWidth + margin * 2 + BtnWH + LableW ,  LabelHight * 2 + margin * 3.5 + BtnWH, BtnWH , BtnWH)];
    [otherBuildBtn setImage:[UIImage imageNamed:@"checkbtn_normal"] forState:UIControlStateNormal];
    [otherBuildBtn setImage:[UIImage imageNamed:@"checkbtn_selected"] forState:UIControlStateSelected];
    [otherBuildBtn addTarget:self action:@selector(selectedType:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel * otherBuildLabel = [[UILabel alloc]initWithFrame:CGRectMake(LabelWidth + margin * 2 + BtnWH * 2 + LableW ,  LabelHight * 2 + margin * 3.5 + BtnWH, LableW, BtnWH)];
    otherBuildLabel.text = @"其它地点";
    otherBuildBtn.tag =4;
    otherBuildLabel.textAlignment = NSTextAlignmentLeft;
    
    
    
    
    
    
    UILabel * coordinatesL = [[UILabel alloc]initWithFrame:CGRectMake(margin, LabelHight * 4 +  margin * 5 , LabelWidth, LabelHight)];
    coordinatesL.text = @"经纬度:";
    
    UILabel * coordinatesF = [[UILabel alloc]initWithFrame:CGRectMake(LabelWidth + margin, LabelHight * 4 + margin * 5 , viewWidth - LabelWidth - 2 * margin, LabelHight)];
   // coordinatesF.placeholder = @"当前经纬度";
    coordinatesF.layer.borderWidth = 1;
    coordinatesF.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    coordinatesF.layer.cornerRadius = 3;
    coordinatesF.layer.masksToBounds = YES;
    coordinatesF.textAlignment = NSTextAlignmentCenter;
//    coordinatesF.clearButtonMode = UITextFieldViewModeWhileEditing;
//    UILabel *coordinatesLV = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, LabelHight)];
//    coordinatesF.leftView = coordinatesLV;
//    coordinatesF.leftViewMode = UITextFieldViewModeAlways;
    
    
    
    UILabel * phoneL = [[UILabel alloc]initWithFrame:CGRectMake(margin, LabelHight * 5 +  margin * 6 , LabelWidth, LabelHight)];
    phoneL.text = @"电话号码:";
    
    UITextField * phoneF = [[UITextField alloc]initWithFrame:CGRectMake(LabelWidth + margin, LabelHight * 5 + margin * 6 , viewWidth - LabelWidth - 2 * margin, LabelHight)];
    phoneF.placeholder = @"电话号码(可为空)";
    phoneF.layer.borderWidth = 1;
    phoneF.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    phoneF.layer.cornerRadius = 3;
    phoneF.layer.masksToBounds = YES;
    phoneF.clearButtonMode = UITextFieldViewModeWhileEditing;
    UILabel *phoneLV = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, LabelHight)];
    phoneF.leftView = phoneLV;
    phoneF.leftViewMode = UITextFieldViewModeAlways;
    
    
    
    UILabel * detailedAddressL = [[UILabel alloc]initWithFrame:CGRectMake(margin, LabelHight * 6 +  margin * 7 , LabelWidth, LabelHight)];
    detailedAddressL.text = @"详细地址:";
    
    UITextView * detailedAddressF = [[UITextView alloc]initWithFrame:CGRectMake(LabelWidth + margin, LabelHight * 6 + margin * 7 , viewWidth - LabelWidth - 2 * margin, LabelHight * 2  - margin)];
    detailedAddressF.layer.borderWidth = 1;
    detailedAddressF.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    detailedAddressF.layer.cornerRadius = 3;
    detailedAddressF.layer.masksToBounds = YES;
    detailedAddressF.alwaysBounceVertical = YES;
    detailedAddressF.showsVerticalScrollIndicator = YES;
    detailedAddressF.font = [UIFont systemFontOfSize:16];
    
    
    UILabel * explainAddressL = [[UILabel alloc]initWithFrame:CGRectMake(margin, LabelHight * 7 +  margin * 10 , LabelWidth, LabelHight)];
    explainAddressL.text = @"说明备注:";
    
    UITextView * explainAddressF = [[UITextView alloc]initWithFrame:CGRectMake(LabelWidth + margin, LabelHight * 7 + margin * 10 , viewWidth - LabelWidth - 2 * margin, LabelHight * 2  - margin)];
    explainAddressF.layer.borderWidth = 1;
    explainAddressF.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    explainAddressF.layer.cornerRadius = 3;
    explainAddressF.layer.masksToBounds = YES;
    explainAddressF.alwaysBounceVertical = YES;
    explainAddressF.showsVerticalScrollIndicator = YES;
    explainAddressF.font = [UIFont systemFontOfSize:16];
    
    if (@available(iOS 13.0, *)) {
        detailedAddressF.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
        explainAddressF.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    }
    
    
#pragma mark - 创建 选择地点和提交按钮
    
    UIButton * selectAddressBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0, viewWidth / 1.7, LabelHight + margin)];
    selectAddressBtn.center = CGPointMake(viewWidth / 2, LabelHight * 8 +  margin * 16 );
    [selectAddressBtn setTitle:@"重新选择地点" forState:UIControlStateNormal];
    [selectAddressBtn setBackgroundColor:[UIColor colorWithRed:0.270 green:0.633 blue:1.000 alpha:1]];
    selectAddressBtn.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    selectAddressBtn.layer.cornerRadius = 3;
    selectAddressBtn.layer.masksToBounds = YES;
    [selectAddressBtn addTarget:self action:@selector(reSelectAddress) forControlEvents:UIControlEventTouchDown];
    
    
    UIButton * submitAddressBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0, viewWidth / 1.7, LabelHight + margin)];
    submitAddressBtn.center = CGPointMake(viewWidth / 2, LabelHight * 9 +  margin * 19 );
    [submitAddressBtn setTitle:@"提交当前地点" forState:UIControlStateNormal];
    [submitAddressBtn setBackgroundColor:[UIColor colorWithRed:0.270 green:0.633 blue:1.000 alpha:1]];
    submitAddressBtn.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    submitAddressBtn.layer.cornerRadius = 3;
    submitAddressBtn.layer.masksToBounds = YES;
    [submitAddressBtn addTarget:self action:@selector(submitAddress) forControlEvents:UIControlEventTouchDown];
    
    
    [self.view addSubview:addressNameL];
    self.addressNameF = addressNameF;
    [self.view addSubview:addressNameF];
    [self.view addSubview:areaNameL];
    self.areaNameF = areaNameF;
    [self.view addSubview:areaNameF];
    [self.view addSubview:addressType];
    self.teachBuildBtn = teachBuildBtn;
    [self.view addSubview:teachBuildBtn];
    [self.view addSubview:teachBuildLabel];
    self.dormitoryBuildBtn = dormitoryBuildBtn;
    [self.view addSubview:dormitoryBuildBtn];
    [self.view addSubview:dormitoryBuildLabel];
    self.officeBuildBtn = officeBuildBtn;
    [self.view addSubview:officeBuildBtn];
    [self.view addSubview:officeBuildLabel];
    self.otherBuildBtn = otherBuildBtn;
    [self.view addSubview:otherBuildBtn];
    [self.view addSubview:otherBuildLabel];
    
    
    [self.view addSubview:coordinatesL];
    self.coordinatesF = coordinatesF;
    [self.view addSubview:coordinatesF];
    [self.view addSubview:phoneL];
    self.phoneF = phoneF;
    [self.view addSubview:phoneF];
    [self.view addSubview:detailedAddressL];
    self.detailedAddressF = detailedAddressF;
    [self.view addSubview:detailedAddressF];
    [self.view addSubview:explainAddressL];
    self.explainAddressF = explainAddressF;
    [self.view addSubview:explainAddressF];
    [self.view addSubview:selectAddressBtn];
    [self.view addSubview:submitAddressBtn];
    
    
}


@end
