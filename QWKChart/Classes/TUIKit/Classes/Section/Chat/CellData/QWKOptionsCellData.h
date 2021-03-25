//
//  QWKOptionsCellData.h
//  QWK
//
//  Created by 轻微课 on 2020/8/26.
//  Copyright © 2020 Hind. All rights reserved.
//

#import "TUIBubbleMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface QWKOptionsCellData : TUIBubbleMessageCellData

/// 内容
@property (nonatomic, strong) NSString *content;

/// 选项
@property (nonatomic, strong) NSArray *options;

@end

NS_ASSUME_NONNULL_END
