//
//  LaunchDefine.h
//  MajiaDemo
//
//  Created by mc on 2018/7/20.
//  Copyright © 2018年 mc. All rights reserved.
//

#ifndef LaunchDefine_h
#define LaunchDefine_h

// appid
#define LaunchAPPID  @"1428371318"

// model本地存储位置
#define LaunchModelArchivePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"LaunchModel.archive"]

// 颜色配置
#define kContentBgColor [UIColor whiteColor]
#define kContentTitleColor [UIColor blackColor]
#define kContentSubTitleColor [UIColor blackColor]
#define kContentDoneBtnBgColor [UIColor colorWithRed:44/255.0 green:104/255.0 blue:188/255.0 alpha:1.0];
#define kContentDoneBtnTextColor [UIColor whiteColor]
#define kBottomBgColor [UIColor colorWithRed:22/255.0 green:22/255.0 blue:22/255.0 alpha:1.0]
#define kBottomTextColor [UIColor colorWithRed:205/255.0 green:20/255.0 blue:47/255.0 alpha:1.0]

// 高度&宽度等配置
#define kBottomBtnHeight 44

// 图片路径
#define kLaunchConfigSrcName(file) [@"LaunchView.bundle" stringByAppendingPathComponent:file]

// 请求路径
#define LaunchAddress @"http://wincjwin.com:50103/app/Foodies"

#endif /* LaunchDefine_h */
