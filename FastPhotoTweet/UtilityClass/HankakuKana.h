//
//  HankakuKana.h
//  UtilityClass
//
//  Created by @peace3884 on 12/04/30.
//

#import <Foundation/Foundation.h>

@interface HankakuKana : NSObject

+ (NSString *)kana:(id)string;
+ (NSString *)hiragana:(id)string;
+ (NSString *)kanaHiragana:(id)string;

@end
