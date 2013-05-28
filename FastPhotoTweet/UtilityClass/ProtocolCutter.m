//
//  ProtocolCutter.m
//  UtilityClass
//
//  Created by @peace3884 on 12/02/23.
//

#import "ProtocolCutter.h"

@implementation ProtocolCutter

+ (NSString *)url:(NSString *)URLString {
    
    NSString *originalURLString = URLString;
    
    @try {
        
        NSError *error = nil;
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z]+://" 
                                                                                options:0 
                                                                                  error:&error];
        
        NSTextCheckingResult *match = [regexp firstMatchInString:URLString 
                                                         options:0 
                                                           range:NSMakeRange(0, URLString.length)];
        
        if (!error) {
            
            if (match.numberOfRanges != 0) {
                
                NSString *protocol = [URLString substringWithRange:match.range];
                
                if (![protocol hasPrefix:@"https"]) {
                    
                    URLString = [URLString substringWithRange:NSMakeRange(protocol.length, 
                                                                          URLString.length - protocol.length)];
                }
                
                if ([URLString hasSuffix:@"/"]) {
                    
                    URLString = [URLString substringWithRange:NSMakeRange(0, 
                                                                          URLString.length - 1)];
                }
            }
            
        } else {
            
            return originalURLString;
        }
        
    }@catch (NSException *e) {
        
        return originalURLString;
    }
    
    return URLString;
}

@end
