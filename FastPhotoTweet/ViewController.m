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
@synthesize tapGesture;
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
    
    //投稿完了通知を受け取る設定
    [notificationCenter addObserver:self 
                           selector:@selector(postDone:) 
                               name:@"PostDone" 
                             object:nil];
    
    //各種初期値をセット
    d = [NSUserDefaults standardUserDefaults];
    postedDic = [[NSMutableDictionary alloc] init];
    postText.text = @"";
    changeAccount = NO;
    actionSheetNo = 0;
    postedCount = 0;
    
    //for debug
    [d setBool:YES forKey:@"NoResizeIphone4Ss"];
    [d setBool:YES forKey:@"NowPlayingEdit"];
    [d setObject:@" #nowplaying : [st] - [ar] - [at] - [pc]回目 - [rt]" forKey:@"NowPlayingEditText"];
    [d setObject:@" #nowplaying : [st] - [ar] - [pc]回目 - [rt]" forKey:@"NowPlayingEditTextSub"];
    [d removeObjectForKey:@"Notification"];
    [d synchronize];
    
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
        
    } else {
        
        twAccount = nil;
        
        ShowAlert *alert = [[[ShowAlert alloc] init] autorelease];
        [alert error:@"Twitter account access denied"];
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
    
    if ( ![EmptyCheck check:[d objectForKey:@"CallBackScheme"]] ) {
        
        //スキームが保存されていない
        //空のキーを保存
        [d setObject:@"" forKey:@"CallBackScheme"];
        
    }else {
        
        //スキームをセット
        callbackTextField.text = [d objectForKey:@"CallBackScheme"];
    }
        
    //リサイズ最大長辺が設定されていない場合640を設定
    if ( [d integerForKey:@"ImageMaxSize"] == 0 ) {
        [d setInteger:640 forKey:@"ImageMaxSize"];
    }
    
    //画像形式が設定されていない場合JPGを設定
    if ( ![EmptyCheck check:[d objectForKey:@"SaveImageType"]] ) {
        [d setObject:@"JPG" forKey:@"SaveImageType"];
    }
}

