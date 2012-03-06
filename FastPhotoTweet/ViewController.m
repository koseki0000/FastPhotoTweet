//
//  ViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "ViewController.h"

@implementation ViewController
@synthesize sv;
@synthesize postButton;
@synthesize dicButton;
@synthesize imageSettingButton;
@synthesize postText;
@synthesize callbackLabel;
@synthesize fastPostLabel;
@synthesize postCharLabel;
@synthesize callbackTextField;
@synthesize callbackSwitch;
@synthesize fastPostSwitch;
@synthesize imagePreview;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad");
        
    //アプリがアクティブになった場合の通知を受け取る設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    d = [NSUserDefaults standardUserDefaults];
    postText.text = @"";
        
    //保存されている情報をロード
    [self loadSettings];
    
    //iOSバージョン判定
    if ( [self ios5Check] ) {
        
        //iOS5
        
        ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:
         ^( BOOL granted, NSError *error ) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if ( granted ) {
                     NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
                     if ( twitterAccounts.count > 0 ) {
                         
                         twAccount = [[twitterAccounts objectAtIndex:0] retain];
                         ShowAlert *alert = [[ShowAlert alloc] init];
                         [alert title:@"Success" message:[NSString stringWithFormat:@"Account Name: %@", twAccount.username]];
                         NSLog(@"twAccount: %@", twAccount);
                         
                         //通知センターにアプリを登録
                         
                         //通知センター登録時は通知を受け取っても無視するように設定
                         [d setBool:YES forKey:@"AddPhoto"];
                         [d setBool:YES forKey:@"AddTweet"];
                         
                         UILocalNotification *localPushPhoto = [[UILocalNotification alloc] init];
                         localPushPhoto.timeZone = [NSTimeZone defaultTimeZone];
                         localPushPhoto.alertBody = @"PhotoTweet";
                         localPushPhoto.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"photo", @"scheme", nil];

                         UILocalNotification *localPush = [[UILocalNotification alloc] init];
                         localPush.timeZone = [NSTimeZone defaultTimeZone];
                         localPush.alertBody = @"Tweet";
                         localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"tweet", @"scheme", nil];
                         
                         localPushPhoto.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
                         localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
                         [[UIApplication sharedApplication] scheduleLocalNotification:localPushPhoto];                                                  
                         [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
                         [localPushPhoto release];
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
    
    if ( [d boolForKey:@"FastPost"] ) {
        
        //オン
        fastPostSwitch.on = YES;
        
    }else {
        
        //オフ
        fastPostSwitch.on = NO;
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
            
            //画像が設定されていない場合
            if ( imagePreview.image == nil ) {
                
                //文字列をバックグラウンドプロセスで投稿
                [TWSendTweet performSelectorInBackground:@selector(post:) withObject:text];
             
            //画像が設定されている場合
            }else {
                
                //文字列と画像をバックグラウンドプロセスで投稿
                NSArray *postData = [NSArray arrayWithObjects:text, imagePreview.image, nil];
                [TWSendTweet performSelectorInBackground:@selector(photoPost:) withObject:postData];
            }
        }
    }
}

- (IBAction)pushDicButton:(id)sender {
    
    //通知センター登録時は通知を受け取っても無視するように設定
    [d setBool:YES forKey:@"AddDic"];
    
    UILocalNotification *localPush = [[UILocalNotification alloc] init];
    localPush.timeZone = [NSTimeZone defaultTimeZone];
    localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
    localPush.alertBody = @"FastDictionary";
    localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"dic", @"scheme", nil];
    [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
    
    [localPush release];
}

- (IBAction)pushImageSettingButton:(id)sender {
    
    //イメージピッカーを表示
    UIImagePickerController *picPicker = [[UIImagePickerController alloc] init];
    picPicker.delegate = self;
    picPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentModalViewController:picPicker animated:YES];
    [picPicker release];
}

