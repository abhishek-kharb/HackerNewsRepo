//
//  DetailedViewController.m
//  HackerNewsAppInitialSecond
//
//  Created by Abhishek Kharb on 09/07/15.
//  Copyright (c) 2015 Abhishek Kharb. All rights reserved.
//

#import "DetailedViewController.h"
#import "Mixpanel.h"


@interface DetailedViewController ()
@property (strong, nonatomic)  UIWebView *myWebView;
@property(strong, nonatomic) UIActivityIndicatorView *mySpinner;
@property (strong, nonatomic) NSURL *myURl;
@property (strong, nonatomic) NSURLRequest *myRequest;
@property (strong, nonatomic) Mixpanel *mixpanel;
@end

@implementation DetailedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mySpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(50, 170, 220, 220)];
    self.mySpinner.color = [UIColor blackColor];
    UIBarButtonItem *myBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(onBackButtonClick)];
    self.navigationItem.leftBarButtonItem = myBackButton;
    self.mixpanel = [Mixpanel sharedInstance];
    [self.mixpanel timeEvent:@"Viewed A Story!"];
}

-(void) viewWillAppear:(BOOL)animated{
    self.myWebView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.myWebView];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.mySpinner];
    [self.mySpinner startAnimating];
    self.myURl = [NSURL URLWithString:self.storyURL];
    self.myRequest = [NSURLRequest requestWithURL:self.myURl];
    self.myWebView.scalesPageToFit = YES;
    [self.myWebView loadRequest:self.myRequest];
    self.myWebView.delegate = self;

}

-(void) viewWillDisappear:(BOOL)animated{
    [self.mixpanel track:@"Viewed A Story!"];
}

-(void) webViewDidStartLoad:(UIWebView *)webView{
    
    
}

-(void) webViewDidFinishLoad:(UIWebView *)webView{
    //NSLog(@"%@\n", self.storyURL);
    [self.mySpinner stopAnimating];
}

-(void) onBackButtonClick{
    
    if(self.myWebView.canGoBack){
        [self.myWebView goBack];
    }
    else{
        [self.myWebView removeFromSuperview];
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:self.myRequest];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
