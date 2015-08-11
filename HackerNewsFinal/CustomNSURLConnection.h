//
//  CustomNSURLConnection.h
//  HackerNewsFinal
//
//  Created by Abhishek Kharb on 21/07/15.
//  Copyright (c) 2015 Abhishek Kharb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CustomNSURLConnection : NSURLConnection
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSNumber *fetchedItemId;
@property (strong, nonatomic) NSManagedObjectID *managedObjectId;
@end
