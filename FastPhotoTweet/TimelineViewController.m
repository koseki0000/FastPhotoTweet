//
//  TimelineViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/08.
//

/////////////////////////////
//////// ARC ENABLED ////////
/////////////////////////////

#import "TimelineViewController.h"

#define TOP_BAR [NSArray arrayWithObjects:actionButton, flexibleSpace, openStreamButton, flexibleSpace, fixedSpace, flexibleSpace , reloadButton, flexibleSpace, postButton, nil]
#define IN_REPLY_TO_BAR [NSArray arrayWithObjects:flexibleSpace, closeInReplyToButton, nil]

@implementation TimelineViewController
@synthesize topBar;
@synthesize timeline;
@synthesize flexibleSpace;
@synthesize fixedSpace;
@synthesize postButton;
@synthesize openStreamButton;
@synthesize actionButton;
@synthesize closeInReplyToButton;
@synthesize accountIconView;
@synthesize timelineSegment;
@synthesize reloadButton;
@synthesize connection = _connection;

#pragma mark - Initialize

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self ) {
        
        self.title = NSLocalizedString(@"Timeline", @"Timeline");
        self.tabBarItem.image = [UIImage imageNamed:@"Timeline.png"];
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //NSLog(@"viewDidLoad");
    
    //各種通知設定
    [self setNotifications];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    d = [NSUserDefaults standardUserDefaults];
    fileManager = [NSFileManager defaultManager];
    pboard = [UIPasteboard generalPasteboard];

    twAccount = [TWGetAccount getTwitterAccount];
    timelineArray = [NSMutableArray array];
    timelineAppend = [NSMutableArray array];
    inReplyTo = [NSMutableArray array];
    reqedUser = [NSMutableArray array];
    iconUrls = [NSMutableArray array];
    icons = [NSMutableDictionary dictionary];
    allTimelines = [NSMutableDictionary dictionary];
    mentionsArray = [NSArray array];
    sinceIds = [NSMutableDictionary dictionary];
    selectTweet = [NSDictionary dictionary];
    userStreamAccount = BLANK;
    timelineTopTweetId = BLANK;
    
    startImage = [UIImage imageNamed:@"ForwardIcon.png"];
    stopImage = [UIImage imageNamed:@"stop.png"];
    openStreamButton.image = startImage;
    
    [topBar setItems:TOP_BAR animated:NO];
    
    userStream = NO;
    openStreamAfter = NO;
    userStreamFirstResponse = NO;
    needAppend = NO;

    timelineScroll = 0;
    
    //アイコン表示の角を丸める
    CALayer *layer = [accountIconView layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:5.0f];
    
    //アイコン保存用ディレクトリ確認
    BOOL isDir = NO;
    BOOL directoryExists = ( [fileManager fileExistsAtPath:ICONS_DIRECTORY isDirectory:&isDir] && isDir );
    
    if ( !directoryExists ) {
        
        //存在しない場合作成
        [fileManager createDirectoryAtPath:ICONS_DIRECTORY
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil]; 
    }
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
    ACAccount *account = [[ACAccount alloc] init];
    
    for ( account in twitterAccounts ) {
    
        [allTimelines setObject:[NSMutableArray array] forKey:account.username];
        [sinceIds setObject:BLANK forKey:account.username];
    }
    
    //インターネット接続を確認
    if ( ![appDelegate reachability] ) return;
    
    [timeline reloadData];
    
    //タイムライン生成
    [self createTimeline];
}

- (void)setNotifications {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    //タイムライン取得完了通知を受け取る設定
    [notificationCenter addObserver:self 
                           selector:@selector(loadTimeline:) 
                               name:@"GetTimeline" 
                             object:nil];
    
    //Mentions取得完了通知を受け取る設定
    [notificationCenter addObserver:self 
                           selector:@selector(loadMentions:) 
                               name:@"GetMentions" 
                             object:nil];
    
    //Favorites取得完了通知を受け取る設定
    [notificationCenter addObserver:self 
                           selector:@selector(loadFavorites:) 
                               name:@"GetFavorites" 
                             object:nil];
    
    //プロフィール取得完了を受け取る設定
    [notificationCenter addObserver:self 
                           selector:@selector(receiveProfile:) 
                               name:@"GetProfile" 
                             object:nil];
    
    //Tweet取得完了を受け取る設定
    [notificationCenter addObserver:self 
                           selector:@selector(receiveTweet:) 
                               name:@"GetTweet" 
                             object:nil];
    
    //アプリがアクティブになった場合の通知を受け取る設定
    [notificationCenter addObserver:self
                           selector:@selector(becomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    
    //バックグラウンドに移行した際にストリームを切断
    [notificationCenter addObserver:self 
                           selector:@selector(enterBackground:) 
                               name:UIApplicationDidEnterBackgroundNotification 
                             object:nil];
    
    //アカウントが切り替わった通知を受け取る設定
    [notificationCenter addObserver:self 
                           selector:@selector(changeAccount:) 
                               name:@"ChangeAccount" 
                             object:nil];
}

#pragma mark - TimelineMethod

- (void)createTimeline {

    //NSLog(@"createTimeline");
    
    twAccount = [TWGetAccount getTwitterAccount];
    
    if ( [allTimelines objectForKey:twAccount.username] == nil ) {
        
        [allTimelines setObject:[NSMutableArray array] forKey:twAccount.username];
    }
    
    timelineArray = [allTimelines objectForKey:twAccount.username];
    
    if ( timelineArray.count != 0 ) {
        
        timelineTopTweetId = [[timelineArray objectAtIndex:0] objectForKey:@"id_str"];
    }
    
    [TWGetTimeline homeTimeline];
}

- (void)loadTimeline:(NSNotification *)center {
    
    //NSLog(@"loadTimeline");
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    dispatch_async( globalQueue, ^{
        dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
        dispatch_sync( syncQueue, ^{
            
            //自分のアイコンを設定
            [self getMyAccountIcon];
            
            //更新アカウントを記憶
            lastUpdateAccount = twAccount.username;
            
            NSString *result = [center.userInfo objectForKey:@"Result"];
            
            if ( [result isEqualToString:@"TimelineSuccess"] ) {
                
                NSArray *newTweet = [center.userInfo objectForKey:@"Timeline"];
                
                //NSLog(@"newTweet: %@", newTweet);
                
                if ( newTweet.count == 0 ) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        reloadButton.enabled = YES;
                        
                        if ( viewWillAppear ) {
                            
                            viewWillAppear = NO;
                            [timeline reloadData];
                        }
                    });
                    
                    return;
                }
                
                if ( [[newTweet objectAtIndex:0] objectForKey:@"errors"] != nil ) {
                    
                    [ShowAlert error:@"タイムライン取得時にエラーが発生しました。"];
                    
                    return;
                }
                
                //NGClient判定を行う
                newTweet = [TWNgTweet ngClient:newTweet];
                
                //NGName判定を行う
                newTweet = [TWNgTweet ngName:newTweet];
                
                //NGWord判定を行う
                newTweet = [TWNgTweet ngWord:newTweet];
                
                if ( [EmptyCheck check:newTweet] ) {
                    
                    if ( ![[[newTweet objectAtIndex:0] objectForKey:@"id_str"] isEqualToString:BLANK] ) {
                     
                        [sinceIds setObject:[[newTweet objectAtIndex:0] objectForKey:@"id_str"] forKey:twAccount.username];
                    }
                    
                    int index = 0;
                    for ( id tweet in newTweet ) {
                        
                        [timelineArray insertObject:tweet atIndex:index];
                        index++;
                    }
                    
                    //NSLog(@"%@", timelineArray);
                    
                    //タイムラインを保存
                    [allTimelines setObject:timelineArray forKey:twAccount.username];
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        reloadButton.enabled = YES;
                        
                        [ActivityIndicator off];
                        
                        //タイムラインを再読み込み
                        [timeline reloadData];
                        
                        //新着取得前の最新までスクロール
                        [self scrollTimelineForNewTweet];
                    
                        if ( [d boolForKey:@"ReloadAfterUSConnect"] ) {
                        
                            //UserStream接続
                            if ( !userStream ) [self performSelector:@selector(pushOpenStreamButton:) withObject:nil afterDelay:0.1];
                        }
                    });
                    
                    //タイムラインからアイコンのURLを取得
                    [self getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
                    
                }else {
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        reloadButton.enabled = YES;
                        
                        if ( [d boolForKey:@"ReloadAfterUSConnect"] ) {
                            
                            //UserStream接続
                            if ( !userStream ) [self performSelector:@selector(pushOpenStreamButton:) withObject:nil afterDelay:0.1];
                        }
                        
                        [timeline reloadData];
                    });
                }
            }
        });
        
        dispatch_release(syncQueue);
    });
}

