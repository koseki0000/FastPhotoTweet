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
    
    NSMutableArray *postError;
    NSNumber *resendNumber;
    NSNumber *resendMode;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (nonatomic, retain) OAConsumer *oaConsumer;
@property (nonatomic, retain) NSMutableArray *postError;
@property (nonatomic, retain) NSNumber *resendNumber;
@property (nonatomic, retain) NSNumber *resendMode;

- (BOOL)ios5Check;

@end
