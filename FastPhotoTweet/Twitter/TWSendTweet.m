//
//  TWSendTweet.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "TWSendTweet.h"

@implementation TWSendTweet


+ (void)post:(NSArray *)postData {
    
    NSString *postText = [postData objectAtIndex:0];
    ACAccount *twAccount = [postData objectAtIndex:1];
    
    NSDictionary *tParam = [NSDictionary dictionaryWithObject:postText forKey:@"status"];
    NSURL *tURL = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/update.json"];
    TWRequest *updateProfile = [[TWRequest alloc] initWithURL:tURL parameters:tParam
                                                requestMethod:TWRequestMethodPOST];
    
    //Twitterアカウントの確認
    if (twAccount == nil) {
        
        ShowAlert *alert = [[ShowAlert alloc] init];
        [alert error:@"Can’t post"];
        
        return;
    }
    
    updateProfile.account = twAccount;
    
    TWRequestHandler requestHandler = ^(NSData *responseData, 
                                        NSHTTPURLResponse *urlResponse, 
                                        NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
                        
            if (error != nil) {
            
                NSString *responseDataString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
                
                ShowAlert *alert = [[ShowAlert alloc] init];
                [alert error:@"Post Error"];
                
                NSLog(@"Post Error: %@", responseDataString);
                
            } else {
                
                //JSONからDictionaryを生成
                NSString *responseDataString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
                NSDictionary *result = [responseDataString JSONValue];
                
                //Postしたテキスト
                NSString *text = [result objectForKey:@"text"];
                
                if ( [text isEqualToString:@""] || text == nil ) {
                    
                    NSLog(@"Post Error");
                    
                    //textが空の場合は失敗してる
                    ShowAlert *alert = [[ShowAlert alloc] init];
                    [alert error:@"Post Error"];
                    
                }else {
                    
                    NSLog(@"Post Success");
                    
                    ShowAlert *alert = [[ShowAlert alloc] init];
                    [alert title:@"Success" message:text];
                    
                }
                
            }
            
            [ActivityIndicator activityIndicatorVisible:NO];
        });
    };
    
    [updateProfile performRequestWithHandler:requestHandler];
    [ActivityIndicator activityIndicatorVisible:YES];
    
    NSLog(@"Post sended");
}

@end
