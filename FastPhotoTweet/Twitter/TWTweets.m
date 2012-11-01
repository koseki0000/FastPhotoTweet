//
//  TWTweets.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/27.
//
//

#import "TWTweets.h"

#define BLANK @""

@implementation TWTweets

+ (TWTweets *)manager {
    
    return (TWTweets *)[TWTweetsBase manager];
}

+ (NSMutableDictionary *)timelines {
    
    return [TWTweetsBase manager].timelines;
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

+ (NSString *)topTweetID {
    
    NSString *tweetID = nil;
    
    if ( [[TWTweets currentTimeline] isNotEmpty] ) {
    
        BOOL reTweet = [[[[[TWTweets currentTimeline] objectAtIndex:0] objectForKey:@"retweeted_status"] objectForKey:@"id"] boolValue];
        
        if ( reTweet ) {
            
            tweetID = [[[[TWTweets currentTimeline] objectAtIndex:0] objectForKey:@"retweeted_status"] objectForKey:@"id_str"];
            
        }else {
         
            tweetID = [[[TWTweets currentTimeline] objectAtIndex:0] objectForKey:@"id_str"];
        }
    }
    
    return tweetID;
}

@end
