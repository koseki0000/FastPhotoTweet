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
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    //iOS5以降かチェック
    if ( [self ios5Check] ) {
        //Internet接続のチェック
        if ( [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable ) {
            
            NSLog(@"Notification");
            
            NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
            
            if ( [d boolForKey:@"AddApp"] ) {
                
                //通知センターへのアプリ登録時は何もしない
                [d removeObjectForKey:@"AddApp"];
                
                return;
            }
            
            UIPasteboard *pboard = [UIPasteboard generalPasteboard];
            NSString *itemName = [notification.userInfo objectForKey:@"scheme"];
            NSLog(@"itemName: %@", itemName);
            
            if ( [itemName hasPrefix:@"dic"] ) {
                
                //辞書
                UIReferenceLibraryViewController *controller = [[UIReferenceLibraryViewController alloc] initWithTerm:pboard.string];
                [self.viewController presentModalViewController:controller animated:YES];
                
            }else if ( [itemName hasPrefix:@"tweet"] ) {
                
                if ( [d boolForKey:@"CallBack"] ) {
                    
                    BOOL canOpen = NO;
                    
                    if ( ![[d objectForKey:@"CallBackScheme"] isEqualToString:@""] ||
                        [d objectForKey:@"CallBackScheme"] != nil) {
                        
                        //CallbackSchemeがアクセス可能な物がテスト
                        canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[d objectForKey:@"CallBackScheme"]]];
                        
                    }
                    
                    //アカウント情報取得
                    ACAccount *twAccount = [TWGetAccount getTwitterAccount];
                    
                    if (twAccount != nil) {
                        
                        //ペーストボードの内容を投稿
                        NSArray *postDataArray = [NSArray arrayWithObjects:pboard.string, twAccount, nil];
                        [TWSendTweet post:postDataArray];
                        
                    }else {
                        
                        //Twitterアカウントが見つからない場合設定に飛ばす
                        ShowAlert *alert = [[[ShowAlert alloc] init] autorelease];
                        [alert error:@"Twitter account nothing"];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
                        
                    }
                    
                    if ( !canOpen ) {
                        
                        NSLog(@"Can't callBack");
                        
                        ShowAlert *alert = [[ShowAlert alloc] init];
                        [alert error:@"Can't callBack"];
                        
                    }else {
                        
                        NSLog(@"CallBack");
                        
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[d objectForKey:@"CallBackScheme"]]];
                        
                    }
                }
            }
            
        }else {
            
            ShowAlert *alert = [[ShowAlert alloc] init];
            [alert error:@"No internet connection"];
            
        }
    }
}

- (BOOL)ios5Check {
    
    BOOL result = NO;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
        
        //iOS5以前
        ShowAlert *alert = [[ShowAlert alloc] init];
        [alert error:@"Twitter API not available, please upgrade to iOS 5"];
        
    }else {
        
        result = YES;
        
    }
    
    return result;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
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
