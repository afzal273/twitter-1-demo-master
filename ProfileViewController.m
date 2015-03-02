//
//  ProfileViewController.m
//  Twitter
//
//  Created by Syed, Afzal on 2/28/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//

#import "ProfileViewController.h"
#import "ComposeTweetViewController.h"
#import "ProfileCell.h"
#import "TweetCell.h"
#import "TwitterClient.h"
#import "TweetsViewController.h"
#import "SVProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "TweetDetailViewController.h"
#import "User.h"

@interface ProfileViewController ()<UITableViewDataSource, UITableViewDelegate, ComposeTweetViewControllerDelegate, TweetDetailViewControllerDelegate, TweetCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSArray *tweets;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    UIColor *myBlueColor = [UIColor colorWithRed:0.251 green:0.6 blue:1 alpha:1];
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    //self.tableView.estimatedRowHeight = 105;
     self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Profile";
    self.navigationController.navigationBar.backgroundColor = myBlueColor;
    self.navigationController.navigationBar.barTintColor = myBlueColor;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(onBackButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(onNewButton)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    
    User *user = self.user ? self.user : [User currentUser];
    
    if (!self.user) {
        // add Sign Out button
        UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];
        self.navigationItem.leftBarButtonItem = leftBarButton;
        
          } else {
        self.navigationItem.title = user.name;
    }
    

    
    // register cells
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileCell" bundle:nil] forCellReuseIdentifier:@"ProfileCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    //self.tableView.estimatedRowHeight = 105;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    
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

#pragma Mark Table View methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //ignore profile cell
    if (indexPath.row == 0) {
        return;
    }
    
    
    TweetDetailViewController *tdvc = [[TweetDetailViewController alloc] init];
    tdvc.delegate = self;
    tdvc.tweet = self.tweets[indexPath.row-1];
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:tdvc];
    nvc.navigationBar.translucent = NO;
    
    
    
    CATransition *tdvctransition = [CATransition animation];
    tdvctransition.type = kCATransitionPush;
    tdvctransition.subtype = kCATransitionFromRight;
    [self.view.window.layer addAnimation:tdvctransition forKey:kCATransition];
    [self.navigationController presentViewController:nvc animated:NO completion:nil];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 ) {
        self.tableView.rowHeight = 250;
        ProfileCell *Cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileCell"];
        User *profileUser;
        
        if (!self.user) {
            profileUser = [User currentUser];
        } else {
            profileUser = self.user;
            
        }
        
        [Cell setUser:profileUser];
        
        return Cell;
        
    } else {
        if([self.tweets[indexPath.row - 1] retweeted] == YES )
            self.tableView.rowHeight = 130;
        else
            self.tableView.rowHeight = 115;
        
        TweetCell *Cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
        Cell.tweet = self.tweets[indexPath.row - 1];
        Cell.delegate = self;
        
        // if data for the last cell is requested, then obtain more data
        if (indexPath.row == self.tweets.count - 1) {
            NSLog(@"End of list reached...");
            //[self fetchMoreTweets];
            
            
        }
        
        return Cell;
    }
}

- (void)onLogout {
    [User logout];
}

- (void) onNewButton {
    ComposeTweetViewController *ctvc = [[ComposeTweetViewController alloc] init];
    ctvc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:ctvc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
    
}

- (void)refreshTweets {
    [[TwitterClient sharedInstance] userTimelineWithParams:nil user:self.user completion:^(NSArray *tweets, NSError *error) {
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

- (void) showLoadingHUD {
    [SVProgressHUD show];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:0.251 green:0.6 blue:1 alpha:1]];
    [SVProgressHUD showWithStatus:@"Loading"];
    
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

- (void)tweetedThisTweet:(Tweet *)tweet {
    if (!self.user) {
        NSMutableArray *temp = [NSMutableArray arrayWithArray:self.tweets];
        [temp insertObject:tweet atIndex:0];
        self.tweets = [temp copy];
        [self.tableView reloadData];
    }
}

#pragma mark TweetCell Delegate methods

- (void)onReplyButton:(TweetCell *)tweetCell {
    [self composeTweet:tweetCell];
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

- (void)onImageTapGesture:(TweetCell *)tweetCell {
    ProfileViewController *pvc = [[ProfileViewController alloc] init];
    //tdvc.delegate = self;
    pvc.user = tweetCell.tweet.user;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:pvc];
    nvc.navigationBar.translucent = NO;
    
    
    
    CATransition *tdvctransition = [CATransition animation];
    tdvctransition.type = kCATransitionPush;
    tdvctransition.subtype = kCATransitionFromRight;
    [self.view.window.layer addAnimation:tdvctransition forKey:kCATransition];
    
    [self.navigationController presentViewController:nvc animated:NO completion:nil];
    
    
}

- (void) onBackButton {
    CATransition *tdvctransition = [CATransition animation];
    tdvctransition.type = kCATransitionPush;
    tdvctransition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:tdvctransition forKey:kCATransition];
    [self dismissViewControllerAnimated:NO completion:nil];
    
}


@end
