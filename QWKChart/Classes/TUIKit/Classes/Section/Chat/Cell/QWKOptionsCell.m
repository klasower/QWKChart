//
//  QWKOptionsCell.m
//  QWK
//
//  Created by 轻微课 on 2020/8/26.
//  Copyright © 2020 Hind. All rights reserved.
//

#import "QWKOptionsCell.h"

@interface QWKOptionItemCell : UITableViewCell

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIButton *contentButton;

@property (nonatomic, strong) UIImageView *selectedIcon;

@end

@implementation QWKOptionItemCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIView *containerView = InsertColorView(self.contentView, [HexColor(@"#2EB8D0") colorWithAlphaComponent:0.05], ^(MASConstraintMaker * _Nullable make) {
            [make edges];
        });
        _containerView = containerView;
        containerView.borderColor = [HexColor(@"#2EB8D0") colorWithAlphaComponent:0.18];
        containerView.borderWidth = k1px;
        containerView.cornerRadius = 2.0;
        
        self.contentButton = InsertButton(containerView, 14.0, HexColor(@"#2EB8D0"), 10001, nil, nil, @"", ^(MASConstraintMaker * _Nullable make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
        });
        self.contentButton.titleLabel.numberOfLines = 2;
        
        self.selectedIcon = InsertImageView(containerView, Image(@"service_icon_get"), ^(MASConstraintMaker * _Nullable make) {
            make.right.top.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(19.0, 17.0));
        });
        self.selectedIcon.hidden = YES;
        
        if (@available(iOS 11.0, *)) {
            self.contentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeading;
        } else {
            // Fallback on earlier versions
        }
    }
    return self;
}

@end

@interface QWKOptionsCell ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation QWKOptionsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.questionLabel = InsertLabel(self.bubbleView, NSTextAlignmentLeft, 14.0, kColorText1, @"", ^(MASConstraintMaker * _Nullable make) {
            make.top.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
        });
        self.questionLabel.numberOfLines = 0;
        
        self.tableView = InsertGroupTableView(self.bubbleView, self, self, 30.0, ^(MASConstraintMaker * _Nullable make) {
            make.top.equalTo(self.questionLabel.mas_bottom).offset(10.0);
            make.right.bottom.mas_equalTo(-10.0);
            make.left.mas_equalTo(10.0);
        });
        self.tableView.scrollEnabled = NO;
        self.tableView.backgroundColor = self.bubbleView.backgroundColor;
        [self.tableView registerClass:QWKOptionItemCell.class forCellReuseIdentifier:NSStringFromClass(QWKOptionItemCell.class)];
        
        UIView *view = self.superview;
        while (view && ![view isKindOfClass:[UITableView class]]) {
            view = view.superview;
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
        tap.delegate = self;
        [view addGestureRecognizer:tap];
    }
    return self;
}

- (void)click:(UIGestureRecognizer *)ges {
    
}

- (void)fillWithData:(QWKOptionsCellData *)data;
{
    [super fillWithData:data];
    
    self.optionsData = data;
    
    self.questionLabel.text = data.content;
    
    [self.tableView reloadData];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)didClickOptionItem:(UIButton *)button {
    // 点击了选项, 发送消息
    NSString *conversationId = [[NSUserDefaults standardUserDefaults] objectForKey:QWK_LAST_CONVERSATION_ID_KEY];
    NSString *optionKey = [NSString stringWithFormat:@"qwk_%@_%@", conversationId, self.optionsData.content];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:optionKey]) {
        // 当前会话用户没点击过该选项, 则发送消息, 并记录(阿伟说的)
        NSString *msg = [self.optionsData.options[button.tag] stringForKey:@"title"];
        [[NSNotificationCenter defaultCenter] postNotificationName:sendOptionMessageNotification object:msg];
        [[NSUserDefaults standardUserDefaults] setObject:msg forKey:optionKey];
        
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.optionsData.options.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QWKOptionItemCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(QWKOptionItemCell.class)];

    NSString *msg = [self.optionsData.options[indexPath.section] stringForKey:@"title"];
    [cell.contentButton setTitle:msg forState:UIControlStateNormal];
    [cell.contentButton setTag:indexPath.section];
    [cell.contentButton addTarget:self action:@selector(didClickOptionItem:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *conversationId = [[NSUserDefaults standardUserDefaults] objectForKey:QWK_LAST_CONVERSATION_ID_KEY];
    NSString *optionKey = [NSString stringWithFormat:@"qwk_%@_%@", conversationId, self.optionsData.content];
    NSString *selectedMsg = [[NSUserDefaults standardUserDefaults] objectForKey:optionKey];
    if (selectedMsg && selectedMsg.length) {
        cell.containerView.backgroundColor = HexColor(@"#F8F8F8");
        cell.containerView.borderColor = HexColor(@"#F8F8F8");
        [cell.contentButton setTitleColor:HexColor(@"#C4C4C4") forState:UIControlStateNormal];
        cell.selectedIcon.hidden = ![msg isEqualToString:selectedMsg];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

@end
