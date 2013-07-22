//
//  NSString+RegularExpression.m
//

#import "NSString+RegularExpression.h"

@implementation NSString (RegularExpression)

#pragma mark - BOOL

- (BOOL)boolWithRegExp:(NSString *)regExpPattern {
    
    if ( regExpPattern == nil ) {
        
        return NO;
    }
    
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:regExpPattern
                                                                            options:0
                                                                              error:&error];
    
    NSTextCheckingResult *match = [regexp firstMatchInString:self
                                                     options:0
                                                       range:NSMakeRange(0, self.length)];
    
    if ( !error ) {
        
        if ( match.numberOfRanges != 0 ) {
            
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - NSString

- (NSString *)stringWithRegExp:(NSString *)regExpPattern {
    
    return [NSString stringWithString:[self mutableStringWithRegExp:regExpPattern]];
}

- (NSMutableString *)mutableStringWithRegExp:(NSString *)regExpPattern {
    
    if ( regExpPattern == nil ) {
        
        return [NSMutableString string];
    }
    
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:regExpPattern
                                                                            options:0
                                                                              error:&error];
    
    NSTextCheckingResult *match = [regexp firstMatchInString:self
                                                     options:0
                                                       range:NSMakeRange(0, self.length)];
    
    if ( !error ) {
        
        if ( match.numberOfRanges != 0 ) {
            
            return [NSMutableString stringWithString:[self substringWithRange:match.range]];
        }
    }
    
    return [NSMutableString string];
}

#pragma mark - NSArray

- (NSArray *)arrayWithRegExp:(NSString *)regExpPattern {
    
    return [NSArray arrayWithArray:[self mutableArrayWithRegExp:regExpPattern]];
}

- (NSMutableArray *)mutableArrayWithRegExp:(NSString *)regExpPattern {
    
    if ( regExpPattern == nil ) {
        
        return [NSMutableArray array];
    }
    
    NSMutableArray *resultArray = [NSMutableArray array];
    NSError *error = nil;
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:regExpPattern
                                                                            options:0
                                                                              error:&error];
    
    NSArray *match = [regexp matchesInString:self
                                     options:0
                                       range:NSMakeRange(0, self.length)];
    
    if ( !error ) {
        
        for ( NSTextCheckingResult *result in match ) {
            
            [resultArray addObject:[self substringWithRange:result.range]];
        }
    }
    
    return resultArray;
}

- (NSMutableArray *)URLs {
    
    NSError *error = nil;
    NSMutableArray *urlList = [NSMutableArray array];
    
    NSDataDetector *linkDetector = [[[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink
                                                                    error:&error] autorelease];
    
    NSArray *matches = [linkDetector matchesInString:self
                                             options:0
                                               range:NSMakeRange(0, [self length])];
    
    if ( !error ) {
        
        for ( NSTextCheckingResult *match in matches ) {
            
            [urlList addObject:match.URL.absoluteString];
        }
    }
    
    return urlList;
}

- (NSArray *)URLRanges {
    
    NSError *error = nil;
    NSMutableArray *ranges = [NSMutableArray array];
    
    NSDataDetector *linkDetector = [[[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink
                                                                    error:&error] autorelease];
    
    NSArray *matches = [linkDetector matchesInString:self
                                             options:0
                                               range:NSMakeRange(0, [self length])];
    
    if ( !error ) {
        
        for ( NSTextCheckingResult *match in matches ) {
            
            [ranges addObject:[NSValue valueWithRange:match.range]];
        }
    }
    
    return ranges;
}

- (NSMutableArray *)twitterIDs {
    
    return [self mutableArrayWithRegExp:@"@[\\w]{1,15}"];
}

#pragma mark - ReplaceNSString

- (NSString *)replaceStringWithRegExp:(NSString *)regExpPattern
                        targetWord:(NSString *)targetWord {
    
    return [NSString stringWithString:[self replaceMutableStringWithRegExp:regExpPattern targetWord:targetWord]];
}

- (NSString *)replaceMutableStringWithRegExp:(NSString *)regExpPattern
                         targetWord:(NSString *)targetWord {
    
    NSError *error = nil;
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:regExpPattern
                                                                            options:0
                                                                              error:&error];
    
    if ( !error ) {
        
        return [[[regexp stringByReplacingMatchesInString:self
                                                  options:0
                                                    range:NSMakeRange(0, self.length)
                                             withTemplate:targetWord] mutableCopy] autorelease];
        
    } else {
        
        return @"";
    }
}

@end
