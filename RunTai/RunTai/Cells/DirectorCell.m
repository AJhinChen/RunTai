//
//  DirectorCell.m
//  RunTai
//
//  Created by Joel Chen on 16/3/16.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "DirectorCell.h"

@interface DirectorCell()

@property (strong, nonatomic) UIImageView *iconImg ,*iconBackgroundImg;

@property (strong, nonatomic) UILabel *nameLabel, *introLabel;

@end

@implementation DirectorCell

+ (instancetype)cellWithTableView:(UITableView *)tablView {
    
    DirectorCell *cell = [tablView dequeueReusableCellWithIdentifier:kCellIdentifier_Director];
    if (!cell) {
        cell = [[DirectorCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier_Director];
    }
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //添加Feed具体内容
        [self setupDetailView];
        //cell设置
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    return self;
    
}
- (void)setupDetailView {
    
    CGFloat cellWidth = kScreen_Width - kPaddingLeftWidth*2;
    CGFloat paddingToLeft = 9;
    CGFloat paddingToBottom = 8;
    
    //iconBackgroundImg
    UIImage *iconBackgroundImage = [UIImage imageNamed:@"common_slider_controler"];
    
    self.iconBackgroundImg = ({
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.image = iconBackgroundImage;
        
        imgView.layer.masksToBounds = YES;
        imgView.layer.cornerRadius = 30;
        imgView.layer.borderWidth = 1.0;
        imgView.layer.borderColor = [UIColor clearColor].CGColor;
        imgView;
    });
    
    [self.contentView addSubview:self.iconBackgroundImg];
    
    [self.iconBackgroundImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.left.equalTo(self.contentView.mas_left).offset(paddingToBottom);
        make.top.equalTo(self.contentView.mas_top).offset(paddingToBottom);
    }];
    
    self.iconImg = ({
        UIImageView *imgView = [[UIImageView alloc] init];
        
        imgView.layer.masksToBounds = YES;
        imgView.layer.cornerRadius = 25;
        imgView.layer.borderWidth = 1.0;
        imgView.layer.borderColor = [UIColor clearColor].CGColor;
        imgView;
    });
    
    [self.contentView addSubview:self.iconImg];
    
    [self.iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.left.equalTo(self.iconBackgroundImg.mas_left).offset(5);
        make.top.equalTo(self.iconBackgroundImg.mas_top).offset(5);
    }];
    
    //nameLabel
    
    self.nameLabel = ({
        UILabel *intro = [[UILabel alloc] init];
        intro.textColor = [UIColor blackColor];
        intro.font = NotesCommonFont;
        intro.textAlignment=NSTextAlignmentLeft;
        intro.backgroundColor=[UIColor clearColor];
        
        intro;
    });
    
    [self.contentView addSubview:self.nameLabel];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cellWidth-paddingToLeft, 20));
        make.left.equalTo(self.iconImg.mas_right).offset(paddingToLeft);
        make.top.equalTo(self.iconImg.mas_top).offset(3);
    }];
    
    //introLabel
    
    self.introLabel = ({
        UILabel *intro = [[UILabel alloc] init];
        intro.textColor = [UIColor blackColor];
        intro.font = NotesCommonFont;
        intro.textAlignment=NSTextAlignmentLeft;
        intro.backgroundColor=[UIColor clearColor];
        
        intro;
    });
    
    [self.contentView addSubview:self.introLabel];
    
    [self.introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cellWidth-paddingToLeft, 20));
        make.left.equalTo(self.iconImg.mas_right).offset(paddingToLeft);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(paddingToBottom/2);
    }];
    
}

- (void)setTitle:(NSString *)title subtitle:(NSString *)subtitle value:(NSString *)value{
    self.nameLabel.text = title;
    self.introLabel.text = subtitle;
    [self.iconImg sd_setImageWithURL:[value urlImageWithCodePathResizeToView:_iconImg] placeholderImage:kPlaceholderUserIcon];
}

+ (CGFloat)cellHeight{
    CGFloat cellHeight = 76;
    return ceilf(cellHeight);
}
@end
