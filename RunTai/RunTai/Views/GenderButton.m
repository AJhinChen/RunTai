//
//  GenderButton.m
//  RunTai
//
//  Created by Joel Chen on 16/3/21.
//  Copyright © 2016年 AJhin. All rights reserved.
//

#import "GenderButton.h"

@interface GenderButton ()
@property (strong, nonatomic) UILabel *valueLabel;
@property (strong, nonatomic) UIView *lineView;
@end

@implementation GenderButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:17];
        self.enabled = YES;
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(-10, 5, 0.5, CGRectGetHeight(frame) - 2*5)];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"0xD8D8D8"];
        [self addSubview:_lineView];
        
        if (!_valueLabel) {
            _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 25)];
            _valueLabel.backgroundColor = [UIColor clearColor];
            _valueLabel.font = [UIFont systemFontOfSize:15];
            _valueLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _valueLabel.textAlignment = NSTextAlignmentCenter;
            _valueLabel.adjustsFontSizeToFitWidth = YES;
            _valueLabel.minimumScaleFactor = 0.6;
            [self addSubview:_valueLabel];
        }
    }
    return self;
}

- (void)setvalueStr:(NSString *)value{
    _valueLabel.text = value;
}

@end
