//
//  TitleValueMoreCell.m
//  RunTai
//
//  Created by Joel Chen on 16/3/19.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "TitleValueMoreCell.h"

@interface TitleValueMoreCell ()
@property (strong, nonatomic) UILabel *titleLabel, *valueLabel;
@end

@implementation TitleValueMoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.backgroundColor = kColorTableBG;
        
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, 7, 100, 30)];
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.font = [UIFont systemFontOfSize:16];
            _titleLabel.textColor = [UIColor blackColor];
            [self.contentView addSubview:_titleLabel];
        }
        if (!_valueLabel) {
            _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 7, kScreen_Width-(110+kPaddingLeftWidth) - 30, 30)];
            _valueLabel.backgroundColor = [UIColor clearColor];
            _valueLabel.font = [UIFont systemFontOfSize:15];
            _valueLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _valueLabel.textAlignment = NSTextAlignmentRight;
            _valueLabel.adjustsFontSizeToFitWidth = YES;
            _valueLabel.minimumScaleFactor = 0.6;
            [self.contentView addSubview:_valueLabel];
        }
        if ([reuseIdentifier isEqualToString:kCellIdentifier_TitleValue]) {
            self.accessoryType = UITableViewCellAccessoryNone;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)setTitleStr:(NSString *)title valueStr:(NSString *)value{
    _titleLabel.text = title;
    _valueLabel.text = value;
}

+ (CGFloat)cellHeight{
    return 44.0;
}

@end
