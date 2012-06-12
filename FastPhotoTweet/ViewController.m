//
//  ViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "ViewController.h"

#define APP_VERSION @"1.4.1a"

#define TOP_BAR [NSArray arrayWithObjects:trashButton, flexibleSpace, idButton, flexibleSpace, resendButton, flexibleSpace, imageSettingButton, flexibleSpace, postButton, nil]
#define BOTTOM_BAR [NSArray arrayWithObjects:settingButton, flexibleSpace, browserButton, flexibleSpace, nowPlayingButton, flexibleSpace, actionButton, nil]

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
@synthesize callbackSwitch;
@synthesize imagePreview;
@synthesize topBar;
@synthesize trashButton;
@synthesize postButton;
@synthesize flexibleSpace;
@synthesize tapGesture;
@synthesize rigthSwipe;
@synthesize leftSwipe;
@synthesize inputFunctionButton;
@synthesize callbackSelectButton;
@synthesize browserButton;
@synthesize actionButton;
@synthesize nowPlayingButton;
@synthesize idButton;
@synthesize bottomBar;
@synthesize settingButton;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //NSLog(@"viewDidLoad");
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
    UILocalNotification *localPush = [[[UILocalNotification alloc] init] autorelease];
    localPush.timeZone = [NSTimeZone defaultTimeZone];
    localPush.alertBody = @"Action";
    localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
    
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
    
    //イメージプレビュータップ時のジェスチャーを設定
    imagePreview.gestureRecognizers = nil;
    UITapGestureRecognizer *imagePreviewTapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self 
                                                                                             action:@selector(imagePreviewTapGesture:)] autorelease];
	[imagePreview addGestureRecognizer:imagePreviewTapGesture];
    
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
    artWorkUploading = NO;
    showActionSheet = NO;
    nowPlayingMode = NO;
    iconUploadMode = NO;
    actionSheetNo = 0;
    
    postText.layer.borderWidth = 2;
	postText.layer.borderColor = [[UIColor blackColor] CGColor];
    
    [d removeObjectForKey:@"applicationWillResignActive"];
    
    //処理中を表すビューを生成
    grayView = [[GrayView alloc] init];
    [sv addSubview:grayView];
    
    //ツールバーにボタンをセット
    [topBar setItems:TOP_BAR animated:NO];
    [bottomBar setItems:BOTTOM_BAR animated:NO];
    
    //保存されている情報をロード
    [self loadSettings];
    [self setCallbackButtonTitle];
    
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
                         
                         //[ShowAlert title:@"Success" message:[NSString stringWithFormat:@"Account Name: %@", twAccount.username]];
                         
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
    //[self testMethod];
}

//- (void)testMethod {
//
//}

