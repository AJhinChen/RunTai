//
//  NotesCell.m
//  RunTai
//
//  Created by Joel Chen on 16/3/15.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "NotesCell.h"

@interface NotesCell()

@property (strong, nonatomic) UIImageView *backgroundImg ,*iconImg ,*watchedImg, *userSexIconView;

@property (strong, nonatomic) UILabel *userLabel ,*titleLabel ,*introLabel ,*statusLabel ,*watchedLabel;

@end

@implementation NotesCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    NotesCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Notes];
    if (!cell) {
        cell = [[NotesCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier_Notes];
    }
    
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //添加Feed具体内容
        [self setupDetailView];
        //cell设置
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
    
}

- (void)setupDetailView {
    
    self.backgroundImg = ({
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.layer.masksToBounds = YES;
        imgView.layer.cornerRadius = 8;
        imgView.layer.borderWidth = 1.0;
        imgView.layer.borderColor = [UIColor clearColor].CGColor;
        imgView;
    });
    
    [self.contentView addSubview:self.backgroundImg];
    
    //titleLabel
    
    self.titleLabel = ({
        UILabel *title = [[UILabel alloc] init];
        title.textColor = [UIColor whiteColor];
        title.font = NotesTitleFont;
        title.textAlignment=NSTextAlignmentLeft;
        title.backgroundColor=[UIColor clearColor];
        
        title;
    });
    
//    CGRect rect=[self.titleLabel.text boundingRectWithSize:CGSizeMake(cellWidth-paddingToLeft, INT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.titleLabel.font,NSFontAttributeName, nil] context:nil];
    [self.contentView addSubview:self.titleLabel];
    
    //introLabel
    
    self.introLabel = ({
        UILabel *intro = [[UILabel alloc] init];
        intro.textColor = [UIColor whiteColor];
        intro.font = NotesIntroFont;
        intro.textAlignment=NSTextAlignmentLeft;
        intro.backgroundColor=[UIColor clearColor];
        
        intro;
    });
    
    [self.contentView addSubview:self.introLabel];
    
    self.iconImg = ({
        UIImageView *imgView = [[UIImageView alloc] init];
        
        imgView.layer.masksToBounds = YES;
        imgView.layer.cornerRadius = 12.5;
        imgView.layer.borderColor = [UIColor whiteColor].CGColor;
        imgView.layer.borderWidth = 1.0f;
        imgView.autoresizingMask = UIViewAutoresizingNone;
        
        imgView;
    });
    
    [self.contentView addSubview:self.iconImg];
    
    //userLabel
    
    self.userLabel = ({
        UILabel *user = [[UILabel alloc] init];
        user.textColor = [UIColor whiteColor];
        user.font = NotesCommonFont;
        user.textAlignment=NSTextAlignmentLeft;
        user.backgroundColor=[UIColor clearColor];
        
        user;
    });
    
    [self.contentView addSubview:self.userLabel];
    
    //watchedLabel
    
    self.watchedLabel = ({
        UILabel *watched = [[UILabel alloc] init];
        watched.textColor = [UIColor whiteColor];
        watched.font = NotesCommonFont;
        watched.textAlignment=NSTextAlignmentCenter;
        watched.backgroundColor=[UIColor clearColor];
        
        watched;
    });
    
    [self.contentView addSubview:self.watchedLabel];
    
    //watchedImg
    UIImage *watchedImage = [UIImage imageNamed:@"compose_photo_video_highlighted"];
    
    self.watchedImg = ({
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.image = watchedImage;
        
        imgView.layer.masksToBounds = YES;
        imgView.layer.cornerRadius = 9.5;
        imgView.autoresizingMask = UIViewAutoresizingNone;
        
        imgView;
    });

    [self.contentView addSubview:self.watchedImg];

    //statusLabel
    
    self.statusLabel = ({
        UILabel *user = [[UILabel alloc] init];
        user.textColor = [UIColor whiteColor];
        user.font = NotesCommonFont;
        user.textAlignment=NSTextAlignmentLeft;
        user.backgroundColor=[UIColor clearColor];
        
        user;
    });
    
    [self.contentView addSubview:self.statusLabel];
    
    if (!_userSexIconView) {
        _userSexIconView = [[UIImageView alloc] init];
        [self.contentView addSubview:_userSexIconView];
    }
    
}

