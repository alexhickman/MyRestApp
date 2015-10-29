//
//  Challenge3ViewController.m
//  ApiTest
//
//  Created by ios on 10/23/15.
//  Copyright © 2015 Brandon. All rights reserved.
//

#import "AllUsersViewController.h"
#import "ApiManager.h"
#import "UserDetailViewController.h"

@interface AllUsersViewController ()

@property (strong, nonatomic) NSArray<User *> *model;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation AllUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    ApiManager *api = [ApiManager getInstance];
    
    if ([self checkLoggedIn]) {
        [api fetchAllUserDataWithCompletion:^(NSArray<User *> *userData){
            
            NSLog(@"got user data!");
            self.model = userData;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        } failure:^{
            NSLog(@"Failed to get user data");
        }];
    }
}

- (BOOL)checkLoggedIn {
    if (![ApiManager getInstance].isAuthenticated) {
        [self performSegueWithIdentifier:@"authenticate" sender:self];
        return NO;
    }
    
    return YES;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.model count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"userCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"userCell"];
    }
    
    User *user = self.model[indexPath.row];
    
    cell.textLabel.text = user.username;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Device: %@", user.deviceSummary];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"userDetail" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([@"userDetail" isEqualToString:segue.identifier]) {
        UserDetailViewController *vc = [segue destinationViewController];
        vc.user = self.model[self.selectedIndexPath.row];
    }
}

- (IBAction)logoutPressed:(id)sender {
    [[ApiManager getInstance] logout];
    //    [self checkLoggedIn];
    [self performSegueWithIdentifier:@"authenticate" sender:self];
}

- (IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
}

@end
