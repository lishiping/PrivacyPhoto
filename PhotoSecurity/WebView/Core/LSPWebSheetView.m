//
//  LSPWebSheetView.m
//  LGLApolloApi
//
//  Created by lishiping on 2020/11/6.
//  Copyright © 2020 lgl. All rights reserved.
//

#import "LSPWebSheetView.h"
#import "LSPAlignButton.h"
#import "LSPBundleTools.h"
#import <UIView+SPBorder.h>
#import "UIImage+Util.h"
#import <SPMacro.h>


@interface LSPWebSheetView()

@end

@implementation LSPWebSheetView

-(instancetype)initWithBoxViewMargin:(CGFloat)margin popDirection:(LSPAutoPopFrom)autoPopFrom parentViewSize:(CGSize)parentViewSize
{
    self = [super initWithBoxViewMargin:margin popDirection:autoPopFrom parentViewSize:parentViewSize];
    self.boxView.backgroundColor = UIColor.whiteColor;
    [self.boxView sp_border_radius:(UIRectCornerTopLeft|UIRectCornerTopRight) corner:10];
    self.animateDuration=0.2f;
    [self setupUI];
    return self;
}

-(void)setupUI
{
    SP_WEAK_SELF
    LSPAlignButton *refreshB = [[LSPAlignButton alloc] initWithFrame:CGRectMake(30, 50, 60, 60)];
//    refreshB.backgroundColor = UIColor.redColor;
    UIImage *eyen =LSP_IMAGE(@"SPWebView", @"reading_loop");
    eyen = [eyen imageWithColor:UIColor.blackColor];
    [refreshB setImage:eyen forState:UIControlStateNormal];
    [refreshB setTitle:@"刷新" forState:UIControlStateNormal];
    [refreshB setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    refreshB.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.boxView addSubview:refreshB];
    [refreshB sp_makeTopImageBottomTitle:8];
    [refreshB button_onClickBlock:^(LSPAlignButton * _Nonnull sender) {
        [weak_self dismiss];
        if (weak_self.refreshBlock) {
            weak_self.refreshBlock();
        }
    }];
    
    LSPAlignButton *copyB = [[LSPAlignButton alloc] initWithFrame:CGRectMake(100, 50, 60, 60)];
//    copyB.backgroundColor = UIColor.redColor;
    UIImage *copyn =LSP_IMAGE(@"SPWebView", @"sp_link_brown");
    copyn = [copyn imageWithColor:UIColor.blackColor];
    [copyB setImage:copyn forState:UIControlStateNormal];
    [copyB setTitle:@"复制链接" forState:UIControlStateNormal];
    [copyB setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    copyB.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.boxView addSubview:copyB];
    [copyB sp_makeTopImageBottomTitle:11];
    [copyB button_onClickBlock:^(LSPAlignButton * _Nonnull sender) {
        [weak_self dismiss];
        if (weak_self.copyBlock) {
            weak_self.copyBlock();
        }
    }];
}

@end


