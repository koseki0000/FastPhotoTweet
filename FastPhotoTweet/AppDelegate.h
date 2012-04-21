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
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (nonatomic, retain) OAConsumer *oaConsumer;

- (BOOL)ios5Check;

@end