- (void)loadMentions:(NSNotification *)center {
    
    if ( userStream ) [self closeStream];
    
    openStreamButton.enabled = NO;
    
    NSString *result = [center.userInfo objectForKey:@"Result"];
    
    if ( [result isEqualToString:@"MentionsSuccess"] ) {
        
        NSArray *newTweet = [center.userInfo objectForKey:@"Mentions"];
        
        //NGClient判定を行う
        newTweet = [TWNgTweet ngClient:newTweet];
        
        //NGName判定を行う
        newTweet = [TWNgTweet ngName:newTweet];
        
        //NGWord判定を行う
        newTweet = [TWNgTweet ngWord:newTweet];
        
        //InReplyToからの復帰用に保存しておく
        mentionsArray = newTweet;
        
        timelineArray = [NSMutableArray arrayWithArray:newTweet];
        
        //タイムラインからアイコンのURLを取得
        [self getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
        
        [ActivityIndicator off];
        
        //タイムラインを再読み込み
        [timeline reloadData];
    }
}

- (void)loadFavorites:(NSNotification *)center {
    
    if ( userStream ) [self closeStream];
    
    openStreamButton.enabled = NO;
    
    NSString *result = [center.userInfo objectForKey:@"Result"];
    
    if ( [result isEqualToString:@"FavoritesSuccess"] ) {
        
        NSArray *newTweet = [center.userInfo objectForKey:@"Favorites"];
        
        //NSLog(@"newTweet: %@", newTweet);
        
        //InReplyToからの復帰用に保存しておく
        mentionsArray = newTweet;
        
        timelineArray = [NSMutableArray arrayWithArray:newTweet];
        
        //タイムラインからアイコンのURLを取得
        [self getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
        
        [ActivityIndicator off];
        
        //タイムラインを再読み込み
        [timeline reloadData];
    }
}

- (void)getIconWithTweetArray:(NSMutableArray *)tweetArray {
    
    //NSLog(@"getIconWithTweetArray");
    
    NSMutableArray *addUser = [NSMutableArray array];
    NSMutableArray *addIconUrls = [NSMutableArray arrayWithArray:iconUrls];
    
    for ( NSDictionary *dic in tweetArray ) {
        
        //アイコンのユーザー名
        NSString *screenName = [[dic objectForKey:@"user"] objectForKey:@"screen_name"];
        
        if ( ![EmptyCheck string:screenName] ) {
            
            screenName = [dic objectForKey:@"screen_name"];
        }
        
        //biggerサイズのURL
        NSString *biggerUrl = [TWIconBigger normal:[[dic objectForKey:@"user"] objectForKey:@"profile_image_url"]];
        
        if ( ![EmptyCheck string:biggerUrl] ) {
            
            biggerUrl = [TWIconBigger normal:[dic objectForKey:@"profile_image_url"]];
        }
        
        //保存ファイル名
        NSString *fileName = [biggerUrl lastPathComponent];
        //検索用の名前
        NSString *searchName = [NSString stringWithFormat:@"%@_%@", screenName, fileName];
        
        if ( [appDelegate iconExist:searchName] ) {
         
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:FILE_PATH];
            
            [icons setObject:image forKey:searchName];
            
            if ( [screenName isEqualToString:twAccount.username] ) accountIconView.image = image;
            
            [ActivityIndicator off];
            
            continue;
            
        }else {
         
            //保存されていないアイコンを保存する
            if ( [icons objectForKey:searchName] == nil ) {
                
                //各情報が空でないかチェック
                if ( [EmptyCheck string:screenName] && [EmptyCheck string:biggerUrl] && 
                     [EmptyCheck string:fileName]   && [EmptyCheck string:searchName] ) {
                    
                    BOOL find = NO;
                    for ( NSString *addedUser in addUser ) {
                        
                        if ( [screenName isEqualToString:addedUser] ) {
                            
                            find = YES;
                            break;
                        }
                    }
                    
                    if ( find ) continue;
                    
                    for ( NSString *addedUser in reqedUser ) {
                        
                        if ( [screenName isEqualToString:addedUser] ) {
                            
                            find = YES;
                            break;
                        }
                    }
                    
                    if ( find ) continue;
                    
                    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
                    //ユーザー名を設定
                    [tempDic setObject:screenName forKey:@"screen_name"];
                    //アイコンURLを設定
                    [tempDic setObject:biggerUrl forKey:@"profile_image_url"];
                    //検索用の名前
                    [tempDic setObject:searchName forKey:@"SearchName"];
                    
                    //アイコン情報を保存
                    [addIconUrls addObject:tempDic];
                }
            }
        }
        
        //リクエストを行ったユーザーを追加
        [addUser addObject:screenName];
    }
    
    for ( int i = 0; i < addUser.count; i++ ) {
        
        [reqedUser addObject:[addUser objectAtIndex:i]];
    }
    
    //アイコン保存開始
    if ( addIconUrls.count != 0 ) {
        
        iconUrls = addIconUrls;
        
        [self getIconWithSequential];
    }
    
    [ActivityIndicator off];
}

- (void)getIconWithSequential {
    
    //NSLog(@"getIconWithSequential");
    
    //保存すべきURLが無ければ終了
    if ( iconUrls.count == 0 ) {
     
        [ActivityIndicator off];
        
        return;
    }
    
    NSDictionary *dic = [iconUrls objectAtIndex:0];
    NSString *biggerUrl = [dic objectForKey:@"profile_image_url"];
    
    NSURL *URL = [NSURL URLWithString:biggerUrl];
    ASIFormDataRequest *reSendRequest = [[ASIFormDataRequest alloc] initWithURL:URL];
    reSendRequest.userInfo = dic;
    [reSendRequest setDelegate:self];
    [reSendRequest start];
    
    [iconUrls removeObjectAtIndex:0];
}

- (void)changeAccount:(NSNotification *)notification {
    
    //Tweet画面でアカウントが切り替えられた際に呼ばれる
    
    //NSLog(@"changeAccount");
    
    //UserStreamが有効な場合切断する
    if ( userStream ) [self closeStream];
    
    //リロードする
    [self performSelector:@selector(pushOpenStreamButton:) withObject:nil afterDelay:0.1];
}

#pragma mark - In reply to

- (void)getInReplyToChain:(NSDictionary *)tweetData {

    NSString *inReplyToId = [tweetData objectForKey:@"in_reply_to_status_id_str"];
    
    if ( [EmptyCheck check:inReplyToId] ) {
        
        [ActivityIndicator on];
        [TWEvent getTweet:inReplyToId];
        
    }else {
        
        if ( [EmptyCheck check:inReplyTo] && inReplyTo.count > 1 ) {
            
            [self closeStream];
            
            dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
            dispatch_async( globalQueue, ^{
                dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
                dispatch_sync( syncQueue, ^{
                    
                    //表示開始
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        [topBar setItems:IN_REPLY_TO_BAR animated:YES];
                        
                        timelineArray = [NSMutableArray array];
                        [timeline reloadData];
                        
                        [NSThread sleepForTimeInterval:0.1f];
                        
                        for ( NSDictionary *tweet in inReplyTo ) {
                            
                            //タイムラインに追加
                            [timelineArray insertObject:tweet atIndex:0];
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
                            [timeline insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
                            [NSThread sleepForTimeInterval:0.2f];
                        }
                    });
                });
                
                dispatch_release(syncQueue);
            });
        }
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //TableViewの要素数を返す
	return [timelineArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"cellForRowAtIndexPath: %d", indexPath.row);
    
    //TableViewCellを生成
	static NSString *identifier = @"TimelineCell";
	TimelineCell *cell = (TimelineCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	cell.infoLabel.textColor = [UIColor blackColor];
	cell.textLabel.textColor = [UIColor blackColor];
    
	if ( cell == nil ) {
        
		TimelineCellController *controller = [[TimelineCellController alloc] initWithNibName:identifier bundle:nil];
		cell = (TimelineCell *)controller.view;
	}
    
    timelineScroll = (int)timeline.contentOffset.y;
    
    currentTweet = [timelineArray objectAtIndex:indexPath.row];
    
    //ReTweetの色変えと本文の調整は先にやっておく
    if ( [[currentTweet objectForKey:@"retweeted_status"] objectForKey:@"id"] ) {
        
        NSString *userMentionsScreenName = [[[[currentTweet objectForKey:@"entities"] objectForKey:@"user_mentions"] objectAtIndex:0] objectForKey:@"screen_name"];
        NSString *reTweetText = [NSString stringWithFormat:@"RT @%@: %@", userMentionsScreenName, [[currentTweet objectForKey:@"retweeted_status"] objectForKey:@"text"]];
        
        NSMutableDictionary *mutableCurrentTweet = [NSMutableDictionary dictionaryWithDictionary:currentTweet];
        [mutableCurrentTweet setObject:reTweetText forKey:@"text"];
        
        currentTweet = [NSDictionary dictionaryWithDictionary:mutableCurrentTweet];
        
        cell.infoLabel.textColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0];
        cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0];
    }
    
    NSString *myAccountName = twAccount.username;
    NSString *text = [TWEntities replace:currentTweet];
    NSString *screenName = [[currentTweet objectForKey:@"user"] objectForKey:@"screen_name"];
    NSString *jstDate = [TWParseTimeline JSTDate:[currentTweet objectForKey:@"created_at"]];
    NSString *clientName = [TWParseTimeline client:[currentTweet objectForKey:@"source"]];
    NSString *infoLabelText = [NSString stringWithFormat:@"%@ - %@ [%@]", screenName, jstDate, clientName];
    BOOL favorited = [[currentTweet objectForKey:@"favorited"] boolValue];
    
    //アイコン検索用
    NSString *fileName = [TWIconBigger normal:[[[currentTweet objectForKey:@"user"] objectForKey:@"profile_image_url"] lastPathComponent]];
    NSString *searchName = [NSString stringWithFormat:@"%@_%@", screenName, fileName];
    
    if ( [icons objectForKey:searchName] != nil ) {
        
        //角を丸める
        CALayer *layer = [cell.iconView layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:6.0f];
        
        //アイコンを設定
        cell.iconView.image = [icons objectForKey:searchName];
        
    }else {
        
        cell.iconView.image = nil;
    }
    
    //自分の発言の色を変える
    if ( [screenName isEqualToString:myAccountName] ) {
        
        cell.infoLabel.textColor = [UIColor blueColor];
        cell.textLabel.textColor = [UIColor blueColor];
    }
    
    //Replyの色を変える
    if ( [RegularExpression boolRegExp:text 
                         regExpPattern:[NSString stringWithFormat:@"@%@", myAccountName]] ) {
        
        cell.infoLabel.textColor = [UIColor redColor];
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    //Favoriteの色を変えて星をつける
    if ( favorited ) {
        
        infoLabelText = [NSMutableString stringWithFormat:@"★%@",infoLabelText];
        cell.infoLabel.textColor = [UIColor colorWithRed:0.5 green:0.4 blue:0.0 alpha:1.0];
        cell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0.4 blue:0.0 alpha:1.0];
    }
    
    //ふぁぼられイベント用
    if ( [currentTweet objectForKey:@"FavEvent"] != nil ) {
        
        NSString *temp = infoLabelText;
        infoLabelText = [NSString stringWithFormat:@"【%@がお気に入りに追加】", [currentTweet objectForKey:@"addUser"]];
        
        text = [NSString stringWithFormat:@"%@\n%@", temp, text];
    }
    
    cell.infoLabel.text = infoLabelText;
    cell.textLabel.text = text;
    cell.textLabel.frame = CGRectMake(54, 22, 264, [self heightForContents:text]);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルの高さを設定
    currentTweet = [timelineArray objectAtIndex:indexPath.row];
    
    if ( [[currentTweet objectForKey:@"retweeted_status"] objectForKey:@"id"] ) {
        
        NSString *userMentionsScreenName = [[[[currentTweet objectForKey:@"entities"] objectForKey:@"user_mentions"] objectAtIndex:0] objectForKey:@"screen_name"];
        NSString *reTweetText = [NSString stringWithFormat:@"RT @%@: %@", userMentionsScreenName, [[currentTweet objectForKey:@"retweeted_status"] objectForKey:@"text"]];
        
        NSMutableDictionary *mutableCurrentTweet = [NSMutableDictionary dictionaryWithDictionary:currentTweet];
        [mutableCurrentTweet setObject:reTweetText forKey:@"text"];
        
        currentTweet = [NSDictionary dictionaryWithDictionary:mutableCurrentTweet];
        
    }else if ( [currentTweet objectForKey:@"FavEvent"] != nil ) {
        
        return [self heightForContents:[NSString stringWithFormat:@"【%@がお気に入りに追加】\n%@", [currentTweet objectForKey:@"addUser"], [currentTweet objectForKey:@"text"]]] + 17 + 8;
    }
    
    return [self heightForContents:[TWEntities replace:currentTweet]] + 17 + 8;
}

