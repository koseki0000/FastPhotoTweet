//
//  EncodeImage.h
//  UtilityClass
//
//  Created by @peace3884 on 12/04/15.
//

#import <Foundation/Foundation.h>

@interface EncodeImage : NSObject

+ (NSData *)image:(UIImage *)encodeImage;
+ (NSData *)jpgLow:(UIImage *)encodeImage;
+ (NSData *)jpg:(UIImage *)encodeImage;
+ (NSData *)jpgHigh:(UIImage *)encodeImage;
+ (NSData *)png:(UIImage *)encodeImage;

@end
