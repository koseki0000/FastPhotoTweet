//
//  DeleteWhiteSpace.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/06/02.
//

#import "DeleteWhiteSpace.h"

@implementation DeleteWhiteSpace

+ (NSString *)string:(NSString *)string {
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^[\\s]+" 
                                                                            options:0 
                                                                              error:nil];
    
    string = [regexp stringByReplacingMatchesInString:string
                                              options:0
                                                range:NSMakeRange(0, string.length)
                                         withTemplate:@""];
    
    regexp = [NSRegularExpression regularExpressionWithPattern:@"[\\s]+$" 
                                                       options:0 
                                                         error:nil];
    
    string = [regexp stringByReplacingMatchesInString:string
                                              options:0
                                                range:NSMakeRange(0, string.length)
                                         withTemplate:@""];

    return string;
}

@end
