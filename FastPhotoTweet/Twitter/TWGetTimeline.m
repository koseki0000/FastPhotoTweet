//
//  TWGetTimeline.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import "TWGetTimeline.h"

#define BLANK @""

@implementation TWGetTimeline

+ (void)homeTimeline {
    
    //アカウントの取得
    ACAccount *twAccount = [TWGetAccount currentAccount];
    
    //NSLog(@"homeTimeline: %@", twAccount.username);
    
    //Twitterアカウントの確認
    if ( twAccount == nil ) {
        
        //アカウントデータが空
        [ShowAlert error:@"アカウントが取得できませんでした。"];
        
        return;
    }
    
    //インターネット未接続
    if ( ![TWGetTimeline reachability] ) return;
    
    [ActivityIndicator on];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //タイムライン取得リクエストURL作成
    NSURL *reqUrl = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/home_timeline.json"];
    
    //リクエストパラメータを作成
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    //取得数
    [params setObject:@"60" forKey:@"count"];
    //エンティティの有効化
    [params setObject:@"1" forKey:@"include_entities"];
    //RT表示
    [params setObject:@"1" forKey:@"include_rts"];
    
    //差分取得
    if ( ![appDelegate.sinceId isEqualToString:BLANK] ) {
     
        [params setObject:appDelegate.sinceId forKey:@"since_id"];
    }
    
    //リクエストを作成
    TWRequest *request = [[[TWRequest alloc] initWithURL:reqUrl
                                             parameters:params
                                          requestMethod:TWRequestMethodGET] autorelease];
    
    //リクエストにアカウントを設定
    [request setAccount:twAccount];
    
    //Timeline取得結果通知を作成
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSNotification *notification =[NSNotification notificationWithName:@"GetTimeline" 
                                                                    object:self 
                                                                  userInfo:result];
    
    [request performRequestWithHandler:
     ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             if ( responseData ) {
                 
                 NSError *jsonError = nil;
                 NSMutableArray *timeline = (NSMutableArray *)[NSJSONSerialization JSONObjectWithData:responseData
                                                                                              options:NSJSONReadingMutableLeaves 
                                                                                                error:&jsonError];

                 [result setObject:twAccount.username forKey:@"Account"];
                 
                 if ( timeline != nil ) {
                 
                     //取得完了を通知
                     [result setObject:@"TimelineSuccess" forKey:@"Result"];
                     [result setObject:timeline forKey:@"Timeline"];
                     
                 }else {
                     
                     [result setObject:@"TimelineError" forKey:@"Result"];
                 }
                 
                 //通知を実行
                 [[NSNotificationCenter defaultCenter] postNotification:notification];
                 
                 [ActivityIndicator off];
             }
         });
     }];
    
    //NSLog(@"Timeline request sended");
}

