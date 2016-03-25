//
//  UserDescriptionCell.m
//  RunTai
//
//  Created by Joel Chen on 16/3/17.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#define kUserDescriptionCell_Font [UIFont systemFontOfSize:15]
#define kUserDescriptionCell_ContentWidth (kScreen_Width - kPaddingLeftWidth*2)

#import "UserDescriptionCell.h"

@interface UserDescriptionCell ()
@property (strong, nonatomic) UIButton *proDesL;
@end

@implementation UserDescriptionCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kColorTableBG;
        self.descriptionStr = @"客服联系方式: 400-996-2538";
        
        if (!_proDesL) {
            _proDesL = [UIButton buttonWithType:UIButtonTypeCustom];
            NSAttributedString * attstr=[[NSAttributedString alloc] initWithString:self.descriptionStr attributes:@{NSFontAttributeName:kUserDescriptionCell_Font,NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],}];
            _proDesL.titleLabel.attributedText=attstr;
            [_proDesL setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [_proDesL setTitle:self.descriptionStr forState:UIControlStateNormal];
            [_proDesL setTitleColor:[UIColor colorWithHexString:@"0x222222"] forState:UIControlStateNormal];
            [_proDesL addTarget:self action:@selector(linkAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_proDesL];
        }
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat desHeight = [self.descriptionStr getSizeWithFont:kUserDescriptionCell_Font constrainedToSize:CGSizeMake(kUserDescriptionCell_ContentWidth, CGFLOAT_MAX)].height;
    [_proDesL setFrame:CGRectMake(kPaddingLeftWidth, 15, kUserDescriptionCell_ContentWidth, desHeight)];
}

-(void) linkAction:(UIButton *)sender{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",[@"400-996-2538" stringByReplacingOccurrencesOfString:@" " withString:@""]]]];
}

//+ (CGFloat)cellHeightWithObj:(id)obj{
//    CGFloat cellHeight = 0;
//    if ([obj isKindOfClass:[Project class]]) {
//        Project *curProject = (Project *)obj;
//        NSString *descriptionStr = curProject.description_mine.length > 0? curProject.description_mine: @"未填写";
//        CGFloat desHeight = [descriptionStr getSizeWithFont:kProjectDescriptionCell_Font constrainedToSize:CGSizeMake(kProjectDescriptionCell_ContentWidth, CGFLOAT_MAX)].height;
//        cellHeight += desHeight + 2*15;
//    }
//    return cellHeight;
//}

+ (CGFloat)cellHeight{
    CGFloat cellHeight = 44;
    return cellHeight;
}

@end
