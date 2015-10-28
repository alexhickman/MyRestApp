//
//  ApiManager.m
//  ApiTest
//
//  Created by ios on 10/23/15.
//  Copyright © 2015 Brandon. All rights reserved.
//

#import "ApiManager.h"

NSString *SERVER_API_BASE_URL = @"http://localhost:5000";

@interface ApiManager ()

@property (readonly, strong, nonatomic) NSString *serverBase;
@property (strong, nonatomic) NSString *authToken;

@end

@implementation ApiManager

+(instancetype)getInstance {
    // the 'static' keyword causes this line to only be executed once, ever.
    static ApiManager *instance = nil;
    
    // what is this doing?
    if (!instance) {
        NSLog(@"initializing ApiManager");
        instance = [[ApiManager alloc] initWithServerBase:SERVER_API_BASE_URL];
    }
    
    return instance;
}

- (instancetype)initWithServerBase:(NSString *)serverBase {
    self = [self init];
    
    _serverBase = serverBase;
    
    return self;
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
    
    return [NSString stringWithFormat:@"%@%@", self.serverBase, pathFormat];
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
    NSURL *url = [NSURL URLWithString:@"http://104.236.231.254:5000/user"];
    
    // create a request to interact with server
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // set the HTTPMethod as specified in API documentation: POST = push/create
    request.HTTPMethod = @"POST";
    
    // set the HTTPBody as specified in API documentation: JSON object from above
    request.HTTPBody = dataToPass;
    
    // set the header as specified in API documentation
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // prepare to interact with server/API
    NSURLSession *urlSession = [NSURLSession sharedSession];

    // prepare what you want the server to do and how to react
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // Error/Success code server with give you: (long)((NSHTTPURLResponse *)response).statusCode)
        
        if (!error) {
            if ( ((NSHTTPURLResponse *)response).statusCode == 200 ) {
                NSString *authToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                self.authToken = authToken;
                completion(authToken);
            }
            else
            {
                failure();
            }
        }
        else
        {
            NSLog(@"There was an error: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
            failure();
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
    
    // set the url as specified in API documentation
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://104.236.231.254:5000/auth?username=%@&password=%@", username, password]];
    
    // create a request to interact with server
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // set the HTTPMethod as specified in API documentation: POST = push/create
    request.HTTPMethod = @"POST";
    
    // set the header as specified in API documentation
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // prepare to interact with server/API
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    // prepare what you want the server to do and how to react
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // Error/Success code server with give you: (long)((NSHTTPURLResponse *)response).statusCode)
        
        if (!error) {
            NSLog(@"There was no error: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
            if ( ((NSHTTPURLResponse *)response).statusCode == 200 ) {
                NSString *authToken = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                self.authToken = authToken;
                completion(authToken);
            }
            else
            {
                failure();
            }
        }
        else
        {
            NSLog(@"There was an error: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
            failure();
        }
    }];
    
    // Attempt to connect to server
    [dataTask resume];
    
}

#pragma mark CHALLENGE #3 - with a partner or on your own
- (void)fetchAllUserDataWithCompletion:(void (^)(NSArray<User *> *))completion failure:(void (^)(void))failure {
    // set the url as specified in API documentation
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://104.236.231.254:5000/user?auth=%@", self.authToken]];
    
    // create a request to interact with server
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // set the HTTPMethod as specified in API documentation: POST = push/create
    request.HTTPMethod = @"GET";
    
    // prepare to interact with server/API
    NSURLSession *urlSession = [NSURLSession sharedSession];
    
    // prepare what you want the server to do and how to react
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        // Error/Success code server with give you: (long)((NSHTTPURLResponse *)response).statusCode)
        
        if (!error) {
            NSLog(@"There was no error: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
            if ( ((NSHTTPURLResponse *)response).statusCode == 200 ) {
                NSArray *userArray = [User usersFromData:data];
                completion(userArray);
            }
            else
            {
                failure();
            }
        }
        else
        {
            NSLog(@"There was an error: %ld", (long)((NSHTTPURLResponse *)response).statusCode);
            failure();
        }
    }];
    
    // Attempt to connect to server
    [dataTask resume];
}

#pragma mark CHALLENGE #4 - with a partner or on your own
-(void)saveDevice:(Device *)device forUser:(User *)user completion:(void (^)(void))completion failure:(void (^)(void))failure {
    
}

-(BOOL)isAuthenticated {
    return self.authToken;
}

/**
 * BONUS CHALLENGES...
 *
 * Below here you'll find methods that will flesh out this API Manager
 * even more. Pick and choose which you're interested in and ask for help...
 * Heads up! These have actually not been implemented as any prep for this
 * exercise, so you're probably the first one doing these!
 */

-(void)logout {
    NSLog(@"Hi! Does anybody want to implement ApiManager.logout ;)");
    
    // what should this method do?
    
    // How do we DELETE an auth token from the API?
    
    // What if ApiManager simply 'forgets' its auth token?
    
    // What do you think this method should really do?
}

@end
