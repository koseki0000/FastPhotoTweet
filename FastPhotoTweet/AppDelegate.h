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

#define IMGUR_API_KEY   @"6de089e68b55d6e390d246c4bf932901"
#define TWITPIC_API_KEY @"95cf146048caad3267f95219b379e61c"
#define OAUTH_KEY       @"dVbmOIma7UCc5ZkV3SckQ"
#define OAUTH_SECRET    @"wnDptUj4VpGLZebfLT3IInTZPkPS4XimYh6WXAmdI"

#define SCREEN_HEIGHT (int)[UIScreen mainScreen].applicationFrame.size.height
#define SCREEN_WIDTH (int)[UIScreen mainScreen].applicationFrame.size.width
#define STATUS_BAR_HEIGHT 20
#define TOOL_BAR_HEIGHT 44
#define SEGMENT_BAR_HEIGHT 30
#define TAB_BAR_HEIGHT 48
#define PICKER_HEIGHT 216
#define HEADER_HEIGHT 60
#define REFRESH_DERAY -65

#define BLANK @""
#define BLANK_ARRAY [NSArray array]
#define BLANK_M_ARRAY [NSMutableArray array]
#define BLANK_DIC [NSDictionary dictionary]
#define BLANK_M_DIC [NSMutableDictionary dictionary]
#define D [NSUserDefaults standardUserDefaults]

#define ORIENTATION [[UIDevice currentDevice] orientation]

#define FIREFOX_USERAGENT @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:13.0) Gecko/20100101 Firefox/13.0.1"
#define IPAD_USERAFENT @"Mozilla/5.0 (iPad; CPU OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B176 Safari/7534.48.3"
#define IPHONE_USERAGENT @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Mobile/9B206"

#define ICONS_DIRECTORY [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Icons"]
#define LOGS_DIRECTORY [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Logs"]
#define FILE_PATH [ICONS_DIRECTORY stringByAppendingPathComponent:searchName]

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
    
    UIPasteboard *pboard;
    UIBackgroundTaskIdentifier backgroundTask;
    
    BOOL pBoardWatch;
    BOOL debugMode;
}

@property NSInteger startUpFreeMemory;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainTabBarController *tabBarController;
@property (retain, nonatomic) StatusBarInfo *statusBarInfo;

@property (nonatomic, retain) NSString *postText;
@property (nonatomic, retain) NSString *postTextType;
@property (nonatomic, retain) NSString *bookmarkUrl;
@property (nonatomic, retain) NSString *urlSchemeDownloadUrl;
@property (nonatomic, retain) NSString *tabChangeFunction;
@property (nonatomic, retain) NSString *reOpenUrl;
@property (nonatomic, retain) NSString *listId;
@property (nonatomic, retain) NSString *addTwitpicAccountName;
@property (nonatomic, retain) NSString *platformName;
@property (nonatomic, retain) NSString *firmwareVersion;
@property (nonatomic, retain) NSArray *startupUrlList;
@property (nonatomic, retain) NSArray *listAll;
@property (nonatomic, retain) NSMutableArray *postError;
@property (nonatomic, retain) NSMutableDictionary *postData;
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

//- (oneway void)setNavigatorMap;
- (BOOL)ios5Check;
- (BOOL)iconExist:(NSString *)searchName;
- (NSString *)getPlatformName;
- (void)memoryStatus;
- (void)startPasteBoardTimer;
- (void)stopPasteBoardTimer;
- (void)checkPasteBoard;

@end
