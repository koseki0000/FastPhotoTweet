//
//  RegularExpression.m
//  UtilityClass
//
//  Created by @peace3884 on 12/02/23.
//

#import "RegularExpression.h"

@implementation RegularExpression

+ (BOOL)boolRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern {

    BOOL result = NO;
    
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:regExpPattern 
                                                                            options:0 
                                                                              error:&error];
    
    NSTextCheckingResult *match = [regexp firstMatchInString:matchString 
                                                     options:0 
                                                       range:NSMakeRange(0, matchString.length)];
    
    if (!error) {
        
        if (match.numberOfRanges != 0) {
            
            result = YES;
        }
        
    }else {
        
        [RegularExpression regExpError];
    }
    
    return result;
}

+ (NSString *)strRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern {
    
    NSString *result = [NSString string];
    
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:regExpPattern 
                                                                            options:0 
                                                                              error:&error];
    
    NSTextCheckingResult *match = [regexp firstMatchInString:matchString 
                                                     options:0 
                                                       range:NSMakeRange(0, matchString.length)];
    
    if (!error) {
        
        if (match.numberOfRanges != 0) {
            
            result = [matchString substringWithRange:match.range];
        }
        
    }else {
        
        [RegularExpression regExpError];
    }
    
    return result;
}

+ (NSMutableString *)mStrRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern {
    
    NSMutableString *result = [NSMutableString string];
    
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:regExpPattern 
                                                                            options:0 
                                                                              error:&error];
    
    NSTextCheckingResult *match = [regexp firstMatchInString:matchString 
                                                     options:0 
                                                       range:NSMakeRange(0, matchString.length)];
    
    if (!error) {
        
        if (match.numberOfRanges != 0) {
            
            result = [NSMutableString stringWithString:[matchString substringWithRange:match.range]];
        }
        
    }else {
        
        [RegularExpression regExpError];
    }
    
    return result;
}

+ (NSArray *)arrayRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern {
    
    NSArray *resultArray = [[[NSArray alloc] init] autorelease];
    NSMutableArray *tmpArray = [[[NSMutableArray alloc] initWithArray:resultArray] autorelease];
    NSString *tmp = @"";
    NSError *error = nil;
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:regExpPattern 
                                                                            options:0 
                                                                              error:&error];
    
    NSArray *match = [regexp matchesInString:matchString 
                                     options:0 
                                       range:NSMakeRange(0, 
                                                         matchString.length)];
    
    if ( !error ) {
        
        for (NSTextCheckingResult *result in match) {
            
            tmp = [matchString substringWithRange:result.range];
            [tmpArray addObject:tmp];
        }
        
    }else {
        
        [RegularExpression regExpError];
        return [NSArray array];
    }
    
    resultArray = tmpArray;
    
    return resultArray;
}

+ (NSMutableArray *)mArrayRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern {
    
    NSMutableArray *resultArray = [NSMutableArray array];
    NSString *tmp = @"";
    NSError *error = nil;
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:regExpPattern 
                                                                            options:0 
                                                                              error:&error];
    
    NSArray *match = [regexp matchesInString:matchString 
                                     options:0 
                                       range:NSMakeRange(0, 
                                                         matchString.length)];
    
    if (!error) {
        
        for (NSTextCheckingResult *result in match) {
            
            tmp = [matchString substringWithRange:result.range];
            [resultArray addObject:tmp];
        }
        
    }else {
        
        [RegularExpression regExpError];
        
        return [NSMutableArray array];
    }
    
    return resultArray;
}

+ (NSMutableArray *)urls:(id)string {
    
    NSError *error = nil;
    NSString *searchString = [NSString stringWithString:string];
    NSMutableArray *urlList = [NSMutableArray array];

    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink 
                                                                   error:&error];
    
    NSArray *matches = [linkDetector matchesInString:searchString 
                                             options:0 
                                               range:NSMakeRange(0, [searchString length])];
    
    for ( NSTextCheckingResult *match in matches ) {
        
        [urlList addObject:match.URL.absoluteString];
    }
    
    return urlList;
}

+ (void)regExpError {
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.delegate = self;
    alert.title = @"エラー";
    alert.message = @"正規表現でエラーが発生しました。";
    [alert addButtonWithTitle:@"OK"];
    [alert show];
    [alert release];
}

@end
