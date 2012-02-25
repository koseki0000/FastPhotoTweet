//
//  ViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "ViewController.h"

@implementation ViewController
@synthesize postButton;
@synthesize dicButton;
@synthesize postText;
@synthesize callbackLabel;
@synthesize callbackTextField;
@synthesize callbackSwitch;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    d = [NSUserDefaults standardUserDefaults];
    postText.text = @"";
    
    //保存されている情報をロード
    [self loadSettings];
    
    //iOSバージョン判定
    if ( [self ios5Check] ) {
        
        //iOS5
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:
         ^(BOOL granted, NSError *error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (granted) {
                     NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
                     if (twitterAccounts.count > 0) {
                         
                         twAccount = [[twitterAccounts objectAtIndex:0] retain];
                         ShowAlert *alert = [[ShowAlert alloc] init];
                         [alert title:@"Success" message:[NSString stringWithFormat:@"Account Name: %@", twAccount.username]];
                         
                         //NSLog(@"twAccount: %@", twAccount);
                         
                         //通知センターにアプリを登録
                         
                         //通知センター登録時は通知を受け取っても無視するように設定
                         [d setBool:YES forKey:@"AddApp"];
                         
                         UILocalNotification *localPush = [[UILocalNotification alloc] init];
                         localPush.timeZone = [NSTimeZone defaultTimeZone];
                         localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
                         
                         localPush.alertBody = @"FastPhotoTweet";
                         localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"tweet", @"scheme", nil];
                         [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
                         [localPush release];
                         
                     } else {
                         
                         twAccount = nil;
                         
                         ShowAlert *alert = [[ShowAlert alloc] init];
                         [alert error:@"Twitter account nothing"];

                     }
                     
                 } else {
                     
                     twAccount = nil;
                     
                     ShowAlert *alert = [[ShowAlert alloc] init];
                     [alert error:@"Twitter account access denied"];
                     
                 }
             });
         }];
    }
}

- (void)loadSettings {
    
    if ( [d boolForKey:@"CallBack"] ) {
        
        //オン
        callbackSwitch.on = YES;
        
    }else {
        
        //オフ
        callbackSwitch.on = NO;
        
    }
    
    NSString *str = [d objectForKey:@"CallBackScheme"];
    if ( [str isEqualToString:@""] || str == nil) {
        
        //スキームが保存されていない
        //空のキーを保存
        [d setObject:@"" forKey:@"CallBackScheme"];
        
    }else {
        
        //スキームをセット
        callbackTextField.text = str;
    }
}

- (IBAction)pushPostButton:(id)sender {
    
    //iOSバージョン判定
    if ( [self ios5Check] ) {
        //Internet接続のチェック
        if ( [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable ) {
            
            NSString *text;
            
            if ( [postText.text isEqualToString:@""] ) {
                
                //Post入力欄が空ならテスト用テキストを生成して投稿
                NSString *testDate = [NSDateFormatter localizedStringFromDate:[NSDate date] 
                                                                    dateStyle:kCFDateFormatterNoStyle
                                                                    timeStyle:kCFDateFormatterMediumStyle];
                
                text = [NSString stringWithFormat:@"TestDate: %@", testDate];
                
            }else {
                
                //文字が入力されている場合はそちらを投稿
                text = postText.text;
                postText.text = @"";
            }
            
            //Textをバックグラウンドプロセスで投稿
            NSArray *postDataArray = [NSArray arrayWithObjects:text, twAccount, nil];
            [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postDataArray];
        }
    }
}

- (IBAction)pushDicButton:(id)sender {
    
    //通知センター登録時は通知を受け取っても無視するように設定
    [d setBool:YES forKey:@"AddApp"];
    
    UILocalNotification *localPush = [[UILocalNotification alloc] init];
    localPush.timeZone = [NSTimeZone defaultTimeZone];
    localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    
    localPush.alertBody = @"FastDictionary";
    localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"dic", @"scheme", nil];
    [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
    
    [localPush release];
}

- (IBAction)callbackTextFieldEnter:(id)sender {
    
    //Enterが押されたらキーボードを隠す
    [callbackTextField resignFirstResponder];
    
    //コールバックスキームを保存
    [d setObject:callbackTextField.text forKey:@"CallBackScheme"];
    
    //スキームを再設定
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *localPush = [[UILocalNotification alloc] init];
    localPush.timeZone = [NSTimeZone defaultTimeZone];
    localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    
    localPush.alertBody = @"FastPhotoTweet";
    localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:callbackTextField.text, @"scheme", nil];
    [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
    [localPush release];
}

- (IBAction)callbackSwitchDidChage:(id)sender {
    
    //スイッチの状態を保存
    if ( callbackSwitch.on ) {
     
        [d setBool:YES forKey:@"CallBack"];
        
    }else {
        
        [d setBool:NO forKey:@"CallBack"];
        
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

- (void)viewDidUnload {
    
    [self setPostButton:nil];
    [self setPostText:nil];
    [self setCallbackLabel:nil];
    [self setCallbackTextField:nil];
    [self setCallbackSwitch:nil];
    [self setDicButton:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    
	[super viewDidDisappear:animated];
}

- (void)dealloc {
    
    [twAccount release];
    
    [postButton release];
    [postText release];
    [callbackLabel release];
    [callbackTextField release];
    [callbackSwitch release];
    [dicButton release];
    [super dealloc];
}

@end