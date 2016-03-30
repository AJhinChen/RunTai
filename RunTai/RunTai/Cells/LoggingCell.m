//
//  LoggingCell.m
//  RunTai
//
//  Created by Joel Chen on 16/3/16.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "LoggingCell.h"
#import "UIImageView+WebCache.h"
#import "Photo.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "LoggingPhotosView.h"

#define StatusPhotosMaxCount 9
#define StatusPhotosMaxCols(photosCount) ((photosCount == 4) ? 2 :3)
#define StatusPhotosW (kScreen_Width - 2*StatusPhotosMargin - 8*2)/3
#define StatusPhotosH StatusPhotosW
#define StatusPhotosMargin 5

@interface LoggingCell()

@property (strong, nonatomic) UILabel *introLabel;

@property (strong, nonatomic) UIView *line, *footer;

@property (strong, nonatomic) LoggingPhotosView *photosView;

@end

@implementation LoggingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupDetailView];
    }
    return self;
}

- (void)setNote:(Note *)note{
    self.introLabel.text = note.text;
    self.photosView.picUrls = note.pic_urls;
    
    CGFloat cellWidth = kScreen_Width - kPaddingLeftWidth*2;
    CGFloat cellHeight = [LoggingCell cellHeightWithObj:note];
    CGFloat paddingToBottom = 8;
    int count = (int)[note.pic_urls count];
    CGSize photoSize = [LoggingPhotosView sizeWithPhotosCount:count];
    CGFloat introHeight = cellHeight - photoSize.height - paddingToBottom*3 + 0.5;
    
    
    [self.introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cellWidth, introHeight));
        make.left.equalTo(self.contentView.mas_left).offset(paddingToBottom);
        make.top.equalTo(self.contentView.mas_top).offset(paddingToBottom);
    }];
    
    [self.photosView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(photoSize);
        make.left.equalTo(self.contentView.mas_left).offset(paddingToBottom);
        make.top.equalTo(self.introLabel.mas_bottom).offset(paddingToBottom);
    }];
    
//    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 0.5));
//        make.bottom.equalTo(self.contentView.mas_bottom).offset(0);
//    }];
}

- (void)setupDetailView {
    
    self.introLabel = ({
        UILabel *intro = [[UILabel alloc] init];
        intro.textColor = [UIColor colorWithHexString:@"0x222222"];
        intro.numberOfLines = 0;
        intro.font = NotesCommonFont;
        intro.textAlignment=NSTextAlignmentLeft;
        intro.backgroundColor=[UIColor clearColor];
        
        intro;
    });
    
    [self.contentView addSubview:self.introLabel];
    
    //photosView
    
    self.photosView = ({
        LoggingPhotosView *photosView = [[LoggingPhotosView alloc] init];
        self.photosView = photosView;
    });
    
    [self.contentView addSubview:self.photosView];
    
//    self.line = ({
//        UIView *line = [[UIView alloc]init];
//        line.backgroundColor = [UIColor lightGrayColor];
//        line;
//    });
//    
//    [self.contentView addSubview:self.line];
}

- (void)statusPhotoOnTap:(UITapGestureRecognizer *)recognizer {
    // 1.创建图片浏览器
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    
    // 2.设置图片浏览器显示的所有图片
    NSMutableArray *photos = [NSMutableArray array];
    int count = (int)[self.note.pic_urls count];
    for (int i = 0; i <count; i++){
        Photo *pic = [[Photo alloc] init];
        pic.original_pic = self.note.pic_urls[i];
        
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:pic.original_pic];
        //设置来源于哪一个UIImageView
        photo.srcImageView = self.subviews[i];
        
        [photos addObject:photo];
    }
    
    browser.photos = photos;
    
    // 3.设置默认显示的图片索引
    browser.currentPhotoIndex = recognizer.view.tag;
    
    // 4.显示浏览器
    [browser show];
}

+ (CGFloat)cellHeightWithObj:(Note *)obj{
    CGRect rect=[obj.text boundingRectWithSize:CGSizeMake(kScreen_Width - 8*2, INT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObjectsAndKeys:NotesCommonFont,NSFontAttributeName, nil] context:nil];
    CGSize photoSize = [LoggingPhotosView sizeWithPhotosCount:(int)obj.pic_urls.count];
    return rect.size.height+photoSize.height+8*3;
}

@end
