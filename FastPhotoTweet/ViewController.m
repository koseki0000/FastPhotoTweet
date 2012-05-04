//
//  ViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "ViewController.h"

#define TOP_BAR [NSArray arrayWithObjects:trashButton, flexibleSpace, idButton, flexibleSpace, resendButton, flexibleSpace, imageSettingButton, flexibleSpace, postButton, nil]
#define BOTTOM_BAR [NSArray arrayWithObjects:settingButton, flexibleSpace, actionButton, flexibleSpace, nowPlayingButton, flexibleSpace, addButton, nil]

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
@synthesize postCharLabel;
@synthesize callbackTextField;
@synthesize callbackSwitch;
@synthesize imagePreview;
@synthesize topBar;
@synthesize trashButton;
@synthesize postButton;
@synthesize flexibleSpace;
@synthesize addButton;
@synthesize tapGesture;
@synthesize rigthSwipe;
@synthesize leftSwipe;
@synthesize actionButton;
@synthesize nowPlayingButton;
@synthesize idButton;
@synthesize bottomBar;
@synthesize settingButton;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //NSLog(@"viewDidLoad");
    
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
    pboard = [UIPasteboard generalPasteboard];
    errorImage = nil;
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    postText.text = BLANK;
    changeAccount = NO;
    cameraMode = NO;
    repeatedPost = NO;
    webBrowserMode = NO;
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
                         
                         [ShowAlert title:@"Success" message:[NSString stringWithFormat:@"Account Name: %@", twAccount.username]];
                         
                         //NSLog(@"twAccount: %@", twAccount);
                         
                         //入力可能状態にする
                         [postText becomeFirstResponder];
            
                         //更新情報の表示
                         [self showInfomation];
                         
                     } else {
                         
                         twAccount = nil;
                         
                         [ShowAlert error:@"Twitterアカウントが見つかりませんでした。"];
                     }
                     
                 } else {
                     
                     twAccount = nil;
                     
                     [ShowAlert error:@"Twitterのアカウントへのアクセスが拒否されました。"];
                 }
             });
         }];
        
    } else {
        
        twAccount = nil;
        
        [ShowAlert error:@"Twitterのアカウントへのアクセスが拒否されました。"];
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
        
        //NSLog(@"Create UUID: %@", uuidString);
        
    }else {
        
        //NSLog(@"UUID: %@", [d objectForKey:@"UUID"]);
    }
    
    if ( [d boolForKey:@"CallBack"] ) {
        
        //オン
        callbackSwitch.on = YES;
        
    }else {
        
        //オフ
        callbackSwitch.on = NO;
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
    
    //NSLog(@"showInfomation");
    
    BOOL check = YES;
    NSMutableDictionary *information = [NSMutableDictionary dictionary];
    
    if ( ![EmptyCheck check:[d dictionaryForKey:@"Information"]] ) {
        
        //NSLog(@"init Information");
        [d setObject:[NSDictionary dictionary] forKey:@"Information"];
    }
    
    while ( check ) {
                
        if ( [[d dictionaryForKey:@"Information"] valueForKey:@"FirstRun"] == 0 ) {
            
            //NSLog(@"FirstRun");
            
            [ShowAlert title:@"ようこそ" 
                message:@"FastPhotoTweetへようこそ\n通知センターから様々なTweetを素早くTwitterに投稿する事が出来ます。始めに画面右下から通知センターへの登録を行なってください。"];
            
            information = [[d dictionaryForKey:@"Information"] mutableCopy];
            [information setValue:[NSNumber numberWithInt:1] forKey:@"FirstRun"];
            
            NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:information];
            [d setObject:dic forKey:@"Information"];            
            [dic release];
            
            continue;
        }
        
        NSString *newVersion = @"1.1";
        
        if ( [[d dictionaryForKey:@"Information"] valueForKey:newVersion] == 0 ) {
            
            //NSLog(@"newVersion");
            
            [ShowAlert title:[NSString stringWithFormat:@"FastPhotoTweet %@", newVersion] 
                 message:@"\n・「FastGoogle」機能を追加\n通知センターからペーストボード内の文字列を素早くGoogle検索する事が出来ます。\n・「WebPageShare」機能を追加\nURLの含まれる文字列がペーストボード内にある状態で使うと、ページタイトルを取得し、書式を整えた状態に変換されワンタッチでTwitterでリンクを共有する事が出来ます。"];
            
            information = [[d dictionaryForKey:@"Information"] mutableCopy];
            [information setValue:[NSNumber numberWithInt:1] forKey:newVersion];
            
            NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:information];
            [d setObject:dic forKey:@"Information"];
            [dic release];
            
            continue;
        }
        
        check = NO;
    }
    
    //NSLog(@"Information: %@", [d dictionaryForKey:@"Information"]);
    
    //設定を即反映
    [d synchronize];
}

