//
//  AppDelegate.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "AppDelegate.h"
#import "ViewController.h"

#define OAUTH_KEY    @"dVbmOIma7UCc5ZkV3SckQ"
#define OAUTH_SECRET @"wnDptUj4VpGLZebfLT3IInTZPkPS4XimYh6WXAmdI"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize oaConsumer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"FinishLaunching");
    
    //OAConsumer設定
    oaConsumer = [[OAConsumer alloc] initWithKey:OAUTH_KEY 
                                          secret:OAUTH_SECRET];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSLog(@"Notification");
    
    //iOS5以降かチェック
    if ( [self ios5Check] ) {
        
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        
        if ( [d boolForKey:@"AddNotificationCenter"] ) {
            
            //通知センターへの登録時は何もしない
            [d removeObjectForKey:@"AddNotificationCenter"];
            
            return;
        }
        
        //通知の判別
        NSString *itemName = [notification.userInfo objectForKey:@"scheme"];
        NSLog(@"itemName: %@", itemName);
        
        //通知フラグと種類を登録
        [d setBool:YES forKey:@"Notification"];
        [d setObject:itemName forKey:@"NotificationType"];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)schemeURL {

    NSLog(@"handleOpenURL: %@", schemeURL.absoluteString);
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setBool:YES forKey:@"Notification"];
    [d setObject:[schemeURL.absoluteString substringWithRange:NSMakeRange(6, schemeURL.absoluteString.length - 6)] forKey:@"NotificationType"];
    
    return YES;
}

- (BOOL)ios5Check {
    
    BOOL result = NO;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
        
        //iOS5以前
        ShowAlert *alert = [[ShowAlert alloc] init];
        [alert error:@"Twitter API not available, please upgrade to iOS 5"];
        
    }else {
        
        result = YES;
    }
    
    return result;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //NSLog(@"applicationWillResignActive");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //NSLog(@"applicationWillTerminate");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
	backgroundTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        [application endBackgroundTask:backgroundTask];
    }];
}

- (void)dealloc {
    
    [oaConsumer release];
    
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
