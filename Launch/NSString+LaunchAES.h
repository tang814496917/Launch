//
//  NSString+LaunchAES.h
//  MajiaDemo
//
//  Created by mc on 2018/7/20.
//  Copyright © 2018年 mc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LaunchAES)
/**< 加密方法 */
- (NSString*)LaunchAES_encryptWithAES;

/**< 解密方法 */
- (NSString*)LaunchAES_decryptWithAES;

// md5
- (NSString *)LaunchAES_MD5ForUpper32Bate;
@end
