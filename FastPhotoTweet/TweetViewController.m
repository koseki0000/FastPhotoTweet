//
//  ViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "TweetViewController.h"

#define APP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define TOP_BAR [NSArray arrayWithObjects:trashButton, flexibleSpace, idButton, flexibleSpace, resendButton, flexibleSpace, imageSettingButton, flexibleSpace, postButton, nil]
#define BOTTOM_BAR [NSArray arrayWithObjects:settingButton, flexibleSpace, browserButton, flexibleSpace, nowPlayingButton, flexibleSpace, actionButton, nil]

@implementation TweetViewController
@synthesize resendButton;
@synthesize sv;
@synthesize imageSettingButton;
@synthesize postText;
@synthesize callbackLabel;
@synthesize postCharLabel;
@synthesize pboardURLLabel;
@synthesize callbackSwitch;
@synthesize pboardURLSwitch;
@synthesize imagePreview;
@synthesize topBar;
@synthesize trashButton;
@synthesize postButton;
@synthesize flexibleSpace;
@synthesize tapGesture;
@synthesize rigthSwipe;
@synthesize leftSwipe;
@synthesize inputFunctionButton;
@synthesize iconPreview;
@synthesize browserButton;
@synthesize actionButton;
@synthesize nowPlayingButton;
@synthesize idButton;
@synthesize bottomBar;
@synthesize settingButton;

#pragma mark - Initialize

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self ) {
        
        self.title = NSLocalizedString(@"Tweet", @"Tweet");
        self.tabBarItem.image = [UIImage imageNamed:@"Bubble"];
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //NSLog(@"Tweet viewDidLoad");
    
    dispatch_queue_t asyncQueue = GLOBAL_QUEUE_DEFAULT;
    dispatch_async(asyncQueue, ^{
        
        SYNC_MAIN_QUEUE ^{
            
            [self setBottomBarPosition];
            
            //アイコン表示の角を丸める
            [iconPreview.layer setMasksToBounds:YES];
            [iconPreview.layer setCornerRadius:5.0f];
            
            postText.layer.borderWidth = 2;
            postText.layer.borderColor = [[UIColor blackColor] CGColor];
            
            //画像プレビュー時用マスク
            clearView = nil;
            
            //処理中を表すビューを生成
            grayView = [[GrayView alloc] init];
            [sv addSubview:grayView];
            
            //ツールバーにボタンをセット
            [topBar setItems:TOP_BAR animated:NO];
            [bottomBar setItems:BOTTOM_BAR animated:NO];
            
            postText.text = BLANK;
        });
        
        //アプリがアクティブになった場合の通知を受け取る設定
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(becomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        
        //投稿完了通知を受け取る設定
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(postDone:)
                                                     name:@"PostDone"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pboardNotification:)
                                                     name:@"pboardNotification"
                                                   object:nil];
        
        //各種初期値をセット
        d = [NSUserDefaults standardUserDefaults];
        pboard = [UIPasteboard generalPasteboard];
        errorImage = nil;
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        inReplyToId = BLANK;
        changeAccount = NO;
        cameraMode = NO;
        repeatedPost = NO;
        webBrowserMode = NO;
        artWorkUploading = NO;
        showActionSheet = NO;
        nowPlayingMode = NO;
        iconUploadMode = NO;
        actionSheetNo = 0;
        
        //保存されている情報をロード
        [self loadSettings];
        
        //インターネット接続のチェック
        [InternetConnection enable];
        
        //iOSバージョン判定
        if ( [appDelegate ios5Check] ) {
            
            ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
            ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            
            [accountStore requestAccessToAccountsWithType:accountType
                                    withCompletionHandler:^( BOOL granted, NSError *error ) {
                                        
                                        SYNC_MAIN_QUEUE ^{
                                            
                                            if ( granted ) {
                                                
                                                if ( [TWAccounts accountCount] > 0 ) {
                                                    
                                                    twAccount = [TWAccounts currentAccount];
                                                    
                                                    //入力可能状態にする
                                                    [postText becomeFirstResponder];
                                                    
                                                    //更新情報の表示
                                                    [self showInfomation];
                                                    
                                                } else {
                                                    
                                                    twAccount = nil;
                                                    [self setPostButton:nil];
                                                    [ShowAlert error:@"Twitterアカウントが見つかりませんでした。"];
                                                }
                                            } else {
                                                
                                                twAccount = nil;
                                                [self setPostButton:nil];
                                                [ShowAlert error:@"Twitterのアカウントへのアクセスが拒否されました。"];
                                            }
                                        });
                                    }];
            
        } else {
            
            SYNC_MAIN_QUEUE ^{
                
                twAccount = nil;
                [self setPostButton:nil];
                [ShowAlert error:@"Twitterのアカウントへのアクセスが拒否されました。"];
            });
        }
    });
}

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
    
    SYNC_MAIN_QUEUE ^{
       
        pboardURLSwitch.on = [d boolForKey:@"PasteBoardCheck"];
        callbackSwitch.on = [d boolForKey:@"CallBack"];
    });
    
    if ( ![EmptyCheck check:[d objectForKey:@"CallBackScheme"]] ) {
        
        //スキームが保存されていない場合FPTを設定
        [d setObject:@"FPT" forKey:@"CallBackScheme"];
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
        [d setObject:@" #nowplaying : [st] - [ar] - [at] -" forKey:@"NowPlayingEditText"];
    }
    
    //サブ書式が設定されていない場合デフォルト書式を設定
    if ( ![EmptyCheck check:[d objectForKey:@"NowPlayingEditTextSub"]] ) {
        [d setObject:@" #nowplaying : [st] - [ar] - " forKey:@"NowPlayingEditTextSub"];
    }
    
    //写真投稿先が設定されていない場合Twitterを設定
    if ( ![EmptyCheck check:[d objectForKey:@"PhotoService"]] ) {
        [d setObject:@"Twitter" forKey:@"PhotoService"];
    }
    
    //Webページ投稿書式が設定されていない場合はデフォルトの書式を設定
    if ( ![EmptyCheck check:[d objectForKey:@"WebPagePostFormat"]] ) {
        [d setObject:@" \"[title]\" [url] " forKey:@"WebPagePostFormat"];
    }
    
    //UserAgentが設定されていない場合はiPhoneを設定
    if ( ![EmptyCheck check:[d objectForKey:@"UserAgent"]] ) {
        [d setObject:@"iPhone" forKey:@"UserAgent"];
    }
    
    //UserAgentを戻す設定がされていない場合はOFFを設定
    if ( ![EmptyCheck check:[d objectForKey:@"UserAgentReset"]] ) {
        [d setObject:@"OFF" forKey:@"UserAgentReset"];
    }
    
    if ( ![EmptyCheck check:[d dictionaryForKey:@"ArtworkUrl"]] ) {
        [d setObject:[NSDictionary dictionary] forKey:@"ArtworkUrl"];
    }
    
    if ( [d integerForKey:@"IconCornerRounding"] == 0 ) {
        
        [d setInteger:1 forKey:@"IconCornerRounding"];
    }
    
    if ( [d objectForKey:@"TimelineLoadCount"] == nil ) {
        [d setObject:@"80" forKey:@"TimelineLoadCount"];
    }
    
    if ( [d objectForKey:@"MentionsLoadCount"] == nil ) {
        [d setObject:@"40" forKey:@"MentionsLoadCount"];
    }
    
    if ( [d objectForKey:@"FavoritesLoadCount"] == nil ) {
        [d setObject:@"40" forKey:@"FavoritesLoadCount"];
    }
    
    //設定を即反映
    [d synchronize];
}

