//
//  ViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "ViewController.h"

@implementation ViewController
@synthesize postButton;
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
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
        
        //iOS5以前
        NSLog(@"Twitter API not available, please upgrade to iOS 5");
        
    } else {
        
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
                         NSLog(@"twAccount: %@", twAccount);
                         
                     } else {
                         
                         twAccount = nil;
                         
                         NSLog(@"Twitter account nothing");
                     }
                 } else {
                     
                     twAccount = nil;
                     
                     NSLog(@"Twitter account access denied");
                     
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
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
        
        //iOS5以前
        NSLog(@"Twitter API not available, please upgrade to iOS 5");
        
    }else{
        
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
        }
        
        //Textを投稿
        [TWSendTweet post:text twAccount:twAccount];
    }
}

- (IBAction)callbackTextFieldEnter:(id)sender {
    
    //Enterが押されたらキーボードを隠す
    [callbackTextField resignFirstResponder];
    
    //コールバックスキームを保存
    [d setObject:callbackTextField.text forKey:@"CallBackScheme"];
}

- (IBAction)callbackSwitchDidChage:(id)sender {
    
    //スイッチの状態を保存
    if ( callbackSwitch.on ) {
     
        [d setBool:YES forKey:@"CallBack"];
        
    }else {
        
        [d setBool:NO forKey:@"CallBack"];
        
    }
}

- (void)viewDidUnload {
    
    [self setPostButton:nil];
    [self setPostText:nil];
    [self setCallbackLabel:nil];
    [self setCallbackTextField:nil];
    [self setCallbackSwitch:nil];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc {
    
    [twAccount release];
    
    [postButton release];
    [postText release];
    [callbackLabel release];
    [callbackTextField release];
    [callbackSwitch release];
    [super dealloc];
}

@end