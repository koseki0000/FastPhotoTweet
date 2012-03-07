//
//  TWSendTweet.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "TWSendTweet.h"

@implementation TWSendTweet

+ (void)post:(NSArray *)postData {
    
    //Tweet可能な状態か判別
    if ( [TWTweetComposeViewController canSendTweet] ) {
        
        //0:画像つき投稿 1:文字のみ
        int postMode = 0;
        
        //画像のチェック
        if ( [postData objectAtIndex:1] == nil ) {
            
            //imageが空なら文字のみ投稿
            //文字データのチェック
            if ( ![EmptyCheck check:[postData objectAtIndex:0]] ) {
                
                ShowAlert *alert = [[ShowAlert alloc] init];
                [alert error:@"文字が入力されていません。"];
                return;
                
            }else {
                
                //文字のみの投稿モードを設定
                postMode = 1;
            }
        }
        
        NSString *postText = [postData objectAtIndex:0];
        UIImage *image = [postData objectAtIndex:1];
        
        NSLog(@"Start PhotoPost");
        
        //ステータスバーに処理中表示
        [ActivityIndicator activityIndicatorVisible:YES];
        
        //リクエストURLを指定
        NSString *tReqURL;
        if ( postMode == 0 ) {
            
            tReqURL = @"https://upload.twitter.com/1/statuses/update_with_media.json";
            
        }else if ( postMode == 1 ) {
            
            tReqURL = @"http://api.twitter.com/1/statuses/update.json";
        }
        
        //リクエストの作成
        TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL] 
                                                     parameters:nil 
                                                  requestMethod:TWRequestMethodPOST];
        
        //UIImageをNSDataに変換
        NSData *imageData;
        imageData = UIImagePNGRepresentation(image);
        //imageData = UIImageJPEGRepresentation(image, 0.95);
        
        if ( postMode == 0 ) {
            
            //画像を追加
            [postRequest addMultiPartData:imageData 
                                 withName:@"media[]" 
                                     type:@"multipart/form-data"];
        }
        
        //テキストを追加
        [postRequest addMultiPartData:[postText dataUsingEncoding:NSUTF8StringEncoding]
                             withName:@"status" 
                                 type:@"multipart/form-data"];
        
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
                     
                     //NSLog(@"result: %@", result);
                     
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
//                       ShowAlert *alert = [[ShowAlert alloc] init];
//                       [alert title:@"Success" message:text];
                         
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
