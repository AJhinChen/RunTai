//
//  UserInfoCell.m
//  RunTai
//
//  Created by Joel Chen on 16/3/17.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#define kUserInfoCell_ProImgViewWidth kScaleFrom_iPhone5_Desgin(55.0)

#import "UserInfoCell.h"
#import "User.h"

@interface UserInfoCell ()
@property (strong, nonatomic) UIImageView *proImgView, *userSexIconView;
@property (strong, nonatomic) UILabel *proTitleL;
@property (strong, nonatomic) UILabel *proAddressL;
@property (strong, nonatomic) UIView *lineView;
@end

@implementation UserInfoCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kColorTableBG;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (!_proImgView) {
            _proImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kUserInfoCell_ProImgViewWidth, kUserInfoCell_ProImgViewWidth)];
            [_proImgView doCircleFrame];
            
            [self.contentView addSubview:_proImgView];
        }
        if (!_proTitleL) {
            _proTitleL = [[UILabel alloc] init];
            _proTitleL.font = [UIFont systemFontOfSize:17];
            _proTitleL.textColor = [UIColor colorWithHexString:@"0x222222"];
            [self.contentView addSubview:_proTitleL];
        }
        if (!_proAddressL) {
            _proAddressL = [[UILabel alloc] init];
            _proAddressL.font = [UIFont systemFontOfSize:17];
            _proAddressL.textColor = [UIColor colorWithHexString:@"0x222222"];
            [self.contentView addSubview:_proAddressL];
        }
        if (!_lineView) {
            _lineView = [[UIView alloc] init];
            _lineView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot_line"]];
            [self.contentView addSubview:_lineView];
        }
        if (!_loginBtn) {
            _loginBtn = [[UIButton alloc] init];
            [_loginBtn addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_loginBtn setTitle:@"点击登录" forState:UIControlStateNormal];
            [_loginBtn setTitleColor:[UIColor colorWithHexString:@"0x222222"] forState:UIControlStateNormal];
            _loginBtn.backgroundColor = [UIColor clearColor];
        }
        if (!_userSexIconView) {
            _userSexIconView = [[UIImageView alloc] init];
            [self.contentView addSubview:_userSexIconView];
        }
    }
    return self;
}

+ (CGFloat)cellHeight{
    
    return kScaleFrom_iPhone5_Desgin(80.0);
}

- (void)setCurUser:(User *)curUser{
    _curUser = curUser;
    [_proImgView sd_setImageWithURL:[_curUser.avatar urlImageWithCodePathResize:2*kUserInfoCell_ProImgViewWidth] placeholderImage:kPlaceholderUserIcon];
    if (!_curUser) {
        [self.contentView addSubview:_loginBtn];
        [_loginBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left);
            make.centerY.equalTo(_proImgView.mas_centerY);
            make.width.mas_equalTo(kScreen_Width);
            make.height.mas_equalTo([UserInfoCell cellHeight]);
        }];
    }else{
        _proTitleL.text = _curUser.name;
        _proAddressL.text = [NSString stringWithFormat:@"[%@ %@]",_curUser.location,_curUser.address];
        [_userSexIconView setImage:[UIImage imageNamed:[_curUser.gender isEqualToString:@"先生"]?@"n_sex_man_icon":@"n_sex_woman_icon"]];
        if (!_curUser.location && !_curUser.address) {
            _proAddressL.text = @"[暂未填写]";
        }else if(!_curUser.address){
            _proAddressL.text = [NSString stringWithFormat:@"[%@]",_curUser.location];
        }else if(!_curUser.location){
            _proAddressL.text = [NSString stringWithFormat:@"[%@]",_curUser.address];
        }
        [_loginBtn removeFromSuperview];
    }
}

- (void)loginButtonClicked:(id)sender{
    if (self.loginBtnClckedBlock) {
        self.loginBtnClckedBlock(sender);
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat pading = 15;
    CGFloat titleWidth = [_proTitleL.text getWidthWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)];
    CGFloat adrressWidth = [_proAddressL.text getWidthWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(CGFLOAT_MAX, 20)];
    
    [_proImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(pading);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(kUserInfoCell_ProImgViewWidth, kUserInfoCell_ProImgViewWidth));
    }];
    [_proTitleL mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_proImgView.mas_right).offset(pading);
        make.width.mas_lessThanOrEqualTo(titleWidth);
        make.centerY.equalTo(_proImgView.mas_centerY).offset(-kUserInfoCell_ProImgViewWidth/5);
        make.height.mas_equalTo(20);
    }];
    CGFloat userSexIconViewWidth = (14);
    [_userSexIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(userSexIconViewWidth, userSexIconViewWidth));
        
        make.left.equalTo(_proTitleL.mas_right).offset(5);
        make.centerY.equalTo(_proTitleL);
    }];
    [_proAddressL mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_proImgView.mas_right).offset(pading);
        make.width.mas_lessThanOrEqualTo(adrressWidth);
        make.centerY.equalTo(_proImgView.mas_centerY).offset(kUserInfoCell_ProImgViewWidth/5);
        make.height.mas_equalTo(20);
    }];
    [_lineView setFrame:CGRectMake(pading, [UserInfoCell cellHeight] - 1.0, kScreen_Width - 2*pading, 1.0)];
}

@end
