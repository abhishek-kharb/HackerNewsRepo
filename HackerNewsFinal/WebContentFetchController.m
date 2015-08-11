//
//  WebContentFetchController.m
//  HackerNewsFinal
//
//  Created by Abhishek Kharb on 21/07/15.
//  Copyright (c) 2015 Abhishek Kharb. All rights reserved.
//

#import "WebContentFetchController.h"
#import "StoryItem.h"
#import "CustomNSURLConnection.h"

@interface WebContentFetchController()
@property (strong, nonatomic) NSNumber *totalItemsToFetch;
@property (strong, nonatomic) NSMutableArray *storyIDs;
@property (strong, nonatomic) NSNumber *currentFetchIndex;
@property (strong, nonatomic) NSNumber *currentFetchCounter;
@property (strong, nonatomic) NSPersistentStoreCoordinator *myCoordinator;
@property (strong, nonatomic) NSManagedObjectModel *myModel;
@property (strong, nonatomic) NSURL *myStoreUrl;
@property (strong, nonatomic) NSMutableArray *myManagedObjects;
@property (strong, nonatomic) NSMutableArray *myFinalDataArray;
@property (strong, nonatomic) NSArray *myDescriptorArray;
@property (strong, nonatomic) NSManagedObjectContext *myContext;
@end

@implementation WebContentFetchController

-(instancetype) init{
    self = [super init];
    if(self){
        self.totalItemsToFetch = @20;
        self.currentFetchIndex = @0;
        self.currentFetchCounter = @1;
        self.storyIDs = [[NSMutableArray alloc] initWithObjects: nil];
        self.myManagedObjects = [[NSMutableArray alloc] initWithObjects: nil];
        self.myFinalDataArray = [[NSMutableArray alloc] initWithObjects: nil];
        self.isThisRefreshDelegateCall = NO;
        NSError *myError;
        NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"DataModel" withExtension:@".momd"];
        self.myModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
        self.myCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.myModel];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath =[paths objectAtIndex:0];
        NSString *storeString = [docPath stringByAppendingPathComponent:@"MyStoryItemStore.sqlite"];
        self.myStoreUrl = [NSURL fileURLWithPath:storeString];
        
        [self.myCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.myStoreUrl options:nil error:&myError];
        self.myContext =[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [self.myContext setPersistentStoreCoordinator:self.myCoordinator];
        
        NSSortDescriptor *myDescriptorWithFetchId = [[NSSortDescriptor alloc] initWithKey:@"storyId" ascending:NO];
        self.myDescriptorArray = [[NSArray alloc] initWithObjects:myDescriptorWithFetchId, nil];

    }
    return self;
}


-(void) initiateItemIdFetch{
    
    ///***************** First try to Fetch Core Data and see if data already exisis. If So updata allStoryId property and return
   ///******************  otherwise fetch contents from the web!
    
    NSEntityDescription *myStoreEntity = [NSEntityDescription entityForName:@"StoryItem" inManagedObjectContext:self.myContext];
    NSFetchRequest *myFetchRequest = [[NSFetchRequest alloc] init];
    NSError *myError;
    [myFetchRequest setEntity:myStoreEntity];
    [myFetchRequest setSortDescriptors:self.myDescriptorArray];
    NSArray *myData = [self.myContext executeFetchRequest:myFetchRequest error:&myError];
    [self.myManagedObjects addObjectsFromArray:myData];
    if (self.myManagedObjects.count >0) {
      //  NSLog(@"%ld",self.myManagedObjects.count);
        for (int i=0; i<self.myManagedObjects.count; i++) {
            StoryItem *myItem = (StoryItem *) [self.myManagedObjects objectAtIndex:i];
            [self.storyIDs addObject:myItem.storyId];
            if(myItem.storyTitle){
                [self.myFinalDataArray addObject:myItem];
            }
        }
        //NSLog(@"%ld",self.myFinalDataArray.count);
       // NSLog(@"%@ %ld",self.storyIDs,self.storyIDs.count);
        [self.delegate didFinishDataFetchWithData:self.myFinalDataArray];
    }
    else{
        NSURL *fetchRequestUrl = [NSURL URLWithString:@"https://hacker-news.firebaseio.com/v0/newstories.json?print=pretty"];
        NSURLRequest *fetchRequest = [NSURLRequest requestWithURL:fetchRequestUrl];
        CustomNSURLConnection *fetchConnection = [[CustomNSURLConnection alloc] initWithRequest:fetchRequest delegate:self];
        fetchConnection.identifier = @"Initiate Item Id Fetch";

    }
    
}

