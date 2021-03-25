//
//  QWKChatVC.h
//  QWK
//
//  Created by 轻微课 on 2020/6/5.
//  Copyright © 2020 Hind. All rights reserved.
//

#import "JDViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface QWKChatVC : JDViewController

///预发送消息
@property (nonatomic, strong) NSArray<NSString *> *preMessages;

///客服端信息
@property (nonatomic, copy) NSString *clientIdentity;

@end

NS_ASSUME_NONNULL_END
