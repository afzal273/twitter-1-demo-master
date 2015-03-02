//
//  ProfileCell.m
//  Twitter
//
//  Created by Syed, Afzal on 2/28/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//

#import "ProfileCell.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"

@interface ProfileCell()
@property (weak, nonatomic) IBOutlet UIImageView *thumbImage;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *twitterHandleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numTweetsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numFollowingLabel;
@property (weak, nonatomic) IBOutlet UILabel *numFollowersLabel;


@end


@implementation ProfileCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setUser: (User *) user {
    if(user == nil)
        return;
    
    
    [self.thumbImage setImageWithURL:[NSURL URLWithString:user.profileImageUrl]];
    self.userNameLabel.text = user.name;
    self.twitterHandleLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];

    // setting labels
    self.numTweetsLabel.text = [self fetchFormattedNumber:user.statusesCount];
    self.numFollowingLabel.text = [self fetchFormattedNumber:user.friendsCount];
    self.numFollowersLabel.text = [self fetchFormattedNumber:user.followersCount];
}


- (NSString *) fetchFormattedNumber:(NSInteger)number {
    if (number >= 10000) {
        return [NSString stringWithFormat:@"%.1fK", (double)number / 1000];
    } else if (number >= 1000) {
        return [NSString stringWithFormat:@"%ld,%ld", (long)number / 1000, (long)number % 1000];
    } else {
        return [NSString stringWithFormat:@"%ld", (long)number];
    }
}



@end
