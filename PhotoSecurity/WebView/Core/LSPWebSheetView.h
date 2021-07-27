//
//  LSPWebSheetView.h
//
//  Created by lishiping on 2020/11/6.
//  Copyright © 2020 lishiping. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPAutoPopView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSPWebSheetView : LSPAutoPopView

@property (nonatomic, copy) void(^refreshBlock)(void);
@property (nonatomic, copy) void(^copyBlock)(void);

@end

NS_ASSUME_NONNULL_END
