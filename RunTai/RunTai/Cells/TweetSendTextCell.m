//
//  TweetSendTextCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-9-9.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTweetContentCell_ContentFont [UIFont systemFontOfSize:16]
#define kKeyboardView_Height 216.0


#import "TweetSendTextCell.h"

@interface TweetSendTextCell () <AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource>
@property (strong, nonatomic) AGEmojiKeyboardView *emojiKeyboardView;
@end


@implementation TweetSendTextCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        if (!_tweetContentView) {
            _tweetContentView = [[UIPlaceHolderTextView alloc] initWithFrame:CGRectMake(7, 7, kScreen_Width-7*2, [TweetSendTextCell cellHeight]-10)];
            _tweetContentView.backgroundColor = [UIColor clearColor];
            _tweetContentView.font = kTweetContentCell_ContentFont;
            _tweetContentView.delegate = self;
            _tweetContentView.placeholder = @"更新新笔录...";
            _tweetContentView.returnKeyType = UIReturnKeyDefault;
            [self.contentView addSubview:_tweetContentView];
        }
        if (!_emojiKeyboardView) {
            _emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kKeyboardView_Height) dataSource:self showBigEmotion:YES];
            _emojiKeyboardView.delegate = self;
            [_emojiKeyboardView setDoneButtonTitle:@"完成"];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)cellHeight{
    CGFloat cellHeight;
    if (kDevice_Is_iPhone5){
        cellHeight = 150;
    }else if (kDevice_Is_iPhone6) {
        cellHeight = 150;
    }else if (kDevice_Is_iPhone6Plus){
        cellHeight = 150;
    }else{
        cellHeight = 95;
    }
    return cellHeight;
}
- (BOOL)becomeFirstResponder{
    [super becomeFirstResponder];
    [self.tweetContentView becomeFirstResponder];
    return YES;
}

#pragma mark TextView Delegate
- (void)textViewDidChange:(UITextView *)textView{
    if (self.textValueChangedBlock) {
        self.textValueChangedBlock(textView.text);
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    [kKeyWindow addSubview:self.keyboardToolBar];
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}
#pragma mark KeyboardToolBar
- (UIView *)keyboardToolBar{
    if (!_footerToolBar) {
        _footerToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, 80)];
        
        UIView  *keyboardToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_footerToolBar.frame) - 40, kScreen_Width, 40)];
        [keyboardToolBar addLineUp:YES andDown:NO andColor:[UIColor colorWithHexString:@"0xc8c7cc"]];
        keyboardToolBar.backgroundColor = [UIColor colorWithHexString:@"0xf8f8f8"];
        {//tool button
            UIButton *photoButton = [self toolButtonWithToolBarFrame:keyboardToolBar.frame index:0 imageStr:@"keyboard_photo" andSelecter:@selector(photoButtonClicked:)];
            [keyboardToolBar addSubview:photoButton];
            
            UIButton *emotionButton = [self toolButtonWithToolBarFrame:keyboardToolBar.frame index:1 imageStr:@"keyboard_emotion" andSelecter:@selector(emotionButtonClicked:)];
            [keyboardToolBar addSubview:emotionButton];
        }
        
        [_footerToolBar addSubview:keyboardToolBar];
    }
    return _footerToolBar;
}

- (UIButton *)toolButtonWithToolBarFrame:(CGRect)toolBarFrame index:(NSInteger)index imageStr:(NSString *)imageStr andSelecter:(SEL)sel{
    CGFloat toolBarHeight = CGRectGetHeight(toolBarFrame);
    CGFloat padding = 15;
    CGFloat buttonWidth = (CGRectGetWidth(toolBarFrame) - padding*2)/4;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(padding + buttonWidth * index, 0, buttonWidth, toolBarHeight)];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [button setImage:[UIImage imageNamed:imageStr] forState:UIControlStateNormal];
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)emotionButtonClicked:(id)sender{
    UIButton *emotionButton = sender;
    if (self.tweetContentView.inputView != self.emojiKeyboardView) {
        self.tweetContentView.inputView = self.emojiKeyboardView;
        [emotionButton setImage:[UIImage imageNamed:@"keyboard_keyboard"] forState:UIControlStateNormal];
    }else{
        self.tweetContentView.inputView = nil;
        [emotionButton setImage:[UIImage imageNamed:@"keyboard_emotion"] forState:UIControlStateNormal];
    }
    [self.tweetContentView resignFirstResponder];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tweetContentView becomeFirstResponder];
    });
}

- (void)photoButtonClicked:(id)sender{
    if (self.photoBtnBlock) {
        self.photoBtnBlock();
    }
}

#pragma mark - KeyBoard Notification Handlers
- (void)keyboardChange:(NSNotification*)aNotification{
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardEndFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:animationDuration delay:0.0f options:[UIView animationOptionsForCurve:animationCurve] animations:^{
        CGFloat keyboardY =  keyboardEndFrame.origin.y;
        [self.footerToolBar setY:keyboardY- CGRectGetHeight(self.footerToolBar.frame)];
    } completion:^(BOOL finished) {
    }];
}

#pragma mark AGEmojiKeyboardView

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    NSRange selectedRange = self.tweetContentView.selectedRange;
    self.tweetContentView.text = [self.tweetContentView.text stringByReplacingCharactersInRange:selectedRange withString:emoji];
    self.tweetContentView.selectedRange = NSMakeRange(selectedRange.location +emoji.length, 0);
    [self textViewDidChange:self.tweetContentView];
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    [self.tweetContentView deleteBackward];
}

- (void)emojiKeyBoardViewDidPressSendButton:(AGEmojiKeyboardView *)emojiKeyBoardView{
    [_tweetContentView resignFirstResponder];
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    UIImage *img;
    img = [UIImage imageNamed:@"keyboard_emotion_emoji"];
    return img;
}

- (UIImage *)emojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView imageForNonSelectedCategory:(AGEmojiKeyboardViewCategoryImage)category {
    return [self emojiKeyboardView:emojiKeyboardView imageForSelectedCategory:category];
}

- (UIImage *)backSpaceButtonImageForEmojiKeyboardView:(AGEmojiKeyboardView *)emojiKeyboardView {
    UIImage *img = [UIImage imageNamed:@"keyboard_emotion_delete"];
    return img;
}

@end




