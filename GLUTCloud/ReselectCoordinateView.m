//
//  LZCoordinateView.m
//  maidaojia
//
//  Created by bailin on 14-6-23.
//  Copyright (c) 2014年 BaiLin. All rights reserved.
//

#import "ReselectCoordinateView.h"

@implementation ReselectCoordinateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        //加载xib文件
        UIView * topView =  [[[NSBundle mainBundle]loadNibNamed:@"ReselectCoordinateView" owner:self options:nil] objectAtIndex:0];
        [self addSubview:topView];
        [self setFrame:topView.frame];
        [self setFrame:frame];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
