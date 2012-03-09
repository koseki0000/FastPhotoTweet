//
//  ViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "ViewController.h"

#define TOP_BAR [NSArray arrayWithObjects:trashButton, flexibleSpace, idButton, flexibleSpace, imageSettingButton, flexibleSpace, postButton, nil]
#define BOTTOM_BAR [NSArray arrayWithObjects:settingButton, flexibleSpace, addButton, nil]

@implementation ViewController
@synthesize sv;
@synthesize imageSettingButton;
@synthesize postText;
@synthesize callbackLabel;
@synthesize fastPostLabel;
@synthesize postCharLabel;
@synthesize callbackTextField;
@synthesize callbackSwitch;
@synthesize fastPostSwitch;
@synthesize imagePreview;
@synthesize topBar;
@synthesize trashButton;
@synthesize postButton;
@synthesize flexibleSpace;
@synthesize addButton;
@synthesize idButton;
@synthesize bottomBar;
@synthesize settingButton;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad");
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    //アプリがアクティブになった場合の通知を受け取る設定
    [notificationCenter addObserver:self
                           selector:@selector(becomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    
    [notificationCenter addObserver:self 
                           selector:@selector(postDone:) 
                               name:@"PostDone" 
                             object:nil];
    
    //各種初期値をセット
    d = [NSUserDefaults standardUserDefaults];
    postedText = [NSMutableArray array];
    postedImage = [NSMutableArray array];
    postText.text = @"";
    changeAccount = NO;
    actionSheetNo = 0;
    
    //for debug
    [d setInteger:1 forKey:@"noResizeIphone4Ss"];
    [d setInteger:800 forKey:@"imageMaxSize"];
    
    //ツールバーにボタンをセット
    [topBar setItems:TOP_BAR animated:NO];
    [bottomBar setItems:BOTTOM_BAR animated:NO];
    
    //保存されている情報をロード
    [self loadSettings];
    
    //iOSバージョン判定
    if ( [self ios5Check] ) {
        
        //iOS5
        
        ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:
         ^( BOOL granted, NSError *error ) {
             dispatch_sync(dispatch_get_main_queue(), ^{
                 if ( granted ) {
                     NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
                     if ( twitterAccounts.count > 0 ) {
                         
                         twAccount = [[twitterAccounts objectAtIndex:[d integerForKey:@"UseAccount"]] retain];
                         ShowAlert *alert = [[ShowAlert alloc] init];
                         [alert title:@"Success" message:[NSString stringWithFormat:@"Account Name: %@", twAccount.username]];
                         NSLog(@"twAccount: %@", twAccount);
                         
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
    if ( [EmptyCheck check:str] ) {
        
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
        if ( [self reachability] ) {

            NSString *text = @"";
            
            if ( [postText.text isEqualToString:@""] ) {

                //Post入力欄が空ならテスト用テキストを生成して投稿
                NSString *testDate = [NSDateFormatter localizedStringFromDate:[NSDate date] 
                                                                    dateStyle:kCFDateFormatterNoStyle
                                                                    timeStyle:kCFDateFormatterMediumStyle];
                
                text = [NSString stringWithFormat:@"TestDate: %@", testDate];
                
            }else {

                //文字が入力されている場合はそちらを投稿
                text = postText.text;
                
                
                //TODO 失敗時最投稿処理用の保存を行う
            }
            
            //画像が設定されていない場合
            if ( imagePreview.image == nil ) {
                
                //投稿失敗時の再投稿用に文字列を保存
                //[postedText addObject:text];
                
                //文字列をバックグラウンドプロセスで投稿
                NSArray *postData = [NSArray arrayWithObjects:text, nil, nil];
                [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
                
                //入力欄を空にする
                postText.text = @"";
             
            //画像が設定されている場合
            }else {
                
                //投稿失敗時の再投稿用に文字列と画像を保存
                //[postedText addObject:text];
                //[postedImage addObject:imagePreview.image];
                
                //文字列と画像をバックグラウンドプロセスで投稿
                NSArray *postData = [NSArray arrayWithObjects:text, imagePreview.image, nil];
                [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
                
                //入力欄と画像プレビューを空にする
                postText.text = @"";
                imagePreview.image = nil;
            }
        }
    }
}

- (void)postDone:(NSNotification *)center {

    NSString *result = [center.userInfo objectForKey:@"PostResult"];
    
    if ( [result isEqualToString:@"Success"] ) {
        
        //投稿成功、入力欄を空にする
        //postText.text = @"";
        
    }else if ( [result isEqualToString:@"PhotoSuccess"] ) {
        
        //投稿成功、入力欄と画像プレビューを空にする
        //postText.text = @"";
        //imagePreview.image = nil;
        
    }else {
        
        //TODO 投稿失敗、再投稿の確認を出す予定
    }
    
    //TODO Post失敗後再送信待ちの物があるかチェック
}

- (IBAction)pushTrashButton:(id)sender {
    
    NSLog(@"Trash");
    
    postText.text = @"";
    imagePreview.image = nil;
}

- (IBAction)pushSettingButton:(id)sender {
    
    NSLog(@"Setting");
    
    //for debug
    imagePreview.image = [ResizeImage aspectResize:imagePreview.image];
}

- (IBAction)pushIDButton:(id)sender {
    
    NSLog(@"ID Change");
    
    changeAccount = YES;
    
    IDChangeViewController *dialog = [[[IDChangeViewController alloc] init] autorelease];
	dialog.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:dialog animated:YES];
}

- (IBAction)pushAddButton:(id)sender {
    
    actionSheetNo = 0;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"通知センター登録"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Tweet", @"PhotoTweet", @"Dictionary", nil];
	[sheet autorelease];
	[sheet showInView:self.view];
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
    [sv setContentOffset:CGPointMake(0, 60) animated:YES];
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

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( actionSheetNo == 0 ) {
             
        //通知センターにアプリを登録
        //通知センター登録時は通知を受け取っても無視するように設定
        [d setBool:YES forKey:@"AddPhoto"];
        
        UILocalNotification *localPush = [[UILocalNotification alloc] init];
        localPush.timeZone = [NSTimeZone defaultTimeZone];
        
        if ( buttonIndex == 0 ) {

            localPush.alertBody = @"Tweet";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"tweet", @"scheme", nil];
            
            NSLog(@"Add NotificationCenter Tweet");
            
        }else if ( buttonIndex == 1 ) {
            
            localPush.alertBody = @"PhotoTweet";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"photo", @"scheme", nil];

            NSLog(@"Add NotificationCenter PhotoTweet");
            
        }else if ( buttonIndex == 2 ) {
            
            localPush.alertBody = @"Dictionary";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"dic", @"scheme", nil];
            
            NSLog(@"Add NotificationCenter Dictionary");
        }
        
        localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
        [localPush release];
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

- (BOOL)reachability {
    
    BOOL result = NO;
    
    if ( [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable ) {
        
        result = YES;
        
    }else {
        
        ShowAlert *alert = [[ShowAlert alloc] init];
        [alert error:@"No Internet connection"];
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
        
        postButton.enabled = NO;
        
    }else {
        
        postButton.enabled = YES;
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
                
                NSLog(@"Dictionary");
                
                if ( [PasteboardType check] == 0 ) {
                    
                    UIReferenceLibraryViewController *controller = [[[UIReferenceLibraryViewController alloc] initWithTerm:pboard.string] autorelease];
                    [self presentModalViewController:controller animated:YES];
                    
                }else {
                    
                    ShowAlert *alert = [[ShowAlert alloc] init];
                    [alert error:@"ペーストボード内が文字以外です。"];
                }
                
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
            if ( [self reachability] ) {
                
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
                        
                        if ( [[d objectForKey:@"NotificationType"] isEqualToString:@"photo"] ) {
                            
                            //ペーストボードの画像をサムネイル表示
                            imagePreview.image = pboard.image;
                            
                        }else {
                            
                            if ( [EmptyCheck check:pboard.string] ) {
                                
                                //ペーストボードが空
                                //入力可能状態にする
                                [postText becomeFirstResponder];
                                
                            }else {
                                
                                //入力欄にペーストボードのテキストをコピー
                                postText.text = pboard.string;
                            }
                        }
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
                    NSString *text = [[[NSString alloc] initWithString:pboard.string] autorelease];
                    NSArray *postData = [NSArray arrayWithObjects:text, nil, nil];
                    [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
                    
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
    
    [self setPostText:nil];
    [self setCallbackLabel:nil];
    [self setCallbackTextField:nil];
    [self setCallbackSwitch:nil];
    [self setFastPostLabel:nil];
    [self setFastPostSwitch:nil];
    [self setPostCharLabel:nil];
    [self setImagePreview:nil];
    [self setImageSettingButton:nil];
    [self setSv:nil];
    [self setTopBar:nil];
    [self setTrashButton:nil];
    [self setPostButton:nil];
    [self setFlexibleSpace:nil];
    [self setSettingButton:nil];
    [self setBottomBar:nil];
    [self setIdButton:nil];
    [self setAddButton:nil];
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
    
    NSLog(@"viewDidAppear");
    
    if ( changeAccount ) {
        
        NSLog(@"ChangeAccount");
        
        [twAccount release];
        
        //アカウント設定を更新
        ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
        twAccount = [[twitterAccounts objectAtIndex:[d integerForKey:@"UseAccount"]] retain];
        [twAccount retain];
        
        changeAccount = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    
	[super viewDidDisappear:animated];
}

- (void)dealloc {
    
    [twAccount release];
    
    [postText release];
    [callbackLabel release];
    [callbackTextField release];
    [callbackSwitch release];
    [fastPostLabel release];
    [fastPostSwitch release];
    [postCharLabel release];
    [imagePreview release];
    [imageSettingButton release];
    [sv release];
    
    [topBar release];
    [trashButton release];
    [postButton release];
    [flexibleSpace release];
    [settingButton release];
    [bottomBar release];
    [idButton release];
    [addButton release];
    [super dealloc];
}

@end