//
//  RegularExpression.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <Foundation/Foundation.h>

@interface RegularExpression : NSObject

+ (BOOL)boolRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern;
+ (NSString *)strRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern;
+ (NSMutableString *)mStrRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern;
+ (NSArray *)arrayRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern;
+ (NSMutableArray *)mArrayRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern;

+ (void)regExpError;

@end