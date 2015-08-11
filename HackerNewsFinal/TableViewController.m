//
//  TableViewController.m
//  HackerNewsFinal
//
//  Created by Abhishek Kharb on 21/07/15.
//  Copyright (c) 2015 Abhishek Kharb. All rights reserved.
//

#import "TableViewController.h"
#import "TableViewCell.h"
#import "StoryItem.h"
#import "DetailedViewController.h"
#import "AppDelegate.h"

@interface TableViewController ()
@property (strong, nonatomic) WebContentFetchController *webContentFetchController;
@property (strong, nonatomic) NSMutableArray *allStoryData;
@property (strong, nonatomic) NSMutableArray *allStoryTempData;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) UIActivityIndicatorView *footerSpinner;
@property (strong, nonatomic) DetailedViewController *detailedViewController;
@end

@implementation TableViewController

static NSString *myIdentifier = @"MySimpleIdentifier";


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"TableViewCell" bundle:nil] forCellReuseIdentifier:myIdentifier];
    self.tableView.rowHeight = 83;
    self.allStoryData = [[NSMutableArray alloc] initWithObjects: nil];
    self.allStoryTempData = [[NSMutableArray alloc] initWithObjects: nil];
    self.detailedViewController = [[DetailedViewController alloc] init];
    self.title = @"Hacker News";
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(50, 130, 220, 220)];
    self.spinner.color = [UIColor blackColor];
    [self.spinner startAnimating];
    [self.tableView addSubview:self.spinner];
    
    self.footerSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(1, 1, 120, 80)];
    self.footerSpinner.color = [UIColor blackColor];
    self.tableView.tableFooterView = self.footerSpinner;
    
    UIBarButtonItem *myRefreshButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStylePlain target:self action:@selector(onRefreshButtonClick)];
    self.navigationItem.rightBarButtonItem =myRefreshButton;
    
    self.webContentFetchController = [[WebContentFetchController alloc] init];
    self.webContentFetchController.delegate = self;
    [self.webContentFetchController initiateItemIdFetch];

}


-(void) didFinishDataFetchWithData:(NSArray *)data{
 
    if (self.webContentFetchController.isThisRefreshDelegateCall == YES) {
        [self.allStoryData addObjectsFromArray:data];
        [self.allStoryData addObjectsFromArray:self.allStoryTempData];
    }
    else{
        [self.allStoryData addObjectsFromArray:self.allStoryTempData];
        [self.allStoryData addObjectsFromArray:data];
    }
    
    
    [self.spinner stopAnimating];
    [self.tableView reloadData];
}


-(void) onRefreshButtonClick{
    
    
    self.allStoryTempData = nil;
    self.allStoryTempData = [[NSMutableArray alloc] initWithArray:self.allStoryData];
    self.allStoryData = nil;
    self.allStoryData = [[NSMutableArray alloc] initWithObjects: nil];
    [self.spinner startAnimating];
    [self.footerSpinner stopAnimating];
    [self.tableView reloadData];
    [self.webContentFetchController refreshData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allStoryData.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:myIdentifier forIndexPath:indexPath];
    
    if(self.allStoryData.count>0){
        StoryItem *storyItem;
        storyItem = [self.allStoryData objectAtIndex:indexPath.row];
        cell.storyAuthor.text = storyItem.storyAuthor;
        cell.storyTitle.text =  storyItem.storyTitle;
        cell.storyScore.text = [storyItem.storyScore stringValue];
        cell.storyCommentCount.text = [storyItem.storyCommentCount stringValue];
        
        if (indexPath.row == self.allStoryData.count-1) {
            
            [self.footerSpinner startAnimating];
            long count = self.allStoryData.count;
            self.allStoryTempData = nil;
            self.allStoryTempData = [[NSMutableArray alloc] initWithArray:self.allStoryData];
            self.allStoryData = nil;
            self.allStoryData = [[NSMutableArray alloc] initWithObjects: nil];
            [self.webContentFetchController fetchMoreItemsStaringFromIndex: count];
        }

        
    }
    return cell;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    StoryItem *storyItem;
    storyItem = [self.allStoryData objectAtIndex:indexPath.row];
    self.detailedViewController.storyURL = storyItem.storyUrl;
    [self.navigationController pushViewController:self.detailedViewController animated:YES];

}


@end
