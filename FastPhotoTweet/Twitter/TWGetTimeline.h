//
//  TWGetTimeline.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import <Foundation/Foundation.h>
#import "TWGetAccount.h"
#import "ShowAlert.h"
#import "ActivityIndicator.h"
#import "AppDelegate.h"

@interface TWGetTimeline : NSObject

+ (void)homeTimeline;

@end
