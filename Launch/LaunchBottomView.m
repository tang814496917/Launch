//
//  LaunchBottomView.m
//  01-majiatest
//
//  Created by mc on 2018/7/18.
//  Copyright © 2018年 mc. All rights reserved.
//

#import "LaunchBottomView.h"
#import "LaunchDefine.h"

@interface LaunchBttton : UIButton
@end

@implementation LaunchBttton
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageView.contentMode = UIViewContentModeCenter;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat width = contentRect.size.width;
    CGFloat height = contentRect.size.height * 0.7;
    return CGRectMake(0, 0, width, height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat y = contentRect.size.height * 0.7;
    CGFloat width = contentRect.size.width;
    CGFloat height = contentRect.size.height * 0.3;
    return CGRectMake(0, y, width, height);
}
@end


@interface LaunchBottomView()
@property (nonatomic, strong) NSArray *btnNames;
@property (nonatomic, strong) NSMutableArray<LaunchBttton *> *btns;
@end

@implementation LaunchBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.btnNames = @[@"首页",@"刷新",@"后退",@"前进",@"清理缓存"];
        self.btns = [NSMutableArray array];
        self.backgroundColor = kBottomBgColor;
        
        // 底部的button
        for (int i = 0; i < self.btnNames.count; i++) {
            NSString *title = self.btnNames[i];
            LaunchBttton *btn = [[LaunchBttton alloc] init];
            [self addSubview:btn];
            [self.btns addObject:btn];
            
            // btn设定
            NSString *imageName = [NSString stringWithFormat:@"LaunchImg_%d", i];
            NSString *imagePath = kLaunchConfigSrcName(imageName);
            [btn setImage:[UIImage imageNamed:imagePath] forState:UIControlStateNormal];
            [btn setTitle:title forState:UIControlStateNormal];
            [btn setTitleColor:kBottomTextColor forState:UIControlStateNormal];
            
            btn.titleLabel.font = [UIFont systemFontOfSize:11];
            
            btn.tag = i;
            [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = kBottomBtnHeight;
    NSInteger count = self.btns.count;
    CGFloat btnW = width / count;
    [self.btns enumerateObjectsUsingBlock:^(UIButton* btn, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat btnX = idx * btnW;
        btn.frame = CGRectMake(btnX, 0, btnW, height);
    }];
}

- (void)btnClicked:(UIButton *)btn
{
    // 通知外部
    if (self.clickedHandler) {
        self.clickedHandler(btn);
    }
}
@end