- (CGFloat)heightForContents:(NSString *)contents {
    
	CGSize labelSize = [contents sizeWithFont:[UIFont systemFontOfSize:12.0]
                                                       constrainedToSize:CGSizeMake(264, 20000)
                                                           lineBreakMode:UILineBreakModeWordWrap];
	
    CGFloat height = labelSize.height;
    
    if ( height < 31 ) {
        
        height = 31;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルの選択状態を解除
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    selectRow = indexPath.row;
    selectTweet = [timelineArray objectAtIndex:indexPath.row];
    
    if ( [selectTweet objectForKey:@"FavEvent"] == nil ) {
     
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"機能選択"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"URLを開く", @"Reply", @"Favorite／UnFavorite", @"ReTweet", @"Fav+RT", @"ハッシュタグをNG", @"クライアントをNG", @"InReplyTo", @"Tweetをコピー", @"TweetのURLをコピー", @"Tweetの本文をコピー", nil];
        
        sheet.tag = 0;
        
        [sheet showInView:appDelegate.tabBarController.self.view];
        
    }else {
        
        NSString *targetId = [selectTweet objectForKey:@"id_str"];
        NSString *favStarUrl = [NSString stringWithFormat:@"http://ja.favstar.fm/users/%@/status/%@",twAccount.username, targetId];

        appDelegate.startupUrlList = [NSArray arrayWithObject:favStarUrl];
        
        [self openBrowser];
    }
}

