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

#pragma mark - Timeline

+ (void)saveCurrentTimeline:(NSMutableArray *)currentTimeline {

    __block __weak NSMutableDictionary *wTimelines = [TWTweetsBase manager].timelines;
    __block __weak NSString *wCurrentAccountName = [TWAccounts currentAccountName];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        [wTimelines setObject:currentTimeline
                       forKey:wCurrentAccountName];
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
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
    
    __block __weak NSMutableDictionary *wSinceIDs = [TWTweetsBase manager].sinceIDs;
    __block __weak NSString *wCurrentAccountName = [TWAccounts currentAccountName];
    __block __weak NSString *wSinceID = sinceID;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        [[wSinceIDs objectForKey:wCurrentAccountName] setObject:wSinceID forKey:@"SinceID"];
        [[wSinceIDs objectForKey:wCurrentAccountName] setObject:@(TimelineRequestStatsSended) forKey:@"Status"];
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

@end
