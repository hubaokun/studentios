//
//  DSSearchBar.m
//  wedding
//
//  Created by Jianyong Duan on 14/11/21.
//  Copyright (c) 2014年 daoshun. All rights reserved.
//

#import "DSSearchBar.h"

@interface DSSearchBar () <UITextFieldDelegate>

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *labelPlaceholder;
@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIButton *cancelButton;


@property(nonatomic) BOOL editing;

@end

@implementation DSSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.editing = NO;

        UIImage *bgImage = [[UIImage imageNamed:@"backgroud_search"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)];
        _bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(frame)/2 - 15, CGRectGetWidth(frame), 30)];
        _bgImageView.image = bgImage;
        [self addSubview:_bgImageView];
        
        UIImageView *imageViewIcon = [[UIImageView alloc] initWithFrame:CGRectMake(11, CGRectGetHeight(frame)/2 - 8, 18, 17)];
        imageViewIcon.image= [UIImage imageNamed:@"icon_search_white"];
        [self addSubview:imageViewIcon];
        
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(35, 0, CGRectGetWidth(frame)-45, CGRectGetHeight(frame))];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textField.textColor = [UIColor whiteColor];
        _textField.font = [UIFont systemFontOfSize:13];
        _textField.delegate = self;
        [_textField setReturnKeyType:UIReturnKeySearch];
        [_textField addTarget:self action:@selector(textFieldValueChanged:)forControlEvents:UIControlEventEditingChanged];
        [self addSubview:_textField];
        
        _labelPlaceholder = [[UILabel alloc] initWithFrame:_textField.frame];
        _labelPlaceholder.font = _textField.font;
        _labelPlaceholder.textColor = [UIColor whiteColor];
        [self insertSubview:_labelPlaceholder belowSubview:_textField];
        
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(0, 0, 50, CGRectGetHeight(frame));
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.hidden = YES;
        [self addSubview:_cancelButton];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    if (_editing) {
        _bgImageView.frame = CGRectMake(0, CGRectGetHeight(self.frame)/2 - 15, CGRectGetWidth(self.frame) - 50, 30);
        _textField.frame = CGRectMake(35, 0, CGRectGetWidth(self.frame)- 45 - 50, CGRectGetHeight(self.frame));
        _cancelButton.frame = CGRectMake(CGRectGetWidth(self.frame) - 50, 0, 50, CGRectGetHeight(self.frame));
        _labelPlaceholder.frame = _textField.frame;
        _cancelButton.hidden = NO;
        
    } else {
        _bgImageView.frame = CGRectMake(0, CGRectGetHeight(self.frame)/2 - 15, CGRectGetWidth(self.frame), 30);
        _textField.frame = CGRectMake(35, 0, CGRectGetWidth(self.frame)-45, CGRectGetHeight(self.frame));
        _labelPlaceholder.frame = _textField.frame;
        _cancelButton.hidden = YES;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (NSString *)text
{
    return self.textField.text;
}

- (void)setText:(NSString *)value
{
    self.textField.text = value;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.labelPlaceholder.text = _placeholder;
}

#pragma mark - UITextFieldDelegate
- (void)cancelButtonClick:(id)sender {
    self.textField.text = @"";
    [self.textField resignFirstResponder];
    
    if (_delegate && [_delegate respondsToSelector:@selector(searchBarCancelButtonClicked:)]) {
        [_delegate searchBarCancelButtonClicked:self];
    } else {
        [self layoutSubviews];
    }
}

//- (void)searchBar:(DSSearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope NS_AVAILABLE_IOS(3_0);

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (_delegate && [_delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        self.editing = [_delegate searchBarShouldBeginEditing:self];
    } else {
        self.editing = YES;
    }
    return self.editing;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (_delegate && [_delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
        [_delegate searchBarTextDidBeginEditing:self];
    }
    
    self.labelPlaceholder.hidden = YES;
    [self layoutSubviews];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    BOOL endEditing = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(searchBarShouldEndEditing:)]) {
        endEditing = [_delegate searchBarShouldEndEditing:self];
    } else {
        endEditing = YES;
    }
    if (endEditing) {
        self.editing = NO;
        self.labelPlaceholder.hidden = NO;
    }
    
    return endEditing;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (_delegate && [_delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)]) {
        [_delegate searchBarTextDidEndEditing:self];
    }
    self.labelPlaceholder.hidden = NO;
    [self layoutSubviews];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (_delegate && [_delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)]) {
        return [_delegate searchBar:self shouldChangeTextInRange:range replacementText:string];
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
//    textField.text
    NSLog(@"textFieldShouldClear");
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([CommonUtil isEmpty:textField.text]) {
        return NO;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
        [_delegate searchBarSearchButtonClicked:self];
    }
    [self.textField resignFirstResponder];
    return YES;
}

- (void)textFieldValueChanged:(UITextField *)textField {
    if (_delegate && [_delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [_delegate searchBar:self textDidChange:textField.text];
    }
}

@end