- (IBAction)pushPostButton:(id)sender {
    
    //iOSバージョン判定
    if ( [self ios5Check] ) {

        //Internet接続のチェック
        if ( [self reachability] ) {
            
            NSString *text = [[[NSString alloc] initWithString:BLANK] autorelease];
            
            text = postText.text;
            
            if ( ![EmptyCheck check:text] ) {
                
                [ShowAlert error:@"文字が入力されていません。"];
                
                return;
            }
            
            //画像が設定されていない場合
            if ( imagePreview.image == nil ) {
                
                @autoreleasepool {
                    
                    //文字列をバックグラウンドプロセスで投稿
                    NSArray *postData = [NSArray arrayWithObjects:[self deleteWhiteSpace:text], nil];
                    [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
                }
                
                //入力欄を空にする
                postText.text = BLANK;
             
            //画像が設定されている場合
            }else {
                
                //画像投稿先がTwitterの場合
                if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitter"] ) {
                    
                    @autoreleasepool {
                        
                        //文字列と画像をバックグラウンドプロセスで投稿
                        NSArray *postData = [NSArray arrayWithObjects:[self deleteWhiteSpace:text], imagePreview.image, nil];
                        [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
                    }
                    
                //画像投稿先がimg.urかTwitpicもしくは画像の再投稿
                }else {
                    
                    @autoreleasepool {
                        
                        //文字列をバックグラウンドプロセスで投稿
                        NSArray *postData = [NSArray arrayWithObjects:[self deleteWhiteSpace:text], nil];
                        [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
                    }
                }
                
                //入力欄と画像プレビューを空にする
                postText.text = BLANK;
                imagePreview.image = nil;
            }
            
            [self callback];
        }
    }
}

- (void)postDone:(NSNotification *)center {

    //NSLog(@"postDone: %@", center.userInfo);
    
    NSString *result = [center.userInfo objectForKey:@"PostResult"];
    
    if ( [result isEqualToString:@"Success"] || [result isEqualToString:@"PhotoSuccess"] ) {
        
        //投稿成功
        NSString *successText = [center.userInfo objectForKey:@"SuccessText"];
        
        //再投稿リストから投稿成功したものを探し削除        
        int arrayIndex = 0;
        BOOL find = NO;
        for ( NSArray *temp in appDelegate.postError ) {
            
            if ( [successText hasPrefix:[temp objectAtIndex:2]] ) {
                
                find = YES;
                break;
            }
            
            arrayIndex++;
        }
        
        if ( find ) {
            
            [appDelegate.postError removeObjectAtIndex:arrayIndex];
        }
        
    }else if ( [result isEqualToString:@"Error"] || [result isEqualToString:@"PhotoError"]) {
        
        [ShowAlert error:@"投稿に失敗しました。失敗したPostは上部中央のボタンから再投稿出来ます。"];
    }
        
    //再投稿ボタンの有効･無効切り替え
    if ( appDelegate.postError.count == 0 ) {
        
        resendButton.enabled = NO;
        
    }else {
        
        resendButton.enabled = YES;
    }
}

- (NSString *)deleteWhiteSpace:(NSString *)string {
    
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"^[\\s]+" 
                                                                            options:0 
                                                                              error:nil];
    
    string = [regexp stringByReplacingMatchesInString:string
                                              options:0
                                                range:NSMakeRange(0, string.length)
                                         withTemplate:@""];
    
    regexp = [NSRegularExpression regularExpressionWithPattern:@"[\\s]+$" 
                                                       options:0 
                                                         error:nil];
    
    string = [regexp stringByReplacingMatchesInString:string
                                              options:0
                                                range:NSMakeRange(0, string.length)
                                         withTemplate:@""];
    
    return string;
}

- (IBAction)pushNowPlayingButton:(id)sender {
    
    //NSLog(@"pushNowPlayingButton");
    [self nowPlayingNotification];
}

- (IBAction)pushResendButton:(id)sender {
    
    //NSLog(@"pushResendButton");
    
    appDelegate.resendMode = [NSNumber numberWithInt:1];
    
    ResendViewController *dialog = [[[ResendViewController alloc] init] autorelease];
    dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:dialog animated:YES];
}