- (void)imagePickerController:(UIImagePickerController *)picPicker
        didFinishPickingImage:(UIImage *)image 
                  editingInfo:(NSDictionary*)editingInfo {

    //画像が選択された場合
    //画像を設定
    imagePreview.image = image;
    
    //モーダルビューを閉じる
    [picPicker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picPicker {
 
    //画像選択がキャンセルされた場合
    //モーダルビューを閉じる
    [picPicker dismissModalViewControllerAnimated:YES];
}

- (IBAction)callbackTextFieldEnter:(id)sender {
    
    //Enterが押されたらキーボードを隠す
    [callbackTextField resignFirstResponder];
    
    //ビューの位置を戻す
    [sv setContentOffset:CGPointMake(0, 0) animated:YES];
    
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

- (IBAction)textFieldStartEdit:(id)sender {
    
    //ビューの位置を上げる
    [sv setContentOffset:CGPointMake(0, 80) animated:YES];
}

- (IBAction)callbackSwitchDidChage:(id)sender {
    
    //スイッチの状態を保存
    if ( callbackSwitch.on ) {
     
        [d setBool:YES forKey:@"CallBack"];
        
    }else {
        
        [d setBool:NO forKey:@"CallBack"];
    }
}

- (IBAction)fastPostSwitchDidChage:(id)sender {
    
    //スイッチの状態を保存
    if ( fastPostSwitch.on ) {
        
        [d setBool:YES forKey:@"FastPost"];
        
    }else {
        
        [d setBool:NO forKey:@"FastPost"];
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

- (void)textViewDidChange:(UITextView *)textView {

    //TextViewの内容が変更された時に呼ばれる
    
    //t.coを考慮した文字数カウントを行う
    int num = [TWTwitterCharCounter charCounter:postText.text];
    
    //結果をラベルに反映
    postCharLabel.text = [NSString stringWithFormat:@"%d", num];
    
    //文字数が140字を超えていた場合Postボタンを隠す
    if (num < 0) {
        
        postButton.hidden = YES;
        
    }else {
        
        postButton.hidden = NO;
    }
}

- (void)becomeActive:(NSNotification *)notification {
    
    //アプリケーションがアクティブになった際に呼ばれる
    NSLog(@"becomeActive");
    
    //通知判定がある場合
    if ( [d boolForKey:@"Notification"] ) {
        
        //通知判定を削除
        [d removeObjectForKey:@"Notification"];
        
        //iOS5以降かチェック
        if ( [self ios5Check] ) {
            
            UIPasteboard *pboard = [UIPasteboard generalPasteboard];
            
            //通知が辞書機能だった場合
            if ( [[d objectForKey:@"NotificationType"] isEqualToString:@"dic"] ) {
                
                UIReferenceLibraryViewController *controller = [[UIReferenceLibraryViewController alloc] initWithTerm:pboard.string];
                [self presentModalViewController:controller animated:YES];

                return;
            }
            
            //以下通知がtweetだった場合
            
            if ( twAccount == nil ) {
                
                //Twitterアカウントが見つからない場合設定に飛ばす
                ShowAlert *alert = [[ShowAlert alloc] init];
                [alert error:@"Twitter account nothing"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=TWITTER"]];
                
                return;
            }
            
            //インターネット接続のチェック
            if ( [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable ) {
                
                BOOL canPost = NO;
                BOOL canOpen = NO;
                
                //ペーストボードの内容をチェック
                int pBoardType = [PasteboardType check];
                
                if ( pBoardType == -1 ) {
                    
                    //テキストか画像以外
                    return;
                }
                
                //FastPostが無効な場合
                if ( ![d boolForKey:@"FastPost"] ) {
                    
                    NSLog(@"FastPost Disable");
                    
                    //テキスト
                    if ( pBoardType == 0 ) {
                        
                        NSLog(@"pBoardType Text");
                        
                        //ペーストボード内容をPost入力欄にコピー
                        postText.text = pboard.string;
                        int num = [TWTwitterCharCounter charCounter:postText.text];
                        postCharLabel.text = [NSString stringWithFormat:@"%d", num];
                        
                    //画像
                    }else if ( pBoardType == 1 ) {
                        
                        NSLog(@"pBoardType Image");
                        
                        //ペーストボードの画像をサムネイル表示
                        imagePreview.image = pboard.image;
                    }
                    
                    //Post入力状態にする
                    [postText becomeFirstResponder];
                
                //FastPostが有効な場合
                }else {
                    
                    NSLog(@"FastPost Enable");
                    
                    //コールバックが有効な場合
                    if ( [d boolForKey:@"CallBack"] ) {
                        
                        NSLog(@"CallBack Enable");
                        
                        //CallbackSchemeが空でない
                        if ( ![[d objectForKey:@"CallBackScheme"] isEqualToString:@""] ||
                            [d objectForKey:@"CallBackScheme"] != nil) {
                            
                            //CallbackSchemeがアクセス可能な物がテスト
                            canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[d objectForKey:@"CallBackScheme"]]];
                        }
                    }
                    
                    //ペーストボード内がテキスト
                    if ( pBoardType == 0 ) {
                        
                        //t.coを考慮した文字数カウントを行う
                        int num = [TWTwitterCharCounter charCounter:pboard.string];
                        
                        if ( num < 0 ) {
                            
                            //140字を超えていた場合
                            ShowAlert *alert = [[ShowAlert alloc] init];
                            [alert error:[NSString stringWithFormat:@"Post message is over 140: %d", num]];
                            
                            NSLog(@"%@", [NSString stringWithFormat:@"Post message is over 140: %d", num]);
                            
                        }else {
                            
                            //投稿可能文字数である
                            canPost = YES;
                        }
                    }
                }
                
                if ( canPost ) {
                 
                    //投稿処理
                    [TWSendTweet post:pboard.string];
                    
                    //コールバックが有効
                    if ( [d boolForKey:@"CallBack"] ) {
                        
                        //コールバックスキームが開けない
                        if ( !canOpen ) {
                            
                            NSLog(@"Can't callBack");
                            
                            ShowAlert *alert = [[ShowAlert alloc] init];
                            [alert error:@"Can't callBack"];
                            
                        //コールバックスキームを開くことが出来る
                        }else {
                            
                            NSLog(@"CallBack");
                            
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[d objectForKey:@"CallBackScheme"]]];
                        }
                    }
                    
                //投稿不可能な場合
                }else {
                    
                    //ペーストボード内容をPost入力欄にコピー
                    postText.text = pboard.string;
                    int num = [TWTwitterCharCounter charCounter:postText.text];
                    postCharLabel.text = [NSString stringWithFormat:@"%d", num];
                }
                
            }else {
                
                //インターネ接続されていない
                ShowAlert *alert = [[ShowAlert alloc] init];
                [alert error:@"No internet connection"];
            }
        }
    }
}

- (void)viewDidUnload {
    
    [self setPostButton:nil];
    [self setPostText:nil];
    [self setCallbackLabel:nil];
    [self setCallbackTextField:nil];
    [self setCallbackSwitch:nil];
    [self setDicButton:nil];
    [self setFastPostLabel:nil];
    [self setFastPostSwitch:nil];
    [self setPostCharLabel:nil];
    [self setImagePreview:nil];
    [self setImageSettingButton:nil];
    [self setSv:nil];
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
    [fastPostLabel release];
    [fastPostSwitch release];
    [postCharLabel release];
    [imagePreview release];
    [imageSettingButton release];
    [sv release];
    
    [super dealloc];
}

@end