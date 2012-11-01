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

@interface TWTweets : TWTweetsBase

+ (TWTweets *)manager;
+ (NSMutableDictionary *)timelines;

+ (void)saveCurrentTimeline:(NSMutableArray *)currentTimeline;
+ (NSMutableArray *)currentTimeline;
+ (NSMutableArray *)saveCurrentTimelineAndChangeAccount:(NSMutableArray *)currentTimeline forChangeAccountName:(NSString *)accontName;
+ (NSString *)topTweetID;

@end
