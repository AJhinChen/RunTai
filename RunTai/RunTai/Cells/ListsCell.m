//
//  ListsCell.m
//  RunTai
//
//  Created by Joel Chen on 16/3/16.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "ListsCell.h"

@interface ListsCell ()
@property (strong, nonatomic) UIImageView *imgView;
@end

@implementation ListsCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundColor = kColorTableBG;
        if (!_imgView) {
            _imgView = [UIImageView new];
            [self.contentView addSubview:_imgView];
            [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(20, 20));
                make.left.equalTo(self.contentView).offset(15);
                make.centerY.equalTo(self.contentView);
            }];
        }
        if (!_titleLabel) {
            _titleLabel = [UILabel new];
            _titleLabel.font = [UIFont systemFontOfSize:15];
            _titleLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            [self.contentView addSubview:_titleLabel];
            [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(_imgView.mas_right).offset(15);
                make.right.equalTo(self.contentView).offset(-kPaddingLeftWidth);
                make.centerY.height.equalTo(self.contentView);
            }];
        }
    }
    return self;
}

- (void)setImageStr:(NSString *)imgStr andTitle:(NSString *)title{
    self.imgView.image = [UIImage imageNamed:imgStr];
    self.titleLabel.text = title;
}

+ (CGFloat)cellHeight{
    return 44.0;
}

@end
