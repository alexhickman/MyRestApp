//
//  Challenge1ViewController.m
//  ApiTest
//
//  Created by ios on 10/23/15.
//  Copyright © 2015 Brandon. All rights reserved.
//

#import "AuthenticateViewController.h"
#import "ApiManager.h"

@interface AuthenticateViewController ()

@end

@implementation AuthenticateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonCreateUserPressed:(id)sender {
    
    [[ApiManager sharedManager] authenticateUser:self.textFieldUsername.text withPassword:self.textFieldPassword.text completion:^(NSString *authToken){
        
        NSLog(@"created auth token: %@", authToken);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"unwindWithAuthToken" sender:self];
        });
        
    } failure:^{
        
        NSLog(@"auth failed. bad credentials or user does not exist?");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.labelError.hidden = NO;
        });
        
    }];
}

@end
