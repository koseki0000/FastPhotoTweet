//
//  ViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "ViewController.h"

#define TOP_BAR [NSArray arrayWithObjects:trashButton, flexibleSpace, idButton, flexibleSpace, resendButton, flexibleSpace, imageSettingButton, flexibleSpace, postButton, nil]
#define BOTTOM_BAR [NSArray arrayWithObjects:settingButton, flexibleSpace, addButton, nil]

#define IMGUR_API_KEY   @"6de089e68b55d6e390d246c4bf932901"
#define TWITPIC_API_KEY @"95cf146048caad3267f95219b379e61c"
#define OAUTH_KEY       @"dVbmOIma7UCc5ZkV3SckQ"
#define OAUTH_SECRET    @"wnDptUj4VpGLZebfLT3IInTZPkPS4XimYh6WXAmdI"

#define BLANK @""

@implementation ViewController
@synthesize resendButton;
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
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    postText.text = BLANK;
    changeAccount = NO;
    cameraMode = NO;
    repeatedPost = NO;
    resendImage = NO;
    actionSheetNo = 0;
    
    postText.layer.borderWidth = 2;
	postText.layer.borderColor = [[UIColor blackColor] CGColor];
    
    [d removeObjectForKey:@"Notification"];
    
    //処理中を表すビューを生成
    grayView = [[GrayView alloc] init];
    [sv addSubview:grayView];
    
    //ツールバーにボタンをセット
    [topBar setItems:TOP_BAR animated:NO];
    [bottomBar setItems:BOTTOM_BAR animated:NO];
    
    //保存されている情報をロード
    [self loadSettings];
    
    //インターネット接続のチェック
    [self reachability];
    
    //iOSバージョン判定
    if ( [self ios5Check] ) {
        
        //iOS5
        
        ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:accountType 
                                withCompletionHandler:^( BOOL granted, NSError *error ) {
            
             dispatch_sync(dispatch_get_main_queue(), ^{
                 
                 if ( granted ) {
                     
                     NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
                     
                     if ( twitterAccounts.count > 0 ) {
                         
                         twAccount = [[twitterAccounts objectAtIndex:[d integerForKey:@"UseAccount"]] retain];
                         
                         ShowAlert *alert = [[ShowAlert alloc] init];
                         [alert title:@"Success" message:[NSString stringWithFormat:@"Account Name: %@", twAccount.username]];
                         
                         NSLog(@"twAccount: %@", twAccount);
                         
                         //入力可能状態にする
                         [postText becomeFirstResponder];
            
                         //更新情報の表示
                         [self showInfomation];
                         
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
        
        ShowAlert *alert = [[ShowAlert alloc] init];
        [alert error:@"Twitter account access denied"];
    }
    
    //for debug
    [self testMethod];
}

- (void)testMethod {
    
}

- (void)loadSettings {
    
    if ( ![EmptyCheck check:[d objectForKey:@"UUID"]] ) {
        
        //UUIDを生成して保存
        CFUUIDRef uuidObj = CFUUIDCreate(kCFAllocatorDefault);
        NSString *uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
        CFRelease(uuidObj);
        
        [d setObject:uuidString forKey:@"UUID"];
        
        NSLog(@"Create UUID: %@", uuidString);
        
    }else {
        
        NSLog(@"UUID: %@", [d objectForKey:@"UUID"]);
    }
    
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
        [d setObject:BLANK forKey:@"CallBackScheme"];
        
    }else {
        
        //スキームをセット
        callbackTextField.text = [d objectForKey:@"CallBackScheme"];
    }
    
    //画像形式が設定されていない場合JPGを設定
    if ( ![EmptyCheck check:[d objectForKey:@"SaveImageType"]] ) {
        [d setObject:@"JPG" forKey:@"SaveImageType"];
    }
    
    //リサイズ最大長辺が設定されていない場合640を設定
    if ( [d integerForKey:@"ImageMaxSize"] == 0 ) {
        [d setInteger:640 forKey:@"ImageMaxSize"];
    }
    
    //カスタム書式が設定されていない場合デフォルト書式を設定
    if ( ![EmptyCheck check:[d objectForKey:@"NowPlayingEditText"]] ) {
        [d setObject:@" #nowplaying [st] - [ar] " forKey:@"NowPlayingEditText"];
    }
    
    //サブ書式が設定されていない場合デフォルト書式を設定
    if ( ![EmptyCheck check:[d objectForKey:@"NowPlayingEditTextSub"]] ) {
        [d setObject:@" #nowplaying [st] - [ar] " forKey:@"NowPlayingEditTextSub"];
    }
    
    //写真投稿先が設定されていない場合Twitterを設定
    if ( ![EmptyCheck check:[d objectForKey:@"PhotoService"]] ) {
        [d setObject:@"Twitter" forKey:@"PhotoService"];
    }
    
    //設定を即反映
    [d synchronize];
}

- (void)showInfomation {
    
    NSLog(@"showInfomation");
    
    BOOL check = YES;
    NSMutableDictionary *information = [NSMutableDictionary dictionary];
    
    if ( ![EmptyCheck check:[d dictionaryForKey:@"Information"]] ) {
        
        NSLog(@"init Information");
        [d setObject:[NSDictionary dictionary] forKey:@"Information"];
    }
    
    while ( check ) {
                
        if ( [[d dictionaryForKey:@"Information"] valueForKey:@"FirstRun"] == 0 ) {
            
            NSLog(@"FirstRun");
            
            ShowAlert *alert = [[ShowAlert alloc] init];
            [alert title:@"ようこそ" 
                message:@"message"];
            
            information = [[d dictionaryForKey:@"Information"] mutableCopy];
            [information setValue:[NSNumber numberWithInt:1] forKey:@"FirstRun"];
            
            NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:information];
            [d setObject:dic forKey:@"Information"];            
            [dic release];
            
            continue;
        }
        
        NSString *newVersion = @"1.0";
        
        if ( [[d dictionaryForKey:@"Information"] valueForKey:newVersion] == 0 ) {
            
            NSLog(@"newVersion");
            
            ShowAlert *alert = [[ShowAlert alloc] init];
            [alert title:[NSString stringWithFormat:@"FastPhotoTweet %@", newVersion] 
                 message:@"message"];
            
            information = [[d dictionaryForKey:@"Information"] mutableCopy];
            [information setValue:[NSNumber numberWithInt:1] forKey:newVersion];
            
            NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:information];
            [d setObject:dic forKey:@"Information"];
            [dic release];
            
            continue;
        }
        
        check = NO;
    }
    
    NSLog(@"Information: %@", [d dictionaryForKey:@"Information"]);
    
    //設定を即反映
    [d synchronize];
}

- (IBAction)pushPostButton:(id)sender {
    
    //iOSバージョン判定
    if ( [self ios5Check] ) {

        //Internet接続のチェック
        if ( [self reachability] ) {
            
            NSString *text = [[[NSString alloc] initWithString:BLANK] autorelease];
            
            if ( [postText.text isEqualToString:BLANK] ) {

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
                
                //入力欄を空にする
                postText.text = BLANK;
             
            //画像が設定されている場合
            }else {
                
                //画像投稿先がTwitterの場合
                if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitter"] && !resendImage ) {
                    
                    //文字列と画像をバックグラウンドプロセスで投稿
                    NSArray *postData = [NSArray arrayWithObjects:text, imagePreview.image, nil];
                    [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
                    
                //画像投稿先がimg.urかTwitpicもしくは画像の再投稿
                }else {
                    
                    //文字列をバックグラウンドプロセスで投稿
                    NSArray *postData = [NSArray arrayWithObjects:text, nil, nil];
                    [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
                }
                
                //入力欄と画像プレビューを空にする
                postText.text = BLANK;
                imagePreview.image = nil;
                resendImage = NO;
            }
        }
    }
}

- (void)postDone:(NSNotification *)center {

    NSLog(@"postDone: %@", center.userInfo);
    
    NSString *result = [center.userInfo objectForKey:@"PostResult"];
    
    //[0]アカウント番号 [1]アカウント名 [2]テキスト [3]画像
    NSArray *resultData = [center.userInfo objectForKey:@"PostData"];

    if ( [result isEqualToString:@"Success"] ) {

    }else if ( [result isEqualToString:@"PhotoSuccess"] ) {
             
    }else if ( [result isEqualToString:@"Error"] ) {
        
        [appDelegate.postError addObject:resultData];
        
    }else if ( [result isEqualToString:@"PhotoError"] ) {
        
        [appDelegate.postError addObject:resultData];
    }
    
    //再投稿ボタンの有効･無効切り替え
    if ( appDelegate.postError.count == 0 ) {
        
        resendButton.enabled = YES;
        
    }else {
        
        resendButton.enabled = YES;
    }
}

- (IBAction)pushResendButton:(id)sender {
    
    NSLog(@"pushResendButton");
    
    appDelegate.resendMode = [NSNumber numberWithInt:1];
    
    ResendViewController *dialog = [[[ResendViewController alloc] init] autorelease];
    dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:dialog animated:YES];
}

- (IBAction)pushTrashButton:(id)sender {
    
    NSLog(@"Trash");
    
    postText.text = BLANK;
    imagePreview.image = nil;
    resendImage = NO;
    [self countText];
}

- (IBAction)pushSettingButton:(id)sender {
    
    NSLog(@"Setting");
    
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
                            otherButtonTitles:@"Tweet", @"FastTweet", @"PhotoTweet", @"NowPlaying", nil];
	[sheet autorelease];
	[sheet showInView:self.view];
}

