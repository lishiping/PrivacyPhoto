//
//  LSPAlignButton.h
//
//  Created by lishiping on 2018/11/11.
//  Copyright © 2018 amap. All rights reserved.
//  本类是一个自定义的摆放按钮标题和图片的类，并不是真实的button类，是模仿button样式，
//  由于没有找到更好的UIButton类的标题和图片位置摆放的方法，所以使用这个类代替

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSPAlignButton : UIView

@property(nonatomic,strong) UILabel    *titleLabel;
@property(nonatomic,strong) UIImageView *imageView;
@property(nonatomic,getter=isSelected) BOOL selected;// default is NO

-(instancetype)initWithFrame:(CGRect)frame;

/// 控制自定义按钮的标题和图片，目前只支持normal和selected两种状态
/// @param title 标题
/// @param state 状态
-(void)setTitle:(nullable NSString *)title forState:(UIControlState)state;
-(void)setTitleColor:(nullable UIColor *)color forState:(UIControlState)state;
-(void)setImage:(nullable UIImage *)image forState:(UIControlState)state;

/// 控制按钮图片和文字位置及间距，设置标题和图片之后再调用此方法
/// @param padding 间距
-(void)sp_makeLeftImageRightTitle:(CGFloat)padding;
-(void)sp_makeLeftTitleRightImage:(CGFloat)padding;
-(void)sp_makeTopImageBottomTitle:(CGFloat)padding;
-(void)sp_makeTopTitleBottomImage:(CGFloat)padding;

/// 按钮点击事件
/// @param block 点击回调
-(void)button_onClickBlock:(void(^)(LSPAlignButton *sender))block;

@end

NS_ASSUME_NONNULL_END
