//
//  TweetDetailViewController.m
//  Twitter
//
//  Created by Syed, Afzal on 2/21/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//

#import "TweetDetailViewController.h"
#import "UIImageView+AFNetworking.h"
#import "TwitterClient.h"
#import "ComposeTweetViewController.h"

@interface TweetDetailViewController ()<ComposeTweetViewControllerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thumImageTopViewContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userNameTopViewConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UIButton *topRetweetedButton;
@property (weak, nonatomic) IBOutlet UILabel *topRetweetedNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *twitterHandleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetedCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoritedCount;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;

@end

@implementation TweetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIColor *myBlueColor = [UIColor colorWithRed:0.251 green:0.6 blue:1 alpha:1];
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    

    // self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Tweet";
    self.navigationController.navigationBar.backgroundColor = myBlueColor;
    self.navigationController.navigationBar.barTintColor = myBlueColor;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(onBackButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Reply" style:UIBarButtonItemStylePlain target:self action:@selector(onReplyButton)];
    
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];
    

    
    if (self.tweet) {
        User *user = self.tweet.user;
        Tweet *displayedTweet;
        
        if (self.tweet.retweetedTweet) {
            displayedTweet = self.tweet.retweetedTweet;
            self.tweet = self.tweet.retweetedTweet;
            self.thumImageTopViewContraint.constant = 32;
            self.userNameTopViewConstraint.constant = 32;
            [self.topRetweetedButton setImage:[[UIImage imageNamed:@"retweet_hover.png" ] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            self.topRetweetedNameLabel.text = [NSString stringWithFormat:@"%@ retweeted", user.name];
            [self.topRetweetedButton setHidden:NO];
            [self.topRetweetedNameLabel setHidden:NO];
        } else {
            displayedTweet = self.tweet;
            self.thumImageTopViewContraint.constant = 16;
            self.userNameTopViewConstraint.constant = 16;
            [self.topRetweetedNameLabel setHidden:YES];
            [self.topRetweetedButton setHidden:YES];

        }
        
        [self.thumbImageView setImageWithURL:[NSURL URLWithString:displayedTweet.user.profileImageUrl]];
        
        self.userNameLabel.text = self.tweet.user.name;
        self.twitterHandleLabel.text = [NSString stringWithFormat:@"@%@", displayedTweet.user.screenName];
        self.tweetLabel.text = displayedTweet.text;

        
        [self.replyButton setImage:[[UIImage imageNamed:@"reply_hover.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self.retweetButton setImage:[[UIImage imageNamed:@"retweet_hover.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self.favoriteButton setImage:[[UIImage imageNamed:@"favorite_hover.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        
        self.retweetedCountLabel.text = [NSString stringWithFormat:@"%ld", (long)displayedTweet.retweetedCount];
        self.favoritedCount.text = [NSString stringWithFormat:@"%ld", (long)displayedTweet.favoritedCount];
        
        if (displayedTweet.retweeted) {
            self.retweetedCountLabel.textColor = [UIColor orangeColor];
            [self.retweetButton setImage:[[UIImage imageNamed:@"retweet_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            [self.topRetweetedButton setImage:[[UIImage imageNamed:@"retweet_on.png" ] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        }

        if (displayedTweet.favorited) {
            self.favoritedCount.textColor = [UIColor orangeColor];
            [self.favoriteButton setImage:[[UIImage imageNamed:@"favorite_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        }
        
        // Let's show time elapsed
        NSTimeInterval secondsElapsed = -[self.tweet.createdAt timeIntervalSinceNow];
        
        if (secondsElapsed >= 86400) {
            // show month, day, and year
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"M/d/yy"];
            self.durationLabel.text = [dateFormat stringFromDate:displayedTweet.createdAt];
        } else if (secondsElapsed >= 3600) {
            // show hours
            self.durationLabel.text = [NSString stringWithFormat:@"%.0fh", secondsElapsed/3600];
        } else if (secondsElapsed >= 60){
            // show minutes
            self.durationLabel.text = [NSString stringWithFormat:@"%.0fm", secondsElapsed/60];
        } else {
            // show seconds
            self.durationLabel.text = [NSString stringWithFormat:@"%.0fs", secondsElapsed];
        }
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark twitter private methods

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
}

- (void) onReplyButton {
    
    // send the tweet to compose tweet vc for reply
    ComposeTweetViewController *ctvc = [[ComposeTweetViewController alloc] init];
    ctvc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:ctvc];
    ctvc.tweet = self.tweet;
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
    
}

- (void) onBackButton {
    CATransition *tdvctransition = [CATransition animation];
    tdvctransition.type = kCATransitionPush;
    tdvctransition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:tdvctransition forKey:kCATransition];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)onReplyButton:(id)sender {
    [self onReplyButton];
}

- (IBAction)onRetweetButton:(id)sender {
    BOOL retweeted = [self.tweet retweet];
    
    self.retweetedCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.tweet.retweetedCount];
    
    if (retweeted) {
        self.retweetedCountLabel.textColor = [UIColor orangeColor];
        [self.retweetButton setImage:[[UIImage imageNamed:@"retweet_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self.topRetweetedButton setImage:[[UIImage imageNamed:@"retweet_on.png" ] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    } else {
        self.retweetedCountLabel.textColor = [UIColor blackColor];
        [self.retweetButton setImage:[[UIImage imageNamed:@"retweet_hover.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self.topRetweetedButton setImage:[[UIImage imageNamed:@"retweet_hover.png" ] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    }
    
    [self.delegate retweeted:retweeted];
}

- (IBAction)onTopRetweetButton:(id)sender {
    [self onRetweetButton:self];
}


- (IBAction)onFavoriteButton:(id)sender {
    Tweet *tweetForFavoriting;
    if (self.tweet.retweetedTweet) {
        tweetForFavoriting = self.tweet.retweetedTweet;
    } else {
        tweetForFavoriting = self.tweet;
    }
    
    BOOL favorited = [tweetForFavoriting favorite];
    
    self.favoritedCount.text = [NSString stringWithFormat:@"%ld", (long)tweetForFavoriting.favoritedCount];
    if (favorited) {
        
        self.favoritedCount.textColor = [UIColor orangeColor];
        [self.favoriteButton setImage:[[UIImage imageNamed:@"favorite_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    } else {
        self.favoritedCount.textColor = [UIColor blackColor];
        [self.favoriteButton setImage:[[UIImage imageNamed:@"favorite_hover.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    }
    
    [self.delegate favorited:favorited];
}



#pragma mark delegate methods

- (void)tweetedThisTweet:(Tweet *)tweet {
    
}



@end
