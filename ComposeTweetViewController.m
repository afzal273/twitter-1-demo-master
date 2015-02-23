//
//  ComposeTweetViewController.m
//  Twitter
//
//  Created by Syed, Afzal on 2/21/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//

#import "ComposeTweetViewController.h"
#import "TwitterClient.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"

@interface ComposeTweetViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userTwitterHandleLabel;
@property (weak, nonatomic) IBOutlet UITextView *tweetText;

@end

@implementation ComposeTweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tweetText.delegate = self;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweetButton)];
    
    
    User *currentUser = [User currentUser];

    [self.thumbImageView setImageWithURL:[NSURL URLWithString:[currentUser profileImageUrl]]];
    self.userNameLabel.text = currentUser.name;
    self.userTwitterHandleLabel.text = [NSString stringWithFormat:@"@%@", currentUser.screenName];

    // If this is a reply to existing tweet
    if (self.tweet) {

        if (self.tweet.retweetedTweet) {
            if ([self.tweet.user.screenName isEqualToString:[[User currentUser] screenName]]) {
                self.tweetText.text = [NSString stringWithFormat:@"@%@ ", self.tweet.retweetedTweet.user.screenName];
            } else {
                self.tweetText.text = [NSString stringWithFormat:@"@%@ @%@ ", self.tweet.retweetedTweet.user.screenName, self.tweet.user.screenName];
            }
        } else {
            self.tweetText.text = [NSString stringWithFormat:@"@%@ ", self.tweet.user.screenName];
        }
    }
    
    if (self.user) {
        self.tweetText.text = [NSString stringWithFormat:@"@%@ ", self.user.screenName];
    }
    
    [self.tweetText becomeFirstResponder];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Twitter private methods

- (void) onTweetButton {
    
    //create a tweet with the text
    Tweet *tweet = [[Tweet alloc] initWithText:self.tweetText.text replyToTweet:self.tweet];
    
    [[TwitterClient sharedInstance] postTweetWithParams:nil tweet:tweet completion:^(NSString *tweetIdString, NSError *error) {
        if(tweetIdString != nil) {
            // Setting tweed id
            tweet.idString = tweetIdString;
        } else {
            NSLog(@"Error sending tweet: %@", [error userInfo]);
        }

    }];
    
    [self.delegate tweetedThisTweet:tweet];
    [self dismissViewControllerAnimated:YES completion:nil];
 
}


#pragma mark private methods

-(void) onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
