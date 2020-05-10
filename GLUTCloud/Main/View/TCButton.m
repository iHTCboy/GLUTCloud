//
//  TCButton.m
//  GLUTCloud
//
//  Created by HTC on 14-12-29.
//  Copyright (c) 2014年 HTC. All rights reserved.
//

#import "TCButton.h"
#import "appMarco.h"

#define margin 35


@implementation TCButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       // [self setup];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        //[self setup];
    }
    return self;
}



-(void)drawRect:(CGRect)rect
{
    if (@available(iOS 13.0, *)) {
        [self setTitleColor:UIColor.labelColor forState:UIControlStateNormal];
        self.layer.borderColor = [[UIColor tertiaryLabelColor] CGColor];
    } else {
        [self setTitleColor:[UIColor colorWithWhite:0.098 alpha:1.000] forState:UIControlStateNormal];
        self.layer.borderColor = [[UIColor colorWithWhite:0.800 alpha:1.000]CGColor];
    }

    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    //self.titleLabel.backgroundColor = [UIColor colorWithRed:0.270 green:0.633 blue:1.000 alpha:1];
    
//    self.titleLabel.layer.cornerRadius = 4;
//    self.titleLabel.layer.masksToBounds = YES;
    
    self.layer.borderWidth = 0.5f;
    self.layer.cornerRadius = 0;
    self.layer.masksToBounds = YES;


}

// 设置文字
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat Y = contentRect.size.width;
    CGFloat W = contentRect.size.width;
    CGFloat H = margin;
    
    return CGRectMake(0, Y - 1.5 * margin, W, H);

}


 // 顶部图片
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat W = contentRect.size.width - 2 *margin;
    CGFloat H = W;
    
    return CGRectMake(margin, margin /2, W, H);
    
}

@end
