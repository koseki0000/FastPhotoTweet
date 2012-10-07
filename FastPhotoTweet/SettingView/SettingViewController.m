//
//  SettingViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "SettingViewController.h"

//セクション数
#define SECTION_COUNT 5
//セクション0の項目数 (画像関連設定)
#define SECTION_0 9
//セクション1の項目数 (投稿関連設定)
#define SECTION_1 13
//セクション2の項目数 (その他の設定)
#define SECTION_2 5
//セクション2の項目数 (タイムライン設定)
#define SECTION_3 6

//セクション3の項目数 (ライセンス)
#define SECTION_4 1

//設定項目名
//画像関連設定
#define NAME_0  @"画像投稿時リサイズを行う"
#define NAME_1  @"リサイズ最大長辺"
#define NAME_2  @"画像形式"
#define NAME_3  @"Retina解像度画像もリサイズを行う"
#define NAME_4  @"画像投稿先"
#define NAME_5  @"画像ソース"
#define NAME_6  @"連続投稿確認表示"
#define NAME_7  @"画像共有サービスフルサイズ取得"
#define NAME_8  @"NowPlaying画像投稿先"
//投稿関連設定
#define NAME_9  @"NowPlaying時はFastTweetを行う"
#define NAME_10 @"NowPlaying時はCallBackを行う"
#define NAME_11 @"NowPlayingにカスタム書式を使用"
#define NAME_12 @"カスタム書式を編集"
#define NAME_13 @"曲名とアルバム名が同じな場合サブ書式を使用"
#define NAME_14 @"サブ書式を編集"
#define NAME_15 @"NowPlaying時にアートワークを投稿"
#define NAME_16 @"とは検索機能を使用"
#define NAME_17 @"Webページ投稿書式変更"
#define NAME_18 @"Webページ投稿書式セット後カーソル位置"
#define NAME_19 @"引用投稿書式変更"
#define NAME_20 @"引用投稿書式セット後カーソル位置"
#define NAME_21 @"投稿後アプリ切替"

//その他の設定
#define NAME_22 @"アプリがアクティブになった際入力可能状態にする"
#define NAME_23 @"ブラウザの検索ワードを毎回リセット"
#define NAME_24 @"ブラウザを開く時ペーストボード内のURLを開く"
#define NAME_25 @"ブラウザユーザーエージェント"
#define NAME_26 @"ブラウザを閉じる時にユーザーエージェントを戻す"
//タイムライン設定
#define NAME_27 @"バックグラウンドに移行時UserStreamを切断"
#define NAME_28 @"バックグラウンドから復帰時UserStreamに接続"
#define NAME_29 @"通常の更新後にUserStreamに接続"
#define NAME_30 @"NG設定を開く"
#define NAME_31 @"自分のTweetもNGを行う"
#define NAME_32 @"アイコンの角を丸める"

//ライセンス
#define NAME_LICENSE @"ライセンス"

#define BLANK @""

@implementation SettingViewController
@synthesize tv;
@synthesize bar;
@synthesize saveButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    //初期化処理
    if ( self ) {

        //NSLog(@"SettingView init");
        
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        d = [NSUserDefaults standardUserDefaults];
        actionSheetNo = 0;
        alertTextNo = 0;
        
        appDelegate.twitpicLinkMode = NO;
        appDelegate.addTwitpicAccountName = BLANK;
        
        //設定項目名を持った可変長配列を生成
        settingArray = [NSMutableArray arrayWithObjects:NAME_0,  NAME_1,  NAME_2,  NAME_3, 
                                                        NAME_4,  NAME_5,  NAME_6,  NAME_7, 
                                                        NAME_8,  NAME_9,  NAME_10, NAME_11, 
                                                        NAME_12, NAME_13, NAME_14, NAME_15, 
                                                        NAME_16, NAME_17, NAME_18, NAME_19, 
                                                        NAME_20, NAME_21, NAME_22, NAME_23,
                                                        NAME_24, NAME_25, NAME_26, NAME_27, 
                                                        NAME_28, NAME_29, NAME_30, NAME_31,
                                                        NAME_32, NAME_LICENSE, nil];
        
        [settingArray retain];
    }
    
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    //NSLog(@"viewDidAppear");
    
    if ( [[d objectForKey:@"OAuthRequestTokenKey"] isEqualToString:BLANK] || 
         [[d objectForKey:@"OAuthRequestTokenSecret"] isEqualToString:BLANK] ||
         [d integerForKey:@"AccountCount"] == 0 ) {
        
        [d setObject:@"Twitter" forKey:@"PhotoService"];
    }
    
    if ( appDelegate.twitpicLinkMode ) {
        
        //NSLog(@"TwitPic Link");
        
        if ( [EmptyCheck check:appDelegate.addTwitpicAccountName] ) {
            
            appDelegate.twitpicLinkMode = NO;
            
            //仮登録された情報の名前を生成
            NSString *searchAccountName = [NSString stringWithFormat:@"OAuthAccount_%d", [d integerForKey:@"AccountCount"]];
            
            //NSLog(@"searchAccountName: %@", searchAccountName);
            
            //設定からアカウントリストを読み込む
            NSMutableDictionary *dic = [[d dictionaryForKey:@"OAuthAccount"] mutableCopy];
            
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
            [d setObject:saveDic forKey:@"OAuthAccount"];
            [saveDic release];
            [dic release];
            
            [d setObject:@"Twitpic" forKey:@"PhotoService"];
            appDelegate.addTwitpicAccountName = BLANK;
            appDelegate.needChangeAccount = YES;
            
            //NSLog(@"OAuthAccount: %@", [d dictionaryForKey:@"OAuthAccount"]);
            
        }else {
            
            IDChangeViewController *dialog = [[[IDChangeViewController alloc] init] autorelease];
            dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentModalViewController:dialog animated:YES];
        }
    }
    
    //設定項目の表示を更新
    [tv reloadData];
}

