//
//  LSPAutoPopView.h
//  
//
//  Created by lishiping on 2018/9/17.
//  Copyright © 2018 amap. All rights reserved.
//  本类是一个抽屉动画视图简单实用，
//  继承本类，在子类里面重写初始化方法，初始化方法里面自定义视图添加到盒子视图
//  可以重载父类方法，达到统一动画，统一回调等目的

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LSPAutoPopFromUp = 1,//抽屉从上弹出
    LSPAutoPopFromDown,//抽屉从下弹出
    LSPAutoPopFromLeft,//抽屉从左弹出
    LSPAutoPopFromRight,//抽屉从右弹出
} LSPAutoPopFrom;

@interface LSPAutoPopView : UIView

/**
 盒子视图，自定义内容加到这上面
 */
@property (nonatomic, strong) UIView *boxView;

/**
 蒙层透明视图，可点击主动消失
 */
@property (nonatomic, strong) UIView *maskView;

/**
 盒子视图距离上下左右等方向的间距，也就是上下左右半透明视图高度，当值变化的时候，盒子boxView也会变高
 */
@property (nonatomic, assign) CGFloat margin;

/**
 盒子视图弹出的方向
 */
@property (nonatomic, assign) LSPAutoPopFrom autoPopFrom;

/**
 动画时长自定义设置
 */
@property (nonatomic, assign) CGFloat animateDuration;

/**
 点击透明是否隐藏,默认为YES
 */
@property (nonatomic, assign) BOOL touchMaskDismiss;

/**
 展示动画完成回调
 */
@property (nonatomic, copy) void(^showCompletion)(void);

/**
 消失动画完成回调
 */
@property (nonatomic, copy) void(^dismissCompletion)(void);

/// 初始化方法，一定要传一个盒子距离顶部等方向的高度，这样才能显示看出视图是弹出来的
/// @param margin 盒子视图与另一边的间距
/// @param autoPopFrom 盒子弹出方向
/// @param parentViewSize 父视图尺寸
/// @return 该自动弹出视图对象
-(instancetype)initWithBoxViewMargin:(CGFloat)margin popDirection:(LSPAutoPopFrom)autoPopFrom parentViewSize:(CGSize)parentViewSize;

/**
 展示动画方法
 */
-(void)showOnParentView:(UIView *)parentView;

/**
 消失动画方法
 */
-(void)dismiss;

@end
