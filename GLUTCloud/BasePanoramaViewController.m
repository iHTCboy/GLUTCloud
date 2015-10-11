//
//  BasePanoramaViewController.m
//  officialDemoPanorama
//
//  Created by 刘博 on 14-5-29.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import "BasePanoramaViewController.h"

@implementation BasePanoramaViewController

#pragma mark - Handle Action

- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Initialization

- (void)initBaseNavigationBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(returnAction)];
}

- (void)initTitle:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] init];
    
    titleLabel.backgroundColor  = [UIColor clearColor];
    titleLabel.textColor        = [UIColor whiteColor];
    titleLabel.text             = title;
    [titleLabel sizeToFit];
    
    self.navigationItem.titleView = titleLabel;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTitle:self.title];
    
    [self initBaseNavigationBar];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

@end
