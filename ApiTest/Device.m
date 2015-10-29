//
//  Device.m
//  ApiTest
//
//  Created by ios on 10/23/15.
//  Copyright © 2015 Brandon. All rights reserved.
//

#import "Device.h"

@implementation Device

-(instancetype)initWithJSON:(NSDictionary *)dict {
    self = [self init];
    
    _deviceType = [dict objectForKey:@"device_type"];
    _iosVersion = [dict objectForKey:@"ios_version"];
    _language = [dict objectForKey:@"language"];
    _appVersion = [dict objectForKey:@"app_version"];
    
    return self;
}

- (instancetype)initWithType:(NSString *)deviceType withIosVersion:(NSString *)iosVersion withLanguage:(NSString *)language withAppVersion:(NSString *)appVersion {
    self = [self init];
    
    _deviceType = deviceType;
    _iosVersion = iosVersion;
    _language = language;
    _appVersion = appVersion;
    
    return self;
}


+(Device *)currentDeviceInfo {

    Device *newDevice = [[Device alloc]initWithType:@"poop" withIosVersion:@"iOS 9" withLanguage:@"English" withAppVersion:@"1.43yup"];
    
    return newDevice;
}

@end
