//
//  TWList.m
//  FastPhotoTweet
//
//  Created by @peace3884 12/09/09.
//

#import "TWList.h"

#define API_VERSION @"1"

@implementation TWList

+ (oneway void)getListAll {
    
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
        [params setObject:twAccount.username forKey:@"screen_name"];
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/%@/lists/all.json", API_VERSION];
        
        //リクエストの作成
        TWRequest *request = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL]
                                                  parameters:params
                                               requestMethod:TWRequestMethodGET] autorelease];
        
        //リクエストにアカウントを設定
        [request setAccount:twAccount];
        
        [request performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 //処理中表示を消す
                 [ActivityIndicator off];
                 
                 if ( responseData ) {
                     
                     NSError *jsonError = nil;
                     NSArray *result = [NSJSONSerialization JSONObjectWithData:responseData
                                                                            options:NSJSONReadingMutableLeaves
                                                                              error:&jsonError];

                     //NSLog(@"result: %@", result);
                     
                     NSDictionary *resultData = @{ @"ResultData" : result };
                     
                     NSNotification *notification =[NSNotification notificationWithName:@"ReceiveListAll"
                                                                                 object:self
                                                                               userInfo:resultData];
                     
                     //通知を実行
                     [[NSNotificationCenter defaultCenter] postNotification:notification];
                 }
             });
         }];
    }
}

+ (oneway void)getList:(NSString *)listId {
    
    NSLog(@"getList: %@", listId);
    
    //リストIDが不正な場合は終了
    if ( ![RegularExpression boolWithRegExp:listId regExpPattern:@"[0-9]+"] ) return;
    
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
        //取得リスト
        [params setObject:listId forKey:@"list_id"];
        //エンティティの有効化
        [params setObject:@"1" forKey:@"include_entities"];
        //RT表示
        [params setObject:@"1" forKey:@"include_rts"];
        //取得数
        [params setObject:@"60" forKey:@"per_page"];
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/%@/lists/statuses.json", API_VERSION];
        
        //リクエストの作成
        TWRequest *request = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL]
                                                  parameters:params
                                               requestMethod:TWRequestMethodGET] autorelease];
        
        //リクエストにアカウントを設定
        [request setAccount:twAccount];
        
        [request performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 //処理中表示を消す
                 [ActivityIndicator off];
                 
                 if ( responseData ) {
                     
                     NSError *jsonError = nil;
                     NSArray *result = [NSJSONSerialization JSONObjectWithData:responseData
                                                                       options:NSJSONReadingMutableLeaves
                                                                         error:&jsonError];
                     
                     //t.coを全て展開する
                     result = [TWEntities replaceTcoAll:result];
                     
                     //NSLog(@"ReceiveList: %@", result);
                     NSLog(@"ReceiveList count: %d", result.count);
                     
                     NSDictionary *resultData = @{ @"ResultData" : result };
                     
                     NSNotification *notification =[NSNotification notificationWithName:@"ReceiveList"
                                                                                 object:self
                                                                               userInfo:resultData];
                     
                     //通知を実行
                     [[NSNotificationCenter defaultCenter] postNotification:notification];
                 }
             });
         }];
    }
}

@end
