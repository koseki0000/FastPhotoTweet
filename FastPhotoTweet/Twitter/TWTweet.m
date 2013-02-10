//
//  TWTweet.m
//

#import "TWTweet.h"
#import "TWTweetUtility.h"
#import "TWAccounts.h"
#import "TWParser.h"
#import "NSString+RegularExpression.h"
#import "NSString+Calculator.h"

@implementation TWTweet

#define SEARCH_PATH [NSString stringWithFormat:@"%@_%@", tweet.screenName, [tweet.iconURL lastPathComponent]]
#define RT_SEARCH_PATH [NSString stringWithFormat:@"%@_%@", tweet.rtUserName, [tweet.rtIconURL lastPathComponent]]
#define SCREEN_NAME [tweet isReTweet] ? tweetDictionary[@"retweeted_status"][@"user"][@"screen_name"] : tweetDictionary[@"user"][@"screen_name"]
#define ICON_URL [tweet isReTweet] ? tweetDictionary[@"retweeted_status"][@"user"][@"profile_image_url"] : tweetDictionary[@"user"][@"profile_image_url"]

- (void)debugLog {
    
    NSLog(@"entities.urls: %@", self.entities.urls);
    NSLog(@"entities.userMentions: %@", self.entities.userMentions);
    
    NSLog(@"text: %@", self.text);
    NSLog(@"screenName: %@", self.screenName);
    NSLog(@"iconURL: %@", self.iconURL);
    NSLog(@"iconSearchPath: %@", self.iconSearchPath);
    NSLog(@"infoText: %@", self.infoText);
    NSLog(@"inReplyToID: %@", self.inReplyToID);
    NSLog(@"tweetID: %@", self.tweetID);
    NSLog(@"source: %@", self.source);
    NSLog(@"createdAt: %@", self.createdAt);
    
    NSLog(@"rtUserName: %@", self.rtUserName);
    NSLog(@"rtIconURL: %@", self.rtIconURL);
    NSLog(@"rtIconSearchPath: %@", self.rtIconSearchPath);
    NSLog(@"rtID: %@", self.rtID);
    
    NSLog(@"textColor: %d", self.textColor);
    NSLog(@"cellHeight: %.0f", self.cellHeight);
    NSLog(@"isMyTweet: %@", self.isMyTweet ? @"YES" : @"NO");
    NSLog(@"isReply: %@", self.isReply ? @"YES" : @"NO");
    NSLog(@"isReTweet: %@", self.isReTweet ? @"YES" : @"NO");
    NSLog(@"isFavorited: %@", self.isFavorited ? @"YES" : @"NO");
    NSLog(@"-------------------------");
}

+ (TWTweet *)tweetWithDictionary:(NSDictionary *)tweetDictionary {
    
//    NSLog(@"%s", __func__);
    
    TWTweet *tweet = [[TWTweet alloc] init];
    
    //RT判定
    [tweet setIsReTweet:[tweetDictionary[@"retweeted_status"][@"id"] boolValue]];
    //ふぁぼり判定
    [tweet setIsFavorited:[tweetDictionary[@"favorited"] boolValue]];
    //Reply判定
    [tweet setIsReply:[tweet.text boolWithRegExp:tweet.screenName]];
    //自分のTweet判定
    [tweet setIsMyTweet:[tweet.screenName isEqualToString:[TWAccounts currentAccountName]]];
    
    [tweet setIconURL:ICON_URL];
    [tweet setScreenName:SCREEN_NAME];
    [tweet setTweetID:tweetDictionary[@"id_str"]];
    
    //アイコン検索名
    [tweet setIconSearchPath:SEARCH_PATH];
    
    if ( [tweet isReTweet] ) {
        
        //RTのテキスト
        [tweet setText:tweetDictionary[@"retweeted_status"][@"text"]];
        
        //RTした人
        [tweet setRtUserName:tweetDictionary[@"retweeted_status"][@"user"][@"screen_name"]];
        
        [tweet setSource:[TWParser client:tweetDictionary[@"retweeted_status"][@"source"]]];
        [tweet setCreatedAt:[TWParser JSTDate:tweetDictionary[@"retweeted_status"][@"created_at"]]];
        [tweet setRtUserName:tweetDictionary[@"user"][@"screen_name"]];
        [tweet setRtIconURL:tweetDictionary[@"user"][@"profile_image_url"]];
        [tweet setRtIconSearchPath:RT_SEARCH_PATH];
        [tweet setTweetID:tweetDictionary[@"retweeted_status"][@"id_str"]];
        
    }else {
        
        [tweet setText:tweetDictionary[@"text"]];
        
        [tweet setSource:[TWParser client:tweetDictionary[@"source"]]];
        [tweet setCreatedAt:[TWParser JSTDate:tweetDictionary[@"created_at"]]];
    }
    
    [tweet setEntities:[TWTweetEntities entitiesWithDictionary:tweetDictionary]];
    
    //t.coを展開
    [tweet setText:[TWTweetUtility openTco:tweet.text
                              fromEntities:tweet.entities]];
    
    //参照文字列を置換
    [tweet setText:[TWTweetUtility replaceCharacterReference:tweet.text]];
    
    tweet = [TWTweetUtility createTimelineCellInfo:tweet];
    
//    [tweet debugLog];
    
    return tweet;
}

@end
