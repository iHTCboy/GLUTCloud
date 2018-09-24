//
//  SettingViewController.m
//  GLUTCloud
//
//  Created by bailin on 15/1/5.
//  Copyright (c) 2015年 HTC. All rights reserved.
//

#import "SettingViewController.h"
#import "appMarco.h"
#import "AbutGLUTCloudViewController.h"
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD+MJ.h"
#import "TCAppViewController.h"
#import "TCHelpViewController.h"
#import <StoreKit/StoreKit.h>
#import <SafariServices/SafariServices.h>

@interface SettingViewController ()<UITableViewDataSource, UITableViewDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SettingViewController

@synthesize tableView = _tableView;

#pragma mark - Utility

- (NSString *)titleForIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = nil;
    
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0 : title = @"桂工云图定位";    break;
            default:    break;
        }
    }
    else if(indexPath.section == 1)
    {
        switch (indexPath.row)
        {
            case 0   : title = @"全部云图定位";            break;
            default  :  break;
        }
    }
    else
    {
        switch (indexPath.row)
        {
            case 0   : title = @"使用帮助";            break;
            case 1   : title = @"意见反馈";            break;
            case 2   : title = @"作者博客";            break;
            case 3   : title = @"推荐应用";            break;
            case 4   : title = @"关于应用";            break;
            case 5   : title = @"应用内评分";          break;
            case 6   : title = @"AppStore评分";       break;
            default  :  break;
        }
    }
    
    return title;
}




#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        section = 1;
    
    
    }
    else if(section  == 1)
    {
        section = 1;
    }
    else
    {
        section = 7;
    }
    
    return section;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString * headerTitle;
    
    if(section == 0)
    {
        headerTitle = @"是否使用自己的位置作为桂工云图的地图中心点（默认以桂林理工GPS为中心）";
        
        
    }
    else if(section  == 1)
    {
        headerTitle =  @"是否使用自己的位置作为全部云图的地图中心点（默认以桂林理工GPS为中心）";
    }
    else
    {
        headerTitle =  @"桂林理工云图";
    }
    
    return headerTitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *poiDetailCellIdentifier = @"poiDetailCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:poiDetailCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:poiDetailCellIdentifier];
    }
    
    cell.textLabel.text         = [self titleForIndexPath:indexPath];
