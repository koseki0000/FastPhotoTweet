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

#define D [NSUserDefaults standardUserDefaults]

#define BLANK @""

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize oaConsumer;
@synthesize openURL;
@synthesize reopenURL;
@synthesize postText;
@synthesize postError;
@synthesize resendNumber;
@synthesize resendMode;
@synthesize isBrowserOpen;
@synthesize fastGoogleMode;
@synthesize webPageShareMode;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //NSLog(@"FinishLaunching");
    
    //OAConsumer設定
    oaConsumer = [[OAConsumer alloc] initWithKey:OAUTH_KEY 
                                          secret:OAUTH_SECRET];
    
    if ( [D objectForKey:@"HomePageURL"] == nil || [[D objectForKey:@"HomePageURL"] isEqualToString:@""] ) {
        
        NSLog(@"Set HomePageURL");
        [D setObject:@"http://www.google.com/" forKey:@"HomePageURL"];
    }
    
    openURL = [D objectForKey:@"HomePageURL"];
    reopenURL = BLANK;
    postText = BLANK;
    
    //再投稿用配列
    postError = [NSMutableArray array];
    [postError retain];
    
    resendNumber = [NSNumber numberWithInt:0];
    resendMode = [NSNumber numberWithInt:0];
    isBrowserOpen = [NSNumber numberWithInt:0];
    fastGoogleMode = [NSNumber numberWithInt:0];
    webPageShareMode = [NSNumber numberWithInt:0];
    
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
        
        //通知の判別
        NSString *itemName = [notification.userInfo objectForKey:@"scheme"];
        //NSLog(@"itemName: %@", itemName);
        
        if ( [itemName isEqualToString:@"tweet"] ) {
            
            if ( [D boolForKey:@"AddNotificationCenterTweet"] ) { 
                
                //NSLog(@"DeleteNotificationTweet");
                [D removeObjectForKey:@"AddNotificationCenterTweet"];
                return;   
            }
            
        }else if ( [itemName isEqualToString:@"fast"] ) {
            
            if ( [D boolForKey:@"AddNotificationCenterFastTweet"] ) { 
                
                //NSLog(@"DeleteNotificationFastTweet");
                [D removeObjectForKey:@"AddNotificationCenterFastTweet"];
                return;
            }
            
        }else if ( [itemName isEqualToString:@"photo"] ) {
            
            if ( [D boolForKey:@"AddNotificationCenterFastTweet"] ) { 
                
                //NSLog(@"DeleteNotificationPhotoTweet");
                [D removeObjectForKey:@"AddNotificationCenterPhotoTweet"];
                return;
            }
            
        }else if ( [itemName isEqualToString:@"music"] ) {
            
            if ( [D boolForKey:@"AddNotificationCenterFastTweet"] ) {
                
                //NSLog(@"DeleteNotificationNowPlaying");
                [D removeObjectForKey:@"AddNotificationCenterNowPlaying"];
                return;
            }
            
        }else if ( [itemName isEqualToString:@"google"] ) {
            
            if ( [D boolForKey:@"AddNotificationCenterFastGoogle"] ) {
                
                //NSLog(@"DeleteNotificationFastGoogle");
                [D removeObjectForKey:@"AddNotificationCenterFastGoogle"];
                return;
            }
            
        }else if ( [itemName isEqualToString:@"page"] ) {
            
            if ( [D boolForKey:@"AddNotificationCenterWebPageShare"] ) {
                
                //NSLog(@"DeleteNotificationWebPageShare");
                [D removeObjectForKey:@"AddNotificationCenterWebPageShare"];
                return;
            }
        }
        
        if ( [itemName isEqualToString:@"google"] ) {
            
            NSLog(@"Set webBrowsingMode");
            fastGoogleMode = [NSNumber numberWithInt:1];
            
        }else if ( [itemName isEqualToString:@"page"] ) {
            
            NSLog(@"Set webPageShareMode");
            webPageShareMode = [NSNumber numberWithInt:1];
        }
        
        //通知フラグと種類を登録
        [D setBool:YES forKey:@"Notification"];
        [D setObject:itemName forKey:@"NotificationType"];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)schemeURL {

    NSLog(@"handleOpenURL: %@", schemeURL.absoluteString);
    
    NSString *scheme = [schemeURL.absoluteString substringWithRange:NSMakeRange(6, schemeURL.absoluteString.length - 6)];
    
    if ( [scheme isEqualToString:@"google"] ) {
        
        NSLog(@"Set webBrowsingMode");
        fastGoogleMode = [NSNumber numberWithInt:1];
        
    }else if ( [scheme isEqualToString:@"page"] ) {
        
        NSLog(@"Set webPageShareMode");
        webPageShareMode = [NSNumber numberWithInt:1];
    }
    
    [D setBool:YES forKey:@"Notification"];
    [D setObject:scheme forKey:@"NotificationType"];
    
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