+ (void)userTimeline:(NSString *)screenName {
    
    //アカウントの取得
    ACAccount *twAccount = [TWGetAccount currentAccount];
    
    //NSLog(@"homeTimeline: %@", twAccount.username);
    
    //Twitterアカウントの確認
    if ( twAccount == nil ) {
        
        //アカウントデータが空
        [ShowAlert error:@"アカウントが取得できませんでした。"];
        
        return;
    }
    
    //インターネット未接続
    if ( ![TWGetTimeline reachability] ) return;
    
    [ActivityIndicator on];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //タイムライン取得リクエストURL作成
    NSURL *reqUrl = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/user_timeline.json"];
    
    //リクエストパラメータを作成
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    //表示するユーザー
    [params setObject:screenName forKey:@"screen_name"];
    //取得数
    [params setObject:@"60" forKey:@"count"];
    //エンティティの有効化
    [params setObject:@"1" forKey:@"include_entities"];
    //RT表示
    [params setObject:@"1" forKey:@"include_rts"];
    
    //差分取得
    if ( ![appDelegate.sinceId isEqualToString:BLANK] ) {
        
        [params setObject:appDelegate.sinceId forKey:@"since_id"];
    }
    
    //リクエストを作成
    TWRequest *request = [[[TWRequest alloc] initWithURL:reqUrl
                                              parameters:params
                                           requestMethod:TWRequestMethodGET] autorelease];
    
    //リクエストにアカウントを設定
    [request setAccount:twAccount];
    
    //Timeline取得結果通知を作成
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSNotification *notification =[NSNotification notificationWithName:@"GetUserTimeline"
                                                                object:self
                                                              userInfo:result];
    
    [request performRequestWithHandler:
     ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             if ( responseData ) {
                 
                 NSError *jsonError = nil;
                 NSMutableArray *timeline = (NSMutableArray *)[NSJSONSerialization JSONObjectWithData:responseData
                                                                                              options:NSJSONReadingMutableLeaves
                                                                                                error:&jsonError];
                 
                 [result setObject:twAccount.username forKey:@"Account"];
                 
                 if ( timeline != nil ) {
                     
                     //取得完了を通知
                     [result setObject:@"UserTimelineSuccess" forKey:@"Result"];
                     [result setObject:timeline forKey:@"UserTimeline"];
                     
                 }else {
                     
                     [result setObject:@"UserTimelineError" forKey:@"Result"];
                 }
                 
                 //通知を実行
                 [[NSNotificationCenter defaultCenter] postNotification:notification];
                 
                 [ActivityIndicator off];
             }
         });
     }];
    
    //NSLog(@"UserTimeline request sended");
}

+ (void)mentions {
    
    //アカウントの取得
    ACAccount *twAccount = [TWGetAccount currentAccount];
    //NSLog(@"mentions: %@", twAccount.username);
    
    //Twitterアカウントの確認
    if ( twAccount == nil ) {
        
        //アカウントデータが空
        [ShowAlert error:@"アカウントが取得できませんでした。"];
        
        return;
    }
    
    //インターネット未接続
    if ( ![TWGetTimeline reachability] ) return;
    
    [ActivityIndicator on];
    
    //タイムライン取得リクエストURL作成
    NSURL *reqUrl = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/mentions.json"];
    
    //リクエストパラメータを作成
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    //取得数
    [params setObject:@"40" forKey:@"count"];
    //エンティティの有効化
    [params setObject:@"1" forKey:@"include_entities"];
    
    //リクエストを作成
    TWRequest *request = [[[TWRequest alloc] initWithURL:reqUrl
                                              parameters:params
                                           requestMethod:TWRequestMethodGET] autorelease];
    
    //リクエストにアカウントを設定
    [request setAccount:twAccount];
    
    //Mentions取得結果通知を作成
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSNotification *notification =[NSNotification notificationWithName:@"GetMentions" 
                                                                object:self 
                                                              userInfo:result];
    
    [request performRequestWithHandler:
     ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             if ( responseData ) {
                 
                 NSError *jsonError = nil;
                 NSMutableArray *mentions = (NSMutableArray *)[NSJSONSerialization JSONObjectWithData:responseData
                                                                                              options:NSJSONReadingMutableLeaves 
                                                                                                error:&jsonError];
                 
                 //取得完了を通知
                 [result setObject:@"MentionsSuccess" forKey:@"Result"];
                 [result setObject:mentions forKey:@"Mentions"];
                 
                 //通知を実行
                 [[NSNotificationCenter defaultCenter] postNotification:notification];
                 
                 [ActivityIndicator off];
             }
         });
     }];
    
    //NSLog(@"Mentions request sended");
}

