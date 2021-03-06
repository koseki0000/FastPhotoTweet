//
//  SettingViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "SettingViewController.h"
#import "ListViewController.h"

//セクション数
#define SECTION_COUNT 5
//セクション0の項目数 (画像関連設定)
#define SECTION_0 9
//セクション1の項目数 (投稿関連設定)
#define SECTION_1 10
//セクション2の項目数 (その他の設定)
#define SECTION_2 6
//セクション2の項目数 (タイムライン設定)
#define SECTION_3 15

//セクション3の項目数 (ライセンス)
#define SECTION_4 2

//設定項目名
//画像関連設定
#define IMAGE_RESIZE  @"画像投稿時リサイズを行う"
#define IMAGE_RESIZE_MAX  @"リサイズ最大長辺"
#define IMAGE_FORMAT  @"画像形式"
#define NO_RESIZE_RETINA  @"Retina解像度画像もリサイズを行う"
#define IMAGE_SERVICE  @"画像投稿先"
#define IMAGE_SOURCE  @"画像ソース"
#define IMAGE_REPEATED  @"連続投稿確認表示"
#define IMAGE_GET_FULL  @"画像共有サービスフルサイズ取得"
#define NOWPLAYING_IMAGE  @"NowPlaying画像投稿先"
//投稿関連設定
#define NOWPLAYING_CUSTOM @"NowPlayingにカスタム書式を使用"
#define NOWPLAYING_CUSTOM_EDIT @"カスタム書式を編集"
#define NOWPLAYING_DUPLICATE_NAME @"曲名とアルバム名が同じな場合サブ書式を使用"
#define NOWPLAYING_SUB_STYLE @"サブ書式を編集"
#define NOWPLAYING_ARTWORK @"NowPlaying時にアートワークを投稿"
#define TOHA_SEARCH @"とは検索機能を使用"
#define WEB_PAGE_SHARE_STYLE @"Webページ投稿書式変更"
#define WEB_PAGE_SHARE_CURSOR @"Webページ投稿書式セット後カーソル位置"
#define WEB_PAGE_QUOTE_STYLE @"引用投稿書式変更"
#define WEB_PAGE_QUOTE_CURSOR @"引用投稿書式セット後カーソル位置"

//その他の設定
#define ACTIVE_INPUT @"アプリがアクティブになった際入力可能状態にする"
#define SEARCH_WORD_RESET @"ブラウザの検索ワードを毎回リセット"
#define PASTE_BOARD_URL @"ブラウザを開く時ペーストボード内のURLを開く"
#define USER_AGENT @"ブラウザユーザーエージェント"
#define USER_AGENT_RESET @"ブラウザを閉じる時にユーザーエージェントを戻す"
#define SWIPE_SHIFT_CARET @"Tweet入力欄をスワイプでカーソルを移動"

//タイムライン設定
#define ENTER_BACKGROUND_US @"バックグラウンドに移行時UserStreamを切断"
#define BECOME_ACTIVE_US @"バックグラウンドから復帰時UserStreamに接続"
#define RELOAD_US @"通常の更新後にUserStreamに接続"
#define NG_OPEN @"NG設定を開く"
#define MY_TWEET_NG @"自分のTweetもNGを行う"
#define ICON_CORNER @"アイコンの角を丸める"
#define US_NO_AUTO_LOCK @"UserStream接続中は自動ロックを無効化する"
#define TIMELINE_LOAD @"Timeline読み込み数"
#define MENTIONS_LOAD @"Mentions読み込み数"
#define FAVORITES_LOAD @"Favorites読み込み数"
#define TIMELINE_FIRSTLOAD @"Timeline初回読み込み後表示位置"
#define TIMELINE_ICON_ACTION @"アイコンタップ時の動作"
#define TIMELINE_LIST @"Timeline代替Listを使用"
#define TIMELINE_LIST_SELECT @"Timeline代替List選択"
#define ICON_QUALITY @"アイコン画質"

#define NAME_LICENSE @"ライセンス"
#define SPECIAL_THANKS @"スペシャルサンクス"

#define BLANK @""