- (IBAction)pushTrashButton:(id)sender {
    
    //NSLog(@"Trash");
    
    postText.text = BLANK;
    imagePreview.image = nil;
    appDelegate.fastGoogleMode = [NSNumber numberWithInt:0];
    appDelegate.webPageShareMode = [NSNumber numberWithInt:0];
    [self countText];
}

- (IBAction)pushActionButton:(id)sender {
    
    actionSheetNo = 4;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"機能選択"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"半角カナ変換", @"ブラウザ", nil];
	[sheet autorelease];
	[sheet showInView:self.view];
}

- (IBAction)pushSettingButton:(id)sender {
    
    //NSLog(@"Setting");
    
    SettingViewController *dialog = [[[SettingViewController alloc] init] autorelease];
    dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:dialog animated:YES];
}

- (IBAction)pushIDButton:(id)sender {
    
    //NSLog(@"ID Change");
    
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
                            otherButtonTitles:@"Tweet", @"FastTweet", @"PhotoTweet", 
                                              @"NowPlaying", @"FastGoogle", @"FastPagePost", @"全て", nil];
	[sheet autorelease];
	[sheet showInView:self.view];
}

- (IBAction)pushImageSettingButton:(id)sender {
    
    //NSLog(@"pushImageSettingButton");
    
    //カメラか投稿時選択
    if ( [d integerForKey:@"ImageSource"] == 0 ||
         [d integerForKey:@"ImageSource"] == 2 ) {
        
        //連続投稿確認がON
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
        
        //連続投稿確認がOFF
        }else {
            
            repeatedPost = NO;
            [self showImagePicker];
        }
        
    //カメラ
    }else {
        
        repeatedPost = NO;
        [self showImagePicker];
    }
}

- (void)showImagePicker {
    
    UIImagePickerController *picPicker = [[UIImagePickerController alloc] init];
    
    if ( [d integerForKey:@"ImageSource"] == 0 ) {
        
        picPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
    }else if ( [d integerForKey:@"ImageSource"] == 1 ) {
        
        picPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
    }else if ( [d integerForKey:@"ImageSource"] == 2 && !repeatedPost ) {
    
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
        
    }else {
        
        picPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
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
        
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), nil);
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

- (void)savingImageIsFinished:(UIImage *)image
     didFinishSavingWithError:(NSError *)error
                  contextInfo:(void *)contextInfo {
    
    //NSLog(@"savingImageIsFinished");
    
    if( error ){
        
        errorImage = image;
        
        actionSheetNo = 3;
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"写真の保存に失敗しました。"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"再保存", @"破棄", nil];
        [sheet autorelease];
        [sheet showInView:self.view];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    //アップロードに成功した場合
    
    @try {
        
        //レスポンスのStringからDictionaryを生成
        NSDictionary *result = [request.responseString JSONValue];
        
        //NSLog(@"resultDic: %@", result);
        
        NSString *imageURL;
        
        //Dictionaryから画像URLを抜き出す
        if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"img.ur"] ) {
            
            imageURL = [[[result objectForKey:@"upload"] objectForKey:@"links"] objectForKey:@"original"];
            
        }else if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitpic"] ) {
            
            imageURL = [result objectForKey:@"url"];
        }
        
        //アップロードが成功しているかチェック
        if ( ![EmptyCheck check:imageURL] ) {
            
            [ShowAlert error:@"アップロードに失敗しました。"];
            
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
    
    //NSDictionary *result = [request.responseString JSONValue];
    //NSLog(@"resultDic: %@", result);
    
    [ShowAlert error:@"アップロードに失敗しました。"];
    
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
    [sv setContentOffset:CGPointMake(0, 70) animated:YES];
}

