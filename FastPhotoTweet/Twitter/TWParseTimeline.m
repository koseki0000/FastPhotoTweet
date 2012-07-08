//
//  TWParseTimeline.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import "TWParseTimeline.h"

#define DATE_FORMAT @"HH:mm:ss"
#define BLANK @""

@implementation TWParseTimeline

//in: create_at
//out: JSTタイムゾーン適用済み時刻
+ (NSString *)date:(NSString *)tweetData {
    
    NSString *date = [tweetData substringWithRange:NSMakeRange(11,8)];
    
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
	[inputDateFormatter setDateFormat:DATE_FORMAT];

	NSDate *inputDate = [inputDateFormatter dateFromString:date];
	
	NSString *jstDate = [[[inputDate initWithTimeInterval:64800 sinceDate:inputDate] description] substringWithRange:NSMakeRange(11,8)];
    
    return jstDate;
}

//in: source
//out: クライアント名
+ (NSString *)client:(NSString *)tweetData {
    
    NSError *error = nil;
	NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@">.{1,160}<" 
                                                                            options:0 
                                                                              error:&error];
    
    //エラーの場合は空白文字を返す
    if ( error ) return BLANK;
    
	NSTextCheckingResult *match = [regexp firstMatchInString:tweetData 
                                                     options:0 
                                                       range:NSMakeRange(0, tweetData.length)];
	
	if ( match.numberOfRanges != 0 ) {
        
		tweetData = [tweetData substringWithRange:[match rangeAtIndex:0]];
		tweetData = [tweetData substringWithRange:NSMakeRange( 1, tweetData.length-2 )];
	}
    
    return tweetData;
}

@end
