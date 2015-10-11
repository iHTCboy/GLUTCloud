//
//  TCAppViewController.m
//  GLUTJWS
//
//  Created by HTC on 14-10-11.
//  Copyright (c) 2014年 JoonSheng. All rights reserved.
//

#import "TCAppViewController.h"
#import "MBProgressHUD+MJ.h"
#import <MessageUI/MessageUI.h>

@interface TCAppViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) UITableView * moreAppTable;

@end

@implementation TCAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //标题
    [self initTitle:@"应用推荐"];
    
    
    UITableView * aboutAppTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain ];
    aboutAppTable.separatorColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:252/255.0 alpha:1];
    aboutAppTable.separatorStyle = UITableViewCellSelectionStyleNone;
    self.moreAppTable = aboutAppTable;
    self.moreAppTable.delegate = self;
    self.moreAppTable.dataSource = self;
    
    [self.view addSubview:aboutAppTable];
    
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


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"aboutID";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    //字体大小
    cell.textLabel.font = [UIFont boldSystemFontOfSize:25];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    
    //cell被选中的颜色
    cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0/255.0 green:122/255.0 blue:252/255.0 alpha:1];

    //右侧的指示
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if ([indexPath section] == 0)
    {
        cell.textLabel.text = @"桂林理工大学";
        cell.detailTextLabel.text = @"学生版:教务、校历、时间...";
        cell.imageView.image = [UIImage imageNamed:@"JWSlogomini.png"];
        
    }
    else if([indexPath section] == 1)
    {
        
        cell.textLabel.text = @"桂林理工大学";
        cell.detailTextLabel.text = @"教师版:教务、校历、时间...";
        cell.imageView.image = [UIImage imageNamed:@"JWTlogomini.png"];

    }
    else if([indexPath section] == 2)
    {

        cell.textLabel.text = @"密记";
        cell.detailTextLabel.text = @"最简单，最简洁的笔记，备忘录";
        cell.imageView.image = [UIImage imageNamed:@"snlogo180.png"];
        
        
    }
    else if([indexPath section] == 3)
    {
        
        
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath section] == 0)
    {
        
        UIActionSheet * sheets = [[UIActionSheet alloc]initWithTitle:@"桂林理工大学教务在线——学生iOS版" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从AppStore下载",@"短信告诉好友",@"邮件告诉好友", nil];
        
        sheets.actionSheetStyle = UIActionSheetStyleAutomatic;
        
        //帮定tag
        sheets.tag = 1;
        
        [sheets showInView:self.view];
        
    }
    else if([indexPath section] == 1)
    {
        
        UIActionSheet * sheets = [[UIActionSheet alloc]initWithTitle:@"桂林理工大学教务在线——教师iOS版" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从AppStore下载",@"短信告诉好友",@"邮件告诉好友", nil];
        
        sheets.actionSheetStyle = UIActionSheetStyleAutomatic;
        
        //帮定tag
        sheets.tag = 2;
        
        [sheets showInView:self.view];
        

    
    }
    else if([indexPath section] == 2)
    {
        
        UIActionSheet * sheets = [[UIActionSheet alloc]initWithTitle:@"密记——与众不同的记录方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从AppStore下载",@"短信告诉好友",@"邮件告诉好友", nil];
        
        sheets.actionSheetStyle = UIActionSheetStyleAutomatic;
        
        //帮定tag
        sheets.tag = 3;
        
        [sheets showInView:self.view];
        
        
    }
    else if([indexPath section] == 3)
    {

    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

    return 15;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{

    if (section == 2)
    {
        return 15;
    }
    
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 100;

}



//处理Sheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (actionSheet.tag == 1)
    {
        [self studentActionSheet:actionSheet withIndex:buttonIndex];
        return ;
    }
    
    if (actionSheet.tag == 2)
    {
         [self teacherActionSheet:actionSheet withIndex:buttonIndex];
        return;
        
    }
    
    if (actionSheet.tag == 3)
    {
         [self snoteActionSheet:actionSheet withIndex:buttonIndex];
        return;
        
    }

    

}


                                  
                            
#pragma mark - Sheet处理事件

-(void)studentActionSheet:(UIActionSheet *)actionSheet withIndex:(NSInteger)buttonIndex
{
    //学生版
    if (actionSheet.tag == 1 && buttonIndex == 0)
    {
        [self openAppStoreWithID:@"914453383"];
        
    }
    else if(actionSheet.tag == 1 && buttonIndex == 1)
    {
        [self sendMessageWithBody:@"推荐你使用这款应用，这是桂林理工大学教务在线---学生iOS客户端，主要是学生登陆，可以查看校历、作息时间，最重要的是教务管理，方便通过手机查看，快速的登陆教务系统，了解教学的相关事务。您也快来下载试试用啊！\nAppStore下载: https://appsto.re/cn/hoxG2.i"];

        
    }
    else if(actionSheet.tag == 1 && buttonIndex == 2)
    {
        [self sendEmeilTitle:@"桂林理工大学学生教务在线" withBody:@"推荐你使用这款应用，这是桂林理工大学教务在线---学生iOS客户端，主要是学生登陆，可以查看校历、作息时间，最重要的是教学管理，方便通过手机，快速的登陆教务系统，了解教学的相关事务。您也快来下载试试用啊！\n1、界面简洁，便捷\n2、记住密码，登陆方便\n3、离线模式，为您省流量\nAppStore下载: https://appsto.re/cn/hoxG2.i "];
    }
    
}

-(void)teacherActionSheet:(UIActionSheet *)actionSheet withIndex:(NSInteger)buttonIndex
{

    
    //教师版
    if (actionSheet.tag == 2 && buttonIndex == 0)
    {
        [self openAppStoreWithID:@"914463106"];
        
    }
    else if(actionSheet.tag == 2 && buttonIndex == 1)
    {
        [self sendMessageWithBody:@"推荐你使用这款应用，这是桂林理工大学教务在线---教师iOS客户端，主要是教师登陆，可以查看校历、作息时间，最重要的是教师教学管理，方便教师通过手机，快速的登陆教务系统，了解教学的相关事务。您也快来下载试试用啊！\nAppStore下载: https://appsto.re/cn/cMzG2.i"];
        
        
    }
    else if(actionSheet.tag == 2 && buttonIndex == 2)
    {
        [self sendEmeilTitle:@"桂林理工大学教师教务在线" withBody:@"推荐你使用这款应用，教师iOS客户端，主要是教师登陆，可以查看校历、作息时间，最重要的是教师教学管理，方便教师通过手机，快速的登陆教务系统，了解教学的相关事务。您也快来下载试试用啊！\n1、界面简洁，便捷\n2、记住密码，登陆方便\n3、离线模式，为您省流量\nAppStore下载: https://appsto.re/cn/cMzG2.i "];
    }

}



-(void)snoteActionSheet:(UIActionSheet *)actionSheet withIndex:(NSInteger)buttonIndex
{

    //密记
    if (actionSheet.tag == 3 && buttonIndex == 0)
    {
        [self openAppStoreWithID:@"925021570"];
        
    }
    else if(actionSheet.tag == 3 && buttonIndex == 1)
    {
        [self sendMessageWithBody:@"推荐你使用这款应用，密记——专注于打造最简单，最简洁，最简明，最简便的生活小密记，帮你记列表，记事项，写密记，个人心情的日记，备忘录等。您也快来下载试试用啊！\nAppStore下载: https://appsto.re/cn/cMzG2.i"];
        
        
    }
    else if(actionSheet.tag == 3 && buttonIndex == 2)
    {
        [self sendEmeilTitle:@"桂林理工大学教师教务在线" withBody:@"推荐你使用这款应用，密记——专注于打造最简单，最简洁，最简明，最简便的生活小密记，帮你记列表，记事项，写密记，个人心情的日记，备忘录等。\n大三功能：\n1.简记\n专注于列表清单，还原最简单的记录方式。\n2.密记\n与众不同的密记，让你的日记更加自定义，更加简洁和简明。\n3.备忘\n独特的备忘录，同样的简便快捷。\n我们的目标：不用太多的花哨，还你一个高效的记录方式！密记，我的选择！\nAppStore下载: https://appsto.re/cn/cwRi3.i "];
    }



}

#pragma mark - send 通用方法

-(void)openAppStoreWithID:(NSString *)ID
{
    //评分 无法使用
    //NSString *str = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",ID];
    NSString *str = [NSString stringWithFormat: @"https://itunes.apple.com/cn/app/gui-lin-li-gong-da-xue-yun/id%@?mt=8", ID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

}

-(void)sendMessageWithBody:(NSString *)body
{

    //短信
    //发短信
    MFMessageComposeViewController *mess = [[MFMessageComposeViewController alloc] init];
    
    // 设置短信内容
    mess.body = body;
    
    // 设置收件人列表
    //mess.recipients = @[@"joonsheng.htc@icloud.com"];
    
    // 设置代理
    mess.messageComposeDelegate = self;
    
    // 显示控制器
    [self presentViewController:mess animated:YES completion:nil];


}


-(void)sendEmeilTitle:(NSString *)title withBody:(NSString *)body
{

    //邮件
    // 不能发邮件
    //if (![MFMailComposeViewController canSendMail]) return;
    
    MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
    
    // 设置邮件主题
    [mail setSubject:title];
    // 设置邮件内容
    [mail setMessageBody:body isHTML:NO];
    
    // 设置代理
    mail.mailComposeDelegate = self;
    // 显示控制器
    [self presentViewController:mail animated:YES completion:nil];


}

#pragma mark - 处理发送
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
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(didhideHUD) userInfo:nil repeats:NO];
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
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(didhideHUD) userInfo:nil repeats:NO];
}


//隐藏提示框
-(void)didhideHUD
{
    
    [MBProgressHUD hideHUD];
    
}

@end
