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

- (void)dealloc {
    
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    if ( notification ) {
        
        NSLog(@"Notification");
        
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        
        if ( [d boolForKey:@"AddApp"] ) {
            
            //通知センターへのアプリ登録時は何もしない
            NSLog(@"AddApp");
            [d removeObjectForKey:@"AddApp"];
            return;
        }
        
        if ( [d boolForKey:@"CallBack"] ) {
            
            //ペーストボードの内容をPost
            ACAccountStore *accountStore = [[ACAccountStore alloc] init];
            ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:
             ^(BOOL granted, NSError *error) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (granted) {
                         NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
                         if (twitterAccounts.count > 0) {
                             
                             ACAccount *twAccount = [[twitterAccounts objectAtIndex:0] retain];
                             UIPasteboard *pboard = [UIPasteboard generalPasteboard];
                             [TWSendTweet post:pboard.string twAccount:twAccount];
                             
                             NSLog(@"CallBack");
                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[d objectForKey:@"CallBackScheme"]]];
                         }
                     }
                 });
             }];
        }
    }   
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
	backgroundTask = [application beginBackgroundTaskWithExpirationHandler: 
                      ^{ [application endBackgroundTask:backgroundTask]; }];
}

@end
