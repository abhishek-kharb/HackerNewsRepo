//
//  TableViewCell.h
//  HackerNewsAppInitialSecond
//
//  Created by Abhishek Kharb on 08/07/15.
//  Copyright (c) 2015 Abhishek Kharb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *storyTitle;
@property (strong, nonatomic) IBOutlet UILabel *storyAuthor;
@property (strong, nonatomic) IBOutlet UILabel *storyScore;
@property (strong, nonatomic) IBOutlet UILabel *storyCommentCount;

@end
