//
//  MenuProfileCell.m
//  Twitter
//
//  Created by Syed, Afzal on 3/1/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//

#import "MenuProfileCell.h"
#import "UIImageView+AFNetworking.h"

@interface MenuProfileCell()
@property (weak, nonatomic) IBOutlet UIImageView *thumbImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *twitterHandle;


@end

@implementation MenuProfileCell

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
    
    self.backgroundColor = [UIColor colorWithRed:0.251 green:0.6 blue:1 alpha:1];
    
    self.userName.textColor = [UIColor whiteColor];
    self.twitterHandle.textColor = [UIColor whiteColor];
    
    [self.thumbImage setImageWithURL:[NSURL URLWithString:user.profileImageUrl]];
    
    self.userName.text = user.name;
    self.twitterHandle.text = [NSString stringWithFormat:@"@%@", user.screenName];
    
    
}

@end
