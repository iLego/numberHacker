//
//  ProgressViewManager.m
//  CGM
//
//  Created by Vladimir Dmitrovich on 15.11.12.
//  Copyright (c) 2012 osellus. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "ProgressViewManager.h"

@implementation ProgressViewManager {
}
@synthesize progressView = _progressView;


+ (ProgressViewManager *)sharedProgressViewManager {
    static dispatch_once_t pred;
    static ProgressViewManager *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[ProgressViewManager alloc] init];
    });
    return shared;
}

- (id)init {
    self = [super init];

    if (self) {

    }

    return self;
}


- (void)showWithTitle:(NSString *)title {
    if (self.progressView) {
        return;
    }
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (!window)
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    self.progressView = [[UIView alloc] initWithFrame:window.bounds];
    self.progressView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.85];
    if (title.length) {
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        titleLabel.text = title;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];

        titleLabel.frame = CGRectMake(self.progressView.center.x-80, self.progressView.center.y+20, 160, 40);
        [self.progressView addSubview:titleLabel];
    }

    [window addSubview:self.progressView];

    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.center = (CGPoint) self.progressView.center;
    [self.progressView addSubview:indicatorView];
    [indicatorView startAnimating];
}

- (void)showProgressView {
#if KIOSK
    [self showWithTitle:@"Анализ"];
#else
    [self showWithTitle:nil];
#endif

}

- (void)dismissProgressView {

    if (!self.progressView) {
        return;
    }

    [self.progressView removeFromSuperview];
    self.progressView = nil;
}



@end
