//
//  TWTweets.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/27.
//
//

@interface TWTweets : NSObject

@property (retain, nonatomic) NSMutableDictionary *timelines;
@property (retain, nonatomic) NSMutableDictionary *sinceIDs;

@property (retain, nonatomic) NSMutableArray *sendedTweets;

@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *inReplyToID;
@property (copy, nonatomic) NSString *tabChangeFunction;

@property (retain, nonatomic) NSArray *lists;
@property (copy, nonatomic) NSString *listID;
@property (copy, nonatomic) NSString *showingListID;

+ (TWTweets *)manager;

/////

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