//
//  TableViewCell.m
//  HackerNewsAppInitialSecond
//
//  Created by Abhishek Kharb on 08/07/15.
//  Copyright (c) 2015 Abhishek Kharb. All rights reserved.
//

#import "TableViewCell.h"

@interface TableViewCell() 
@property (strong, nonatomic) IBOutlet UILabel *byLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *commentCountLabel;

@end

@implementation TableViewCell

- (void)awakeFromNib {
    self.storyTitle.numberOfLines = 2;
    self.storyTitle.font = [UIFont italicSystemFontOfSize:15];
    self.storyTitle.textColor = [UIColor blueColor];
    self.storyAuthor.font = [UIFont italicSystemFontOfSize:13];
    self.storyAuthor.textColor = [UIColor blueColor];
    self.byLabel.font = [UIFont systemFontOfSize:13];
    self.scoreLabel.font = [UIFont systemFontOfSize:13];
    self.storyScore.font = [UIFont italicSystemFontOfSize:13];
    self.storyScore.textColor = [UIColor blueColor];
    self.commentCountLabel.font = [UIFont systemFontOfSize:13];
    self.storyCommentCount.font = [UIFont italicSystemFontOfSize:13];
    self.storyCommentCount.textColor = [UIColor blueColor];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
