//
//  UUIDEncryptor.m
//  UtilityClass
//
//  Created by @peace3884 on 12/04/28.
//

#import "UUIDEncryptor.h"

@implementation UUIDEncryptor

+ (NSString *)encryption:(NSString *)string {
    
    //UUIDが存在するかチェック
    NSString *UUID = [USER_DEFAULTS objectForKey:@"UUID"];
    if ( ![EmptyCheck check:UUID] ) {
        
        //UUIDを生成して保存
        [USER_DEFAULTS setObject:[[NSUUID UUID] UUIDString]
                                                  forKey:@"UUID"];
    }
    
    //受け取った文字列をUUIDをキーにAES256暗号化し返す
    return [FBEncryptorAES encryptBase64String:string
                                     keyString:UUID
                                 separateLines:NO];
}

+ (NSString *)decryption:(NSString *)string {
    
    NSString *UUID = [USER_DEFAULTS objectForKey:@"UUID"];
    if ( ![EmptyCheck check:UUID] ) {
        
        //復号化時にUUIDがないのは完全にロジックエラー
        [ShowAlert error:@"UUIDがありません。"];
        
        return nil;
    }
    
    //受け取った文字列をUUIDをキーにAES256復号化し返す
    return [FBEncryptorAES decryptBase64String:string
                                     keyString:UUID];
}

@end