- (void)setCurPro:(Project *)curPro{
    [_backgroundImg sd_setImageWithURL:[curPro.background urlImageWithCodePathResizeToView:_backgroundImg] placeholderImage:kPlaceholderBackground];
    self.titleLabel.text = curPro.full_name;
    self.introLabel.text = curPro.name;
    [_iconImg sd_setImageWithURL:[curPro.owner.avatar urlImageWithCodePathResizeToView:_iconImg] placeholderImage:kPlaceholderUserIcon];
    self.userLabel.text = curPro.owner.name;
    self.watchedLabel.text = [NSString stringWithFormat:@"%d",curPro.watch_count.intValue];
    self.statusLabel.text = [Project getProcessingName:curPro.processing.intValue];
    [_userSexIconView setImage:[UIImage imageNamed:[curPro.owner.gender isEqualToString:@"先生"]?@"n_sex_man_icon":@"n_sex_woman_icon"]];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
//    CGFloat userWidth = [_userLabel.text getWidthWithFont:NotesCommonFont constrainedToSize:CGSizeMake(CGFLOAT_MAX, 25)];
    
    CGFloat cellWidth = kScreen_Width - kPaddingLeftWidth*2;
    CGFloat cellHeight = [NotesCell cellHeight];
    CGFloat paddingToLeft = 9;
    CGFloat paddingToBottom = 8;
    
    [self.backgroundImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cellWidth, cellHeight));
        make.left.equalTo(self.contentView.mas_left).offset(paddingToLeft);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cellWidth-paddingToLeft, 20));
        make.left.equalTo(self.backgroundImg.mas_left).offset(paddingToLeft);
        make.top.equalTo(self.backgroundImg.mas_top).offset(paddingToBottom);
    }];
    
    [self.introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cellWidth-paddingToLeft, 20));
        make.left.equalTo(self.backgroundImg.mas_left).offset(paddingToLeft);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(paddingToBottom/2);
    }];
    
    [self.iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.left.equalTo(self.backgroundImg.mas_left).offset(paddingToLeft);
        make.bottom.equalTo(self.backgroundImg.mas_bottom).offset(-paddingToLeft);
    }];
    
    CGFloat userSexIconViewWidth = (14);
    [_userSexIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(userSexIconViewWidth, userSexIconViewWidth));
        make.left.equalTo(_iconImg.mas_right).offset(paddingToLeft);
        make.centerY.equalTo(_iconImg);
    }];
    
    [self.userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 25));
        make.left.equalTo(self.userSexIconView.mas_right).offset(paddingToLeft);
        make.bottom.equalTo(self.backgroundImg.mas_bottom).offset(-paddingToLeft);
    }];
    
    [self.watchedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(45, 25));
        make.right.equalTo(self.backgroundImg.mas_right).offset(-paddingToLeft);
        make.bottom.equalTo(self.backgroundImg.mas_bottom).offset(-paddingToLeft);
    }];
    
    [self.watchedImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(19, 19));
        make.right.equalTo(self.watchedLabel.mas_left).offset(-3);
        make.bottom.equalTo(self.backgroundImg.mas_bottom).offset(-paddingToLeft-3);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 25));
        make.right.equalTo(self.watchedImg.mas_left).offset(-paddingToLeft);
        make.bottom.equalTo(self.backgroundImg.mas_bottom).offset(-paddingToLeft);
    }];
}

+ (CGFloat)cellHeight{
    CGFloat cellHeight = (kScreen_Height - 64 - 49 - kPaddingLeftWidth*3)/3 - 6;
    return ceilf(cellHeight);
}

@end
