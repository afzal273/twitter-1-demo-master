//
//  TwitterClient.h
//  Twitter
//
//  Created by Syed, Afzal on 2/16/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "BDBOAuth1SessionManager.h"
#import "User.h"
#import "Tweet.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *)sharedInstance;

- (void) loginWithCompletion:( void (^) (User *user, NSError *error)) completion;
- (void) openURL : (NSURL *) url;

//fetching homeline
- (void) homeTimelineWithParams :(NSDictionary *)params completion: (void (^) (NSArray *tweets, NSError *error)) completion;

// posting a tweet
- (void)postTweetWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSString *, NSError *))completion;

// methods for favoriting and re-tweeting
- (void)favoriteWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSError *error))completion;
- (void)unfavoriteWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSError *error))completion;

- (void)retweetWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSString *retweetIdStr, NSError *error))completion;
- (void)unretweetWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSError *error))completion;



@end
