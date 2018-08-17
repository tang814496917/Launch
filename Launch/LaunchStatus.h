//
//  LaunchStatus.h
//  MajiaDemo
//
//  Created by mc on 2018/7/20.
//  Copyright © 2018年 mc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    StudyWorkTypeFail = -911,        // 请求失败
    StudyWorkTypeNoNetWork = -811,   // 没有网络
    StudyWorkTypeSucceed = 1,        // 请求成功
} StudyWork;

@interface LaunchResponse : NSObject
/** 整个返回的JSON字典 */
@property (nonatomic, strong) NSDictionary *jsonDic;
/** 已经解析的具体数据 */
@property (nonatomic, strong) id data;
/** 状态码 0:请求成功 -1:请求失败 其它code码根据具体接口文档定义 */
@property (nonatomic, assign) StudyWork code;
/** 客户端展示的提示 */
@property (nonatomic, copy) NSString *msg;
/** 服务器异常数据 */
@property (nonatomic, copy) NSString *messageErr;
/** 错误解决方案 */
@property (nonatomic, copy) NSString *solution;

@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) NSError *error;
@end


@interface LaunchStatus : NSObject
// 单例方法，必须使用这个方法才能获取到单例
+ (instancetype)sharedStatus;

// 配置
- (void)setupLaunchStatus;
@end
