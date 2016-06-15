//
//  BFScrollView.m
//  CustomScrollView
//
//  Created by bifangao on 16/6/14.
//  Copyright © 2016年 bifangao. All rights reserved.
//

#import "BFScrollView.h"
#import "BFDynamicItem.h"
/**
 *  rubber(橡皮筋)下拉距离
 *  formulate:f(x, d, c) = (x * d * c) / (d + c * x)
 *   https://twitter.com/chpwn/status/285540192096497664
 *
 *  @param offset touch distance (distance from the edge)
 *  @param dimension dimension, either width or height
 *
 *  @return visual distance
 */
static CGFloat rubberBandDistance(CGFloat offset, CGFloat dimension){
    const CGFloat constant = 0.55f;
    CGFloat result = (constant * fabs(offset) * dimension) /
    (dimension + constant * fabs(offset));
    
    return offset < 0 ? -result : result;
}

@interface BFScrollView()

@property (nonatomic) CGRect startBounds;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, weak) UIDynamicItemBehavior *decelerationBehavior;
@property (nonatomic, weak) UIAttachmentBehavior *springBehavior;
@property (nonatomic, strong) BFDynamicItem *dynamicItem;
@property (nonatomic) CGPoint lastPointInBounds;

@end

@implementation BFScrollView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self customInitScrollView];
    }
    return self;
}

- (void)customInitScrollView{
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGestureRecognizer];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    self.dynamicItem = [[BFDynamicItem alloc] init];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture{
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.startBounds = self.bounds;
            [self.animator removeAllBehaviors];
        }
            break;
        case  UIGestureRecognizerStateChanged:
        {
            /**
             *  偏移量，此时手指还未离开屏幕
             */
            CGPoint translation = [panGesture translationInView:self];
            CGRect bounds = self.startBounds;
            
            if (![self scrollHorizontal]) {
                translation.x = 0;
            }
            if (![self scrollVertical]) {
                translation.y = 0;
            }
            /**
             *  bounds边界不得超出contensize的边界
             */
            CGFloat newBoundsOriginX = bounds.origin.x - translation.x;
            CGFloat minBoundsOriginX = 0;
            CGFloat maxBoundsOriginX = self.contentSize.width - bounds.size.width;
            CGFloat constrainedBoundsOriginX = fmax(minBoundsOriginX, fmin(newBoundsOriginX, maxBoundsOriginX));
            /**
             *  y轴同上
             */
            CGFloat newBoundsOriginY = bounds.origin.y - translation.y;
            CGFloat minBoundsOriginY = 0;
            CGFloat maxBoundsOriginY = self.contentSize.height - bounds.size.height;
            CGFloat constrainedBoundsOriginY = fmax(minBoundsOriginY, fmin(newBoundsOriginY, maxBoundsOriginY));
            
            CGFloat rubberBandedX = rubberBandDistance(newBoundsOriginX - constrainedBoundsOriginX, CGRectGetWidth(self.bounds));
            bounds.origin.x = constrainedBoundsOriginX + rubberBandedX;
            CGFloat rubberBandedY = rubberBandDistance(newBoundsOriginY - constrainedBoundsOriginY, CGRectGetHeight(self.bounds));
            bounds.origin.y = constrainedBoundsOriginY + rubberBandedY;
            self.bounds = bounds;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGPoint velocity = [panGesture velocityInView:self];
            velocity.x = - velocity.x;
            velocity.y = - velocity.y;
            if (![self scrollHorizontal] || [self outsideBoundsMaximun] || [self outsideBoundsMinimum]) {
                velocity.x = 0;
            }
            if (![self scrollVertical] || [self outsideBoundsMaximun] || [self outsideBoundsMinimum]) {
                velocity.y = 0;
            }
            
            self.dynamicItem.center = self.bounds.origin;
            UIDynamicItemBehavior *decelerationBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.dynamicItem]];
            [decelerationBehavior addLinearVelocity:velocity forItem:self.dynamicItem];
            decelerationBehavior.resistance = 2.0;
            __weak typeof(self) weakSelf = self;
            decelerationBehavior.action = ^{
                /**
                 *  移动self.bounds会驱使dynamicitem改变自身的center，触发dynamicitem的setCenter方法
                 */
                CGRect bounds = weakSelf.bounds;
                bounds.origin = weakSelf.dynamicItem.center;
                weakSelf.bounds = bounds;
            };
            [self.animator addBehavior:decelerationBehavior];
            self.decelerationBehavior = decelerationBehavior;
        }
            break;
        default:
            break;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
