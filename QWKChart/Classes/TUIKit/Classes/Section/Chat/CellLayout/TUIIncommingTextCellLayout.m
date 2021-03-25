//
//  TUIIncommingTextCellLayout.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIIncommingTextCellLayout.h"

@implementation TUIIncommingTextCellLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.bubbleInsets = (UIEdgeInsets){.top = 13, .bottom = 10, .left = 12, .right = 12};
    }
    return self;
}

@end
