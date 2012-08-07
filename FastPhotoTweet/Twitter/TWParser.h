//
//  TWParser
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import <Foundation/Foundation.h>
#import "ShowAlert.h"

@interface TWParser : NSObject

+ (NSString *)JSTDate:(NSString *)tweetData;
+ (NSString *)date:(NSString *)tweetData;
+ (NSString *)client:(NSString *)tweetData;
+ (NSDictionary *)rtText:(NSDictionary *)tweet;

@end