- (IBAction)svTapGesture:(id)sender {
    
    //NSLog(@"svTapGesture");
    
    [postText resignFirstResponder];
    [callbackTextField resignFirstResponder];
    [sv setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)swipeToMoveCursorRight:(id)sender {
    
    int location = postText.selectedRange.location + 1;
    
    if ( location <= postText.text.length ) {
        
        //NSLog(@"swipeToMoveCursorRight");
        [postText setSelectedRange:NSMakeRange( location, 0 ) ];   
    }
}

- (IBAction)swipeToMoveCursorLeft:(id)sender {
    
    if ( postText.selectedRange.location != 0 ) {
        
        //NSLog(@"swipeToMoveCursorLeft");
        int location = postText.selectedRange.location - 1;
        [postText setSelectedRange:NSMakeRange( location, 0 ) ];
    }
}

- (IBAction)callbackSwitchDidChage:(id)sender {
    
    //スイッチの状態を保存
    if ( callbackSwitch.on ) {
     
        [d setBool:YES forKey:@"CallBack"];
        
    }else {
        
        [d setBool:NO forKey:@"CallBack"];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( actionSheetNo == 0 ) {
        
        //通知センターにアプリを登録
        //通知センター登録時は通知を受け取っても無視するように設定
        
        UILocalNotification *localPush = [[UILocalNotification alloc] init];
        localPush.timeZone = [NSTimeZone defaultTimeZone];
        
        if ( buttonIndex == 0 ) {

            [d setBool:YES forKey:@"AddNotificationCenterTweet"];
            localPush.alertBody = @"Tweet";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"tweet", @"scheme", nil];
            
            //NSLog(@"Add NotificationCenter Tweet");
        
        }else if ( buttonIndex == 1 ) {
            
            [d setBool:YES forKey:@"AddNotificationCenterFastTweet"];
            localPush.alertBody = @"FastTweet";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"fast", @"scheme", nil];
            
            //NSLog(@"Add NotificationCenter FastTweet");
            
        }else if ( buttonIndex == 2 ) {
            
            [d setBool:YES forKey:@"AddNotificationCenterPhotoTweet"];
            localPush.alertBody = @"PhotoTweet";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"photo", @"scheme", nil];
            
            //NSLog(@"Add NotificationCenter PhotoTweet");
            
        }else if ( buttonIndex == 3 ) {
            
            [d setBool:YES forKey:@"AddNotificationCenterNowPlaying"];
            localPush.alertBody = @"NowPlaying";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"music", @"scheme", nil];
            
            //NSLog(@"Add NotificationCenter NowPlaying");
        
        }else if ( buttonIndex == 4 ) {
            
            [d setBool:YES forKey:@"AddNotificationCenterFastGoogle"];
            localPush.alertBody = @"FastGoogle";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"google", @"scheme", nil];
            
        }else if ( buttonIndex == 5 ) {
            
            [d setBool:YES forKey:@"AddNotificationCenterWebPageShare"];
            localPush.alertBody = @"WebPageShare";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"page", @"scheme", nil];
            
        }else if ( buttonIndex == 6 ) {
            
            [d setBool:YES forKey:@"AddNotificationCenterWebPageShare"];
            localPush.alertBody = @"WebPageShare";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"page", @"scheme", nil];
            localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
            
            [d setBool:YES forKey:@"AddNotificationCenterFastGoogle"];
            localPush.alertBody = @"FastGoogle";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"google", @"scheme", nil];
            localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
            
            [d setBool:YES forKey:@"AddNotificationCenterNowPlaying"];
            localPush.alertBody = @"NowPlaying";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"music", @"scheme", nil];
            localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
            
            [d setBool:YES forKey:@"AddNotificationCenterPhotoTweet"];
            localPush.alertBody = @"PhotoTweet";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"photo", @"scheme", nil];
            localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
            
            [d setBool:YES forKey:@"AddNotificationCenterFastTweet"];
            localPush.alertBody = @"FastTweet";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"fast", @"scheme", nil];
            localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
            [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
            
            [d setBool:YES forKey:@"AddNotificationCenterTweet"];
            localPush.alertBody = @"Tweet";
            localPush.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"tweet", @"scheme", nil];
            
            //NSLog(@"Add NotificationCenter All");
            
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
        
    }else if ( actionSheetNo == 3 ) {
    
        if ( buttonIndex == 0 ) {
            
//          NSLog(@"PhotoReSave");
            UIImageWriteToSavedPhotosAlbum(errorImage, self, @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), nil);

        }else {
            
//          NSLog(@"PhotoTrash");
            errorImage = nil;
        }
    }else if ( actionSheetNo == 4 ) {
        
        if ( buttonIndex == 0 ) {
            
            actionSheetNo = 5;
            
            UIActionSheet *sheet = [[UIActionSheet alloc]
                                    initWithTitle:@"半角カナ変換"
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:@"半角カナ変換(カタカナ)", @"半角カナ変換(ひらがな)", @"半角カナ変換(カタカナ+ひらがな)", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        }else if ( buttonIndex == 1 ) {
            
            [self startWebBrowsing];
        }
    
    }else if ( actionSheetNo == 5 ) {
        
        if ( buttonIndex == 0 ) {
            
            postText.text = [HankakuKana kana:postText.text];
            
        }else if ( buttonIndex == 1 ) {
            
            postText.text = [HankakuKana hiragana:postText.text];
            
        }else if ( buttonIndex == 2 ) {
            
            postText.text = [HankakuKana kanaHiragana:postText.text];
        }
    }
}

