//
//  AppDelegate.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <UIKit/UIKit.h>
#import "OAConsumer.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate> {
    
    OAConsumer *oaConsumer;
    UIBackgroundTaskIdentifier backgroundTask;
    
    NSString *openURL;
    NSString *postText;
    NSString *postTextType;
    NSString *bookmarkUrl;
    NSString *urlSchemeDownloadUrl;
    NSString *tabChangeFunction;
    NSString *sinceId;
    NSMutableArray *postError;
    NSNumber *resendNumber;
    NSNumber *resendMode;
    NSNumber *isBrowserOpen;
    NSNumber *launchMode;
    NSNumber *pcUaMode;
    NSNumber *tlUrlOpenMode;
    NSMutableDictionary *postData;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (nonatomic, retain) OAConsumer *oaConsumer;
@property (nonatomic, retain) NSString *openURL;
@property (nonatomic, retain) NSString *postText;
@property (nonatomic, retain) NSString *postTextType;
@property (nonatomic, retain) NSString *bookmarkUrl;
@property (nonatomic, retain) NSString *urlSchemeDownloadUrl;
@property (nonatomic, retain) NSString *tabChangeFunction;
@property (nonatomic, retain) NSString *sinceId;
@property (nonatomic, retain) NSMutableArray *postError;
@property (nonatomic, retain) NSNumber *resendNumber;
@property (nonatomic, retain) NSNumber *resendMode;
@property (nonatomic, retain) NSNumber *isBrowserOpen;
@property (nonatomic, retain) NSNumber *launchMode;
@property (nonatomic, retain) NSNumber *pcUaMode;
@property (nonatomic, retain) NSNumber *tlUrlOpenMode;
@property (nonatomic, retain) NSMutableDictionary *postData;

- (BOOL)ios5Check;

@end
