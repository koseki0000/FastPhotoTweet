//
//  PasteboardType.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/03/01.
//

#import <Foundation/Foundation.h>
#import "ShowAlert.h"

@interface PasteboardType : NSObject

+ (int)check;
+ (BOOL)isText;
+ (BOOL)isImage;

@end