+ (void)favotites {
    
    //アカウントの取得
    ACAccount *twAccount = [TWGetAccount currentAccount];
    //NSLog(@"mentions: %@", twAccount.username);
    
    //Twitterアカウントの確認
    if ( twAccount == nil ) {
        
        //アカウントデータが空
        [ShowAlert error:@"アカウントが取得できませんでした。"];
        
        return;
    }
    
    //インターネット未接続
    if ( ![TWGetTimeline reachability] ) return;
    
    [ActivityIndicator on];
    
    //タイムライン取得リクエストURL作成
    NSURL *reqUrl = [NSURL URLWithString:@"https://api.twitter.com/1/favorites.json"];
    
    //リクエストパラメータを作成
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    //取得数
    [params setObject:@"40" forKey:@"count"];
    //エンティティの有効化
    [params setObject:@"1" forKey:@"include_entities"];
    
    //リクエストを作成
    TWRequest *request = [[[TWRequest alloc] initWithURL:reqUrl
                                              parameters:params
                                           requestMethod:TWRequestMethodGET] autorelease];
    
    //リクエストにアカウントを設定
    [request setAccount:twAccount];
    
    //Mentions取得結果通知を作成
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSNotification *notification =[NSNotification notificationWithName:@"GetFavorites" 
                                                                object:self 
                                                              userInfo:result];
    
    [request performRequestWithHandler:
     ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             if ( responseData ) {
                 
                 NSError *jsonError = nil;
                 NSMutableArray *favorites = (NSMutableArray *)[NSJSONSerialization JSONObjectWithData:responseData
                                                                                              options:NSJSONReadingMutableLeaves 
                                                                                                error:&jsonError];
                 
                 //取得完了を通知
                 [result setObject:@"FavoritesSuccess" forKey:@"Result"];
                 [result setObject:favorites forKey:@"Favorites"];
                 
                 //通知を実行
                 [[NSNotificationCenter defaultCenter] postNotification:notification];
                 
                 [ActivityIndicator off];
             }
         });
     }];
    
    //NSLog(@"Favorites request sended");
}

+ (void)twitterSearch:(NSString *)searchWord {
    
    //アカウントの取得
    ACAccount *twAccount = [TWGetAccount currentAccount];
    //NSLog(@"mentions: %@", twAccount.username);
    
    //Twitterアカウントの確認
    if ( twAccount == nil ) {
        
        //アカウントデータが空
        [ShowAlert error:@"アカウントが取得できませんでした。"];
        
        return;
    }
    
    //インターネット未接続
    if ( ![TWGetTimeline reachability] ) return;
    
    [ActivityIndicator on];
    
    //タイムライン取得リクエストURL作成
    NSURL *reqUrl = [NSURL URLWithString:@"http://search.twitter.com/search.json"];
    
    //リクエストパラメータを作成
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    //サーチワード
    [params setObject:searchWord forKey:@"q"];
    //取得数
    [params setObject:@"60" forKey:@"count"];
    //エンティティの有効化
    [params setObject:@"1" forKey:@"include_entities"];
    //日本
    [params setObject:@"ja" forKey:@"lang"];
    
    //リクエストを作成
    TWRequest *request = [[[TWRequest alloc] initWithURL:reqUrl
                                              parameters:params
                                           requestMethod:TWRequestMethodGET] autorelease];
    
    //リクエストにアカウントを設定
    [request setAccount:twAccount];
    
    //Mentions取得結果通知を作成
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSNotification *notification =[NSNotification notificationWithName:@"GetSearch"
                                                                object:self
                                                              userInfo:result];
    
    [request performRequestWithHandler:
     ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             if ( responseData ) {
                 
                 NSError *jsonError = nil;
                 NSDictionary *searchResult = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                               options:NSJSONReadingMutableLeaves
                                                                                                 error:&jsonError];
                 
                 
                 NSLog(@"searchResult: %@", searchResult);
                 
                 //取得完了を通知
                 [result setObject:@"SearchSuccess" forKey:@"Result"];
                 [result setObject:[searchResult objectForKey:@"results"] forKey:@"Search"];
                 
                 //通知を実行
                 [[NSNotificationCenter defaultCenter] postNotification:notification];
                 
                 [ActivityIndicator off];
             }
         });
     }];
    
    //NSLog(@"Favorites request sended");
}

+ (BOOL)reachability {
    
    BOOL result = NO;
    
    if ( [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable ) {
        
        result = YES;
        
    }else {
        
        [ShowAlert error:@"インターネットに接続されていません。"];
    }
    
    return result;
}

@end
