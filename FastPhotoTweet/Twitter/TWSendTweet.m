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
        
        //アカウントの取得
        ACAccount *twAccount = [TWGetAccount getTwitterAccount];
        
        //Twitterアカウントの確認
        if (twAccount == nil) {
            
            //アカウントデータが空
            ShowAlert *alert = [[[ShowAlert alloc] init] autorelease];
            [alert error:@"Can’t post"];
            
            return;
        }
        
        //0:画像つき投稿 1:文字のみ
        int postMode = 0;
        NSString *postText;
        UIImage *image = [[[UIImage alloc] init] autorelease];
        
        NSLog(@"postData: %@", postData);
        
        //画像のチェック
        if ( postData.count == 1 ) {
            
            //imageが空なら文字のみ投稿
            //文字データのチェック
            if ( [EmptyCheck check:[postData objectAtIndex:0]] ) {
                
                //文字のみの投稿モードを設定
                postMode = 1;
                
            }else {
                
                NSLog(@"PostTextEmpty");
                
                ShowAlert *alert = [[[ShowAlert alloc] init] autorelease];
                [alert error:@"文字が入力されていません。"];
                return;
            }
        }
        
        postText = [postData objectAtIndex:0];
        
        //ステータスバーに処理中表示
        [ActivityIndicator activityIndicatorVisible:YES];
        
        //リクエストURLを指定
        NSString *tReqURL;
        if ( postMode == 0 ) {
            
            tReqURL = @"https://upload.twitter.com/1/statuses/update_with_media.json";
            image = [postData objectAtIndex:1];
            
        }else if ( postMode == 1 ) {
            
            tReqURL = @"http://api.twitter.com/1/statuses/update.json";
        }
        
        //リクエストの作成
        TWRequest *postRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL] 
                                                     parameters:nil 
                                                  requestMethod:TWRequestMethodPOST] autorelease];
        
        if ( postMode == 0 ) {
            
            NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
            
            //画像をリサイズするか判定
            if ( [d boolForKey:@"ResizeImage"] ) {
                
                //リサイズを行う
                image = [ResizeImage aspectResize:image];
            }
            
            //UIImageをNSDataに変換
            NSData *imageData;            
            if ( [[d objectForKey:@"SaveImageType"] isEqualToString:@"JPG(Low)"] ) {
                imageData = UIImageJPEGRepresentation(image, 0.6);
            }else if ( [[d objectForKey:@"SaveImageType"] isEqualToString:@"JPG"] ) {
                imageData = UIImageJPEGRepresentation(image, 0.8);
            }else if ( [[d objectForKey:@"SaveImageType"] isEqualToString:@"JPG(High)"] ) {
                imageData = UIImageJPEGRepresentation(image, 0.95);
            }else if ( [[d objectForKey:@"SaveImageType"] isEqualToString:@"PNG"] ) {
                imageData = UIImagePNGRepresentation(image);
            }else {
                imageData = UIImageJPEGRepresentation(image, 0.8);
            }
            
            //画像を追加
            [postRequest addMultiPartData:imageData 
                                 withName:@"media[]" 
                                     type:@"multipart/form-data"];
        }
        
        //テキストを追加
        [postRequest addMultiPartData:[postText dataUsingEncoding:NSUTF8StringEncoding]
                             withName:@"status" 
                                 type:@"multipart/form-data"];
            
        //リクエストにアカウントを設定
        [postRequest setAccount:twAccount];
        
        //投稿結果通知を作成
        NSMutableDictionary *postResult = [NSMutableDictionary dictionary];
        NSNotification *postNotification =[NSNotification notificationWithName:@"PostDone" 
                                                                        object:self 
                                                                      userInfo:postResult];
        NSLog(@"SetNotification");
        
        [postRequest performRequestWithHandler:
         ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 //レスポンスのデータをNSStringに変換後JSONをDictionaryに格納
                 NSString *responseDataString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
                 NSDictionary *result = [responseDataString JSONValue];
                 
                 NSLog(@"ResultText: %@", [result objectForKey:@"text"]);
                 
                 BOOL media = NO;
                 NSString *entities = [[result objectForKey:@"entities"] objectForKey:@"media"];
                 
                 //投稿完了したPostが文字のみか画像付きか判定
                 if ( [EmptyCheck check:entities] ) {
                     
                     //画像付き
                     media = YES;
                 }
                 
                 //Postしたテキスト
                 NSString *text = [result objectForKey:@"text"];
                 NSLog(@"Text: %@", text);
                 
                 if (error != nil) {
                     
                     //エラー
                     NSString *errorText = [result objectForKey:@"error"];
                                          
                     ShowAlert *alert = [[[ShowAlert alloc] init] autorelease];
                     [alert error:errorText];
                     
                     //通知にエラーをセット
                     if ( media ) {
                         
                         [postResult setObject:@"PhotoError" forKey:@"PostResult"];
                         
                         NSArray *resultArray = [NSArray arrayWithObjects:text, image, nil];
                         [postResult setObject:resultArray forKey:@"PostData"];
                         
                     }else {
                         
                         [postResult setObject:@"Error" forKey:@"PostResult"];
                         
                         NSArray *resultArray = [NSArray arrayWithObjects:text, nil, nil];
                         [postResult setObject:resultArray forKey:@"PostData"];
                     }
                     
                     //通知を実行
                     [[NSNotificationCenter defaultCenter] postNotification:postNotification];
                     
                     NSLog(@"PostErrorNotification: %@", errorText);
                     
                 } else {
                     
                     if ( ![EmptyCheck check:text] ) {
                         
                         NSString *errorText = [result objectForKey:@"error"];
                         
                         //textが空の場合は失敗してる
                         ShowAlert *alert = [[[ShowAlert alloc] init] autorelease];
                         [alert error:errorText];
                         
                         NSLog(@"Post Error: %@", errorText);
                         
                     }else {
                         
                         //通知に成功をセット
                         if ( media ) {
                             
                             [postResult setObject:@"PhotoSuccess" forKey:@"PostResult"];
                             
                             NSArray *resultArray = [NSArray arrayWithObjects:text, image, nil];
                             [postResult setObject:resultArray forKey:@"PostData"];
                             
                         }else {
                             
                             [postResult setObject:@"Success" forKey:@"PostResult"];
                             
                             NSArray *resultArray = [NSArray arrayWithObjects:text, nil, nil];
                             [postResult setObject:resultArray forKey:@"PostData"];
                         }
                         
                         //通知を実行
                         [[NSNotificationCenter defaultCenter] postNotification:postNotification];
                         
                         NSLog(@"PostSuccessNotification");
                     }
                 }
                 
                 //ステータスバーの処理中表示オフ
                 [ActivityIndicator activityIndicatorVisible:NO];
             });
         }];
        
        NSLog(@"Post sended: %@", twAccount.username);
        
    }else {
        
        //何らかの理由でTweet不可だった場合
        ShowAlert *alert = [[[ShowAlert alloc] init] autorelease];
        [alert error:@"Please try again later"];
        
    }
}

@end
