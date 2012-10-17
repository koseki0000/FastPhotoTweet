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
    
    @autoreleasepool {
        
        NSString *jstDate = BLANK;
        
        @try {
            
            //時刻のトリム開始位置
            int from = 11;
            
            //,がある場合はTwitterSearchのパターン
            //トリム開始位置を変更
            if ( [tweetData rangeOfString:@","].location != NSNotFound ) from = 17;
            
            //時刻部分を抜き出す
            NSString *date = [tweetData substringWithRange:NSMakeRange(from, 8)];
            
            //時刻フォーマットを指定
            NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
            [inputDateFormatter setDateFormat:DATE_FORMAT];
            
            //時刻を指定フォーマットに合わせる
            NSDate *inputDate = [inputDateFormatter dateFromString:date];
            
            //JSTタイムゾーンを適用し、時刻部分を抜き出す
            jstDate = [[[NSDate dateWithTimeInterval:64800 sinceDate:inputDate] description] substringWithRange:NSMakeRange(11, 8)];
            
        }@catch ( NSException *e ) {
            
            return BLANK;
        }
        
        //JSTタイムゾーン適用済み時刻をHH:mm:ss形式で返却
        return jstDate;
    }
}

+ (NSString *)date:(NSString *)tweetData {
        
    return [tweetData substringWithRange:NSMakeRange(11,8)];
}

//in: source
//out: クライアント名
+ (NSString *)client:(NSString *)tweetData {
    
    NSString *clientName = BLANK;
    
    @try {
        
        if ( [tweetData isEqualToString:@"web"] ) return @"web";
        
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
        
    }@catch ( NSException *e ) {
        
        return BLANK;
    }
    
    return clientName;
}

+ (NSDictionary *)rtText:(NSDictionary *)tweet {
    
    NSString *originalText =  [[tweet objectForKey:@"retweeted_status"] objectForKey:@"text"];
    NSString *postUser =     [[[tweet objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"screen_name"];
    NSString *postUserIcon = [[[tweet objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"profile_image_url"];
    NSString *rtUser = [[tweet objectForKey:@"user"] objectForKey:@"screen_name"];
    
    NSMutableDictionary *user = [NSMutableDictionary dictionaryWithDictionary:[tweet objectForKey:@"user"]];
    [user setObject:postUser forKey:@"screen_name"];
    [user setObject:postUserIcon forKey:@"profile_image_url"];
    
    NSMutableDictionary *mutableCurrentTweet = [NSMutableDictionary dictionaryWithDictionary:tweet];
    [mutableCurrentTweet setObject:originalText forKey:@"text"];
    [mutableCurrentTweet setObject:user forKey:@"user"];
    [mutableCurrentTweet setObject:rtUser forKey:@"rt_user"];
    
    return [NSDictionary dictionaryWithDictionary:mutableCurrentTweet];
}

@end
