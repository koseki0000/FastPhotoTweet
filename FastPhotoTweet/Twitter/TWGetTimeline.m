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
    ACAccount *twAccount = [TWGetAccount getTwitterAccount];
    NSLog(@"homeTimeline: %@", twAccount.username);
    
    //Twitterアカウントの確認
    if ( twAccount == nil ) {
        
        //アカウントデータが空
        [ShowAlert error:@"アカウントが取得できませんでした。"];
        
        return;
    }
    
    [ActivityIndicator on];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //タイムライン取得リクエストURL作成
    NSURL *reqUrl = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/home_timeline.json"];
    
    //リクエストパラメータを作成
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    //取得数
    [params setObject:@"100" forKey:@"count"];
    //エンティティの有効化
    [params setObject:@"1" forKey:@"include_entities"];
    //RT表示
    [params setObject:@"1" forKey:@"include_rts"];
    
    //差分取得
    if ( ![appDelegate.sinceId isEqualToString:BLANK] ) {
     
        [params setObject:appDelegate.sinceId forKey:@"since_id"];
    }
    
    //リクエストを作成
    TWRequest *request = [[TWRequest alloc] initWithURL:reqUrl
                                             parameters:params
                                          requestMethod:TWRequestMethodGET];
    
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

                 //取得完了を通知
                 [result setObject:@"TimelineSuccess" forKey:@"Result"];
                 [result setObject:timeline forKey:@"Timeline"];
                 
                 //通知を実行
                 [[NSNotificationCenter defaultCenter] postNotification:notification];
                 
                 [ActivityIndicator off];
             }
         });
     }];
    
    //NSLog(@"Timeline request sended");
}

@end
