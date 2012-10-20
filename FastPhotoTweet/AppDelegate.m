//
//  AppDelegate.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "TimelineViewController.h"
#import <Three20UI/TTNavigator.h>
#import <Three20UINavigator/TTURLMap.h>

void uncaughtExceptionHandler(NSException *e) {
    
    NSLog(@"CRASH: %@", e);
    NSLog(@"Stack Trace: %@", [e callStackSymbols]);
    
    NSString *outputText = [NSString stringWithFormat:@"%@\n\n%@", e, [e callStackSymbols]];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd_hh-mm-ss"];
    
    NSString *convertedDate = [formatter stringFromDate:now];
    
    NSMutableString *fileName = [NSMutableString stringWithFormat:@"%@.txt", convertedDate];
    NSString *dataPath = [LOGS_DIRECTORY stringByAppendingPathComponent:fileName];
    
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:dataPath] ) {
        
        [outputText writeToFile:dataPath atomically:NO
                 encoding:NSUTF8StringEncoding
                    error:nil];
    }
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
@synthesize addTwitpicAccountName;
@synthesize platformName;
@synthesize firmwareVersion;
@synthesize startupUrlList;
@synthesize listAll;
@synthesize postError;
@synthesize postData;
@synthesize resendNumber;
@synthesize launchMode;
@synthesize reloadInterval;
@synthesize resendMode;
@synthesize browserOpenMode;
@synthesize pcUaMode;
@synthesize pboardURLOpenTweet;
@synthesize pboardURLOpenTimeline;
@synthesize pboardURLOpenBrowser;
@synthesize pBoardWatchTimer;
@synthesize willResignActive;
@synthesize willResignActiveBrowser;
@synthesize twitpicLinkMode;
@synthesize needChangeAccount;

#pragma mark - Initialize

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //NSLog(@"FinishLaunching: %@", launchOptions);
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    if ( [D objectForKey:@"HomePageURL"] == nil || [[D objectForKey:@"HomePageURL"] isEqualToString:BLANK] ) {
        
        [D setObject:@"http://www.google.co.jp/" forKey:@"HomePageURL"];
    }
    
//    [self setNavigatorMap];
    
    //各種初期化
    pboard = [UIPasteboard generalPasteboard];
    postText = BLANK;
    postTextType = BLANK;
    bookmarkUrl = BLANK;
    urlSchemeDownloadUrl = BLANK;
    tabChangeFunction = BLANK;
    sinceId = BLANK;
    reOpenUrl = BLANK;
    listId = BLANK;
    addTwitpicAccountName = BLANK;
    firmwareVersion = [[UIDevice currentDevice] systemVersion];
    platformName = [self getPlatformName];
    
    postError = [NSMutableArray array];
    
    resendNumber = 0;
    resendMode = NO;
    browserOpenMode = NO;
    pcUaMode = NO;
    pboardURLOpenTweet = NO;
    pboardURLOpenTimeline = NO;
    pboardURLOpenBrowser = NO;
    
    willResignActive = NO;
    willResignActiveBrowser = NO;
    twitpicLinkMode = NO;
    needChangeAccount = NO;
    
    startupUrlList = [NSArray arrayWithObject:[D objectForKey:@"HomePageURL"]];
    
    listAll = BLANK_ARRAY;
    
    postData = [NSMutableDictionary dictionary];
    
    if ( launchOptions == NULL ) {
        launchMode = 0;
    }else {
        launchMode = 1;
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIViewController *mainView = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    UIViewController *timelineView = [[TimelineViewController alloc] initWithNibName:@"TimelineViewController" bundle:nil];
    
    self.tabBarController = [[MainTabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:mainView, timelineView, nil];
    self.window.rootViewController = self.tabBarController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - LocalNotification

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSLog(@"Notification: %@", notification.userInfo);
    
    if ( notification.userInfo != nil ) {
    
        pboardURLOpenTweet = YES;
        pboardURLOpenTimeline = YES;
        pboardURLOpenBrowser = YES;
        
        NSNotification *pboardNotification =
        [NSNotification notificationWithName:@"pboardNotification"
                                      object:self
                                    userInfo:notification.userInfo];
        
        [[NSNotificationCenter defaultCenter] postNotification:pboardNotification];
    }
}

#pragma mark - URL Scheme

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)schemeURL {

    //NSLog(@"handleOpenURL: %@", schemeURL.absoluteString);

    if ( [schemeURL.absoluteString hasPrefix:@"fhttp"] || [schemeURL.absoluteString hasPrefix:@"fhttps"]) {
        
        urlSchemeDownloadUrl = [schemeURL.absoluteString substringFromIndex:1];
    }
    
    return YES;
}

#pragma mark - System

//- (oneway void)setNavigatorMap {
//    
//    TTNavigator *navigator = [TTNavigator navigator];
//    TTURLMap *map = navigator.URLMap;
//    [map from:@"*" toViewController:[TimelineViewController class] selector:@selector(openTimelineURL:)];
//}

