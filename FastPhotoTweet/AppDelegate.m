//
//  AppDelegate.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"FinishLaunching");
    
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
        
        if ( [d boolForKey:@"AddDic"] ) {
            
            //通知センターへの登録時は何もしない
            [d removeObjectForKey:@"AddDic"];
            
            return;
        }
        
        if ( [d boolForKey:@"AddPhoto"] ) {
            
            //通知センターへの登録時は何もしない
            [d removeObjectForKey:@"AddPhoto"];
            
            return;
        }
        
        if ( [d boolForKey:@"AddTweet"] ) {
            
            //通知センターへの登録時は何もしない
            [d removeObjectForKey:@"AddTweet"];
            
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

- (BOOL)ios5Check {
    
    BOOL result = NO;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
        
        //iOS5以前
        ShowAlert *alert = [[[ShowAlert alloc] init] autorelease];
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
    
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
