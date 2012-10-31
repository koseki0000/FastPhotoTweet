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

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        [[TWTweetsBase manager].timelines setObject:currentTimeline
                                             forKey:[TWAccounts currentAccountName]];
        
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

#pragma mark - SinceIDs

+ (void)saveSinceID:(NSString *)tweetID {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_async(queue, ^{
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        [[TWTweetsBase manager].sinceIDs setObject:tweetID forKey:[TWAccounts currentAccountName]];
        
        dispatch_semaphore_signal(semaphore);
        dispatch_release(semaphore);
    });
}

+ (void)saveSinceID:(NSString *)tweetID forAccountName:(NSString *)accountName {
    
    [self saveSinceID:tweetID forAccountName:accountName];
}

+ (NSString *)currentSinceID {
    
    return [[TWTweetsBase manager].sinceIDs objectForKey:[TWAccounts currentAccountName]];
}

@end
