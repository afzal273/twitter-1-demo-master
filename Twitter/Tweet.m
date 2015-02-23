//
//  Tweet.m
//  Twitter
//
//  Created by Syed, Afzal on 2/18/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//

#import "Tweet.h"
#import "TwitterClient.h"

@implementation Tweet

- (id) initWithDictionary: (NSDictionary *) dictionary {
    
    self = [super init];
    
    if (self) {
        //NSLog(@"%@", dictionary);
        self.user = [[User alloc]initWithDictionary:dictionary[@"user"]];
        
        self.text = dictionary[@"text"];
        NSString *createdAtString  = dictionary[@"created_at"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
        
        self.createdAt = [formatter dateFromString:createdAtString];
        self.userHandle = dictionary[@"screen_name"];
        self.userName = dictionary[@"name"];
        self.thumbImageUrl = dictionary[@"profile_image_url"];
        
        self.retweetedCount = [dictionary[@"retweet_count"] integerValue];
        self.favoritedCount = [dictionary[@"favorite_count"] integerValue];
        
        self.retweeted = [dictionary[@"retweeted"] boolValue];
        self.favorited = [dictionary[@"favorited"] boolValue];
        
        // if tweet has retweeded_status, create another tweet under the class
        if (dictionary[@"retweeted_status"] != nil) {
            self.retweetedTweet = [[Tweet alloc] initWithDictionary:dictionary[@"retweeted_status"]];
        }
        
        self.idString = dictionary[@"id_str"];
        
        if (dictionary[@"in_reply_to_status_id_str"]) {
            self.inReplyToStatusIdStr = dictionary[@"in_reply_to_status_id_str"];
        }
        
        if (dictionary[@"current_user_retweet"]) {
            self.retweetIdString = dictionary[@"current_user_retweet"][@"id_str"];
        } else if (self.retweeted && [self.user.screenName isEqualToString:[[User currentUser] screenName]]) {
            self.retweetIdString = self.idString;
        }

    }
    
    return self;
}



+ (NSArray *) tweetsWithArray: (NSArray *) array {
    NSMutableArray *tweets = [NSMutableArray array];
    
    for (NSDictionary *dictionary in array) {
        [tweets addObject:[[Tweet alloc]initWithDictionary:dictionary]];
    }
    
    return tweets;
}

- (id) initWithText:(NSString *)text  replyToTweet:(Tweet *) replyToTweet {
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
    
    NSDictionary *data = [NSDictionary dictionary];
    NSDictionary *user = [NSDictionary dictionary];
    User *currentUser = [User currentUser];
    
    user = @{
             @"name" : currentUser.name,
             @"screen_name" : currentUser.screenName,
             @"profile_image_url" : currentUser.profileImageUrl,
            };
    
    data = @{
             @"user" : user,
             @"text" : text,
             @"created_at" : [formatter stringFromDate:now],
             @"retweeted" : @NO,
             @"favorited" : @NO,
             @"in_reply_to_status_id_str" : replyToTweet ? replyToTweet.idString : @NO
             };
    
    return [self initWithDictionary:data];
}

- (BOOL)retweet {
    // This is a toggle switch so consider both cases
    self.retweeted = !self.retweeted;
    if (self.retweeted) {
        self.retweetedCount++;
        [[TwitterClient sharedInstance] retweetWithParams:nil tweet:self completion:^(NSString *retweetIdStr, NSError *error) {
            if (!error) {
                //NSLog(@"Successfully retweeted, %@",retweetIdStr);
                self.retweetIdString = retweetIdStr;

            } else {
                NSLog(@"Couldn't retweet %@",[error userInfo]);
                
            }
        }];
    } else {
        self.retweetedCount--;
        [[TwitterClient sharedInstance] unretweetWithParams:nil tweet:self completion:^(NSError *error) {
            if (!error) {
                //NSLog(@"Successfully unretweeted");
            } else {
                NSLog(@"Couldn't unretweet, %@", [error userInfo]);
            }
        }];
    }
    
    return self.retweeted;
}

- (BOOL)favorite {
    // This is a toggle switch so consider both cases
    self.favorited = !self.favorited;
    if (self.favorited) {
        self.favoritedCount++;
        [[TwitterClient sharedInstance] favoriteWithParams:nil tweet:self completion:^(NSError *error) {
            if (!error) {
                //NSLog(@"Succesfully Favorited");
            } else {
                NSLog(@"Couldn't favorite, %@",[error userInfo]);
            }
        }];
    } else {
        self.favoritedCount--;
        [[TwitterClient sharedInstance] unfavoriteWithParams:nil tweet:self completion:^(NSError *error) {
            if (!error) {
                //NSLog(@"Successfully unfavorited");
            } else {
                NSLog(@"Couldn't unfavorite, %@", [error userInfo]);
            }
        }];
    }
    
    return self.favorited;
}

@end