/**
 *  判断这个scrollview的contentsize有没有大到可以横滚
 *
 *  @return 是否可以横滚
 */
- (BOOL)scrollHorizontal{
    return self.contentSize.width > CGRectGetWidth(self.bounds);
}
/**
 *  同上
 *
 *  @return 是否可以竖着滚动
 */
- (BOOL)scrollVertical{
    return self.contentSize.height > CGRectGetHeight(self.bounds);
}

-(void)setBounds:(CGRect)bounds{
    [super setBounds:bounds];
    /**
     *  首先判断是否超出边界,并且要在手势离开以后减速过程中吸附
     */
    if (([self outsideBoundsMinimum] || [self outsideBoundsMaximun]) && (self.decelerationBehavior && !self.springBehavior)) {
        CGPoint attachAnchor = [self attachAnchor];
        UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.dynamicItem attachedToAnchor:attachAnchor];
        springBehavior.length = 0;
        springBehavior.damping = 1;
        springBehavior.frequency = 2;
        [self.animator addBehavior:springBehavior];
        self.springBehavior = springBehavior;
    }
    /**
     *  没有超出边界的时候
     */
    if (![self outsideBoundsMaximun] && ![self outsideBoundsMinimum]) {
        self.lastPointInBounds = bounds.origin;
    }
}
/**
 *  判断是否超出边界
 *
 *  @return 是否超出边界
 */
- (BOOL)outsideBoundsMinimum{
    return self.bounds.origin.x < 0 || self.bounds.origin.y < 0;
}
/**
 *  同上
 */
- (BOOL)outsideBoundsMaximun{
    CGPoint maxBoundsOrigin = [self maxBoundsOrigin];
    return self.bounds.origin.x > maxBoundsOrigin.x || self.bounds.origin.y > maxBoundsOrigin.y;
}
/**
 *
 *
 *  @return 根据contentsize和bounds得到self的最大origin
 */
- (CGPoint)maxBoundsOrigin{
    return CGPointMake(self.contentSize.width - self.bounds.size.width,
                       self.contentSize.height - self.bounds.size.height);
}
/**
 *  回弹吸附点
 *
 *  @return attach point
 */
- (CGPoint)attachAnchor{
    CGRect bounds = self.bounds;
    CGPoint maxBoundsOrigin = [self maxBoundsOrigin];
    CGFloat deltaX = self.lastPointInBounds.x - bounds.origin.x;
    CGFloat deltaY = self.lastPointInBounds.y - bounds.origin.y;
    // 二元一次方程: y_1 = ax_1 + b and y_2 = ax_2 + b
    CGFloat a = deltaY / deltaX;
    CGFloat b = self.lastPointInBounds.y - self.lastPointInBounds.x * a;
    
    CGFloat leftBending = -bounds.origin.x;
    CGFloat topBending = -bounds.origin.y;
    CGFloat rightBending = bounds.origin.x - maxBoundsOrigin.x;
    CGFloat bottomBending = bounds.origin.y - maxBoundsOrigin.y;
    
    void(^updateY)(CGPoint *) = ^(CGPoint *anchor){
        if (deltaY != 0) {
            anchor->y = a * anchor->x +b;
        }
    };
    
    void(^updateX)(CGPoint *) = ^(CGPoint *anchor){
        if (deltaX != 0) {
            anchor->x = (anchor->y - b) / a;
        }
    };
    
    CGPoint anchor = bounds.origin;
    if (bounds.origin.x < 0 && leftBending > topBending && leftBending > bottomBending) {
        anchor.x = 0;
        updateY(&anchor);
    } else if (bounds.origin.y < 0 && topBending > leftBending && topBending > rightBending){
        anchor.y = 0;
        updateX(&anchor);
    } else if (bounds.origin.x > maxBoundsOrigin.x && rightBending > topBending && rightBending > bottomBending) {
        anchor.x = maxBoundsOrigin.x;
        updateY(&anchor);
    } else if (bounds.origin.y > maxBoundsOrigin.y) {
        anchor.y = maxBoundsOrigin.y;
        updateX(&anchor);
    }
    
    return anchor;
    
}
@end