- (void)setBottomBarPosition {
    
    //下部バーの位置を計算する
    int bottomBarY = SCREEN_HEIGHT - TAB_BAR_HEIGHT - TOOL_BAR_HEIGHT;
    
    //下部バーに位置と高さを設定する
    bottomBar.frame = CGRectMake(0,
                                 bottomBarY,
                                 SCREEN_WIDTH,
                                 TOOL_BAR_HEIGHT);
}

- (void)showInfomation {
    
    //NSLog(@"showInfomation");
    
    BOOL check = YES;
    NSMutableDictionary *information = nil;
    
    if ( ![EmptyCheck check:[d dictionaryForKey:@"Information"]] ) {
        
        //NSLog(@"init Information");
        [d setObject:[NSDictionary dictionary] forKey:@"Information"];
    }
    
    while ( check ) {
        
        if ( [[d dictionaryForKey:@"Information"] valueForKey:@"FirstRun"] == 0 ) {
            
            //NSLog(@"FirstRun");
            
            [ShowAlert title:@"ようこそ"
                     message:@"FastPhotoTweetへようこそ\nアプリ内やタスクスイッチャーから様々なTweetを素早くTwitterに投稿する事が出来ます。"];
            
            information = [[[NSMutableDictionary alloc] initWithDictionary:[d dictionaryForKey:@"Information"]] autorelease];
            [information setValue:[NSNumber numberWithInt:1] forKey:@"FirstRun"];
            
            NSDictionary *dic = [[[NSDictionary alloc] initWithDictionary:information] autorelease];
            [d setObject:dic forKey:@"Information"];
            
            //推奨設定
            [d setBool:YES forKey:@"ResizeImage"];
            [d setInteger:800 forKey:@"ImageMaxSize"];
            [d setObject:@"JPG(High)" forKey:@"SaveImageType"];
            [d setBool:YES forKey:@"NoResizeIphone4Ss"];
            [d setBool:YES forKey:@"FullSizeImage"];
            [d setBool:YES forKey:@"NowPlayingArtWork"];
            [d setBool:YES forKey:@"OpenPasteBoardURL"];
            [d setBool:YES forKey:@"SwipeShiftCaret"];
            [d setBool:YES forKey:@"EnterBackgroundUSDisConnect"];
            [d setBool:YES forKey:@"BecomeActiveUSConnect"];
            [d setBool:YES forKey:@"ReloadAfterUSConnect"];
            
            continue;
        }
        
        if ( [[d dictionaryForKey:@"Information"] valueForKey:APP_VERSION] == 0 ) {
            
            //NSLog(@"newVersion");
            
            [ShowAlert title:[NSString stringWithFormat:@"FastPhotoTweet %@", APP_VERSION]
                     message:@"・Timelineメニュー表示の微調整\n・Timeline更新後のスクロールの問題を修正\n・ReTweetの表示形式の変更\n・｢NowPlaying｣の問題を修正\n・｢Tweetを編集｣の問題を修正\n・その他細かな修正"];
            
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

#pragma mark - IBAction

- (IBAction)pushPostButton:(id)sender {
    
    //iOSバージョン判定
    if ( [appDelegate ios5Check] ) {
        
        //Internet接続のチェック
        if ( [InternetConnection enable] ) {
            
            if ( [TWAccounts accountCount] == 0 ) {
                
                [ShowAlert error:@"Twitterアカウントが見つかりませんでした。"];
                return;
            }
            
            NSString *text = [[[NSString alloc] initWithString:postText.text] autorelease];
            
            if ( imagePreview.image == nil &&
                ![EmptyCheck check:text] ) {
                
                [ShowAlert error:@"文字が入力されていません。"];
                return;
            }
            
            dispatch_queue_t globalQueue = GLOBAL_QUEUE_DEFAULT;
            dispatch_async( globalQueue, ^{
                
                SYNC_MAIN_QUEUE ^{
                    
                    postButton.enabled = NO;
                    [self callback];
                });
                
                //画像が設定されていない場合
                if ( imagePreview.image == nil ) {
                    
                    [TWSendTweet post:text
                      withInReplyToID:inReplyToId];
                    
                }else {
                    
                    //画像投稿先がTwitterの場合
                    if (( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitter"] ||
                        ( nowPlayingMode && [d  integerForKey:@"NowPlayingPhotoService"] == 1 )) &&
                         !cacheArtWorkSeted ) {
                        
                        //文字列と画像をバックグラウンドプロセスで投稿
                        [TWSendTweet post:text
                          withInReplyToID:inReplyToId
                                 andImage:imagePreview.image];
                        
                    }else {
                        
                        //画像投稿先がimg.urかTwitpicもしくは画像の再投稿
                        
                        [TWSendTweet post:text
                          withInReplyToID:inReplyToId];
                    }
                }
                
                SYNC_MAIN_QUEUE ^{
                    
                    //入力欄を空にする
                    postText.text = BLANK;
                    [inReplyToId release];
                    inReplyToId = BLANK;
                    imagePreview.image = nil;
                    cacheArtWorkSeted = NO;
                    
                    //とは検索機能ONかつ条件にマッチ
                    if ( [d boolForKey:@"TohaSearch"] &&
                        [text boolWithRegExp:@".+とは$"] ) {
                            
                            [self tohaSearch:text];
                        }
                    
                    postButton.enabled = YES;
                });
            });
        }
    }
}

- (IBAction)pushNowPlayingButton:(id)sender {
    
    //NSLog(@"pushNowPlayingButton");
    [self nowPlayingNotification];
}

- (IBAction)pushResendButton:(id)sender {
    
    //NSLog(@"pushResendButton");
    
    appDelegate.resendMode = YES;
    
    ResendViewController *dialog = [[[ResendViewController alloc] init] autorelease];
    dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:dialog animated:YES];
}

