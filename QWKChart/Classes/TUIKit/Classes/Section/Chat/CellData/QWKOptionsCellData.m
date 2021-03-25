//
//  QWKOptionsCellData.m
//  QWK
//
//  Created by 轻微课 on 2020/8/26.
//  Copyright © 2020 Hind. All rights reserved.
//

#import "QWKOptionsCellData.h"

@implementation QWKOptionsCellData

- (CGSize)contentSize {

    CGFloat itemH = 36.0f;
    CGFloat lineSpace = 10.0f;
    
    CGRect rect = [self.content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH*0.6, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14] } context:nil];
    
    CGSize size = CGSizeMake(SCREEN_WIDTH*0.6, ceilf(rect.size.height) + self.options.count * (itemH + lineSpace));

    // 加上气泡边距
    size.height += 20;
    size.width += 20;

    return size;
}

@end