//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
//
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//}

- (void)scrollTimelineForNewTweet {
    
    NSArray *tl = [allTimelines objectForKey:twAccount.username];
    
    if ( ![EmptyCheck check:timelineTopTweetId] ) return;
    
    int index = 0;
    BOOL find = NO;
    for ( NSDictionary *tweet in tl ) {
        
        if ( [[tweet objectForKey:@"id_str"] isEqualToString:timelineTopTweetId] ) {
            
            find = YES;
            timelineTopTweetId = BLANK;
            break;
        }
        
        index++;
    }
    
    if ( find ) {
     
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [timeline scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - ASIHTTPRequest

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    dispatch_async( globalQueue, ^{
        dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
        dispatch_sync( syncQueue, ^{
            
            NSString *screenName = [request.userInfo objectForKey:@"screen_name"];
            NSString *searchName = [request.userInfo objectForKey:@"SearchName"];
            UIImage *receiveImage = [UIImage imageWithData:request.responseData];
            
            [icons setObject:receiveImage forKey:searchName];
            
            if ( ![appDelegate iconExist:searchName] ) {
                
                [request.responseData writeToFile:FILE_PATH atomically:YES];
            }
            
            NSArray *tempTimelineArray = [NSArray arrayWithArray:timelineArray];
            int index = 0;
            
            for ( NSDictionary *tweet in tempTimelineArray ) {
                
                if ( [[[tweet objectForKey:@"user"] objectForKey:@"screen_name"] isEqualToString:screenName] ) {
                    
                    //TL更新
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        if ( timelineScroll < 60 ) {
                            
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
                            [timeline reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                        }
                    });
                }
                
                //自分のアイコンの場合はツールバーにも設定
                if ( [screenName isEqualToString:twAccount.username] ) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        accountIconView.image = [[UIImage alloc] initWithContentsOfFile:FILE_PATH];
                    });
                }
                
                index++;
            }
        });
        
        dispatch_release(syncQueue);
    });
    
    [self getIconWithSequential];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    //NSLog(@"requestFailed");
    
    [ActivityIndicator off];
    
    //再送信
    NSURL *URL = [NSURL URLWithString:[request.userInfo objectForKey:@"profile_image_url"]];
    ASIFormDataRequest *reSendRequest = [[ASIFormDataRequest alloc] initWithURL:URL];
    reSendRequest.userInfo = request.userInfo;
    
    [reSendRequest setDelegate:self];
    [reSendRequest start];
}

#pragma mark - IBAction

- (IBAction)pushPostButton:(UIBarButtonItem *)sender {
    
    appDelegate.tabChangeFunction = @"Post";
    self.tabBarController.selectedIndex = 0;
}

- (IBAction)pushReloadButton:(UIBarButtonItem *)sender {
    
    //NSLog(@"pushReloadButton");
    
    if ( ![appDelegate reachability] ) return;
    
    if ( timelineAppend.count != 0 ) {
        
        int index = 0;
        for ( id unit in timelineAppend ) {
            
            //タイムラインに追加
            [timelineArray insertObject:unit atIndex:index];
            index++;
        }
        
        [timelineAppend removeAllObjects];
        
        //タイムラインを保存
        [allTimelines setObject:timelineArray forKey:twAccount.username];
    }
    
    [self getMyAccountIcon];
    
    reloadButton.enabled = NO;
    
    //リロード後にUserStreamに接続
    if ( [d boolForKey:@"ReloadAfterUSConnect"] ) {
     
        if ( !userStream ) [self performSelector:@selector(pushOpenStreamButton:) withObject:nil afterDelay:0.1];
    }
    
    [self createTimeline];
}

- (IBAction)pushOpenStreamButton:(UIBarButtonItem *)sender {
    
    if ( !userStream && [appDelegate reachability] ) {
    
        //UserStream未接続
        userStream = YES;
        openStreamButton.enabled = NO;
        userStreamFirstResponse = NO;
        [self openStream];
        
    }else {
        
        //UserStream接続済み
        [self closeStream];
    }
}

- (IBAction)pushActionButton:(UIBarButtonItem *)sender {

    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"外部サービスを開く"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Twilog", @"Twilog検索", @"favstar", @"Twitpic", nil];
    
    sheet.tag = 1;
    
    [sheet showInView:appDelegate.tabBarController.self.view];
}

- (IBAction)pushCloseInReplyToButton:(UIBarButtonItem *)sender {
    
    inReplyToMode = NO;
    [topBar setItems:TOP_BAR animated:YES];
    
    [self performSelector:@selector(changeSegment:) withObject:nil afterDelay:0.1];
}

#pragma mark - UserStream

- (void)openStream {
    
    //NSLog(@"openStream");
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    dispatch_async( globalQueue, ^{
        dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
        dispatch_sync( syncQueue, ^{
            
            twAccount = [TWGetAccount getTwitterAccount];
            
            userStreamAccount = twAccount.username;
            
            TWRequest *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://userstream.twitter.com/2/user.json"] 
                                                     parameters:nil 
                                                  requestMethod:TWRequestMethodPOST];
            
            [request setAccount:twAccount];
            
            self.connection = [NSURLConnection connectionWithRequest:request.signedURLRequest delegate:self];
            [self.connection start];
            
            // 終わるまでループさせる
            while ( userStream ) {

                //NSLog(@"RunLoop");
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
        });
        
        dispatch_release(syncQueue);
    });
}

