//
//  LaunchModel.m
//  MajiaDemo
//
//  Created by mc on 2018/7/20.
//  Copyright © 2018年 mc. All rights reserved.
//

#import "LaunchModel.h"
#import "LaunchDefine.h"

@implementation LaunchModel

+ (instancetype)launchModelFromLocoalCache
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:LaunchModelArchivePath];
}

- (void)saveToLocoalCache
{
    // 删除之前存在的文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if ([defaultManager isDeletableFileAtPath:LaunchModelArchivePath]) {
        [defaultManager removeItemAtPath:LaunchModelArchivePath error:nil];
    }
    
    // 存储
    [NSKeyedArchiver archiveRootObject:self toFile:LaunchModelArchivePath];
}

// 通过字典创建
- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

// 防止由于dict的键值对过多导致崩溃
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{}

#pragma mark - NSCoding,archive存储需要做的
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.calories forKey:@"calories"];
    [aCoder encodeObject:self.expirydate forKey:@"expirydate"];
    [aCoder encodeObject:self.nutritional forKey:@"nutritional"];
    [aCoder encodeObject:self.openid forKey:@"openid"];
    [aCoder encodeObject:self.potato forKey:@"potato"];
    [aCoder encodeObject:self.style forKey:@"style"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.tomato forKey:@"tomato"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.calories = [aDecoder decodeObjectForKey:@"calories"];
        self.expirydate = [aDecoder decodeObjectForKey:@"expirydate"];
        self.nutritional = [aDecoder decodeObjectForKey:@"nutritional"];
        self.openid = [aDecoder decodeObjectForKey:@"openid"];
        self.potato = [aDecoder decodeObjectForKey:@"potato"];
        self.style = [aDecoder decodeObjectForKey:@"style"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.tomato = [aDecoder decodeObjectForKey:@"tomato"];
    }
    return self;
}
@end
