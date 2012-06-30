//
//  AppDelegate.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <UIKit/UIKit.h>
#import "OAConsumer.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    OAConsumer *oaConsumer;
    UIBackgroundTaskIdentifier backgroundTask;
    
    NSString *openURL;
    NSString *postText;
    NSString *postTextType;
    NSString *bookmarkUrl;
    NSMutableArray *postError;
    NSNumber *resendNumber;
    NSNumber *resendMode;
    NSNumber *isBrowserOpen;
    NSNumber *fastGoogleMode;
    NSNumber *webPageShareMode;
    NSNumber *launchMode;
    NSNumber *pcUaMode;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (nonatomic, retain) OAConsumer *oaConsumer;
@property (nonatomic, retain) NSString *openURL;
@property (nonatomic, retain) NSString *postText;
@property (nonatomic, retain) NSString *postTextType;
@property (nonatomic, retain) NSString *bookmarkUrl;
@property (nonatomic, retain) NSMutableArray *postError;
@property (nonatomic, retain) NSNumber *resendNumber;
@property (nonatomic, retain) NSNumber *resendMode;
@property (nonatomic, retain) NSNumber *isBrowserOpen;
@property (nonatomic, retain) NSNumber *fastGoogleMode;
@property (nonatomic, retain) NSNumber *webPageShareMode;
@property (nonatomic, retain) NSNumber *launchMode;
@property (nonatomic, retain) NSNumber *pcUaMode;

- (BOOL)ios5Check;

@end
