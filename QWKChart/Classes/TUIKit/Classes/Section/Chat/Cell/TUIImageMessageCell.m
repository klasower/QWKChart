//
//  TUIImageMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIImageMessageCell.h"
#import "THeader.h"
#import "THelper.h"
#import "MMLayout/UIView+MMLayout.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import <IDMPhotoBrowser/IDMPhotoBrowser.h>

@implementation TUIImageMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _thumb = [[UIImageView alloc] init];
        _thumb.layer.cornerRadius = 5.0;
        [_thumb.layer setMasksToBounds:YES];
        _thumb.contentMode = UIViewContentModeScaleAspectFill;
        _thumb.backgroundColor = [UIColor whiteColor];
        [self.container addSubview:_thumb];
        _thumb.mm_fill();
        _thumb.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _thumb.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
        [_thumb addGestureRecognizer:tap];

        _progress = [[UILabel alloc] init];
        _progress.textColor = [UIColor whiteColor];
        _progress.font = [UIFont systemFontOfSize:15];
        _progress.textAlignment = NSTextAlignmentCenter;
        _progress.layer.cornerRadius = 5.0;
        _progress.hidden = YES;
        _progress.backgroundColor = TImageMessageCell_Progress_Color;
        [_progress.layer setMasksToBounds:YES];
        [self.container addSubview:_progress];
        _progress.mm_fill();
        _progress.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)tapImage:(UIGestureRecognizer *)ges {
    
    if (!self.imageData.path && (!self.imageData.url || self.imageData.url.length == 0)) {
        return;
    }
    
    IDMPhoto *photo;
    
    if (self.imageData.url && self.imageData.url.length) {
        photo = [[IDMPhoto alloc] initWithURL:[NSURL URLWithString:self.imageData.url]];
        photo.placeholderImage = self.thumb.image;
    }else {
        photo = [[IDMPhoto alloc] initWithFilePath:self.imageData.path];
    }
    
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo] animatedFromView:nil];
    browser.displayActionButton = NO;
    browser.dismissOnTouch = YES;
    browser.displayDoneButton = NO;
    browser.displayCounterLabel = YES;
    [[JDViewController navigationController] presentViewController:browser animated:YES completion:nil];
}

- (void)fillWithData:(TUIImageMessageCellData *)data;
{
    //set data
    [super fillWithData:data];
    self.imageData = data;
    _thumb.image = nil;
    if(data.thumbImage == nil) {
        [data downloadImage:TImage_Type_Thumb];
    }

    @weakify(self)
    [[RACObserve(data, thumbImage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(UIImage *thumbImage) {
        @strongify(self)
        if (thumbImage) {
            
            self.thumb.image = thumbImage;
        }
    }];
    
    if (data.direction == MsgDirectionIncoming) {
        [[[RACObserve(data, thumbProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
            @strongify(self)
            int progress = [x intValue];
            self.progress.text = [NSString stringWithFormat:@"%d%%", progress];
            self.progress.hidden = (progress >= 100 || progress == 0);
        }];
    } else {
        [[[RACObserve(data, uploadProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
            @strongify(self)
            int progress = [x intValue];
            if (progress >= 100 || progress == 0) {
                [self.indicator stopAnimating];
            } else {
                [self.indicator startAnimating];
            }
        }];
    }
}


@end