@implementation SettingViewController
@synthesize tv;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    //初期化処理
    if ( self ) {
        
        //NSLog(@"SettingView init");
        
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        actionSheetNo = 0;
        alertTextNo = 0;
        
        appDelegate.twitpicLinkMode = NO;
        appDelegate.addTwitpicAccountName = BLANK;
        
        //設定項目名を持った可変長配列を生成
        settingArray =
        [NSMutableArray arrayWithObjects:
         IMAGE_RESIZE, IMAGE_RESIZE_MAX, IMAGE_FORMAT, NO_RESIZE_RETINA, IMAGE_SERVICE, IMAGE_SOURCE,
         IMAGE_REPEATED, IMAGE_GET_FULL, NOWPLAYING_IMAGE, NOWPLAYING_CUSTOM, NOWPLAYING_CUSTOM_EDIT,
         NOWPLAYING_DUPLICATE_NAME, NOWPLAYING_SUB_STYLE, NOWPLAYING_ARTWORK, TOHA_SEARCH,
         WEB_PAGE_SHARE_STYLE, WEB_PAGE_SHARE_CURSOR, WEB_PAGE_QUOTE_STYLE, WEB_PAGE_QUOTE_CURSOR,
         ACTIVE_INPUT, SEARCH_WORD_RESET, PASTE_BOARD_URL, USER_AGENT, USER_AGENT_RESET,
         SWIPE_SHIFT_CARET, ENTER_BACKGROUND_US, BECOME_ACTIVE_US, RELOAD_US, NG_OPEN, MY_TWEET_NG,
         ICON_CORNER, US_NO_AUTO_LOCK, TIMELINE_LOAD, MENTIONS_LOAD, FAVORITES_LOAD, TIMELINE_FIRSTLOAD,
         TIMELINE_ICON_ACTION, TIMELINE_LIST, TIMELINE_LIST_SELECT, ICON_QUALITY,
         NAME_LICENSE, SPECIAL_THANKS, nil];
        
        [settingArray retain];
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [tv flashScrollIndicators];
    
    UIBarButtonItem *closeButton = [[[UIBarButtonItem alloc] initWithTitle:@"閉じる"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(pushDoneButton:)] autorelease];
    self.navigationItem.leftBarButtonItem = closeButton;
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    //NSLog(@"viewDidAppear");
    
    if ( appDelegate.twitpicLinkMode ) {
        
        //NSLog(@"TwitPic Link");
        
        if ( [EmptyCheck check:appDelegate.addTwitpicAccountName] ) {
            
            appDelegate.twitpicLinkMode = NO;
            
            //仮登録された情報の名前を生成
            NSString *searchAccountName = [NSString stringWithFormat:@"OAuthAccount_%d", [USER_DEFAULTS integerForKey:@"AccountCount"]];
            
            //NSLog(@"searchAccountName: %@", searchAccountName);
            
            //設定からアカウントリストを読み込む
            NSMutableDictionary *dic = [[USER_DEFAULTS dictionaryForKey:@"OAuthAccount"] mutableCopy];
            
            //key, secretを取得
            NSString *key = [[dic objectForKey:searchAccountName] objectAtIndex:0];
            NSString *secret = [[dic objectForKey:searchAccountName] objectAtIndex:1];
            
            //配列を生成
            NSArray *accountData = [NSArray arrayWithObjects:key, secret, nil];
            
            //仮情報を削除
            [dic removeObjectForKey:searchAccountName];
            
            //アカウント情報を登録
            [dic setObject:accountData forKey:appDelegate.addTwitpicAccountName];
            
            //設定に反映
            NSDictionary *saveDic = [[NSDictionary alloc] initWithDictionary:dic];
            [USER_DEFAULTS setObject:saveDic forKey:@"OAuthAccount"];
            [saveDic release];
            [dic release];
            
            [USER_DEFAULTS setObject:@"Twitpic" forKey:@"PhotoService"];
            appDelegate.addTwitpicAccountName = BLANK;
            appDelegate.needChangeAccount = YES;
            
            //NSLog(@"OAuthAccount: %@", [USER_DEFAULTS dictionaryForKey:@"OAuthAccount"]);
            
        } else {
            
            IDChangeViewController *dialog = [[[IDChangeViewController alloc] init] autorelease];
            dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self showModalViewController:dialog];
        }
        
    } else if ( self.listSelectMode ) {
        
        [self setListSelectMode:NO];
        
        NSLog(@"%@", [USER_DEFAULTS objectForKey:@"TimelineList"]);
    }
    
    //設定項目の表示を更新
    [tv reloadData];
}