- (BOOL)ios5Check {
    
    BOOL result = NO;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
        
        //iOS5以前
        [ShowAlert error:@"Twitter APIはiOS5以降で使用できます。最新OSに更新してください。"];
        
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
        
        [ShowAlert error:@"インターネットに接続されていません。"];
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
        
        //NSLog(@"img.ur upload");
        
        [request addPostValue:IMGUR_API_KEY forKey:@"key"];
        [request addData:imageData forKey:@"image"];
        
    }else if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitpic"] ) {
        
        //NSLog(@"Twitpic upload");
        
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
            
            [ShowAlert error:[NSString stringWithFormat:@"%@のTwitpicアカウントが見つからなかったためimg.urに投稿しました。", twAccount.username]];
        }
    }
    
    [request setDelegate:self];
    [request start];
}

- (void)startWebBrowsing {
    
    webBrowserMode = YES;
    WebViewExController *dialog = [[[WebViewExController alloc] init] autorelease];
    dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:dialog animated:YES];
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
        
        //NSLog(@"Notification: YES");
        
        //通知判定を削除
        [d removeObjectForKey:@"Notification"];
        
        //iOS5以降かチェック
        if ( [self ios5Check] ) {
            
            //Twitterアカウントのチェック
            if ( twAccount == nil ) {
                
                [ShowAlert error:@"Twitterアカウントが見つかりませんでした。"];
                return;
            }
            
            if ( [[d objectForKey:@"NotificationType"] isEqualToString:@"music"] ) {
                
                //NSLog(@"NowPlaying Start");
                
                [self nowPlayingNotification];
                return;
            }
            
            //ペーストボードの内容をチェック
            int pBoardType = [PasteboardType check];
            
            if ( [[d objectForKey:@"NotificationType"] isEqualToString:@"tweet"] ) {
                
                //NSLog(@"Post Start");
                
                [self postNotification:pBoardType];
                
            }else if ( [[d objectForKey:@"NotificationType"] isEqualToString:@"fast"] ) {
                
                //NSLog(@"Fast Post Start");
                
                [self fastPostNotification:pBoardType];
                
            }else if ( [[d objectForKey:@"NotificationType"] isEqualToString:@"photo"] ) {
                
                //NSLog(@"Photo Start");
                
                [self photoPostNotification:pBoardType];
            
            }else if ( [[d objectForKey:@"NotificationType"] isEqualToString:@"google"] ) {
                
                NSLog(@"Google Start");
                
                if ( pBoardType == 0 ) {
                    
                    NSLog(@"pBoardType == 0");
                    
                    NSString *searchURL = @"http://www.google.co.jp/search?q=";
                    NSString *encodedSearchWord = [((NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
                                                                                                        (CFStringRef)pboard.string, 
                                                                                                        NULL, 
                                                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]", 
                                                                                                        kCFStringEncodingShiftJIS)) autorelease];
                    
                    appDelegate.openURL = [NSString stringWithFormat:@"%@%@", searchURL, encodedSearchWord];
                    
                }else {
                    
                    NSLog(@"pBoardType != 0");
                }
                
                if ( [appDelegate.isBrowserOpen intValue] == 0 ) {
                
                    NSLog(@"Open Browser");
                    
                    [self startWebBrowsing];
                    
                }else {
                    
                    NSLog(@"Opened Browser");
                }
                
            }else if ( [[d objectForKey:@"NotificationType"] isEqualToString:@"page"] ) {
                
                NSLog(@"WebPageShare Start");
                
                @autoreleasepool {
                 
                    [ActivityIndicator performSelectorInBackground:@selector(on) withObject:nil];
                }
                
                [self webPageShareNotification:pBoardType];
            }
        }
        
    }else {
        
        //NSLog(@"Notification: NO");
    }
    
    [self countText];
}