-(void) connection:(CustomNSURLConnection *)connection didReceiveData:(NSData *)data{
    NSError *myError;
    if ([connection.identifier isEqualToString:@"Initiate Item Id Fetch"]) {
        NSArray *myStoryIDs = [NSJSONSerialization JSONObjectWithData:data options:0 error:&myError];
        
        //*** If storyID already contains data, then the data received is from a refresh request, in which case only a few new stories need to be added
        
        if(self.storyIDs.count >0){
            NSNumber *lastTopStory = [self.storyIDs objectAtIndex:0];
            self.storyIDs = nil;
            self.storyIDs = [[NSMutableArray alloc] initWithArray:myStoryIDs];
            //NSLog(@"%@", self.storyIDs);
            int counter =0;
            for (NSNumber *iterator in self.storyIDs) {
                if ([iterator isEqualToNumber:lastTopStory]) {
                    break;
                }
                else{
                    counter++;
                }
            }
            
            self.totalItemsToFetch = [NSNumber numberWithInt:counter];
            self.currentFetchIndex = @0;
            
            
            //**** Delete items equal to counter from the rear side of the managed object array so that the total number of items in the sqlite table remains 500   ******//
            
            //NSLog(@"%ld",self.myManagedObjects.count);
            long i= self.myManagedObjects.count-1;
            
            while (counter) {
                [self.myContext deleteObject: [self.myManagedObjects objectAtIndex:i]];
                i--;
                counter--;
            }
            for (int i=[self.totalItemsToFetch intValue]-1; i>=0; i--) {
                //*********** Add the new objects to be fetched to the managed object context and associate its object id with the connection ******//
                NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"StoryItem" inManagedObjectContext:self.myContext];
                StoryItem *storyItem =[[StoryItem alloc] initWithEntity:myEntity insertIntoManagedObjectContext:self.myContext];
                storyItem.storyId = [self.storyIDs objectAtIndex:i];
                [self.myManagedObjects insertObject:storyItem atIndex:0];
            }
        }
        
        else{
            self.myManagedObjects = nil;
            self.myManagedObjects = [[NSMutableArray alloc] initWithObjects: nil];
            [self.storyIDs addObjectsFromArray:myStoryIDs];
            for (int i=0; i<500; i++) {
                //*********** Add the object to be fetched to the managed object context and associate its object id with the connection ******//
                NSEntityDescription *myEntity = [NSEntityDescription entityForName:@"StoryItem" inManagedObjectContext:self.myContext];
                StoryItem *storyItem =[[StoryItem alloc] initWithEntity:myEntity insertIntoManagedObjectContext:self.myContext];
                storyItem.storyId = [self.storyIDs objectAtIndex:i];
                [self.myManagedObjects addObject:storyItem];
            }
        }
        
        
        NSError *myError;
        [self.myContext obtainPermanentIDsForObjects:self.myManagedObjects error:&myError];
        
    }
    else if ([connection.identifier isEqualToString:@"Fetch Particular Item"]){
        NSDictionary *myItemData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&myError];
        
        StoryItem *storyItem =  (StoryItem *)  [self.myContext objectWithID:connection.managedObjectId];
        storyItem.storyAuthor = [myItemData objectForKey:@"by"];
        storyItem.storyTitle = [myItemData objectForKey:@"title"];
        storyItem.storyCommentCount = [myItemData objectForKey:@"descendants"];
        storyItem.storyScore = [myItemData objectForKey:@"score"];
        storyItem.storyUrl = [myItemData objectForKey:@"url"];
        storyItem.storyTimeStamp = [myItemData objectForKey:@"time"];
        [self.myFinalDataArray addObject:storyItem];
    }
}

