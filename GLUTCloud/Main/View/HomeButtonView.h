//
//  HomeButtonView.h
//  GLUTCloud
//
//  Created by HTC on 14-12-29.
//  Copyright (c) 2014年 HTC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TCButton;

@protocol HomeButtonViewDelegate <NSObject>

@optional

-(void)buttonViewDidSelect:(TCButton *)selBtn withTag:(NSInteger)tag;

@end

@interface HomeButtonView : UIView

@property (nonatomic , weak) id<HomeButtonViewDelegate> delegate;

/**
 *  添加按钮
 *
 */

- (void)addButtonWithTitle:(NSString *)title imageName:(NSString *)imgName;

@end