- (void)webPageShareNotification:(int)pBoardType {
    
    @try {
        
        NSString *pboardString = nil;
        NSError *error = nil;
        
        //URLを抽出する正規表現を設定
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"https?:([^\\x00-\\x20()\"<>\\x7F-\\xFF])*" 
                                                                                options:0 
                                                                                  error:&error];
		
		NSTextCheckingResult *matchResult = [regexp firstMatchInString:pboard.string 
                                                               options:0 
                                                                 range:NSMakeRange( 0, pboard.string.length )];
        if ( !error ) {
            
            if (matchResult.numberOfRanges != 0) {
                
                pboardString = [pboard.string substringWithRange:matchResult.range];
            }
            
        }else {
            
            [ShowAlert error:error.localizedDescription];
            return;
        }
        
        if ( pBoardType != 0 || pboardString == nil ) {
            
            [ShowAlert error:@"ペーストボード内にURLがありません。"];
            return;
        }
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:pboardString]];
        
        NSData *response = [NSURLConnection sendSynchronousRequest:request 
                                                 returningResponse:nil 
                                                             error:&error];
        
        int encodingList[] = {
            
            NSUTF8StringEncoding,			// UTF-8
            NSShiftJISStringEncoding,		// Shift_JIS
            NSJapaneseEUCStringEncoding,	// EUC-JP
            NSISO2022JPStringEncoding,		// JIS
            NSUnicodeStringEncoding,		// Unicode
            NSASCIIStringEncoding			// ASCII
        };
        
        NSString *dataStr = nil;
        int max = sizeof( encodingList ) / sizeof( encodingList[0] );
        
        for ( int i = 0; i < max; i++ ) {
            
            NSLog(@"encoding: %d", encodingList[i]);
            
            dataStr = [[[NSString alloc] initWithData:response encoding:encodingList[i]] autorelease];
            
            if ( dataStr != nil ) {
                
                break;
            }
        }
        
        NSLog(@"dataStr.length: %d", dataStr.length);
        
        if ( error ) {
            
            [ShowAlert error:error.localizedDescription];
            return;
        }
        
        if ( ![EmptyCheck check:dataStr] ) {
            
            [ShowAlert error:@"正常にデータが取得できませんでした。"];
            return;
        }
        
        NSMutableString *title = [RegularExpression mStrRegExp:dataStr regExpPattern:@"<title>.+</title>"];
        title = [ReplaceOrDelete deleteWordReturnMStr:title deleteWord:@"<title>"];
        title = [ReplaceOrDelete deleteWordReturnMStr:title deleteWord:@"</title>"];
        
        if ( ![EmptyCheck check:title] ) {
            
            title = (NSMutableString *)[pboardString lastPathComponent];
            
            if ( ![EmptyCheck check:title] ) {
            
                [ShowAlert error:@"正常にタイトルが取得できませんでした。"];
                return;
            }
        }
        
        NSString *shareString = [NSString stringWithFormat:@"\"%@\" %@", title, pboardString];
        
        postText.text = [NSString stringWithFormat:@"%@ ", [self deleteWhiteSpace:[NSString stringWithFormat:@"%@ %@", postText.text, shareString]]];
        [postText becomeFirstResponder];
        
    }@catch ( NSException *e ) {
        
        [ShowAlert error:[NSString stringWithFormat:@"原因不明なエラーが発生しました。\n%@", e]];
        
    }@finally {
        
        [ActivityIndicator visible:NO];
    }
}

