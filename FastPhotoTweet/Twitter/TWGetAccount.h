//
//  TWGetAccount.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/25.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

@interface TWGetAccount : NSObject

+ (ACAccount *)getTwitterAccount;
+ (ACAccount *)getTwitterAccount:(int)num;
+ (int)getTwitterAccountCount;

@end
