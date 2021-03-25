//
//  QWKChatVC.m
//  QWK
//
//  Created by 轻微课 on 2020/6/5.
//  Copyright © 2020 Hind. All rights reserved.
//

#import "QWKChatVC.h"
#import "TUIChatController.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUITextMessageCellData.h"
#import "TUISystemMessageCellData.h"
#import "QWKOptionsCell.h"
#import "TUIImageMessageCellData.h"
#import "QWKChatManager.h"

@interface QWKChatVC ()<TUIChatControllerDelegate>

@property (nonatomic, strong) TUIConversationCellData *conversationData;

@property (nonatomic, strong) TUIChatController *chat;

/// 会话 ID，用于唯一标识一个会话。
@property (nonatomic, strong) NSString *convId;

///
@property (nonatomic, strong) NSString *name;

@end

@implementation QWKChatVC

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"正在接入人工客服...";
    
    _chat = [[TUIChatController alloc] initWithConversation:nil];
    [self addChildViewController:_chat];
    [self.view addSubview:_chat.view];
    [_chat.view mas_makeConstraints:^(MASConstraintMaker *make) {
        [make edges];
    }];
    
    [self initValue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMsg:) name:sendOptionMessageNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 离开界面时, 更新所有消息为已读
    [self updateAllMsgRead];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)sendMsg:(NSNotification *)noti {
    TUITextMessageCellData *data = [[TUITextMessageCellData alloc] initWithDirection:(MsgDirectionOutgoing)];
    data.content = noti.object;
    [_chat sendMessage:data];
}

#pragma mark - UI

- (void)buildUI {
    self.conversationData = [[TUIConversationCellData alloc] init];
    self.conversationData.convType = TIM_C2C;
    self.conversationData.convId = _convId;
    
    // 发起对话后，原来的客服名称位置，显示为"对方正在输入中…"，持续5s
    self.conversationData.title = @"对方正在输入中...";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.conversationData.title = self.name;
    });
    
    RAC(self, title) = [RACObserve(_conversationData, title) distinctUntilChanged];
    TIMConversation *conv = [[TIMManager sharedInstance] getConversation:_conversationData.convType receiver:_conversationData.convId];
    [_chat.view removeFromSuperview];
    [_chat removeFromParentViewController];
    _chat = [[TUIChatController alloc] initWithConversation:conv];
    _chat.delegate = self;
    [self addChildViewController:_chat];
    [self.view addSubview:_chat.view];
    [_chat.view mas_makeConstraints:^(MASConstraintMaker *make) {
        [make edges];
    }];
    // 预发送消息
    for (NSString *msg in self.preMessages) {
        TUITextMessageCellData *data = [[TUITextMessageCellData alloc] initWithDirection:(MsgDirectionOutgoing)];
        data.content = msg;
        data.ignoreRecordMsg = YES;
        [_chat sendMessage:data];
    }
    
}

#pragma mark - network

- (void)initValue {
    
    [[QWKChatManager sharedInstance] startConversationWithClientIdentity:_clientIdentity block:^(id  _Nonnull data, NSString * _Nonnull conversationId, NSString * _Nonnull name) {
        if (conversationId && conversationId.length) {
            self.convId = conversationId;
            self.name = name;
            
            [self updateAllMsgRead];
            
            [self buildUI];
        }
    }];
}

// 更新消息已读
- (void)updateAllMsgRead {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:clearUnreadCountNotification object:nil];
    
    if (self.convId && self.convId.length) {
        [JDDataReq start:[NSString stringWithFormat:@"%@/app/im/updateAllMsgRead", IM_URL_PREFIX]]
        .param(@"teamId", @(QWK_IM_TEAM_ID))
        .param(@"conversationId", self.convId)
        .success(^(id  _Nonnull data, id  _Nonnull response, BOOL isCache) {
            
        })
        .silent(YES)
        .send();
    }
    
}

#pragma mark - TUIChatControllerDelegate

/// 发送新消息时的回调
- (void)chatController:(TUIChatController *)controller didSendMessage:(TUIMessageCellData *)msgCellData {
    
    //在客户发送消息后，显示为"对方正在输入中…"，持续5s
    self.conversationData.title = @"对方正在输入中...";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.conversationData.title = self.name;
    });
}

