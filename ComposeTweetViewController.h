//
//  ComposeTweetViewController.h
//  Twitter
//
//  Created by Syed, Afzal on 2/21/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@protocol ComposeTweetViewControllerDelegate <NSObject>

- (void)tweetedThisTweet:(Tweet *)tweet;

@end

@interface ComposeTweetViewController : UIViewController

@property (nonatomic, strong) Tweet *tweet; 
@property (nonatomic, strong) User *user;

@property (nonatomic, weak) id <ComposeTweetViewControllerDelegate> delegate;

@end