- (IBAction)pushImageSettingButton:(id)sender {
    
    NSLog(@"pushImageSettingButton");
    
    if ( [d boolForKey:@"RepeatedPost"] ) {
        
        actionSheetNo = 2;
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"連続投稿"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"ON", @"OFF", nil];
        [sheet autorelease];
        [sheet showInView:self.view];
        
    }else {

        [self showImagePicker];
    }
}

- (void)showImagePicker {
    
    NSLog(@"showImagePicker");
    
    //イメージピッカーを表示
    UIImagePickerController *picPicker = [[UIImagePickerController alloc] init];
    
    if ( [d integerForKey:@"ImageSource"] == 0 ) {
        
        picPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    }else if ( [d integerForKey:@"ImageSource"] == 1 ) {
        
        picPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
    }else if ( [d integerForKey:@"ImageSource"] == 2 ) {
        
        actionSheetNo = 1;
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"画像ソース"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"カメラロール", @"カメラ", nil];
        [sheet autorelease];
        [sheet showInView:self.view];
        
        [picPicker release];
        
        return;
    }
    
    picPicker.delegate = self;
    [self presentModalViewController:picPicker animated:YES];
    [picPicker release];
}

- (void)imagePickerController:(UIImagePickerController *)picPicker
        didFinishPickingImage:(UIImage *)image 
                  editingInfo:(NSDictionary*)editingInfo {

    //画像ソースがカメラの場合保存
    if ( [d integerForKey:@"ImageSource"] == 1 || cameraMode ) {
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    
    //画像が選択された場合
    if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"img.ur"] || 
         [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitpic"] ) {
        
        //画像アップロード開始
        [self uploadImage:image];
    }
    
    //画像を設定
    imagePreview.image = image;
    
    //モーダルビューを閉じる
    if ( !repeatedPost ) {
        
        [picPicker dismissModalViewControllerAnimated:YES];
    }
    
    //Post入力状態にする
    [postText becomeFirstResponder];
    [postText setSelectedRange:NSMakeRange(0, 0)];
    [self countText];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picPicker {
 
    //画像選択がキャンセルされた場合
    //モーダルビューを閉じる
    repeatedPost = NO;
    [picPicker dismissModalViewControllerAnimated:YES];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    //アップロードに成功した場合
    
    @try {
        
        //レスポンスのStringからDictionaryを生成
        NSDictionary *result = [request.responseString JSONValue];
        
        NSLog(@"resultDic: %@", result);
        
        NSString *imageURL;
        
        //Dictionaryから画像URLを抜き出す
        if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"img.ur"] ) {
            
            imageURL = [[[result objectForKey:@"upload"] objectForKey:@"links"] objectForKey:@"original"];
            
        }else if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitpic"] ) {
            
            imageURL = [result objectForKey:@"url"];
        }
        
        //アップロードが成功しているかチェック
        if ( ![EmptyCheck check:imageURL] ) {
            
            ShowAlert *alert = [[ShowAlert alloc] init];
            [alert error:@"アップロードに失敗しました。"];
            
            return;
        }
        
        //Post入力欄の最後にURLを付ける
        postText.text = [NSString stringWithFormat:@"%@ %@ ", postText.text, imageURL];
        
        //連続するスペースを1つにする
        postText.text = [ReplaceOrDelete replaceWordReturnStr:postText.text 
                                                  replaceWord:@"  "
                                                 replacedWord:@" "];
        
        //文字数カウントを行いラベルに反映
        [self countText];
        
    }@catch ( NSException *e ) {
        
    }@finally {
        
        //処理中表示をオフ
        [grayView off];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    //アップロードに失敗した場合
    
    NSDictionary *result = [request.responseString JSONValue];
    NSLog(@"resultDic: %@", result);
    
    ShowAlert *alert = [[ShowAlert alloc] init];
    [alert error:@"アップロードに失敗しました。"];
    
    //処理中表示をオフ
    [grayView off];
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
    [sv setContentOffset:CGPointMake(0, 120) animated:YES];
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
        [d setBool:YES forKey:@"AddNotificationCenter"];
        
        UILocalNotification *localPush = [[UILocalNotification alloc] init];
        localPush.timeZone = [NSTimeZone defaultTimeZone];
        
        if ( buttonIndex == 0 ) {

            localPush.alertBody = @"Tweet";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"tweet", @"scheme", nil];
            
            NSLog(@"Add NotificationCenter Tweet");
        
        }else if ( buttonIndex == 1 ) {
            
            localPush.alertBody = @"FastTweet";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"fast", @"scheme", nil];
            
            NSLog(@"Add NotificationCenter FastTweet");
            
        }else if ( buttonIndex == 2 ) {
            
            localPush.alertBody = @"PhotoTweet";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"photo", @"scheme", nil];

            NSLog(@"Add NotificationCenter PhotoTweet");
            
        }else if ( buttonIndex == 3 ) {
            
            localPush.alertBody = @"NowPlaying";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"music", @"scheme", nil];
            
            NSLog(@"Add NotificationCenter NowPlaying");
            
        }else {
            
            [localPush release];
            return;
        }
        
        localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
        [localPush release];
        
    }else if ( actionSheetNo == 1 ) {
        
        //イメージピッカーを表示
        UIImagePickerController *picPicker = [[UIImagePickerController alloc] init];
        
        if ( buttonIndex == 0 ) {
            
            //カメラロールを開く
            cameraMode = NO;
            picPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
        }else if ( buttonIndex == 1 ) {
            
            //写真を撮る
            cameraMode = YES;
            picPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
        }else {
            
            //キャンセル
            [picPicker release];
            
            return;
        }
        
        picPicker.delegate = self;
        [self presentModalViewController:picPicker animated:YES];
        [picPicker release];
        
    }else if ( actionSheetNo == 2 ) {
        
        if ( buttonIndex == 0 ) {
            
            repeatedPost = YES;
            
        }else if ( buttonIndex == 1 ) {
            
            repeatedPost = NO;
            
        }else {
            
            return;
        }
        
        [self showImagePicker];
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
    
    //文字数をカウントしてラベルに反映
    [self countText];
}

