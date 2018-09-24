//
//  ScreenshotDetailViewController.m
//  officialDemoPanorama
//
//  Created by 刘博 on 14-5-26.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import "ScreenshotDetailViewController.h"

@implementation ScreenshotDetailViewController

#pragma mark - Handle Action

- (void)backAction
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
    {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    else
    {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [self dismissModalViewControllerAnimated:YES];
#pragma GCC diagnostic pop
    }
}

#pragma mark - Initialization

- (void)initNavigationBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(backAction)];
}

- (void)initImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.screenshotImage];
    imageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleRightMargin
    | UIViewAutoresizingFlexibleTopMargin
    | UIViewAutoresizingFlexibleBottomMargin;
    
    [self.view addSubview:imageView];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavigationBar];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initImageView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle    = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
}

@end
