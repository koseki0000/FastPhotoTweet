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
@synthesize postError;
@synthesize resendNumber;
@synthesize resendMode;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //NSLog(@"FinishLaunching");
    
    //OAConsumer設定
    oaConsumer = [[OAConsumer alloc] initWithKey:OAUTH_KEY 
                                          secret:OAUTH_SECRET];
        
    //再投稿用配列
    postError = [NSMutableArray array];
    [postError retain];
    
    resendNumber = [NSNumber numberWithInt:0];
    resendMode = [NSNumber numberWithInt:0];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    //NSLog(@"Notification");
    
    //iOS5以降かチェック
    if ( [self ios5Check] ) {
        
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        
        //通知の判別
        NSString *itemName = [notification.userInfo objectForKey:@"scheme"];
        //NSLog(@"itemName: %@", itemName);
        
        if ( [itemName isEqualToString:@"tweet"] ) {
            
            if ( [d boolForKey:@"AddNotificationCenterTweet"] ) { 
                
                //NSLog(@"DeleteNotificationTweet");
                [d removeObjectForKey:@"AddNotificationCenterTweet"];
                return;   
            }
            
        }else if ( [itemName isEqualToString:@"fast"] ) {
            
            if ( [d boolForKey:@"AddNotificationCenterFastTweet"] ) { 
                
                //NSLog(@"DeleteNotificationFastTweet");
                [d removeObjectForKey:@"AddNotificationCenterFastTweet"];
                return;
            }
            
        }else if ( [itemName isEqualToString:@"photo"] ) {
            
            if ( [d boolForKey:@"AddNotificationCenterFastTweet"] ) { 
                
                //NSLog(@"DeleteNotificationPhotoTweet");
                [d removeObjectForKey:@"AddNotificationCenterPhotoTweet"];
                return;
            }
            
        }else if ( [itemName isEqualToString:@"music"] ) {
            
            if ( [d boolForKey:@"AddNotificationCenterFastTweet"] ) {
                
                //NSLog(@"DeleteNotificationNowPlaying");
                [d removeObjectForKey:@"AddNotificationCenterNowPlaying"];
                return;
            }
        }
        
        //通知フラグと種類を登録
        [d setBool:YES forKey:@"Notification"];
        [d setObject:itemName forKey:@"NotificationType"];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)schemeURL {

    //NSLog(@"handleOpenURL: %@", schemeURL.absoluteString);
    
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
        [alert error:@"Twitter APIはiOS5以降で使用できます。最新OSに更新してください。"];
        
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
    [postError release];

    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
