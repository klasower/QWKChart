//
//  QWKChatManager.h
//  QWK
//
//  Created by 轻微课 on 2020/12/25.
//  Copyright © 2020 Hind. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QWKChatConfig : NSObject

+ (QWKChatConfig *)defaultConfig;

/// 轻微课的teamId
@property (nonatomic, assign) NSInteger teamId;
/// TIM p12证书id
@property (nonatomic, assign) NSInteger busiId;
/// TIM app id
@property (nonatomic, assign) NSInteger appId;
/// 默认头像
@property (nonatomic, strong) UIImage *defaultAvatarImage;
/// 客服系统api域名
@property (nonatomic, strong) NSString *imUrlPrefix;
///
@property (nonatomic, strong) NSString *clientIdentity;

@end

@interface QWKChatManager : NSObject

@property QWKChatConfig *config;

+ (instancetype)sharedInstance;

+ (void)registerDeviceToken:(NSData *)deviceToken;

/// APP 进前台的时候需要主动调用 doForeground，这个时候后台知道 APP 的状态，之后的消息不会下发推送通知
- (void)doForeground;

/// APP 进后台的时候需要主动调用 doBackground ，这个时候后台知道 APP 的状态，之后的消息会下发推送通知。
- (void)doBackground;

/// 登录客服系统
- (void)login;
/// 退出登录
- (void)logout;

/// 开始会话
- (void)startConversationWithClientIdentity:(NSString *)clientIdentity block:(void (^)(id data, NSString *conversationId, NSString *name))block;

/// 手动结束会话
- (void)endConversationWithBlock:(void (^)(BOOL success))block;

@end

NS_ASSUME_NONNULL_END