- (BOOL)ios5Check {
    
    BOOL result = NO;
    
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] < 5.0 ) {
        
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

- (NSString *)getPlatformName {
    
    struct utsname u;
    uname(&u);
    NSString *hardwareName = [NSString stringWithFormat:@"%s", u.machine];
    
    if ( [hardwareName hasPrefix:@"iPhone2"] ) {
        hardwareName = @"iPhone 3GS";
        reloadInterval = 0.5;
    }else if ( [hardwareName hasPrefix:@"iPhone3"] ) {
        hardwareName = @"iPhone 4";
        reloadInterval = 0.3;
    }else if ( [hardwareName hasPrefix:@"iPhone4"] ) {
        hardwareName = @"iPhone 4S";
        reloadInterval = 0.15;
    }else if ( [hardwareName hasPrefix:@"iPhone5"] ) {
        hardwareName = @"iPhone 5";
        reloadInterval = 0.15;
    }else if ( [hardwareName hasPrefix:@"iPad1"] ) {
        hardwareName = @"iPad";
        reloadInterval = 0.25;
    }else if ( [hardwareName hasPrefix:@"iPad2"] ) {
        hardwareName = @"iPad 2gen";
        reloadInterval = 0.15;
    }else if ( [hardwareName hasPrefix:@"iPad3"] ) {
        hardwareName = @"iPad 3gen";
        reloadInterval = 0.15;
    }else if ( [hardwareName hasPrefix:@"x86_64"] ||
               [hardwareName hasPrefix:@"i386"] ) {
        hardwareName = @"iOS Simulator";
        reloadInterval = 0.15;
    }else {
        hardwareName = @"OtherDevice";
        reloadInterval = 0.35;
    }
    
    NSLog(@"Run with %@@%@", hardwareName, firmwareVersion);
    
    return hardwareName;
}

#pragma mark - PasteBoard

- (void)startPasteBoardTimer {
    
    NSLog(@"startPasteBoardTimer");
    
    @try {
        
        lastCheckPasteBoardURL = pboard.string;
        
    }@catch ( NSException *e ) {
        
        [pboard setString:BLANK];
        lastCheckPasteBoardURL = BLANK;
    }
    
    pBoardUrls = BLANK_ARRAY;
    
    pBoardWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                        target:self
                                                      selector:@selector(checkPasteBoard)
                                                      userInfo:nil
                                                       repeats:YES];
    [pBoardWatchTimer fire];
}

- (void)stopPasteBoardTimer {
    
    NSLog(@"stopPasteBoardTimer");
    
    [pBoardWatchTimer invalidate];
}

- (void)checkPasteBoard {
    
    @try {
        
        //NSLog(@"checkPasteBoard");
        
        NSString *pBoardString = pboard.string;
        
//        NSLog(@"pBoardString: %@", pBoardString);
//        NSLog(@"lastCheckPasteBoardURL: %@", lastCheckPasteBoardURL);
        
        if ( ![EmptyCheck string:pBoardString] ) {
            
            pBoardString = pboard.URL.absoluteString;
        }
        
        //文字列がない場合は終了
        if ( ![EmptyCheck string:pBoardString] ) return;
        
        //ペーストボードの内容が変化チェック
        if ( ![pBoardString isEqualToString:lastCheckPasteBoardURL] ) {
            
            //URLがあるか確認
            pBoardUrls = [NSArray arrayWithArray:[RegularExpression urls:pBoardString]];
            
            if ( pBoardUrls.count == 0 ) return;
            
            lastCheckPasteBoardURL = pBoardString;
            
            //通知を行う
            UILocalNotification *localPush = [[UILocalNotification alloc] init];
            localPush.timeZone = [NSTimeZone defaultTimeZone];
            localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            localPush.alertBody = lastCheckPasteBoardURL;
            localPush.userInfo = @{ @"pboardURL" : [pBoardUrls objectAtIndex:0] };
            [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
        }
        
    }@catch ( NSException *e ) { }
}

#pragma mark - Application

- (void)applicationWillResignActive:(UIApplication *)application {
    
    //NSLog(@"applicationWillResignActive");
    
    willResignActive = YES;
    willResignActiveBrowser = YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    //NSLog(@"applicationWillEnterForeground");
    
    if ( pBoardWatchTimer.isValid ) [self stopPasteBoardTimer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    //NSLog(@"applicationDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    //NSLog(@"applicationWillTerminate");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    //NSLog(@"applicationDidEnterBackground");
    
    willResignActive = NO;
    willResignActiveBrowser = NO;
    
    if ( [D boolForKey:@"PasteBoardCheck"] && !pBoardWatchTimer.isValid ) [self startPasteBoardTimer];

	backgroundTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        
        [application endBackgroundTask:backgroundTask];
    }];
}

#pragma mark - View

- (void)dealloc {

    if ( pBoardWatchTimer.isValid ) [self stopPasteBoardTimer];
    
    self.tabBarController = nil;
    self.window = nil;
}

@end
