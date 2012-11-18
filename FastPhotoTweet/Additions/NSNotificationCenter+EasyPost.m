//
//  NSNotificationCenter+EasyPost.m
//

#import "NSNotificationCenter+EasyPost.h"

@implementation NSNotificationCenter (EasyPost)

+ (void)postNotificationCenterForName:(NSString *)name {
    
    [self postNotificationCenterForName:name withUserInfo:nil];
}

+ (void)postNotificationCenterForName:(NSString *)name withUserInfo:(NSDictionary *)userInfo {
    
    if ( name != nil ) {
        
        NSNotification *notification = [NSNotification notificationWithName:name
                                                                     object:self
                                                                   userInfo:userInfo];
        
        [NOTIFICATION postNotification:notification];
    }
}

@end
