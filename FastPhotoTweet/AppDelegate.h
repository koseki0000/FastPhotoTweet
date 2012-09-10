//
//  AppDelegate.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import <UIKit/UIKit.h>

#define IMGUR_API_KEY   @"6de089e68b55d6e390d246c4bf932901"
#define TWITPIC_API_KEY @"95cf146048caad3267f95219b379e61c"
#define OAUTH_KEY       @"dVbmOIma7UCc5ZkV3SckQ"
#define OAUTH_SECRET    @"wnDptUj4VpGLZebfLT3IInTZPkPS4XimYh6WXAmdI"

#define BLANK @""
#define D [NSUserDefaults standardUserDefaults]

#define FIREFOX_USERAGENT @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.7; rv:13.0) Gecko/20100101 Firefox/13.0.1"
#define IPAD_USERAFENT @"Mozilla/5.0 (iPad; CPU OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9B176 Safari/7534.48.3"
#define IPHONE_USERAGENT @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_1_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Mobile/9B206"

#define ICONS_DIRECTORY [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Icons"]
#define FILE_PATH [ICONS_DIRECTORY stringByAppendingPathComponent:searchName]

void uncaughtExceptionHandler(NSException *exception);

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate> {
    
    UIBackgroundTaskIdentifier backgroundTask;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (nonatomic, retain) NSString *postText;
@property (nonatomic, retain) NSString *postTextType;
@property (nonatomic, retain) NSString *bookmarkUrl;
@property (nonatomic, retain) NSString *urlSchemeDownloadUrl;
@property (nonatomic, retain) NSString *tabChangeFunction;
@property (nonatomic, retain) NSString *sinceId;
@property (nonatomic, retain) NSString *reOpenUrl;
@property (nonatomic, retain) NSString *listId;
@property (nonatomic, retain) NSArray *startupUrlList;
@property (nonatomic, retain) NSMutableArray *postError;
@property (nonatomic, retain) NSMutableDictionary *postData;
@property int resendNumber;
@property int launchMode;
@property BOOL resendMode;
@property BOOL browserOpenMode;
@property BOOL pcUaMode;

- (BOOL)ios5Check;
- (BOOL)iconExist:(NSString *)searchName;

@end
