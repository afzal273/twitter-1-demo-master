//
//  TweetCell.m
//  Twitter
//
//  Created by Syed, Afzal on 2/19/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+AFNetworking.h"
#import "ComposeTweetViewController.h"

@interface TweetCell ()
@property (strong, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *twitterHandleLabel;
@property (strong, nonatomic) IBOutlet UILabel *durationLabel;
@property (strong, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetedByLabel;
@property (weak, nonatomic) IBOutlet UIButton *topRetweetedButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationTopViewContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twitterHandleTopViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userNameTopViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *thumbImageTopViewConstraint;

@end

@implementation TweetCell

- (void)awakeFromNib {
    // Initialization code
    
    self.thumbImageView.layer.cornerRadius = 3;
    self.thumbImageView.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setTweet:(Tweet *)tweet {
    _tweet = tweet;
    Tweet *displayedTweet;
    User *user = tweet.user;


    
    if (tweet.retweetedTweet) {
        displayedTweet = tweet.retweetedTweet;

        self.durationTopViewContraint.constant = 28;
        self.twitterHandleTopViewConstraint.constant = 28;
        self.userNameTopViewConstraint.constant = 28;
        self.thumbImageTopViewConstraint.constant = 28;
        
        [self.topRetweetedButton setImage:[[UIImage imageNamed:@"retweet_hover.png" ] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        self.retweetedByLabel.text = [NSString stringWithFormat:@"%@ retweeted", user.name];
        [self.topRetweetedButton setHidden:NO];
        [self.retweetedByLabel setHidden:NO];

    } else {
        displayedTweet = tweet;
        self.durationTopViewContraint.constant = 10;
        self.twitterHandleTopViewConstraint.constant = 10;
        self.userNameTopViewConstraint.constant = 10;
        self.thumbImageTopViewConstraint.constant = 10;
        

        [self.topRetweetedButton setHidden:YES];
        [self.retweetedByLabel setHidden:YES];

    }
    
    [self.thumbImageView setImageWithURL:[NSURL URLWithString:displayedTweet.user.profileImageUrl]];
    self.usernameLabel.text = displayedTweet.user.screenName;
    
    self.twitterHandleLabel.text = [NSString stringWithFormat:@"@%@", displayedTweet.user.screenName];
    self.tweetLabel.text = displayedTweet.text;
    
    
    // Let's show time elapsed
    NSTimeInterval secondsElapsed = -[displayedTweet.createdAt timeIntervalSinceNow];
    
    if (secondsElapsed >= 86400) {
        // show date
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"M/d/yy"];
        self.durationLabel.text = [dateFormat stringFromDate:tweet.createdAt];
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
    
    
    [self.replyButton setImage:[[UIImage imageNamed:@"reply_hover.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.retweetButton setImage:[[UIImage imageNamed:@"retweet_hover.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.favoriteButton setImage:[[UIImage imageNamed:@"favorite_hover.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    
    if (displayedTweet.retweetedCount > 0) {
        self.retweetLabel.text = [NSString stringWithFormat:@"%ld", (long)displayedTweet.retweetedCount];
    } else {
        self.retweetLabel.text = @"";
    }
    
    if (displayedTweet.favoritedCount > 0) {
        self.favoriteLabel.text = [NSString stringWithFormat:@"%ld", (long)displayedTweet.favoritedCount];
    } else {
        self.favoriteLabel.text = @"";
    }
    
    if (displayedTweet.retweeted) {
        self.retweetLabel.textColor = [UIColor orangeColor];
        [self.retweetButton setImage:[[UIImage imageNamed:@"retweet_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self.topRetweetedButton setImage:[[UIImage imageNamed:@"retweet_on.png" ] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        
    } else {
        self.retweetLabel.textColor = [UIColor blackColor];
    }
    
    if (displayedTweet.favorited) {
        self.favoriteLabel.textColor = [UIColor orangeColor];
        [self.favoriteButton setImage:[[UIImage imageNamed:@"favorite_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    } else {
        self.favoriteLabel.textColor = [UIColor blackColor];
    }
    
}

#pragma mark action buttons

- (IBAction)onReplyButton:(id)sender {
    [self.delegate onReplyButton:self];
}

- (IBAction)onRetweetButton:(id)sender {
    BOOL retweeted = [self.tweet retweet];
    
    if (retweeted) {
        self.retweetLabel.textColor = [UIColor orangeColor];
        [self.retweetButton setImage:[[UIImage imageNamed:@"retweet_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self.topRetweetedButton setImage:[[UIImage imageNamed:@"retweet_on.png" ] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    } else {
        self.retweetLabel.textColor = [UIColor blackColor];
        [self.retweetButton setImage:[[UIImage imageNamed:@"retweet_hover.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        [self.topRetweetedButton setImage:[[UIImage imageNamed:@"retweet_hover.png" ] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    }
    if (self.tweet.retweetedCount > 0) {
        self.retweetLabel.text = [NSString stringWithFormat:@"%ld", (long)self.tweet.retweetedCount];
    } else {
        self.retweetLabel.text = @"";
    }

}

- (IBAction)onFavoriteButton:(id)sender {
    
    
    Tweet *tweetForFavoriting;
    if (self.tweet.retweetedTweet) {
        tweetForFavoriting = self.tweet.retweetedTweet;
    } else {
        tweetForFavoriting = self.tweet;
    }
    
    BOOL favorited = [tweetForFavoriting favorite];
    
    if (favorited) {
        
        self.favoriteLabel.textColor = [UIColor orangeColor];
        [self.favoriteButton setImage:[[UIImage imageNamed:@"favorite_on.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    } else {
        self.favoriteLabel.textColor = [UIColor blackColor];
        [self.favoriteButton setImage:[[UIImage imageNamed:@"favorite_hover.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    }
    if (tweetForFavoriting.favoritedCount > 0) {
        self.favoriteLabel.text = [NSString stringWithFormat:@"%ld", (long)tweetForFavoriting.favoritedCount];
    } else {
        self.favoriteLabel.text = @"";
    }
}

- (IBAction)onTopRetweetButton:(id)sender {
    [self onRetweetButton:self];
}


@end
