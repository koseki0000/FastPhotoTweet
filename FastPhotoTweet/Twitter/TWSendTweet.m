//
//  TWSendTweet.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "TWSendTweet.h"

#define API_VERSION @"1"

@implementation TWSendTweet

+ (void)post:(NSArray *)postData {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    @try {
        
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        
        //Tweet可能な状態か判別
        if ( [TWTweetComposeViewController canSendTweet] ) {
            
            //アカウントの取得
            ACAccount *twAccount = [TWGetAccount currentAccount];
            
            //Twitterアカウントの確認
            if ( twAccount == nil ) {
                
                //アカウントデータが空
                [ShowAlert error:@"アカウントが取得できませんでした。"];
                
                return;
            }
            
            //0:画像つき投稿 1:文字のみ
            int postMode = 0;
            NSString *postText = nil;
            NSString *inReplyToId = nil;
            UIImage *image = [[[UIImage alloc] init] autorelease];
            
            //投稿しようとしているPostを保存
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSMutableArray *tempMArray = [NSMutableArray arrayWithArray:postData];
            [tempMArray insertObject:[NSNumber numberWithInt:[d integerForKey:@"UseAccount"]] atIndex:0];
            [tempMArray insertObject:twAccount.username atIndex:1];
            [appDelegate.postError addObject:(NSArray *)tempMArray];
            
            //画像のチェック
            if ( postData.count == 2 ) {
                
                //imageが空なら文字のみ投稿
                //文字データのチェック
                if ( [EmptyCheck check:[postData objectAtIndex:0]] ) {
                    
                    //文字のみの投稿モードを設定
                    postMode = 1;
                    
                }else {
                    
                    //NSLog(@"PostTextEmpty");
                    
                    [ShowAlert error:@"文字が入力されていません。"];
                    return;
                }
            }
            
            postText = [postData objectAtIndex:0];
            inReplyToId = [postData objectAtIndex:1];
            
            //ステータスバーに処理中表示
            [ActivityIndicator on];
            
            //リクエストURLを指定
            NSString *tReqURL;
            if ( postMode == 0 ) {
                
                tReqURL = [NSString stringWithFormat:@"https://upload.twitter.com/%@/statuses/update_with_media.json?include_entities=true", API_VERSION];
                image = [postData objectAtIndex:2];
                
            }else if ( postMode == 1 ) {
                tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/update.json?include_entities=true", API_VERSION];
                tReqURL = @"https://api.twitter.com/1/statuses/update.json?include_entities=true";
            }
            
            //リクエストの作成
            TWRequest *postRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL] 
                                                          parameters:nil 
                                                       requestMethod:TWRequestMethodPOST] autorelease];
            
            if ( postMode == 0 ) {
                
                //画像をリサイズするか判定
                if ( [d boolForKey:@"ResizeImage"] ) {
                    
                    //リサイズを行う
                    image = [ResizeImage aspectResize:image];
                }
                
                //UIImageをNSDataに変換
                NSData *imageData = [EncodeImage image:image];
                
                //画像を追加
                [postRequest addMultiPartData:imageData 
                                     withName:@"media[]" 
                                         type:@"multipart/form-data"];
            }
            
            //テキストを追加
            [postRequest addMultiPartData:[postText dataUsingEncoding:NSUTF8StringEncoding]
                                 withName:@"status" 
                                     type:@"multipart/form-data"];
            
            if ( [EmptyCheck check:inReplyToId] ) {
            
                //InReplyToIdを追加
                [postRequest addMultiPartData:[inReplyToId dataUsingEncoding:NSUTF8StringEncoding]
                                     withName:@"in_reply_to_status_id"
                                         type:@"multipart/form-data"];
            }
            
            //リクエストにアカウントを設定
            [postRequest setAccount:twAccount];
            
            //投稿結果通知を作成
            NSMutableDictionary *postResult = [NSMutableDictionary dictionary];
            NSNotification *postNotification =[NSNotification notificationWithName:@"PostDone" 
                                                                            object:self 
                                                                          userInfo:postResult];

            [postRequest performRequestWithHandler:
             ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     //レスポンスのデータをNSStringに変換後JSONをDictionaryに格納
                     NSString *responseDataString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
                     NSDictionary *result = [responseDataString JSONValue];
                     
                     //NSLog(@"responseDataString: %@", responseDataString);
                     //NSLog(@"ResultText: %@", [result objectForKey:@"text"]);
                     //NSLog(@"Result: %@", result);
                     
                     result = [[TWEntities replaceTcoAll:@[result]] objectAtIndex:0];
                     
                     BOOL media = NO;
                     NSString *entities = [[result objectForKey:@"entities"] objectForKey:@"media"];
                     
                     //投稿完了したPostが文字のみか画像付きか判定
                     if ( [EmptyCheck check:entities] ) {
                         
                         //画像付き
                         media = YES;
                     }
                     
                     //Postしたテキストのt.coを展開
                     NSString *text = [result objectForKey:@"text"];
                     //NSLog(@"text: %@", text);
                     
                     if ( error != nil ) {
                         
                         //NSLog(@"PostNSError: %@", error);
                         
                         //エラー
                         NSString *errorText = [result objectForKey:@"error"];
                         
                         //エラー文が取得出来た場合は表示
                         if ( [EmptyCheck check:errorText] ) {
                             
                             [ShowAlert error:errorText];
                         }
                         
                         //通知にエラーをセット
                         if ( media ) {
                             
                             [postResult setObject:@"PhotoError" forKey:@"PostResult"];
                             
                         }else {
                             
                             [postResult setObject:@"Error" forKey:@"PostResult"];
                         }
                         
                         //通知を実行
                         //NSLog(@"PostErrorNotification: %@", errorText);
                         [[NSNotificationCenter defaultCenter] postNotification:postNotification];
                         
                     } else {
                         
                         if ( ![EmptyCheck check:text] ) {
                             
                             NSString *errorText = [result objectForKey:@"error"];
                             
                             if ( ![EmptyCheck check:errorText] ) {
                                 
                                 errorText = @"不明なエラーです。";
                             }
                             
                             //textが空の場合は失敗してる
                             [ShowAlert error:errorText];
                             
                             [postResult setObject:@"Error" forKey:@"PostResult"];
                             
                             [[NSNotificationCenter defaultCenter] postNotification:postNotification];
                             
                         }else {
                             
                             //通知に成功をセット
                             if ( media ) {
                                 
                                 [postResult setObject:@"PhotoSuccess" forKey:@"PostResult"];
                                 [postResult setObject:text forKey:@"SuccessText"];
                                 
                             }else {
                                 
                                 [postResult setObject:@"Success" forKey:@"PostResult"];
                                 [postResult setObject:text forKey:@"SuccessText"];
                             }
                             
                             //通知を実行
                             //NSLog(@"PostSuccessNotification");
                             [[NSNotificationCenter defaultCenter] postNotification:postNotification];
                         }
                     }
                     
                     //ステータスバーの処理中表示オフ
                     [ActivityIndicator off];
                 });
             }];
            
            //NSLog(@"Post sended: %@", twAccount.username);
            
        }else {
            
            //何らかの理由でTweet不可だった場合
            [ShowAlert unknownError];
        }
        
    }@catch ( NSException *e ) {
        
        [ShowAlert unknownError];
        
    }@finally {
        
        [pool drain];
    }
}

@end