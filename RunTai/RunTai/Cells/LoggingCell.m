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

- (void)setupDetailView {
    
    CGFloat cellWidth = kScreen_Width - kPaddingLeftWidth*2;
    CGFloat cellHeight = [LoggingCell cellHeight];
    CGFloat paddingToBottom = 8;
    
    self.introLabel = ({
        UILabel *intro = [[UILabel alloc] init];
        intro.text=@"前边我虽然说过，要是还没有拿到手，很多事情还不能确定和准备。不过设计这个事情还是可以提前准备的！哈哈！\n刚好有个朋友就是在装修公司做室内设计的，就是麻烦他了！\n特别喜欢它们给我设计的餐厅的部分！卡座！不多说了上图！";
        intro.textColor = [UIColor colorWithHexString:@"0x222222"];
        intro.numberOfLines = 0;
        intro.font = NotesCommonFont;
        intro.textAlignment=NSTextAlignmentLeft;
        intro.backgroundColor=[UIColor clearColor];
        
        intro;
    });
    
    [self.contentView addSubview:self.introLabel];
    
    [self.introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cellWidth, cellHeight-kScreen_Width));
        make.left.equalTo(self.contentView.mas_left).offset(paddingToBottom);
        make.top.equalTo(self.contentView.mas_top).offset(paddingToBottom);
    }];
    
    //photosView
    
    self.photosView = ({
        LoggingPhotosView *photosView = [[LoggingPhotosView alloc] init];
        photosView.picUrls = @[@"",@"",@"",@"",@"",@"",@"",@"",@""];
        self.photosView = photosView;
    });
    
    [self.contentView addSubview:self.photosView];
    
    [self.photosView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo([LoggingPhotosView sizeWithPhotosCount:9]);
        make.left.equalTo(self.contentView.mas_left).offset(paddingToBottom);
        make.top.equalTo(self.introLabel.mas_bottom).offset(paddingToBottom);
    }];
    
//    self.line = ({
//        UIView *line = [[UIView alloc]init];
//        line.backgroundColor = [UIColor lightTextColor];
//        line;
//    });
    
//    [self.contentView addSubview:self.line];
    
//    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 1));
//        make.top.equalTo(self.photosView.mas_bottom).offset(paddingToBottom+1);
//    }];
}

- (void)statusPhotoOnTap:(UITapGestureRecognizer *)recognizer {
    // 1.创建图片浏览器
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    
    // 2.设置图片浏览器显示的所有图片
    NSMutableArray *photos = [NSMutableArray array];
    int count = 9;//(int)self.picUrls.count;
    for (int i = 0; i <count; i++){
        Photo *pic = [[Photo alloc] init];
        pic.original_pic = @"";//self.picUrls[i];
        
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

+ (CGFloat)cellHeight{
    UILabel *intro = [[UILabel alloc] init];
    intro.text=@"前边我虽然说过，要是还没有拿到手，很多事情还不能确定和准备。不过设计这个事情还是可以提前准备的！哈哈！\n刚好有个朋友就是在装修公司做室内设计的，就是麻烦他了！\n特别喜欢它们给我设计的餐厅的部分！卡座！不多说了上图！";
    intro.font = NotesIntroFont;
    CGRect rect=[intro.text boundingRectWithSize:CGSizeMake(kScreen_Width - kPaddingLeftWidth*2, INT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObjectsAndKeys:intro.font,NSFontAttributeName, nil] context:nil];
    return rect.size.height+kScreen_Width+kPaddingLeftWidth*2;
}

@end
