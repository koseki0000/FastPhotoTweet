//
//  TWParser
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

/////////////////////////////
//////// ARC ENABLED ////////
/////////////////////////////

#import "TWParser.h"

#define DATE_FORMAT @"HH:mm:ss"
#define BLANK @""

@implementation TWParser

//in: create_at
//out: JSTタイムゾーン適用済み時刻
+ (NSString *)JSTDate:(NSString *)tweetData {
    
    NSString *date = [tweetData substringWithRange:NSMakeRange(11,8)];
    
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
	[inputDateFormatter setDateFormat:DATE_FORMAT];

	NSDate *inputDate = [inputDateFormatter dateFromString:date];
	
	NSString *jstDate = [[[inputDate initWithTimeInterval:64800 sinceDate:inputDate] description] substringWithRange:NSMakeRange(11,8)];
    
    return jstDate;
}

+ (NSString *)date:(NSString *)tweetData {
        
    return [tweetData substringWithRange:NSMakeRange(11,8)];
}

//in: source
//out: クライアント名
+ (NSString *)client:(NSString *)tweetData {
    
    NSString *clientName = nil;
    
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
        
        //クライアント名が取得できた場合
		tweetData = [tweetData substringWithRange:[match rangeAtIndex:0]];
		clientName = [tweetData substringWithRange:NSMakeRange( 1, tweetData.length-2 )];
	}
    
    //クライアント名が取得できなかった場合
    if ( clientName == nil ) return BLANK;
    
    return clientName;
}

+ (NSDictionary *)rtText:(NSDictionary *)tweet {
    
    NSString *userMentionsScreenName = [[[[tweet objectForKey:@"entities"] objectForKey:@"user_mentions"] objectAtIndex:0] objectForKey:@"screen_name"];
    NSString *reTweetText = [NSString stringWithFormat:@"RT @%@: %@", userMentionsScreenName, [[tweet objectForKey:@"retweeted_status"] objectForKey:@"text"]];
    
    NSMutableDictionary *mutableCurrentTweet = [NSMutableDictionary dictionaryWithDictionary:tweet];
    [mutableCurrentTweet setObject:reTweetText forKey:@"text"];
    
    return [NSDictionary dictionaryWithDictionary:mutableCurrentTweet];
}

@end
