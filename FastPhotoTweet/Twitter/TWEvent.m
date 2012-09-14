//
//  TWEvent.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/11.
//

#import "TWEvent.h"

@implementation TWEvent

+ (void)favorite:(NSString *)tweetId {
    
    NSLog(@"Add Favorite");
    
    ACAccount *twAccount = [TWEvent canAction];
    
    if ( twAccount != nil ) {
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/1/favorites/create/%@.json", tweetId];
        
        //リクエストの作成
        TWRequest *postRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL] 
                                                      parameters:nil 
                                                   requestMethod:TWRequestMethodPOST] autorelease];
        
        //リクエストにアカウントを設定
        [postRequest setAccount:twAccount];
        
        [postRequest performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [ActivityIndicator visible:NO];
             });
         }];
    }
}

+ (void)reTweet:(NSString *)tweetId {
    
    NSLog(@"ReTweet");
    
    ACAccount *twAccount = [TWEvent canAction];
    
    if ( twAccount != nil ) {
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/1/statuses/retweet/%@.json", tweetId];
        
        //リクエストの作成
        TWRequest *postRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL] 
                                                      parameters:nil 
                                                   requestMethod:TWRequestMethodPOST] autorelease];
        
        //リクエストにアカウントを設定
        [postRequest setAccount:twAccount];
        
        [postRequest performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                                  
                 [ActivityIndicator visible:NO];
             });
         }];
    }
}

+ (void)favoriteReTweet:(NSString *)tweetId {
    
    [TWEvent favorite:tweetId];
    [TWEvent reTweet:tweetId];
}

+ (void)unFavorite:(NSString *)tweetId {
    
    NSLog(@"UnFavorite");
    
    ACAccount *twAccount = [TWEvent canAction];
    
    if ( twAccount != nil ) {
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/1/favorites/destroy/%@.json", tweetId];
        
        //リクエストの作成
        TWRequest *postRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL] 
                                                      parameters:nil 
                                                   requestMethod:TWRequestMethodPOST] autorelease];
        
        //リクエストにアカウントを設定
        [postRequest setAccount:twAccount];
        
        [postRequest performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [ActivityIndicator visible:NO];
             });
         }];
    }
}

+ (void)getProfile:(NSString *)screenName {
    
    NSLog(@"getProfile");
    
    ACAccount *twAccount = [TWEvent canAction];
    
    if ( twAccount != nil ) {
        
        //ステータスバーに処理中表示
        [ActivityIndicator visible:YES];
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/1/users/show.json?screen_name=%@&include_entities=true", screenName];
        
        //リクエストの作成
        TWRequest *postRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL] 
                                                      parameters:nil 
                                                   requestMethod:TWRequestMethodGET] autorelease];
        
        //リクエストにアカウントを設定
        [postRequest setAccount:twAccount];
        
        //投稿結果通知を作成
        NSMutableDictionary *resultProfile = [NSMutableDictionary dictionary];
        NSNotification *notification =[NSNotification notificationWithName:@"GetProfile" 
                                                                    object:self 
                                                                  userInfo:resultProfile];
        
        [postRequest performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 //レスポンスのデータをNSStringに変換後JSONをDictionaryに格納
                 NSString *responseDataString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
                 
                 if ( responseDataString != nil && ![responseDataString isEqualToString:@""] ) {
                     
                     NSDictionary *result = [responseDataString JSONValue];
                     
                     if ( result != nil ) {
                         
                         [resultProfile setObject:@"Success" forKey:@"Result"];
                         [resultProfile setObject:result forKey:@"Profile"];
                         
                     }else {
                         
                         [resultProfile setObject:@"Error" forKey:@"Result"];
                     }
                     
                 }else {
                     
                     [resultProfile setObject:@"Error" forKey:@"Result"];
                 }
                 
                 [[NSNotificationCenter defaultCenter] postNotification:notification];
                 
                 [ActivityIndicator visible:NO];
             });
         }];
    }
}

+ (void)getTweet:(NSString *)tweetId {
    
    NSLog(@"getTweet");
    
    ACAccount *twAccount = [TWEvent canAction];
    
    if ( twAccount != nil ) {
     
        //ステータスバーに処理中表示
        [ActivityIndicator visible:YES];
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/1/statuses/show.json?id=%@&include_entities=true", tweetId];
        
        //リクエストの作成
        TWRequest *postRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL] 
                                                      parameters:nil 
                                                   requestMethod:TWRequestMethodGET] autorelease];
        
        //リクエストにアカウントを設定
        [postRequest setAccount:twAccount];
        
        //投稿結果通知を作成
        NSMutableDictionary *resultProfile = [NSMutableDictionary dictionary];
        NSNotification *notification =[NSNotification notificationWithName:@"GetTweet" 
                                                                    object:self 
                                                                  userInfo:resultProfile];
        
        [postRequest performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 //レスポンスのデータをNSStringに変換後JSONをDictionaryに格納
                 NSString *responseDataString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
                 NSDictionary *result = [responseDataString JSONValue];
                 
                 //NSLog(@"Tweet: %@", result);
                 
                 if ( result != nil ) {
                     
                     if ( [result objectForKey:@"error"] == nil ) {
                     
                         [resultProfile setObject:@"Success" forKey:@"Result"];
                         [resultProfile setObject:result forKey:@"Tweet"];
                         
                     }else {
                         
                         [ShowAlert error:[result objectForKey:@"error"]];
                         [resultProfile setObject:@"AuthorizeError" forKey:@"Result"];
                     }
                     
                 }else {
                     
                     [resultProfile setObject:@"Error" forKey:@"Result"];
                 }
                 
                 [[NSNotificationCenter defaultCenter] postNotification:notification];
                 
                 [ActivityIndicator visible:NO];
             });
         }];
    }
}

+ (void)destroy:(NSString *)tweetId {
    
    NSLog(@"destroy");
    
    ACAccount *twAccount = [TWEvent canAction];
    
    if ( twAccount != nil ) {
        
        //ステータスバーに処理中表示
        [ActivityIndicator visible:YES];
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/1/statuses/destroy/%@.json", tweetId];
        
        //リクエストの作成
        TWRequest *postRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL] 
                                                      parameters:nil 
                                                   requestMethod:TWRequestMethodPOST] autorelease];
        
        //リクエストにアカウントを設定
        [postRequest setAccount:twAccount];
        
        //投稿結果通知を作成
        NSMutableDictionary *resultDestroy = [NSMutableDictionary dictionary];
        NSNotification *notification =[NSNotification notificationWithName:@"Destroy" 
                                                                    object:self 
                                                                  userInfo:resultDestroy];
        [postRequest performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 //レスポンスのデータをNSStringに変換後JSONをDictionaryに格納
                 NSString *responseDataString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
                 NSDictionary *result = [responseDataString JSONValue];
                 
                 //NSLog(@"result: %@", result);
                 
                 if ( result != nil ) {
                     
                     [resultDestroy setObject:@"Success" forKey:@"Result"];
                     [resultDestroy setObject:result forKey:@"Tweet"];
                     
                 }else {
                     
                     [resultDestroy setObject:@"Error" forKey:@"Result"];
                 }
                 
                 [[NSNotificationCenter defaultCenter] postNotification:notification];
                 
                 [ActivityIndicator visible:NO];
             });
         }];
    }
}

+ (ACAccount *)canAction {
    
    ACAccount *twAccount = [TWGetAccount currentAccount];
    
    if ( [TWTweetComposeViewController canSendTweet] && [TWGetAccount currentAccount] != nil ) {
        
        return twAccount;
    }
    
    return nil;
}

@end
