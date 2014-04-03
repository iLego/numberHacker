//
//  WebViewController.m
//  numberHack
//
//  Created by yury.mehov on 2/19/14.
//  Copyright (c) 2014 yury.mehov. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    if(self.url.length > 0){
        [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://images.google.com/searchbyimage?hl=en&biw=1060&bih=766&gbv=2&site=search&image_url=%@&sa=X&ei=H6RaTtb5JcTeiALlmPi2CQ&ved=0CDsQ9Q8",self.url]]]];
    }
    else
    {
        NSString *req = [NSString stringWithFormat:@"https://www.google.by/search?q=%@+inurl:vk.com",self.name];
        req = [req stringByReplacingOccurrencesOfString:@" " withString:@"+"];
        [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:req]]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}


- (IBAction)closeWebView {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
