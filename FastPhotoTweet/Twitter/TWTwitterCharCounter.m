//
//  TWTwitterCharCounter.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/25.
//

#import "TWTwitterCharCounter.h"

@implementation TWTwitterCharCounter

+ (int)charCounter:(id)post {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *postString = [NSString stringWithString:post];
    
    int num = 140;
    int originalCharNum = postString.length;
    int urlCount = 0;
    NSMutableArray *urlList = [NSMutableArray array];
    
    @try {
        
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"https?:([^\\x00-\\x20()\"<>\\x7F-\\xFF])*" 
                                                                                options:0 
                                                                                  error:nil];
        
        NSArray *match = [regexp matchesInString:post 
                                         options:0 
                                           range:NSMakeRange(0, postString.length)];
        
        for (NSTextCheckingResult *result in match) {
            
            NSString *matchString = [post substringWithRange:result.range];
            [urlList addObject:matchString];
            urlCount++;
            
        }
        
        for (NSString *tmp in urlList) {
            
            [post replaceOccurrencesOfString:tmp withString:@"" 
                                     options:0 
                                       range:NSMakeRange(0, postString.length)];
            
        }
        
        num = num - postString.length - urlCount * 20;
        
    }@catch (NSException *e) {
        
        return originalCharNum;
        
    }@finally {
        
        [pool drain];
        
    }
    
    return num;
}

@end
