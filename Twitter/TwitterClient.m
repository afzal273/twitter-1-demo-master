//
//  TwitterClient.m
//  Twitter
//
//  Created by Syed, Afzal on 2/16/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//

#import "TwitterClient.h"
#import "Tweet.h"

NSString *const kTwitterConsumerKey = @"Sk9M0CXgu5hlqCU90yUYXk11F";
NSString *const kTwitterConsumerSecret = @"GkF4wvDrIW7Rj8MWg6g86ta62FFaFZyvPjfHx8ttdUUxoztfmR";
NSString *const kTwitterBaseUrl = @"https://api.twitter.com";

// Class extension
@interface TwitterClient()

@property (nonatomic, strong) void (^loginCompletion) (User *user, NSError *error);

@end

@implementation TwitterClient

+ (TwitterClient *)sharedInstance {
    // = nil will
    static TwitterClient *instance = nil;
    
    static dispatch_once_t onceToken;
    // wrapping code inside the dispatch to make it thread safe
    
    dispatch_once(&onceToken, ^{
    
        if (instance == nil){
            instance = [[TwitterClient alloc]initWithBaseURL:[NSURL URLWithString:kTwitterBaseUrl] consumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
        }
    
    });

    
    return instance;
    
}

- (void) loginWithCompletion:( void (^) (User *user, NSError *error)) completion {
    
    self.loginCompletion = completion;
    
    [self.requestSerializer removeAccessToken];
    [self fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"cptwitterdemo://oauth"] scope:nil
                            success:^(BDBOAuth1Credential *requestToken){
                                NSLog(@"Got the request token");
                                NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token]];
                                [[UIApplication sharedApplication] openURL:authURL];
                                
                            }failure:^(NSError *error){
                                NSLog(@"Failed to get the request token");
                                self.loginCompletion (nil,error);
                            }];
    
}


- (void)openURL:(NSURL *)url {
    
    [self fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query] success:^(BDBOAuth1Credential* accessToken) {
        NSLog(@"Got the access token");
        [self.requestSerializer saveAccessToken:accessToken];
        // Any requests made now will be authenticated
        [self GET:@"1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //  NSLog(@"Current user: %@", responseObject);
            User *user = [[User alloc]initWithDictionary:responseObject];
            // Persist the user
            [User setCurrentUser:user];
            NSLog(@"Current user: %@", user.name);
            self.loginCompletion(user,nil);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error){
            NSLog(@"failed getting current user");
        }];
        
     
        
    } failure:^(NSError *error){
        NSLog(@"Failed to get the access token");
        self.loginCompletion(nil,error);
    }];
    
}

- (void) homeTimelineWithParams :(NSDictionary *)params completion: (void (^) (NSArray *tweets, NSError *error)) completion {
    
    //for favoriting, posting it will be self POST instead of self GET
    
    [self GET:@"1.1/statuses/home_timeline.json?include_my_retweet=1" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *tweets = [Tweet tweetsWithArray:responseObject];
        completion(tweets,nil);
       // NSLog(@"%@", tweets);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        completion(nil,error);
        
    }];
}

- (void)postTweetWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSString *, NSError *))completion {
    
    NSString *urlToPost;
    
    if (tweet.inReplyToStatusIdStr) {
        urlToPost = [NSString stringWithFormat:@"1.1/statuses/update.json?status=%@&in_reply_to_status_id=%@", tweet.text, tweet.inReplyToStatusIdStr];
    } else {
        urlToPost = [NSString stringWithFormat:@"1.1/statuses/update.json?status=%@", tweet.text];
    }
    
    [self POST:[urlToPost stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           completion(responseObject[@"id_str"], nil);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           completion(nil, error);
       }];
}


- (void)retweetWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSString *retweetIdStr, NSError *error))completion {
    NSString *postUrl = [NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", tweet.idString];
    [self POST:[postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           completion(responseObject[@"id_str"], nil);
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           completion(nil, error);
       }];
    
}
- (void)unretweetWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSError *error))completion {
    NSString *postUrl = [NSString stringWithFormat:@"1.1/statuses/destroy/%@.json", tweet.retweetIdString];
    [self POST:[postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error);
    }];
    
}

- (void)favoriteWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSError *error))completion {
    NSString *postUrl = [NSString stringWithFormat:@"1.1/favorites/create.json?id=%@", tweet.idString];
    [self POST:[postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error);
    }];
    
}

- (void)unfavoriteWithParams:(NSDictionary *)params tweet:(Tweet *)tweet completion:(void (^)(NSError *error))completion {
    NSString *postUrl = [NSString stringWithFormat:@"1.1/favorites/destroy.json?id=%@", tweet.idString];
    [self POST:[postUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completion(error);
    }];
    
}

- (void)userTimelineWithParams:(NSDictionary *)params user:(User *)user completion:(void (^)(NSArray *tweets, NSError *error))completion {
    User *forUser = user ? user : [User currentUser];
    NSString *getUrl = [NSString stringWithFormat:@"1.1/statuses/user_timeline.json?include_rts=1&count=20&include_my_retweet=1&screen_name=%@", forUser.screenName];
    [self GET:getUrl parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSArray *tweets = [Tweet tweetsWithArray:responseObject];
          completion(tweets, nil);
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          completion(nil, error);
      }];
}

- (void)mentionsTimelineWithParams:(NSDictionary *)params completion:(void (^)(NSArray *tweets, NSError *error))completion {
    [self GET:@"1.1/statuses/mentions_timeline.json?include_my_retweet=1" parameters:params
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          NSArray *tweets = [Tweet tweetsWithArray:responseObject];
          completion(tweets, nil);
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          completion(nil, error);
      }];
}


@end
