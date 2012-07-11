//
//  TWEvent.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/11.
//

#import "TWEvent.h"

@implementation TWEvent

+ (void)favorite:(NSString *)tweetId {
    
    //Tweet可能な状態か判別
    if ( [TWTweetComposeViewController canSendTweet] ) {
        
        //アカウントの取得
        ACAccount *twAccount = [TWGetAccount getTwitterAccount];
        
        //Twitterアカウントの確認
        if (twAccount == nil) {
            
            //アカウントデータが空
            [ShowAlert error:@"アカウントが取得できませんでした。"];
            
            return;
        }
        
        //ステータスバーに処理中表示
        [ActivityIndicator visible:YES];
        
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
                 
                 //レスポンスのデータをNSStringに変換後JSONをDictionaryに格納
                 NSString *responseDataString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
                 NSDictionary *result = [responseDataString JSONValue];
                 
                 //NSLog(@"responseDataString: %@", responseDataString);
                 //NSLog(@"ResultText: %@", [result objectForKey:@"text"]);
                 NSLog(@"Result: %@", result);
                 
                 [ActivityIndicator visible:NO];
             });
         }];
    }
}

+ (void)reTweet:(NSString *)tweetId {
    
    //Tweet可能な状態か判別
    if ( [TWTweetComposeViewController canSendTweet] ) {
        
        //アカウントの取得
        ACAccount *twAccount = [TWGetAccount getTwitterAccount];
        
        //Twitterアカウントの確認
        if (twAccount == nil) {
            
            //アカウントデータが空
            [ShowAlert error:@"アカウントが取得できませんでした。"];
            
            return;
        }
        
        //ステータスバーに処理中表示
        [ActivityIndicator visible:YES];
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/1/statuses/retweet/%@json ", tweetId];
        
        //リクエストの作成
        TWRequest *postRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL] 
                                                      parameters:nil 
                                                   requestMethod:TWRequestMethodPOST] autorelease];
        
        //リクエストにアカウントを設定
        [postRequest setAccount:twAccount];
        
        [postRequest performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 //レスポンスのデータをNSStringに変換後JSONをDictionaryに格納
                 NSString *responseDataString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
                 NSDictionary *result = [responseDataString JSONValue];
                 
                 //NSLog(@"responseDataString: %@", responseDataString);
                 //NSLog(@"ResultText: %@", [result objectForKey:@"text"]);
                 NSLog(@"Result: %@", result);
                 
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
    
    //Tweet可能な状態か判別
    if ( [TWTweetComposeViewController canSendTweet] ) {
        
        //アカウントの取得
        ACAccount *twAccount = [TWGetAccount getTwitterAccount];
        
        //Twitterアカウントの確認
        if (twAccount == nil) {
            
            //アカウントデータが空
            [ShowAlert error:@"アカウントが取得できませんでした。"];
            
            return;
        }
        
        //ステータスバーに処理中表示
        [ActivityIndicator visible:YES];
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/1/favorites/destroy/%@.json ", tweetId];
        
        //リクエストの作成
        TWRequest *postRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL] 
                                                      parameters:nil 
                                                   requestMethod:TWRequestMethodPOST] autorelease];
        
        //リクエストにアカウントを設定
        [postRequest setAccount:twAccount];
        
        [postRequest performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 //レスポンスのデータをNSStringに変換後JSONをDictionaryに格納
                 NSString *responseDataString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
                 NSDictionary *result = [responseDataString JSONValue];
                 
                 //NSLog(@"responseDataString: %@", responseDataString);
                 //NSLog(@"ResultText: %@", [result objectForKey:@"text"]);
                 NSLog(@"Result: %@", result);
                 
                 [ActivityIndicator visible:NO];
             });
         }];
    }
}

@end
