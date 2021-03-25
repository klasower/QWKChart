//
//  QWKOptionsCell.h
//  QWK
//
//  Created by 轻微课 on 2020/8/26.
//  Copyright © 2020 Hind. All rights reserved.
//

#import "TUIBubbleMessageCell.h"
#import "QWKOptionsCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface QWKOptionsCell : TUIBubbleMessageCell

@property (nonatomic, strong) UILabel *questionLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray<NSString *> *options;

@property (nonatomic, strong) QWKOptionsCellData *optionsData;

- (void)fillWithData:(QWKOptionsCellData *)data;

@end

NS_ASSUME_NONNULL_END
