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
#import "UtilityClass.h"

@interface TWSendTweet : NSObject

+ (void)post:(NSArray *)postData;

@end
