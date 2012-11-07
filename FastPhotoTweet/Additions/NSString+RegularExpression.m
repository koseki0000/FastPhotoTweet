//
//  NSString+RegularExpression.m
//  FastPhotoTweet
//
//  Created by @peace3884 12/11/07.
//

#import "NSString+RegularExpression.h"

@implementation NSString (RegularExpression)

#pragma mark - BOOL

- (BOOL)boolWithRegExp:(NSString *)regExpPattern {
    
    if ( self == nil || regExpPattern == nil ) {
        
        return NO;
    }
    
    NSError *error = nil;
    NSRegularExpression *regexp = [[NSRegularExpression alloc] initWithPattern:regExpPattern
                                                                       options:0
                                                                         error:&error];
    
    NSTextCheckingResult *match = [regexp firstMatchInString:self
                                                     options:0
                                                       range:NSMakeRange(0, self.length)];
    [regexp release];
    
    if ( !error ) {
        
        if ( match.numberOfRanges != 0 ) {
            
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - NSString

- (NSString *)strWithRegExp:(NSString *)regExpPattern {
    
    return [NSString stringWithString:[self mStrWithRegExp:regExpPattern]];
}

- (NSMutableString *)mStrWithRegExp:(NSString *)regExpPattern {
    
    if ( self == nil || regExpPattern == nil ) {
        
        return [NSMutableString string];
    }
    
    NSError *error = nil;
    NSRegularExpression *regexp = [[NSRegularExpression alloc] initWithPattern:regExpPattern
                                                                       options:0
                                                                         error:&error];
    
    NSTextCheckingResult *match = [regexp firstMatchInString:self
                                                     options:0
                                                       range:NSMakeRange(0, self.length)];
    [regexp release];
    
    if ( !error ) {
        
        if ( match.numberOfRanges != 0 ) {
            
            return [NSMutableString stringWithString:[self substringWithRange:match.range]];
        }
    }
    
    return [NSMutableString string];
}

#pragma mark - NSArray

- (NSArray *)arrayWithRegExp:(NSString *)regExpPattern {
    
    return [NSArray arrayWithArray:[self mArrayWithRegExp:regExpPattern]];
}

- (NSMutableArray *)mArrayWithRegExp:(NSString *)regExpPattern {
    
    if ( self == nil || regExpPattern == nil ) {
        
        return [NSMutableArray array];
    }
    
    NSMutableArray *resultArray = [[[NSMutableArray alloc] init] autorelease];
    NSError *error = nil;
    
    NSRegularExpression *regexp = [[NSRegularExpression alloc] initWithPattern:regExpPattern
                                                                       options:0
                                                                         error:&error];
    
    NSArray *match = [regexp matchesInString:self
                                     options:0
                                       range:NSMakeRange(0, self.length)];
    [regexp release];
    
    if ( !error ) {
        
        for ( NSTextCheckingResult *result in match ) {
            
            [resultArray addObject:[self substringWithRange:result.range]];
        }
    }
    
    return resultArray;
}

- (NSMutableArray *)urls {
    
    if ( self == nil ) {
        
        return [NSMutableArray array];
    }
    
    NSError *error = nil;
    NSString *searchString = [[NSString alloc] initWithString:self];
    NSMutableArray *urlList = [[[NSMutableArray alloc] init] autorelease];
    
    NSDataDetector *linkDetector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink
                                                                   error:&error];
    
    NSArray *matches = [linkDetector matchesInString:searchString
                                             options:0
                                               range:NSMakeRange(0, [searchString length])];
    [linkDetector release];
    
    if ( !error ) {
     
        for ( NSTextCheckingResult *match in matches ) {
            
            [urlList addObject:match.URL.absoluteString];
        }
    }
    
    [searchString release];
    
    return urlList;
}

- (NSMutableArray *)twitterIds {
    
    if ( self == nil ) {
        
        return [NSMutableArray array];
    }
    
    return [self mArrayWithRegExp:@"@[a-zA-Z0-9_]{1,15}"];
}

#pragma mark - ReplaceNSString

- (NSString *)replaceStrWithRegExp:(NSString *)regExpPattern
                        targetWord:(NSString *)targetWord {
    
    return [NSString stringWithString:[self replaceMStrWithRegExp:regExpPattern targetWord:targetWord]];
}

- (NSString *)replaceMStrWithRegExp:(NSString *)regExpPattern
                         targetWord:(NSString *)targetWord {
    
    NSString *tempString = [NSString stringWithString:self];
    NSError *error = nil;
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:regExpPattern
                                                                            options:0
                                                                              error:&error];
    
    if ( !error ) {
        
        return tempString = [regexp stringByReplacingMatchesInString:tempString
                                                             options:0
                                                               range:NSMakeRange(0, tempString.length)
                                                        withTemplate:targetWord];
        
    }else {
        
        return @"";
    }
}

@end
