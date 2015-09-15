//
//  DXQuestionView.m
//  CustomerSystem-ios
//
//  Created by dhc on 15/2/14.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "DXQuestionView.h"

@implementation DXQuestionView

@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleArray = @[ @"收不到验证码信息？",@"资金冻结是怎么回事？", @"学员申请小巴券？", @"我在校已报名了我要怎么选教练？", @"约考的流程是怎么样的？",@"学员取消订单怎么操作？"];
        [self setupSubviews];
    }
    
    return self;
}

- (void)setupSubviews
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, self.frame.size.width - 40, 15)];
    titleLabel.text = NSLocalizedString(@"commonProblems", @"Common Problems");
    titleLabel.text = @"常见问题";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:titleLabel];
    
    int col = 3;
    CGFloat margin = 10;
    CGFloat width = (self.frame.size.width - 4 * margin) / col;
    CGFloat height = 80;
    
    CGFloat y = margin + CGRectGetMaxY(titleLabel.frame);
    CGFloat x = margin;
    
    int z = 0;
    for(int i = 0; i < [_titleArray count]; i++)
    {
        if (i % col == 0) {
            x = margin;
        }
        else{
            x += (margin + width);
        }
        NSLog(@"--%d",(i/col));
        if ((i/col) > z) {
            y += (i / col) * (margin + height);
            z = i/col;
        }

        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(x, y, width, height)];
        button1.titleLabel.numberOfLines = 0;
        [button1 setTitle:[_titleArray objectAtIndex:i] forState:UIControlStateNormal];
        button1.tag = i;
        [button1 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [button1 setBackgroundColor:[UIColor colorWithRed:0 green:199 / 255.0 blue:176 / 255.0 alpha:1]];
        button1.clipsToBounds = YES;
        button1.layer.cornerRadius = 5;
        button1.layer.borderColor = [UIColor colorWithRed:0 green:194 / 255.0 blue:170 / 255.0 alpha:1].CGColor;
        button1.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:button1];
    }
}

- (void)buttonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger tag = button.tag;
    if (tag < [_titleArray count]) {
        NSString *string = [_titleArray objectAtIndex:tag];
        if (_delegate && [_delegate respondsToSelector:@selector(questionViewSeletedTitle:)]) {
            [_delegate questionViewSeletedTitle:string];
        }
    }
}

@end
