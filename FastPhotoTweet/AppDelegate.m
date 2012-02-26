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
            NSLog(@"pboard: %@", pboard.pasteboardTypes);
    
//            BOOL pBoardType = NO;
            int pBoardType = 0;
            
            if ( [[pboard.pasteboardTypes objectAtIndex:0] isEqualToString:@"public.text"] ) {
            
                //テキストの場合
                pBoardType = 0;
                
            }else if ( [[pboard.pasteboardTypes objectAtIndex:0] isEqualToString:@"public.jpeg"] ||
                       [[pboard.pasteboardTypes objectAtIndex:0] isEqualToString:@"public.png"] ||
                       [[pboard.pasteboardTypes objectAtIndex:0] isEqualToString:@"public.gif"] ||
                       [[pboard.pasteboardTypes objectAtIndex:0] isEqualToString:@"public.bmp"] ) {
                
                //画像の場合
                pBoardType = 1;
            
            }else {
                
                //得体の知れない物
                pBoardType = 2;
                
            }
            
            NSString *itemName = [notification.userInfo objectForKey:@"scheme"];
            NSLog(@"itemName: %@", itemName);
            
            if ( [itemName hasPrefix:@"dic"] ) {
                
                //辞書
                UIReferenceLibraryViewController *controller = [[UIReferenceLibraryViewController alloc] initWithTerm:pboard.string];
                [self.viewController presentModalViewController:controller animated:YES];
                
            }else if ( [itemName hasPrefix:@"tweet"] ) {
                
                //FastPostが有効
                if ( [d boolForKey:@"FastPost"] ) {
                    
                    BOOL canOpen = NO;
                    if ( [d boolForKey:@"CallBack"] ) {
                        
                        //CallbackSchemeが空でない
                        if ( ![[d objectForKey:@"CallBackScheme"] isEqualToString:@""] ||
                            [d objectForKey:@"CallBackScheme"] != nil) {
                            
                            //CallbackSchemeがアクセス可能な物がテスト
                            canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[d objectForKey:@"CallBackScheme"]]];
                            
                        }
                    }
                    
                    //アカウント情報取得
                    ACAccount *twAccount = [TWGetAccount getTwitterAccount];
                    
                    if (twAccount != nil) {
                    
                        //ペーストボードの内容を投稿
                        if ( pBoardType == 0 ) {
                            
                            //t.coを考慮した文字数カウントを行う
                            int num = [TWTwitterCharCounter charCounter:pboard.string];
                            
                            if ( num < 0 ) {
                                
                                //140字を超えていた場合
                                ShowAlert *alert = [[ShowAlert alloc] init];
                                [alert error:[NSString stringWithFormat:@"Post message is over 140: %d", num]];
                                
                                NSLog(@"%@", [NSString stringWithFormat:@"Post message is over 140: %d", num]);
                                
                                //140字を超えていた事を表すフラグを設置
                                [d setBool:YES forKey:@"Over140Chars"];
                                
                                return;
                                
                            }
                            
                            //テキスト
                            [TWSendTweet post:pboard.string];
                            
                        }else if ( pBoardType == 1 ){
                            
                            //画像
                            
                        }else {
                            
                            //得体の知れない物
                            ShowAlert *alert = [[ShowAlert alloc] init];
                            [alert error:@"ペーストボードの中身がテキストか画像以外です。"];
                            
                        }
                        
                        
                    }else {
                        
                        //Twitterアカウントが見つからない場合設定に飛ばす
                        ShowAlert *alert = [[ShowAlert alloc] init];
                        [alert error:@"Twitter account nothing"];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
                        
                    }
                    
                    //Callbackが有効
                    if ( [d boolForKey:@"CallBack"] ) {
                        
                        //Schemeが開けない
                        if ( !canOpen ) {
                        
                            NSLog(@"Can't callBack");
                            
                            ShowAlert *alert = [[ShowAlert alloc] init];
                            [alert error:@"Can't callBack"];
                        
                        }else {
                            
                            NSLog(@"CallBack");
                            
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[d objectForKey:@"CallBackScheme"]]];
                            
                        }
                    }
                    
                }else {
                    
                    //通知判定
                    [d setBool:YES forKey:@"Notification"];
                    
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
    
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
