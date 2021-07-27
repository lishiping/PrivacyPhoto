//
//  LSPAutoPopView.m
//
//
//  Created by lishiping on 2018/9/17.
//  Copyright © 2018 amap. All rights reserved.
//

#import "LSPAutoPopView.h"
#import <UIView+SPFrame.h>

@interface LSPAutoPopView ()

@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;

@end

@implementation LSPAutoPopView

- (instancetype)initWithBoxViewMargin:(CGFloat)margin popDirection:(LSPAutoPopFrom)autoPopFrom parentViewSize:(CGSize)parentViewSize
{
    if (self = [super init]) {
        self.screenWidth =parentViewSize.width;
        self.screenHeight =parentViewSize.height;
        self.margin = margin;
        self.autoPopFrom = autoPopFrom;
        self.animateDuration=0.0f;
        self.touchMaskDismiss = YES;
        self.frame = CGRectMake(0, 0,self.screenWidth , self.screenHeight);
        self.maskView = [[UIView alloc] initWithFrame:self.bounds];
        self.maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
        [self.maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGuesture:)]];
        [self addSubview:self.maskView];
        
        CGRect frame = CGRectZero;
        if (self.autoPopFrom == LSPAutoPopFromUp) {
            frame = CGRectMake(0, margin-self.screenHeight, self.screenWidth, self.screenHeight-margin);
        }
        else if (self.autoPopFrom == LSPAutoPopFromDown){
            frame = CGRectMake(0, self.screenHeight, self.screenWidth, self.screenHeight-margin);
        }
        else if (self.autoPopFrom == LSPAutoPopFromLeft){
            frame = CGRectMake(margin-self.screenWidth, 0, self.screenWidth-margin, self.screenHeight);
        }
        else if (self.autoPopFrom == LSPAutoPopFromRight){
            frame = CGRectMake(self.screenWidth, 0, self.screenWidth-margin, self.screenHeight);
        }
        self.boxView = [[UIView alloc] initWithFrame:frame];
        self.boxView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.boxView];
    }
    return self;
}

-(void)setMargin:(CGFloat)margin
{
    _margin = margin;
    if (self.autoPopFrom == LSPAutoPopFromUp) {
        self.boxView.sp_y=0;
        self.boxView.sp_height = self.screenHeight-margin;
    }
    else if (self.autoPopFrom == LSPAutoPopFromDown){
        self.boxView.sp_y=margin;
        self.boxView.sp_height = self.screenHeight-margin;
    }
    else if (self.autoPopFrom == LSPAutoPopFromLeft){
        self.boxView.sp_x=0;
        self.boxView.sp_width = self.screenWidth-margin;
    }
    else if (self.autoPopFrom == LSPAutoPopFromRight){
        self.boxView.sp_x=margin;
        self.boxView.sp_width = self.screenWidth-margin;
    }
}

- (void)handleGuesture:(UITapGestureRecognizer *)sender
{
    if (self.touchMaskDismiss) {
        [self dismiss];
    }
}

-(void)showOnParentView:(UIView *)parentView
{
    [parentView addSubview:self];
    [UIView animateWithDuration:self.animateDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        
        if (self.autoPopFrom == LSPAutoPopFromUp) {
            self.boxView.sp_y=0;
        }
        else if (self.autoPopFrom == LSPAutoPopFromDown){
            self.boxView.sp_y=self.margin;
        }
        else if (self.autoPopFrom == LSPAutoPopFromLeft){
            self.boxView.sp_x=0;
        }
        else if (self.autoPopFrom == LSPAutoPopFromRight){
            self.boxView.sp_x=self.margin;
        }
    }
                     completion:^(BOOL finished) {
        if (self.showCompletion) {
            self.showCompletion();
        }
    }];
}

-(void)dismiss
{
    [UIView animateWithDuration:self.animateDuration
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        if (self.autoPopFrom == LSPAutoPopFromUp) {
            self.boxView.sp_y=self.margin-self.screenHeight;
        }
        else if (self.autoPopFrom == LSPAutoPopFromDown){
            self.boxView.sp_y=self.screenHeight;
        }
        else if (self.autoPopFrom == LSPAutoPopFromLeft){
            self.boxView.sp_x=self.margin-self.screenWidth;
        }
        else if (self.autoPopFrom == LSPAutoPopFromRight){
            self.boxView.sp_x=self.screenWidth;
        }
    }
                     completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.dismissCompletion) {
            self.dismissCompletion();
        }
    }];
}

@end
