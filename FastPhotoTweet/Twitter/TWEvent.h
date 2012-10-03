//
//  TWEvent.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/11.
//

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <Foundation/Foundation.h>
#import "TWGetAccount.h"
#import "ShowAlert.h"
#import "ActivityIndicator.h"
#import "JSON.h"

@interface TWEvent : NSObject {
    
@public
    ACAccount *twAccount;
}

+ (void)favorite:(NSString *)tweetId accountIndex:(int)accountIndex;
+ (void)reTweet:(NSString *)tweetId accountIndex:(int)accountIndex;
+ (void)favoriteReTweet:(NSString *)tweetId accountIndex:(int)accountIndex;
+ (void)getProfile:(NSString *)screenName;
+ (void)getTweet:(NSString *)tweetId;

+ (void)unFavorite:(NSString *)tweetId accountIndex:(int)accountIndex;
+ (void)destroy:(NSString *)tweetId;

+ (ACAccount *)canAction;
+ (ACAccount *)canActionWithAccount:(int)num;

@end
