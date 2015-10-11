//
//  AbutGLUTCloudViewController.m
//  SecurityNote
//
//  Created by HTC on 14-10-1.
//  Copyright (c) 2014年 JoonSheng. All rights reserved.
//

#import "AbutGLUTCloudViewController.h"


#define TCCoror(a,b,c) [UIColor colorWithRed:(a/255.0) green:(b/255.0) blue:(c/255.0) alpha:1]

@interface AbutGLUTCloudViewController ()

@end

@implementation AbutGLUTCloudViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [self initTitle:@"关于"];
    
    UIImageView * logoV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"aboutglutcloud"]];
    logoV.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.3);
    logoV.bounds = CGRectMake(0, 0, 120, 75);
    logoV.layer.cornerRadius = 3;
    logoV.layer.masksToBounds = YES;
    [self.view addSubview:logoV];
    
    
    UILabel * name = [[UILabel alloc]init];
    name.center = CGPointMake(self.view.frame.size.width * 0.5,self.view.frame.size.height * 0.40);
    name.bounds = CGRectMake(0, 0, 250, 80);
    name.text = @"桂林理工大学云图";
    name.textAlignment = NSTextAlignmentCenter;
    name.font = [UIFont boldSystemFontOfSize:21];
    name.textColor = TCCoror(23, 23, 23);
    [self.view addSubview:name];
    
    
    UILabel * version = [[UILabel alloc]init];
    version.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.44);
    version.bounds = CGRectMake(0, 0, 180, 80);
    version.text = @"桂工云图iPhone版1.1";
    version.textAlignment = NSTextAlignmentCenter;
    version.font = [UIFont systemFontOfSize:13];
    version.textColor = TCCoror(187, 187, 187);
    [self.view addSubview:version];
    
    UILabel * htc = [[UILabel alloc]init];
    htc.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.95);
    htc.bounds = CGRectMake(0, 0, 250, 80);
    htc.text = @"何天从 版权所有";
    htc.textAlignment = NSTextAlignmentCenter;
    htc.textColor = TCCoror(147, 147, 147);
    htc.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:htc];
    

    UILabel * rights = [[UILabel alloc]init];
    rights.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.98);
    rights.bounds = CGRectMake(0, 0, 250, 80);
    rights.text = @"© 2014-2015 hetiancong All rights reserved";
    rights.textAlignment = NSTextAlignmentCenter;
    rights.textColor = TCCoror(147, 147, 147);
    rights.font = [UIFont systemFontOfSize:11];
    [self.view addSubview:rights];


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


@end