- (IBAction)pushTrashButton:(id)sender {
    
    //NSLog(@"Trash");
    
    nowPlayingMode = NO;
    artWorkUploading = NO;
    postText.text = BLANK;
    imagePreview.image = nil;
    postButton.enabled = YES;
    
    if ( [EmptyCheck check:inReplyToId] ) {
        
        [inReplyToId release];
        
        inReplyToId = BLANK;
    }
    
    [self countText];
}

- (IBAction)pushBrowserButton:(id)sender {
    
    NSString *useragent = IPHONE_USERAGENT;
    
    if ( [[d objectForKey:@"UserAgent"] isEqualToString:@"FireFox"] ) {
        
        useragent = FIREFOX_USERAGENT;
        
    }else if ( [[d objectForKey:@"UserAgent"] isEqualToString:@"iPad"] ) {
        
        useragent = IPAD_USERAFENT;
    }
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:useragent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    [dictionary release];
    
    webBrowserMode = YES;
    
    WebViewExController *dialog = [[[WebViewExController alloc] init] autorelease];
    dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:dialog animated:YES];
}

- (IBAction)pushSettingButton:(id)sender {
    
    //NSLog(@"Setting");
    
    SettingViewController *dialog = [[[SettingViewController alloc] init] autorelease];
    dialog.title = @"Settings";
    UINavigationController *navigation = [[[UINavigationController alloc] initWithRootViewController:dialog] autorelease];
    navigation.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    navigation.navigationBar.tintColor = [UIColor colorWithRed:0.4 green:0.8 blue:1.0 alpha:1.0];
    [self presentModalViewController:navigation animated:YES];
}

- (IBAction)pushIDButton:(id)sender {
    
    //NSLog(@"ID Change");
    
    changeAccount = YES;
    
    IDChangeViewController *dialog = [[[IDChangeViewController alloc] init] autorelease];
    dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:dialog animated:YES];
}

- (IBAction)pushImageSettingButton:(id)sender {
    
    //NSLog(@"pushImageSettingButton");
    
    //カメラか投稿時選択
    if ( [d integerForKey:@"ImageSource"] == 0 ||
         [d integerForKey:@"ImageSource"] == 2 ) {
        
        if ( [d boolForKey:@"RepeatedPost"] ) {
            
            //連続投稿確認がON
            
            actionSheetNo = 2;
            UIActionSheet *sheet = [[UIActionSheet alloc]
                                    initWithTitle:@"連続投稿"
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:appDelegate.tabBarController.self.view];
            
        }else {
            
            //連続投稿確認がOFF
            repeatedPost = NO;
            [self showImagePicker];
        }
        
    }else {
        
        //カメラ
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
                            otherButtonTitles:@"アイコン変更", @"指定時間後につぶやく", nil];
    [sheet autorelease];
    [sheet showInView:appDelegate.tabBarController.self.view];
}

- (IBAction)pushInputFunctionButton:(id)sender {
    
    actionSheetNo = 5;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"入力支援機能"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"半角カナ変換(カタカナ)", @"半角カナ変換(ひらがな)", @"半角カナ変換(カタカナ+ひらがな)", nil];
    [sheet autorelease];
    [sheet showInView:appDelegate.tabBarController.self.view];
}

- (IBAction)callbackSwitchDidChage:(id)sender {
    
    //スイッチの状態を保存
    if ( callbackSwitch.on ) {
        
        [d setBool:YES forKey:@"CallBack"];
        
    }else {
        
        [d setBool:NO forKey:@"CallBack"];
    }
}

- (IBAction)pboardSwitchDidChage:(id)sender {
    
    //スイッチの状態を保存
    if ( pboardURLSwitch.on ) {
        
        [d setBool:YES forKey:@"PasteBoardCheck"];
        
    }else {
        
        [d setBool:NO forKey:@"PasteBoardCheck"];
    }
}

#pragma mark - GestureRecognizer

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
        
        if ( nowPlayingMode ) {
            
            actionSheetNo = 11;
            
            UIActionSheet *sheet = [[UIActionSheet alloc]
                                    initWithTitle:@"機能選択"
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:@"アートワークURLを再設定", @"画像をアップロード", @"画像を破棄", @"画像を再選択", nil];
            [sheet autorelease];
            [sheet showInView:appDelegate.tabBarController.self.view];
            
        }else {
            
            actionSheetNo = 7;
            
            UIActionSheet *sheet = [[UIActionSheet alloc]
                                    initWithTitle:@"機能選択"
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:@"画像をアップロード", @"画像を破棄", @"画像を再選択", @"画像を表示", nil];
            [sheet autorelease];
            [sheet showInView:appDelegate.tabBarController.self.view];
        }
    }
}

- (IBAction)svSwipeGesture:(UISwipeGestureRecognizer *)sender {
    
    NSLog(@"svSwipeGesture");
    self.tabBarController.selectedIndex = 1;
}

- (IBAction)imagePreviewSwipeGesture:(UISwipeGestureRecognizer *)sender {
    
    NSLog(@"imagePreviewSwipeGesture");
    self.tabBarController.selectedIndex = 1;
}

