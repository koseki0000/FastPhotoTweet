//
//  FullSizeImage.h
//  UtilityClass
//
//  Created by @peace3884 on 12/05/13.
//

#import <Foundation/Foundation.h>
#import "ShowAlert.h"
#import "NSString+RegularExpression.h"
#import "NSString+WordCollect.h"
#import "JSON.h"

@interface FullSizeImage : NSObject

+ (NSString *)urlString:(NSString *)urlString;
+ (NSString *)getSourceCode:(NSString *)urlString;

+ (BOOL)checkImageUrl:(NSString *)urlString;
+ (BOOL)isSocialService:(NSString *)urlString;

@end
