//
//  NSNotificationCenter+EasyPost.h
//

#import <Foundation/Foundation.h>

#define NOTIFICATION [NSNotificationCenter defaultCenter]

@interface NSNotificationCenter (EasyPost)

+ (void)postNotificationCenterForName:(NSString *)name;
+ (void)postNotificationCenterForName:(NSString *)name withUserInfo:(NSDictionary *)userInfo;

@end
