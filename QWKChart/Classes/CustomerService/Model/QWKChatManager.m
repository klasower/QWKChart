//
//  QWKChatManager.m
//  QWK
//
//  Created by 轻微课 on 2020/12/25.
//  Copyright © 2020 Hind. All rights reserved.
//

#import "QWKChatManager.h"
#import <TIMManager.h>
#import "TUIKit.h"

static NSString *const qwk_chat_device_token_key = @"qwk_chat_device_token_key";

@interface QWKChatManager ()

@property (nonatomic, assign) BOOL autoStartConversation;

@property (nonatomic, copy) NSString *clientIdentity;

@property (nonatomic, copy) void (^finishStartConversationBlock)(id data, NSString *conversationId, NSString *name);

@end

@implementation QWKChatConfig

- (id)init
{
    self = [super init];
    if(self){
        _imUrlPrefix = @"https://kf-api.qingwk.com";
    }
    return self;
}

+ (id)defaultConfig
{
    static dispatch_once_t onceToken;
    static QWKChatConfig *config;
    dispatch_once(&onceToken, ^{
        config = [[QWKChatConfig alloc] init];
    });
    return config;
}

@end

@implementation QWKChatManager

+ (instancetype)sharedInstance {
    static QWKChatManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[QWKChatManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _config = [QWKChatConfig defaultConfig];
        
        [self setup];
    }
    return self;
}

+ (void)registerDeviceToken:(NSData *)deviceToken {
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:qwk_chat_device_token_key];
}

- (void)setup {
    
    [[TUIKit sharedInstance] setupWithAppId:_config.appId];
    
    TUIKitConfig *config = [TUIKitConfig defaultConfig];
    config.avatarType = TAvatarTypeRounded;
    config.defaultAvatarImage = _config.defaultAvatarImage;
}

- (void)login {
    [self getOrCreateUser];
}

- (void)logout {
    [self logoutTIM];
}

- (void)getOrCreateUser {
    
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSString *ueid = @"";
    for(NSHTTPCookie *cookie in [cookieJar cookies]) {
        if ([cookie.name isEqualToString:@"ueid"]) {
            ueid = cookie.value;
        }
    }
    
    // 查询或创建用户信息
    [JDDataReq start:[NSString stringWithFormat:@"%@/app/im/getOrCreateUser", _config.imUrlPrefix]]
    .param(@"teamId", @(self.config.teamId))
    .param(@"clientId", ueid)
    .success(^(id  _Nonnull data, id  _Nonnull response, BOOL isCache) {
        NSLog(@"------im-----\n%@", data);
        [self getOrCreateAccount];
    })
    .error(^(NSString * _Nonnull msg, DataReqErrorType errType, id  _Nonnull data) {
        
    })
    .send();
}

- (void)getOrCreateAccount {
    // 查询或创建im信息
    [JDDataReq start:[NSString stringWithFormat:@"%@/app/im/getOrCreateAccount", _config.imUrlPrefix]]
    .param(@"teamId", @(self.config.teamId))
    .success(^(id  _Nonnull data, id  _Nonnull response, BOOL isCache) {
        
        [self loginTIMWithAccout:[data stringForKey:@"account"] userSig:[data stringForKey:@"userSig"]];
    })
    .error(^(NSString * _Nonnull msg, DataReqErrorType errType, id  _Nonnull data) {
        
    })
    .send();
}

/// 手动结束会话
//- (void)endConversationWithBlock:(void (^)(BOOL success))block {
//    [JDDataReq start:[NSString stringWithFormat:@"%@/im/kefu/endConversation", _config.imUrlPrefix]]
//    .param(@"teamId", @(self.config.teamId))
//    .success(^(id  _Nonnull data, id  _Nonnull response, BOOL isCache) {
//
//    })
//    .error(^(NSString * _Nonnull msg, DataReqErrorType errType, id  _Nonnull data) {
//
//    })
//    .send();
//}

