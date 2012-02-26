//
//  TWSendTweet.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "TWSendTweet.h"

@implementation TWSendTweet


+ (void)post:(NSString *)postText {
    
    //Tweet可能な状態か判別
    if ( [TWTweetComposeViewController canSendTweet] ) {
        
        //ステータスバーに処理中表示
        [ActivityIndicator activityIndicatorVisible:YES];
        
        //リクエストの作成
        TWRequest *postRequest = [[TWRequest alloc] initWithURL:
                                  [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"] 
                                                     parameters:[NSDictionary dictionaryWithObject:postText 
                                                                                            forKey:@"status"] 
                                                  requestMethod:TWRequestMethodPOST];
        
        //アカウントの取得
        ACAccount *twAccount = [TWGetAccount getTwitterAccount];
        
        //Twitterアカウントの確認
        if (twAccount == nil) {
            
            //アカウントデータが空
            ShowAlert *alert = [[ShowAlert alloc] init];
            [alert error:@"Can’t post"];
            
            return;
        }
        
        //リクエストにアカウントを設定
        [postRequest setAccount:twAccount];
        
        [postRequest performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
            
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if (error != nil) {
                     
                     //エラー
                     NSString *responseDataString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
                     NSDictionary *result = [responseDataString JSONValue];
                     
                     NSString *errorText = [result objectForKey:@"error"];
                     
                     ShowAlert *alert = [[ShowAlert alloc] init];
                     [alert error:errorText];
                     
                     NSLog(@"Post Error: %@", errorText);
                     
                 } else {
                     
                     //JSONからDictionaryを生成
                     NSString *responseDataString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
                     NSDictionary *result = [responseDataString JSONValue];
                     
                     //Postしたテキスト
                     NSString *text = [result objectForKey:@"text"];
                     
                     if ( [text isEqualToString:@""] || text == nil ) {
                     
                         NSString *errorText = [result objectForKey:@"error"];
                         
                         //textが空の場合は失敗してる
                         ShowAlert *alert = [[ShowAlert alloc] init];
                         [alert error:errorText];
                         
                         NSLog(@"Post Error: %@", errorText);
                         
                     }else {
                         
                         //Post成功
                         ShowAlert *alert = [[ShowAlert alloc] init];
                         [alert title:@"Success" message:text];
                         
                         NSLog(@"Post Success");
                         
                     }
                     
                 }
                 
                 //ステータスバーの処理中表示オフ
                 [ActivityIndicator activityIndicatorVisible:NO];
             });
        }];
        
        NSLog(@"Post sended");
        
    }else {
        
        //何らかの理由でTweet不可だった場合
        ShowAlert *alert = [[ShowAlert alloc] init];
        [alert error:@"Please try again later"];
        
    }
}

@end