- (void)closeStream {
    
    //NSLog(@"closeStream");
    
    userStream = NO;
    userStreamFirstResponse = NO;
    openStreamButton.enabled = YES;
    openStreamButton.image = startImage;
    [self.connection cancel];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    dispatch_async( globalQueue, ^{
        dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
        dispatch_sync( syncQueue, ^{
            
            @try {
                
                NSError *error = nil;
                NSMutableDictionary *receiveData = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data
                                                                                                                                 options:NSJSONReadingMutableLeaves 
                                                                                                                                   error:&error]];
                
//                NSLog(@"receiveData(%d): %@", receiveData.count, receiveData);
//                NSLog(@"event: %@", [receiveData objectForKey:@"event"]);
                
                if ( !userStreamFirstResponse ) {

                    //接続初回のレスポンスは無視
                    userStreamFirstResponse = YES;
                    
                    return;
                }
                
                //定期的に送られてくる空データは無視
                if ( receiveData.count == 0 ) return;
                
                //接続初回のようなデータは無視
                if ( receiveData.count == 1 && [receiveData objectForKey:@"friends"] != nil ) return;
                
                //更新アカウントを記憶
                lastUpdateAccount = twAccount.username;
                
                NSArray *newTweet = [NSArray arrayWithObject:receiveData];
                
                if ( [receiveData objectForKey:@"event"] == nil ) {
                
                    //NGClient判定を行う
                    newTweet = [TWNgTweet ngClient:newTweet];
                    
                    //NGName判定を行う
                    newTweet = [TWNgTweet ngName:newTweet];
                    
                    //NGWord判定を行う
                    newTweet = [TWNgTweet ngWord:newTweet];
                    
                    //新着が無いので終了
                    if ( newTweet.count == 0 ) return;
                }
                
                receiveData = [newTweet objectAtIndex:0];
                
                //エラーは無視
                if ( error ) return;
                
                if ( receiveData.count != 1 && [receiveData objectForKey:@"delete"] == nil ) {
                    
                    if ( [[receiveData objectForKey:@"event"] isEqualToString:@"favorite"] &&
                        [[[receiveData objectForKey:@"source"] objectForKey:@"screen_name"] isEqualToString:twAccount.username] ) {
                        
                        //自分のふぁぼりイベント
                        NSString *favedTweetId = [[receiveData objectForKey:@"target_object"] objectForKey:@"id_str"];
                        
                        int index = 0;
                        for ( NSDictionary *tweet in timelineArray ) {
                            
                            if ( [[tweet objectForKey:@"id_str"] isEqualToString:favedTweetId] ) {
                                
                                NSMutableDictionary *favedTweet = [NSMutableDictionary dictionaryWithDictionary:tweet];
                                [favedTweet setObject:@"1" forKey:@"favorited"];
                                
                                dispatch_async(dispatch_get_main_queue(), ^ {
                                    
                                    [timelineArray replaceObjectAtIndex:index withObject:favedTweet];
                                    
                                    //タイムラインを保存
                                    [allTimelines setObject:timelineArray forKey:twAccount.username];
                                    
                                    //TL更新
                                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                                    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
                                    [timeline reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
                                    
                                });
                                
                                break;
                            }
                            
                            index++;
                        }
                        
                        return;
                        
                    }else if ( [[receiveData objectForKey:@"event"] isEqualToString:@"unfavorite"] &&
                              [[[receiveData objectForKey:@"source"] objectForKey:@"screen_name"] isEqualToString:twAccount.username] ) {
                        
                        //自分のふぁぼり外しイベント
                        NSString *favedTweetId = [[receiveData objectForKey:@"target_object"] objectForKey:@"id_str"];
                        
                        int index = 0;
                        for ( NSDictionary *tweet in timelineArray ) {
                            
                            if ( [[tweet objectForKey:@"id_str"] isEqualToString:favedTweetId] ) {
                                
                                NSMutableDictionary *favedTweet = [NSMutableDictionary dictionaryWithDictionary:tweet];
                                [favedTweet setObject:@"0" forKey:@"favorited"];
                                
                                dispatch_async(dispatch_get_main_queue(), ^ {
                                    
                                    [timelineArray replaceObjectAtIndex:index withObject:favedTweet];
                                    
                                    //タイムラインを保存
                                    [allTimelines setObject:timelineArray forKey:twAccount.username];
                                    
                                    //TL更新
                                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                                    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
                                    [timeline reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
                                });
                                
                                break;
                            }
                            
                            index++;
                        }
                        
                        return;
                        
                    }else if ( [[receiveData objectForKey:@"event"] isEqualToString:@"favorite"] ) {
                        
                        NSMutableDictionary *favDic = [NSMutableDictionary dictionary];
                        //user
                        NSMutableDictionary *user = [NSMutableDictionary dictionary];
                        
                        //ふぁぼられた人
                        NSString *favUser = [[receiveData objectForKey:@"target"] objectForKey:@"screen_name"];
                        
                        //ふぁぼられ人のアイコン
                        NSString *favUserIcon = [[receiveData objectForKey:@"target"] objectForKey:@"profile_image_url"];
                        
                        //ふぁぼった人
                        NSString *addUser = [[receiveData objectForKey:@"source"] objectForKey:@"screen_name"];
                        
                        //ふぁぼられたTweetの時間
                        NSString *favTime = [[receiveData objectForKey:@"target_object"] objectForKey:@"created_at"];
                        
                        //ふぁぼられたTweet
                        NSString *targetText = [[receiveData objectForKey:@"target_object"] objectForKey:@"text"];
                        
                        //ふぁぼられたID
                        NSString *targetId = [[receiveData objectForKey:@"target_object"] objectForKey:@"id_str"];
                        
                        //クライアント
                        NSString *favClient = [[receiveData objectForKey:@"target_object"] objectForKey:@"source"];
                        
                        //辞書に追加
                        //ふぁぼられイベントフラグ
                        [favDic setObject:@"YES" forKey:@"FavEvent"];
                        [user setObject:BLANK forKey:@"id_str"];
                        [user setObject:favUser forKey:@"screen_name"];
                        [user setObject:favUserIcon forKey:@"profile_image_url"];
                        [favDic setObject:favTime forKey:@"created_at"];
                        [favDic setObject:favClient forKey:@"source"];
                        [favDic setObject:user forKey:@"user"];
                        [favDic setObject:targetText forKey:@"text"];
                        [favDic setObject:targetId forKey:@"id_str"];
                        [favDic setObject:@"1" forKey:@"favorited"];
                        [favDic setObject:addUser forKey:@"addUser"];
                        
                        //NSLog(@"favDic: %@", favDic);
                        
                        if ( [icons objectForKey:favUser] == nil ) {
                            
                            NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
                            [tempDic setObject:[[favDic objectForKey:@"user"] objectForKey:@"screen_name"] forKey:@"screen_name"];
                            [tempDic setObject:[TWIconBigger normal:[[favDic objectForKey:@"user"] objectForKey:@"profile_image_url"]] forKey:@"profile_image_url"];
                            
                            [self getIconWithTweetArray:[NSMutableArray arrayWithObject:tempDic]];
                        }
                                               
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            //タイムラインに追加
                            [timelineArray insertObject:favDic atIndex:0];
                            
                            //タイムラインを保存
                            [allTimelines setObject:timelineArray forKey:twAccount.username];
                            
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
                            [timeline insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
                        });
                        
                        return;
                        
                    }else if ( [receiveData objectForKey:@"event"] != nil ) {
                    
                        return;
                    }
                    
                    //以下通常Post向け処理
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        if ( timelineScroll < 60 ) {
                        
                            BOOL needScroll = NO;
                            
                            if ( needAppend && timelineAppend.count != 0 ) {
                                
                                timelineTopTweetId = [[timelineArray objectAtIndex:0] objectForKey:@"id_str"];
                                
                                int index = 0;
                                for ( id unit in timelineAppend ) {

                                    //タイムラインに追加
                                    [timelineArray insertObject:unit atIndex:index];
                                    index++;
                                }
                                
                                [timelineAppend removeAllObjects];
                                
                                needAppend = NO;
                                needScroll = YES;
                                
                                [timeline reloadData];
                            }
                            
                            //タイムラインに追加
                            [timelineArray insertObject:receiveData atIndex:0];
                            
                            //タイムラインを保存
                            [allTimelines setObject:timelineArray forKey:twAccount.username];
                            
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                            NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
                            [timeline insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
                            
                            if ( needScroll ) [self scrollTimelineForNewTweet];
                            
                        }else {
                            
                            needAppend = YES;
                            
                            //仮保存に追加
                            [timelineAppend insertObject:receiveData atIndex:0];
                        }
                    });
                    
                    //IDを記憶
                    if ( ![[receiveData objectForKey:@"id_str"] isEqualToString:BLANK] ) {
                        
                        [sinceIds setObject:[receiveData objectForKey:@"id_str"] forKey:twAccount.username];
                    }
                    
                    //アイコン保存
                    [self getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
                    
                }else if ( receiveData.count == 1 && [receiveData objectForKey:@"delete"] != nil ) {
                    
                    //削除イベント
                    NSString *deleteTweetId = [[[receiveData objectForKey:@"delete"] objectForKey:@"status"] objectForKey:@"id_str"];
                    
                    //削除されたTweetを検索
                    int index = 0;
                    BOOL find = NO;
                    for ( NSDictionary *tweet in timelineArray ) {
                        
                        if ( [[tweet objectForKey:@"id_str"] isEqualToString:deleteTweetId] ) {
                            
                            find = YES;
                            
                            break;
                        }
                        
                        index++;
                    }
                    
                    if ( find ) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            //見つかった物を削除
                            [timelineArray removeObjectAtIndex:index];
                            
                            //タイムラインを保存
                            [allTimelines setObject:timelineArray forKey:twAccount.username];
                            
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                            NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
                            [timeline deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
                        });
                    }
                }
                
            }@catch ( NSException *e ) { /* 例外は投げ捨てる物 */ }
        });
        
        dispatch_release(syncQueue);
    });
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSLog(@"didReceiveResponse:%d, %lld", httpResponse.statusCode, response.expectedContentLength);
    
    if ( httpResponse.statusCode == 200 ) {
     
        userStream = YES;
        openStreamButton.image = stopImage;
        
    }else {
        
        userStream = NO;
        openStreamButton.image = startImage;
    }
    
    openStreamButton.enabled = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    //NSLog(@"connectionDidFinishLoading:");
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    //NSLog(@"didFailWithError:%@", error);
    
    [self closeStream];
}

