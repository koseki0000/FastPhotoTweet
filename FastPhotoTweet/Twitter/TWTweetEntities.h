//
//  TWTweetEntities.h
//

#import <Foundation/Foundation.h>
#import "TWTweet.h"

@interface TWTweetEntities : NSMutableArray

@property (nonatomic, retain) NSArray *urls;
@property (nonatomic, retain) NSArray *userMentions;

+ (TWTweetEntities *)entitiesWithDictionary:(NSDictionary *)tweet;
+ (TWTweetEntities *)rtEntitiesWithDictionary:(NSDictionary *)tweet;

@end
