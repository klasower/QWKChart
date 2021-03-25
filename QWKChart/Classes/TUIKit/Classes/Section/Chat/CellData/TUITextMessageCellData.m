//
//  TUITextMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUITextMessageCellData.h"
#import "TUIFaceView.h"
#import "TUIFaceCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "THelper.h"
#import "YYText.h"

#ifndef CGFLOAT_CEIL
#ifdef CGFLOAT_IS_DOUBLE
#define CGFLOAT_CEIL(value) ceil(value)
#else
#define CGFLOAT_CEIL(value) ceilf(value)
#endif
#endif

@interface TUITextMessageCellData()
@property CGSize textSize;
@property CGPoint textOrigin;

@end

@implementation TUITextMessageCellData

- (instancetype)initWithDirection:(TMsgDirection)direction
{
    self = [super initWithDirection:direction];
    if (self) {
        if (direction == MsgDirectionIncoming) {
            _textColor = kColorText1;
            _textFont = Font(14.0);
            [self.class setIncommingBubbleTop:0];
//            [self.class setIncommingBubble:[UIImage imageWithColor:HexColor(@"#FFFFFF")]];
//            [self.class setIncommingHighlightedBubble:[UIImage imageWithColor:HexColor(@"#FFFFFF")]];
            self.cellLayout = [TUIMessageCellLayout incommingTextMessageLayout];
            
        } else {
            _textColor = UIColor.whiteColor;
            _textFont = Font(14.0);
            [self.class setOutgoingBubbleTop:0];
//            [self.class setOutgoingBubble:[UIImage imageWithColor:HexColor(@"#F1F2F5")]];
//            [self.class setOutgoingHighlightedBubble:[UIImage imageWithColor:HexColor(@"#F1F2F5")]];
            self.cellLayout = [TUIMessageCellLayout outgoingTextMessageLayout];
        }
    }
    return self;
}

- (CGSize)contentSize
{
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:CGSizeMake(TTextMessageCell_Text_Width_Max, MAXFLOAT) text:self.attributedString];
    CGSize size = layout.textBoundingSize;
    
//    CGRect rect = [self.attributedString boundingRectWithSize:CGSizeMake(TTextMessageCell_Text_Width_Max, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
//    CGSize size = CGSizeMake(CGFLOAT_CEIL(rect.size.width), CGFLOAT_CEIL(rect.size.height));
    self.textSize = size;
    self.textOrigin = CGPointMake(self.cellLayout.bubbleInsets.left, self.cellLayout.bubbleInsets.top+self.bubbleTop);

    size.height += self.cellLayout.bubbleInsets.top+self.cellLayout.bubbleInsets.bottom;
    size.width += self.cellLayout.bubbleInsets.left+self.cellLayout.bubbleInsets.right;

    if (self.direction == MsgDirectionIncoming) {
        size.height = MAX(size.height, 40.0);
    } else {
        size.height = MAX(size.height, 40.0);
    }
    
    if (self.QQ && self.QQ.length) {
        size.height += 32.0;
    }

    return size;
}

- (NSString *)QQ {
    
    if (self.direction == MsgDirectionIncoming) {

        NSString *regex_qq = @"[Qq]{2}[:：]?(\\d{5,})"; //匹配qq
        NSError *error = nil;
        NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_qq options:NSRegularExpressionCaseInsensitive error:&error];
        
        if (!error) {
            NSTextCheckingResult *match = [re firstMatchInString:_content?:@"" options:0 range:NSMakeRange(0, [_content?:@"" length])];
            if (match) {
                NSString *result = [_content?:@"" substringWithRange:[match rangeAtIndex:1]];
                return result;
            }
        }
    }
    return nil;
}

- (NSAttributedString *)attributedString
{
    if (!_attributedString) {
        _attributedString = [self formatMessageString:_content];
    }
    return _attributedString;
}