- (IBAction)swipeToMoveCursorRight:(id)sender {
    
    if ( ![d boolForKey:@"SwipeShiftCaret"] ) return;
    
    int location = postText.selectedRange.location + 1;
    
    if ( location <= postText.text.length ) {
        
        [postText setSelectedRange:NSMakeRange( location, 0 )];
    }
}

- (IBAction)swipeToMoveCursorLeft:(id)sender {
    
    if ( ![d boolForKey:@"SwipeShiftCaret"] ) return;
    
    if ( postText.selectedRange.location != 0 ) {
        
        int location = postText.selectedRange.location - 1;
        [postText setSelectedRange:NSMakeRange( location, 0 )];
    }
}

- (void)tapClearView:(UITapGestureRecognizer *)sender {
    
    //NSLog(@"tapClearView");
    
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         self.view.frame = viewRect;
                         sv.frame = svRect;
                         imagePreview.frame = imagePreviewRect;
                     }
     
                     completion:^( BOOL finished ){
                         
                         appDelegate.tabBarController.tabBar.userInteractionEnabled = YES;
                         
                         if ( clearView != nil ) {
                             
                             [clearView removeFromSuperview];
                             clearView = nil;
                         }
                         
                         showImageMode = NO;
                     }
     ];
}

#pragma mark - Notification

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

- (void)becomeActive:(NSNotification *)notification {
    
    //アプリケーションがアクティブになった際に呼ばれる
    NSLog(@"ViewController becomeActive");
    
    if ( showImageMode ) [self tapClearView:nil];
    
    if ( appDelegate.browserOpenMode ) return;
    
    if ( appDelegate.willResignActive ) {
        
        NSLog(@"  willResignActive");
        appDelegate.willResignActive = NO;
        return;
    }
    
    if ( appDelegate.pboardURLOpenTweet ) {
        
        NSLog(@"  pboardURLOpenTweet");
        appDelegate.pboardURLOpenTweet = NO;
        return;
    }
    
    if ( [EmptyCheck check:appDelegate.urlSchemeDownloadUrl] ) {
        
        NSLog(@"  urlSchemeDownloadUrl");
        appDelegate.startupUrlList = [NSArray arrayWithObject:@"about:blank"];
        
        [self pushBrowserButton:nil];
        
        return;
    }
    
    if ( self.tabBarController.selectedIndex == 1 ) {
     
        NSLog(@"  selectedIndex == 1");
        return;
    }
    
    //設定が有効な場合Post入力可能状態にする
    if ( [d boolForKey:@"ShowKeyboard"] ) {
        
        [postText becomeFirstResponder];
    }
    
    //iOS5以降かチェック
    if ( [appDelegate ios5Check] ) {
        
        NSLog(@"  version check ok");
        NSLog(@"  showActionSheet: %@, showImagePicker: %@",
              showActionSheet ? @"YES" : @"NO",
              showImagePicker ? @"YES" : @"NO");
        
        if ( !showActionSheet && !showImagePicker ) {
            
            if ( appDelegate.launchMode == 2 ) {
                
                NSLog(@"  launchMode == 2");
                [self showActionMenu];
                
            }else {
                
                if ( appDelegate.launchMode == 1 ) {
                
                    NSLog(@"  launchMode == 1");
                    [self showActionMenu];
                }
            }
        }
        
        appDelegate.launchMode = 2;
    }
    
    [self countText];
}

- (void)pboardNotification:(NSNotification *)notification {
    
    NSLog(@"Tweet pboardNotification: %@", notification.userInfo);
    
    //Tweetタブを開いていない場合は終了
    if ( appDelegate.tabBarController.selectedIndex != 0 ||
        appDelegate.browserOpenMode ) return;
    
    appDelegate.startupUrlList = [NSArray arrayWithObject:[notification.userInfo objectForKey:@"pboardURL"]];
    [self pushBrowserButton:nil];
}

- (void)tohaSearch:(NSString *)text {
    
    appDelegate.startupUrlList = [NSArray arrayWithObject:[CreateSearchURL google:[text substringWithRange:NSMakeRange(0, text.length - 2)]]];
    
    [self pushBrowserButton:nil];
}

#pragma mark - ImagePicker

- (void)showImagePicker {
    
    showImagePicker = YES;
    
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
        [sheet showInView:appDelegate.tabBarController.self.view];
        
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
    
    showImagePicker = NO;
    
    if ( iconUploadMode ) {
        
        iconUploadMode = NO;
        
        image = [ResizeImage aspectResizeForMaxSize:image maxSize:256];
        [TWIconUpload image:image];
        
        if ( [appDelegate.firmwareVersion hasPrefix:@"6"] ) {
            
            [picPicker dismissViewControllerAnimated:YES completion:nil];
            
        }else {
            
            [picPicker dismissModalViewControllerAnimated:YES];
        }
        
        return;
    }
    
    //モーダルビューを閉じる
    if ( !repeatedPost ) {
        
        if ( [appDelegate.firmwareVersion hasPrefix:@"6"] ) {
            
            [picPicker dismissViewControllerAnimated:YES completion:nil];
            
        }else {
            
            [picPicker dismissModalViewControllerAnimated:YES];
        }
    }
    
    //画像ソースがカメラの場合保存
    if ( [d integerForKey:@"ImageSource"] == 1 || cameraMode ) {
    
        __block TweetViewController *weakSelf = self;
        __block UIImage *weakImage = image;
        
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        dispatch_async(queue, ^{
            
            UIImageWriteToSavedPhotosAlbum(weakImage,
                                           weakSelf,
                                           @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:),
                                           nil);
        });
    }
    
    //画像が選択された場合
    if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"img.ur"] ||
         [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitpic"] ) {
        
        //画像アップロード開始
        [self uploadImage:image];
    }
    
    //画像を設定
    imagePreview.image = image;
    
    //Post入力状態にする
    [postText becomeFirstResponder];
    [postText setSelectedRange:NSMakeRange(0, 0)];
    [self countText];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picPicker {
    
    //画像選択がキャンセルされた場合
    //モーダルビューを閉じる
    showImagePicker = NO;
    repeatedPost = NO;
    iconUploadMode = NO;
    
    if ( [appDelegate.firmwareVersion hasPrefix:@"6"] ) {
        
        [picPicker dismissViewControllerAnimated:YES completion:nil];
        
    }else {
        
        [picPicker dismissModalViewControllerAnimated:YES];
    }
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
        [sheet showInView:appDelegate.tabBarController.self.view];
    }
}

