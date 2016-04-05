//
//  Note.h
//  RunTai
//
//  Created by Joel Chen on 16/3/28.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TweetImage;

typedef NS_ENUM(NSInteger, NoteType)
{
    NoteTypeReviewing = 0,
    NoteTypeReady,
    NoteTypeDismantle,
    NoteTypeHydropower,
    NoteTypeCement,
    NoteTypePaint,
    NoteTypeComplete,
    NoteTypeCustom,
    NoteTypeCheckin
};

@interface Note : NSObject

@property (readwrite, nonatomic, strong) NSString *objectId, *text;

//配图
@property (nonatomic , strong) NSMutableArray *pic_urls;
@property (readwrite, nonatomic, strong) NSMutableArray *selectedAssetURLs;

@property (strong, nonatomic) NSDate *updatedAt;

@property (assign, nonatomic) NoteType noteType;

+(Note *)tweetForSend;

- (void)addASelectedAssetURL:(NSURL *)assetURL;

- (void)deleteATweetImage:(TweetImage *)assetURL;

@end


typedef NS_ENUM(NSInteger, TweetImageUploadState)
{
    TweetImageUploadStateInit = 0,
    TweetImageUploadStateIng,
    TweetImageUploadStateSuccess,
    TweetImageUploadStateFail
};

@interface TweetImage : NSObject
@property (readwrite, nonatomic, strong) UIImage *image, *thumbnailImage;
@property (strong, nonatomic) NSURL *assetURL;
@property (assign, nonatomic) TweetImageUploadState uploadState;
@property (readwrite, nonatomic, strong) NSString *imageStr;
+ (instancetype)tweetImageWithAssetURL:(NSURL *)assetURL;
+ (instancetype)tweetImageWithAssetURL:(NSURL *)assetURL andImage:(UIImage *)image;
@end