- (IBAction)pushDoneButton:(id)sender {
    
    //NSLog(@"pushDoneButton");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)getSettingState:(int)settingState {
    
    //NSLog(@"getSettingState: %d", index);
    
    NSString *result = BLANK;
    
    //画像投稿時リサイズを行う
    if ( settingState == 0 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"ResizeImage"] ) {
            
            result = @"ON";
            
        } else {
            
            result = @"OFF";
        }
        
        //リサイズ最大長辺
    } else if ( settingState == 1 ) {
        
        result = [NSString stringWithFormat:@"%d", [USER_DEFAULTS integerForKey:@"ImageMaxSize"]];
        
        //画像形式
    } else if ( settingState == 2 ) {
        
        result = [NSString stringWithFormat:@"%@", [USER_DEFAULTS objectForKey:@"SaveImageType"]];;
        
        //Retina解像度画像もリサイズを行う
    } else if ( settingState == 3 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"NoResizeIphone4Ss"] ) {
            
            result = @"OFF";
            
        } else {
            
            result = @"ON";
        }
        
        //画像投稿先
    } else if ( settingState == 4 ) {
        
        result = [NSString stringWithFormat:@"%@", [USER_DEFAULTS objectForKey:@"PhotoService"]];
        
        //画像ソース
    } else if ( settingState == 5 ) {
        
        if ( [USER_DEFAULTS integerForKey:@"ImageSource"] == 0 ) {
            
            result = @"カメラロール";
            
        } else if ( [USER_DEFAULTS integerForKey:@"ImageSource"] == 1 ) {
            
            result = @"カメラ";
            
        } else if ( [USER_DEFAULTS integerForKey:@"ImageSource"] == 2 ) {
            
            result = @"投稿時選択";
        }
        
        //連続投稿確認表示
    } else if ( settingState == 6 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"RepeatedPost"] ) {
            
            result = @"ON";
            
        } else {
            
            result = @"OFF";
        }
        
        //画像共有サービスフルサイズ取得
    } else if ( settingState == 7 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"FullSizeImage"] ) {
            
            result = @"ON";
            
        } else {
            
            result = @"OFF";
        }
        
        //NowPlaying画像投稿先
    } else if ( settingState == 8 ) {
        
        if ( [USER_DEFAULTS integerForKey:@"NowPlayingPhotoService"] == 0 ) {
            
            result = @"通常と同じ";
            
        } else if ( [USER_DEFAULTS integerForKey:@"NowPlayingPhotoService"] == 1 ) {
            
            result = @"Twitter";
            
        } else if ( [USER_DEFAULTS integerForKey:@"NowPlayingPhotoService"] == 2 ) {
            
            result = @"img.ur";
            
        } else if ( [USER_DEFAULTS integerForKey:@"NowPlayingPhotoService"] == 3 ) {
            
            result = @"Twitpic";
        }
        
        //NowPlayingにカスタム書式を使用
    } else if ( settingState == 9 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"NowPlayingEdit"] ) {
            
            result = @"ON";
            
        } else {
            
            result = @"OFF";
        }
        
        //カスタム書式を編集
    } else if ( settingState == 10 ) {
        
        //空のまま
        
        //曲名とアルバム名が同じな場合サブ書式を使用
    } else if ( settingState == 11 ) {
        
        if ( [USER_DEFAULTS integerForKey:@"NowPlayingEditSub"] == 0 ) {
            
            result = @"OFF";
            
        } else if ( [USER_DEFAULTS integerForKey:@"NowPlayingEditSub"] == 1 ) {
            
            result = @"ON\n(前方一致)";
            
        } else if ( [USER_DEFAULTS integerForKey:@"NowPlayingEditSub"] == 2 ) {
            
            result = @"ON\n(完全一致)";
        }
        
        //サブ書式を編集
    } else if ( settingState == 12 ) {
        
        //空のまま
        
        //NowPlaying時にアートワークを投稿
    } else if ( settingState == 13 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"NowPlayingArtWork"] ) {
            
            result = @"ON";
            
        } else {
            
            result = @"OFF";
        }
        
        //とは検索
    } else if ( settingState == 14 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"TohaSearch"] ) {
            
            result = @"ON";
            
        } else {
            
            result = @"OFF";
        }
        
        //Webページ投稿書式変更
    } else if ( settingState == 15 ) {
        
        //Webページ投稿書式セット後カーソル位置
    } else if ( settingState == 16 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"WebPagePostCursorPosition"] ) {
            
            result = @"先頭";
            
        } else {
            
            result = @"末尾";
        }
        
        //  } else if ( settingState == 17 ) {
        
    } else if ( settingState == 18 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"QuoteCursorPosition"] ) {
            
            result = @"先頭";
            
        } else {
            
            result = @"末尾";
        }
        
        //アプリがアクティブになった際入力可能状態にする
    } else if ( settingState == 19 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"ShowKeyboard"] ) {
            
            result = @"ON";
            
        } else {
            
            result = @"OFF";
        }
        
    } else if ( settingState == 20 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"ClearBrowserSearchField"] ) {
            
            result = @"ON";
            
        } else {
            
            result = @"OFF";
        }
        
    } else if ( settingState == 21 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"OpenPasteBoardURL"] ) {
            
            result = @"ON";
            
        } else {
            
            result = @"OFF";
        }
        
    } else if ( settingState == 22 ) {
        
        if ( [[USER_DEFAULTS objectForKey:@"UserAgent"] isEqualToString:@"FireFox"] ) {
            
            result = @"FireFox";
            
        } else if ( [[USER_DEFAULTS objectForKey:@"UserAgent"] isEqualToString:@"iPad"] ) {
            
            result = @"iPad";
            
        } else {
            
            result = @"iPhone";
        }
        
    } else if ( settingState == 23 ) {
        
        if ( [[USER_DEFAULTS objectForKey:@"UserAgentReset"] isEqualToString:@"FireFox"] ) {
            
            result = @"FireFox";
            
        } else if ( [[USER_DEFAULTS objectForKey:@"UserAgentReset"] isEqualToString:@"iPad"] ) {
            
            result = @"iPad";
            
        } else if ( [[USER_DEFAULTS objectForKey:@"UserAgentReset"] isEqualToString:@"iPhone"] ) {
            
            result = @"iPhone";
            
        } else {
            
            result = @"OFF";
        }
        
    } else if ( settingState == 24 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"SwipeShiftCaret"] ) {
            
            result = @"ON";
            
        } else {
            
            result = @"OFF";
        }
        
    } else if ( settingState == 25 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"EnterBackgroundUSDisConnect"] ) {
            
            result = @"ON";
            
        } else {
            
            result = @"OFF";
        }
        
    } else if ( settingState == 26 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"BecomeActiveUSConnect"] ) {
            
            result = @"ON";
            
        } else {
            
            result = @"OFF";
        }
        
    } else if ( settingState == 27 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"ReloadAfterUSConnect"] ) {
            
            result = @"ON";
            
        } else {
            
            result = @"OFF";
        }
        
        //    } else if ( settingState == 29 ) {
        
    } else if ( settingState == 29 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"MyTweetNG"] ) {
            
            result = @"ON";
            
        } else {
            
            result = @"OFF";
        }
        
    } else if ( settingState == 30 ) {
        
        if ( [USER_DEFAULTS integerForKey:@"IconCornerRounding"] == 1 ) {
            
            result = @"ON";
            
        } else {
            
            result = @"OFF";
        }
        
    } else if ( settingState == 31 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"USNoAutoLock"] ) {
            
            result = @"ON";
            
        } else {
            
            result = @"OFF";
        }
        
    } else if ( settingState == 32 ) {
        
        result = [USER_DEFAULTS objectForKey:@"TimelineLoadCount"];
        
    } else if ( settingState == 33 ) {
        
        result = [USER_DEFAULTS objectForKey:@"MentionsLoadCount"];
        
    } else if ( settingState == 34 ) {
        
        result = [USER_DEFAULTS objectForKey:@"FavoritesLoadCount"];
        
    } else if ( settingState == 35 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"TimelineFirstLoad"] ) {
            
            result = @"最下部";
            
        } else {
            
            result = @"最上部";
        }
        
    } else if ( settingState == 36 ) {
        if ( [USER_DEFAULTS integerForKey:@"TimelineIconAction"] == 0 ) {
            result = @"UserMenu";
        } else if ( [USER_DEFAULTS integerForKey:@"TimelineIconAction"] == 1 ) {
            result = @"Reply";
        } else if ( [USER_DEFAULTS integerForKey:@"TimelineIconAction"] == 2 ) {
            result = @"Favorite／UnFavorite";
        } else if ( [USER_DEFAULTS integerForKey:@"TimelineIconAction"] == 3 ) {
            result = @"ReTweet";
        } else if ( [USER_DEFAULTS integerForKey:@"TimelineIconAction"] == 4 ) {
            result = @"Fav+RT";
        } else if ( [USER_DEFAULTS integerForKey:@"TimelineIconAction"] == 5 ) {
            result = @"IDとFav,RTを選択";
        }
        
    } else if ( settingState == 37 ) {
        
        if ( [USER_DEFAULTS boolForKey:@"UseTimelineList"] ) {
            result = @"ON";
        } else {
            result = @"OFF";
        }
        
    } else if ( settingState == 38 ) {
        
        result = [[USER_DEFAULTS objectForKey:@"TimelineList"] objectForKey:[TWAccounts currentAccountName]];
        
    } else if ( settingState == 39 ) {
        
        result = [USER_DEFAULTS objectForKey:@"IconQuality"];
    }
    
    return result;
}

