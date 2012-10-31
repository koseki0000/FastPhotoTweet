//
//  TWSendTweet.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "TWSendTweet.h"

#define API_VERSION @"1"

@implementation TWSendTweet

+ (void)post:(NSString *)text withInReplyToID:(NSString *)tweetID {
    
    NSLog(@"Tweet only Text");
    
    if ( ![TWTweetComposeViewController canSendTweet] ) return;
    
    if ( [TWAccounts currentAccount] == nil ) {
        
        [ShowAlert error:@"アカウントが取得できませんでした。"];
        return;
    }
    
    if ( text == nil ) return;
    
    text = [DeleteWhiteSpace string:text];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableArray *tempMArray = [NSMutableArray array];
    [tempMArray addObject:text];
    if ( tweetID != nil && ![tweetID isEqualToString:@""] ) [tempMArray addObject:tweetID];
    [tempMArray insertObject:[NSNumber numberWithInt:[[NSUserDefaults standardUserDefaults] integerForKey:@"UseAccount"]] atIndex:0];
    [tempMArray insertObject:[TWAccounts currentAccountName] atIndex:1];
    [appDelegate.postError addObject:(NSArray *)tempMArray];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [ActivityIndicator on];
    });
    
    NSString *tReqURL = [NSString stringWithFormat:@"https://api.twitter.com/%@/statuses/update.json", API_VERSION];
    
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    [params setObject:@"1" forKey:@"include_entities"];
    [params setObject:text forKey:@"status"];
    
    if (  tweetID != nil &&
        ![tweetID isEqualToString:@""] ) {
        
        [params setObject:tweetID forKey:@"in_reply_to_status_id"];
    }
    
    TWRequest *postRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL]
                                                  parameters:params
                                               requestMethod:TWRequestMethodPOST] autorelease];
    
    postRequest.account = [TWAccounts currentAccount];
    
    [postRequest performRequestWithHandler:
     ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
         
         NSLog(@"Receive Tweet Response");
         
         if ( !error ) {
             
             if ( responseData != nil ) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     id result = [NSJSONSerialization JSONObjectWithData:responseData
                                                                 options:NSJSONReadingMutableLeaves
                                                                   error:nil];
                     
                     NSMutableDictionary *postResult = [NSMutableDictionary dictionary];
                     NSNotification *postNotification =[NSNotification notificationWithName:@"PostDone"
                                                                                     object:self
                                                                                   userInfo:postResult];
                     
                     if ( result != nil ) {
                         
                         if ( [result isKindOfClass:[NSDictionary class]] ) {
                             
                             NSDictionary *resultDic = [NSDictionary dictionaryWithDictionary:result];
                             
                             if ( [resultDic objectForKey:@"error"] == nil &&
                                  [resultDic objectForKey:@"text"] != nil ) {
                                 
                                 [postResult setObject:@"Success" forKey:@"PostResult"];
                                 [postResult setObject:[TWEntities openTco:resultDic] forKey:@"SuccessText"];
                                 
                             }else if ( [resultDic objectForKey:@"error"] != nil ||
                                        [resultDic objectForKey:@"text"] == nil ) {
                                 
                                 if ( [resultDic objectForKey:@"error"] != nil ) {
                                     
                                     [ShowAlert error:[resultDic objectForKey:@"error"]];
                                     
                                 }else {
                                     
                                     [ShowAlert error:@"原因不明のエラー"];
                                 }
                                 
                                 [postResult setObject:@"Error" forKey:@"PostResult"];
                                 
                             }else {
                                 
                                 [postResult setObject:@"Error" forKey:@"PostResult"];
                                 [ShowAlert error:@"不明のエラー"];
                             }
                             
                         }else {
                             
                             [postResult setObject:@"Error" forKey:@"PostResult"];
                             [ShowAlert error:@"不明なレスポンスタイプ"];
                         }
                     }
                     
                     [[NSNotificationCenter defaultCenter] postNotification:postNotification];
                     [ActivityIndicator off];
                 });
             }
             
         }else {
             
             [ShowAlert error:error.description];
         }
     }];
    
    NSLog(@"Tweet Request Sended");
}