- (IBAction)pushPostButton:(id)sender {
    
    //iOSバージョン判定
    if ( [self ios5Check] ) {

        //Internet接続のチェック
        if ( [self reachability] ) {
            
            NSString *text = [[[NSString alloc] initWithString:@""] autorelease];
            
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
            
            //画像が設定されていない場合
            if ( imagePreview.image == nil ) {
                
                //文字列をバックグラウンドプロセスで投稿
                NSArray *postData = [NSArray arrayWithObjects:text, nil, nil];
                [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
                
                //投稿失敗時の再投稿用に文字列を保存
                NSArray *saveArray = [NSArray arrayWithObjects:text, nil, nil];
                [postedDic setObject:saveArray forKey:[NSString stringWithFormat:@"%d", postedCount]];
                
                //投稿カウントを増やす
                postedCount++;
                
                //入力欄を空にする
                postText.text = @"";
             
            //画像が設定されている場合
            }else {
                
                //文字列と画像をバックグラウンドプロセスで投稿
                NSArray *postData = [NSArray arrayWithObjects:text, imagePreview.image, nil];
                [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
                
                //投稿失敗時の再投稿用に文字列と画像を保存
                NSArray *saveArray = [NSArray arrayWithObjects:text, imagePreview.image, nil];
                [postedDic setObject:saveArray forKey:[NSString stringWithFormat:@"%d", postedCount]];
                
                //投稿カウントを増やす
                postedCount++;
                
                //入力欄と画像プレビューを空にする
                postText.text = @"";
                imagePreview.image = nil;
            }
        }
    }
}

- (void)postDone:(NSNotification *)center {

    NSLog(@"PostedDic: %@", postedDic);
    
    reSendText = nil;
    reSendImage = nil;
    
    NSString *result = [center.userInfo objectForKey:@"PostResult"];
    NSArray *resultData = [center.userInfo objectForKey:@"PostData"];
    
    //投稿完了した文字列
    NSString *resultString = [resultData objectAtIndex:0];
    NSLog(@"resultString: %@", resultString);
    
    NSArray *dicValue = [postedDic allValues];
    NSArray *dicKey = [postedDic allKeys];
    
    //文字投稿成功
    if ( [result isEqualToString:@"Success"] ||
         [result isEqualToString:@"PhotoSuccess"] ) {
        
        NSLog(@"postDone: Success");
        
        int i = 0;
        for ( id obj in dicValue ) {
    
            NSLog(@"obj%d: %@",i , [obj objectAtIndex:0]);
            
            if ( [resultString hasPrefix:[obj objectAtIndex:0]] ) {
                
                NSLog(@"Delete: %d", i);
                [postedDic removeObjectForKey:[dicKey objectAtIndex:i]];
            }
            
            i++;
        }

    //投稿失敗
    }else if ( [result isEqualToString:@"Error"] ) {
        
        NSLog(@"ReSend Text");
        
        if ( [EmptyCheck check:resultData] ) {
            
            postText.text = [resultData objectAtIndex:0];
        }
        
    }else if ( [result isEqualToString:@"PhotoError"] ) {
        
        NSLog(@"ReSend Text, Image");
        
        if ( [EmptyCheck check:resultData] ) {
            
            postText.text = [resultData objectAtIndex:0];
            imagePreview.image = [resultData objectAtIndex:1];
        }
    }
    
    NSLog(@"PostedDic: %@", postedDic);
}

- (IBAction)pushTrashButton:(id)sender {
    
    NSLog(@"Trash");
    
    postText.text = @"";
    imagePreview.image = nil;
}

- (IBAction)pushSettingButton:(id)sender {
    
    NSLog(@"Setting");
    
//    if ( imagePreview.image != nil ) {
//        
//        //for debug
//        imagePreview.image = [ResizeImage aspectResize:imagePreview.image];
//    }
    
    SettingViewController *dialog = [[[SettingViewController alloc] init] autorelease];
	dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:dialog animated:YES];
}

- (IBAction)pushIDButton:(id)sender {
    
    NSLog(@"ID Change");
    
    changeAccount = YES;
    
    IDChangeViewController *dialog = [[[IDChangeViewController alloc] init] autorelease];
	dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:dialog animated:YES];
}

- (IBAction)pushAddButton:(id)sender {
    
    actionSheetNo = 0;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"通知センター登録"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Tweet", @"PhotoTweet", @"Dictionary",
                                              @"NowPlaying", nil];
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
}

- (IBAction)textFieldStartEdit:(id)sender {
    
    //ビューの位置を上げる
    [sv setContentOffset:CGPointMake(0, 60) animated:YES];
}

- (IBAction)svTapGesture:(id)sender {
    
    NSLog(@"svTapGesture");
    
    [postText resignFirstResponder];
    [callbackTextField resignFirstResponder];
    [sv setContentOffset:CGPointMake(0, 0) animated:YES];
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
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
            
        }else if ( buttonIndex == 3 ) {
            
            localPush.alertBody = @"NowPlaying";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"music", @"scheme", nil];
            
            NSLog(@"Add NotificationCenter NowPlaying");
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
        ShowAlert *alert = [[[ShowAlert alloc] init] autorelease];
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
        
        ShowAlert *alert = [[[ShowAlert alloc] init] autorelease];
        [alert error:@"No Internet connection"];
    }
    
    return result;
}

