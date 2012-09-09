//
//  TWFriends.m
//  FastPhotoTweet
//
//  Created by @peace3884 12/09/09.
//

#import "TWFriends.h"

#define API_VERSION @"1"

@implementation TWFriends

+ (void)follow:(NSString *)screenName {
    
    NSLog(@"follow: %@", screenName);
    
    NSString *type = @"friendships/create";
    [TWFriends friendship:type screenName:screenName];
}

+ (void)unfollow:(NSString *)screenName {
    
    NSLog(@"unfollow: %@", screenName);
    
    NSString *type = @"friendships/destroy";
    [TWFriends friendship:type screenName:screenName];
}

+ (void)block:(NSString *)screenName {
    
    NSLog(@"block: %@", screenName);
    
    NSString *type = @"blocks/create";
    [TWFriends friendship:type screenName:screenName];
}

+ (void)unblock:(NSString *)screenName {
    
    NSLog(@"unblock: %@", screenName);
    
    NSString *type = @"blocks/destroy";
    [TWFriends friendship:type screenName:screenName];
}

+ (void)reportSpam:(NSString *)screenName {
    
    NSLog(@"reportSpam: %@", screenName);
    
    NSString *type = @"report_spam";
    [TWFriends friendship:type screenName:screenName];
}

+ (void)friendship:(NSString *)type screenName:(NSString *)screenName {
    
    //Tweet可能な状態か判別
    if ( [TWTweetComposeViewController canSendTweet] ) {
        
        //アカウントの取得
        ACAccount *twAccount = [TWGetAccount currentAccount];
        
        //Twitterアカウントの確認
        if (twAccount == nil) {
            
            //アカウントデータが空
            [ShowAlert error:@"アカウントが取得できませんでした。"];
            
            return;
        }
        
        //ステータスバーに処理中表示
        [ActivityIndicator visible:YES];
        
        //リクエストパラメータを作成
        NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
        //対象ユーザー
        [params setObject:screenName forKey:@"screen_name"];
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/%@/%@.json", API_VERSION, type];
        
        //リクエストの作成
        TWRequest *request = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL]
                                                  parameters:params
                                               requestMethod:TWRequestMethodPOST] autorelease];
        
        //リクエストにアカウントを設定
        [request setAccount:twAccount];
        
        [request performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 //処理中表示を消す
                 [ActivityIndicator off];
                 
                 if ( responseData ) {
                     
                     NSError *jsonError = nil;
                     NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData
                                                                            options:NSJSONReadingMutableLeaves
                                                                              error:&jsonError];
                     NSLog(@"result.class: %@", result.class);
                     NSLog(@"result: %@", result);
                 }
             });
         }];
    }
}

@end