- (void)countText {
    
    //t.coを考慮した文字数カウントを行う
    int num = [TWTwitterCharCounter charCounter:postText.text];
    
    //画像投稿先がTwitterの場合で画像が設定されている場合入力可能文字数を21文字減らす
    if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitter"] ) {
        
        if ( imagePreview.image != nil ) {
            
            num = num - 21;
        }
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

- (void)uploadImage:(UIImage *)image {
    
    //処理中を表すビューを表示
    [grayView onAndSetSize:postText.frame.origin.x   y:postText.frame.origin.y
                         w:postText.frame.size.width h:postText.frame.size.height];
    
    //画像をリサイズするか判定
    if ( [d boolForKey:@"ResizeImage"] ) {
        
        //リサイズを行う
        image = [ResizeImage aspectResize:image];
    }
    
    //UIImageをNSDataに変換
    NSData *imageData = [EncodeImage image:image];
    
    //リクエストURLを指定
    NSURL *URL;
    
    if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"img.ur"] ) {
        
        URL = [NSURL URLWithString:@"http://api.imgur.com/2/upload.json"];
        
    }else if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitpic"] ) {
        
        URL = [NSURL URLWithString:@"http://api.twitpic.com/1/upload.json"];
    }
    
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:URL] autorelease];
    
    if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"img.ur"] ) {
        
        NSLog(@"img.ur upload");
        
        [request addPostValue:IMGUR_API_KEY forKey:@"key"];
        [request addData:imageData forKey:@"image"];
        
    }else if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitpic"] ) {
        
        NSLog(@"Twitpic upload");
        
        NSDictionary *dic = [d dictionaryForKey:@"OAuthAccount"];
        
        if ( [EmptyCheck check:[dic objectForKey:twAccount.username]] ) {
            
            NSString *key = [UUIDEncryptor decryption:[[dic objectForKey:twAccount.username] objectAtIndex:0]];
            NSString *secret = [UUIDEncryptor decryption:[[dic objectForKey:twAccount.username] objectAtIndex:1]];
            
            [request addPostValue:TWITPIC_API_KEY forKey:@"key"];
            [request addPostValue:OAUTH_KEY forKey:@"consumer_token"];
            [request addPostValue:OAUTH_SECRET forKey:@"consumer_secret"];
            [request addPostValue:key forKey:@"oauth_token"];
            [request addPostValue:secret forKey:@"oauth_secret"];
            [request addPostValue:postText.text forKey:@"message"];
            [request addData:imageData forKey:@"media"];
            
        }else {
            
            //Twitpic投稿が不可な場合はimg.urに投稿
            request.url = [NSURL URLWithString:@"http://api.imgur.com/2/upload.json"];
            
            [d setObject:@"img.ur" forKey:@"PhotoService"];
            [request addPostValue:IMGUR_API_KEY forKey:@"key"];
            [request addData:imageData forKey:@"image"];
            
            ShowAlert *alert = [[ShowAlert alloc] init];
            [alert error:[NSString stringWithFormat:@"%@のTwitpicアカウントが見つからなかったためimg.urに投稿しました。", twAccount.username]];
        }
    }
    
    [request setDelegate:self];
    [request start];
}

