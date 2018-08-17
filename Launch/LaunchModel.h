//
//  LaunchModel.h
//  MajiaDemo
//
//  Created by mc on 2018/7/20.
//  Copyright © 2018年 mc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LaunchModel : NSObject<NSCoding>

#pragma mark - 增加属性需要在NSCoding相关方法做操作
@property (nonatomic, copy) NSString *calories;
@property (nonatomic, copy) NSString *expirydate;
@property (nonatomic, copy) NSString *nutritional;
@property (nonatomic, copy) NSString *openid;
@property (nonatomic, copy) NSString *potato;
@property (nonatomic, copy) NSString *style;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *tomato;

// 从cache中加载
+ (instancetype)launchModelFromLocoalCache;
// 存入cache
- (void)saveToLocoalCache;
// 通过字典创建
- (instancetype)initWithDict:(NSDictionary *)dict;
@end
