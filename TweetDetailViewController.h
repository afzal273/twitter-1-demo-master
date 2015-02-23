//
//  TweetDetailViewController.h
//  Twitter
//
//  Created by Syed, Afzal on 2/21/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@protocol TweetDetailViewControllerDelegate <NSObject>

- (void)retweeted:(BOOL)retweeted;
- (void)favorited:(BOOL)favorited;

@end

@interface TweetDetailViewController : UIViewController

@property (nonatomic, strong) Tweet *tweet;

@property (nonatomic, weak) id <TweetDetailViewControllerDelegate> delegate;


@end
