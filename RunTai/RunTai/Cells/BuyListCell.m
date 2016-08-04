//
//  BuyListCell.m
//  RunTai
//
//  Created by Joel Chen on 16/4/15.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "BuyListCell.h"

@interface BuyListCell()

@property (strong, nonatomic) UIImageView *lineImg;

@property (strong, nonatomic) UILabel *nameLabel, *introLabel, *valueLabel;

@end

@implementation BuyListCell

+ (instancetype)cellWithTableView:(UITableView *)tablView {
    
    BuyListCell *cell = [tablView dequeueReusableCellWithIdentifier:kCellIdentifier_BuyList];
    if (!cell) {
        cell = [[BuyListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier_BuyList];
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
        self.selectionStyle = UITableViewCellSelectionStyleNone;//UITableViewCellSelectionStyleDefault;
    }
    return self;
    
}
- (void)setupDetailView {
    
    CGFloat cellWidth = kScreen_Width - kPaddingLeftWidth*2;
    CGFloat paddingToBottom = 16;
    
    //lineImg
    UIImage *lineImg = [UIImage imageNamed:@"dots"];
    
    self.lineImg = ({
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.image = lineImg;
        imgView;
    });
    
    [self.contentView addSubview:self.lineImg];
    
    [self.lineImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(5, 30));
        make.left.equalTo(self.contentView.mas_left).offset(paddingToBottom);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    //nameLabel
    
    self.nameLabel = ({
        UILabel *intro = [[UILabel alloc] init];
        intro.textColor = [UIColor colorWithHexString:@"0x222222"];
        intro.font = NotesCommonFont;
        intro.textAlignment=NSTextAlignmentLeft;
        intro.backgroundColor=[UIColor clearColor];
        
        intro;
    });
    
    [self.contentView addSubview:self.nameLabel];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cellWidth-paddingToBottom, 20));
        make.left.equalTo(self.lineImg.mas_right).offset(paddingToBottom);
        make.top.equalTo(self.contentView.mas_top).offset(paddingToBottom);
    }];
    
    //introLabel
    
    self.introLabel = ({
        UILabel *intro = [[UILabel alloc] init];
        intro.textColor = [UIColor colorWithHexString:@"0x999999"];
        intro.font = NotesCommonFont;
        intro.textAlignment=NSTextAlignmentLeft;
        intro.backgroundColor=[UIColor clearColor];
        
        intro;
    });
    
    [self.contentView addSubview:self.introLabel];
    
    [self.introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cellWidth-paddingToBottom, 20));
        make.left.equalTo(self.lineImg.mas_right).offset(paddingToBottom);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(paddingToBottom/4);
    }];
    
    //valueLabel
    
    self.valueLabel = ({
        UILabel *intro = [[UILabel alloc] init];
        intro.textColor = [UIColor colorWithHexString:@"0xb0271d"];
        intro.font = NotesCommonFont;
        intro.textAlignment=NSTextAlignmentRight;
        intro.backgroundColor=[UIColor clearColor];
        
        intro;
    });
    
    [self.contentView addSubview:self.valueLabel];
    
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 20));
        make.right.equalTo(self.contentView.mas_right).offset(-paddingToBottom);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
}

- (void)setTitle:(NSString *)title subtitle:(NSArray *)subtitle value:(NSString *)value{
    self.nameLabel.text = title;
    self.introLabel.text = [NSString stringWithFormat:@"品牌：%@",[subtitle componentsJoinedByString:@" "]];
    self.valueLabel.text = value;
}

+ (CGFloat)cellHeight{
    CGFloat cellHeight = 76;
    return ceilf(cellHeight);
}

@end
