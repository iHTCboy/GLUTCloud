//
//  TCHelpViewController.m
//  GLUTJWS
//
//  Created by HTC on 14-10-1.
//  Copyright (c) 2014年 JoonSheng. All rights reserved.
//

#import "TCHelpViewController.h"

@interface TCHelpViewController ()

@end

@implementation TCHelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //标题
    [self initWithTitle:@"使用帮助"];
    
    UITextView * aboutGlut = [[UITextView alloc]initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, self.view.frame.size.height)];
    
    aboutGlut.text = @"▶︎1、桂工云图\n       “桂工云图”是以桂林理工大学(雁山校区)为中心的云地图，目的是为所有在桂林理工大学的朋友同学老师们，提供一个方便的导航，全部地点是经过确认后的地点信息位置，默认是以桂林理工大学GPS为中心点，如果你在学校(雁山校区),可以在设置里打开以自己为定位点，以便看到自己现在所在的位置。\n\n▶︎2、全部云图\n       此云图显示的地点，是以大家上传的地点为数据来源，还没有经过确认的地点，地点信息信不信由你。\n\n▶︎3、添加云图\n       用户可以自己添加地点到云图上，添加成功的地点首先显示在全部云图的地图上，经过我们信息确认后，可以显示在桂工云图上。添加成功的地点，可能显示时间不确实，一般5分钟内会显示在全部云图中。\n\n▶︎4、导航图\n       可以为你提供导航功能的地图.\n\n▶︎5、卫星图\n       雁山卫星数据暂时还没有，此模式下可以转为黑夜图。\n\n▶︎6信息图\n       此地图是，用户长压地图(0.3s)后，会显示该点的地理信息，包括周边的道路、兴趣点。\n\n▶︎7、我的位置\n       显示用户当前的GPS信息\n\n▶︎8、周边搜索\n       此地图用于搜索周边的地点，包括公交站、餐饮、住宿等，比如搜索“公交”，就会显示周边(5km)内的公交站信息。\n\n▶︎8、关于桂林理工大学云图\n       如果你对应用有什么反馈意见，欢迎发邮件给我(ihetiancong@qq.com),感谢您的使用！\n\n\n注：此云图是基于高德地图开发，对数据来源的真实性，本应用不负责任。同时在此，感谢高德地图API部门！\n\n\n开发者  何天从\n\n\n\n\n\n";
    
    aboutGlut.font = [UIFont systemFontOfSize:17];
    aboutGlut.editable = NO;
    [self.view addSubview:aboutGlut];

    
}

#pragma mark - init

-(void)initWithTitle:(NSString *)title
{
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textColor        = [UIColor whiteColor];
    titleLabel.font             = [UIFont boldSystemFontOfSize:16];
    titleLabel.text             = title;
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
}

@end
