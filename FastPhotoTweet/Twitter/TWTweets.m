//
//  TWTweets.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/27.
//
//

#import "TWTweets.h"
#import "TWTweet.h"

#define BLANK @""

@implementation TWTweets

+ (TWTweets *)manager {
    
    return (TWTweets *)[TWTweetsBase manager];
}

+ (NSMutableDictionary *)timelines {
    
    return [TWTweetsBase manager].timelines;
}

+ (NSMutableArray *)sendedTweets {
    
    return [TWTweetsBase manager].sendedTweets;
}

+ (NSString *)text {
    
    return [TWTweetsBase manager].text;
}

+ (NSString *)inReplyToID {
    
    return [TWTweetsBase manager].inReplyToID;
}

+ (NSString *)tabChangeFunction {
    
    return [TWTweetsBase manager].tabChangeFunction;
}

+ (NSArray *)lists {
    
    return [TWTweetsBase manager].lists;
}

+ (NSString *)listID {
    
    return [TWTweetsBase manager].listID;
}

+ (NSString *)showingListID {
    
    return [TWTweetsBase manager].showingListID;
}

#pragma mark - Timeline

+ (void)saveCurrentTimeline:(NSMutableArray *)currentTimeline {
    
    [[TWTweetsBase manager].timelines setObject:currentTimeline
                                         forKey:[TWAccounts currentAccountName]];
}

+ (NSMutableArray *)currentTimeline {
    
    return [[TWTweetsBase manager].timelines objectForKey:[TWAccounts currentAccountName]];
}

+ (NSMutableArray *)saveCurrentTimelineAndChangeAccount:(NSMutableArray *)currentTimeline forChangeAccountName:(NSString *)accontName {
    
    [self saveCurrentTimeline:currentTimeline];
    
    return [[TWTweetsBase manager].timelines objectForKey:accontName];
}

+ (NSString *)topTweetID {
    
    NSString *tweetID = nil;
    
    if ( [[TWTweets currentTimeline] isNotEmpty] ) {
    
        for ( TWTweet *tweet in [TWTweets currentTimeline] ) {

            tweetID = tweet.tweetID;
            
            if ( tweetID != nil ) break;
        }
    }
    
    return tweetID;
}

+ (NSMutableDictionary *)sinceIDs {
    
    return [TWTweetsBase manager].sinceIDs;
}

+ (void)saveSinceID:(NSString *)sinceID {
    
    [[TWTweetsBase manager].sinceIDs[[TWAccounts currentAccountName]] setObject:sinceID
                                                                         forKey:@"SinceID"];
    
    [[TWTweetsBase manager].sinceIDs[[TWAccounts currentAccountName]] setObject:@(TimelineRequestStatsSended)
                                                                         forKey:@"Status"];
}

@end