- (void)loginTIMWithAccout:(NSString *)account userSig:(NSString *)userSig {
    
    TIMLoginParam *param = [[TIMLoginParam alloc] init];
    param.identifier = account;
    param.userSig = userSig;
    MJWeakSelf
    // 登录腾讯云sdk
    [[TIMManager sharedInstance] login:param succ:^{
        NSLog(@"TIM login succ!!!");
        
        if (weakSelf.autoStartConversation) {
            weakSelf.autoStartConversation = NO;
            [weakSelf startConversationWithClientIdentity:weakSelf.clientIdentity block:weakSelf.finishStartConversationBlock];
        }
        
        NSData *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:qwk_chat_device_token_key];
        
        if (deviceToken) {
            TIMTokenParam *param = [[TIMTokenParam alloc] init];
            /* 用户自己到苹果注册开发者证书，在开发者帐号中下载并生成证书(p12 文件)，将生成的 p12 文件传到腾讯证书管理控制台，控制台会自动生成一个证书 ID，将证书 ID 传入一下 busiId 参数中。*/
            param.busiId = (int)weakSelf.config.busiId;
            [param setToken:deviceToken];
            [[TIMManager sharedInstance] setToken:param succ:^{
                NSLog(@"-----> 上传 token 成功 ");
                TIMAPNSConfig *config = [[TIMAPNSConfig alloc] init];
                config.openPush = 1;
                [[TIMManager sharedInstance] setAPNS:config succ:^{
                    NSLog(@"-----> 设置 APNS 成功");
                } fail:^(int code, NSString *msg) {
                    NSLog(@"-----> 设置 APNS 失败");
                }];
            } fail:^(int code, NSString *msg) {
                NSLog(@"-----> 上传 token 失败 ");
            }];
        }
    } fail:^(int code, NSString *msg) {
        NSLog(@"%@----%@", @(code), msg);
    }];
}

- (void)logoutTIM {
    
    [[TIMManager sharedInstance] logout:^{
        
    } fail:^(int code, NSString *msg) {
        
    }];
}

- (void)startConversationWithClientIdentity:(NSString *)clientIdentity block:(void (^)(id data, NSString *conversationId, NSString *name))block {
    
    _clientIdentity = clientIdentity;
    _finishStartConversationBlock = block;
    
    if (TIMManager.sharedInstance.getLoginStatus==TIM_STATUS_LOGOUT) {
        self.autoStartConversation = YES;
        [self login];
    }else {
        
        // 开始会话
        [JDDataReq start:[NSString stringWithFormat:@"%@/app/im/startConversation", _config.imUrlPrefix]]
        .param(@"teamId", @(self.config.teamId))
        .param(@"sourcePlatform", @"iOS_SDK")
        .param(@"sourceType", @1)
        .param(@"clientIdentity", clientIdentity?:@"")
        .success(^(id  _Nonnull data, id  _Nonnull response, BOOL isCache) {
            
            NSString *conversationId = [data[@"conversationId"] stringValue];
            if (conversationId) {
                [[NSUserDefaults standardUserDefaults] setObject:conversationId forKey:QWK_LAST_CONVERSATION_ID_KEY];
            }
            
            if (block) {
                block(data, conversationId, data[@"name"]);
            }
            
        })
        .error(^(NSString * _Nonnull msg, DataReqErrorType errType, id  _Nonnull data) {
            if (block) {
                block(nil, nil, nil);
            }
        })
        .send();
    }
    
}

- (void)doForeground {
    [[TIMManager sharedInstance] doForeground:^() {
        NSLog(@"doForegroud Succ");
    } fail:^(int code, NSString * err) {
        NSLog(@"Fail: %d->%@", code, err);
    }];
}

- (void)doBackground {
    TIMBackgroundParam *param = [[TIMBackgroundParam alloc] init];
    param.c2cUnread = 0;
    [[TIMManager sharedInstance] doBackground:param succ:^() {
        NSLog(@"doBackgroud Succ");
    } fail:^(int code, NSString * err) {
        NSLog(@"Fail: %d->%@", code, err);
    }];
}

@end
