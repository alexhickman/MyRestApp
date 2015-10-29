//
//  UserDetailViewController.m
//  ApiTest
//
//  Created by ios on 10/23/15.
//  Copyright © 2015 Brandon. All rights reserved.
//

#import "UserDetailViewController.h"
#import "ApiManager.h"

@interface UserDetailViewController ()

@end

@implementation UserDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@'s Device", self.user.username];
    
    Device *device = self.user.device;
    
    BOOL editable = !device;
    
    [self setupTextField:self.textFieldDeviceType withText:device.deviceType editable:editable];
    [self setupTextField:self.textFieldiosVersion withText:device.iosVersion editable:editable];
    [self setupTextField:self.textFieldLanguage withText:device.language editable:editable];
    [self setupTextField:self.textFieldAppVersion withText:device.appVersion editable:editable];
    
    self.buttonPopulateDeviceInfo.hidden = !editable;
    self.buttonSaveDeviceInfo.hidden = !editable;
}

- (void)setupTextField:(UITextField *)textField withText:(NSString *)text editable:(BOOL)editable {
    textField.text = text;
    textField.enabled = editable;
    textField.borderStyle = editable? UITextBorderStyleRoundedRect : UITextBorderStyleNone;
}

- (IBAction)buttonPressedPopulateDeviceInfo:(id)sender {
    Device *device = [Device currentDeviceInfo];
    
    [self setupTextField:self.textFieldDeviceType withText:device.deviceType editable:YES];
    [self setupTextField:self.textFieldiosVersion withText:device.iosVersion editable:YES];
    [self setupTextField:self.textFieldLanguage withText:device.language editable:YES];
    [self setupTextField:self.textFieldAppVersion withText:device.appVersion editable:YES];
    
}
- (IBAction)buttonSaveDevicePressed:(id)sender {
    
    Device *device = [[Device alloc] initWithType:self.textFieldDeviceType.text
                                   withIosVersion:self.textFieldiosVersion.text
                                     withLanguage:self.textFieldLanguage.text
                                   withAppVersion:self.textFieldAppVersion.text];
    
    [[ApiManager sharedManager] saveDevice:device forUser:self.user completion:^{
        self.labelStatusMessage.textColor = [UIColor blueColor];
        self.labelStatusMessage.text = @"Device Saved!";
        self.labelStatusMessage.hidden = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupTextField:self.textFieldDeviceType withText:device.deviceType editable:NO];
            [self setupTextField:self.textFieldiosVersion withText:device.iosVersion editable:NO];
            [self setupTextField:self.textFieldLanguage withText:device.language editable:NO];
            [self setupTextField:self.textFieldAppVersion withText:device.appVersion editable:NO];
            
            self.buttonPopulateDeviceInfo.hidden = YES;
            self.buttonSaveDeviceInfo.hidden = YES;
        });
        
    } failure:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.labelStatusMessage.textColor = [UIColor redColor];
            self.labelStatusMessage.text = @"Error Saving Device";
            self.labelStatusMessage.hidden = NO;
        });
    }];
}
@end
