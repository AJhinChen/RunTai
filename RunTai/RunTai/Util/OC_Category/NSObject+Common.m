//
//  NSObject+Common.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-7-31.
//  Copyright (c) 2014年 Coding. All rights reserved.
//
#define kPath_ImageCache @"ImageCache"
#define kPath_ResponseCache @"ResponseCache"
#define kTestKey @"BaseURLIsTest"
#define kHUDQueryViewTag 101

#import "NSObject+Common.h"
#import "AppDelegate.h"
#import "LoadingView.h"
#import "MBProgressHUD+Add.h"

@implementation NSObject (Common)

#pragma mark Tip M
+ (NSString *)tipFromError:(NSError *)error{
    if (error && error.userInfo) {
        NSMutableString *tipStr = [[NSMutableString alloc] init];
        if ([error.userInfo objectForKey:@"msg"]) {
            NSArray *msgArray = [[error.userInfo objectForKey:@"msg"] allValues];
            NSUInteger num = [msgArray count];
            for (int i = 0; i < num; i++) {
                NSString *msgStr = [msgArray objectAtIndex:i];
                if (i+1 < num) {
                    [tipStr appendString:[NSString stringWithFormat:@"%@\n", msgStr]];
                }else{
                    [tipStr appendString:msgStr];
                }
            }
        }else{
            if ([error.userInfo objectForKey:@"NSLocalizedDescription"]) {
                tipStr = [error.userInfo objectForKey:@"NSLocalizedDescription"];
            }else{
                [tipStr appendFormat:@"ErrorCode%ld", (long)error.code];
            }
        }
        return tipStr;
    }
    return nil;
}


#pragma mark loadingView

static LoadingView *_newLoadingView = nil;
+ (void)showLoadingView:(NSString *)title {
    if (!_newLoadingView) {
        _newLoadingView =[[LoadingView alloc] initFullScreen:title];
    } else {
        [_newLoadingView setTitle:title];
    }
}

+ (void)hideLoadingView {
    if (_newLoadingView) {
        [_newLoadingView dismiss];
        _newLoadingView = nil;
    }
}
+ (void)showHudTipStr:(NSString *)tipStr{
    if (tipStr && tipStr.length > 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelFont = [UIFont boldSystemFontOfSize:15.0];
        hud.detailsLabelText = tipStr;
        hud.margin = 10.f;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:1.5];
    }
}
+ (instancetype)showHUDQueryStr:(NSString *)titleStr{
    titleStr = titleStr.length > 0? titleStr: @"正在获取数据...";
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
    hud.tag = kHUDQueryViewTag;
    hud.labelText = titleStr;
    hud.labelFont = [UIFont boldSystemFontOfSize:15.0];
    hud.margin = 10.f;
    return hud;
}
+ (NSUInteger)hideHUDQuery{
    __block NSUInteger count = 0;
    NSArray *huds = [MBProgressHUD allHUDsForView:kKeyWindow];
    [huds enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if (obj.tag == kHUDQueryViewTag) {
            [obj removeFromSuperview];
            count++;
        }
    }];
    return count;
}

#pragma mark File M
//获取fileName的完整地址
+ (NSString* )pathInCacheDirectory:(NSString *)fileName
{
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    return [cachePath stringByAppendingPathComponent:fileName];
}
//创建缓存文件夹
+ (BOOL) createDirInCache:(NSString *)dirName
{
    NSString *dirPath = [self pathInCacheDirectory:dirName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:dirPath isDirectory:&isDir];
    BOOL isCreated = NO;
    if ( !(isDir == YES && existed == YES) )
    {
        isCreated = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (existed) {
        isCreated = YES;
    }
    return isCreated;
}



// 图片缓存到本地
+ (BOOL) saveImage:(UIImage *)image imageName:(NSString *)imageName inFolder:(NSString *)folderName
{
    if (!image) {
        return NO;
    }
    if (!folderName) {
        folderName = kPath_ImageCache;
    }
    if ([self createDirInCache:folderName]) {
        NSString * directoryPath = [self pathInCacheDirectory:folderName];
        BOOL isDir = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existed = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
        bool isSaved = false;
        if ( isDir == YES && existed == YES )
        {
            isSaved = [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:imageName] options:NSAtomicWrite error:nil];
        }
        return isSaved;
    }else{
        return NO;
    }
}
// 获取缓存图片
+ (NSData*) loadImageDataWithName:( NSString *)imageName inFolder:(NSString *)folderName
{
    if (!folderName) {
        folderName = kPath_ImageCache;
    }
    NSString * directoryPath = [self pathInCacheDirectory:folderName];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL dirExisted = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
    if ( isDir == YES && dirExisted == YES )
    {
        NSString *abslutePath = [NSString stringWithFormat:@"%@/%@", directoryPath, imageName];
        BOOL fileExisted = [fileManager fileExistsAtPath:abslutePath];
        if (!fileExisted) {
            return NULL;
        }
        NSData *imageData = [NSData dataWithContentsOfFile : abslutePath];
        return imageData;
    }
    else
    {
        return NULL;
    }
}
@end
