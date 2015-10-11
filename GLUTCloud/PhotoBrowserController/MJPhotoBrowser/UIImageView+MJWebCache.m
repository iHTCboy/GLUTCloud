//
//  UIImageView+MJWebCache.m
//  FingerNews
//
//  Created by mj on 13-10-2.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "UIImageView+MJWebCache.h"
#import "UIImageView+WebCache.h"

@implementation UIImageView (MJWebCache)
- (void)setImageURL:(NSURL *)url placeholder:(UIImage *)placeholder
{
    [self sd_setImageWithURL:url placeholderImage:placeholder];
}

- (void)setImageURLStr:(NSString *)urlStr placeholder:(UIImage *)placeholder
{
    [self sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:placeholder];
    
}
@end
