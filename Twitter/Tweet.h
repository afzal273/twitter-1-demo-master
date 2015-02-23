//
//  Tweet.h
//  Twitter
//
//  Created by Syed, Afzal on 2/18/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic, strong) User *user;

@property (nonatomic, strong) NSDate *createdAt;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *userHandle;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *thumbImageUrl;


@property (nonatomic) NSInteger retweetedCount;
@property (nonatomic) NSInteger favoritedCount;

@property (nonatomic) BOOL retweeted;
@property (nonatomic) BOOL favorited;

@property (nonatomic, strong) Tweet *retweetedTweet;
@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSString *inReplyToStatusIdStr;
@property (nonatomic, strong) NSString *retweetIdString;






- (id) initWithDictionary: (NSDictionary *) dictionary;
- (id) initWithText:(NSString *)text replyToTweet:(Tweet *)replyToTweet;

// methods for retweeting and favoriting a tweet

- (BOOL) retweet;
- (BOOL) favorite;

+ (NSArray *) tweetsWithArray: (NSArray *) array;

@end
