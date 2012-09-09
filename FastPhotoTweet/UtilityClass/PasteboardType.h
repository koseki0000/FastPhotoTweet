//
//  PasteboardType.h
//  UtilityClass
//
//  Created by @peace3884 on 12/03/01.
//

#import <Foundation/Foundation.h>
#import "ShowAlert.h"
#import "EmptyCheck.h"

@interface PasteboardType : NSObject

+ (int)check;
+ (BOOL)isText;
+ (BOOL)isImage;

@end