#pragma mark - ASIHTTPRequest

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
        postText.text = [postText.text replaceWord:@"  " replacedWord:@" "];
        
        //文字数カウントを行いラベルに反映
        [self countText];
        
        //カーソルを先頭にする
        [postText becomeFirstResponder];
        [postText setSelectedRange:NSMakeRange(0, 0)];
        
        //処理中表示をオフ
        [grayView off];
        
        if ( nowPlayingMode && artWorkUploading ) {
            
            [self saveArtworkUrl:imageURL];
        }
        
        if ( artWorkUploading ) artWorkUploading = NO;
        
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
    //NSLog(@"request.userInfo: %@", request.userInfo);
    
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
    [sheet showInView:appDelegate.tabBarController.self.view];
}

#pragma mark - ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( actionSheetNo == 0 ) {
        
        showActionSheet = NO;
        self.tabBarController.selectedIndex = 0;
        
        //ペーストボードの内容をチェック
        int pBoardType = [PasteboardType check];
        
        //NSLog(@"pBoardType: %d", pBoardType);
        
        if ( buttonIndex == 0 ) {
            
            [self tweetNotification:pBoardType];
            
        }else if ( buttonIndex == 1 ) {
            
            [self fasttweetNotification:pBoardType];
            
        }else if ( buttonIndex == 2 ) {
            
            [self phototweetNotification:pBoardType];
            
        }else if ( buttonIndex == 3 ) {
            
            [self nowPlayingNotification];
            
        }else if ( buttonIndex == 4 ) {
            
            if ( pBoardType == 0 ) {
                
                if ( !appDelegate.browserOpenMode ) {
                    
                    appDelegate.startupUrlList = [NSArray arrayWithObject:[CreateSearchURL google:pboard.string]];
                    
                    [self pushBrowserButton:nil];
                }
            }
            
        }else if ( buttonIndex == 5 ) {
            
            if ( !appDelegate.browserOpenMode ) {
                
                //NSLog(@"Open Browser");
                
                appDelegate.startupUrlList = [NSArray arrayWithObject:[d objectForKey:@"HomePageURL"]];
                
                [self pushBrowserButton:nil];
            }
            
        }else if ( buttonIndex == 6 ) {
            
            @autoreleasepool {
                
                [ActivityIndicator performSelectorInBackground:@selector(on) withObject:nil];
            }
            
            [self webPageShareNotification:pBoardType];
        }
        
    }else if ( actionSheetNo == 1 ) {
        
        showImagePicker = YES;
        
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
            showImagePicker = NO;
            
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
            
            UIImageWriteToSavedPhotosAlbum(errorImage,
                                           self,
                                           @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:),
                                           nil);
            
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
            
        }else if ( buttonIndex == 3 ) {
            
            showImageMode = YES;
            appDelegate.tabBarController.tabBar.userInteractionEnabled = NO;
            
            clearView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)] autorelease];
            clearView.backgroundColor = [UIColor clearColor];
            
            UITapGestureRecognizer *tapClearView = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClearView:)] autorelease];
            [clearView addGestureRecognizer:tapClearView];
            [self.view addSubview:clearView];
            
            viewRect = self.view.frame;
            svRect = sv.frame;
            imagePreviewRect = imagePreview.frame;
            
            [UIView animateWithDuration:0.4f
                                  delay:0.0f
                                options:UIViewAnimationOptionTransitionNone
             
                             animations:^{
                                 
                                 self.view.frame = CGRectMake(0 - (SCREEN_WIDTH - SCREEN_WIDTH / 8),
                                                              0,
                                                              SCREEN_WIDTH,
                                                              SCREEN_HEIGHT);
                                 
                                 sv.frame = CGRectMake(0,
                                                       TOOL_BAR_HEIGHT,
                                                       SCREEN_WIDTH * 2,
                                                       SCREEN_HEIGHT - TOOL_BAR_HEIGHT * 2);
                             }
             
                             completion:^( BOOL finished ){
                                 
                                 [UIView animateWithDuration:0.2f
                                                       delay:0.0f
                                                     options:UIViewAnimationOptionTransitionNone
                                  
                                                  animations:^{
                                                      
                                                      imagePreview.frame = CGRectMake(SCREEN_WIDTH,
                                                                                      0,
                                                                                      SCREEN_WIDTH - (SCREEN_WIDTH / 8),
                                                                                      SCREEN_HEIGHT - TAB_BAR_HEIGHT - (TOOL_BAR_HEIGHT * 2));
                                                  }
                                  
                                                  completion:nil
                                  ];
                             }
             ];
        }
        
    }else if ( actionSheetNo == 8 ) {
        
    }else if ( actionSheetNo == 9 ) {
        
        if ( buttonIndex == 0 ) {
            
            iconUploadMode = YES;
            showImagePicker = YES;
            
            UIImagePickerController *picPicker = [[[UIImagePickerController alloc] init] autorelease];
            picPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picPicker.delegate = self;
            [self presentModalViewController:picPicker animated:YES];
            
        }else if ( buttonIndex == 1 ) {
            
            actionSheetNo = 10;
            
            UIActionSheet *sheet = [[UIActionSheet alloc]
                                    initWithTitle:@"時間設定"
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:@"1分後", @"15分後", @"30分後", @"60分後", @"90分後", @"120分後", nil];
            [sheet autorelease];
            [sheet showInView:appDelegate.tabBarController.self.view];
        }
        
    }else if ( actionSheetNo == 10 ) {
        
        int sec = 0;
        
        if ( buttonIndex == 0 ) {
            sec = 60;
        }else if ( buttonIndex == 1 ) {
            sec = 60 * 15;
        }else if ( buttonIndex == 2 ) {
            sec = 60 * 30;
        }else if ( buttonIndex == 3 ) {
            sec = 60 * 60;
        }else if ( buttonIndex == 4 ) {
            sec = 60 * 90;
        }else if ( buttonIndex == 5 ) {
            sec = 60 * 120;
        }else {
            return;
        }
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        UILocalNotification *localPush = [[[UILocalNotification alloc] init] autorelease];
        localPush.timeZone = [NSTimeZone defaultTimeZone];
        localPush.fireDate = [NSDate dateWithTimeIntervalSinceNow:sec];
        localPush.alertBody = @"Tweet";
        [[UIApplication sharedApplication] scheduleLocalNotification:localPush];
        
    }else if ( actionSheetNo == 11 ) {
        
        if ( buttonIndex == 0 ) {
            
            //キー情報作成のために再生情報を取得
            MPMusicPlayerController *player = [MPMusicPlayerController iPodMusicPlayer];
            NSString *songTitle = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
            NSString *songArtist = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];
            NSString *albumTitle = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyAlbumTitle];
            
            //再設定するキー名を生成
            NSString *keyName = [NSString stringWithFormat:@"%@ - %@ - %@", songTitle, songArtist, albumTitle];
            
            //設定を読み込む
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[d dictionaryForKey:@"ArtworkUrl"]];
            
            //削除するURLを取得
            NSString *deleteUrl = [dic objectForKey:keyName];
            
            //入力欄から対象URLを削除
            postText.text = [postText.text deleteWord:deleteUrl];
            
            //対象キーを削除
            [dic removeObjectForKey:keyName];
            [d setObject:dic forKey:@"ArtworkUrl"];
            
            //アートワークの再アップロード開始
            artWorkUploading = YES;
            [self uploadImage:imagePreview.image];
            
        }else if ( buttonIndex == 1 ) {
            
            if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitter"] ) {
                
                [ShowAlert error:@"Twitterへのアップロードは本文の投稿と同時に行われます。"];
                
            }else {
                
                [self uploadImage:imagePreview.image];
            }
            
        }else if ( buttonIndex == 2 ) {
            
            imagePreview.image = nil;
            [self countText];
            
        }else if ( buttonIndex == 3 ) {
            
            [self pushImageSettingButton:nil];
        }
    }
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
	[sheet showInView:appDelegate.tabBarController.self.view];
}

