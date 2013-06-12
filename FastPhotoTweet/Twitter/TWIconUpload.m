//
//  TWIconUpload.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/06/09.
//

#import "TWIconUpload.h"

#define API_VERSION @"1.1"

@implementation TWIconUpload

+ (void)image:(UIImage *)image {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    @try {
        
        //Twitterアカウントの確認
        if ( [TWAccounts currentAccount] == nil ) {
            
            //アカウントデータが空
            [ShowAlert error:@"アカウントが取得できませんでした。"];
            return;
        }
        
        //ステータスバーに処理中表示
        [ActivityIndicator visible:YES];
        
        //リクエストURLを指定
        NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/%@/account/update_profile_image.json", API_VERSION];
        
        //リクエストの作成
        SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:TWRequestMethodPOST
                                                              URL:[NSURL URLWithString:tReqURL]
                                                       parameters:nil];
        
        //リクエストにアカウントを設定
        [postRequest setAccount:[TWAccounts currentAccount]];
        
        //UIImageをNSDataに変換
        NSData *imageData = [EncodeImage png:image];
        
        //画像を追加
        [postRequest addMultipartData:imageData
                             withName:@"image"
                                 type:@"image/png"
                             filename:@"icon.png"];
        
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
        
    }@catch ( NSException *e ) {
        
        [ShowAlert unknownError];
        
    }@finally {
        
        [pool drain];
    }
}

@end