- (NSAttributedString *)formatMessageString:(NSString *)text
{
    // 先判断text是否存在
    if (text == nil || text.length == 0) {
        NSLog(@"TTextMessageCell formatMessageString failed , current text is nil");
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    // 创建一个可变的属性字符串
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    
    // 匹配链接, 添加下划线
//    NSString *regex_url = @"(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]";
    NSString *regex_url = @"(((https|http):)?\\/\\/)?([a-z0-9-]+\\.)+(com|info|net|org|edu|gov|ac|ad|ae|af|ag|ai|al|am|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cu|cv|cw|cx|cy|cz|de|dj|dk|dm|do|dz|ec|ee|eg|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|html|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sk|sl|sm|sn|so|sr|ss|st|su|sv|sx|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|za|zm|zw)(:\\d+)?(\\/[a-z0-9&@#;_\\-.%?=]*)*";
    
    NSError *error_url = nil;
    NSRegularExpression *re_url = [NSRegularExpression regularExpressionWithPattern:regex_url options:NSRegularExpressionCaseInsensitive error:&error_url];
    if (!re_url) {
        return attributeString;
    }
    
    NSArray *resultArray_url = [re_url matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    //根据匹配范围来用图片进行相应的替换
    for(NSTextCheckingResult *match in resultArray_url) {
        //获取数组元素中得到range
        NSRange range = [match range];
        
        // 添加下划线
        [attributeString yy_setTextHighlightRange:range color:UIColor.clearColor backgroundColor:UIColor.clearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            NSString *targetUrl = [attributeString.string substringWithRange:range];
            [QwkUIRouter openWebView:targetUrl title:@"" fixedTitle:NO];
        }];
        
        [attributeString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
    }
    

    if (self.direction == MsgDirectionIncoming) {
        // 匹配5位数字, 添加复制按钮
        NSString *regex_num = @"\\d{5,}"; //匹配超过5位数字
        
        NSError *error1 = nil;
        NSRegularExpression *re1 = [NSRegularExpression regularExpressionWithPattern:regex_num options:NSRegularExpressionCaseInsensitive error:&error1];
        if (!re1) {
            return attributeString;
        }
        
        NSArray *resultArray1 = [re1 matchesInString:text options:0 range:NSMakeRange(0, text.length)];
        
        //用来存放字典，字典中存储的是图片和图片对应的位置
        NSMutableArray *copyArray = [NSMutableArray arrayWithCapacity:resultArray1.count];
        //根据匹配范围来用图片进行相应的替换
        for(NSTextCheckingResult *match in resultArray1) {
            //获取数组元素中得到range
            NSRange range = [match range];
            //获取原字符串中对应的值
            NSString *subStr = [text substringWithRange:range];
            
            UIButton *button = InsertButton(nil, 12.0, kColorText1, subStr.intValue, nil, nil, @" 复制数字 ", nil);
            [button setFrame:CGRectMake(0, 0, 84.0, 21.0)];
            [button setImage:Image(@"复制") forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageWithColor:HexColor(@"#F4F4F4")] forState:UIControlStateNormal];
            button.layer.cornerRadius = 2;
            [button setBlock:^{
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = subStr;
                [CTPromptView showText:@"复制成功"];
            }];
            
            NSMutableAttributedString *attachText = [NSMutableAttributedString yy_attachmentStringWithContent:button contentMode:UIViewContentModeScaleAspectFit attachmentSize:button.frame.size alignToFont:self.textFont alignment:YYTextVerticalAlignmentCenter];
            
            NSMutableDictionary *attachDic = [NSMutableDictionary dictionaryWithCapacity:2];
            [attachDic setObject:attachText forKey:@"attachText"];
            [attachDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
            //把字典存入数组中
            [copyArray addObject:attachDic];
        }
        
        //4、从后往前替换，否则会引起位置问题
        for (int i = (int)copyArray.count -1; i >= 0; i--) {
            NSRange range;
            [copyArray[i][@"range"] getValue:&range];
            // 添加下划线
            [attributeString yy_setTextHighlightRange:range color:UIColor.clearColor backgroundColor:UIColor.clearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = [attributeString.string substringWithRange:range];
                [CTPromptView showText:@"复制成功"];
            }];
            
            [attributeString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
            [attributeString insertAttributedString:copyArray[i][@"attachText"] atIndex:range.location+range.length];
        }
    }
    
    if([TUIKit sharedInstance].config.faceGroups.count == 0){
        [attributeString addAttribute:NSFontAttributeName value:self.textFont range:NSMakeRange(0, attributeString.length)];
        return attributeString;
    }
    
    text = attributeString.string;

    //2、通过正则表达式来匹配字符串
    NSString *regex_emoji = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]"; //匹配表情

    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex_emoji options:NSRegularExpressionCaseInsensitive error:&error];
    if (!re) {
        NSLog(@"%@", [error localizedDescription]);
        return attributeString;
    }

    NSArray *resultArray = [re matchesInString:text options:0 range:NSMakeRange(0, text.length)];

    TFaceGroup *group = [TUIKit sharedInstance].config.faceGroups[0];

    //3、获取所有的表情以及位置
    //用来存放字典，字典中存储的是图片和图片对应的位置
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    //根据匹配范围来用图片进行相应的替换
    for(NSTextCheckingResult *match in resultArray) {
        //获取数组元素中得到range
        NSRange range = [match range];
        //获取原字符串中对应的值
        NSString *subStr = [text substringWithRange:range];

        for (TFaceCellData *face in group.faces) {
            if ([face.name isEqualToString:subStr]) {
                UIImage *faceImage = [[TUIImageCache sharedInstance] getFaceFromCache:face.path];
                NSMutableAttributedString *imageStr = [NSMutableAttributedString yy_attachmentStringWithEmojiImage:faceImage fontSize:CTFontGetSize((__bridge CTFontRef)self.textFont)];
                //把图片和图片对应的位置存入字典中
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                //把字典存入数组中
                [imageArray addObject:imageDic];
                break;
            }
        }
    }

    //4、从后往前替换，否则会引起位置问题
    for (int i = (int)imageArray.count -1; i >= 0; i--) {
        NSRange range;
        [imageArray[i][@"range"] getValue:&range];
        //进行替换
        [attributeString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
    }

    [attributeString addAttribute:NSFontAttributeName value:self.textFont range:NSMakeRange(0, attributeString.length)];
    [attributeString setYy_lineSpacing:4.2];

    return attributeString;
}

static UIColor *sOutgoingTextColor;

+ (UIColor *)outgoingTextColor
{
    if (!sOutgoingTextColor) {
        sOutgoingTextColor = [UIColor blackColor];
    }
    return sOutgoingTextColor;
}

+ (void)setOutgoingTextColor:(UIColor *)outgoingTextColor
{
    sOutgoingTextColor = outgoingTextColor;
}

static UIFont *sOutgoingTextFont;

+ (UIFont *)outgoingTextFont
{
    if (!sOutgoingTextFont) {
        sOutgoingTextFont = [UIFont systemFontOfSize:16];
    }
    return sOutgoingTextFont;
}

+ (void)setOutgoingTextFont:(UIFont *)outgoingTextFont
{
    sOutgoingTextFont = outgoingTextFont;
}

static UIColor *sIncommingTextColor;

+ (UIColor *)incommingTextColor
{
    if (!sIncommingTextColor) {
        sIncommingTextColor = [UIColor blackColor];
    }
    return sIncommingTextColor;
}

+ (void)setIncommingTextColor:(UIColor *)incommingTextColor
{
    sIncommingTextColor = incommingTextColor;
}

static UIFont *sIncommingTextFont;

+ (UIFont *)incommingTextFont
{
    if (!sIncommingTextFont) {
        sIncommingTextFont = [UIFont systemFontOfSize:16];
    }
    return sIncommingTextFont;
}

+ (void)setIncommingTextFont:(UIFont *)incommingTextFont
{
    sIncommingTextFont = incommingTextFont;
}
@end
