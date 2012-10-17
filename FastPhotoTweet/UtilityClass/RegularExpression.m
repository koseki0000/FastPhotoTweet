//
//  RegularExpression.m
//  UtilityClass
//
//  Created by @peace3884 on 12/02/23.
//

#import "RegularExpression.h"

@implementation RegularExpression

+ (BOOL)boolWithRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern {
    
    BOOL result = NO;
    
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:regExpPattern
                                                                            options:0
                                                                              error:&error];
    
    NSTextCheckingResult *match = [regexp firstMatchInString:matchString
                                                     options:0
                                                       range:NSMakeRange(0, matchString.length)];
    
    if ( !error ) {
        
        if ( match.numberOfRanges != 0 ) {
            
            //正規表現にマッチ
            result = YES;
        }
        
    }else {
        
        //正規表現でエラー
        [RegularExpression regExpError];
    }
    
    return result;
}

+ (NSString *)strWithRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern {
    
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

+ (NSMutableString *)mStrWithRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern {
    
    //マッチした文字列を格納する
    NSMutableString *result = [NSMutableString string];
    
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:regExpPattern
                                                                            options:0
                                                                              error:&error];
    
    NSTextCheckingResult *match = [regexp firstMatchInString:matchString
                                                     options:0
                                                       range:NSMakeRange(0, matchString.length)];
    
    if ( !error ) {
        
        if ( match.numberOfRanges != 0 ) {
            
            //正規表現でマッチした文字列を可変長にする
            result = [NSMutableString stringWithString:[matchString substringWithRange:match.range]];
        }
        
    }else {
        
        //正規表現でエラー
        [RegularExpression regExpError];
    }
    
    return result;
}

+ (NSArray *)arrayWithRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern {
    
    //マッチした文字列を格納する
    NSMutableArray *resultArray = [NSMutableArray array];
    NSError *error = nil;
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:regExpPattern
                                                                            options:0
                                                                              error:&error];
    
    NSArray *match = [regexp matchesInString:matchString
                                     options:0
                                       range:NSMakeRange(0,
                                                         matchString.length)];
    
    if ( !error ) {
        
        for ( NSTextCheckingResult *result in match ) {
            
            [resultArray addObject:[matchString substringWithRange:result.range]];
        }
        
    }else {
        
        //正規表現でエラー
        [RegularExpression regExpError];
        return [NSArray array];
    }
    
    //固定長にして返す
    return [NSArray arrayWithArray:resultArray];
}

+ (NSMutableArray *)mArrayWithRegExp:(NSString *)matchString regExpPattern:(NSString *)regExpPattern {
    
    //マッチした文字列を格納する
    NSMutableArray *resultArray = [NSMutableArray array];
    NSError *error = nil;
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:regExpPattern
                                                                            options:0
                                                                              error:&error];
    
    NSArray *match = [regexp matchesInString:matchString
                                     options:0
                                       range:NSMakeRange(0,
                                                         matchString.length)];
    
    if ( !error ) {
        
        for ( NSTextCheckingResult *result in match ) {
            
            [resultArray addObject:[matchString substringWithRange:result.range]];
        }
        
    }else {
        
        //正規表現でエラー
        [RegularExpression regExpError];
        return [NSMutableArray array];
    }
    
    return resultArray;
}

+ (NSMutableArray *)urls:(id)string {
    
    //stringが空の場合終了
    if ( string == nil ) return [NSMutableArray array];
    
    //NSStringでもNSMutableStringでもない場合は終了
    if ( ![string isKindOfClass:[NSString class]] &&
        ![string isKindOfClass:[NSMutableString class]] ) return [NSMutableArray array];
    
    NSError *error = nil;
    
    //NSMutableString型にする
    NSString *searchString = [NSString stringWithString:string];
    
    //URLを格納する
    NSMutableArray *urlList = [NSMutableArray array];
    
    //URLを判定する
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink
                                                                   error:&error];
    
    NSArray *matches = [linkDetector matchesInString:searchString
                                             options:0
                                               range:NSMakeRange(0, [searchString length])];
    
    for ( NSTextCheckingResult *match in matches ) {
        
        //マッチしたURLを配列に追加
        [urlList addObject:match.URL.absoluteString];
    }
    
    return urlList;
}

+ (NSMutableArray *)twitterIds:(id)searchString {
    
    //stringが空の場合終了
    if ( searchString == nil ) return [NSMutableArray array];
    
    //NSStringでもNSMutableStringでもない場合は終了
    if ( ![searchString isKindOfClass:[NSString class]] &&
        ![searchString isKindOfClass:[NSMutableString class]] ) return [NSMutableArray array];
    
    //NSStringにする
    NSString *string = [NSString stringWithString:searchString];
    
    //マッチしたTwitterIDを配列化して返す
    return [RegularExpression mArrayWithRegExp:string regExpPattern:@"@[a-zA-Z0-9_]{1,15}"];
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