- (void)loadSettings {
    
    if ( ![EmptyCheck check:[d objectForKey:@"UUID"]] ) {
        
        //UUIDを生成して保存
        CFUUIDRef uuidObj = CFUUIDCreate(kCFAllocatorDefault);
        NSString *uuidString = (NSString *)CFUUIDCreateString(nil, uuidObj);
        CFRelease(uuidObj);
        
        [d setObject:uuidString forKey:@"UUID"];
        
        //NSLog(@"Create UUID: %@", uuidString);
        
        [uuidString release];
        
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

- (void)setCallbackButtonTitle {
    
    NSString *scheme = [d objectForKey:@"CallBackScheme"];
    
    if ( [scheme isEqualToString:@"twitter://"] ) {
        
        [callbackSelectButton setTitle:@"Twitter for iPhone" forState:UIControlStateNormal];
        
    }else if ( [scheme isEqualToString:@"tweetbot://"] ) {
        
        [callbackSelectButton setTitle:@"Tweetbot" forState:UIControlStateNormal];
        
    }else if ( [scheme isEqualToString:@"echofon://?"] ) {
        
        [callbackSelectButton setTitle:@"Echofon" forState:UIControlStateNormal];
        
    }else if ( [scheme isEqualToString:@"echofonpro://?"] ) {
        
        [callbackSelectButton setTitle:@"Echofon Pro" forState:UIControlStateNormal];
        
    }else if ( [scheme isEqualToString:@"soicha://"] ) {
        
        [callbackSelectButton setTitle:@"SOICHA" forState:UIControlStateNormal];
        
    }else if ( [scheme isEqualToString:@"tweetings://"] ) {
        
        [callbackSelectButton setTitle:@"Tweetings" forState:UIControlStateNormal];
        
    }else if ( [scheme isEqualToString:@"osfoora://"] ) {
        
        [callbackSelectButton setTitle:@"Osfoora" forState:UIControlStateNormal];
        
    }else if ( [scheme isEqualToString:@"twittelator://"] ) {
        
        [callbackSelectButton setTitle:@"Twittelator" forState:UIControlStateNormal];
        
    }else if ( [scheme isEqualToString:@"tweetlist://"] ) {
        
        [callbackSelectButton setTitle:@"TweetList!" forState:UIControlStateNormal];
        
    }else if ( [scheme isEqualToString:@"tweetatok://"] ) {
        
        [callbackSelectButton setTitle:@"Tweet ATOK" forState:UIControlStateNormal];
        
    }else if ( [scheme isEqualToString:@"tweetlogix://"] ) {
        
        [callbackSelectButton setTitle:@"Tweetlogix" forState:UIControlStateNormal];
        
    }else if ( [scheme isEqualToString:@"hootsuite://"] ) {
        
        [callbackSelectButton setTitle:@"HootSuite" forState:UIControlStateNormal];
        
    }else if ( [scheme isEqualToString:@"simplytweet://"] ) {
        
        [callbackSelectButton setTitle:@"SimplyTweet" forState:UIControlStateNormal];
        
    }else if ( [scheme isEqualToString:@"reeder://"] ) {
        
        [callbackSelectButton setTitle:@"Reeder" forState:UIControlStateNormal];
        
    }else {
        
        [callbackSelectButton setTitle:@"未選択" forState:UIControlStateNormal];
    }
}

- (void)showInfomation {
    
    //NSLog(@"showInfomation");
    
    BOOL check = YES;
    NSMutableDictionary *information;
    
    if ( ![EmptyCheck check:[d dictionaryForKey:@"Information"]] ) {
        
        //NSLog(@"init Information");
        [d setObject:[NSDictionary dictionary] forKey:@"Information"];
    }
    
    while ( check ) {
                
        if ( [[d dictionaryForKey:@"Information"] valueForKey:@"FirstRun"] == 0 ) {
            
            //NSLog(@"FirstRun");
            
            [ShowAlert title:@"ようこそ" 
                message:@"FastPhotoTweetへようこそ\n通知センターから様々なTweetを素早くTwitterに投稿する事が出来ます。始めに画面右下から通知センターへの登録を行なってください。"];
            
            information = [[[NSMutableDictionary alloc] initWithDictionary:[d dictionaryForKey:@"Information"]] autorelease];
            [information setValue:[NSNumber numberWithInt:1] forKey:@"FirstRun"];
            
            NSDictionary *dic = [[[NSDictionary alloc] initWithDictionary:information] autorelease];
            [d setObject:dic forKey:@"Information"];
            
            continue;
        }
        
        if ( [[d dictionaryForKey:@"Information"] valueForKey:APP_VERSION] == 0 ) {
            
            //NSLog(@"newVersion");
            
//            [ShowAlert title:[NSString stringWithFormat:@"FastPhotoTweet %@", APP_VERSION] 
//                 message:@"・ブラウザの画面回転時の問題を修正\n・Amazonアフィリエイトリンク削除の処理改善"];
            
            information = [[[NSMutableDictionary alloc] initWithDictionary:[d dictionaryForKey:@"Information"]] autorelease];
            [information setValue:[NSNumber numberWithInt:1] forKey:APP_VERSION];
            
            NSDictionary *dic = [[[NSDictionary alloc] initWithDictionary:information] autorelease];
            [d setObject:dic forKey:@"Information"];
            
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
            
            NSString *text = [[[NSString alloc] initWithString:postText.text] autorelease];
            
            if ( ![EmptyCheck check:text] ) {
                
                [ShowAlert error:@"文字が入力されていません。"];
                return;
            }
            
            //画像が設定されていない場合
            if ( imagePreview.image == nil ) {
                
                @autoreleasepool {
                    
                    //文字列をバックグラウンドプロセスで投稿
                    NSArray *postData = [NSArray arrayWithObjects:[DeleteWhiteSpace string:text], nil];
                    [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
                }
                
                //入力欄を空にする
                postText.text = BLANK;
             
            //画像が設定されている場合
            }else {
                
                //画像投稿先がTwitterの場合
                if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitter"] || 
                     [d integerForKey:@"NowPlayingPhotoService"] == 1 ) {
                    
                    @autoreleasepool {
                        
                        //文字列と画像をバックグラウンドプロセスで投稿
                        NSArray *postData = [NSArray arrayWithObjects:[DeleteWhiteSpace string:text], imagePreview.image, nil];
                        [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
                    }
                    
                //画像投稿先がimg.urかTwitpicもしくは画像の再投稿
                }else {
                    
                    @autoreleasepool {
                        
                        //文字列をバックグラウンドプロセスで投稿
                        NSArray *postData = [NSArray arrayWithObjects:[DeleteWhiteSpace string:text], nil];
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
    
    nowPlayingMode = NO;
    postText.text = BLANK;
    imagePreview.image = nil;
    appDelegate.fastGoogleMode = [NSNumber numberWithInt:0];
    appDelegate.webPageShareMode = [NSNumber numberWithInt:0];
    [self countText];
}

- (IBAction)pushBrowserButton:(id)sender {
    
    webBrowserMode = YES;
    
    WebViewExController *dialog = [[[WebViewExController alloc] init] autorelease];
    dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:dialog animated:YES];
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

- (IBAction)pushCallbackSelectButton:(id)sender {
    
    actionSheetNo = 8;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"アプリ選択"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Twitter for iPhone", @"Tweetbot", @"Echofon", 
                                              @"Echofon Pro", @"SOICHA", @"Tweetings", 
                                              @"Osfoora", @"Twittelator", @"TweetList!", 
                                              @"Tweet ATOK", @"Tweetlogix",  @"HootSuite", 
                                              @"SimplyTweet", @"Reeder", nil];
	[sheet autorelease];
	[sheet showInView:self.view];
}

- (void)showActionMenu {
    
    showActionSheet = YES;
    
    actionSheetNo = 0;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"動作選択"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Tweet", @"FastTweet", @"PhotoTweet", 
                                              @"NowPlaying", @"FastGoogle", @"Browser",
                                              @"FastPagePost", nil];
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

- (IBAction)pushActionButton:(id)sender {
    
    actionSheetNo = 9;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"機能選択"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"アイコン変更", nil];
    [sheet autorelease];
    [sheet showInView:self.view];
}

- (void)showImagePicker {
    
    UIImagePickerController *picPicker = [[[UIImagePickerController alloc] init] autorelease];
    
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
        
        return;
        
    }else {
        
        picPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    picPicker.delegate = self;
    [self presentModalViewController:picPicker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picPicker
        didFinishPickingImage:(UIImage *)image 
                  editingInfo:(NSDictionary *)editingInfo {

    if ( iconUploadMode ) {
        
        iconUploadMode = NO;
        
        image = [ResizeImage aspectResizeSetMaxSize:image maxSize:256];
        [TWIconUpload image:image];
        
        [picPicker dismissModalViewControllerAnimated:YES];
        
        return;
    }
    
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
    iconUploadMode = NO;
    [picPicker dismissModalViewControllerAnimated:YES];
}

- (void)savingImageIsFinished:(UIImage *)image
     didFinishSavingWithError:(NSError *)error
                  contextInfo:(void *)contextInfo {
    
    //NSLog(@"savingImageIsFinished");
    
    if( error ) {
        
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
    
    //NSLog(@"requestFinished");
    
    @try {
        
        //レスポンスのStringからDictionaryを生成
        NSDictionary *result = [request.responseString JSONValue];
        
        //NSLog(@"resultDic: %@", result);
        
        NSString *imageURL = nil;
        
        //Dictionaryから画像URLを抜き出す
        int service = 0;
        
        if ( nowPlayingMode ) {
            
            if ( [d integerForKey:@"NowPlayingPhotoService"] == 2 ) {
                
                service = 1;
                
            }else if ( [d integerForKey:@"NowPlayingPhotoService"] == 3 ) {
                
                service = 2;
            }
            
            nowPlayingMode = NO;
            
        }else {
            
            if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"img.ur"] ) {
                
                service = 1;
                
            }else if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitpic"] ) {
                
                service = 2;
            }
        }
        
        if ( service == 1 ) {
            
            imageURL = [[[result objectForKey:@"upload"] objectForKey:@"links"] objectForKey:@"original"];
            
        }else if ( service == 2 ) {
            
            imageURL = [result objectForKey:@"url"];
        }
        
        //アップロードが成功しているかチェック
        if ( ![EmptyCheck check:imageURL] ) {
            
            //失敗
            [self requestFailed:nil];
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
        
        //カーソルを先頭にする
        [postText becomeFirstResponder];
        [postText setSelectedRange:NSMakeRange(0, 0)];
        
        //処理中表示をオフ
        [grayView off];
        
    }@catch ( NSException *e ) {
        
        [ShowAlert error:@"アップロード開始処理中に原因不明なエラーが発生しました。"];
        
        //処理中表示をオフ
        [grayView off];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    //アップロードに失敗した場合
    
    //NSDictionary *result = [request.responseString JSONValue];
    //NSLog(@"resultDic: %@", result);
    
    //処理中表示をオフ
    [grayView off];
    
    actionSheetNo = 6;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"アップロードに失敗しました。\n現在プレビューされている画像が再投稿されます。"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"再投稿", @"破棄", nil];
    [sheet autorelease];
    [sheet showInView:self.view];
}

- (IBAction)svTapGesture:(id)sender {
    
    //NSLog(@"svTapGesture");
    
    [postText resignFirstResponder];
    [sv setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)imagePreviewTapGesture:(UITapGestureRecognizer *)sender {
    
    //NSLog(@"imagePreviewTapGesture");
    
    [postText resignFirstResponder];
    [sv setContentOffset:CGPointMake(0, 0) animated:YES];
    
    if ( imagePreview.image != nil ) {
        
        actionSheetNo = 7;
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"機能選択"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"画像をアップロード", @"画像を破棄", @"画像を再選択", nil];
        [sheet autorelease];
        [sheet showInView:self.view];
    }
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

- (IBAction)pushInputFunctionButton:(id)sender {
    
    actionSheetNo = 5;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"入力支援機能"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"半角カナ変換(カタカナ)", @"半角カナ変換(ひらがな)", @"半角カナ変換(カタカナ+ひらがな)", 
                                              @"ペーストボードへコピー", @"ペーストボードからコピー", 
                                              @"現在位置から右を削除", @"現在位置から左を削除", nil];
    [sheet autorelease];
    [sheet showInView:self.view];
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
        
        showActionSheet = NO;
        
        //ペーストボードの内容をチェック
        int pBoardType = [PasteboardType check];
        
        //NSLog(@"pBoardType: %d", pBoardType);
        
        if ( buttonIndex == 0 ) {

            [self postNotification:pBoardType];
        
        }else if ( buttonIndex == 1 ) {
            
            [self fastPostNotification:pBoardType];
            
        }else if ( buttonIndex == 2 ) {
            
            [self photoPostNotification:pBoardType];
            
        }else if ( buttonIndex == 3 ) {
            
            [self nowPlayingNotification];
            
        }else if ( buttonIndex == 4 ) {
            
            if ( pBoardType == 0 ) {
                
                NSString *searchURL = @"http://www.google.co.jp/search?q=";
                NSString *encodedSearchWord = [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                   (CFStringRef)pboard.string,
                                                                                                   NULL,
                                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                   kCFStringEncodingShiftJIS) autorelease];
                
                appDelegate.openURL = [NSString stringWithFormat:@"%@%@", searchURL, encodedSearchWord];
                
                appDelegate.fastGoogleMode = [NSNumber numberWithInt:1];
                
                [self pushBrowserButton:nil];
            }
            
            if ( [appDelegate.isBrowserOpen intValue] == 0 ) {
                
                //NSLog(@"Open Browser");
                
                [self pushBrowserButton:nil];
            }
        
        }else if ( buttonIndex == 5 ) {

            if ( [appDelegate.isBrowserOpen intValue] == 0 ) {
                
                //NSLog(@"Open Browser");
                
                [self pushBrowserButton:nil];
            }
            
        }else if ( buttonIndex == 6 ) {
            
            @autoreleasepool {
                
                [ActivityIndicator performSelectorInBackground:@selector(on) withObject:nil];
            }
            
            [self webPageShareNotification:pBoardType];
        }
        
    }else if ( actionSheetNo == 1 ) {
        
        //イメージピッカーを表示
        UIImagePickerController *picPicker = [[[UIImagePickerController alloc] init] autorelease];
        
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
            return;
        }
        
        picPicker.delegate = self;
        [self presentModalViewController:picPicker animated:YES];
        
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
            
            UIImageWriteToSavedPhotosAlbum(errorImage, self, @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), nil);

        }else {
            
            errorImage = nil;
        }
        
    }else if ( actionSheetNo == 5 ) {
        
        if ( buttonIndex == 0 ) {
            
            postText.text = [HankakuKana kana:postText.text];
            
        }else if ( buttonIndex == 1 ) {
            
            postText.text = [HankakuKana hiragana:postText.text];
            
        }else if ( buttonIndex == 2 ) {
            
            postText.text = [HankakuKana kanaHiragana:postText.text];
        
        }else if ( buttonIndex == 3 ) {
            
            [pboard setString:postText.text];
            
        }else if ( buttonIndex == 4 ) {
            
            postText.text = [NSString stringWithFormat:@"%@%@", postText.text, pboard.string];
        
        }else if ( buttonIndex == 5 ) {
            
            if ( ![postText.text isEqualToString:@""] ) {
                
                postText.text = [NSString stringWithString:[postText.text substringWithRange:NSMakeRange( 0, postText.selectedRange.location )]];
                [postText setSelectedRange:NSMakeRange( postText.text.length, 0 )];
            }
            
        }else if ( buttonIndex == 6 ) {
        
            if ( ![postText.text isEqualToString:@""] ) {
                
                postText.text = [NSString stringWithString:[postText.text substringWithRange:NSMakeRange( postText.selectedRange.location, postText.text.length - ( postText.selectedRange.location ))]];
                [postText setSelectedRange:NSMakeRange( 0, 0 )];
            }
        }
    
    }else if ( actionSheetNo == 6 ) {
        
        if ( buttonIndex == 0 ) {
            
            [self uploadImage:imagePreview.image];
        }
    
    }else if ( actionSheetNo == 7 ) {
    
        if ( buttonIndex == 0 ) {
            
            if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitter"] ) {
                
                [ShowAlert error:@"Twitterへのアップロードは本文の投稿と同時に行われます。"];
                
            }else {
                
                [self uploadImage:imagePreview.image];
            }

        }else if ( buttonIndex == 1 ) {
            
            imagePreview.image = nil;
            [self countText];
            
        }else if ( buttonIndex == 2 ) {
            
            [self pushImageSettingButton:nil];
        }
        
    }else if ( actionSheetNo == 8 ) {
        
        if ( buttonIndex == 0 ) {
            [d setObject:@"twitter://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 1 ) {
            [d setObject:@"tweetbot://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 2 ) {
            [d setObject:@"echofon://?" forKey:@"CallBackScheme"];        
        }else if ( buttonIndex == 3 ) {
            [d setObject:@"echofonpro://?" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 4 ) {
            [d setObject:@"soicha://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 5 ) {
            [d setObject:@"tweetings://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 6 ) {
            [d setObject:@"osfoora://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 7 ) {
            [d setObject:@"twittelator://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 8 ) {
            [d setObject:@"tweetlist://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 9 ) {
            [d setObject:@"tweetatok://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 10 ) {
            [d setObject:@"tweetlogix://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 11 ) {
            [d setObject:@"hootsuite://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 12 ) {
            [d setObject:@"simplytweet://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 13 ) {
            [d setObject:@"reeder://" forKey:@"CallBackScheme"];
        }
        
        [self setCallbackButtonTitle];
    
    }else if ( actionSheetNo == 9 ) {
        
        if ( buttonIndex == 0 ) {
            
            iconUploadMode = YES;
            
            UIImagePickerController *picPicker = [[[UIImagePickerController alloc] init] autorelease];
            picPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picPicker.delegate = self;
            [self presentModalViewController:picPicker animated:YES];
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
    NSURL *URL = nil;
    
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

- (void)uploadNowPlayingImage:(UIImage *)image uploadType:(int)uploadType {
    
    //NSLog(@"uploadType: %d", uploadType);
    
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
    NSURL *URL = nil;
    
    if ( uploadType == 2 ) {
        
        URL = [NSURL URLWithString:@"http://api.imgur.com/2/upload.json"];
        
    }else if ( uploadType == 3 ) {
        
        URL = [NSURL URLWithString:@"http://api.twitpic.com/1/upload.json"];
    }
    
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:URL] autorelease];
    
    if ( uploadType == 2 ) {
        
        //NSLog(@"img.ur upload");
        
        [request addPostValue:IMGUR_API_KEY forKey:@"key"];
        [request addData:imageData forKey:@"image"];
        
    }else if ( uploadType == 3 ) {
        
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

- (void)becomeActive:(NSNotification *)notification {
    
    //アプリケーションがアクティブになった際に呼ばれる
    //NSLog(@"becomeActive");
    
    if ( [d boolForKey:@"applicationWillResignActive"] ) {
        
        [d removeObjectForKey:@"applicationWillResignActive"];
        return;
    }
    
    //設定が有効な場合Post入力可能状態にする
    if ( [d boolForKey:@"ShowKeyboard"] ) {
        
        [postText becomeFirstResponder];
    }
    
    //iOS5以降かチェック
    if ( [self ios5Check] ) {
                
        if ( !showActionSheet ) {
            
            if ( [appDelegate.launchMode intValue] == 2 ) {
                
                [self showActionMenu];
                
            }else {
                
                if ( [appDelegate.launchMode intValue] == 1 ) {
                    
                    [self showActionMenu];
                }
            }
        }
        
        appDelegate.launchMode = [NSNumber numberWithInt:2];
    }
    
    [self countText];
}

- (void)webPageShareNotification:(int)pBoardType {
    
    @try {
        
        NSString *pboardString = nil;
        NSError *error = nil;
        
        NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink 
                                                                       error:&error];
        
        NSArray *matches = [linkDetector matchesInString:pboard.string 
                                                 options:0 
                                                   range:NSMakeRange(0, [pboard.string  length])];
        
        if ( !error ) {
            
            if ( [EmptyCheck check:matches] ) {
                
                NSTextCheckingResult *match = [matches objectAtIndex:0];
                pboardString = [pboard.string substringWithRange:match.range];
            }
            
        }else {
            
            [ShowAlert error:[NSString stringWithFormat:@"CODE: 01\n%@", error.localizedDescription]];
            return;
        }
        
        if ( pBoardType != 0 || pboardString == nil ) {
            
            [ShowAlert error:@"CODE: 02\nペーストボード内にURLがありません。"];
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
            
            //NSLog(@"encoding: %d", encodingList[i]);
            
            dataStr = [[[NSString alloc] initWithData:response encoding:encodingList[i]] autorelease];
            
            if ( dataStr != nil ) {
                
                break;
            }
        }
        
        //NSLog(@"dataStr.length: %d", dataStr.length);
        
        if ( error ) {
            
            [ShowAlert error:[NSString stringWithFormat:@"CODE: 03\n%@", error.localizedDescription]];
            return;
        }
        
        NSMutableString *title = [RegularExpression mStrRegExp:dataStr regExpPattern:@"<title>.+</title>"];
        title = [ReplaceOrDelete deleteWordReturnMStr:title deleteWord:@"<title>"];
        title = [ReplaceOrDelete deleteWordReturnMStr:title deleteWord:@"</title>"];
        
        if ( ![EmptyCheck check:title] ) {
            
            title = (NSMutableString *)[pboardString lastPathComponent];
            
            if ( ![EmptyCheck check:title] ) {
            
                [ShowAlert error:@"CODE: 04\n正常にタイトルが取得できませんでした。"];
                return;
            }
        }
        
        NSString *shareString = [NSString stringWithFormat:@"\"%@\" %@", title, pboardString];
        
        postText.text = [NSString stringWithFormat:@"%@ ", [DeleteWhiteSpace string:[NSString stringWithFormat:@"%@ %@", postText.text, shareString]]];
        [postText becomeFirstResponder];
        
    }@catch ( NSException *e ) {
        
        [ShowAlert error:[NSString stringWithFormat:@"CODE: 00\n原因不明なエラーが発生しました。\n%@", e]];
        
    }@finally {
        
        [ActivityIndicator visible:NO];
    }
}

- (void)nowPlayingNotification {
 
    nowPlayingMode = YES;
    
    NSString *nowPlayingText = [self nowPlaying];
    int length = nowPlayingText.length;
    
    //投稿可能文字数(1-140)
    if ( length > 0 ) {
        
        //NSLog(@"SongTitleOK");
        
        //FastPostが有効、またはNowPlaying限定CallBackが有効
        if ( [d boolForKey:@"NowPlayingFastPost"] && !artWorkUploading ) {
            
            @autoreleasepool {
            
                if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitter"] ) {
                
                    if ( imagePreview.image != nil ) {
                        
                        NSArray *postData = [NSArray arrayWithObjects:[DeleteWhiteSpace string:nowPlayingText], imagePreview.image, nil];
                        [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
                        
                    }else {
                        
                        NSArray *postData = [NSArray arrayWithObjects:[DeleteWhiteSpace string:nowPlayingText], nil];
                        [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
                    }
                    
                }else {
                    
                    NSArray *postData = [NSArray arrayWithObjects:[DeleteWhiteSpace string:nowPlayingText], nil];
                    [TWSendTweet performSelectorInBackground:@selector(post:) withObject:postData];
                }
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
                NSArray *postData = [NSArray arrayWithObjects:[DeleteWhiteSpace string:text], nil];
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
        
        if ( [d boolForKey:@"NowPlayingArtWork"] ) {
            
            MPMediaItemArtwork *artwork = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork];
            
            int h = (int)artwork.bounds.size.height;
            int w = (int)artwork.bounds.size.width;
            
            if ( h != 0 && w != 0 ) {
                
                imagePreview.image = [ResizeImage aspectResizeSetMaxSize:[artwork imageWithSize:CGSizeMake(500, 500)] 
                                                                 maxSize:500];
                                
                int uploadType = [d integerForKey:@"NowPlayingPhotoService"];
                
                if ( uploadType == 0 ) {
                    
                    if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"img.ur"] ) {
                        
                        uploadType = 2;
                        
                    }else if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitpic"] ) {    
                        
                        uploadType = 3;
                    }
                }
                
                if ( uploadType != 0 && uploadType != 1 ) {
                 
                    artWorkUploading = YES;
                    
                    [self uploadNowPlayingImage:imagePreview.image 
                                     uploadType:uploadType];
                }
            }
        }
        
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
    
    @try {
        
        if ( webBrowserMode && [EmptyCheck check:appDelegate.postText] ) {
            
            webBrowserMode = NO;
            appDelegate.fastGoogleMode = [NSNumber numberWithInt:0];
            postText.text = [NSString stringWithFormat:@"%@ ", [DeleteWhiteSpace string:[NSString stringWithFormat:@"%@ %@", postText.text, appDelegate.postText]]];
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
        
    }@catch (NSException *e) {
    }@finally {
        
        [self countText];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    
    [self setPostText:nil];
    [self setCallbackLabel:nil];
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
    [self setTapGesture:nil];
    [self setResendButton:nil];
    [self setRigthSwipe:nil];
    [self setLeftSwipe:nil];
    [self setNowPlayingButton:nil];
    [self setBrowserButton:nil];
    [self setInputFunctionButton:nil];
    [self setCallbackSelectButton:nil];
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
    [tapGesture release];
    [resendButton release];
    [rigthSwipe release];
    [leftSwipe release];
    [nowPlayingButton release];
    [browserButton release];
    [inputFunctionButton release];
    [callbackSelectButton release];
    [actionButton release];
    [super dealloc];
}

@end