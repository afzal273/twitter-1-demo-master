//
//  TweetCell.h
//  Twitter
//
//  Created by Syed, Afzal on 2/19/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//




#import <UIKit/UIKit.h>
#import "Tweet.h"

@class TweetCell;

@protocol TweetCellDelegate <NSObject>

- (void)onReplyButton:(TweetCell *)tweetCell;

@end

@interface TweetCell : UITableViewCell

@property (nonatomic, strong) Tweet *tweet;

@property (nonatomic, weak) id <TweetCellDelegate> delegate;

@end
