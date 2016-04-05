//
//  Note.m
//  RunTai
//
//  Created by Joel Chen on 16/3/28.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "Note.h"
static Note *_tweetForSend = nil;

@implementation Note
- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

-(id)copyWithZone:(NSZone*)zone {
    Note *note = [[[self class] allocWithZone:zone] init];
    note.objectId = [_objectId copy];
    note.updatedAt = [_updatedAt copy];
    note.text=[_text copy];
    note.pic_urls=[NSMutableArray arrayWithCapacity:0];
    return note;
}

+(Note *)tweetForSend{
    if (!_tweetForSend) {
        _tweetForSend = [[Note alloc] init];
    }
    return _tweetForSend;
}

#pragma mark ALAsset
- (void)setSelectedAssetURLs:(NSMutableArray *)selectedAssetURLs{
    NSMutableArray *needToAdd = [NSMutableArray new];
    NSMutableArray *needToDelete = [NSMutableArray new];
    [self.selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![selectedAssetURLs containsObject:obj]) {
            [needToDelete addObject:obj];
        }
    }];
    [needToDelete enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self deleteASelectedAssetURL:obj];
    }];
    [selectedAssetURLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (![self.selectedAssetURLs containsObject:obj]) {
            [needToAdd addObject:obj];
        }
    }];
    [needToAdd enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addASelectedAssetURL:obj];
    }];
}

- (void)addASelectedAssetURL:(NSURL *)assetURL{
    if (!_selectedAssetURLs) {
        _selectedAssetURLs = [NSMutableArray new];
    }
    if (!_pic_urls) {
        _pic_urls = [NSMutableArray new];
    }
    
    [_selectedAssetURLs addObject:assetURL];
    
    NSMutableArray *pic_urls = [self mutableArrayValueForKey:@"pic_urls"];//为了kvo
    TweetImage *tweetImg = [TweetImage tweetImageWithAssetURL:assetURL];
    [pic_urls addObject:tweetImg];
}

- (void)deleteASelectedAssetURL:(NSURL *)assetURL{
    [self.selectedAssetURLs removeObject:assetURL];
    NSMutableArray *pic_urls = [self mutableArrayValueForKey:@"pic_urls"];//为了kvo
    [pic_urls enumerateObjectsUsingBlock:^(TweetImage *obj, NSUInteger idx, BOOL *stop) {
        if (obj.assetURL == assetURL) {
            [pic_urls removeObject:obj];
            *stop = YES;
        }
    }];
}

- (void)deleteATweetImage:(TweetImage *)tweetImage{
    NSMutableArray *pic_urls = [self mutableArrayValueForKey:@"pic_urls"];//为了kvo
    [pic_urls removeObject:tweetImage];
    if (tweetImage.assetURL) {
        [self.selectedAssetURLs removeObject:tweetImage.assetURL];
    }
}

@end

@implementation TweetImage
+ (instancetype)tweetImageWithAssetURL:(NSURL *)assetURL{
    TweetImage *tweetImg = [[TweetImage alloc] init];
    tweetImg.uploadState = TweetImageUploadStateInit;
    tweetImg.assetURL = assetURL;
    
    void (^selectAsset)(ALAsset *) = ^(ALAsset *asset){
        if (asset) {
            UIImage *highQualityImage = [UIImage fullScreenImageALAsset:asset];
            UIImage *thumbnailImage = [UIImage imageWithCGImage:[asset thumbnail]];
            dispatch_async(dispatch_get_main_queue(), ^{
                tweetImg.image = highQualityImage;
                tweetImg.thumbnailImage = thumbnailImage;
            });
        }
    };
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    @weakify(assetsLibrary);
    [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        if (asset) {
            selectAsset(asset);
        }else{
            @strongify(assetsLibrary);
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupPhotoStream usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stopG) {
                    if([result.defaultRepresentation.url isEqual:assetURL]) {
                        selectAsset(result);
                        *stop = YES;
                        *stopG = YES;
                    }
                }];
            } failureBlock:^(NSError *error) {
                [NSObject showHudTipStr:@"读取图片失败"];
            }];
        }
    }failureBlock:^(NSError *error) {
        [NSObject showHudTipStr:@"读取图片失败"];
    }];
    return tweetImg;
    
}

+ (instancetype)tweetImageWithAssetURL:(NSURL *)assetURL andImage:(UIImage *)image{
    TweetImage *tweetImg = [[TweetImage alloc] init];
    tweetImg.uploadState = TweetImageUploadStateInit;
    tweetImg.assetURL = assetURL;
    tweetImg.image = image;
    tweetImg.thumbnailImage = [image scaledToSize:CGSizeMake(kScaleFrom_iPhone5_Desgin(70), kScaleFrom_iPhone5_Desgin(70)) highQuality:YES];
    return tweetImg;
}

@end
