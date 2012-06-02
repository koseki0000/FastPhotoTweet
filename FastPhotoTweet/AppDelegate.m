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
@synthesize postText;
@synthesize bookmarkUrl;
@synthesize postError;
@synthesize resendNumber;
@synthesize resendMode;
@synthesize isBrowserOpen;
@synthesize fastGoogleMode;
@synthesize webPageShareMode;
@synthesize launchMode;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //NSLog(@"FinishLaunching: %@", launchOptions);
    
    //OAConsumer設定
    oaConsumer = [[OAConsumer alloc] initWithKey:OAUTH_KEY 
                                          secret:OAUTH_SECRET];
    
    if ( [D objectForKey:@"HomePageURL"] == nil || [[D objectForKey:@"HomePageURL"] isEqualToString:@""] ) {
        
        NSLog(@"Set HomePageURL");
        [D setObject:@"http://www.google.co.jp/" forKey:@"HomePageURL"];
    }
    
    //各種初期化
    openURL = [D objectForKey:@"HomePageURL"];
    postText = BLANK;
    bookmarkUrl = BLANK;
    
    postError = [NSMutableArray array];
    [postError retain];
    
    resendNumber = [NSNumber numberWithInt:0];
    resendMode = [NSNumber numberWithInt:0];
    isBrowserOpen = [NSNumber numberWithInt:0];
    fastGoogleMode = [NSNumber numberWithInt:0];
    webPageShareMode = [NSNumber numberWithInt:0];
    
    if ( launchOptions == NULL ) {
        launchMode = [NSNumber numberWithInt:0];
    }else {
        launchMode = [NSNumber numberWithInt:1];
    }
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    //NSLog(@"Notification");
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)schemeURL {

    //NSLog(@"handleOpenURL: %@", schemeURL.absoluteString);
    
    return YES;
}

- (BOOL)ios5Check {
    
    BOOL result = NO;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
        
        //iOS5以前
        [ShowAlert error:@"Twitter APIはiOS5以降で使用できます。最新OSに更新してください。"];
        
    }else {
        
        result = YES;
    }
    
    return result;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    NSLog(@"applicationWillResignActive");
    
    [D setBool:YES forKey:@"applicationWillResignActive"];
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
    
    [D removeObjectForKey:@"applicationWillResignActive"];
    
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
