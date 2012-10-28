//
//  TWTweets.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/27.
//
//

#import "TWTweetsBase.h"

@interface TWTweets : TWTweetsBase

+ (TWTweets *)manager;
+ (NSMutableDictionary *)timelines;
+ (NSMutableDictionary *)sinceIDs;

+ (void)saveCurrentTimeline:(NSMutableArray *)currentTimeline;
+ (NSMutableArray *)currentTimeline;
+ (NSMutableArray *)saveCurrentTimelineAndChangeAccount:(NSMutableArray *)currentTimeline forChangeAccountName:(NSString *)accontName;

+ (void)saveSinceID:(NSString *)tweetID;
+ (void)saveSinceID:(NSString *)tweetID forAccountName:(NSString *)accountName;
+ (NSString *)currentSinceID;

@end
