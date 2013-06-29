//
//  TWTweets.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/27.
//
//

#import "NSObject+EmptyCheck.h"
#import "NSDictionary+DataExtraction.h"
#import "NSArray+AppendUtil.h"

#import "TWTweets.h"
#import "TWTweet.h"
#import "TWAccounts.h"

#define BLANK @""

@implementation TWTweets

static TWTweets *sharedObject = nil;

+ (TWTweets *)manager {
    
    if ( sharedObject == nil ) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            [[self alloc] init];
        });
    }
    
    return sharedObject;
}

+ (id)allocWithZone:(NSZone *)zone {
    
    if ( sharedObject == nil ) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            sharedObject = [super allocWithZone:zone];
            
            sharedObject.timelines = [NSMutableDictionary dictionary];
            sharedObject.sinceIDs = [NSMutableDictionary dictionary];
            sharedObject.sendedTweets = [NSMutableArray array];
            sharedObject.text = @"";
            sharedObject.inReplyToID = @"";
            sharedObject.tabChangeFunction = @"";
            sharedObject.lists = @[];
            sharedObject.listID = @"";
            sharedObject.showingListID = @"";
            
            for ( ACAccount *account in [[TWAccounts manager] twitterAccounts] ) {
                
                [sharedObject.timelines setObject:[NSMutableArray array] forKey:account.username];
                [sharedObject.sinceIDs setObject:[NSDictionary dictionary] forKey:account.username];
            }
        });
        
        return sharedObject;
    }
    
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    
    return self;
}

- (id)retain {
    
    return self;
}

- (unsigned)retainCount {
    
    return UINT_MAX;
}

- (oneway void)release {
    
}

- (id)autorelease {
    
    return self;
}

- (void)dealloc {
    
    [self setTimelines:nil];
    [self setSinceIDs:nil];
    
    [super dealloc];
}

#pragma mark - Timeline

+ (void)saveCurrentTimeline:(NSMutableArray *)currentTimeline {
    
    [[TWTweets manager].timelines setObject:currentTimeline
                                     forKey:[TWAccounts currentAccountName]];
}

+ (NSMutableArray *)currentTimeline {
    
    return [[TWTweets manager].timelines objectForKey:[TWAccounts currentAccountName]];
}

+ (NSMutableArray *)saveCurrentTimelineAndChangeAccount:(NSMutableArray *)currentTimeline forChangeAccountName:(NSString *)accontName {
    
    [self saveCurrentTimeline:currentTimeline];
    
    return [[TWTweets manager].timelines objectForKey:accontName];
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
    
    return [TWTweets manager].sinceIDs;
}

+ (void)saveSinceID:(NSString *)sinceID {
    
    [[TWTweets manager].sinceIDs [[TWAccounts currentAccountName]] setObject:sinceID
                                                                      forKey:@"SinceID"];
    
    [[TWTweets manager].sinceIDs [[TWAccounts currentAccountName]] setObject:@(TimelineRequestStatsSended)
                                                                      forKey:@"Status"];
}

@end
