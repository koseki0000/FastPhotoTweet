//
//  FullSizeImage.h
//  UtilityClass
//
//  Created by @peace3884 on 12/05/13.
//

#import <Foundation/Foundation.h>
#import "ShowAlert.h"
#import "RegularExpression.h"
#import "JSON.h"

@interface FullSizeImage : NSObject

+ (NSString *)urlString:(NSString *)urlString;
+ (NSString *)getSourceCode:(NSString *)urlString;

+ (BOOL)checkImageUrl:(NSString *)urlString;

@end
