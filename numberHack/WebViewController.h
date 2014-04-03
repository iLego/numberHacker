//
//  WebViewController.h
//  numberHack
//
//  Created by yury.mehov on 2/19/14.
//  Copyright (c) 2014 yury.mehov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *name;

- (IBAction)closeWebView;
@end