- (void)becomeActive:(NSNotification *)notification {
    
    //アプリケーションがアクティブになった際に呼ばれる
    NSLog(@"becomeActive");
    
    //設定が有効な場合Post入力可能状態にする
    if ( [d boolForKey:@"ShowKeyboard"] ) {
        
        [postText becomeFirstResponder];
    }
    
    //通知判定がある場合
    if ( [d boolForKey:@"Notification"] ) {
        
        NSLog(@"Notification: YES");
        
        //通知判定を削除
        [d removeObjectForKey:@"Notification"];
        
        //iOS5以降かチェック
        if ( [self ios5Check] ) {
            
            UIPasteboard *pboard = [UIPasteboard generalPasteboard];
            
            if ( twAccount == nil ) {
                
                ShowAlert *alert = [[ShowAlert alloc] init];
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
                    
                    //投稿可能文字数(1-140)
                    if ( length > 0 ) {
                        
                        //FastPostが有効、またはNowPlaying限定CallBackが有効
                        if ( [d boolForKey:@"FastPost"] || [d boolForKey:@"NowPlayingFastPost"] ) {
                            
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
                        
                    }else if ( length == 0 ) {
                        
                        //再生中でなかった場合
                        ShowAlert *alert = [[ShowAlert alloc] init];
                        [alert error:@"iPod再生中に使用してください。"];
                        
                    //140字を超えていた場合
                    }else {
                        
                        ShowAlert *alert = [[ShowAlert alloc] init];
                        [alert error:[NSString stringWithFormat:@"Post message is over 140: %d", length]];
                        
                        //入力欄に貼り付け
                        postText.text = nowPlayingText;
                        [postText becomeFirstResponder];
                        [postText setSelectedRange:NSMakeRange(0, 0)];
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
                        
                        if ( [[d objectForKey:@"NotificationType"] isEqualToString:@"tweet"] ) {
                            
                            NSLog(@"NotificationType tweet");
                            
                            if ( pBoardType == 0 ) {
                                
                                NSLog(@"pBoardType Text");
                                
                                //ペーストボード内容をPost入力欄にコピー
                                postText.text = pboard.string;
                                
                            }else {
                                
                                NSLog(@"pBoardType not text");
                            }
                            
                            //Post入力状態にする
                            [postText becomeFirstResponder];
                            
                        }else if ( [[d objectForKey:@"NotificationType"] isEqualToString:@"photo"] ) {
                            
                            NSLog(@"NotificationType photo");
                            
                            if ( pBoardType == 1 ) {
                                
                                NSLog(@"pBoardType Photo");
                                
                                UIImage *image = pboard.image;
                                
                                if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"img.ur"] || 
                                     [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitpic"] ) {
                                    
                                    //画像アップロード開始
                                    [self uploadImage:image];
                                }
                                
                                //ペーストボードの画像をサムネイル表示
                                imagePreview.image = image;
                                
                                //Post入力状態にする
                                [postText becomeFirstResponder];
                                
                            }else {
                                
                                NSLog(@"pBoardType not Photo");
                                
                                [self pushImageSettingButton:nil];
                            }
                        }
                        
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
                                ShowAlert *alert = [[ShowAlert alloc] init];
                                [alert error:[NSString stringWithFormat:@"Post message is over 140: %d", num]];
                                
                            }else {
                                
                                //投稿可能文字数である
                                canPost = YES;
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
                            }
                        }
                    }
                }
                
            }else {
                
                //インターネット接続されていない
                ShowAlert *alert = [[ShowAlert alloc] init];
                [alert error:@"No internet connection"];
            }
        }
        
    }else {
        
        NSLog(@"Notification: NO");
    }
    
    [self countText];
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
            
            ShowAlert *alert = [[ShowAlert alloc] init];
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
    
    NSMutableString *resultText = [NSMutableString stringWithString:BLANK];
    
    @try {
        
        //再生中各種の曲の各種情報を取得
        MPMusicPlayerController *player = [MPMusicPlayerController iPodMusicPlayer];
        NSString *songTitle = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
        NSString *songArtist = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];
        NSString *albumTitle = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyAlbumTitle];
        NSNumber *playCount = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyPlayCount];
        NSNumber *ratingNum = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyRating];
        
        //曲名が無い場合は終了
        if ( songTitle.length == 0 ) {
            
            return BLANK;
        }
        
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
        
        //自分で設定した書式を使用しない場合
        if ( [d boolForKey:@"NowPlayingEdit"] ) {
            
            NSLog(@"template");
            
            //自分で設定した書式に再生中の曲の情報を埋め込む
            
            resultText = [NSMutableString stringWithString:[d stringForKey:@"NowPlayingEditText"]];
            
            //サブ書式使用設定が2(OFF)以外の場合
            if ( [d boolForKey:@"NowPlayingEditSub"] != 0 ) {
                
                //サブ書式使用設定が完全一致かつ条件に当てはまる場合
                if ( [d integerForKey:@"NowPlayingEditSub"] == 2 && [albumTitle isEqualToString:songTitle] ) {
                    
                    resultText = [NSMutableString stringWithString:[d stringForKey:@"NowPlayingEditTextSub"]];
                    
                //サブ書式使用設定が前方一致かつ条件に当てはまる場合
                }else if ( [d integerForKey:@"NowPlayingEditSub"] == 1 && [albumTitle hasPrefix:songTitle] ) {
                    
                    resultText = [NSMutableString stringWithString:[d stringForKey:@"NowPlayingEditTextSub"]];
                }
            }
                        
            //曲情報を書式に埋め込み
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
    [self setResendButton:nil];
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
    
    if ( changeAccount || [d boolForKey:@"ChangeAccount"] ) {
        
        NSLog(@"ChangeAccount");
        
        [d removeObjectForKey:@"ChangeAccount"];
        changeAccount = NO;
        [twAccount release];
        
        //アカウント設定を更新
        ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
        twAccount = [[twitterAccounts objectAtIndex:[d integerForKey:@"UseAccount"]] retain];
        
    }else if ( [appDelegate.resendMode intValue] != 0 ) {
        
        appDelegate.resendMode = [NSNumber numberWithInt:0];
        
        int indexNum = [appDelegate.resendNumber intValue];
        NSArray *resendArray = [appDelegate.postError objectAtIndex:indexNum];
        
        int account = [[resendArray objectAtIndex:1] intValue];
        [d setInteger:account forKey:@"UseAccount"];
        
        postText.text = [resendArray objectAtIndex:2];
        
        if ( resendArray.count == 3 ) {
            
            NSLog(@"Resend data set TEXT");
            
        }else {
            
            NSLog(@"Resend data set PHOTO");
            resendImage = YES;
            imagePreview.image = [resendArray objectAtIndex:3];
        }
        
        [appDelegate.postError removeObjectAtIndex:indexNum];
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
    [resendButton release];
    [super dealloc];
}

@end