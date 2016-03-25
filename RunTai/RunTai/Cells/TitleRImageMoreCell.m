//
//  TitleRImageMoreCell.m
//  RunTai
//
//  Created by Joel Chen on 16/3/19.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#define kTitleRImageMoreCell_HeightIcon 50.0

#import "TitleRImageMoreCell.h"
#import "User.h"
@interface TitleRImageMoreCell ()
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *userIconView;
@end
@implementation TitleRImageMoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundColor = kColorTableBG;
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, ([TitleRImageMoreCell cellHeight] -30)/2, 100, 30)];
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.font = [UIFont systemFontOfSize:16];
            _titleLabel.textColor = [UIColor blackColor];
            [self.contentView addSubview:_titleLabel];
        }
        if (!_userIconView) {
            _userIconView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreen_Width- kTitleRImageMoreCell_HeightIcon)- kPaddingLeftWidth- 30, ([TitleRImageMoreCell cellHeight] -kTitleRImageMoreCell_HeightIcon)/2, kTitleRImageMoreCell_HeightIcon, kTitleRImageMoreCell_HeightIcon)];
            [_userIconView doCircleFrame];
            [self.contentView addSubview:_userIconView];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
//    if (!_curUser) {
//        return;
//    }
    self.titleLabel.text = @"头像";
    [self.userIconView sd_setImageWithURL:[_curUser.avatar urlImageWithCodePathResizeToView:_userIconView] placeholderImage:kPlaceholderUserIcon];
}

+ (CGFloat)cellHeight{
    return 70.0;
}

@end