- (void)textViewDidChange:(UITextView *)textView {

    //TextViewの内容が変更された時に呼ばれる
    
    //t.coを考慮した文字数カウントを行う
    int num = [TWTwitterCharCounter charCounter:postText.text];
    
    //画像が設定されている場合入力可能文字数を21文字減らす
    if ( imagePreview.image != nil ) {
        num = num - 21;
    }
    
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
        
        NSLog(@"Notification: YES");
        
        //通知判定を削除
        [d removeObjectForKey:@"Notification"];
        
        //iOS5以降かチェック
        if ( [self ios5Check] ) {
            
            UIPasteboard *pboard = [UIPasteboard generalPasteboard];
            
            //通知が辞書機能だった場合
            if ( [[d objectForKey:@"NotificationType"] isEqualToString:@"dic"] ) {
                
                NSLog(@"Dictionary Start");
                
                if ( [PasteboardType check] == 0 ) {
                    
                    UIReferenceLibraryViewController *controller = [[[UIReferenceLibraryViewController alloc] initWithTerm:pboard.string] autorelease];
                    [self presentModalViewController:controller animated:YES];
                    
                }else {
                    
                    ShowAlert *alert = [[[ShowAlert alloc] init] autorelease];
                    [alert error:@"ペーストボード内が文字以外です。"];
                }
                
                return;
            }
            
            //以下通知がtweetだった場合
            
            if ( twAccount == nil ) {
                
                //Twitterアカウントが見つからない場合設定に飛ばす
                ShowAlert *alert = [[[ShowAlert alloc] init] autorelease];
                [alert error:@"Twitter account nothing"];
                
                return;
            }
            
            //インターネット接続のチェック
            if ( [self reachability] ) {
                
                BOOL canPost = NO;
                
                if ( [[d objectForKey:@"NotificationType"] isEqualToString:@"music"] ) {
                    
                    NSLog(@"NowPlaying Start");
                    
                    NSString *nowPlayingText = [self nowPlaying];
                    int length = [TWTwitterCharCounter charCounter:nowPlayingText];
                    
                    if ( length > 0 ) {
                        
                        //FastPostが有効、またはNowPlaying限定CallBackが有効
                        if ( [d boolForKey:@"FastPost"] || [d boolForKey:@"NowPlayingCallBack"]) {
                            
                            NSArray *postData = [NSArray arrayWithObjects:nowPlayingText, nil, nil];
                            [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
                            
                            //CallBack、またはNowPlaying限定CallBackが有効
                            if ( [d boolForKey:@"CallBack"] || [d boolForKey:@"NowPlayingCallBack"] ) {
                                
                                NSLog(@"Callback Enable");
                                
                                //CallBack
                                [self callback];
                            }
                            
                        }else {
                            
                            postText.text = nowPlayingText;
                            [postText becomeFirstResponder];
                            [postText setSelectedRange:NSMakeRange(0, 0)];
                        }
                        
                    }else {
                        
                        //140字を超えていた場合
                        ShowAlert *alert = [[[ShowAlert alloc] init] autorelease];
                        [alert error:[NSString stringWithFormat:@"Post message is over 140: %d", length]];
                    }
                    
                }else {
                    
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
                        if ( [d boolForKey:@"CallBack"] || [d boolForKey:@"NowPlayingCallBack"] ) {
                            
                            NSLog(@"Callback Enable");
                            
                            //CallBack
                            [self callback];
                        }
                        
                        //ペーストボード内がテキスト
                        if ( pBoardType == 0 ) {
                            
                            //t.coを考慮した文字数カウントを行う
                            int num = [TWTwitterCharCounter charCounter:pboard.string];
                            
                            if ( num < 0 ) {
                                
                                //140字を超えていた場合
                                ShowAlert *alert = [[[ShowAlert alloc] init] autorelease];
                                [alert error:[NSString stringWithFormat:@"Post message is over 140: %d", num]];
                                
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
                        
                        //CallBack
                        [self callback];
                        
                        //投稿不可能な場合
                    }else {
                        
                        //ペーストボード内容をPost入力欄にコピー
                        postText.text = pboard.string;
                        int num = [TWTwitterCharCounter charCounter:postText.text];
                        postCharLabel.text = [NSString stringWithFormat:@"%d", num];
                    }
                }
                
            }else {
                
                //インターネット接続されていない
                ShowAlert *alert = [[[ShowAlert alloc] init] autorelease];
                [alert error:@"No internet connection"];
            }
        }
        
    }else {
        
        NSLog(@"Notification: NO");
    }
}

- (void)callback {
    
    NSLog(@"Callback Start");
    
    BOOL canOpen = NO;
    
    //CallbackSchemeが空でない
    if ( [EmptyCheck check:[d objectForKey:@"CallBackScheme"]] ) {
        
        //CallbackSchemeがアクセス可能な物がテスト
        canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[d objectForKey:@"CallBackScheme"]]];
        
        //コールバックスキームが開けない
        if ( !canOpen ) {
            
            NSLog(@"Can't callBack");
            
            ShowAlert *alert = [[[ShowAlert alloc] init] autorelease];
            [alert error:@"Can't callBack"];
            
            //コールバックスキームを開くことが出来る
        }else {
            
            NSLog(@"CallBack");
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[d objectForKey:@"CallBackScheme"]]];
        }
    }
}