//    cell.detailTextLabel.text   = [self subTitleForIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    if ([cell.textLabel.text isEqualToString:@"桂工云图定位"])
    {
        UISwitch * locationSwitch = [[UISwitch alloc]init];
        locationSwitch.onTintColor = [UIColor colorWithRed:0.186 green:0.744 blue:1.000 alpha:1.000];
        locationSwitch.tintColor = [UIColor lightGrayColor];
        [locationSwitch addTarget:self action:@selector(settingSwith:) forControlEvents:UIControlEventValueChanged];
        locationSwitch.tag =1;
        
        NSUserDefaults * defaults =  [NSUserDefaults standardUserDefaults];
        //判断用户是否存储了设置，如果没有YES，刚统一NO
        if([defaults boolForKey:@"glutSwitchIsOn"])
        {
            [locationSwitch setOn:YES];
        }

        cell.accessoryView = locationSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if([cell.textLabel.text isEqualToString:@"全部云图定位"])
    {
        UISwitch * locationSwitch = [[UISwitch alloc]init];
        locationSwitch.onTintColor = [UIColor colorWithRed:0.186 green:0.744 blue:1.000 alpha:1.000];
        locationSwitch.tintColor = [UIColor lightGrayColor];
        [locationSwitch addTarget:self action:@selector(settingSwith:) forControlEvents:UIControlEventValueChanged];
        locationSwitch.tag =2;

        NSUserDefaults * defaults =  [NSUserDefaults standardUserDefaults];
        //判断用户是否存储了设置，如果没有YES，刚统一NO
        if ([defaults boolForKey:@"allSwitchIsOn"])
        {
            [locationSwitch setOn:YES];
        }
        
        cell.accessoryView = locationSwitch;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.textLabel.text isEqualToString:@"AppStore评分"])
    {
        [self openAppStoreWithID:@"954359041"];
       
    }
    else if ([cell.textLabel.text isEqualToString:@"关于应用"])
    {
        [self initbackItem];
        
        AbutGLUTCloudViewController * abut = [[AbutGLUTCloudViewController alloc]init];
        
        [self.navigationController pushViewController:abut animated:YES];
       
    }
    else if ([cell.textLabel.text isEqualToString:@"意见反馈"])
    {
        [self sendFeedback];
    }
    else if([cell.textLabel.text isEqualToString:@"使用帮助"])
    {
        [self initbackItem];
        
        TCHelpViewController * help = [[TCHelpViewController alloc]init];
        
        [self.navigationController pushViewController:help animated:YES];
    }
    else if([cell.textLabel.text isEqualToString:@"推荐应用"])
    {
        [self initbackItem];
        
        TCAppViewController * apps = [[TCAppViewController alloc]init];
        
        [self.navigationController pushViewController:apps animated:YES];
        
    }
    else if([cell.textLabel.text isEqualToString:@"应用内评分"])
    {
        if (@available(iOS 10.3, *)) {
            [SKStoreReviewController requestReview];
        }else{
            [self openAppStoreWithID:@"954359041"];
        }
    }
    else if([cell.textLabel.text isEqualToString:@"作者博客"])
    {
        [self inSafariOpenWithURL:@"https://www.iHTCboy.com"];
        
    }
    
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Appstore
-(void)openAppStoreWithID:(NSString *)ID
{
    //评分 无法使用
    //NSString *str = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",ID];
    NSString *str = [NSString stringWithFormat: @"https://itunes.apple.com/cn/app/gui-lin-li-gong-da-xue-yun/id%@?mt=8&action=write-review", ID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    
}

/**
 *  从Safari打开
 */
- (void)inSafariOpenWithURL:(NSString *)url
{
    if (@available(iOS 9.0, *)) {
        SFSafariViewController * sf = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
        if (@available(iOS 11.0, *)) {
            sf.preferredBarTintColor = [UIColor colorWithRed:(66)/255.0 green:(156)/255.0 blue:(249)/255.0 alpha:1];
            sf.dismissButtonStyle = SFSafariViewControllerDismissButtonStyleClose;
        }
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:sf animated:YES completion:nil];
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}


#pragma mark - 意见反馈
-(void)sendFeedback
{

    MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
    
    // 设置邮件主题
    [mail setSubject:@"使用桂工云图的意见反馈"];
    
    // 设置邮件内容
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString * messBody = [NSString stringWithFormat:@"我当前使用的云图版本是:%@, %@,OS%@\n我的反馈和建议：\n1、\n2、\n3、",[infoDictionary objectForKey:@"CFBundleShortVersionString"],[[UIDevice currentDevice] model],[[UIDevice currentDevice] systemVersion]];
    
    [mail setMessageBody:messBody isHTML:NO];
    
    
    // 设置收件人列表
    [mail setToRecipients:@[@"ihetiancong@qq.com"]];
    
    
    //        // 设置抄送人列表
    //        [mail setCcRecipients:@[@"1234@qq.com"]];
    //        // 设置密送人列表
    //        [mail setBccRecipients:@[@"56789@qq.com"]];
    
    // 设置代理
    mail.mailComposeDelegate = self;
    // 显示控制器
    [self presentViewController:mail animated:YES completion:nil];

}



#pragma mark - 按钮处理事件
-(void)settingSwith:(UISwitch *)settingSwith
{
    NSUserDefaults * defaults =  [NSUserDefaults standardUserDefaults];
    
    if (settingSwith.tag == 1)
    {
        
        if (settingSwith.isOn)
        {
            [defaults setBool:YES forKey:@"glutSwitchIsOn"];
        }
        else
        {
        
           [defaults setBool:NO forKey:@"glutSwitchIsOn"];
        
        }
    }
    else
    {
    
        if (settingSwith.isOn)
        {
            [defaults setBool:YES forKey:@"allSwitchIsOn"];
        }
        else
        {
            
            [defaults setBool:NO forKey:@"allSwitchIsOn"];
        }
    
    }



}


#pragma mark - Initialization
- (void)initbackItem
{

    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = backItem;
}



- (void)initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

- (void)initTitle:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textColor        = [UIColor whiteColor];
    titleLabel.font             = [UIFont boldSystemFontOfSize:16];
    titleLabel.text             = title;
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    
}


#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTitle:@"应用设置"];
    
    [self initTableView];
    
}

#pragma mark - send Email
//处理短信
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    // 关闭短信界面
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultCancelled)
    {
        //NSLog(@"取消发送");
        [MBProgressHUD showSuccess:@"已取消发送"];
        
    }
    else if (result == MessageComposeResultSent)
    {
        //NSLog(@"已经发出");
        [MBProgressHUD showSuccess:@"发送成功"];
        
    } else
    {
        //NSLog(@"发送失败");
        [MBProgressHUD showError:@"发送失败"];
    }
    
    
    //定时器关闭提示
    [self performSelector:@selector(didhideHUD) withObject:nil afterDelay:1.0];
}

//处理邮件
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    // 关闭邮件界面
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MFMailComposeResultCancelled)
    {
        [MBRoundProgressView setAnimationDelay:1];
        //NSLog(@"取消发送");
        [MBProgressHUD showSuccess:@"已取消发送"];
        
    } else if (result == MFMailComposeResultSent)
    {
        //NSLog(@"已经发出");
        [MBProgressHUD showSuccess:@"发送成功"];
        
    } else
    {
        //NSLog(@"发送失败");
        [MBProgressHUD showError:@"发送失败"];
    }
    
    //定时器关闭提示
    [self performSelector:@selector(didhideHUD) withObject:nil afterDelay:1.0];
}


//隐藏提示框
-(void)didhideHUD
{
    
    [MBProgressHUD hideHUD];
    
}

@end
