//
//  TWTweets.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/27.
//
//

#import "TWTweets.h"

#define BLANK @""
#define API_VERSION @"1"

@implementation TWTweets

+ (TWTweets *)manager {
    
    return (TWTweets *)[TWTweetsBase manager];
}

+ (NSMutableDictionary *)timelines {
    
    return [TWTweetsBase manager].timelines;
}

+ (NSMutableDictionary *)sinceIDs {
    
    return [TWTweetsBase manager].sinceIDs;
}

#pragma mark - Timeline

+ (void)saveCurrentTimeline:(NSMutableArray *)currentTimeline {
    
    @synchronized(self) {
        
        [[TWTweetsBase manager].timelines setObject:currentTimeline forKey:[TWAccounts currentAccountName]];
    }
}

+ (NSMutableArray *)currentTimeline {
    
    return [[TWTweetsBase manager].timelines objectForKey:[TWAccounts currentAccountName]];
}

+ (NSMutableArray *)saveCurrentTimelineAndChangeAccount:(NSMutableArray *)currentTimeline forChangeAccountName:(NSString *)accontName {
    
    [self saveCurrentTimeline:currentTimeline];
    
    return [[TWTweetsBase manager].timelines objectForKey:accontName];
}

#pragma mark - SinceIDs

+ (void)saveSinceID:(NSString *)tweetID {
    
    @synchronized(self) {
        
        [[TWTweetsBase manager].sinceIDs setObject:tweetID forKey:[TWAccounts currentAccountName]];
    }
}

+ (void)saveSinceID:(NSString *)tweetID forAccountName:(NSString *)accountName {
    
    [self saveSinceID:tweetID forAccountName:accountName];
}

+ (NSString *)currentSinceID {
    
    return [[TWTweetsBase manager].sinceIDs objectForKey:[TWAccounts currentAccountName]];
}

@end
