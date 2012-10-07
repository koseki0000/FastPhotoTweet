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
#import "TWGetAccount.h"
#import "TWEntities.h"
#import "UtilityClass.h"

@interface TWSendTweet : NSObject

+ (oneway void)post:(NSArray *)postData;

@end
