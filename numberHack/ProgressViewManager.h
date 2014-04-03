//
//  ProgressViewManager.h
//  CGM
//
//  Created by Vladimir Dmitrovich on 15.11.12.
//  Copyright (c) 2012 osellus. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProgressViewManager : NSObject

@property (nonatomic, retain) UIView *progressView;

+ (ProgressViewManager *)sharedProgressViewManager;

- (void)showProgressView;

- (void)showWithTitle:(NSString *)title;

- (void)dismissProgressView;
@end
