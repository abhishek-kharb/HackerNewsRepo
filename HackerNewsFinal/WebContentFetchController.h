//
//  WebContentFetchController.h
//  HackerNewsFinal
//
//  Created by Abhishek Kharb on 21/07/15.
//  Copyright (c) 2015 Abhishek Kharb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol WebContentFetchDelegate <NSObject>

-(void) didFinishDataFetchWithData: (NSArray *) data;

@end

@interface WebContentFetchController : NSObject <NSURLConnectionDataDelegate>

@property (strong, nonatomic) id<WebContentFetchDelegate> delegate;
@property (nonatomic) BOOL isThisRefreshDelegateCall;


-(void) initiateItemIdFetch;
-(void) refreshData;
-(void) fetchMoreItemsStaringFromIndex: (long) index;

@end
