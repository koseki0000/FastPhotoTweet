//
//  AppDelegate.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import "MainTabBarController.h"
#import "Stats.h"
#import "StatusBarInfo.h"

#define RELEASE_SAFETY(object) [object release]; object = nil;
#define REMOVE_SAFETY(object) [object removeFromSuperview]; object = nil;

#define BLANK @""
#define BLANK_ARRAY [NSArray array]
#define BLANK_M_ARRAY [NSMutableArray array]
#define BLANK_DIC [NSDictionary dictionary]
#define BLANK_M_DIC [NSMutableDictionary dictionary]

#define D [NSUserDefaults standardUserDefaults]
#define P_BOARD [UIPasteboard generalPasteboard]
#define ORIENTATION [[UIDevice currentDevice] orientation]

#define FIREFOX_USERAGENT @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:13.0) Gecko/20100101 Firefox/13.0.1"
#define IPAD_USERAFENT @"Mozilla/5.0 (iPad; CPU OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B176 Safari/7534.48.3"
#define IPHONE_USERAGENT @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Mobile/9B206"

#define FIRMWARE_VERSION [[UIDevice currentDevice] systemVersion]

#define MAIN_QUEUE dispatch_get_main_queue()
#define ASYNC_MAIN_QUEUE dispatch_async(dispatch_get_main_queue(),
#define SYNC_MAIN_QUEUE dispatch_sync(dispatch_get_main_queue(),
#define GLOBAL_QUEUE_DEFAULT dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 )
#define GLOBAL_QUEUE_HIGH dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0 )
#define GLOBAL_QUEUE_BACKGROUND dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0 )

#define DISPATCH_AFTER(delay) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), MAIN_QUEUE,

void uncaughtExceptionHandler(NSException *exception);

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate> {
    
    Stats *stats;
    
    NSString *lastCheckPasteBoardURL;
    NSArray *pBoardUrls;
    
    UIBackgroundTaskIdentifier backgroundTask;
    
    BOOL pBoardWatch;
    BOOL debugMode;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainTabBarController *tabBarController;
@property (retain, nonatomic) StatusBarInfo *statusBarInfo;

@property (nonatomic, copy) NSString *postText;
@property (nonatomic, copy) NSString *postTextType;
@property (nonatomic, copy) NSString *bookmarkUrl;
@property (nonatomic, copy) NSString *urlSchemeDownloadUrl;
@property (nonatomic, copy) NSString *reOpenUrl;
@property (nonatomic, copy) NSString *addTwitpicAccountName;
@property (nonatomic, retain) NSArray *startupUrlList;
@property (nonatomic, weak) NSTimer *pBoardWatchTimer;
@property int resendNumber;
@property int launchMode;
@property float reloadInterval;
@property BOOL resendMode;
@property BOOL browserOpenMode;
@property BOOL pcUaMode;
@property BOOL pboardURLOpenTweet;
@property BOOL pboardURLOpenTimeline;
@property BOOL pboardURLOpenBrowser;

@property BOOL willResignActive;
@property BOOL willResignActiveBrowser;
@property BOOL twitpicLinkMode;
@property BOOL needChangeAccount;

- (NSString *)getPlatformName;
- (void)memoryStatus;
- (void)startPasteBoardTimer;
- (void)stopPasteBoardTimer;
- (void)checkPasteBoard;

@end