#pragma mark - GestureRecognizer

- (IBAction)swipeTimelineRight:(UISwipeGestureRecognizer *)sender {
    
    //NSLog(@"swipeTimelineRight");

    //InReplyTto表示中は何もしない
    if ( inReplyToMode ) return;
    
    int num = [d integerForKey:@"UseAccount"] - 1;
    
    if ( num < 0 ) return;
    
    [NSThread sleepForTimeInterval:0.1f];
    
    int accountCount = [TWGetAccount getTwitterAccountCount] - 1;
    
    if ( accountCount >= num ) {
     
        if ( userStream ) [self closeStream];
        
        twAccount = [TWGetAccount getTwitterAccount:num];
        [d setInteger:num forKey:@"UseAccount"];
        
        [self performSelector:@selector(changeSegment:) withObject:nil afterDelay:0.1];
    }
}

- (IBAction)swipeTimelineLeft:(UISwipeGestureRecognizer *)sender {
    
    //NSLog(@"swipeTimelineLeft");
    
    //InReplyTto表示中は何もしない
    if ( inReplyToMode ) return;
    
    [NSThread sleepForTimeInterval:0.1f];
    
    int num = [d integerForKey:@"UseAccount"] + 1;
    int accountCount = [TWGetAccount getTwitterAccountCount] - 1;
    
    if ( accountCount >= num ) {
        
        if ( userStream ) [self closeStream];
        
        twAccount = [TWGetAccount getTwitterAccount:num];
        [d setInteger:num forKey:@"UseAccount"];
        
        [self performSelector:@selector(changeSegment:) withObject:nil afterDelay:0.1];
    }
}

- (IBAction)longPressTimeline:(UILongPressGestureRecognizer *)sender {
    
    if ( longPressControl == 0 ) {
        
        longPressControl = 1;
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"ログ削除"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"現在のアカウントのTimelineログを削除", @"全てのTimelineログを削除", @"全てのログとアイコンキャッシュを削除", @"タイムラインにNG情報を再適用", nil];
        
        sheet.tag = 2;
        
        [sheet showInView:appDelegate.tabBarController.self.view];
    }
}

#pragma mark - SegmentControl

- (IBAction)changeSegment:(UISegmentedControl *)sender {
    
    //NSLog(@"changeSegment");
    
    //InReplyTo表示中なら閉じる
    if ( inReplyToMode ) {
    
        [self pushCloseInReplyToButton:nil];
        
    }else {
        
        if ( timelineSegment.selectedSegmentIndex == 0 ) {
            
            openStreamButton.enabled = YES;
            
            mentionsArray = [NSArray array];
            
            //Timelineに切り替わった
            timelineArray = [allTimelines objectForKey:twAccount.username];
            
            [timeline reloadData];
            
            [self pushReloadButton:nil];
            
        }else if ( timelineSegment.selectedSegmentIndex == 1 ) {
            
            if ( timelineAppend.count != 0 ) {
             
                int index = 0;
                for ( id unit in timelineAppend ) {
                    
                    //タイムラインに追加
                    [timelineArray insertObject:unit atIndex:index];
                    index++;
                }
                
                [timelineAppend removeAllObjects];
                
                //タイムラインを保存
                [allTimelines setObject:timelineArray forKey:twAccount.username];
            }
            
            //Mentionsに切り替わった
            [TWGetTimeline mentions];
            
        }else if ( timelineSegment.selectedSegmentIndex == 2 ) {
            
            if ( timelineAppend.count != 0 ) {
                
                int index = 0;
                for ( id unit in timelineAppend ) {
                    
                    //タイムラインに追加
                    [timelineArray insertObject:unit atIndex:index];
                    index++;
                }
                
                [timelineAppend removeAllObjects];
                
                //タイムラインを保存
                [allTimelines setObject:timelineArray forKey:twAccount.username];
            }
            
            //Favoritesに切り替わった
            [TWGetTimeline favotites];
        }
    }
}

