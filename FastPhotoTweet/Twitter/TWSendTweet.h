//
//  TWSendTweet.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "JSON.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "TWGetAccount.h"

#import "UtilityClass.h"

@interface TWSendTweet : NSObject

+ (void)post:(NSString *)postText;

@end
