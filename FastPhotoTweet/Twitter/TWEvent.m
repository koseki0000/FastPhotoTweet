//
//  TWEvent.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/11.
//

#import "TWEvent.h"

#define API_VERSION @"1"

@implementation TWEvent

+ (void)favorite:(NSString *)tweetId accountIndex:(int)accountIndex {
    
    NSLog(@"Add Favorite");
    
    if ( [TWAccounts selectAccount:accountIndex] != nil ) {
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/%@/favorites/create/%@.json", API_VERSION, tweetId];
        
        //リクエストの作成
        TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL]
                                                      parameters:nil 
                                                   requestMethod:TWRequestMethodPOST];
        
        //リクエストにアカウントを設定
        [postRequest setAccount:[TWAccounts selectAccount:accountIndex]];
        
        [postRequest performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [ActivityIndicator visible:NO];
             });
         }];
    }
}

+ (void)reTweet:(NSString *)tweetId accountIndex:(int)accountIndex {
    
    NSLog(@"ReTweet");
    
    if ( [TWAccounts selectAccount:accountIndex] != nil ) {
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/retweet/%@.json",API_VERSION , tweetId];
        
        //リクエストの作成
        TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL]
                                                      parameters:nil 
                                                   requestMethod:TWRequestMethodPOST];
        
        //リクエストにアカウントを設定
        [postRequest setAccount:[TWAccounts selectAccount:accountIndex]];
        
        [postRequest performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                                  
                 [ActivityIndicator visible:NO];
             });
         }];
    }
}

+ (void)favoriteReTweet:(NSString *)tweetId accountIndex:(int)accountIndex {
    
    [TWEvent favorite:tweetId accountIndex:accountIndex];
    [TWEvent reTweet:tweetId accountIndex:accountIndex];
}

+ (void)unFavorite:(NSString *)tweetId accountIndex:(int)accountIndex {
    
    NSLog(@"UnFavorite");
    
    if ( [TWAccounts selectAccount:accountIndex] != nil ) {
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/%@/favorites/destroy/%@.json", API_VERSION, tweetId];
        
        //リクエストの作成
        TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL]
                                                      parameters:nil 
                                                   requestMethod:TWRequestMethodPOST];
        
        //リクエストにアカウントを設定
        [postRequest setAccount:[TWAccounts selectAccount:accountIndex]];
        
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
    
    if ( [TWAccounts currentAccount] != nil ) {
        
        //ステータスバーに処理中表示
        [ActivityIndicator visible:YES];
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/%@/users/show.json?screen_name=%@&include_entities=true",API_VERSION , screenName];
        
        //リクエストの作成
        TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL]
                                                      parameters:nil 
                                                   requestMethod:TWRequestMethodGET];
        
        //リクエストにアカウントを設定
        [postRequest setAccount:[TWAccounts currentAccount]];
        
        //投稿結果通知を作成
        NSMutableDictionary *resultProfile = [NSMutableDictionary dictionary];
        NSNotification *notification =[NSNotification notificationWithName:@"GetProfile" 
                                                                    object:self 
                                                                  userInfo:resultProfile];
        
        [postRequest performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 //レスポンスのデータをNSStringに変換後JSONをDictionaryに格納
                 NSString *responseDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                 
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
    
    if ( [TWAccounts currentAccount] != nil ) {
     
        //ステータスバーに処理中表示
        [ActivityIndicator visible:YES];
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/show.json?id=%@&include_entities=true", API_VERSION, tweetId];
        
        //リクエストの作成
        TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL]
                                                      parameters:nil 
                                                   requestMethod:TWRequestMethodGET];
        
        //リクエストにアカウントを設定
        [postRequest setAccount:[TWAccounts currentAccount]];
        
        //投稿結果通知を作成
        NSMutableDictionary *resultProfile = [NSMutableDictionary dictionary];
        NSNotification *notification =[NSNotification notificationWithName:@"GetTweet" 
                                                                    object:self 
                                                                  userInfo:resultProfile];
        
        [postRequest performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 //レスポンスのデータをNSStringに変換後JSONをDictionaryに格納
                 NSString *responseDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
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
    
    if ( [TWAccounts currentAccount] != nil ) {
        
        //ステータスバーに処理中表示
        [ActivityIndicator visible:YES];
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/destroy/%@.json", API_VERSION, tweetId];
        
        //リクエストの作成
        TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL]
                                                      parameters:nil
                                                   requestMethod:TWRequestMethodPOST];
        
        //リクエストにアカウントを設定
        [postRequest setAccount:[TWAccounts currentAccount]];
        
        //投稿結果通知を作成
        NSMutableDictionary *resultDestroy = [NSMutableDictionary dictionary];
        NSNotification *notification =[NSNotification notificationWithName:@"Destroy" 
                                                                    object:self 
                                                                  userInfo:resultDestroy];
        [postRequest performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 //レスポンスのデータをNSStringに変換後JSONをDictionaryに格納
                 NSString *responseDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
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

@end
