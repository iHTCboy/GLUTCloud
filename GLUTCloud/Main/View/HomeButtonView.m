//
//  HomeButtonView.m
//  GLUTCloud
//
//  Created by HTC on 14-12-29.
//  Copyright (c) 2014年 HTC. All rights reserved.
//

#import "HomeButtonView.h"
#import "TCButton.h"

#define margin 0
#define navBarHight (iPhone_X_S ? 87 : 63)
#define  MACRO_IS_GREATER_OR_EQUAL_TO_IOS(v) ([[[UIDevice currentDevice] systemVersion] floatValue] >= v)
#define iPhone_X_S (MACRO_IS_GREATER_OR_EQUAL_TO_IOS(11.0) ? \
    ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? NO :\
    (!UIEdgeInsetsEqualToEdgeInsets([[[UIApplication sharedApplication].keyWindow valueForKey:@"safeAreaInsets"] UIEdgeInsetsValue], UIEdgeInsetsZero)) : NO)

@implementation HomeButtonView

- (void)addButtonWithTitle:(NSString *)title imageName:(NSString *)imgName
{
    // 创建按钮
    TCButton *button = [TCButton buttonWithType:UIButtonTypeCustom];
    
    // 设置图片
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    // 监听
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

    // 添加
    [self addSubview:button];
    
}

/**
 *  监听按钮点击
 */
- (void)buttonClick:(TCButton *)button
{
    // 通知代理
    if ([self.delegate respondsToSelector:@selector(buttonViewDidSelect:withTag:)]) {
        [self.delegate buttonViewDidSelect:button withTag:button.tag];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 140;
    self.frame = CGRectMake(0, navBarHight, width, height);
    CGFloat butoonW = (width - 4 * margin) /3;
    CGFloat butoonH = butoonW + margin;
    int totalColumns = 3;
    if (width > height) {
        butoonH = ( height / (1.0 * self.subviews.count)) * totalColumns;
    }
    
    int count = (int)self.subviews.count;
    for (int i = 0; i<count; i++) {
        TCButton *butoon = self.subviews[i];
        int row = i / totalColumns;
        int col = i % totalColumns;
        CGFloat butoonX = margin + col * (margin + butoonW);
        CGFloat butoonY = row * (margin + butoonH);
        butoon.frame = CGRectMake(butoonX, butoonY, butoonW, butoonH);
        butoon.tag = i;

    }

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    if (@available(iOS 13.0, *)) {
        self.backgroundColor = UIColor.secondarySystemGroupedBackgroundColor;
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
    
}

- (void)drawRect:(CGRect)rect
{
    
}

@end
