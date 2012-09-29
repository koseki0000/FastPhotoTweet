//
//  TWIconUpload.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/06/09.
//

#import <Foundation/Foundation.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "TWGetAccount.h"
#import "ActivityIndicator.h"
#import "ShowAlert.h"
#import "EncodeImage.h"

@interface TWIconUpload : NSObject

+ (void)image:(UIImage *)image;

@end
