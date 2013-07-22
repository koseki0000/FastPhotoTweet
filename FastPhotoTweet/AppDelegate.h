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

#define FIREFOX_USERAGENT @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:13.0) Gecko/20100101 Firefox/13.0.1"
#define IPAD_USERAFENT @"Mozilla/5.0 (iPad; CPU OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B176 Safari/7534.48.3"
#define IPHONE_USERAGENT @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Mobile/9B206"

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