- (NSString *)nowPlaying {
    
    NSLog(@"nowPlaying");
    
    NSMutableString *resultText = [NSMutableString stringWithString:@""];
    
    @try {
        
        //再生中各種の曲の各種情報を取得
        MPMusicPlayerController *player = [MPMusicPlayerController iPodMusicPlayer];
        NSString *songTitle = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
        NSString *songArtist = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];
        NSString *albumTitle = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyAlbumTitle];
        NSNumber *playCount = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyPlayCount];
        NSNumber *ratingNum = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyRating];
        
        //NSNumberをNSStringにキャスト
        int playCountInt = [playCount intValue];
        NSString *playCountStr = [NSString stringWithFormat:@"%d", playCountInt];
	    
        //NSNumberをNSStringにキャスト
        int rating = [ratingNum intValue];
        NSString *ratingStr = [NSString stringWithFormat:@"%d", rating];
        
        //数字の文字から☆表記に変換
        if ([ratingStr isEqualToString:@"0"]) {
            ratingStr = @"☆☆☆☆☆";
        }else if ([ratingStr isEqualToString:@"1"]) {
            ratingStr = @"★☆☆☆☆";
        }else if ([ratingStr isEqualToString:@"2"]) {
            ratingStr = @"★★☆☆☆";
        }else if ([ratingStr isEqualToString:@"3"]) {
            ratingStr = @"★★★☆☆";
        }else if ([ratingStr isEqualToString:@"4"]) {
            ratingStr = @"★★★★☆";
        }else if ([ratingStr isEqualToString:@"5"]) {
            ratingStr = @"★★★★★";
        }
        
        //曲名が空の場合は再生中じゃない
        if ( songTitle != nil ){
            
            //自分で設定した書式を使用しない場合
            if ( [d boolForKey:@"NowPlayingEdit"] ) {
                
                NSLog(@"template");
                
                //自分で設定した書式に再生中の曲の情報を埋め込む
                if ( [songTitle isEqualToString:albumTitle] ) {
                    
                    resultText = [NSMutableString stringWithString:[d stringForKey:@"NowPlayingEditTextSub"]];
                    
                }else {
                    
                    resultText = [NSMutableString stringWithString:[d stringForKey:@"NowPlayingEditText"]];
                }
                
                resultText = [ReplaceOrDelete replaceWordReturnMStr:resultText replaceWord:@"[st]" replacedWord:songTitle];
                resultText = [ReplaceOrDelete replaceWordReturnMStr:resultText replaceWord:@"[ar]" replacedWord:songArtist];
                resultText = [ReplaceOrDelete replaceWordReturnMStr:resultText replaceWord:@"[at]" replacedWord:albumTitle];
                resultText = [ReplaceOrDelete replaceWordReturnMStr:resultText replaceWord:@"[pc]" replacedWord:playCountStr];
                resultText = [ReplaceOrDelete replaceWordReturnMStr:resultText replaceWord:@"[rt]" replacedWord:ratingStr];
                
            }else {
                
                NSLog(@"default");
                
                //デフォルトの書式を適用
                resultText = [NSMutableString stringWithFormat:@" #nowplaying %@ - %@ ", songTitle, songArtist];
            }
        }
        
    }@catch (NSException *e) {
        
        NSLog(@"Exception: %@", e);
    }
    
    return (NSString *)resultText;
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
    [self setTapGesture:nil];
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
    [tapGesture release];
    [super dealloc];
}

@end