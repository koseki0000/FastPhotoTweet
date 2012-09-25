//
//  RegularExpression.h
//  UtilityClass
//
//  Created by @peace3884 on 12/02/23.
//

#import <Foundation/Foundation.h>

@interface RegularExpression : NSObject

+ (BOOL)boolWithRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern;
+ (NSString *)strWithRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern;
+ (NSMutableString *)mStrWithRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern;
+ (NSArray *)arrayWithRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern;
+ (NSMutableArray *)mArrayWithRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern;

+ (NSMutableArray *)urls:(id)string;
+ (NSMutableArray *)twitterIds:(id)searchString;

+ (void)regExpError;

@end