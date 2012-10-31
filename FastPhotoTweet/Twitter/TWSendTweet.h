//
//  TWSendTweet.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <Foundation/Foundation.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "AppDelegate.h"
#import "JSON.h"
#import "TWEntities.h"
#import "UtilityClass.h"
#import "TWAccounts.h"

@interface TWSendTweet : NSObject

+ (void)post:(NSString *)text withInReplyToID:(NSString *)tweetID;
+ (void)post:(NSString *)text withInReplyToID:(NSString *)tweetID andImage:(UIImage *)image;

@end