- (IBAction)pushDoneButton:(id)sender {
    
    //NSLog(@"pushDoneButton");
    
    //閉じる
    [self dismissModalViewControllerAnimated:YES];
}

- (NSString *)getSettingState:(int)settingState {
    
    //NSLog(@"getSettingState: %d", index);
    
    NSString *result = BLANK;
    
    //画像投稿時リサイズを行う
    if ( settingState == 0 ) {
        
        if ( [d boolForKey:@"ResizeImage"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
        
    //リサイズ最大長辺
    }else if ( settingState == 1 ) {
        
        result = [NSString stringWithFormat:@"%d", [d integerForKey:@"ImageMaxSize"]];
        
    //画像形式
    }else if ( settingState == 2 ) {
        
        result = [NSString stringWithFormat:@"%@", [d objectForKey:@"SaveImageType"]];;
    
    //Retina解像度画像もリサイズを行う
    }else if ( settingState == 3 ) {
        
        if ( [d boolForKey:@"NoResizeIphone4Ss"] ) {
            
            result = @"OFF";
            
        }else {
            
            result = @"ON";
        }
        
    //画像投稿先
    }else if ( settingState == 4 ) {
        
        result = [NSString stringWithFormat:@"%@", [d objectForKey:@"PhotoService"]];
        
    //画像ソース
    }else if ( settingState == 5 ) {    
        
        if ( [d integerForKey:@"ImageSource"] == 0 ) {
            
            result = @"カメラロール";
            
        }else if ( [d integerForKey:@"ImageSource"] == 1 ) {
            
            result = @"カメラ";
            
        }else if ( [d integerForKey:@"ImageSource"] == 2 ) {
            
            result = @"投稿時選択";
        }
    
    //連続投稿確認表示
    }else if ( settingState == 6 ) {    
        
        if ( [d boolForKey:@"RepeatedPost"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
    
    //画像共有サービスフルサイズ取得
    }else if ( settingState == 7 ) {
        
        if ( [d boolForKey:@"FullSizeImage"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
    
    //NowPlaying画像投稿先
    }else if ( settingState == 8 ) {    
    
        if ( [d integerForKey:@"NowPlayingPhotoService"] == 0 ) {
            
            result = @"通常と同じ";
            
        }else if ( [d integerForKey:@"NowPlayingPhotoService"] == 1 ) {
        
            result = @"Twitter";
            
        }else if ( [d integerForKey:@"NowPlayingPhotoService"] == 2 ) {
        
            result = @"img.ur";
            
        }else if ( [d integerForKey:@"NowPlayingPhotoService"] == 3 ) {
        
            result = @"Twitpic";
        }
        
    //NowPlaying時はFastPostを行う
    }else if ( settingState == 9 ) {
        
        if ( [d boolForKey:@"NowPlayingFastPost"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
        
    //NowPlaying時はCallBackを行う
    }else if ( settingState == 10 ) {
        
        if ( [d boolForKey:@"NowPlayingCallBack"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
        
    //NowPlayingにカスタム書式を使用
    }else if ( settingState == 11 ) {
        
        if ( [d boolForKey:@"NowPlayingEdit"] ) {
            
            result = @"OFF";
            
        }else {
            
            result = @"ON";
        }
        
    //カスタム書式を編集
    }else if ( settingState == 12 ) {
        
        //空のまま
        
    //曲名とアルバム名が同じな場合サブ書式を使用
    }else if ( settingState == 13 ) {
        
        if ( [d integerForKey:@"NowPlayingEditSub"] == 0 ) {
            
            result = @"OFF";
            
        }else if ( [d integerForKey:@"NowPlayingEditSub"] == 1 ) {
            
            result = @"ON\n(前方一致)";
        
        }else if ( [d integerForKey:@"NowPlayingEditSub"] == 2 ) {    
            
            result = @"ON\n(完全一致)";
        }
        
    //サブ書式を編集
    }else if ( settingState == 14 ) {
        
        //空のまま
    
    //NowPlaying時にアートワークを投稿
    }else if ( settingState == 15 ) {    
        
        if ( [d boolForKey:@"NowPlayingArtWork"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
    
    //とは検索
    }else if ( settingState == 16 ) {
        
        if ( [d boolForKey:@"TohaSearch"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
    
    //Webページ投稿書式変更
    }else if ( settingState == 17 ) {
    
    //Webページ投稿書式セット後カーソル位置
    }else if ( settingState == 18 ) {
        
        if ( [d boolForKey:@"WebPagePostCursorPosition"] ) {
            
            result = @"先頭";
            
        }else {
            
            result = @"末尾";
        }
    
//  }else if ( settingState == 19 ) {
        
    }else if ( settingState == 20 ) {
        
        if ( [d boolForKey:@"QuoteCursorPosition"] ) {
            
            result = @"先頭";
            
        }else {
            
            result = @"末尾";
        }
        
    //投稿後アプリ切替
    }else if ( settingState == 21 ) {
        
        NSString *scheme = [d objectForKey:@"CallBackScheme"];
        
        if ( [scheme isEqualToString:@"FPT"] ) {
            
            result = @"FastPhotoTweet";
            
        }else if ( [scheme isEqualToString:@"twitter://"] ) {
            
            result = @"Twitter for iPhone";
            
        }else if ( [scheme isEqualToString:@"tweetbot://"] ) {
            
            result = @"Tweetbot";
            
        }else if ( [scheme isEqualToString:@"echofon://?"] ) {
            
            result = @"Echofon";
            
        }else if ( [scheme isEqualToString:@"echofonpro://?"] ) {
            
            result = @"Echofon Pro";
            
        }else if ( [scheme isEqualToString:@"soicha://"] ) {
            
            result = @"SOICHA";
            
        }else if ( [scheme isEqualToString:@"tweetings://"] ) {
            
            result = @"Tweetings";
            
        }else if ( [scheme isEqualToString:@"osfoora://"] ) {
            
            result = @"Osfoora";
            
        }else if ( [scheme isEqualToString:@"twittelator://"] ) {
            
            result = @"Twittelator";
            
        }else if ( [scheme isEqualToString:@"tweetlist://"] ) {
            
            result = @"TweetList!";
            
        }else if ( [scheme isEqualToString:@"tweetatok://"] ) {
            
            result = @"Tweet ATOK";
            
        }else if ( [scheme isEqualToString:@"tweetlogix://"] ) {
            
            result = @"Tweetlogix";
            
        }else if ( [scheme isEqualToString:@"hootsuite://"] ) {
            
            result = @"HootSuite";
            
        }else if ( [scheme isEqualToString:@"simplytweet://"] ) {
            
            result = @"SimplyTweet";
            
        }else if ( [scheme isEqualToString:@"reeder://"] ) {
            
            result = @"Reeder";
            
        }else {
            
            result = @"未選択";
        }
        
    //アプリがアクティブになった際入力可能状態にする
    }else if ( settingState == 22 ) {
        
        if ( [d boolForKey:@"ShowKeyboard"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
    
    }else if ( settingState == 23 ) {
        
        if ( [d boolForKey:@"ClearBrowserSearchField"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
    
    }else if ( settingState == 24 ) {
        
        if ( [d boolForKey:@"OpenPasteBoardURL"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
    
    }else if ( settingState == 25 ) {

        if ( [[d objectForKey:@"UserAgent"] isEqualToString:@"FireFox"] ) {
            
            result = @"FireFox";
            
        }else if ( [[d objectForKey:@"UserAgent"] isEqualToString:@"iPad"] ) {
        
            result = @"iPad";
            
        }else {
            
            result = @"iPhone";
        }
    
    }else if ( settingState == 26 ) {
        
        if ( [[d objectForKey:@"UserAgentReset"] isEqualToString:@"FireFox"] ) {
            
            result = @"FireFox";
            
        }else if ( [[d objectForKey:@"UserAgentReset"] isEqualToString:@"iPad"] ) {
            
            result = @"iPad";
            
        }else if ( [[d objectForKey:@"UserAgentReset"] isEqualToString:@"iPhone"] ) {
            
            result = @"iPhone";
            
        }else {
            
            result = @"OFF";
        }
        
    }else if ( settingState == 27 ) {
        
        if ( [d boolForKey:@"EnterBackgroundUSDisConnect"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
        
    }else if ( settingState == 28 ) {
        
        if ( [d boolForKey:@"BecomeActiveUSConnect"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
        
    }else if ( settingState == 29 ) {
        
        if ( [d boolForKey:@"ReloadAfterUSConnect"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
        
//    }else if ( settingState == 30 ) {
        
    }else if ( settingState == 31 ) {

        if ( [d boolForKey:@"MyTweetNG"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
        
    }else if ( settingState == 32 ) {
        
        if ( [d integerForKey:@"IconCornerRounding"] == 1 ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
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
    }else if ( indexPath.section == 1 ) {
        settingState = indexPath.row + SECTION_0;
    }else if ( indexPath.section == 2 ) {
        settingState = indexPath.row + SECTION_0 + SECTION_1;
    }else if ( indexPath.section == 3 ) {
        settingState = indexPath.row + SECTION_0 + SECTION_1 + SECTION_2;
    }else if ( indexPath.section == 4 ) {
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
                     initWithTitle:NAME_0
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        }else if ( indexPath.row == 1 ) {
            
            //リサイズ最大長辺
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_1
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"320", @"640", @"800", @"960",@"1280", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        }else if ( indexPath.row == 2 ) {
            
            //画像形式
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_2
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"JPG(Low)", @"JPG", @"JPG(High)", @"PNG", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        }else if ( indexPath.row == 3 ) {
            
            //Retina解像度画像もリサイズを行う
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_3
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        }else if ( indexPath.row == 4 ) {
            
            //画像投稿先
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_4
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"Twitter", @"img.ur(複数枚投稿可)", 
                                       @"Twitpic(複数枚投稿可)", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        }else if ( indexPath.row == 5 ) {
            
            //画像ソース
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_5
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"カメラロール", @"カメラ", @"投稿時選択", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        
        }else if ( indexPath.row == 6 ) {
            
            //連続投稿確認表示
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_6
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        
        }else if ( indexPath.row == 7 ) {
            
            //画像共有サービスフルサイズ取得
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_7
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        }else if ( indexPath.row == 8 ) {
            
            //NowPlaying画像投稿先
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_8
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"通常と同じ", @"Twitter", @"img.ur", @"Twitpic", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        }
        
    }else if ( indexPath.section == 1 ) {
        
        actionSheetNo = actionSheetNo + SECTION_0;
        
        if ( indexPath.row == 0 ) {
        
            //NowPlaying時はFastPostを行う
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_9
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        }else if ( indexPath.row == 1 ) {
            
            //NowPlaying時はCallBackを行う
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_10
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        }else if ( indexPath.row == 2 ) {
            
            //NowPlayingにカスタム書式を使用
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_11
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        
        }else if ( indexPath.row == 3 ) {
            
            //カスタム書式を編集
            alertTextNo = 0;
            
            NSString *message = @"\n曲名[st] アーティスト名[ar]\nアルバム名[at] 再生数[pc] レート[rt]";
            NSString *alertMessage = BLANK;
            
            if ( [EmptyCheck check:[d objectForKey:@"NowPlayingEditText"]] ) {
                alertMessage = [d objectForKey:@"NowPlayingEditText"];
            }
            
            alert = [[UIAlertView alloc] initWithTitle:NAME_12 
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
            
        }else if ( indexPath.row == 4 ) {
            
            //曲名とアルバム名が同じな場合サブ書式を使用
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_13
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"OFF", @"ON(前方一致)", @"ON(完全一致)", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        }else if ( indexPath.row == 5 ) {
            
            //サブ書式を編集
            alertTextNo = 1;
            
            NSString *message = @"\n曲名[st] アーティスト名[ar]\nアルバム名[at] 再生数[pc] レート[rt]";
            NSString *alertMessage = BLANK;
            
            if ( [EmptyCheck check:[d objectForKey:@"NowPlayingEditTextSub"]] ) {
                alertMessage = [d objectForKey:@"NowPlayingEditTextSub"];
            }
            
            alert = [[UIAlertView alloc] initWithTitle:NAME_14
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
        
        }else if ( indexPath.row == 6 ) {
            
            //NowPlaying時にアートワークを投稿
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_15
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        
        }else if ( indexPath.row == 7 ) {
            
            //とは検索
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_16
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        
        }else if ( indexPath.row == 8 ) {
            
            //Webページ投稿書式変更
            alertTextNo = 2;
            
            NSString *message = @"\nタイトル[title] URL[url]";
            NSString *alertMessage = BLANK;
            
            if ( [EmptyCheck check:[d objectForKey:@"WebPagePostFormat"]] ) {
                
                alertMessage = [d objectForKey:@"WebPagePostFormat"];
                
            }else {
                
                alertMessage = @" \"[title]\" [url] ";
                [d setObject:alertMessage forKey:@"WebPagePostFormat"];
            }
            
            alert = [[UIAlertView alloc] initWithTitle:NAME_17
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
        
        }else if ( indexPath.row == 9 ) {
            
            //Webページ投稿書式セット後カーソル位置
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_18
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"先頭", @"末尾", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        
        }else if ( indexPath.row == 10 ) {
            
            //引用投稿書式変更
            alertTextNo = 3;
            
            NSString *message = @"\nタイトル[title] URL[url] 引用[quote]";
            NSString *alertMessage = BLANK;
            
            if ( [EmptyCheck check:[d objectForKey:@"QuoteFormat"]] ) {
                
                alertMessage = [d objectForKey:@"QuoteFormat"];
                
            }else {
                
                alertMessage = @" \"[title]\" [url] >>[quote]";
                [d setObject:alertMessage forKey:@"QuoteFormat"];
            }
            
            alert = [[UIAlertView alloc] initWithTitle:NAME_19
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
            
        }else if ( indexPath.row == 11 ) {
            
            //引用投稿書式セット後カーソル位置
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_20
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"先頭", @"末尾", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        }else if ( indexPath.row == 12 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_21
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"FastPhotoTweet", @"Twitter for iPhone",
                     @"Tweetbot", @"Echofon", @"Echofon Pro",
                     @"SOICHA", @"Tweetings", @"Osfoora",
                     @"Twittelator", @"TweetList!", @"Tweet ATOK",
                     @"Tweetlogix",  @"HootSuite", @"SimplyTweet",
                     @"Reeder", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        }
        
    }else if ( indexPath.section == 2 ) {
        
        actionSheetNo = actionSheetNo + SECTION_0 + SECTION_1;
        
        if ( indexPath.row == 0 ) {
            
            //アプリがアクティブになった際入力可能状態にする
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_22
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        
        }else if ( indexPath.row == 1 ) {
            
            //ブラウザの検索ワードを毎回リセット
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_23
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        
        }else if ( indexPath.row == 2 ) {
            
            //ブラウザを開く時ペーストボード内のURLを開く
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_24
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        
        }else if ( indexPath.row == 3 ) {
            
            //ブラウザユーザーエージェント
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_25
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"FireFox", @"iPad", @"iPhone", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        
        }else if ( indexPath.row == 4 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_26
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"OFF", @"FireFox", @"iPad", @"iPhone", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        }
    
    }else if ( indexPath.section == 3 ) {
        
        actionSheetNo = actionSheetNo + SECTION_0 + SECTION_1 + SECTION_2;
        
        if ( indexPath.row == 0 ) {
            
            //バックグラウンドに移行時UserStreamを切断
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_27
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        
        }else if ( indexPath.row == 1 ) {
            
            //バックグラウンドから復帰時UserStreamに接続
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_28
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        }else if ( indexPath.row == 2 ) {
        
            //通常の更新後にUserStreamに接続
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_29
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
            
        }else if ( indexPath.row == 3 ) {
        
            //NG設定を開く
            NGSettingViewController *dialog = [[[NGSettingViewController alloc] init] autorelease];
            dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentModalViewController:dialog animated:YES];
        
        }else if ( indexPath.row == 4 ) {
            
            //自分のTweetもNGを行う
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_31
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        
        }else if ( indexPath.row == 5 ) {
            
            //アイコンの角を丸める
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_32
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"OFF", @"ON", nil];
            [sheet autorelease];
            [sheet showInView:self.view];
        }
        
    }else if ( indexPath.section == 4 ) {
        
        if ( indexPath.row == 0 ) {
            
            LicenseViewController *dialog = [[[LicenseViewController alloc] init] autorelease];
            dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentModalViewController:dialog animated:YES];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //確定が押された
    if ( alertTextNo == 0 ) {

        if (buttonIndex == 1) {
            
            //カスタム書式を保存
            [d setObject:alertText.text forKey:@"NowPlayingEditText"];
        }
        
    }else if ( alertTextNo == 1 ) {
        
        //サブ書式を保存
        [d setObject:alertText.text forKey:@"NowPlayingEditTextSub"];
    
    }else if ( alertTextNo == 2 ) {
        
        //Webページ投稿書式を保存
        [d setObject:alertText.text forKey:@"WebPagePostFormat"];
    
    }else if ( alertTextNo == 3 ) {
        
        //引用投稿書式を保存
        [d setObject:alertText.text forKey:@"QuoteFormat"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    
    //NSLog(@"Textfield Enter: %@", sender.text);
    
    if ( alertTextNo == 0 ) {
        
        //カスタム書式を保存
        [d setObject:alertText.text forKey:@"NowPlayingEditText"];
        
    }else if ( alertTextNo == 1 ) {
        
        //サブ書式を保存
        [d setObject:alertText.text forKey:@"NowPlayingEditTextSub"];
        
    }else if ( alertTextNo == 2 ) {
        
        //Webページ投稿書式を保存
        [d setObject:alertText.text forKey:@"WebPagePostFormat"];
        
    }else if ( alertTextNo == 3 ) {
        
        //引用投稿書式を保存
        [d setObject:alertText.text forKey:@"QuoteFormat"];
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
            [d setBool:YES forKey:@"ResizeImage"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"ResizeImage"];
        }
        
    }else if ( actionSheetNo == 1 ) {
        if ( buttonIndex == 0 ) {
            [d setInteger:320 forKey:@"ImageMaxSize"];
        }else if ( buttonIndex == 1 ) {
            [d setInteger:640 forKey:@"ImageMaxSize"];
        }else if ( buttonIndex == 2 ) {
            [d setInteger:800 forKey:@"ImageMaxSize"];
        }else if ( buttonIndex == 3 ) {
            [d setInteger:960 forKey:@"ImageMaxSize"];
        }else if ( buttonIndex == 4 ) {
            [d setInteger:1280 forKey:@"ImageMaxSize"];
        }
        
    }else if ( actionSheetNo == 2 ) {
        if ( buttonIndex == 0 ) {
            [d setObject:@"JPG(Low)" forKey:@"SaveImageType"];
        }else if ( buttonIndex == 1 ) {
            [d setObject:@"JPG" forKey:@"SaveImageType"];
        }else if ( buttonIndex == 2 ) {
            [d setObject:@"JPG(High)" forKey:@"SaveImageType"];
        }else if ( buttonIndex == 3 ) {
            [d setObject:@"PNG" forKey:@"SaveImageType"];
        }
    
    }else if ( actionSheetNo == 3 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:NO forKey:@"NoResizeIphone4Ss"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:YES forKey:@"NoResizeIphone4Ss"];
        }
        
    }else if ( actionSheetNo == 4 ) {
        
        if ( buttonIndex == 0 ) {
            
            [d setObject:@"Twitter" forKey:@"PhotoService"];
            
            if ( [d boolForKey:@"RepeatedPost"] ) {
                
                [ShowAlert error:@"Twitterへの画像投稿では連続投稿機能は使えません。"];
                
                [d setBool:NO forKey:@"RepeatedPost"];
            }
            
        }else if ( buttonIndex == 1 ) {
            
            [d setObject:@"img.ur" forKey:@"PhotoService"];
            
        }else if ( buttonIndex == 2 ) {
            
            NSDictionary *dic = [d dictionaryForKey:@"OAuthAccount"];
            NSArray *oauthAccountNames = [dic allKeys];
            
            ACAccount *twAccount = [TWGetAccount currentAccount];
            NSString *twitpicName = nil;
            
            for ( NSString *accountName in oauthAccountNames ) {
                if ( [accountName isEqualToString:twAccount.username] ) {
                    
                    twitpicName = accountName;
                    
                    break;
                }
            }
            
            if ( twitpicName == nil ) {
                
                [ShowAlert error:[NSString stringWithFormat:@"現在使用中のアカウント %@ のTwitpicアカウントが見つかりません。アカウントを登録してください。", twAccount.username]];
                
                appDelegate.addTwitpicAccountName = twAccount.username;
                
                OAuthSetupViewController *dialog = [[[OAuthSetupViewController alloc] init] autorelease];
                dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                [self presentModalViewController:dialog animated:YES];
                
            }else {
                
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
    
    }else if ( actionSheetNo == 5 ) {
        
        //カメラが使われる可能性のある選択肢
        if ( buttonIndex != 0 ) {
            
            //端末がカメラを使えるか判定
            if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
                
                //カメラが利用できる場合
                
                if ( buttonIndex == 1 ) {
                    
                    [d setInteger:1 forKey:@"ImageSource"];
                    
                    if ( [d boolForKey:@"RepeatedPost"] ) {
                        
                        [d setBool:NO forKey:@"RepeatedPost"];
                        
                        [ShowAlert error:@"カメラでは連続投稿が出来ません"];
                    }
                    
                }else if ( buttonIndex == 2 ) {
                    
                    [d setInteger:2 forKey:@"ImageSource"];
                }
                
            }else {
                
                //カメラが利用できない場合                
                [ShowAlert error:@"カメラが利用出来ない端末です。カメラロールが設定されます。"];
                
                [d setInteger:0 forKey:@"ImageSource"];
            }
            
        }else {
            
            [d setInteger:0 forKey:@"ImageSource"];
        }
    
    //連続投稿確認表示
    }else if ( actionSheetNo == 6 ) {
        if ( buttonIndex == 0 ) {
            
            [d setBool:YES forKey:@"RepeatedPost"];
            
            if ( [[d objectForKey:@"PhotoService"] isEqualToString:@"Twitter"] ) {
                
                [ShowAlert error:@"Twitterへの画像投稿では連続投稿機能は使えません。"];
                
                [d setObject:@"img.ur" forKey:@"PhotoService"];
            }
            
            if ( [d integerForKey:@"ImageSource"] == 1 ) {
                
                [ShowAlert error:@"カメラでは連続投稿が出来ません"];
                
                [d setInteger:0 forKey:@"ImageSource"];
            }

            
        }else if ( buttonIndex == 1 ) {
            
            [d setBool:NO forKey:@"RepeatedPost"];
        }
    
    }else if ( actionSheetNo == 7 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"FullSizeImage"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"FullSizeImage"];
        }
    
    }else if ( actionSheetNo == 8 ) {
        if ( buttonIndex == 0 ) {
            [d setInteger:0 forKey:@"NowPlayingPhotoService"];
        }else if ( buttonIndex == 1 ) {
            [d setInteger:1 forKey:@"NowPlayingPhotoService"];
        }else if ( buttonIndex == 2 ) {
            [d setInteger:2 forKey:@"NowPlayingPhotoService"];
        }else if ( buttonIndex == 3 ) {
            [d setInteger:3 forKey:@"NowPlayingPhotoService"];
        }
        
    }else if ( actionSheetNo == 9 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"NowPlayingFastPost"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"NowPlayingFastPost"];
        }
        
    }else if ( actionSheetNo == 10 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"NowPlayingCallBack"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"NowPlayingCallBack"];
        }
    
    }else if ( actionSheetNo == 11 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"NowPlayingEdit"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"NowPlayingEdit"];
        }
    
//  }else if ( actionSheetNo == 12 ) {
    
    }else if ( actionSheetNo == 13 ) {
        if ( buttonIndex == 0 ) {
            [d setInteger:0 forKey:@"NowPlayingEditSub"];
        }else if ( buttonIndex == 1 ) {
            [d setInteger:1 forKey:@"NowPlayingEditSub"];
        }else if ( buttonIndex == 2 ) {
            [d setInteger:2 forKey:@"NowPlayingEditSub"];
        }
        
//  }else if ( actionSheetNo == 14 ) {
        
    }else if ( actionSheetNo == 15 ) {
        
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"NowPlayingArtWork"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"NowPlayingArtWork"];
        }
    
    }else if ( actionSheetNo == 16 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"TohaSearch"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"TohaSearch"];
        }
    
//  }else if ( actionSheetNo == 17 ) {
        
    }else if ( actionSheetNo == 18 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"WebPagePostCursorPosition"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"WebPagePostCursorPosition"];
        }
        
//  }else if ( actionSheetNo == 19 ) {
        
    }else if ( actionSheetNo == 20 ) {
        
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"QuoteCursorPosition"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"QuoteCursorPosition"];
        }
        
    }else if ( actionSheetNo == 21 ) {
        
        if ( buttonIndex == 0 ) {
            [d setObject:@"FPT" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 1 ) {
            [d setObject:@"twitter://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 2 ) {
            [d setObject:@"tweetbot://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 3 ) {
            [d setObject:@"echofon://?" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 4 ) {
            [d setObject:@"echofonpro://?" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 5 ) {
            [d setObject:@"soicha://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 6 ) {
            [d setObject:@"tweetings://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 7 ) {
            [d setObject:@"osfoora://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 8 ) {
            [d setObject:@"twittelator://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 9 ) {
            [d setObject:@"tweetlist://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 10 ) {
            [d setObject:@"tweetatok://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 11 ) {
            [d setObject:@"tweetlogix://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 12 ) {
            [d setObject:@"hootsuite://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 13 ) {
            [d setObject:@"simplytweet://" forKey:@"CallBackScheme"];
        }else if ( buttonIndex == 14 ) {
            [d setObject:@"reeder://" forKey:@"CallBackScheme"];
        }
        
    }else if ( actionSheetNo == 22 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"ShowKeyboard"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"ShowKeyboard"];
        }
    
    }else if ( actionSheetNo == 23 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"ClearBrowserSearchField"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"ClearBrowserSearchField"];
        }
        
    }else if ( actionSheetNo == 24 ) {
        if ( buttonIndex == 0 ) {
            
            [d setBool:YES forKey:@"OpenPasteBoardURL"];
            
            if ( ![EmptyCheck check:[d objectForKey:@"LastOpendPasteBoardURL"]] ) {
                
                [d setObject:BLANK forKey:@"LastOpendPasteBoardURL"];
            }
            
        }else if ( buttonIndex == 1 ) {
            
            [d setBool:NO forKey:@"OpenPasteBoardURL"];
        }
        
    }else if ( actionSheetNo == 25 ) {
        if ( buttonIndex == 0 ) {
            [d setObject:@"FireFox" forKey:@"UserAgent"];
        }else if ( buttonIndex == 1 ) {
            [d setObject:@"iPad" forKey:@"UserAgent"];
        }else if ( buttonIndex == 2 ) {
            [d setObject:@"iPhone" forKey:@"UserAgent"];
        }
    
    }else if ( actionSheetNo == 26 ) {
        
        if ( buttonIndex == 0 ) {
            [d setObject:@"OFF" forKey:@"UserAgentReset"];
        }else if ( buttonIndex == 1 ) {
            [d setObject:@"FireFox" forKey:@"UserAgentReset"];
        }else if ( buttonIndex == 2 ) {
            [d setObject:@"iPad" forKey:@"UserAgentReset"];
        }else if ( buttonIndex == 3 ) {
            [d setObject:@"iPhone" forKey:@"UserAgentReset"];
        }
    
    }else if ( actionSheetNo == 27 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"EnterBackgroundUSDisConnect"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"EnterBackgroundUSDisConnect"];
        }
        
    }else if ( actionSheetNo == 28 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"BecomeActiveUSConnect"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"BecomeActiveUSConnect"];
        }
        
    }else if ( actionSheetNo == 29 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"ReloadAfterUSConnect"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"ReloadAfterUSConnect"];
        }
        
//    }else if ( actionSheetNo == 30 ) {
    
    }else if ( actionSheetNo == 31 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"MyTweetNG"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"MyTweetNG"];
        }
    
    }else if ( actionSheetNo == 32 ) {
        
        if ( buttonIndex == 0 ) {
            [d setInteger:2 forKey:@"IconCornerRounding"];
        }else if ( buttonIndex == 1 ) {
            [d setInteger:1 forKey:@"IconCornerRounding"];
        }
        
        [ShowAlert title:@"設定変更完了" message:@"設定を有効にするにはアプリケーションを再起動してください。"];
        
    }else if ( actionSheetNo == 100 ) {
        if ( buttonIndex == 0 ) {
            
            [d setObject:@"Twitpic" forKey:@"PhotoService"];
            
        }else if ( buttonIndex == 1 ) {
            
            OAuthSetupViewController *dialog = [[[OAuthSetupViewController alloc] init] autorelease];
            dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentModalViewController:dialog animated:YES];
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
    [self setBar:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotate {
    
    if ( [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait ) return YES;
    
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    
    //NSLog(@"SettingView dealloc");
    
    [settingArray release];
    
    [tv release];
    [bar release];
    [saveButton release];
    [super dealloc];
}

@end
