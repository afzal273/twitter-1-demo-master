//
//  LoginViewController.m
//  Twitter
//
//  Created by Syed, Afzal on 2/16/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//



#import "LoginViewController.h"
#import "TwitterClient.h"
#import "TweetsViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LoginViewController

- (IBAction)onLogin:(id)sender {
    
    [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
        if (user != nil) {
            // Modally present tweets view
            NSLog(@"Welcome to %@", user.name);
            
            [User currentUser];
            [self presentViewController:[[TweetsViewController alloc]init] animated:YES completion:nil];
            
        } else {
            //present error view
        }
        
    }];
     
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    

    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    UIColor *myBlueColor = [UIColor colorWithRed:0.251 green:0.6 blue:1 alpha:1];
    
    self.title = @"Login";
    self.navigationController.navigationBar.backgroundColor = myBlueColor;
    self.navigationController.navigationBar.barTintColor = myBlueColor;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
