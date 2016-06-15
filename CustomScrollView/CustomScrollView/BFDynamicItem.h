//
//  BFDynamicItem.h
//  CustomScrollView
//
//  Created by bifangao on 16/6/14.
//  Copyright © 2016年 bifangao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface BFDynamicItem : NSObject <UIDynamicItem>
@property (nonatomic, readwrite) CGPoint center;
@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic, readwrite) CGAffineTransform transform;
@end