/* TableView必須メソッド */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //NSLog(@"numberOfRowsInSection: %d", section);
    
    //各セクションの要素数を返す
    switch ( section ) {
		case 0:
			return SECTION_0;
            
		case 1:
			return SECTION_1;
            
        case 2:
			return SECTION_2;
            
        case 3:
			return SECTION_3;
            
        case 4:
			return SECTION_4;
	}
    
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	////NSLog(@"CreateCell");
    
	//TableViewCellを生成
	static NSString *identifier = @"TableViewCell";
	TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	cell.numberLabel.textColor = [UIColor blackColor];
	cell.textLabel.textColor = [UIColor blackColor];
    
	if (cell == nil) {
        
		TableViewCellController *controller = [[TableViewCellController alloc] initWithNibName:identifier bundle:nil];
		cell = (TableViewCell *)controller.view;
		[controller autorelease];
	}
    
    //セルのラベルサイズを設定
    cell.numberLabel.frame =    CGRectMake(  5, 0, 200, 44);
    cell.textLabel.frame =      CGRectMake(215, 0,  90, 44);
    
    //テキストをセット
    NSString *settingName = BLANK;
    int settingState = 0;
    
    if ( indexPath.section == 0 ) {
        settingState = indexPath.row;
    } else if ( indexPath.section == 1 ) {
        settingState = indexPath.row + SECTION_0;
    } else if ( indexPath.section == 2 ) {
        settingState = indexPath.row + SECTION_0 + SECTION_1;
    } else if ( indexPath.section == 3 ) {
        settingState = indexPath.row + SECTION_0 + SECTION_1 + SECTION_2;
    } else if ( indexPath.section == 4 ) {
        settingState = indexPath.row + SECTION_0 + SECTION_1 + SECTION_2 + SECTION_3;
    }
    
    settingName = [settingArray objectAtIndex:settingState];
    
    cell.numberLabel.text = settingName;
    cell.textLabel.text = [self getSettingState:settingState];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルの選択状態を解除
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    actionSheetNo = indexPath.row;
    
    UIActionSheet *sheet;
    
    if ( indexPath.section == 0 ) {
        
        if ( indexPath.row == 0 ) {
            
            //画像投稿時リサイズを行う
            sheet = [[UIActionSheet alloc]
                     initWithTitle:IMAGE_RESIZE
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 1 ) {
            
            //リサイズ最大長辺
            sheet = [[UIActionSheet alloc]
                     initWithTitle:IMAGE_RESIZE_MAX
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"320", @"640", @"800", @"960",@"1280", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 2 ) {
            
            //画像形式
            sheet = [[UIActionSheet alloc]
                     initWithTitle:IMAGE_FORMAT
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"JPG(Low)", @"JPG", @"JPG(High)", @"PNG", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 3 ) {
            
            //Retina解像度画像もリサイズを行う
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NO_RESIZE_RETINA
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 4 ) {
            
            //画像投稿先
            sheet = [[UIActionSheet alloc]
                     initWithTitle:IMAGE_SERVICE
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"Twitter", @"img.ur(複数枚投稿可)",
                     @"Twitpic(複数枚投稿可)", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 5 ) {
            
            //画像ソース
            sheet = [[UIActionSheet alloc]
                     initWithTitle:IMAGE_SOURCE
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"カメラロール", @"カメラ", @"投稿時選択", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 6 ) {
            
            //連続投稿確認表示
            sheet = [[UIActionSheet alloc]
                     initWithTitle:IMAGE_REPEATED
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 7 ) {
            
            //画像共有サービスフルサイズ取得
            sheet = [[UIActionSheet alloc]
                     initWithTitle:IMAGE_GET_FULL
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 8 ) {
            
            //NowPlaying画像投稿先
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NOWPLAYING_IMAGE
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"通常と同じ", @"Twitter", @"img.ur", @"Twitpic", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        }
        
    } else if ( indexPath.section == 1 ) {
        
        actionSheetNo = actionSheetNo + SECTION_0;
        
        if ( indexPath.row == 0 ) {
            
            //NowPlayingにカスタム書式を使用
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NOWPLAYING_CUSTOM
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 1 ) {
            
            //カスタム書式を編集
            alertTextNo = 0;
            
            NSString *message = @"\n曲名[st] アーティスト名[ar]\nアルバム名[at] 再生数[pc] レート[rt]";
            NSString *alertMessage = BLANK;
            
            if ( [EmptyCheck check:[USER_DEFAULTS objectForKey:@"NowPlayingEditText"]] ) {
                alertMessage = [USER_DEFAULTS objectForKey:@"NowPlayingEditText"];
            }
            
            alert = [[UIAlertView alloc] initWithTitle:NOWPLAYING_CUSTOM_EDIT
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:@"キャンセル"
                                     otherButtonTitles:@"確定", nil];
            
            alertText = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
            [alertText setBackgroundColor:[UIColor whiteColor]];
            alertText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            alertText.delegate = self;
            alertText.text = alertMessage;
            
            [alert addSubview:alertText];
            [alert show];
            [alert release];
            [alertText becomeFirstResponder];
            [alertText release];
            
            return;
            
        } else if ( indexPath.row == 2 ) {
            
            //曲名とアルバム名が同じな場合サブ書式を使用
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NOWPLAYING_DUPLICATE_NAME
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"OFF", @"ON(前方一致)", @"ON(完全一致)", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 3 ) {
            
            //サブ書式を編集
            alertTextNo = 1;
            
            NSString *message = @"\n曲名[st] アーティスト名[ar]\nアルバム名[at] 再生数[pc] レート[rt]";
            NSString *alertMessage = BLANK;
            
            if ( [EmptyCheck check:[USER_DEFAULTS objectForKey:@"NowPlayingEditTextSub"]] ) {
                alertMessage = [USER_DEFAULTS objectForKey:@"NowPlayingEditTextSub"];
            }
            
            alert = [[UIAlertView alloc] initWithTitle:NOWPLAYING_SUB_STYLE
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:@"キャンセル"
                                     otherButtonTitles:@"確定", nil];
            
            alertText = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
            [alertText setBackgroundColor:[UIColor whiteColor]];
            alertText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            alertText.delegate = self;
            alertText.text = alertMessage;
            
            [alert addSubview:alertText];
            [alert show];
            [alert release];
            [alertText becomeFirstResponder];
            [alertText release];
            
            return;
            
        } else if ( indexPath.row == 4 ) {
            
            //NowPlaying時にアートワークを投稿
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NOWPLAYING_ARTWORK
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 5 ) {
            
            //とは検索
            sheet = [[UIActionSheet alloc]
                     initWithTitle:TOHA_SEARCH
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 6 ) {
            
            //Webページ投稿書式変更
            alertTextNo = 2;
            
            NSString *message = @"\nタイトル[title] URL[url]";
            NSString *alertMessage = BLANK;
            
            if ( [EmptyCheck check:[USER_DEFAULTS objectForKey:@"WebPagePostFormat"]] ) {
                
                alertMessage = [USER_DEFAULTS objectForKey:@"WebPagePostFormat"];
                
            } else {
                
                alertMessage = @" \"[title]\" [url] ";
                [USER_DEFAULTS setObject:alertMessage forKey:@"WebPagePostFormat"];
            }
            
            alert = [[UIAlertView alloc] initWithTitle:WEB_PAGE_SHARE_STYLE
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:@"キャンセル"
                                     otherButtonTitles:@"確定", nil];
            
            alertText = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
            [alertText setBackgroundColor:[UIColor whiteColor]];
            alertText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            alertText.delegate = self;
            alertText.text = alertMessage;
            
            [alert addSubview:alertText];
            [alert show];
            [alert release];
            [alertText becomeFirstResponder];
            [alertText release];
            
            return;
            
        } else if ( indexPath.row == 7 ) {
            
            //Webページ投稿書式セット後カーソル位置
            sheet = [[UIActionSheet alloc]
                     initWithTitle:WEB_PAGE_SHARE_CURSOR
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"先頭", @"末尾", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 8 ) {
            
            //引用投稿書式変更
            alertTextNo = 3;
            
            NSString *message = @"\nタイトル[title] URL[url] 引用[quote]";
            NSString *alertMessage = BLANK;
            
            if ( [EmptyCheck check:[USER_DEFAULTS objectForKey:@"QuoteFormat"]] ) {
                
                alertMessage = [USER_DEFAULTS objectForKey:@"QuoteFormat"];
                
            } else {
                
                alertMessage = @" \"[title]\" [url] >>[quote]";
                [USER_DEFAULTS setObject:alertMessage forKey:@"QuoteFormat"];
            }
            
            alert = [[UIAlertView alloc] initWithTitle:WEB_PAGE_QUOTE_STYLE
                                               message:message
                                              delegate:self
                                     cancelButtonTitle:@"キャンセル"
                                     otherButtonTitles:@"確定", nil];
            
            alertText = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
            [alertText setBackgroundColor:[UIColor whiteColor]];
            alertText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            alertText.delegate = self;
            alertText.text = alertMessage;
            
            [alert addSubview:alertText];
            [alert show];
            [alert release];
            [alertText becomeFirstResponder];
            [alertText release];
            
            return;
            
        } else if ( indexPath.row == 9 ) {
            
            //引用投稿書式セット後カーソル位置
            sheet = [[UIActionSheet alloc]
                     initWithTitle:WEB_PAGE_QUOTE_CURSOR
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"先頭", @"末尾", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        }
        
    } else if ( indexPath.section == 2 ) {
        
        actionSheetNo = actionSheetNo + SECTION_0 + SECTION_1;
        
        if ( indexPath.row == 0 ) {
            
            //アプリがアクティブになった際入力可能状態にする
            sheet = [[UIActionSheet alloc]
                     initWithTitle:ACTIVE_INPUT
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 1 ) {
            
            //ブラウザの検索ワードを毎回リセット
            sheet = [[UIActionSheet alloc]
                     initWithTitle:SEARCH_WORD_RESET
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 2 ) {
            
            //ブラウザを開く時ペーストボード内のURLを開く
            sheet = [[UIActionSheet alloc]
                     initWithTitle:PASTE_BOARD_URL
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 3 ) {
            
            //ブラウザユーザーエージェント
            sheet = [[UIActionSheet alloc]
                     initWithTitle:USER_AGENT
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"FireFox", @"iPad", @"iPhone", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 4 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:USER_AGENT_RESET
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"OFF", @"FireFox", @"iPad", @"iPhone", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 5 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:SWIPE_SHIFT_CARET
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        }
        
    } else if ( indexPath.section == 3 ) {
        
        actionSheetNo = actionSheetNo + SECTION_0 + SECTION_1 + SECTION_2;
        
        if ( indexPath.row == 0 ) {
            
            //バックグラウンドに移行時UserStreamを切断
            sheet = [[UIActionSheet alloc]
                     initWithTitle:ENTER_BACKGROUND_US
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 1 ) {
            
            //バックグラウンドから復帰時UserStreamに接続
            sheet = [[UIActionSheet alloc]
                     initWithTitle:BECOME_ACTIVE_US
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 2 ) {
            
            //通常の更新後にUserStreamに接続
            sheet = [[UIActionSheet alloc]
                     initWithTitle:RELOAD_US
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 3 ) {
            
            //NG設定を開く
            NGSettingViewController *dialog = [[[NGSettingViewController alloc] init] autorelease];
            dialog.title = @"NG Settings";
            [self.navigationController pushViewController:dialog animated:YES];
            
        } else if ( indexPath.row == 4 ) {
            
            //自分のTweetもNGを行う
            sheet = [[UIActionSheet alloc]
                     initWithTitle:MY_TWEET_NG
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 5 ) {
            
            //アイコンの角を丸める
            sheet = [[UIActionSheet alloc]
                     initWithTitle:ICON_CORNER
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"OFF", @"ON", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 6 ) {
            
            //UserStream接続中は自動ロックを無効化する
            sheet = [[UIActionSheet alloc]
                     initWithTitle:US_NO_AUTO_LOCK
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 7 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:TIMELINE_LOAD
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"200", @"160", @"120", @"80", @"40", @"20", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 8 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:MENTIONS_LOAD
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"200", @"160", @"120", @"80", @"40", @"20", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 9 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:FAVORITES_LOAD
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"200", @"160", @"120", @"80", @"40", @"20", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 10 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:TIMELINE_FIRSTLOAD
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"最上部", @"最下部", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 11 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:TIMELINE_ICON_ACTION
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"UserMenu", @"Reply", @"Favorite／UnFavorite", @"ReTweet", @"Fav+RT", @"IDとFav,RTを選択", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 12 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:TIMELINE_LIST
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        } else if ( indexPath.row == 13 ) {
            
            [self setListSelectMode:YES];
            
            ListViewController *dialog = [[[ListViewController alloc] initWithListSelectMode:YES] autorelease];
            dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self showModalViewController:dialog];
            
        } else if ( indexPath.row == 14 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:ICON_QUALITY
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"Mini (24x24)", @"Normal (48x48)", @"Bigger (73x73)", @"Original", @"Original (96x96)", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        }
        
    } else if ( indexPath.section == 4 ) {
        
        if ( indexPath.row == 0 ) {
            
            LicenseViewController *dialog = [[[LicenseViewController alloc] init] autorelease];
            dialog.title = @"License";
            [self.navigationController pushViewController:dialog animated:YES];
            
        } else if ( indexPath.row == 1 ) {
            
            SpecialThanksViewController *dialog = [[[SpecialThanksViewController alloc] init] autorelease];
            dialog.title = @"SpecialThanks";
            [self.navigationController pushViewController:dialog animated:YES];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //確定が押された
    if ( alertTextNo == 0 ) {
        
        if (buttonIndex == 1) {
            
            //カスタム書式を保存
            [USER_DEFAULTS setObject:alertText.text forKey:@"NowPlayingEditText"];
        }
        
    } else if ( alertTextNo == 1 ) {
        
        //サブ書式を保存
        [USER_DEFAULTS setObject:alertText.text forKey:@"NowPlayingEditTextSub"];
        
    } else if ( alertTextNo == 2 ) {
        
        //Webページ投稿書式を保存
        [USER_DEFAULTS setObject:alertText.text forKey:@"WebPagePostFormat"];
        
    } else if ( alertTextNo == 3 ) {
        
        //引用投稿書式を保存
        [USER_DEFAULTS setObject:alertText.text forKey:@"QuoteFormat"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    
    //NSLog(@"Textfield Enter: %@", sender.text);
    
    if ( alertTextNo == 0 ) {
        
        //カスタム書式を保存
        [USER_DEFAULTS setObject:alertText.text forKey:@"NowPlayingEditText"];
        
    } else if ( alertTextNo == 1 ) {
        
        //サブ書式を保存
        [USER_DEFAULTS setObject:alertText.text forKey:@"NowPlayingEditTextSub"];
        
    } else if ( alertTextNo == 2 ) {
        
        //Webページ投稿書式を保存
        [USER_DEFAULTS setObject:alertText.text forKey:@"WebPagePostFormat"];
        
    } else if ( alertTextNo == 3 ) {
        
        //引用投稿書式を保存
        [USER_DEFAULTS setObject:alertText.text forKey:@"QuoteFormat"];
    }
    
    //キーボードを閉じる
    [sender resignFirstResponder];
    
    //アラートを閉じる
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //NSLog(@"actionSheet: %d, buttonIndex: %d", actionSheetNo, buttonIndex);
    
    if ( actionSheetNo == 0 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:YES forKey:@"ResizeImage"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:NO forKey:@"ResizeImage"];
        }
        
    } else if ( actionSheetNo == 1 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setInteger:320 forKey:@"ImageMaxSize"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setInteger:640 forKey:@"ImageMaxSize"];
        } else if ( buttonIndex == 2 ) {
            [USER_DEFAULTS setInteger:800 forKey:@"ImageMaxSize"];
        } else if ( buttonIndex == 3 ) {
            [USER_DEFAULTS setInteger:960 forKey:@"ImageMaxSize"];
        } else if ( buttonIndex == 4 ) {
            [USER_DEFAULTS setInteger:1280 forKey:@"ImageMaxSize"];
        }
        
    } else if ( actionSheetNo == 2 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setObject:@"JPG(Low)" forKey:@"SaveImageType"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setObject:@"JPG" forKey:@"SaveImageType"];
        } else if ( buttonIndex == 2 ) {
            [USER_DEFAULTS setObject:@"JPG(High)" forKey:@"SaveImageType"];
        } else if ( buttonIndex == 3 ) {
            [USER_DEFAULTS setObject:@"PNG" forKey:@"SaveImageType"];
        }
        
    } else if ( actionSheetNo == 3 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:NO forKey:@"NoResizeIphone4Ss"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:YES forKey:@"NoResizeIphone4Ss"];
        }
        
    } else if ( actionSheetNo == 4 ) {
        
        if ( buttonIndex == 0 ) {
            
            [USER_DEFAULTS setObject:@"Twitter" forKey:@"PhotoService"];
            
            if ( [USER_DEFAULTS boolForKey:@"RepeatedPost"] ) {
                
                [ShowAlert error:@"Twitterへの画像投稿では連続投稿機能は使えません。"];
                
                [USER_DEFAULTS setBool:NO forKey:@"RepeatedPost"];
            }
            
        } else if ( buttonIndex == 1 ) {
            
            [USER_DEFAULTS setObject:@"img.ur" forKey:@"PhotoService"];
            
        } else if ( buttonIndex == 2 ) {
            
            NSDictionary *dic = [USER_DEFAULTS dictionaryForKey:@"OAuthAccount"];
            NSArray *oauthAccountNames = [dic allKeys];
            
            ACAccount *twAccount = [TWAccounts currentAccount];
            NSString *twitpicName = nil;
            
            for ( NSString *accountName in oauthAccountNames ) {
                if ( [accountName isEqualToString:twAccount.username] ) {
                    
                    twitpicName = accountName;
                    
                    break;
                }
            }
            
            if ( twitpicName == nil ) {
                
                [ShowAlert error:[NSString stringWithFormat:@"現在使用中のアカウント %@ のTwitpicアカウントが見つかりません。アカウントを登録してください", twAccount.username]];
                
                appDelegate.addTwitpicAccountName = twAccount.username;
                
                OAuthSetupViewController *dialog = [[[OAuthSetupViewController alloc] init] autorelease];
                dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                [self showModalViewController:dialog];
                
            } else {
                
                actionSheetNo = 100;
                
                UIActionSheet *sheet = [[UIActionSheet alloc]
                                        initWithTitle:@"Twitpicアカウントが見つかりました"
                                        delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                        otherButtonTitles:[NSString stringWithFormat:@"%@ を使用", twAccount.username],
                                        @"Twitpicアカウント登録", nil];
                [sheet autorelease];
                [sheet showInView:self.view];
            }
        }
        
    } else if ( actionSheetNo == 5 ) {
        
        //カメラが使われる可能性のある選択肢
        if ( buttonIndex != 0 ) {
            
            //端末がカメラを使えるか判定
            if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
                
                //カメラが利用できる場合
                
                if ( buttonIndex == 1 ) {
                    
                    [USER_DEFAULTS setInteger:1 forKey:@"ImageSource"];
                    
                    if ( [USER_DEFAULTS boolForKey:@"RepeatedPost"] ) {
                        
                        [USER_DEFAULTS setBool:NO forKey:@"RepeatedPost"];
                        
                        [ShowAlert error:@"カメラでは連続投稿が出来ません"];
                    }
                    
                } else if ( buttonIndex == 2 ) {
                    
                    [USER_DEFAULTS setInteger:2 forKey:@"ImageSource"];
                }
                
            } else {
                
                //カメラが利用できない場合
                [ShowAlert error:@"カメラが利用出来ない端末です。カメラロールが設定されます。"];
                
                [USER_DEFAULTS setInteger:0 forKey:@"ImageSource"];
            }
            
        } else {
            
            [USER_DEFAULTS setInteger:0 forKey:@"ImageSource"];
        }
        
        //連続投稿確認表示
    } else if ( actionSheetNo == 6 ) {
        if ( buttonIndex == 0 ) {
            
            [USER_DEFAULTS setBool:YES forKey:@"RepeatedPost"];
            
            if ( [[USER_DEFAULTS objectForKey:@"PhotoService"] isEqualToString:@"Twitter"] ) {
                
                [ShowAlert error:@"Twitterへの画像投稿では連続投稿機能は使えません。"];
                
                [USER_DEFAULTS setObject:@"img.ur" forKey:@"PhotoService"];
            }
            
            if ( [USER_DEFAULTS integerForKey:@"ImageSource"] == 1 ) {
                
                [ShowAlert error:@"カメラでは連続投稿が出来ません"];
                
                [USER_DEFAULTS setInteger:0 forKey:@"ImageSource"];
            }
            
        } else if ( buttonIndex == 1 ) {
            
            [USER_DEFAULTS setBool:NO forKey:@"RepeatedPost"];
        }
        
    } else if ( actionSheetNo == 7 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:YES forKey:@"FullSizeImage"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:NO forKey:@"FullSizeImage"];
        }
        
    } else if ( actionSheetNo == 8 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setInteger:0 forKey:@"NowPlayingPhotoService"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setInteger:1 forKey:@"NowPlayingPhotoService"];
        } else if ( buttonIndex == 2 ) {
            [USER_DEFAULTS setInteger:2 forKey:@"NowPlayingPhotoService"];
        } else if ( buttonIndex == 3 ) {
            [USER_DEFAULTS setInteger:3 forKey:@"NowPlayingPhotoService"];
        }
        
    } else if ( actionSheetNo == 9 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:YES forKey:@"NowPlayingEdit"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:NO forKey:@"NowPlayingEdit"];
        }
        
        //  } else if ( actionSheetNo == 10 ) {
        
    } else if ( actionSheetNo == 11 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setInteger:0 forKey:@"NowPlayingEditSub"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setInteger:1 forKey:@"NowPlayingEditSub"];
        } else if ( buttonIndex == 2 ) {
            [USER_DEFAULTS setInteger:2 forKey:@"NowPlayingEditSub"];
        }
        
        //  } else if ( actionSheetNo == 12 ) {
        
    } else if ( actionSheetNo == 13 ) {
        
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:YES forKey:@"NowPlayingArtWork"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:NO forKey:@"NowPlayingArtWork"];
        }
        
    } else if ( actionSheetNo == 14 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:YES forKey:@"TohaSearch"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:NO forKey:@"TohaSearch"];
        }
        
        //  } else if ( actionSheetNo == 15 ) {
        
    } else if ( actionSheetNo == 16 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:YES forKey:@"WebPagePostCursorPosition"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:NO forKey:@"WebPagePostCursorPosition"];
        }
        
        //  } else if ( actionSheetNo == 17 ) {
        
    } else if ( actionSheetNo == 18 ) {
        
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:YES forKey:@"QuoteCursorPosition"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:NO forKey:@"QuoteCursorPosition"];
        }
        
    } else if ( actionSheetNo == 19 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:YES forKey:@"ShowKeyboard"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:NO forKey:@"ShowKeyboard"];
        }
        
    } else if ( actionSheetNo == 20 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:YES forKey:@"ClearBrowserSearchField"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:NO forKey:@"ClearBrowserSearchField"];
        }
        
    } else if ( actionSheetNo == 21 ) {
        if ( buttonIndex == 0 ) {
            
            [USER_DEFAULTS setBool:YES forKey:@"OpenPasteBoardURL"];
            
            if ( ![EmptyCheck check:[USER_DEFAULTS objectForKey:@"LastOpendPasteBoardURL"]] ) {
                
                [USER_DEFAULTS setObject:BLANK forKey:@"LastOpendPasteBoardURL"];
            }
            
        } else if ( buttonIndex == 1 ) {
            
            [USER_DEFAULTS setBool:NO forKey:@"OpenPasteBoardURL"];
        }
        
    } else if ( actionSheetNo == 22 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setObject:@"FireFox" forKey:@"UserAgent"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setObject:@"iPad" forKey:@"UserAgent"];
        } else if ( buttonIndex == 2 ) {
            [USER_DEFAULTS setObject:@"iPhone" forKey:@"UserAgent"];
        }
        
    } else if ( actionSheetNo == 23 ) {
        
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setObject:@"OFF" forKey:@"UserAgentReset"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setObject:@"FireFox" forKey:@"UserAgentReset"];
        } else if ( buttonIndex == 2 ) {
            [USER_DEFAULTS setObject:@"iPad" forKey:@"UserAgentReset"];
        } else if ( buttonIndex == 3 ) {
            [USER_DEFAULTS setObject:@"iPhone" forKey:@"UserAgentReset"];
        }
        
    } else if ( actionSheetNo == 24 ) {
        
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:YES forKey:@"SwipeShiftCaret"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:NO forKey:@"SwipeShiftCaret"];
        }
        
    } else if ( actionSheetNo == 25 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:YES forKey:@"EnterBackgroundUSDisConnect"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:NO forKey:@"EnterBackgroundUSDisConnect"];
        }
        
    } else if ( actionSheetNo == 26 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:YES forKey:@"BecomeActiveUSConnect"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:NO forKey:@"BecomeActiveUSConnect"];
        }
        
    } else if ( actionSheetNo == 27 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:YES forKey:@"ReloadAfterUSConnect"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:NO forKey:@"ReloadAfterUSConnect"];
        }
        
        //    } else if ( actionSheetNo == 29 ) {
        
    } else if ( actionSheetNo == 29 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:YES forKey:@"MyTweetNG"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:NO forKey:@"MyTweetNG"];
        }
        
    } else if ( actionSheetNo == 30 ) {
        
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setInteger:2 forKey:@"IconCornerRounding"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setInteger:1 forKey:@"IconCornerRounding"];
        }
        
        [ShowAlert title:@"設定変更完了" message:@"設定を有効にするにはアプリケーションを再起動してください。"];
        
    } else if ( actionSheetNo == 31 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:YES forKey:@"USNoAutoLock"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:NO forKey:@"USNoAutoLock"];
        }
        
    } else if ( actionSheetNo == 32 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setObject:@"200" forKey:@"TimelineLoadCount"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setObject:@"160" forKey:@"TimelineLoadCount"];
        } else if ( buttonIndex == 2 ) {
            [USER_DEFAULTS setObject:@"120" forKey:@"TimelineLoadCount"];
        } else if ( buttonIndex == 3 ) {
            [USER_DEFAULTS setObject:@"80" forKey:@"TimelineLoadCount"];
        } else if ( buttonIndex == 4 ) {
            [USER_DEFAULTS setObject:@"40" forKey:@"TimelineLoadCount"];
        } else if ( buttonIndex == 5 ) {
            [USER_DEFAULTS setObject:@"20" forKey:@"TimelineLoadCount"];
        }
        
    } else if ( actionSheetNo == 33 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setObject:@"200" forKey:@"MentionsLoadCount"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setObject:@"160" forKey:@"MentionsLoadCount"];
        } else if ( buttonIndex == 2 ) {
            [USER_DEFAULTS setObject:@"120" forKey:@"MentionsLoadCount"];
        } else if ( buttonIndex == 3 ) {
            [USER_DEFAULTS setObject:@"80" forKey:@"MentionsLoadCount"];
        } else if ( buttonIndex == 4 ) {
            [USER_DEFAULTS setObject:@"40" forKey:@"MentionsLoadCount"];
        } else if ( buttonIndex == 5 ) {
            [USER_DEFAULTS setObject:@"20" forKey:@"MentionsLoadCount"];
        }
        
    } else if ( actionSheetNo == 34 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setObject:@"200" forKey:@"FavoritesLoadCount"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setObject:@"160" forKey:@"FavoritesLoadCount"];
        } else if ( buttonIndex == 2 ) {
            [USER_DEFAULTS setObject:@"120" forKey:@"FavoritesLoadCount"];
        } else if ( buttonIndex == 3 ) {
            [USER_DEFAULTS setObject:@"80" forKey:@"FavoritesLoadCount"];
        } else if ( buttonIndex == 4 ) {
            [USER_DEFAULTS setObject:@"40" forKey:@"FavoritesLoadCount"];
        } else if ( buttonIndex == 5 ) {
            [USER_DEFAULTS setObject:@"20" forKey:@"FavoritesLoadCount"];
        }
        
    } else if ( actionSheetNo == 35 ) {
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:NO forKey:@"TimelineFirstLoad"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:YES forKey:@"TimelineFirstLoad"];
        }
        
    } else if ( actionSheetNo == 36 ) {
        
        if ( buttonIndex != 6 ) {
            
            [USER_DEFAULTS setInteger:buttonIndex forKey:@"TimelineIconAction"];
        }
        
    } else if ( actionSheetNo == 37 ) {
        
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setBool:YES forKey:@"UseTimelineList"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setBool:NO forKey:@"UseTimelineList"];
        }
        
    } else if ( actionSheetNo == 39 ) {
        
        if ( buttonIndex == 0 ) {
            [USER_DEFAULTS setObject:@"Mini" forKey:@"IconQuality"];
        } else if ( buttonIndex == 1 ) {
            [USER_DEFAULTS setObject:@"Normal" forKey:@"IconQuality"];
        } else if ( buttonIndex == 2 ) {
            [USER_DEFAULTS setObject:@"Bigger" forKey:@"IconQuality"];
        } else if ( buttonIndex == 3 ) {
            [USER_DEFAULTS setObject:@"Original" forKey:@"IconQuality"];
        } else if ( buttonIndex == 4 ) {
            [USER_DEFAULTS setObject:@"Original96" forKey:@"IconQuality"];
        }
        
    } else if ( actionSheetNo == 100 ) {
        if ( buttonIndex == 0 ) {
            
            [USER_DEFAULTS setObject:@"Twitpic" forKey:@"PhotoService"];
            
        } else if ( buttonIndex == 1 ) {
            
            OAuthSetupViewController *dialog = [[[OAuthSetupViewController alloc] init] autorelease];
            dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self showModalViewController:dialog];
        }
    }
    
    //設定項目の表示を更新
    [tv reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    //NSLog(@"titleForHeaderInSection");
    
    //セクションのタイトルを決定
    switch ( section ) {
            
        case 0:
            return @"画像関連設定";
            
        case 1:
            return @"投稿関連設定";
            
        case 2:
            return @"その他の設定";
            
        case 3:
            return @"タイムライン設定";
            
        case 4:
            return BLANK;
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //NSLog(@"numberOfSectionsInTableView");
    
    //セクションの数を設定
	return SECTION_COUNT;
}

/* TableView必須メソッドここまで */

- (void)viewDidUnload {
    
    [self setTv:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotate {
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    
    //NSLog(@"SettingView dealloc");
    
    [settingArray release];
    
    appDelegate = nil;
    
    [self.view removeAllSubViews];
    
    [super dealloc];
}

@end
