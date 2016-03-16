//
//  NotesCell.m
//  RunTai
//
//  Created by Joel Chen on 16/3/15.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "NotesCell.h"

@interface NotesCell()

@property (strong, nonatomic) UIImageView *backgroundImg ,*iconImg ,*watchedImg;

@property (strong, nonatomic) UILabel *userLabel ,*titleLabel ,*introLabel ,*statusLabel ,*watchedLabel;

@end

@implementation NotesCell

+ (instancetype)cellWithTableView:(UITableView *)tablView {
    
    NotesCell *cell = [tablView dequeueReusableCellWithIdentifier:kCellIdentifier_Notes];
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

    CGFloat cellWidth = kScreen_Width - kPaddingLeftWidth*2;
    CGFloat cellHeight = [NotesCell cellHeight];
    CGFloat paddingToLeft = 9;
    CGFloat paddingToBottom = 8;
    
    //backgroundImg
    UIImage *backgroundImage = [UIImage imageNamed:@"IMG_NotesDemo"];
    
    self.backgroundImg = ({
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.image = backgroundImage;
        
        imgView.layer.masksToBounds = YES;
        imgView.layer.cornerRadius = 8;
        imgView.layer.borderWidth = 1.0;
        imgView.layer.borderColor = [UIColor clearColor].CGColor;
        imgView;
    });
    
    [self.contentView addSubview:self.backgroundImg];
    
    [self.backgroundImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cellWidth, cellHeight));
        make.left.equalTo(self.contentView.mas_left).offset(paddingToLeft);
    }];
    
    //titleLabel
    
    self.titleLabel = ({
        UILabel *title = [[UILabel alloc] init];
        title.text=@"[南京 金城丽景] 品质北欧简约风";
        title.textColor = [UIColor whiteColor];
        title.font = NotesTitleFont;
        title.textAlignment=NSTextAlignmentLeft;
        title.backgroundColor=[UIColor clearColor];
        
        title;
    });
    
//    CGRect rect=[self.titleLabel.text boundingRectWithSize:CGSizeMake(cellWidth-paddingToLeft, INT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.titleLabel.font,NSFontAttributeName, nil] context:nil];
    [self.contentView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cellWidth-paddingToLeft, 20));
        make.left.equalTo(self.backgroundImg.mas_left).offset(paddingToLeft);
        make.top.equalTo(self.backgroundImg.mas_top).offset(paddingToBottom);
    }];
    
    //introLabel
    
    self.introLabel = ({
        UILabel *title = [[UILabel alloc] init];
        title.text=@"130㎡/三居/北欧简约/报价:16.7万";
        title.textColor = [UIColor whiteColor];
        title.font = NotesIntroFont;
        title.textAlignment=NSTextAlignmentLeft;
        title.backgroundColor=[UIColor clearColor];
        
        title;
    });
    
    [self.contentView addSubview:self.introLabel];
    
    [self.introLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(cellWidth-paddingToLeft, 20));
        make.left.equalTo(self.backgroundImg.mas_left).offset(paddingToLeft);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(paddingToBottom/2);
    }];
    
    //iconImg
    UIImage *iconImage = [UIImage imageNamed:@"avatar_default_big"];
    
    self.iconImg = ({
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.image = iconImage;
        
        imgView.layer.masksToBounds = YES;
        imgView.layer.cornerRadius = 12.5;
        imgView.layer.borderColor = [UIColor whiteColor].CGColor;
        imgView.layer.borderWidth = 2.0f;
        imgView.autoresizingMask = UIViewAutoresizingNone;
        
        imgView;
    });
    
    [self.contentView addSubview:self.iconImg];
    
    [self.iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.left.equalTo(self.backgroundImg.mas_left).offset(paddingToLeft);
        make.bottom.equalTo(self.backgroundImg.mas_bottom).offset(-paddingToLeft);
    }];
    
    //userLabel
    
    self.userLabel = ({
        UILabel *user = [[UILabel alloc] init];
        user.text=@"业主:蒋先生";
        user.textColor = [UIColor whiteColor];
        user.font = NotesIntroFont;
        user.textAlignment=NSTextAlignmentLeft;
        user.backgroundColor=[UIColor clearColor];
        
        user;
    });
    
    [self.contentView addSubview:self.userLabel];
    
    [self.userLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 25));
        make.left.equalTo(self.iconImg.mas_right).offset(paddingToLeft);
        make.bottom.equalTo(self.backgroundImg.mas_bottom).offset(-paddingToLeft);
    }];
    
    //watchedLabel
    
    self.watchedLabel = ({
        UILabel *watched = [[UILabel alloc] init];
        watched.text=@"134";
        watched.textColor = [UIColor whiteColor];
        watched.font = NotesIntroFont;
        watched.textAlignment=NSTextAlignmentRight;
        watched.backgroundColor=[UIColor clearColor];
        
        watched;
    });
    
    [self.contentView addSubview:self.watchedLabel];
    
    [self.watchedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.right.equalTo(self.backgroundImg.mas_right).offset(-paddingToLeft);
        make.bottom.equalTo(self.backgroundImg.mas_bottom).offset(-paddingToLeft);
    }];
    
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
    
    [self.watchedImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(19, 19));
        make.right.equalTo(self.watchedLabel.mas_left).offset(-paddingToLeft);
        make.bottom.equalTo(self.backgroundImg.mas_bottom).offset(-paddingToLeft-3);
    }];

    //statusLabel
    
    self.statusLabel = ({
        UILabel *user = [[UILabel alloc] init];
        user.text=@"正在施工中..";
        user.textColor = [UIColor whiteColor];
        user.font = NotesIntroFont;
        user.textAlignment=NSTextAlignmentLeft;
        user.backgroundColor=[UIColor clearColor];
        
        user;
    });
    
    [self.contentView addSubview:self.statusLabel];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 25));
        make.right.equalTo(self.watchedImg.mas_left).offset(-paddingToLeft);
        make.bottom.equalTo(self.backgroundImg.mas_bottom).offset(-paddingToLeft);
    }];
    
}

+ (CGFloat)cellHeight{
    CGFloat cellHeight = (kScreen_Height - 64 - 49 - kPaddingLeftWidth*3)/3 - 6;
    return ceilf(cellHeight);
}

@end
