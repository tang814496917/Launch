//
//  LaunchBottomView.h
//  01-majiatest
//
//  Created by mc on 2018/7/18.
//  Copyright © 2018年 mc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LaunchBottomView : UIView

@property (nonatomic, strong) void(^clickedHandler)(UIButton *btn);
@end
