//
//  BFDynamicItem.m
//  CustomScrollView
//
//  Created by bifangao on 16/6/14.
//  Copyright © 2016年 bifangao. All rights reserved.
//

#import "BFDynamicItem.h"

@implementation BFDynamicItem
//-(void)setCenter:(CGPoint)center{
//
//}
//
//-(CGPoint)center{
//    return CGPointMake(0, 0);
//}

-(instancetype)init{
    self = [super init];
    if (self) {
        _bounds = CGRectMake(0, 0, 1, 1);
    }
    
    return self;
}
@end
