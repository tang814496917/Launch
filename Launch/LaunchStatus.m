//
//  LaunchStatus.m
//  MajiaDemo
//
//  Created by mc on 2018/7/20.
//  Copyright © 2018年 mc. All rights reserved.
//

#import "LaunchStatus.h"
#import "Reachability.h"
#import "LaunchModel.h"
#import "LaunchDefine.h"
#import "LaunchView.h"
#import <AdSupport/AdSupport.h>
#import "NSString+LaunchAES.h"

@implementation LaunchResponse
@end

@interface LaunchStatus()
@property (nonatomic, strong) LaunchModel *model;
@property (nonatomic, strong) Reachability *reach;
@end

@implementation LaunchStatus

#pragma mark - 外部调用
+ (instancetype)sharedStatus
{
    static id _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

// 配置
- (void)setupLaunchStatus
{
    self.model = [LaunchModel launchModelFromLocoalCache];
    if (self.model) {
        [self showLaunchView];
    }
    //网络检测
    _reach   = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [self postWithInfo:@{@"appid":LaunchAPPID} finish:^(LaunchResponse *result) {
        if (result.code == StudyWorkTypeSucceed) {
            if (!self.model) {
                [self showLaunchView];
            }
        }else if(result.code == StudyWorkTypeFail){
            [self setupLaunchStatus];
        }else{
            
        }
    }];
}

/** 网络监听*/
- (void)reachabilityChanged:(NSNotification *)notification{
    NetworkStatus status = [self.reach currentReachabilityStatus];
    if (status != NotReachable) {
        [self setupLaunchStatus];
    }
}

#pragma mark --------内部方法
- (void)showLaunchView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        LaunchView * launch = [[LaunchView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        [launch showInView:window];
    });
}

// post请求方法
- (void)postWithInfo:(NSDictionary *)info finish:(void(^)(LaunchResponse *result))finish
{
    Reachability *reachability   = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        LaunchResponse *response = [[LaunchResponse alloc] init];
        response.code = StudyWorkTypeNoNetWork;
        response.msg = @"您当前的网络异常,请查看是否连接!";
        finish(response);
        return;
    }
    NSURL *studyAddress = [NSURL URLWithString:LaunchAddress];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:studyAddress];
    NSURLSession *session=[NSURLSession sharedSession];
    NSMutableDictionary * tempParam = [NSMutableDictionary dictionary];
    
    NSString *studyIDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [tempParam setValue:studyIDFA forKey:@"IDFA"];
    
    //getCurrentTimes
    [tempParam addEntriesFromDictionary:info];
    NSMutableDictionary * dicMu = [[NSMutableDictionary alloc]init];
    NSArray * arrayKeys = [tempParam allKeys];
    for (NSString * key in arrayKeys) {
        NSString *encryptValue = [[tempParam objectForKey:key] LaunchAES_encryptWithAES];
        [dicMu setObject:encryptValue forKey:key];
    }
    [dicMu setValue:[[NSString stringWithFormat:@"%@_%@",@"chiji",[LaunchStatus getCurrentTimes]] LaunchAES_MD5ForUpper32Bate] forKey:@"timetoken"];
    NSString * paramStr = [self studyConvertToJsonData:dicMu];
    NSData *postData = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error) {
                
                LaunchResponse *result = [[LaunchResponse alloc] init];
                result.code = StudyWorkTypeFail;
                result.msg = @"系统服务繁忙，请您稍后再试！";
                finish(result);
            }else{
                NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                
                NSData * data1 = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data1 options:NSJSONReadingMutableLeaves error:nil];
                NSLog(@"^^^^%@",jsonDict);
                LaunchResponse *result = [LaunchResponse new];
                result.msg = jsonDict[@"msg"];
                if ([jsonDict[@"code"] integerValue] == 1) {
                    result.code = StudyWorkTypeSucceed;
                }else{
                    result.code = StudyWorkTypeFail;
                }
                
                if (jsonDict[@"data"] != nil&&![jsonDict[@"data"] isEqual:[NSNull null]]) {
                    
                    NSMutableDictionary * dicRes = [NSMutableDictionary new];
                    NSDictionary * dicData = jsonDict[@"data"];
                    if ([dicData isKindOfClass:[NSDictionary class]]) {
                        NSArray * arrayJsonDictKey = [dicData allKeys];
                        for (NSString * key in arrayJsonDictKey) {
                            [dicRes setObject:[[dicData objectForKey:key] LaunchAES_decryptWithAES] forKey:key];
                        }
                        LaunchModel *model = [[LaunchModel alloc] initWithDict:dicRes];
                        [model saveToLocoalCache];
                    }
                }
                finish(result);
            }
        });
    }];
    
    [dataTask resume];
}


+(NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    [formatter setDateFormat:@"YYYYMMdd_HH"];
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    NSLog(@"currentTimeString =  %@",currentTimeString);
    
    return currentTimeString;
    
}

- (NSString *)studyConvertToJsonData:(NSDictionary *)dict

{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
    
}
@end