#pragma mark - ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    dispatch_async( globalQueue, ^{
        dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
        dispatch_sync( syncQueue, ^{
    
            if ( actionSheet.tag == 0 ) {
                
                NSString *tweetId = [selectTweet objectForKey:@"id_str"];
                
                //NSLog(@"selectTweet: %@", selectTweet);
                
                if ( buttonIndex == 0 ) {
                    
                    NSString *text = [TWEntities replace:selectTweet];
                    appDelegate.startupUrlList = [RegularExpression urls:text];

                    [self openBrowser];
                    
                }else if ( buttonIndex == 1 ) {
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                       
                        if ( inReplyToMode ) [self pushCloseInReplyToButton:nil];
                        
                        NSString *screenName = [[selectTweet objectForKey:@"user"] objectForKey:@"screen_name"];
                        NSString *inReplyToId = [selectTweet objectForKey:@"id_str"];
                        
                        [appDelegate.postData setObject:screenName forKey:@"ScreenName"];
                        [appDelegate.postData setObject:inReplyToId forKey:@"InReplyToId"];
                        
                        appDelegate.tabChangeFunction = @"Reply";
                        self.tabBarController.selectedIndex = 0;
                    });
                    
                }else if ( buttonIndex == 2 ) {
                    
                    BOOL favorited = [[selectTweet objectForKey:@"favorited"] boolValue];
                    
                    if ( favorited ) {
                        
                        [TWEvent unFavorite:tweetId];
                        
                    }else {
                        
                        [TWEvent favorite:tweetId];
                    }
                    
                }else if ( buttonIndex == 3 ) {
                    
                    [TWEvent reTweet:tweetId];
                    
                }else if ( buttonIndex == 4 ) {
                    
                    [TWEvent favoriteReTweet:tweetId];
                
                }else if ( buttonIndex == 5 ) {
                    
                    NSString *hashTag = [RegularExpression strRegExp:[selectTweet objectForKey:@"text"] regExpPattern:@"((?:\\A|\\z|[\x0009-\x000D\x0020\xC2\x85\u00A0\u1680\u180E\u2000-\u200A\u2028\u2029\u202F\u205F\u3000]|[\\[\\]［］()（）{}｛｝‘’“”\"\'｟｠⸨⸩「」｢｣『』〚〛⟦⟧〔〕❲❳〘〙⟬⟭〈〉〈〉⟨⟩《》⟪⟫<>＜＞«»‹›【】〖〗]|。|、|\\.|!))(#|＃)([a-z0-9_\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\u0400-\u04FF\u0500-\u0527\u1100-\u11FF\u3130-\u3185\uA960-\uA97F\uAC00-\uD7AF\uD7B0-\uD7FF\u30A1-\u30FA\uFF66-\uFF9D\uFF10-\uFF19\uFF21-\uFF3A\uFF41-\uFF5A\u3041-\u3096\u3400-\u4DBF\u4E00-\u9FFF\u020000-\u02A6DF\u02A700-\u02B73F\u02B740-\u02B81F\u02F800-\u02FA1F\u30FC\u3005]*[a-z_\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\u0400-\u04FF\u0500-\u0527\u1100-\u11FF\u3130-\u3185\uA960-\uA97F\uAC00-\uD7AF\uD7B0-\uD7FF\u30A1-\u30FA\uFF66-\uFF9D\uFF10-\uFF19\uFF21-\uFF3A\uFF41-\uFF5A\u3041-\u3096\u3400-\u4DBF\u4E00-\u9FFF\u020000-\u02A6DF\u02A700-\u02B73F\u02B740-\u02B81F\u02F800-\u02FA1F\u30FC\u3005][a-z0-9_\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\u0400-\u04FF\u0500-\u0527\u1100-\u11FF\u3130-\u3185\uA960-\uA97F\uAC00-\uD7AF\uD7B0-\uD7FF\u30A1-\u30FA\uFF66-\uFF9D\uFF10-\uFF19\uFF21-\uFF3A\uFF41-\uFF5A\u3041-\u3096\u3400-\u4DBF\u4E00-\u9FFF\u020000-\u02A6DF\u02A700-\u02B73F\u02B740-\u02B81F\u02F800-\u02FA1F\u30FC\u3005]*)(?=(?:\\A|\\z|[\x0009-\x000D\x0020\xC2\x85\u00A0\u1680\u180E\u2000-\u200A\u2028\u2029\u202F\u205F\u3000]|[\\[\\]［］()（）{}｛｝‘’“”\"\'｟｠⸨⸩「」｢｣『』〚〛⟦⟧〔〕❲❳〘〙⟬⟭〈〉〈〉⟨⟩《》⟪⟫<>＜＞«»‹›【】〖〗]|。|、|\\.|!))"];
                    
                    if ( [EmptyCheck string:hashTag] ) {
                        
                        NSMutableDictionary *addDic = [NSMutableDictionary dictionary];
                        
                        //NGワード設定を読み込む
                        NSMutableArray *ngWordArray = [NSMutableArray arrayWithArray:[d objectForKey:@"NGWord"]];
                        
                        //NGワードに追加
                        [addDic setObject:[DeleteWhiteSpace string:hashTag] forKey:@"Word"];
                        [ngWordArray addObject:addDic];
                        
                        //設定に反映
                        [d setObject:ngWordArray forKey:@"NGWord"];
                        
                        //タイムラインにNGワードを適用
                        timelineArray = [NSMutableArray arrayWithArray:[TWNgTweet ngWord:[NSArray arrayWithArray:timelineArray]]];
                        
                        //タイムラインを保存
                        [allTimelines setObject:timelineArray forKey:twAccount.username];
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            //リロード
                            [timeline reloadData];
                        });
                        
                    }else {
                        
                        [ShowAlert error:@"ハッシュタグが見つかりませんでした。"];
                    }
                
                }else if ( buttonIndex == 6 ) {
                    
                    NSMutableDictionary *addDic = [NSMutableDictionary dictionary];
                    
                    NSString *clientName = [TWParseTimeline client:[selectTweet objectForKey:@"source"]];
                    
                    //NGクライアント設定を読み込む
                    NSMutableArray *ngClientArray = [NSMutableArray arrayWithArray:[d objectForKey:@"NGClient"]];
                    
                    //NGクライアント
                    [addDic setObject:clientName forKey:@"Client"];
                    
                    [ngClientArray addObject:addDic];
                    
                    //NSLog(@"ngClientArray: %@", ngClientArray);
                    
                    [d setObject:ngClientArray forKey:@"NGClient"];
                    
                    //タイムラインにNGワードを適用
                    timelineArray = [NSMutableArray arrayWithArray:[TWNgTweet ngClient:[NSArray arrayWithArray:timelineArray]]];
                    
                    //タイムラインを保存
                    [allTimelines setObject:timelineArray forKey:twAccount.username];
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        //リロード
                        [timeline reloadData];
                    });
                    
                }else if ( buttonIndex == 7 ) {
                    
                    [inReplyTo removeAllObjects];
                    
                    NSString *inReplyToId = [selectTweet objectForKey:@"in_reply_to_status_id_str"];
                    
                    if ( [EmptyCheck check:inReplyToId] ) {
                        
                        inReplyToMode = YES;
                        
                        [inReplyTo addObject:selectTweet];
                        [TWEvent getTweet:inReplyToId];
                        
                    }else {
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            [ShowAlert error:@"InReplyToIDがありません。"];
                        });
                    }
                
                }else if ( buttonIndex == 8 ) {
                    
                    NSString *screenName = [[selectTweet objectForKey:@"user"] objectForKey:@"screen_name"];
                    NSString *text = [TWEntities replace:selectTweet];
                    
                    NSString *copyText = [NSString stringWithFormat:@"%@: %@ [https://twitter.com/%@/status/%@]", screenName, text, screenName, tweetId];
                    [pboard setString:copyText];
                    
                }else if ( buttonIndex == 9 ) {
                    
                    NSString *screenName = [[selectTweet objectForKey:@"user"] objectForKey:@"screen_name"];
                    NSString *copyText = [NSString stringWithFormat:@"https://twitter.com/%@/status/%@", screenName, tweetId];
                    [pboard setString:copyText];
                    
                }else if ( buttonIndex == 10 ) {
                    
                    [pboard setString:[TWEntities replace:selectTweet]];
                }
                
            }else if ( actionSheet.tag == 1 ) {
                
                NSString *serviceUrl = nil;
                NSString *openAccount = twAccount.username;
                
                if ( buttonIndex == 0 ) {
                    
                    //Twilog
                    serviceUrl = [NSString stringWithFormat:@"http://twilog.org/%@", openAccount];
                    
                }else if ( buttonIndex == 1 ) {    
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        twilogSearch = [[UIAlertView alloc] initWithTitle:@"Twilog検索"
                                                                  message:@"\n"
                                                                 delegate:self 
                                                        cancelButtonTitle:@"キャンセル" 
                                                        otherButtonTitles:@"確定", nil];
                        
                        twilogSearch.tag = 0;
                        
                        twilogSearchText = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
                        [twilogSearchText setBackgroundColor:[UIColor whiteColor]];
                        twilogSearchText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                        twilogSearchText.delegate = self;
                        twilogSearchText.text = BLANK;
                        twilogSearchText.tag = 0;
                        
                        [twilogSearch addSubview:twilogSearchText];
                        [twilogSearch show];
                        [twilogSearchText becomeFirstResponder];
                    });
                    
                    return;
                    
                }else if ( buttonIndex == 2 ) {
                    
                    //favstar
                    serviceUrl = [NSString stringWithFormat:@"http://ja.favstar.fm/users/%@/recent", openAccount];
                
                }else if ( buttonIndex == 3 ) {
                    
                    //Twitpic
                    serviceUrl = [NSString stringWithFormat:@"http://twitpic.com/photos/%@", openAccount];
                    
                }else {
                    
                    return;
                }

                appDelegate.startupUrlList = [NSArray arrayWithObject:serviceUrl];

                [self openBrowser];
                
            }else if ( actionSheet.tag == 2 ) {
                
                longPressControl = 0;
                
                if ( buttonIndex == 0 ) {
                    
                    //タイムラインからログを削除
                    [timelineArray removeAllObjects];
                    timelineArray = [NSMutableArray array];
                    
                    //SinceIDを削除
                    [sinceIds setObject:BLANK forKey:twAccount.username];
                    
                    //タイムラインを保存
                    [allTimelines setObject:timelineArray forKey:twAccount.username];
                    
                }else if ( buttonIndex == 1 || buttonIndex == 2 ) {
                    
                    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
                    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
                    NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
                    ACAccount *account = [[ACAccount alloc] init];
                    
                    //各アカウントのログを削除
                    for ( account in twitterAccounts ) {
                        
                        [allTimelines setObject:[NSMutableArray array] forKey:account.username];
                        [sinceIds setObject:BLANK forKey:account.username];
                    }
                    
                    //タイムラインログを削除
                    timelineArray = [NSMutableArray array];
                    
                    if ( buttonIndex == 2 ) {
                        
                        //アイコンキャッシュを削除
                        [icons removeAllObjects];
                    }
                
                }else if ( buttonIndex == 3 ) {
                    
                    //NG情報を再適用
                    timelineArray = [NSMutableArray arrayWithArray:[TWNgTweet ngWord:timelineArray]];
                    timelineArray = [NSMutableArray arrayWithArray:[TWNgTweet ngName:timelineArray]];
                    timelineArray = [NSMutableArray arrayWithArray:[TWNgTweet ngClient:timelineArray]];
                    [allTimelines setObject:timelineArray forKey:twAccount.username];
                    
                    //タイムラインを更新
                    [timeline reloadData];
                    
                }else {
                    
                    //キャンセル
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    //タイムラインを更新
                    [timeline reloadData];
                });
            }
        });
        
        dispatch_release(syncQueue);
    });
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //確定が押された
    if ( alertView.tag == 0 && buttonIndex == 1) {
        
        NSString *searchURL = [CreateSearchURL twilog:twAccount.username searchWord:twilogSearchText.text];
        appDelegate.startupUrlList = [NSArray arrayWithObject:searchURL];
        
        [self openBrowser];
    }
}

