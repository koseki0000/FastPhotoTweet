//
//  TWFriends.h
//  FastPhotoTweet
//
//  Created by @peace3884 12/09/09.
//

#import <Foundation/Foundation.h>
#import <Twitter/Twitter.h>
#import "TWGetAccount.h"
#import "ActivityIndicator.h"
#import "ShowAlert.h"

@interface TWFriends : NSObject

+ (void)follow:(NSString *)screenName;
+ (void)unfollow:(NSString *)screenName;
+ (void)block:(NSString *)screenName;
+ (void)unblock:(NSString *)screenName;
+ (void)reportSpam:(NSString *)screenName;

+ (void)friendship:(NSString *)type screenName:(NSString *)screenName;

@end
