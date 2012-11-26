//
//  TWGetTimeline.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <Foundation/Foundation.h>
#import "NSObject+EmptyCheck.h"
#import "NSNotificationCenter+EasyPost.h"
#import "ShowAlert.h"
#import "ActivityIndicator.h"
#import "InternetConnection.h"
#import "TWEntities.h"
#import "TWAccounts.h"
#import "TWTweets.h"
#import "TWNgTweet.h"

@interface TWGetTimeline : NSObject

+ (void)homeTimeline;
+ (void)userTimeline:(NSString *)screenName;
+ (void)mentions;
+ (void)favotites;
+ (void)twitterSearch:(NSString *)searchWord;

+ (NSArray *)fixTwitterSearchResponse:(NSArray *)twitterSearchResponse;

@end
