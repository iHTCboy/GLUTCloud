//
//  SearchPanoramaDetailViewController.m
//  officialDemoPanorama
//
//  Created by 刘博 on 14-5-26.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import "SearchPanoramaDetailViewController.h"
#import <AMapPanoramaKit/AMapPanoramaKit.h>

@interface SearchPanoramaDetailViewController ()<AMapPanoramaViewDelegate>

@property (nonatomic, strong) AMapPanoramaView *panoramaView;

@end

@implementation SearchPanoramaDetailViewController

@synthesize panoramaView = _panoramaView;
@synthesize panoramaID = _panoramaID;

#pragma mark - Handle Action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
    
    self.panoramaView.delegate = nil;
    self.panoramaView = nil;
}

#pragma mark - Initialization

- (void)initNavigationBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(backAction)];
}

- (void)initPanoramaView
{
    if (self.panoramaView)
    {
        return;
    }
    
    self.panoramaView = [[AMapPanoramaView alloc] initWithFrame:self.view.bounds PanoramaID:self.panoramaID];
    [self.panoramaView setDelegate:self];
    
    [self.view addSubview:self.panoramaView];
}

#pragma mark - AMapPanorama Delegate

- (void)AMapPanoramaView:(AMapPanoramaView *)panoramaView error:(NSError *)error
{
    NSLog(@"AMapPanoramaViewError:{Domain:%@; Code:%d; Description:%@;}", [error domain], [error code], [error localizedDescription]);
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initPanoramaView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.toolbar.barStyle      = UIBarStyleBlack;
    self.navigationController.toolbar.translucent   = YES;
    [self.navigationController setToolbarHidden:YES animated:NO];
}

@end
