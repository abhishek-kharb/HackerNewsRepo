//
//  DetailedViewController.h
//  HackerNewsAppInitialSecond
//
//  Created by Abhishek Kharb on 09/07/15.
//  Copyright (c) 2015 Abhishek Kharb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailedViewController : UIViewController <UIWebViewDelegate>
@property (strong, nonatomic) NSString *storyURL;
@end