#pragma mark - ViewControl

- (void)textViewDidChange:(UITextView *)textView {
    
    //TextViewの内容が変更された時に呼ばれる
    
    //文字数をカウントしてラベルに反映
    [self countText];
}

- (oneway void)countText {
    
    //t.coを考慮した文字数カウントを行う
    int num = [TWCharCounter charCounter:postText.text];
    
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

- (oneway void)uploadImage:(UIImage *)image {
    
    @autoreleasepool {
        
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
            
            twAccount = [TWAccounts currentAccount];
            
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
}

- (void)callback {
    
    //NSLog(@"Callback Start");
    
    nowPlayingMode = NO;
    
    BOOL canOpen = NO;
    
    if ( [d boolForKey:@"CallBack"] ) {
        
        //CallbackSchemeが空でない
        if ( [EmptyCheck check:[d objectForKey:@"CallBackScheme"]] ) {
            
            if ( [[d objectForKey:@"CallBackScheme"] isEqualToString:@"FPT"] ) {
                
                [postText resignFirstResponder];
                self.tabBarController.selectedIndex = 1;
                
            }else {
                
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
    }
}

#pragma mark - NowPlaying

- (NSString *)nowPlaying {
    
    //NSLog(@"nowPlaying");
    
    cacheArtWorkSeted = NO;
    NSMutableString *resultText = [NSMutableString stringWithString:BLANK];
    
    @try {
        
        //再生中各種の曲の各種情報を取得
        MPMusicPlayerController *player = [MPMusicPlayerController iPodMusicPlayer];
        NSString *songTitle = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
        NSString *songArtist = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];
        NSString *albumTitle = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyAlbumTitle];
        NSNumber *playCount = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyPlayCount];
        NSNumber *ratingNum = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyRating];
        
        NSString *url = nil;
        
        if ( [d boolForKey:@"NowPlayingArtWork"] ) {
            
            NSString *searchKey = [NSString stringWithFormat:@"%@ - %@ - %@", songTitle, songArtist, albumTitle];
            NSDictionary *dic = [d dictionaryForKey:@"ArtworkUrl"];
            
            for ( NSString *key in dic ) {
                
                if ( [key isEqualToString:searchKey] ) {
                    
                    url = [dic objectForKey:key];
                    
                    break;
                }
            }
            
            MPMediaItemArtwork *artwork = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork];
            
            int h = (int)artwork.bounds.size.height;
            int w = (int)artwork.bounds.size.width;
            
            imagePreview.image = [ResizeImage aspectResizeForMaxSize:[artwork imageWithSize:CGSizeMake(500, 500)]
                                                             maxSize:500];
            
            if ( ![EmptyCheck check:url] ) {
                
                if ( h != 0 && w != 0 ) {
                    
                    int uploadType = [d integerForKey:@"NowPlayingPhotoService"];
                    
                    if ( uploadType == 0 ) {
                        
                        if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"img.ur"] ) {
                            
                            uploadType = 2;
                            
                        }else if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitpic"] ) {
                            
                            uploadType = 3;
                        }
                    }
                    
                    //アップロード先がTwitter以外
                    if ( uploadType != 0 && uploadType != 1 ) {
                        
                        artWorkUploading = YES;
                        
                        //アートワークをアップロード
                        [self uploadNowPlayingImage:imagePreview.image
                                         uploadType:uploadType];
                    }
                }
            }
        }
        
        //曲名が無い場合は終了
        if ( songTitle.length == 0 ) return BLANK;
        
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
            resultText = [resultText replaceMutableWord:@"[st]" replacedWord:songTitle];
            resultText = [resultText replaceMutableWord:@"[ar]" replacedWord:songArtist];
            resultText = [resultText replaceMutableWord:@"[at]" replacedWord:albumTitle];
            resultText = [resultText replaceMutableWord:@"[pc]" replacedWord:playCountStr];
            resultText = [resultText replaceMutableWord:@"[rt]" replacedWord:ratingStr];
            
        }else {
            
            //NSLog(@"default");
            
            //デフォルトの書式を適用
            resultText = [NSMutableString stringWithFormat:@" #nowplaying : %@ - %@ ", songTitle, songArtist];
        }
        
        if ( [d boolForKey:@"NowPlayingArtWork"] && [EmptyCheck check:url] ) {
            
            cacheArtWorkSeted = YES;
            resultText = [NSMutableString stringWithFormat:@"%@%@", resultText, url];
        }
        
    }@catch (NSException *e) {
        
        [ShowAlert unknownError];
        
        return BLANK;
    }
    
    return (NSString *)resultText;
}