- (void)nowPlayingNotification {
 
    NSString *nowPlayingText = [self nowPlaying];
    int length = nowPlayingText.length;
    
    //投稿可能文字数(1-140)
    if ( length > 0 ) {
        
        //NSLog(@"SongTitleOK");
        
        //FastPostが有効、またはNowPlaying限定CallBackが有効
        if ( [d boolForKey:@"NowPlayingFastPost"] ) {
            
            @autoreleasepool {
             
                NSArray *postData = [NSArray arrayWithObjects:[self deleteWhiteSpace:nowPlayingText], nil];
                [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
            }
            
            //CallBack、またはNowPlaying限定CallBackが有効
            if ( [d boolForKey:@"CallBack"] || [d boolForKey:@"NowPlayingCallBack"] ) {
                
                //NSLog(@"Callback Enable");
                
                //CallBack
                [self callback];
            }
            
        }else {
            
            postText.text = nowPlayingText;
            [postText becomeFirstResponder];
            [postText setSelectedRange:NSMakeRange(0, 0)];
        }
        
    }else if ( length == 0 ) {
        
        //NSLog(@"SongTitleBlank");
        
        //再生中でなかった場合
        [ShowAlert error:@"iPod再生中に使用してください。"];
        
    //140字を超えていた場合
    }else {
        
        //NSLog(@"SongTitleOverCapacity");
        
        [ShowAlert error:@"文章が140字を超えています。"];
        
        //入力欄に貼り付け
        postText.text = nowPlayingText;
        [postText becomeFirstResponder];
        [postText setSelectedRange:NSMakeRange(0, 0)];
    }
}

- (void)postNotification:(int)pBoardType {
    
    if ( pBoardType == 0 ) {
        
        //NSLog(@"pBoardType Text");
        
        //ペーストボード内容をPost入力欄にコピー
        postText.text = pboard.string;
        
    }else {
        
        //NSLog(@"pBoardType not text");
    }
    
    //Post入力状態にする
    [postText becomeFirstResponder];
}

- (void)fastPostNotification:(int)pBoardType {
    
    BOOL canPost = NO;
    
    //ペーストボード内がテキスト
    if ( pBoardType == 0 ) {
        
        //t.coを考慮した文字数カウントを行う
        int num = [TWTwitterCharCounter charCounter:pboard.string];
        
        if ( num < 0 ) {
            
            //140字を超えていた場合
            [ShowAlert error:@"文章が140字を超えています。"];
            
        }else {
            
            //投稿可能文字数である
            canPost = YES;
        }
        
        if ( canPost ) {
            
            @autoreleasepool {
            
                //投稿処理
                NSString *text = [[[NSString alloc] initWithString:pboard.string] autorelease];
                NSArray *postData = [NSArray arrayWithObjects:[self deleteWhiteSpace:text], nil];
                [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
            }
            
            //コールバックが有効な場合
            if ( [d boolForKey:@"CallBack"] ) {
                
                //NSLog(@"Callback Enable");
                
                //CallBack
                [self callback];
            }
            
        //投稿不可能な場合
        }else {
            
            //ペーストボード内容をPost入力欄にコピー
            postText.text = pboard.string;
            [postText becomeFirstResponder];
        }
        
    }else {
        
        [postText becomeFirstResponder];
    }
}

- (void)photoPostNotification:(int)pBoardType {
    
    if ( pBoardType == 1 ) {
        
        //NSLog(@"pBoardType Photo");
        
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
        
        //NSLog(@"pBoardType not Photo");
        
        [self pushImageSettingButton:nil];
    }
}

- (void)callback {
    
    //NSLog(@"Callback Start");
    
    if ( ![d boolForKey:@"CallBack"] ) {
        
        return;
    }
    
    BOOL canOpen = NO;
    
    //CallbackSchemeが空でない
    if ( [EmptyCheck check:[d objectForKey:@"CallBackScheme"]] ) {
        
        //CallbackSchemeがアクセス可能な物がテスト
        canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[d objectForKey:@"CallBackScheme"]]];
        
        //コールバックスキームが開けない
        if ( !canOpen ) {
            
            //NSLog(@"Can't callBack");
            
            [ShowAlert error:@"コールバックスキームが有効でありません。"];
            
        //コールバックスキームを開くことが出来る
        }else {
            
            //NSLog(@"CallBack");
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[d objectForKey:@"CallBackScheme"]]];
        }
    }
}

