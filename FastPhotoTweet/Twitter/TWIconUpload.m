//
//  TWIconUpload.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/06/09.
//

#import "TWIconUpload.h"

@implementation TWIconUpload

+ (void)image:(UIImage *)image {
 
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    @try {
        
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
            NSString *tReqURL = @"https://api.twitter.com/1/account/update_profile_image.json";
            
            //リクエストの作成
            TWRequest *postRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL] 
                                                          parameters:nil 
                                                       requestMethod:TWRequestMethodPOST] autorelease];
            
            //リクエストにアカウントを設定
            [postRequest setAccount:twAccount];
            
            //UIImageをNSDataに変換
            NSData *imageData = [EncodeImage png:image];
            
            //画像を追加
            [postRequest addMultiPartData:imageData 
                                 withName:@"image" 
                                     type:@"image/png"];
            
            [postRequest performRequestWithHandler:
             ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     //レスポンスのデータをNSStringに変換後JSONをDictionaryに格納
                     //NSString *responseDataString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
                     //NSDictionary *result = [responseDataString JSONValue];
                     
                     //NSLog(@"responseDataString: %@", responseDataString);
                     //NSLog(@"ResultText: %@", [result objectForKey:@"text"]);
                     //NSLog(@"Result: %@", result);
                     
                     [ActivityIndicator visible:NO];
                 });
             }];
        }
        
    }@catch ( NSException *e ) {
        
        [ShowAlert error:@"不明なエラーが発生しました。やり直してください。"];
        
    }@finally {
        
        [pool drain];
    }
}

@end