//
//  TwitterMenuViewController.m
//  Twitter
//
//  Created by Syed, Afzal on 2/28/15.
//  Copyright (c) 2015 afzalsyed. All rights reserved.
//

#import "TwitterMenuViewController.h"
#import "TweetsViewController.h"
#import "TwitterClient.h"
#import "ProfileViewController.h"
#import "MentionsViewController.h"
#import "User.h"
#import "ComposeTweetViewController.h"
#import "MenuProfileCell.h"

@interface TwitterMenuViewController ()<UITableViewDataSource, UITableViewDelegate, ComposeTweetViewControllerDelegate>
@property (strong, nonatomic) NSArray *viewControllers;
@property (strong,nonatomic) UIViewController *runningVC;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *contenView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewYConstraint;
@property (strong,nonatomic) NSArray *titlesArray;

@end

@implementation TwitterMenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    UIColor *myBlueColor = [UIColor colorWithRed:0.251 green:0.6 blue:1 alpha:1];
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    


    
    // Do any additional setup after loading the view from its nib.
    

    self.titlesArray = [[NSArray alloc]initWithObjects:@"Profile", @"Timeline", @"Mentions", nil];
    
    self.title = @"Timeline";
    self.navigationController.navigationBar.backgroundColor = myBlueColor;
    self.navigationController.navigationBar.barTintColor = myBlueColor;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onSignOutButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(onNewButton)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor whiteColor]];

    self.contentViewXConstraint.constant = 0;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = myBlueColor;
    //self.tableView.estimatedRowHeight = 105;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MenuProfileCell" bundle:nil] forCellReuseIdentifier:@"MenuProfileCell"];
    

    [self setupViewControllers];
    [self.tableView reloadData];
    
    
}

- (void)setupViewControllers {
    //Setting up timeline VC
    
    UIViewController *tvc = [[TweetsViewController alloc]init];
    UINavigationController *tnvc = [[UINavigationController alloc]initWithRootViewController:tvc];
    

    //Setting up profile View
    
    ProfileViewController *pvc = [[ProfileViewController alloc] init];
    UINavigationController *pnvc = [[UINavigationController alloc] initWithRootViewController:pvc];
    
    //Setting up mentions View
    
    MentionsViewController *mvc = [[MentionsViewController alloc] init];
    UINavigationController *mnvc = [[UINavigationController alloc] initWithRootViewController:mvc];
    
    self.viewControllers = [NSArray arrayWithObjects:pnvc, tnvc, mnvc, nil];
    
    // set timeline as the initial view
    self.runningVC = tnvc;
    
    [self addChildViewController:self.runningVC];
    self.runningVC.view.frame = self.contenView.bounds;
    [self.contenView addSubview:self.runningVC.view];
    [self.runningVC didMoveToParentViewController:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        self.title = self.titlesArray[indexPath.row];
        [self removeRunningViewController];
        self.runningVC = self.viewControllers[indexPath.row];
        [self showSelectedController];
        
    } else if (indexPath.row < 4) {
        self.title = self.titlesArray[indexPath.row-1];
        [self removeRunningViewController];
        self.runningVC = self.viewControllers[indexPath.row-1];
        [self showSelectedController];
        
    } else  {
        [User logout];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 130;
    } else {
        return 50;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    switch (indexPath.row) {
        case 0: {
            MenuProfileCell *Cell = [tableView dequeueReusableCellWithIdentifier:@"MenuProfileCell"];
            [Cell setUser:[User currentUser]];
            return Cell;
        }
        case 1:
            cell.textLabel.text = @"Profile";
            break;
        case 2:
            cell.textLabel.text = @"Timeline";
            break;
        case 3:
            cell.textLabel.text = @"Mentions";
            break;
        case 4:
            cell.textLabel.text = @"Logout";
            break;
    }
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor colorWithRed:0.251 green:0.6 blue:1 alpha:1];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNueve-Light" size:22];
    
    return cell;
    
}

// Adding Empty Footer
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}



- (void)showSelectedController {
    self.runningVC.view.frame = self.contenView.bounds;
    [self.contenView addSubview:self.runningVC.view];
    [self.runningVC didMoveToParentViewController:self];
    
    [UIView animateWithDuration:.30 animations:^{
        self.contentViewXConstraint.constant = 0;
        self.contentViewYConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (void) removeRunningViewController {
    [self.runningVC willMoveToParentViewController:nil];
    [self.runningVC.view removeFromSuperview];
    [self.runningVC removeFromParentViewController];
}

- (void) onSignOutButton {
    [User logout];
}

- (void) onNewButton {
    ComposeTweetViewController *ctvc = [[ComposeTweetViewController alloc] init];
    ctvc.delegate = self;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:ctvc];
    [self.navigationController presentViewController:nvc animated:YES completion:nil];
    
}



#pragma Mark Gesture methods

- (IBAction)onRightSwipe:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.contentViewXConstraint.constant = -self.view.frame.size.width + 160;
        [self.view layoutIfNeeded];
    }];
}
- (IBAction)onLeftSwipe:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.contentViewXConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark delegate methods
- (void)tweetedThisTweet:(Tweet *)tweet {
}

@end