- (void)saveArtworkUrl:(NSString *)url {
    
    MPMusicPlayerController *player = [MPMusicPlayerController iPodMusicPlayer];
    NSString *songTitle = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle];
    NSString *songArtist = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyArtist];
    NSString *albumTitle = [player.nowPlayingItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    
    NSString *keyName = [NSString stringWithFormat:@"%@ - %@ - %@", songTitle, songArtist, albumTitle];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[d dictionaryForKey:@"ArtworkUrl"]];
    [dic setValue:url forKey:keyName];
    
    [d setObject:dic forKey:@"ArtworkUrl"];
}

- (void)setIconPreviewImage {
    
    NSArray *iconsDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:ICONS_DIRECTORY error:nil];
    NSString *searchName = [NSString stringWithFormat:@"%@_", [TWAccounts currentAccountName]];
    
    //アイコンが見つかったか
    BOOL find = NO;
    
    for ( NSString *name in iconsDirectory ) {
        
        if ( [name hasPrefix:searchName] ) {
            
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:[ICONS_DIRECTORY stringByAppendingPathComponent:name]];
            iconPreview.image = image;
            [image release];
            
            find = YES;
            
            break;
        }
    }
    
    //アイコンが見つからなかった場合はnilをセット
    if ( !find ) iconPreview.image = nil;
}

- (oneway void)uploadNowPlayingImage:(UIImage *)image uploadType:(int)uploadType {
    
    @autoreleasepool {
        
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
            
            twAccount = [TWAccounts currentAccount];
            
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
}

#pragma mark - NotificationAction

- (void)webPageShareNotification:(int)pBoardType {
    
    @try {
        
        dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
        dispatch_async( globalQueue, ^{
            dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
            dispatch_sync( syncQueue, ^{
                
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
                    [ActivityIndicator visible:NO];
                    
                    return;
                }
                
                if ( pBoardType != 0 || pboardString == nil ) {
                    
                    [ShowAlert error:@"CODE: 02\nペーストボード内にURLがありません。"];
                    [ActivityIndicator visible:NO];
                    
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
                    [ActivityIndicator visible:NO];
                    
                    return;
                }
                
                NSMutableString *title = [dataStr mStrWithRegExp:@"<title>.+</title>"];
                title = [title deleteMutableWord:@"<title>"];
                title = [title deleteMutableWord:@"</title>"];
                
                if ( ![EmptyCheck check:title] ) {
                    
                    title = (NSMutableString *)[pboardString lastPathComponent];
                    
                    if ( ![EmptyCheck check:title] ) {
                        
                        [ShowAlert error:@"CODE: 04\n正常にタイトルが取得できませんでした。"];
                        [ActivityIndicator visible:NO];
                        
                        return;
                    }
                }
                
                NSString *shareString = [NSString stringWithFormat:@"\"%@\" %@", title, pboardString];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    postText.text = [NSString stringWithFormat:@"%@ ", [DeleteWhiteSpace string:[NSString stringWithFormat:@"%@ %@", postText.text, shareString]]];
                    [postText becomeFirstResponder];
                    [ActivityIndicator visible:NO];
                });
			});
        });
        
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
        
        //FastPostが有効、アートワークアップロード中ではない
        if ( [d boolForKey:@"NowPlayingFastPost"] && !artWorkUploading ) {
            
            @autoreleasepool {
                
                if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitter"] ) {
                    
                    if ( imagePreview.image != nil ) {
                        
                        [TWSendTweet post:nowPlayingText
                          withInReplyToID:inReplyToId
                                 andImage:imagePreview.image];
                        
                    }else {
                        
                        [TWSendTweet post:nowPlayingText
                          withInReplyToID:inReplyToId];
                    }
                    
                }else {
                    
                    [TWSendTweet post:nowPlayingText
                      withInReplyToID:inReplyToId];
                }
                
                imagePreview.image = nil;
            }
            
            //CallBack、またはNowPlaying限定CallBackが有効
            if ( [d boolForKey:@"CallBack"] ) {
                
                //NSLog(@"Callback Enable");
                
                //CallBack
                [self callback];
            }
            
        }else {
            
            if ( [postText.text hasSuffix:@" "] ) {
                
                postText.text = [NSString stringWithFormat:@"%@ ", postText.text];
            }
            
            postText.text = [NSString stringWithFormat:@"%@%@", postText.text , nowPlayingText];
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
    
    [self countText];
}

- (void)tweetNotification:(int)pBoardType {
    
    if ( pBoardType == 0 ) {
        
        //NSLog(@"pBoardType Text");
        
        @try {
            
            //ペーストボード内容をPost入力欄にコピー
            postText.text = pboard.string;
            
        }@catch ( NSException *e ) {}
        
    }else {
        
        //NSLog(@"pBoardType not text");
    }
    
    //Post入力状態にする
    [postText becomeFirstResponder];
}