-(void) connectionDidFinishLoading:(CustomNSURLConnection *)connection{
    if ([connection.identifier isEqualToString:@"Initiate Item Id Fetch"]) {
        if (self.totalItemsToFetch.intValue == 0) {
            [self.delegate didFinishDataFetchWithData:nil];

        }
        else{
            [self fetchDataForItemIdsStartingFromIndex:self.currentFetchIndex];
        }
    }
    else if([self.currentFetchCounter isEqual: self.totalItemsToFetch]){
        NSError *myError;
        [self.myContext save:&myError];
        [self.delegate didFinishDataFetchWithData:self.myFinalDataArray];
    }
    else{
        self.currentFetchCounter = @(self.currentFetchCounter.integerValue +1);
    }
}


-(void) fetchDataForItemIdsStartingFromIndex: (NSNumber *) index{
    
    NSString *urlFirstPart = @"https://hacker-news.firebaseio.com/v0/item/";
    NSString *urlLastPart = @".json?print=pretty";
    
    for (int i = [index intValue]; i < ([index intValue] + [self.totalItemsToFetch intValue]); i++) {
        NSNumber *itemId = [self.storyIDs objectAtIndex:i];
        NSString *itemIdString = [NSString stringWithFormat:@"%@",itemId];
        NSString *myFinalString = [[NSString alloc] initWithString:urlFirstPart];
        myFinalString = [myFinalString stringByAppendingString:itemIdString];
        myFinalString = [myFinalString stringByAppendingString:urlLastPart];
        
        
        
        NSURL *fetchRequestUrl = [NSURL URLWithString:myFinalString];
        NSURLRequest *fetchRequest = [NSURLRequest requestWithURL:fetchRequestUrl];
        CustomNSURLConnection *fetchConnection = [[CustomNSURLConnection alloc] initWithRequest:fetchRequest delegate:self];
        fetchConnection.identifier = @"Fetch Particular Item";
        fetchConnection.fetchedItemId = itemId;
        StoryItem *currentItemObject = [self.myManagedObjects objectAtIndex:i];
        fetchConnection.managedObjectId = currentItemObject.objectID;
        
    }
}


-(void) fetchMoreItemsStaringFromIndex:(long)index{
    self.totalItemsToFetch = @20;
    self.currentFetchCounter = @1;
    self.currentFetchIndex = [NSNumber numberWithLong:index];
    self.isThisRefreshDelegateCall = NO;
    self.myFinalDataArray = nil;
    self.myFinalDataArray = [[NSMutableArray alloc] initWithObjects: nil];
    [self fetchDataForItemIdsStartingFromIndex:self.currentFetchIndex];

}


-(void) refreshData{
    self.myFinalDataArray = nil;
    self.currentFetchCounter = @1;
    self.isThisRefreshDelegateCall = YES;
    self.myFinalDataArray = [[NSMutableArray alloc] initWithObjects: nil];
    NSURL *fetchRequestUrl = [NSURL URLWithString:@"https://hacker-news.firebaseio.com/v0/newstories.json?print=pretty"];
    NSURLRequest *fetchRequest = [NSURLRequest requestWithURL:fetchRequestUrl];
    CustomNSURLConnection *fetchConnection = [[CustomNSURLConnection alloc] initWithRequest:fetchRequest delegate:self];
    fetchConnection.identifier = @"Initiate Item Id Fetch";
    
}




-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Connection Failed With Error %@",error);
}

@end
