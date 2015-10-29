//
//  RegisterUserViewController.m
//  ApiTest
//
//  Created by ios on 10/22/15.
//  Copyright © 2015 Brandon. All rights reserved.
//

#import "RegisterUserViewController.h"
#import "ApiManager.h"

@interface RegisterUserViewController ()

@end

@implementation RegisterUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)buttonPressedRegister:(id)sender {
    
    [[ApiManager sharedManager] registerNewUsername:self.textFieldUsername.text withPassword:self.textFieldPassword.text completion:^(NSString *authToken) {
        NSLog(@"Created new user, got auth token: %@", authToken);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"unwindWithAuthToken" sender:self];
        });
    } failure:^() {
        NSLog(@"oh no! unrecoverable error :(");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.labelError.hidden = NO;
        });
    }];
}

@end
