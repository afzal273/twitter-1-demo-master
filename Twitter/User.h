//
//  User.h
//  Twitter
//
//  Created by Syed, Afzal on 2/18/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//

#import <Foundation/Foundation.h>

// extern tells the complier that the variable exists
// but is not allocated here
extern NSString *const UserDidLoginNotification;
extern NSString *const UserDidLogoutNotification;

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSString *profileImageUrl;
@property (nonatomic, strong) NSString *tagline;
@property (nonatomic) NSInteger statusesCount;
@property (nonatomic) NSInteger friendsCount;
@property (nonatomic) NSInteger followersCount;

- (id) initWithDictionary: (NSDictionary *) dictionary;

//creating a getter and setter
// to set class properties

+ (User *)currentUser;
+ (void) setCurrentUser:(User *)currentUser;
+ (void) logout;


@end