+ (void)post:(NSString *)text withInReplyToID:(NSString *)tweetID andImage:(UIImage *)image {
    
    NSLog(@"Tweet with Media");
    
    if ( ![TWTweetComposeViewController canSendTweet] ) return;
    
    if ( [TWAccounts currentAccount] == nil ) {
        
        [ShowAlert error:@"アカウントが取得できませんでした。"];
        return;
    }
    
    if ( image == nil ) {
        
        [TWSendTweet post:text withInReplyToID:tweetID];
        return;
    }

    if (( text == nil || [text isEqualToString:@""] ) &&
        image != nil ) {
        
        text = @"";
    }
    
    text = [DeleteWhiteSpace string:text];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSMutableArray *tempMArray = [NSMutableArray array];
    [tempMArray addObject:text];
    if ( tweetID != nil && ![tweetID isEqualToString:@""] ) [tempMArray addObject:tweetID];
    [tempMArray insertObject:[NSNumber numberWithInt:[[NSUserDefaults standardUserDefaults] integerForKey:@"UseAccount"]] atIndex:0];
    [tempMArray insertObject:[TWAccounts currentAccountName] atIndex:1];
    [appDelegate.postError addObject:(NSArray *)tempMArray];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [ActivityIndicator on];
    });
    
    //画像をリサイズするか判定
    if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"ResizeImage"] ) {
        
        //リサイズを行う
        image = [ResizeImage aspectResize:image];
    }
    
    NSString *tReqURL = [NSString stringWithFormat:@"https://upload.twitter.com/%@/statuses/update_with_media.json?include_entities=true", API_VERSION];
    
    TWRequest *postRequest = [[[TWRequest alloc] initWithURL:[NSURL URLWithString:tReqURL]
                                                  parameters:nil
                                               requestMethod:TWRequestMethodPOST] autorelease];
    
    [postRequest addMultiPartData:[text dataUsingEncoding:NSUTF8StringEncoding]
                         withName:@"status"
                             type:@"multipart/form-data"];
    
    [postRequest addMultiPartData:[EncodeImage image:image]
                         withName:@"media[]"
                             type:@"multipart/form-data"];
    
    if (  tweetID != nil &&
        ![tweetID isEqualToString:@""] ) {
        
        [postRequest addMultiPartData:[tweetID dataUsingEncoding:NSUTF8StringEncoding]
                             withName:@"in_reply_to_status_id"
                                 type:@"multipart/form-data"];
        
    }
    
    postRequest.account = [TWAccounts currentAccount];
    
    [postRequest performRequestWithHandler:
     ^( NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error ) {
         
         NSLog(@"Receive Tweet with Media Response");
         
         if ( !error ) {
             
             if ( responseData != nil ) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     id result = [NSJSONSerialization JSONObjectWithData:responseData
                                                                 options:NSJSONReadingMutableLeaves
                                                                   error:nil];
                     
                     NSMutableDictionary *postResult = [NSMutableDictionary dictionary];
                     NSNotification *postNotification =[NSNotification notificationWithName:@"PostDone"
                                                                                     object:self
                                                                                   userInfo:postResult];
                     
                     if ( result != nil ) {
                         
                         if ( [result isKindOfClass:[NSDictionary class]] ) {
                             
                             NSDictionary *resultDic = [NSDictionary dictionaryWithDictionary:result];
                             
                             if ( [resultDic objectForKey:@"error"] != nil ||
                                  [resultDic objectForKey:@"text"] == nil ) {
                                 
                                 if ( [resultDic objectForKey:@"error"] != nil ) {
                                     
                                     [ShowAlert error:[resultDic objectForKey:@"error"]];
                                     
                                 }else {
                                     
                                     [ShowAlert error:@"原因不明のエラー"];
                                 }
                                 
                                 [postResult setObject:@"PhotoError" forKey:@"PostResult"];
                                 
                             }else if ( [result objectForKey:@"error"] == nil &&
                                        [result objectForKey:@"text"] != nil ) {
                                 
                                 [postResult setObject:@"PhotoSuccess" forKey:@"PostResult"];
                                 [postResult setObject:[TWEntities openTco:resultDic] forKey:@"SuccessText"];
                                 
                             }else {
                                 
                                 [postResult setObject:@"PhotoError" forKey:@"PostResult"];
                                 [ShowAlert error:@"不明なエラー"];
                             }
                             
                         }else {
                             
                             [postResult setObject:@"Error" forKey:@"PostResult"];
                             [ShowAlert error:@"不明なレスポンスタイプ"];
                         }
                      
                         [ActivityIndicator off];
                         [[NSNotificationCenter defaultCenter] postNotification:postNotification];
                         
                     }else {
                         
                         NSLog(@"perser error");
                     }
                 });
                 
             }else {
                 
                 NSLog(@"responseData is nil");
             }
             
         }else {
             
             [ShowAlert error:error.description];
         }
     }];
    
    NSLog(@"Tweet with Media Request Sended");
}

@end