//
//  DeleteWhiteSpace.m
//  UtilityClass
//
//  Created by @peace3884 on 12/06/02.
//

#import "DeleteWhiteSpace.h"

#define BLANK @""

@implementation DeleteWhiteSpace

//行頭、末尾の空白文字を削除
+ (NSString *)string:(NSString *)string {
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^[\\s]+" 
                                                                            options:0 
                                                                              error:nil];
    
    string = [regexp stringByReplacingMatchesInString:string
                                              options:0
                                                range:NSMakeRange(0, string.length)
                                         withTemplate:BLANK];
    
    regexp = [NSRegularExpression regularExpressionWithPattern:@"[\\s]+$" 
                                                       options:0 
                                                         error:nil];
    
    string = [regexp stringByReplacingMatchesInString:string
                                              options:0
                                                range:NSMakeRange(0, string.length)
                                         withTemplate:BLANK];

    return string;
}

@end
