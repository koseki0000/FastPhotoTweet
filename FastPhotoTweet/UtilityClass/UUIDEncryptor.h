//
//  UUIDEncryptor.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/04/28.
//

#import <Foundation/Foundation.h>
#import "FBEncryptorAES.h"
#import "EmptyCheck.h"
#import "ShowAlert.h"

@interface UUIDEncryptor : NSObject 

+ (NSString *)encryption:(NSString *)string;
+ (NSString *)decryption:(NSString *)string;

@end
