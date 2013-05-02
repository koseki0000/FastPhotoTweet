//
//  TWTweetUtility.h
//

#import <Foundation/Foundation.h>
#import "TWTweet.h"
#import "TWTweetEntities.h"

@interface TWTweetUtility : NSObject

+ (NSString *)replaceCharacterReference:(NSString *)text;
+ (NSString *)openTco:(NSString *)text
         fromEntities:(TWTweetEntities *)entities;

@end
