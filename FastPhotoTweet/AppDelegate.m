//
//  AppDelegate.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "TimelineViewController.h"
#import "ResizeImage.h"

void uncaughtExceptionHandler(NSException *e) {
    
    NSLog(@"CRASH: %@", e);
    NSLog(@"Stack Trace: %@", [e callStackSymbols]);
}

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

@synthesize postText;
@synthesize postTextType;
@synthesize bookmarkUrl;
@synthesize urlSchemeDownloadUrl;
@synthesize tabChangeFunction;
@synthesize sinceId;
@synthesize reOpenUrl;
@synthesize listId;
@synthesize startupUrlList;
@synthesize postError;
@synthesize postData;
@synthesize resendNumber;
@synthesize launchMode;
@synthesize resendMode;
@synthesize browserOpenMode;
@synthesize pcUaMode;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //NSLog(@"FinishLaunching: %@", launchOptions);
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    if ( [D objectForKey:@"HomePageURL"] == nil || [[D objectForKey:@"HomePageURL"] isEqualToString:BLANK] ) {
        
        [D setObject:@"http://www.google.co.jp/" forKey:@"HomePageURL"];
    }
    
    //各種初期化
    postText = BLANK;
    postTextType = BLANK;
    bookmarkUrl = BLANK;
    urlSchemeDownloadUrl = BLANK;
    tabChangeFunction = BLANK;
    sinceId = BLANK;
    reOpenUrl = BLANK;
    listId = BLANK;
    
    postError = [NSMutableArray array];
    [postError retain];
    
    resendNumber = 0;
    resendMode = NO;
    browserOpenMode = NO;
    pcUaMode = NO;

    startupUrlList = [NSArray arrayWithObject:[D objectForKey:@"HomePageURL"]];
    [startupUrlList retain];
    
    postData = [NSMutableDictionary dictionary];
    [postData retain];
    
    if ( launchOptions == NULL ) {
        launchMode = 0;
    }else {
        launchMode = 1;
    }
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    UIViewController *mainView = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    UIViewController *timelineView = [[[TimelineViewController alloc] initWithNibName:@"TimelineViewController" bundle:nil] autorelease];
    
    self.tabBarController = [[[UITabBarController alloc] init] autorelease];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:mainView, timelineView, nil];
    self.window.rootViewController = self.tabBarController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    //NSLog(@"Notification");
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)schemeURL {

    //NSLog(@"handleOpenURL: %@", schemeURL.absoluteString);

    if ( [schemeURL.absoluteString hasPrefix:@"fhttp"] || [schemeURL.absoluteString hasPrefix:@"fhttps"]) {
        
        urlSchemeDownloadUrl = [schemeURL.absoluteString substringFromIndex:1];
        [urlSchemeDownloadUrl retain];
    }
    
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

- (BOOL)iconExist:(NSString *)searchName {
    
    BOOL isDir = NO;
    
    if ( [[NSFileManager defaultManager] fileExistsAtPath:FILE_PATH isDirectory:&isDir] && !isDir ) isDir = YES;
    
    return isDir;
}

- (BOOL)reachability {
    
    BOOL result = NO;
    
    if ( [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable ) {
        
        result = YES;
        
    }else {
        
        [ShowAlert error:@"インターネットに接続されていません。"];
    }
    
    return result;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    [D setBool:YES forKey:@"applicationWillResignActive"];
    [D setBool:YES forKey:@"applicationWillResignActiveBrowser"];
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
    [D removeObjectForKey:@"applicationWillResignActiveBrowser"];

	backgroundTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        
        [application endBackgroundTask:backgroundTask];
    }];
}

- (void)dealloc {
    
    [postError release];
    [urlSchemeDownloadUrl release];

    [_window release];
    [_tabBarController release];
    
    [super dealloc];
}

@end
