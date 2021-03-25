//
//  TUITextMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUITextMessageCell.h"
#import "TUIFaceView.h"
#import "TUIFaceCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "THelper.h"
#import "MMLayout/UIView+MMLayout.h"

@implementation TUITextMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _content = [[YYLabel alloc] init];
        _content.numberOfLines = 0;
        [self.bubbleView addSubview:_content];
        
        UIButton *button = InsertButton(self.container, 12.0, HexColor(@"#2EB8D0"), 10001, self, @selector(addQQ:), @" 加QQ", nil);
        button.frame = CGRectMake(0, 0, 67.5, 24);
        [button setImage:Image(@"service_qq_icon") forState:UIControlStateNormal];
        button.layer.cornerRadius = 3.2f;
        button.layer.borderColor = [HexColor(@"#2EB8D0") colorWithAlphaComponent:0.2].CGColor;
        button.layer.borderWidth = 1.0f;
        button.layer.masksToBounds = YES;
        button.hidden = YES;
        _addQQButton = button;
        
        
    }
    return self;
}

- (void)addQQ:(UIButton *)button {
    
    NSLog(@"%@", self.textData.QQ);
    
    if (self.textData.QQ && self.textData.QQ.length) {
        // 唤起QQ
        NSURL *url = [NSURL URLWithString:@"mqq://"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"mqq://im/chat?chat_type=crm&uin=%@&version=1&src_type=web", self.textData.QQ]];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_10_0
            [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionsSourceApplicationKey:@YES} completionHandler:^(BOOL success) {}];
#else
            [[UIApplication sharedApplication] openURL:url];
#endif
        }else {
            [CTPromptView showText:@"不能打开QQ,请确保QQ可用"];
        }
    }
    
}

- (void)fillWithData:(TUITextMessageCellData *)data
{
    //set data
    [super fillWithData:data];
    self.textData = data;
    self.content.attributedText = data.attributedString;
    self.content.textColor = data.textColor;
    self.addQQButton.hidden = !(data.QQ && data.QQ.length);
//  font set in attributedString
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.content.frame = (CGRect){.origin = self.textData.textOrigin, .size = self.textData.textSize};
    self.bubbleView.mm_h = self.container.mm_h - ((self.textData.QQ && self.textData.QQ.length) ? 30 : 0);
    self.addQQButton.mm_top(self.bubbleView.mm_y+self.bubbleView.mm_h+6.5);
}

@end
