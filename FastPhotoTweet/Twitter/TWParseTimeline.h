//
//  TWParseTimeline.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import <Foundation/Foundation.h>
#import "ShowAlert.h"

@interface TWParseTimeline : NSObject

+ (NSString *)JSTDate:(NSString *)tweetData;
+ (NSString *)date:(NSString *)tweetData;
+ (NSString *)client:(NSString *)tweetData;

@end