#pragma mark - UIWebViewEx

- (void)openBrowser {
    
    NSString *useragent = IPHONE_USERAGENT;
    
    if ( [[d objectForKey:@"UserAgent"] isEqualToString:@"FireFox"] ) {
        
        useragent = FIREFOX_USERAGENT;
        
    }else if ( [[d objectForKey:@"UserAgent"] isEqualToString:@"iPad"] ) {
        
        useragent = IPAD_USERAFENT;
    }
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:useragent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    
    webBrowserMode = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        WebViewExController *dialog = [[WebViewExController alloc] init];
        dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [appDelegate.tabBarController.self presentModalViewController:dialog animated:YES];
    });
}

#pragma mark - UITextField

- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    
    //NSLog(@"Textfield Enter: %@", sender.text);
    
    if ( sender.tag == 0 ) {
        
        NSString *searchURL = [CreateSearchURL twilog:twAccount.username searchWord:twilogSearchText.text];
        appDelegate.startupUrlList = [NSArray arrayWithObject:searchURL];
        
        [self openBrowser];
    }
    
    //キーボードを閉じる
    [sender resignFirstResponder];
    
    //アラートを閉じる
    [twilogSearch dismissWithClickedButtonIndex:0 animated:YES];
    
    return YES;
}

#pragma mark - Notification

- (void)receiveProfile:(NSNotification *)notification {
    
    if ( [[notification.userInfo objectForKey:@"Result"] isEqualToString:@"Success"] ) {
    
        NSDictionary *result = [notification.userInfo objectForKey:@"Profile"];
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        
        NSString *screenName = [result objectForKey:@"screen_name"];
        NSString *biggerUrl = [TWIconBigger normal:[result objectForKey:@"profile_image_url"]];
        NSString *fileName = [biggerUrl lastPathComponent];
        NSString *searchName = [NSString stringWithFormat:@"%@_%@", screenName, fileName];
        [tempDic setObject:screenName forKey:@"screen_name"];
        [tempDic setObject:biggerUrl forKey:@"profile_image_url"];
        [tempDic setObject:searchName forKey:@"SearchName"];
        
        [self getIconWithTweetArray:[NSMutableArray arrayWithObject:tempDic]];
        
    }else {
     
        [ShowAlert error:@"ユーザー情報の取得に失敗しました。"];
        reloadButton.enabled = YES;
    }
}

- (void)receiveTweet:(NSNotification *)notification {
    
    if ( [[notification.userInfo objectForKey:@"Result"] isEqualToString:@"Success"] ) {
        
        [ActivityIndicator on];
        [inReplyTo insertObject:[notification.userInfo objectForKey:@"Tweet"] atIndex:0];
        [self getInReplyToChain:[notification.userInfo objectForKey:@"Tweet"]];
        
    }else {
        
        [ShowAlert error:@"Tweet取得中にエラーが発生しました。"];
    }
}

- (void)postDone:(NSNotification *)center {
    
    if ( appDelegate.postError.count != 0 ) {
        
        appDelegate.tabChangeFunction = @"PostError";
        timelineSegment.selectedSegmentIndex = 0;
    }
}

- (void)enterBackground:(NSNotification *)notification {
    
    if ( [d boolForKey:@"EnterBackgroundUSDisConnect"] ) {
     
        if ( userStream ) [self closeStream];
    }
}

- (void)becomeActive:(NSNotification *)notification {
    
    if ( [d boolForKey:@"BecomeActiveUSConnect"] && timelineSegment.selectedSegmentIndex == 0 && !inReplyToMode ) {
     
        if ( !userStream ) [self pushReloadButton:nil];
    }
}

#pragma mark - View

- (void)getMyAccountIcon {
    
    accountIconView.image = nil;
    
    if ( icons.count == 0 ) {
        
        //アイコンが1つもない場合は自分のアイコンがないので保存を行う
        [TWEvent getProfile:twAccount.username];
        
        return;
    }
    
    NSArray *array = [icons allKeys];
    NSString *string = BLANK;
    BOOL find = NO;
    
    for ( string in array ) {
        
        if ( [RegularExpression boolRegExp:string regExpPattern:[NSString stringWithFormat:@"%@_", twAccount.username]] ) {
            
            accountIconView.image = [icons objectForKey:string];
            find = YES;
            
            break;
        }
        
        if ( find ) break;
    }
    
    if ( !find ) {
        
        [TWEvent getProfile:twAccount.username];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if ( webBrowserMode ) {
        
        webBrowserMode = NO;
        
        if ( appDelegate.pcUaMode ) {
            
            appDelegate.pcUaMode = NO;
            
            [self openBrowser];
            
            return;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //NSLog(@"viewWillAppear");
    
    ACAccount *account = [TWGetAccount getTwitterAccount];
    
    if ( ![lastUpdateAccount isEqualToString:account.username] && [EmptyCheck string:lastUpdateAccount] ) {
        
        viewWillAppear = YES;
        
        twAccount = account;
        
        if ( userStream ) [self closeStream];
        
        [self createTimeline];
    }
}

- (void)viewDidUnload {
    
    [self setTopBar:nil];
    [self setTimeline:nil];
    [self setFlexibleSpace:nil];
    [self setPostButton:nil];
    [self setOpenStreamButton:nil];
    [self setReloadButton:nil];
    [self setActionButton:nil];
    [self setCloseInReplyToButton:nil];
    [self setAccountIconView:nil];
    [self setFixedSpace:nil];
    [self setTimelineSegment:nil];
    [super viewDidUnload];
}

- (void)dealloc {

}

@end
