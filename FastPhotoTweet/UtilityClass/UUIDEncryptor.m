//
//  UUIDEncryptor.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/04/28.
//

#import "UUIDEncryptor.h"

#define UUID [[NSUserDefaults standardUserDefaults] objectForKey:@"UUID"]

@implementation UUIDEncryptor

+ (NSString *)encryption:(NSString *)string {
     
    NSLog(@"Encryption");
    
    //UUIDが存在するかチェック
    if ( ![EmptyCheck check:UUID] ) {
        
        //UUIDを生成して保存
        CFUUIDRef uuidObj = CFUUIDCreate(kCFAllocatorDefault);
        NSString *uuidString = (NSString *)CFUUIDCreateString(nil, uuidObj);
        CFRelease(uuidObj);
        
        [[NSUserDefaults standardUserDefaults] setObject:uuidString forKey:@"UUID"];
        
        NSLog(@"Create UUID: %@", uuidString);
        
        [uuidString release];
    }
    
    //受け取った文字列をUUIDをキーにAES256暗号化し返す
    return [FBEncryptorAES encryptBase64String:string
                                     keyString:UUID
                                 separateLines:NO];
}

+ (NSString *)decryption:(NSString *)string {
    
    NSLog(@"Decryption");
    
    if ( ![EmptyCheck check:UUID] ) {
        
        //復号化時にUUIDがないのは完全にロジックエラー
        ShowAlert *errorAlert = [[ShowAlert alloc] init];
        [errorAlert error:@"UUIDがありません。"];
        
        return nil;
    }
    
    //受け取った文字列をUUIDをキーにAES256復号化し返す
    return [FBEncryptorAES decryptBase64String:string
                                     keyString:UUID];
}

@end
