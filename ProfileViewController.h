//
//  ProfileViewController.h
//  Twitter
//
//  Created by Syed, Afzal on 2/28/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetCell.h"
#import "ProfileCell.h"
#import "TweetsViewController.h"
#import "ComposeTweetViewController.h"

@interface ProfileViewController : UIViewController

@property (strong, nonatomic) User *user;

@end