- (void)fasttweetNotification:(int)pBoardType {
    
    @try {
        
        BOOL canPost = NO;
        
        //ペーストボード内がテキスト
        if ( pBoardType == 0 ) {
            
            //t.coを考慮した文字数カウントを行う
            int num = [TWCharCounter charCounter:pboard.string];
            
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
                    [TWSendTweet post:text
                      withInReplyToID:inReplyToId];
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
        
    }@catch ( NSException *e ) {}
}

- (void)phototweetNotification:(int)pBoardType {
    
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

#pragma mark - View

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    @try {
        
        //タブ切り替え時の動作
        if ( [EmptyCheck check:appDelegate.tabChangeFunction] ) {
            
            //NSLog(@"Function: %@", appDelegate.tabChangeFunction);
            
            if ( [appDelegate.tabChangeFunction isEqualToString:@"Post"] ) {
                
                //入力可能状態にする
                [postText becomeFirstResponder];
                
            }else if ( [appDelegate.tabChangeFunction isEqualToString:@"Reply"] ) {
                
                NSDictionary *postData = appDelegate.postData;
                postText.text = [NSString stringWithFormat:@"@%@ %@", [postData objectForKey:@"ScreenName"], postText.text];
                inReplyToId = [postData objectForKey:@"InReplyToId"];
                [inReplyToId retain];
                
                [postText becomeFirstResponder];
                [appDelegate.postData removeAllObjects];
                
            }else if ( [appDelegate.tabChangeFunction isEqualToString:@"Edit"] ) {
                
                NSDictionary *postData = appDelegate.postData;
                postText.text = [postData objectForKey:@"Text"];
                inReplyToId = [postData objectForKey:@"InReplyToId"];
                [inReplyToId retain];
                
                [postText becomeFirstResponder];
                [appDelegate.postData removeAllObjects];
                
            }else if ( [appDelegate.tabChangeFunction isEqualToString:@"PostError"] ) {
                
                [ShowAlert error:@"投稿に失敗しました。失敗したPostは上部中央のボタンから再投稿出来ます。"];
                resendButton.enabled = YES;
            }
            
            appDelegate.tabChangeFunction = BLANK;
            
            return;
        }
        
        if ( appDelegate.pcUaMode ) {
            
            appDelegate.pcUaMode = NO;
            
            //開き直す
            [self pushBrowserButton:nil];
            
            return;
        }
        
        if ( [EmptyCheck check:appDelegate.postText] ) {
            
            postText.text = [NSString stringWithFormat:@"%@%@", postText.text, appDelegate.postText];
            [postText becomeFirstResponder];
            
            appDelegate.postText = BLANK;
            
            if ( [appDelegate.postTextType isEqualToString:@"WebPage"] ) {
                
                if ( [d boolForKey:@"WebPagePostCursorPosition"] ) {
                    
                    [postText setSelectedRange:NSMakeRange(0, 0)];
                    
                }else {
                    
                    [postText setSelectedRange:NSMakeRange(postText.text.length, 0)];
                }
                
            }else if ( [appDelegate.postTextType isEqualToString:@"Quote"] ) {
                
                if ( [d boolForKey:@"QuoteCursorPosition"] ) {
                    
                    [postText setSelectedRange:NSMakeRange(0, 0)];
                    
                }else {
                    
                    [postText setSelectedRange:NSMakeRange(postText.text.length, 0)];
                }
            }
            
            appDelegate.postTextType = BLANK;
        }
        
        if ( webBrowserMode ) {
            
            webBrowserMode = NO;
            
            return;
        }
        
        if ( changeAccount || appDelegate.needChangeAccount ) {
            
            //NSLog(@"ChangeAccount");
            
            appDelegate.needChangeAccount = NO;
            changeAccount = NO;
            
            //アカウント設定を更新
            ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
            ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
            twAccount = [twitterAccounts objectAtIndex:[d integerForKey:@"UseAccount"]];
            
        }else if ( appDelegate.resendMode ) {
            
            appDelegate.resendMode = NO;
            
            NSArray *resendArray = [appDelegate.postError objectAtIndex:appDelegate.resendNumber];
            
            int account = [[resendArray objectAtIndex:1] intValue];
            [d setInteger:account forKey:@"UseAccount"];
            
            postText.text = [resendArray objectAtIndex:2];
            inReplyToId = [resendArray objectAtIndex:3];
            
            if ( resendArray.count == 4 ) {
                
                //NSLog(@"Resend data set TEXT");
                
            }else if ( resendArray.count == 5 ) {
                
                //NSLog(@"Resend data set PHOTO");
                imagePreview.image = [resendArray objectAtIndex:4];
            }
            
            [appDelegate.postError removeObjectAtIndex:appDelegate.resendNumber];
        }
        
        //再投稿ボタンの有効･無効切り替え
        if ( appDelegate.postError.count == 0 ) {
            
            resendButton.enabled = NO;
            
        }else {
            
            resendButton.enabled = YES;
        }
        
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
    [self setActionButton:nil];
    [self setIconPreview:nil];
    [self setPboardURLLabel:nil];
    [self setPboardURLSwitch:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //NSLog(@"viewWillAppear");
    [self setIconPreviewImage];
}

- (void)viewWillDisappear:(BOOL)animated {
    
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotate {
    
    //NSLog(@"ViewController shouldAutorotate");
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    //NSLog(@"ViewController supportedInterfaceOrientations");
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    
    [twAccount release];
    twAccount = nil;
    [postText release];
    postText = nil;
    [callbackLabel release];
    callbackLabel = nil;
    [callbackSwitch release];
    callbackSwitch = nil;
    [postCharLabel release];
    postCharLabel = nil;
    [imagePreview release];
    imagePreview = nil;
    [imageSettingButton release];
    imageSettingButton = nil;
    [sv release];
    sv = nil;
    [topBar release];
    topBar = nil;
    [trashButton release];
    trashButton = nil;
    [postButton release];
    postButton = nil;
    [flexibleSpace release];
    flexibleSpace = nil;
    [settingButton release];
    settingButton = nil;
    [bottomBar release];
    bottomBar = nil;
    [idButton release];
    idButton = nil;
    [tapGesture release];
    tapGesture = nil;
    [resendButton release];
    resendButton = nil;
    [rigthSwipe release];
    rigthSwipe = nil;
    [leftSwipe release];
    leftSwipe = nil;
    [nowPlayingButton release];
    nowPlayingButton = nil;
    [browserButton release];
    browserButton = nil;
    [inputFunctionButton release];
    inputFunctionButton = nil;
    [actionButton release];
    actionButton = nil;
    [iconPreview release];
    iconPreview = nil;
    [pboardURLLabel release];
    pboardURLLabel = nil;
    [pboardURLSwitch release];
    pboardURLSwitch = nil;
    
    [super dealloc];
}

@end