/// 接收新消息时的回调，用于甄别自定义消息
- (TUIMessageCellData *)chatController:(TUIChatController *)controller onNewMessage:(TIMMessage *)msg {
    
    if (msg && msg.elemCount > 0) {
        
        TIMElem *elem = [msg getElem:0];
        
        if([elem isKindOfClass:[TIMCustomElem class]]) {
            
            NSDictionary *param = [[(TIMCustomElem *)elem ext] JOSNObject];
            
            NSDictionary *message = param[@"message"];
            NSInteger msgId = [message integerForKey:@"id"];
            // 1：系统，开启会话，结束会话；
            // 2：客户；
            // 3：客服；
            // 4：自动消息；
            NSInteger fromType = [message integerForKey:@"fromType"];
            /**
            消息用途msgUsage：
            1：聊天消息
            2：会话列表消息
            3：当前接待人数消息
            4：用户IM状态消息
            5：会话转接
            6：新客服
             */
            NSInteger msgUsage = [message integerForKey:@"msgUsage"];
            
            NSInteger type = [message integerForKey:@"type"];
            
            BOOL isSelf = (fromType == 2);
            
            if (!isSelf && type == 4) {
                TUIImageMessageCellData *imageData = [[TUIImageMessageCellData alloc] initWithDirection:(isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                imageData.mId = msgId;
                imageData.items = [NSMutableArray array];
                imageData.avatarUrl = [NSURL URLWithString:[[message objectForKey:@"fromUser"] stringForKey:@"faceUrl"]];
                NSString *content = [message stringForKey:@"content"];
                NSDictionary *imageContent = [content JOSNObject];
                if (imageContent) {
                    NSString *coverImgUrl = [imageContent stringForKey:@"coverImgUrl"];
                    NSString *imgUrl = [imageContent stringForKey:@"imgUrl"];
                    imageData.url = imgUrl;
                    TUIImageItem *item1 = [[TUIImageItem alloc] init];
                    item1.uuid = [NSString stringWithFormat:@"%ld_coverImg", msgId];
                    item1.url = coverImgUrl;
                    item1.size = CGSizeMake(500, 500);
                    item1.type = TImage_Type_Thumb;
                    [imageData.items addObject:item1];
                }
                
                return imageData;
            }else {
                if (fromType == 1) {
                    
                    if (msgUsage == 6) {
                        // 新客服
                        TUISystemMessageCellData *data = [[TUISystemMessageCellData alloc] init];
                        data.content = @"";
                        data.mId = msgId;
                        return data;
                    }else {
                        //系统消息
                        TUISystemMessageCellData *data = [[TUISystemMessageCellData alloc] init];
                        data.content = message[@"content"];
                        data.mId = msgId;
                        return data;
                    }
                }else if (fromType == 2) {
                    
                }else {
                    if (type == 3) {
                        // 选项的消息
                        NSString *content = message[@"content"];
                        NSDictionary *param = content.JOSNObject;
                        if (param != nil) {
                            QWKOptionsCellData *data = [[QWKOptionsCellData alloc] initWithDirection:(isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                            data.mId = msgId;
                            data.avatarUrl = [NSURL URLWithString:[[message objectForKey:@"fromUser"] stringForKey:@"faceUrl"]];
                            data.content = [param stringForKey:@"question"];
                            data.options = [param objectForKey:@"options"];
                            return data;
                        }
                    }
                    TUITextMessageCellData *data = [[TUITextMessageCellData alloc] initWithDirection:(isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
                    data.mId = msgId;
                    data.content = message[@"content"];
                    data.avatarUrl = [NSURL URLWithString:[[message objectForKey:@"fromUser"] stringForKey:@"faceUrl"]];
                    return data;
                }
            }
            
            
        }
    }
    
    return nil;
}

- (TUIMessageCell *)chatController:(TUIChatController *)controller onShowMessageData:(TUIMessageCellData *)data
{
    if ([data isKindOfClass:[QWKOptionsCellData class]]) {
        QWKOptionsCell *cell = [[QWKOptionsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell fillWithData:(QWKOptionsCellData *)data];
        return cell;
    }

    return nil;
}

@end
