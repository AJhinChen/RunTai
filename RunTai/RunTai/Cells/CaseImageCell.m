//
//  CaseImageCell.m
//  RunTai
//
//  Created by Joel Chen on 16/3/30.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "CaseImageCell.h"
#import "UIImageView+WebCache.h"
#import "Photo.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

@interface CaseImageCell()

@property (strong, nonatomic) UIImageView *photosView;

@property (strong, nonatomic) UILabel *titleLabel ,*introLabel;

@property (strong, nonatomic) NSArray *images;

@end

@implementation CaseImageCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    CaseImageCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_CaseImageCell];
    if (!cell) {
        cell = [[CaseImageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier_CaseImageCell];
    }
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //cell设置
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.images = [NSArray array];
        
        self.titleLabel = ({
            UILabel *intro = [[UILabel alloc] init];
            intro.textColor = [UIColor colorWithHexString:@"0x222222"];
            intro.font = NotesCommonFont;
            intro.textAlignment=NSTextAlignmentLeft;
            intro.backgroundColor=[UIColor clearColor];
            
            intro;
        });
        
        [self.contentView addSubview:self.titleLabel];
        
        self.introLabel = ({
            UILabel *intro = [[UILabel alloc] init];
            intro.textColor = [UIColor colorWithHexString:@"0x999999"];
            intro.font = NotesCommonFont;
            intro.textAlignment=NSTextAlignmentLeft;
            intro.backgroundColor=[UIColor clearColor];
            
            intro;
        });
        
        [self.contentView addSubview:self.introLabel];
        
        //photosView
        
        self.photosView = ({
            UIImageView *photosView = [[UIImageView alloc] init];
            photosView.contentMode = UIViewContentModeScaleToFill;
            photosView.layer.borderWidth = 2;
            photosView.layer.borderColor = [[UIColor whiteColor] CGColor];
            photosView.userInteractionEnabled = YES;
            //添加手势
            UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(casePhotoOnTap:)];
            [photosView addGestureRecognizer:gestureRecognizer];
            photosView;
        });
        
        [self.contentView addSubview:self.photosView];
    }
    return self;
    
}

- (void)setCurCase:(Case *)curCase{
    self.titleLabel.text = [NSString stringWithFormat:@"%@",curCase.title];
    self.introLabel.text = [NSString stringWithFormat:@"%@/%@",curCase.type,curCase.style];
//    if ([curCase.id isEqualToString:@"全部案例"]) {
//        self.introLabel.text = [NSString stringWithFormat:@"%@/%@",curCase.type,curCase.style];
//    }
    self.images = curCase.images;
    [self.photosView sd_setImageWithURL:[curCase.thumbnail urlImageWithCodePathResizeToView:self.photosView] placeholderImage:kPlaceholderBackground];
    
    CGFloat paddingToBottom = 5;
    CGFloat cellWidth = kScreen_Width/2 - paddingToBottom*2;
    
    [self.photosView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cellWidth, cellWidth*0.6));
        make.left.equalTo(self.contentView.mas_left).offset(paddingToBottom);
        make.top.equalTo(self.contentView.mas_top);
    }];
    
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cellWidth - paddingToBottom*2, 20));
        make.left.equalTo(self.contentView.mas_left).offset(paddingToBottom);
        make.top.equalTo(self.photosView.mas_bottom).offset(paddingToBottom);
    }];
    
    [self.introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cellWidth - paddingToBottom*2, 20));
        make.left.equalTo(self.contentView.mas_left).offset(paddingToBottom);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(3);
    }];
}

- (void)casePhotoOnTap:(UITapGestureRecognizer *)recognizer {
    // 1.创建图片浏览器
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    
    // 2.设置图片浏览器显示的所有图片
    NSMutableArray *photos = [NSMutableArray array];
    int count = (int)[self.images count];
    for (int i = 0; i <count; i++){
        Photo *pic = [[Photo alloc] init];
        pic.original_pic = self.images[i];
        
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:pic.original_pic];
        //设置来源于哪一个UIImageView
//        photo.srcImageView = self.subviews[i];
        
        [photos addObject:photo];
    }
    
    browser.photos = photos;
    
    // 3.设置默认显示的图片索引
    browser.currentPhotoIndex = recognizer.view.tag;
    
    // 4.显示浏览器
    [browser show];
}

+ (CGFloat)cellHeight{
    CGFloat cellWidth = kScreen_Width/2 - 10;
    return cellWidth*0.6+53;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (!self.highlighted) {
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        scaleAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        scaleAnimation.springBounciness = 25.f;
        [self pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    }
}

@end
