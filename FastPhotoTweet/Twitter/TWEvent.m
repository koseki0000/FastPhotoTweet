//
//  TWEvent.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/11.
//

#import "TWEvent.h"
#import "NSNotificationCenter+EasyPost.h"
#import "TWTweet.h"

#define API_VERSION @"1.1"

@implementation TWEvent

+ (void)favorite:(NSString *)tweetId accountIndex:(int)accountIndex {
    
    NSLog(@"Add Favorite");
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        
        if ( [TWAccounts selectAccount:accountIndex] != nil ) {
            
            //リクエストURLを指定
            NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/%@/favorites/create.json", API_VERSION];
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            //ID
            [params setObject:tweetId forKey:@"id"];
            
            //リクエストの作成
            TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL]
                                                         parameters:params
                                                      requestMethod:TWRequestMethodPOST];
            
            //リクエストにアカウントを設定
            [postRequest setAccount:[TWAccounts selectAccount:accountIndex]];
            
            [postRequest performRequestWithHandler:
             ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     NSNotification *statusBarNotification = [NSNotification notificationWithName:@"AddStatusBarTask"
                                                                                           object:self
                                                                                         userInfo:@{@"Task" : @"Favorited"}];
                     [[NSNotificationCenter defaultCenter] postNotification:statusBarNotification];
                     
                     [ActivityIndicator visible:NO];
                 });
             }];
        }
    });
}

+ (void)reTweet:(NSString *)tweetId accountIndex:(int)accountIndex {
    
    NSLog(@"ReTweet");
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        
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
                     
                     NSNotification *statusBarNotification = [NSNotification notificationWithName:@"AddStatusBarTask"
                                                                                           object:self
                                                                                         userInfo:@{@"Task" : @"ReTweeted"}];
                     [[NSNotificationCenter defaultCenter] postNotification:statusBarNotification];
                     
                     [ActivityIndicator visible:NO];
                 });
             }];
        }
    });
}

+ (void)favoriteReTweet:(NSString *)tweetId accountIndex:(int)accountIndex {
    
    [TWEvent favorite:tweetId accountIndex:accountIndex];
    [TWEvent reTweet:tweetId accountIndex:accountIndex];
}

+ (void)unFavorite:(NSString *)tweetId accountIndex:(int)accountIndex {
    
    NSLog(@"UnFavorite");
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
       
        if ( [TWAccounts selectAccount:accountIndex] != nil ) {
            
            //リクエストURLを指定
            NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/%@/favorites/destroy.json", API_VERSION];
            
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            //ID
            [params setObject:tweetId forKey:@"id"];
            
            //リクエストの作成
            TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL]
                                                         parameters:params
                                                      requestMethod:TWRequestMethodPOST];
            
            //リクエストにアカウントを設定
            [postRequest setAccount:[TWAccounts selectAccount:accountIndex]];
            
            [postRequest performRequestWithHandler:
             ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     NSNotification *statusBarNotification = [NSNotification notificationWithName:@"AddStatusBarTask"
                                                                                           object:self
                                                                                         userInfo:@{@"Task" : @"UnFavorited"}];
                     [[NSNotificationCenter defaultCenter] postNotification:statusBarNotification];
                     
                     [ActivityIndicator visible:NO];
                 });
             }];
        }
    });
}

+ (void)getProfile:(NSString *)screenName {
    
    NSLog(@"getProfile: %@", screenName);
    
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
             
             if ( responseData ) {
              
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     //レスポンスのデータをNSStringに変換後JSONをDictionaryに格納
                     NSString *responseDataString = [[NSString alloc] initWithData:responseData
                                                                          encoding:NSUTF8StringEncoding];
                     
                     if ( responseDataString != nil && ![responseDataString isEqualToString:@""] ) {
                         
                         if ( [responseDataString hasPrefix:@"{\"errors\""] ) {
                             
                             [NSNotificationCenter postNotificationCenterForName:@"APIError" withUserInfo:@{@"JSONData" : responseData}];
                             return;
                             
                         } else {
                             
                             NSDictionary *result = [responseDataString JSONValue];
                             
                             if ( result != nil ) {
                                 
                                 [resultProfile setObject:@"Success" forKey:@"Result"];
                                 [resultProfile setObject:result forKey:@"Profile"];
                                 
                             } else {
                                 
                                 [resultProfile setObject:@"Error" forKey:@"Result"];
                             }
                         }
                         
                     } else {
                         
                         [resultProfile setObject:@"Error" forKey:@"Result"];
                     }
                     
                     [[NSNotificationCenter defaultCenter] postNotification:notification];
                     
                     [ActivityIndicator visible:NO];
                 });
             }
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
                 
                 NSString *responseDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                 
                 if ( [responseDataString hasPrefix:@"{\"errors\""] ) {
                     
                     [NSNotificationCenter postNotificationCenterForName:@"APIError" withUserInfo:@{@"JSONData" : responseData}];
                     
                 } else {
                     
                     NSDictionary *result = [responseDataString JSONValue];
                     TWTweet *tweet = [TWTweet tweetWithDictionary:result];
                     
                     //NSLog(@"Tweet: %@", result);
                     
                     if ( result != nil ) {
                         
                         if ( [result objectForKey:@"error"] == nil ) {
                             
                             [resultProfile setObject:@"Success" forKey:@"Result"];
                             [resultProfile setObject:tweet forKey:@"Tweet"];
                             
                         } else {
                             
                             [ShowAlert error:[result objectForKey:@"error"]];
                             [resultProfile setObject:@"AuthorizeError" forKey:@"Result"];
                         }
                         
                     } else {
                         
                         [resultProfile setObject:@"Error" forKey:@"Result"];
                     }
                     
                     [[NSNotificationCenter defaultCenter] postNotification:notification];
                 }
                 
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
                 TWTweet *tweet = [TWTweet tweetWithDictionary:result];
                 
                 if ( result != nil ) {
                     
                     [resultDestroy setObject:@"Success" forKey:@"Result"];
                     [resultDestroy setObject:tweet forKey:@"Tweet"];
                     
                 } else {
                     
                     [resultDestroy setObject:@"Error" forKey:@"Result"];
                 }
                 
                 NSNotification *statusBarNotification = [NSNotification notificationWithName:@"AddStatusBarTask"
                                                                                       object:self
                                                                                     userInfo:@{@"Task" : @"Deleted"}];
                 [[NSNotificationCenter defaultCenter] postNotification:statusBarNotification];
                 
                 [[NSNotificationCenter defaultCenter] postNotification:notification];
                 
                 [ActivityIndicator visible:NO];
             });
         }];
    }
}

@end
