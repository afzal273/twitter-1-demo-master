//
//  TweetsViewController.m
//  Twitter
//
//  Created by Syed, Afzal on 2/19/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//

#import "TweetsViewController.h"
#import "User.h"
#import "TwitterClient.h"
#import "Tweet.h"
#import "TweetCell.h"
#import "SVProgressHUD.h"
#import "ComposeTweetViewController.h"
#import "TweetDetailViewController.h"

@interface TweetsViewController () <UITableViewDataSource, UITableViewDelegate, ComposeTweetViewControllerDelegate, TweetDetailViewControllerDelegate, TweetCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSArray *tweets;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation TweetsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];

    UIColor *myBlueColor = [UIColor colorWithRed:0.251 green:0.6 blue:1 alpha:1];
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    self.tableView.estimatedRowHeight = 105;
   // self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Home";
    self.navigationController.navigationBar.backgroundColor = myBlueColor;
    self.navigationController.navigationBar.barTintColor = myBlueColor;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onSignOutButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(onNewButton)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTweets) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];

    [self showLoadingHUD];
    [self refreshTweets];
    

}
    


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    TweetDetailViewController *tdvc = [[TweetDetailViewController alloc] init];
    tdvc.delegate = self;
    tdvc.tweet = self.tweets[indexPath.row];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:tdvc];
    nvc.navigationBar.translucent = NO;
    

    
    CATransition *tdvctransition = [CATransition animation];
    tdvctransition.type = kCATransitionPush;
    tdvctransition.subtype = kCATransitionFromRight;
    [self.view.window.layer addAnimation:tdvctransition forKey:kCATransition];
    
    [self.navigationController presentViewController:nvc animated:NO completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
    
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    cell.delegate = self;
    
    cell.tweet = self.tweets[indexPath.row];
    
    if (indexPath.row == self.tweets.count - 1) {
        [self grabMoreTweets];
    }
    
    return cell;
    
}

#pragma Mark Twitter Private Methods

- (void) onSignOutButton {
    [User logout];
}


- (void)refreshTweets {
    [[TwitterClient sharedInstance] homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        if (error) {
            NSLog(@"There is an error: %@", [error userInfo]);
        } else {
            self.tweets = tweets;
            [SVProgressHUD dismiss];
            [self.refreshControl endRefreshing];
            [self.tableView reloadData];
        }
    }];
}

- (void) onNewButton {
    [self composeTweet:nil];
    
}

-(void) composeTweet:(TweetCell *)tweetCell{
    ComposeTweetViewController *tvc = [[ComposeTweetViewController alloc] init];
    tvc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:tvc];
    nvc.navigationBar.translucent = NO;
    if(tweetCell != nil){
        tvc.tweet = tweetCell.tweet;
    }
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
}

- (void) grabMoreTweets {
    // using this page https://dev.twitter.com/rest/public/timelines
    
    NSString *lastTweetIdString = [self.tweets[self.tweets.count - 1] idString];
    if (lastTweetIdString == nil) {
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"max_id"] = lastTweetIdString;
    
    [[TwitterClient sharedInstance] homeTimelineWithParams:params completion:^(NSArray *tweets, NSError *error) {
        if (tweets != nil && tweets.count > 0) {
                //NSLog(@"Got %ld more tweets", tweets.count);
                NSMutableArray *allTweets = [NSMutableArray arrayWithArray:self.tweets];
                [allTweets addObjectsFromArray:tweets];
                self.tweets = [allTweets copy];
                [self.tableView reloadData];
            
        } else {
            NSLog(@"Couldn't get more tweets");
        }
        
        if(error){
            NSLog(@"Error: %@", [error userInfo]);
        }
    }];
    
}

#pragma mark ComposeTweetViewController delegate methods


- (void)tweetedThisTweet:(Tweet *)tweet {
    NSMutableArray *allTweets = [NSMutableArray arrayWithArray:self.tweets];
    [allTweets insertObject:tweet atIndex:0];
    self.tweets = [allTweets copy];
    [self.tableView reloadData];
    
}

#pragma mark TweetDetailViewControllerDelegate methods

// Reload the table view data, since we are doing
// everything locally, don't need to fetch from network
// on retweeting or favoriting
- (void)retweeted:(BOOL)retweeted {
    [self.tableView reloadData];
}

- (void)favorited:(BOOL)favorited {
    [self.tableView reloadData];
}

#pragma mark TweetCell Delegate methods

- (void)onReplyButton:(TweetCell *)tweetCell {
    [self composeTweet:tweetCell];
}


#pragma mark Private methods

- (void) showLoadingHUD {
    [SVProgressHUD show];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0.251 green:0.6 blue:1 alpha:1]];
    [SVProgressHUD showWithStatus:@"Loading"];
    
}


@end
