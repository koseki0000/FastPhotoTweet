//
//  TWSendTweet.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "TWSendTweet.h"

@implementation TWSendTweet

+ (void)post:(NSString *)postText twAccount:(ACAccount *)twAccount {
    
    NSDictionary *tParam = [NSDictionary dictionaryWithObject:postText forKey:@"status"];
    NSURL *tURL = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
    TWRequest *updateProfile = [[TWRequest alloc] initWithURL:tURL parameters:tParam
                                                requestMethod:TWRequestMethodPOST];
    
    //Twitterアカウントの確認
    if (twAccount == nil) {
        
        NSLog(@"Can’t post");
        
        return;
    }
    
    updateProfile.account = twAccount;
    
    TWRequestHandler requestHandler = ^(NSData *responseData, 
                                        NSHTTPURLResponse *urlResponse, 
                                        NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //NSString *responseDataString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
            //NSLog(@"Response: %@", responseDataString);
            
            if (error != nil) {
                NSLog(@"Post Error");
            } else {
                NSLog(@"Post Success");
            }
            
            [ActivityIndicator activityIndicatorVisible:NO];
        });
    };
    
    [updateProfile performRequestWithHandler:requestHandler];
    [ActivityIndicator activityIndicatorVisible:YES];
    NSLog(@"Post sended");
}

@end
