//
//  LSPAlignButton.m
//
//  Created by lishiping on 2018/11/11.
//  Copyright © 2018 amap. All rights reserved.
//

#import "LSPAlignButton.h"
#import <UIView+SPFrame.h>

@interface LSPAlignButton()

@property(nonatomic,strong) UIImage *normalImage;
@property(nonatomic,strong) UIImage *selectImage;
@property(nonatomic,copy) NSString *normalTitle;
@property(nonatomic,copy) NSString *selectTitle;
@property(nonatomic,strong) UIColor *normalTitleColor;
@property(nonatomic,strong) UIColor *selectTitleColor;
@property (nonatomic, copy) void(^actionBlock)(LSPAlignButton *sender);

@end

@implementation LSPAlignButton

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self setupUI];
    return self;
}

-(void)setupUI
{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:self.titleLabel];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:self.imageView];
}

-(void)setImage:(UIImage *)image forState:(UIControlState)state
{
    if (state == UIControlStateNormal) {
        self.normalImage = image;
        self.imageView.image = image;
        self.imageView.sp_size = image.size;
    }
    else if(state == UIControlStateSelected){
        self.selectImage = image;
    }
}

-(void)setTitle:(NSString *)title forState:(UIControlState)state
{
    if (state == UIControlStateNormal) {
        self.normalTitle = title;
        self.titleLabel.text = title;
        [self.titleLabel sizeToFit];
    }else if(state == UIControlStateSelected){
        self.selectTitle = title;
    }
}

-(void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    if (state == UIControlStateNormal) {
        self.normalTitleColor = color;
        self.titleLabel.textColor = color;
    }else if(state == UIControlStateSelected){
        self.selectTitleColor = color;
    }
}
-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (selected) {
        self.imageView.image = self.selectImage;
        self.imageView.sp_size = self.selectImage.size;
        self.titleLabel.text = self.selectTitle;
        [self.titleLabel sizeToFit];
    }
    else{
        self.imageView.image = self.normalImage;
        self.imageView.sp_size = self.normalImage.size;
        self.titleLabel.text = self.normalTitle;
        [self.titleLabel sizeToFit];
    }
}

-(void)sp_makeLeftImageRightTitle:(CGFloat)padding
{
    [self.titleLabel sizeToFit];
    CGFloat imageWidth = self.imageView.frame.size.width;
    CGFloat labelWidth = self.titleLabel.frame.size.width;
    
    CGFloat height =  self.frame.size.height;
    CGFloat width = self.frame.size.width;
    
    self.imageView.sp_x =(width-imageWidth-labelWidth-padding)/2.0f;
    self.imageView.sp_centerY =height/2.0;
    self.titleLabel.sp_x =CGRectGetMaxX(self.imageView.frame)+padding;
    self.titleLabel.sp_centerY =height/2.0;
}
-(void)sp_makeLeftTitleRightImage:(CGFloat)padding
{
    [self.titleLabel sizeToFit];
    CGFloat imageWidth = self.imageView.frame.size.width;
    CGFloat labelWidth = self.titleLabel.frame.size.width;
    
    CGFloat height =  self.frame.size.height;
    CGFloat width = self.frame.size.width;
    
    self.titleLabel.sp_x =(width-imageWidth-labelWidth-padding)/2.0f;
    self.titleLabel.sp_centerY =height/2.0;
    self.imageView.sp_x =CGRectGetMaxX(self.titleLabel.frame)+padding;
    self.imageView.sp_centerY =height/2.0;
}
-(void)sp_makeTopImageBottomTitle:(CGFloat)padding
{
    [self.titleLabel sizeToFit];
    CGFloat imageHeight =  self.imageView.frame.size.height;
    CGFloat labelHeight = self.titleLabel.frame.size.height;
    
    CGFloat height =  self.frame.size.height;
    CGFloat width = self.frame.size.width;
    
    self.imageView.sp_y =(height-imageHeight-labelHeight-padding)/2.0f;
    self.imageView.sp_centerX =width/2.0;
    self.titleLabel.sp_y =CGRectGetMaxY(self.imageView.frame)+padding;
    self.titleLabel.sp_centerX =width/2.0;
    
}
-(void)sp_makeTopTitleBottomImage:(CGFloat)padding
{
    [self.titleLabel sizeToFit];
    CGFloat imageHeight =  self.imageView.frame.size.height;
    CGFloat labelHeight = self.titleLabel.frame.size.height;
    
    CGFloat height =  self.frame.size.height;
    CGFloat width = self.frame.size.width;
    
    self.titleLabel.sp_y =(height-imageHeight-labelHeight-padding)/2.0f;
    self.titleLabel.sp_centerX =width/2.0;
    self.imageView.sp_y =CGRectGetMaxY(self.titleLabel.frame)+padding;
    self.imageView.sp_centerX =width/2.0;
}


-(void)button_onClickBlock:(void (^)(LSPAlignButton * _Nonnull))block
{
    self.actionBlock = block;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
}

-(void)tapAction:(id)sender
{
    if (self.actionBlock) {
        self.actionBlock(self);
    }
}

@end