- (NSString *)nowPlaying {
    
    //NSLog(@"nowPlaying");
    
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
            
            //NSLog(@"template");
            
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
            
            //NSLog(@"default");
            
            //デフォルトの書式を適用
            resultText = [NSMutableString stringWithFormat:@" #nowplaying %@ - %@ ", songTitle, songArtist];
        }
        
    }@catch (NSException *e) {
        
        //NSLog(@"Exception: %@", e);
    }
    
    return (NSString *)resultText;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    //NSLog(@"viewDidAppear");
    
    if ( webBrowserMode && [EmptyCheck check:appDelegate.postText] ) {
        
        webBrowserMode = NO;
        appDelegate.fastGoogleMode = [NSNumber numberWithInt:0];
        postText.text = [NSString stringWithFormat:@"%@ ", [self deleteWhiteSpace:[NSString stringWithFormat:@"%@ %@", postText.text, appDelegate.postText]]];
        [postText becomeFirstResponder];
        
        appDelegate.postText = BLANK;
        
        return;
        
    }else if ( webBrowserMode ) {
        
        webBrowserMode = NO;
        
        return;
    }
    
    if ( changeAccount || [d boolForKey:@"ChangeAccount"] ) {
        
        //NSLog(@"ChangeAccount");
        
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
            
            //NSLog(@"Resend data set TEXT");
            
        }else {
            
            //NSLog(@"Resend data set PHOTO");
            imagePreview.image = [resendArray objectAtIndex:3];
        }
        
        [appDelegate.postError removeObjectAtIndex:indexNum];
    }
    
    //再投稿ボタンの有効･無効切り替え
    if ( appDelegate.postError.count == 0 ) {
        
        resendButton.enabled = NO;
        
    }else {
        
        resendButton.enabled = YES;
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    
    [self setPostText:nil];
    [self setCallbackLabel:nil];
    [self setCallbackTextField:nil];
    [self setCallbackSwitch:nil];
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
    [self setRigthSwipe:nil];
    [self setLeftSwipe:nil];
    [self setNowPlayingButton:nil];
    [self setActionButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
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
    [rigthSwipe release];
    [leftSwipe release];
    [nowPlayingButton release];
    [actionButton release];
    [super dealloc];
}

@end