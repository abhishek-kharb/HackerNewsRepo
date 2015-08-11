//
//  StoryItem.h
//  HackerNewsFinal
//
//  Created by Abhishek Kharb on 22/07/15.
//  Copyright (c) 2015 Abhishek Kharb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface StoryItem : NSManagedObject

@property (nonatomic, retain) NSString * storyAuthor;
@property (nonatomic, retain) NSNumber * storyCommentCount;
@property (nonatomic, retain) NSNumber * storyId;
@property (nonatomic, retain) NSNumber * storyScore;
@property (nonatomic, retain) NSNumber * storyTimeStamp;
@property (nonatomic, retain) NSString * storyTitle;
@property (nonatomic, retain) NSString * storyUrl;

@end
