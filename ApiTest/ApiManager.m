//
//  ApiManager.m
//  ApiTest
//
//  Created by ios on 10/23/15.
//  Copyright © 2015 Brandon. All rights reserved.
//

#import "ApiManager.h"
#import "Constants.h"


@interface ApiManager ()

@property (strong, nonatomic) NSString *authToken;

@end

@implementation ApiManager

static ApiManager *sMyApi;

+ (ApiManager *)sharedManager
{
    static dispatch_once_t tokenToRunOnlyOnce;
    
    dispatch_once(&tokenToRunOnlyOnce, ^{
        sMyApi = [[ApiManager alloc]init];
    });
    return sMyApi;
}

/**
 * This is a convenience method that takes a url fragment like '/path/to/something'
 * and it makes an absolute url like 'http://myapi.com/path/to/something'
 * you can also add substitution values like this:
 * [self url:@"/my/path?auth%@", self.authToken], which produces 'http://myapi.com/my/path?auth=ABC123'
 */
- (NSString *)url:(NSString *)pathFormat, ... NS_FORMAT_FUNCTION(1, 2) {
    
    va_list args;
    va_start(args, pathFormat);
    pathFormat = [[NSString alloc] initWithFormat:pathFormat arguments:args];
    va_end(args);
    
    return [NSString stringWithFormat:@"%@%@", kserverBase, pathFormat];
}

#pragma mark CHALLENGE #1 - let's do this together with a projector

//This method takes the Username and Password passed to it and attempts to register a new user on a remote server
//If successful, it executes the completion block of the method call with an authToken
//If failure, it executes the failure block of the method call

- (void)registerNewUsername:(NSString *)username
               withPassword:(NSString *)password
                 completion:(void (^)(NSString *))completion
                    failure:(void (^)(void))failure
{
    //store username and password into a new NSMutabledictionary
    NSMutableDictionary *userDataDictionary = [[NSMutableDictionary alloc]init];
    [userDataDictionary setObject:username forKey:@"username"];
    [userDataDictionary setObject:password forKey:@"password"];
    
    NSError *error;
    //turn dictionary into a JSON object
    NSData *dataToPass = [NSJSONSerialization dataWithJSONObject:userDataDictionary options:0 error:&error];
    //if error bail
    if (error)
    {
        failure();
        return;
    }
    
    // set the url as specified in API documentation
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@/user", kserverBase]];
    
    // create a request to interact with server
    NSMutableURLRequest *request = [self setupRequest:YES withURL:url andData:dataToPass];
    
    // prepare to interact with server/API
    NSURLSession *urlSession = [NSURLSession sharedSession];

    // prepare what you want the server to do and how to react
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ([self dealWithError:error andResponse:response andData:data] == false)
        {
            failure();
        }
        else
        {
            NSString *authToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            self.authToken = authToken;

            completion(authToken);
            return;
        }
    }];
    
    // Attempt to connect to server
    [dataTask resume];
}

#pragma mark CHALLENGE #2 - with a partner
- (void)authenticateUser:(NSString *)username withPassword:(NSString *)password completion:(void (^)(NSString *))completion failure:(void (^)(void))failure {
    
    //store username and password into a new NSMutabledictionary
    NSMutableDictionary *userDataDictionary = [[NSMutableDictionary alloc]init];
    [userDataDictionary setObject:username forKey:@"username"];
    [userDataDictionary setObject:password forKey:@"password"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@&password=%@", kserverBase, kauthenticateUser, username, password]];
    
    NSMutableURLRequest *request = [self setupRequest:YES withURL:url andData:nil];
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ([self dealWithError:error andResponse:response andData:data] == false)
        {
            failure();
        }
        else
        {
            NSString *authToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            self.authToken = authToken;
            completion(self.authToken);
        }
    }];
    
    [dataTask resume];
}

#pragma mark CHALLENGE #3 - with a partner or on your own
- (void)fetchAllUserDataWithCompletion:(void (^)(NSArray<User *> *))completion failure:(void (^)(void))failure {
    // set the url as specified in API documentation
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", kserverBase, kfetchData, self.authToken]];
    
    NSMutableURLRequest *request = [self setupRequest:NO withURL:url andData:nil];
    
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ([self dealWithError:error andResponse:response andData:data] == false)
        {
            failure();
        }
        else
        {
            NSArray *userArray = [User usersFromData:data];
            completion(userArray);
        }
    }];
    
    [dataTask resume];
}

#pragma mark CHALLENGE #4 - with a partner or on your own
-(void)saveDevice:(Device *)device forUser:(User *)user completion:(void (^)(void))completion failure:(void (^)(void))failure {

    //store username and password into a new NSMutabledictionary
    NSMutableDictionary *userDataDictionary = [[NSMutableDictionary alloc]init];
    [userDataDictionary setObject:device.deviceType forKey:@"device_type"];
    [userDataDictionary setObject:device.iosVersion forKey:@"ios_version"];
    [userDataDictionary setObject:device.language forKey:@"language"];
    [userDataDictionary setObject:device.appVersion forKey:@"app_version"];
    
    NSError *error;
    NSData *dataToPass = [NSJSONSerialization dataWithJSONObject:userDataDictionary options:0 error:&error];
    //if error bail
    if (error)
    {
        failure();
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", kserverBase, ksaveServer, self.authToken]];
    
    NSMutableURLRequest *request = [self setupRequest:YES withURL:url andData:dataToPass];
    
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if ([self dealWithError:error andResponse:response andData:data] == false)
        {
            failure();
        }
        else
        {
            completion();
            return;
        }

    }];

    [dataTask resume];

}

- (BOOL)dealWithError:(NSError *)error andResponse:(NSURLResponse *)response andData:(NSData *)data
{
    // Error/Success code server with give you: (long)((NSHTTPURLResponse *)response).statusCode)
    if (!error)
    {
        NSLog(@"There was no error: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
        if ( ((NSHTTPURLResponse *)response).statusCode == 200 ) {
            return true;
        }
        else
        {
            return false;
        }
    }
    else
    {
        NSLog(@"There was an error: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
        return false;
    }
}

-(NSMutableURLRequest *)setupRequest:(BOOL)isPOST withURL:(NSURL *)url andData:(NSData *)dataToPass
{
    // create a request to interact with server
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    if (isPOST) {
        // set the HTTPMethod as specified in API documentation: POST = push/create, default = GET
        request.HTTPMethod = @"POST";
        
        // set the HTTPBody as specified in API documentation: JSON object from above
        request.HTTPBody = dataToPass;
        
        // set the header as specified in API documentation
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    return request;
}

-(BOOL)isAuthenticated {
    return self.authToken;
}

-(void)logout {
    self.authToken = @"";
    self.isAuthenticated = false;
}

@end
