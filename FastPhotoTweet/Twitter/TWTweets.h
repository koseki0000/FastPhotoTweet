//
//  TWTweets.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/27.
//
//

#import "TWTweetsBase.h"
#import "NSObject+EmptyCheck.h"
#import "NSDictionary+DataExtraction.h"
#import "NSArray+AppendUtil.h"

@interface TWTweets : TWTweetsBase

+ (TWTweets *)manager;
+ (NSMutableDictionary *)timelines;
+ (NSMutableArray *)sendedTweets;

+ (NSString *)text;
+ (NSString *)inReplyToID;
+ (NSString *)tabChangeFunction;

+ (NSArray *)lists;
+ (NSString *)listID;
+ (NSString *)showingListID;

+ (void)saveCurrentTimeline:(NSMutableArray *)currentTimeline;
+ (NSMutableArray *)currentTimeline;
+ (NSMutableArray *)saveCurrentTimelineAndChangeAccount:(NSMutableArray *)currentTimeline forChangeAccountName:(NSString *)accontName;

+ (NSString *)topTweetID;
+ (NSMutableDictionary *)sinceIDs;
+ (void)saveSinceID:(NSString *)sinceID;

@end

typedef enum {
    TimelineRequestStatsSended,
    TimelineRequestStatsFailed,
    TimelineRequestStatsSuccess
}TimelineRequestStats;