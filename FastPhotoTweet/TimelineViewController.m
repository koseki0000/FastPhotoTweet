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

#define TOP_BAR [NSArray arrayWithObjects:_actionButton, _flexibleSpace, _timelineControlButton, _flexibleSpace, _fixedSpace, _flexibleSpace , _reloadButton, _flexibleSpace, _postButton, nil]
#define OTHER_TWEETS_BAR [NSArray arrayWithObjects:_flexibleSpace, _closeOtherTweetsButton, nil]
#define PICKER_BAR_ITEM [NSArray arrayWithObjects:_pickerBarCancelButton, _flexibleSpace, _pickerBarDoneButton, nil]

#define CELL_IDENTIFIER @"TimelineAttributedCell"
#define RT_CELL_IDENTIFIER @"TimelineAttributedRTCell"

#define BLACK_COLOR [UIColor blackColor]
#define GREEN_COLOR [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0]
#define BLUE_COLOR  [UIColor blueColor]
#define RED_COLOR   [UIColor redColor]
#define GOLD_COLOR  [UIColor colorWithRed:0.5 green:0.4 blue:0.0 alpha:1.0]

#define D [NSUserDefaults standardUserDefaults]
#define FILE_MANAGER [NSFileManager defaultManager]
#define P_BOARD [UIPasteboard generalPasteboard]
#define APP_DELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@implementation TimelineViewController

#pragma mark - Initialize

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self ) {
        
        self.title = NSLocalizedString(@"Timeline", @"Timeline");
        self.tabBarItem.image = [UIImage imageNamed:@"Timeline.png"];
        
        [Share manager];
        
        __weak TimelineViewController *wself = self;
        
        dispatch_queue_t asyncQueue = GLOBAL_QUEUE_DEFAULT;
        dispatch_async(asyncQueue, ^{
            
            [wself setDefault];
        });
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"%s", __func__);
    
    __weak TimelineViewController *wself = self;
    
    dispatch_queue_t asyncQueue = GLOBAL_QUEUE_DEFAULT;
    dispatch_async(asyncQueue, ^{
        
        SYNC_MAIN_QUEUE ^{
            
            //ツールバーにボタンを設定
            [wself setTimelineBarItems];
            
            wself.accountIconView.userInteractionEnabled = NO;
            wself.timelineControlButton.image = wself.startImage;
            
            wself.timelineSegment.frame = CGRectMake(-4,
                                                     wself.timelineSegment.frame.origin.y,
                                                     wself.timelineSegment.frame.size.width + 8,
                                                     wself.timelineSegment.frame.size.height);
            
            wself.grayView = [ActivityGrayView grayViewWithTaskName:@"FirstLoad"];
            [wself.view addSubview:wself.grayView];
            
            wself.imageWindow = [[ImageWindow alloc] init];
            [wself.view addSubview:wself.imageWindow];
            
            [wself setTimelineHeight];
            
            //アイコン表示の角を丸める
            [wself setMyAccountIconCorner];
            
            [wself createPullDownRefreshHeader];
        });
        
        //各種通知設定
        [wself setNotifications];
        
        //インターネット接続を確認
        if ( [InternetConnection disable] ) return;
        
        //タイムライン生成
        [wself performSelectorInBackground:@selector(createTimeline) withObject:nil];
    });
}

- (void)setDefault {
    
    //各種初期化
    self.timelineArray = BLANK_ARRAY;
    self.inReplyTo = BLANK_M_ARRAY;
    self.currentList = BLANK_M_ARRAY;
    self.searchStreamTemp = BLANK_M_ARRAY;
    self.requestedUser = [NSMutableSet set];
    self.mentionsArray = BLANK_ARRAY;
    self.allLists = BLANK_M_DIC;
    self.selectTweet = BLANK_DIC;
    self.selectAccount = BLANK;
    self.alertSearchUserName = BLANK;
    
    self.startImage = [UIImage imageNamed:@"ForwardIcon.png"];
    self.stopImage = [UIImage imageNamed:@"stop.png"];
    self.listImage = [UIImage imageNamed:@"list.png"];
    
    self.userStream = NO;
    self.userStreamFirstResponse = NO;
    self.pickerVisible = NO;
    self.showMenu = NO;
    
    //アイコン保存用ディレクトリ確認
    BOOL isDir = NO;
    BOOL directoryExists = ( [FILE_MANAGER fileExistsAtPath:ICONS_DIRECTORY isDirectory:&isDir] && isDir );
    
    if ( !directoryExists ) {
        
        //存在しない場合作成
        [FILE_MANAGER createDirectoryAtPath:ICONS_DIRECTORY
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:nil];
    }
    
    //クラッシュログ保存用ディレクトリ確認
    isDir = NO;
    directoryExists = ( [FILE_MANAGER fileExistsAtPath:LOGS_DIRECTORY isDirectory:&isDir] && isDir );
    
    if ( !directoryExists ) {
        
        //存在しない場合作成
        [FILE_MANAGER createDirectoryAtPath:LOGS_DIRECTORY
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:nil];
    }
    
    [self startConnectionCheckTimer];
    self.searchStreamTimer = nil;
}

- (void)setNotifications {
    
    //タイムライン取得完了通知を受け取る設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadTimeline:)
                                                 name:@"GetTimeline"
                                               object:nil];
    
    //ユーザータイムライン取得完了通知を受け取る設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadUserTimeline:)
                                                 name:@"GetUserTimeline"
                                               object:nil];
    
    //Mentions取得完了通知を受け取る設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadMentions:)
                                                 name:@"GetMentions"
                                               object:nil];
    
    //Favorites取得完了通知を受け取る設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadFavorites:)
                                                 name:@"GetFavorites"
                                               object:nil];
    
    //Twitter Search取得完了通知を受け取る設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadSearch:)
                                                 name:@"GetSearch"
                                               object:nil];
    
    //リスト取得完了通知を受け取る設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadList:)
                                                 name:@"ReceiveList"
                                               object:nil];
    
    //プロフィール取得完了を受け取る設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveProfile:)
                                                 name:@"GetProfile"
                                               object:nil];
    
    //Tweet取得完了を受け取る設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTweet:)
                                                 name:@"GetTweet"
                                               object:nil];
    
    //削除完了を受け取る設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(destroyTweet:)
                                                 name:@"Destroy"
                                               object:nil];
    
    //アプリがアクティブになった場合の通知を受け取る設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    //バックグラウンドに移行した際にストリームを切断
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    //アカウントが切り替わった通知を受け取る設定
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeAccount:)
                                                 name:@"ChangeAccount"
                                               object:nil];
    
    //オフライン通知を受け取る
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveOfflineNotification:)
                                                 name:@"Offline"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pboardNotification:)
                                                 name:@"pboardNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startConnectionCheckTimer)
                                                 name:@"BecomeOnline"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openTimelineURL:)
                                                 name:@"OpenTimelineURL"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveGrayViewDoneNotification:)
                                                 name:@"GrayViewDone"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openTimelineImage:)
                                                 name:@"OpenTimelineImage"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timelineMenuAction:)
                                                 name:@"TimelineMenuAction"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideTimelineMenu:)
                                                 name:@"TimelineMenuCanceled"
                                               object:nil];
}

- (void)setTimelineHeight {
    
    //タイムラインの位置を計算する
    int timelineY = TOOL_BAR_HEIGHT + SEGMENT_BAR_HEIGHT;
    
    //タイムラインの高さを計算する
    int timelineHeight = SCREEN_HEIGHT - timelineY - TAB_BAR_HEIGHT;
    
    //タイムラインに位置と高さを設定する
    _timeline.frame = CGRectMake(0,
                                 timelineY,
                                 SCREEN_WIDTH,
                                 timelineHeight);
}

- (void)createPullDownRefreshHeader {
    
    NSLog(@"createPullDownRefreshHeader");
    
    CGRect headerRect = CGRectMake(0,
                                   -_timeline.bounds.size.height,
                                   _timeline.bounds.size.width,
                                   _timeline.bounds.size.height);
    self.headerView = nil;
    self.headerView = [[TTTableHeaderDragRefreshView alloc] initWithFrame:headerRect];
    _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _headerView.backgroundColor = TTSTYLEVAR(tableRefreshHeaderBackgroundColor);
    [_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
    [_timeline addSubview:_headerView];
    [_headerView setUpdateDate:nil];
    
    CGRect activityRect = CGRectMake(0,
                                     44,
                                     self.view.frame.size.width,
                                     self.view.bounds.size.height);
    self.activityTable = nil;
    _activityTable = [[UIView alloc] initWithFrame:activityRect];
    _activityTable.backgroundColor = [UIColor whiteColor];
    
    TTActivityLabel *label = [[TTActivityLabel alloc] initWithStyle:TTActivityLabelStyleGray];
    [_activityTable addSubview:label];
    CGRect frame = _activityTable.bounds;
    frame.origin.y -= 44;
    label.frame = frame;
    label = nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //NSLog(@"scrollViewDidScroll");
    
    if ( scrollView.dragging && !_isLoading ) {
        
        if ( scrollView.contentOffset.y > REFRESH_DERAY &&
            scrollView.contentOffset.y < 0.0f ) {
            
            [_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
            
        }else if ( scrollView.contentOffset.y < REFRESH_DERAY ) {
            
            [_headerView setStatus:TTTableHeaderDragRefreshReleaseToReload];
        }
    }
    
    if ( _isLoading ) {
        
        if ( scrollView.contentOffset.y >= 0 ) {
            
            _timeline.contentInset = UIEdgeInsetsZero;
            
        }else if ( scrollView.contentOffset.y < 0 ) {
            
            _timeline.contentInset = UIEdgeInsetsMake(HEADER_HEIGHT, 0, 0, 0);
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    //NSLog(@"scrollViewDidEndDragging");
    
    if ( scrollView.contentOffset.y <= REFRESH_DERAY &&
        !_isLoading ) {
        
        [self startLoad];
    }
}

#pragma mark - PullDownRefresh

- (void)startLoad {
    
    NSLog(@"startLoad");
    
    [_headerView setStatus:TTTableHeaderDragRefreshLoading];
    
    if ( _reloadButton.isEnabled ) {
        
        __weak TimelineViewController *wself = self;
        
        DISPATCH_AFTER(0.1) ^{
            
            [wself pushReloadButton:nil];
        });
        
    }else {
        
        return;
    }
    
    _isLoading = YES;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultFastTransitionDuration];
    
    if ( _timeline.contentOffset.y < 0 ) {
        
        _timeline.contentInset = UIEdgeInsetsMake(HEADER_HEIGHT, 0, 0, 0);
    }
    
    [UIView commitAnimations];
}

- (void)finishLoad {
    
    NSLog(@"finishLoad");
    
    [_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
    
    [_grayView end];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:ttkDefaultTransitionDuration];
    _timeline.contentInset = UIEdgeInsetsZero;
    [UIView commitAnimations];
    
    [_headerView setCurrentDate];
    _isLoading = NO;
}

#pragma mark - TimelineMethod

- (void)createTimeline {
    
    @autoreleasepool {
        
        NSLog(@"createTimeline");
        
        //インターネット接続を確認
        if ( ![InternetConnection enable] ) return;
        
        if ( [TWAccounts currentAccount] == nil ) {
            
            [ShowAlert error:@"Twitterアカウントが取得できません。iPhoneの設定より登録の後、ご使用ください。"];
            return;
        }
        
        __weak TimelineViewController *wself = self;
        
        //アクティブアカウントのタイムラインを反映
        if ( wself.timelineArray != [TWTweets currentTimeline] ) {
            
            ASYNC_MAIN_QUEUE ^{
                
                wself.timelineArray = [NSMutableArray arrayWithArray:[TWTweets currentTimeline]];
                [wself.timeline reloadData];
            });
        }
        
        ASYNC_MAIN_QUEUE ^{
            
            if ( wself.timelineArray.count == 0 ) {
                
                [wself.grayView start];
                wself.firstLoad = YES;
            }
        });
        
        //タイムライン取得
        [TWGetTimeline homeTimeline];
    }
}

- (void)loadTimeline:(NSNotification *)center {
    
    @autoreleasepool {
        
        __weak TimelineViewController *wself = self;
        
        @try {
            
            dispatch_queue_t globalQueue = GLOBAL_QUEUE_DEFAULT;
            dispatch_async(globalQueue, ^{
                
                NSLog(@"loadTimeline[%d], userStream[%@]",
                      wself.timelineArray.count,
                      wself.userStream ? @"ON" : @"OFF");
                
                //Timelineタブ以外が選択されている場合は終了
                if ( wself.timelineSegment.selectedSegmentIndex != 0 ) return;
                if ( ![center.userInfo[@"Type"] isEqualToString:@"Timeline"] ) return;
                if ( ![center.userInfo[@"Account"] isEqualToString:[TWAccounts currentAccountName]] ) return;
                
                //自分のアイコンを設定
                [wself getMyAccountIcon];
                
                //更新アカウントを記憶
                wself.lastUpdateAccount = [TWAccounts currentAccountName];
                
                NSString *result = [[NSString alloc] initWithString:center.userInfo[@"Result"]];
                
                if ( [result isEqualToString:@"TimelineSuccess"] ) {
                    
                    __block NSArray *newTweet = [[NSArray alloc] initWithArray:center.userInfo[@"Timeline"]];
                    
//                    NSLog(@"newTweet: %@", newTweet);
//                    NSLog(@"newTweet: %d", weakNewTweet.count);
                    
                    if ( newTweet.count == 0 ) {
                        
                        NSLog(@"newTweet.count == 0");
                        
                        ASYNC_MAIN_QUEUE ^{
                            
                            wself.reloadButton.enabled = YES;
                            
                            if ( wself.viewWillAppear ) {
                                
                                wself.viewWillAppear = NO;
                                [wself.timeline reloadData];
                            }
                        });
                        
                        if ( [D boolForKey:@"ReloadAfterUSConnect"] && !wself.userStream ) {
                            
                            //UserStream接続
                            [wself pushTimelineControlButton:nil];
                        }
                        
                        return;
                    }
                    
                    if ( newTweet[0][@"errors"] != nil ) {
                        
                        NSLog(@"newTweet error");
                        
                        [ShowAlert error:@"タイムライン取得時にエラーが発生しました。"];
                        
                        if ( [D boolForKey:@"ReloadAfterUSConnect"] && !wself.userStream ) {
                            
                            //UserStream接続
                            [wself pushTimelineControlButton:nil];
                        }
                        
                        return;
                    }
                    
                    if ( [newTweet isNotEmpty] ) {
                        
                        __block NSString *scrollTweetID = nil;
                        
                        if ( [wself.timelineArray isNotEmpty] ) {
                            
                            scrollTweetID = [[NSString alloc] initWithString:wself.timelineArray[0][@"id_str"]];
                        }
                        
                        wself.timelineArray = [wself.timelineArray appendOnlyNewToTop:newTweet
                                                                             forXPath:@"id_str"
                                                                        returnMutable:YES];
                        
                        //タイムラインを保存
                        [TWTweets saveCurrentTimeline:wself.timelineArray];
                        
                        [wself checkTimelineCount:NO];
                        
                        ASYNC_MAIN_QUEUE ^{
                            
                            wself.reloadButton.enabled = YES;
                            
                            [ActivityIndicator off];
                            
                            //タイムラインを再読み込み
                            [wself.timeline reloadData];
                            
                            if ( wself.firstLoad && [D boolForKey:@"TimelineFirstLoad"] ) {
                                
                                [wself scrollTimelineToBottom:YES];
                                wself.firstLoad = NO;
                                
                            }else {
                                
                                //新着取得前の最新までスクロール
                                [wself scrollTimelineForNewTweet:scrollTweetID];
                                scrollTweetID = nil;
                            }
                            
                            [wself.timeline flashScrollIndicators];
                            
                            if ( [D boolForKey:@"ReloadAfterUSConnect"] && !wself.userStream ) {
                                
                                //UserStream接続
                                DISPATCH_AFTER(0.1) ^{
                                    
                                    [wself pushTimelineControlButton:nil];
                                });
                            }
                        });
                        
                        //タイムラインからアイコンのURLを取得
                        dispatch_async(globalQueue, ^ {
                            
                            [wself getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
                            newTweet = nil;
                        });
                        
                    }else {
                        
                        ASYNC_MAIN_QUEUE ^{
                            
                            wself.reloadButton.enabled = YES;
                            
                            if ( [D boolForKey:@"ReloadAfterUSConnect"] && !wself.userStream ) {
                                
                                //UserStream接続
                                DISPATCH_AFTER(0.1) ^{
                                    
                                    [wself pushTimelineControlButton:nil];
                                });
                            }
                            
                            //タイムライン表示を更新
                            [wself.timeline reloadData];
                        });
                    }
                    
                }else if ( [result isEqualToString:@"TimelineError"] ) {
                    
                    wself.reloadButton.enabled = YES;
                }
            });
            
        }@finally {
            
            ASYNC_MAIN_QUEUE ^{
                
                [wself finishLoad];
            });
        }
    }
}

- (void)loadUserTimeline:(NSNotification *)center {
    
    NSLog(@"loadUserTimeline");
    
    __weak TimelineViewController *wself = self;
    
    @try {
        
        if ( ![center.userInfo[@"Type"] isEqualToString:@"UserTimeline"] ) return;
        
        //レスポンスが空の場合は何もしない
        if ( [center.userInfo[@"UserTimeline"] count] == 0 ) return;
        
        //UserStream接続中の場合は切断する
        if ( _userStream ) [self closeStream];
        
        _timelineControlButton.enabled = NO;
        
        if ( [center.userInfo[@"Result"] isEqualToString:@"UserTimelineSuccess"] ) {
            
            __block NSArray *newTweet = [[NSArray alloc] initWithArray:center.userInfo[@"UserTimeline"]];
            
            //NSLog(@"newTweet: %@", newTweet);
            
            //InReplyToからの復帰用に保存しておく
            self.mentionsArray = [NSArray arrayWithArray:newTweet];
            self.timelineArray = [NSMutableArray arrayWithArray:newTweet];
            
            ASYNC_MAIN_QUEUE ^{
                
                [ActivityIndicator off];
                [wself setOtherTweetsBarItems];
                [wself.timeline reloadData];
                [wself scrollTimelineToTop:NO];
                [wself.timeline flashScrollIndicators];
            });
            
            dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
            dispatch_async(queue, ^ {
                
                [wself getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
                newTweet = nil;
            });
            
        }else {
            
            [ShowAlert error:@"UserTimelineが読み込めませんでした。"];
        }
        
    }@finally {
        
        ASYNC_MAIN_QUEUE ^{
            
            [wself finishLoad];
        });
    }
}

- (void)loadMentions:(NSNotification *)center {
    
    NSLog(@"loadMentions");
    
    __weak TimelineViewController *wself = self;
    
    @try {
        
        if ( ![center.userInfo[@"Type"] isEqualToString:@"Mentions"] ) return;
        
        //Mentionsタブ以外が選択されている場合は終了
        if ( _timelineSegment.selectedSegmentIndex != 1 ) return;
        
        //UserStream接続中の場合は切断する
        if ( _userStream ) [self closeStream];
        
        _reloadButton.enabled = YES;
        _timelineControlButton.enabled = NO;
        
        if ( [center.userInfo[@"Result"] isEqualToString:@"MentionsSuccess"] ) {
            
            __block NSArray *newTweet = [[NSArray alloc] initWithArray:center.userInfo[@"Mentions"]];
            
            //t.coを展開
            newTweet = [TWEntities replaceTcoAll:newTweet];
            
            //NG判定を行う
            newTweet = [TWNgTweet ngAll:newTweet];
            
            //InReplyToからの復帰用に保存しておく
            self.mentionsArray = [NSArray arrayWithArray:newTweet];
            self.timelineArray = [NSMutableArray arrayWithArray:newTweet];
            
            ASYNC_MAIN_QUEUE ^{
                
                [ActivityIndicator off];
                [wself.timeline reloadData];
                [wself scrollTimelineToTop:NO];
                [wself.timeline flashScrollIndicators];
            });
            
            dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
            dispatch_async(queue, ^ {
                
                [wself getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
                newTweet = nil;
            });
        }
        
    }@finally {
        
        ASYNC_MAIN_QUEUE ^{
            
            [wself finishLoad];
        });
    }
}

- (void)loadFavorites:(NSNotification *)center {
    
    NSLog(@"loadFavorites");
    
    __weak TimelineViewController *wself = self;
    
    @try {
        
        if ( ![center.userInfo[@"Type"] isEqualToString:@"Favorites"] ) return;
        
        //Favoritesタブ以外が選択されている場合は終了
        if ( _timelineSegment.selectedSegmentIndex != 2 ) return;
        
        //UserStream接続中の場合は切断する
        if ( _userStream ) [self closeStream];
        
        _timelineControlButton.enabled = NO;
        _reloadButton.enabled = YES;
        
        NSString *result = [[NSString alloc] initWithString:center.userInfo[@"Result"]];
        
        if ( [result isEqualToString:@"FavoritesSuccess"] ) {
            
            __block NSArray *newTweet = [[NSArray alloc] initWithArray:center.userInfo[@"Favorites"]];
            
            //t.coを展開
            newTweet = [TWEntities replaceTcoAll:newTweet];
            
            //InReplyToからの復帰用に保存しておく
            self.mentionsArray = [NSArray arrayWithArray:newTweet];
            self.timelineArray = [NSMutableArray arrayWithArray:newTweet];
            
            ASYNC_MAIN_QUEUE ^{
                
                [ActivityIndicator off];
                [wself.timeline reloadData];
                [wself scrollTimelineToTop:NO];
                [wself.timeline flashScrollIndicators];
            });
            
            dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
            dispatch_async(queue, ^ {
                
                [wself getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
                newTweet = nil;
            });
        }
        
    }@finally {
        
        ASYNC_MAIN_QUEUE ^{
            
            [wself finishLoad];
        });
    }
}

- (void)loadSearch:(NSNotification *)center {
    
    NSLog(@"loadSearch");
    
    __weak TimelineViewController *wself = self;
    
    @try {
        
        if ( ![center.userInfo[@"Type"] isEqualToString:@"Search"] ) return;
        
        //UserStream接続中の場合は切断する
        if ( _userStream ) [self closeStream];
        
        _timelineControlButton.enabled = NO;
        
        NSString *result = [[NSString alloc] initWithString:center.userInfo[@"Result"]];
        
        if ( [result isEqualToString:@"SearchSuccess"] ) {
            
            __block NSArray *newTweet = [[NSArray alloc] initWithArray:center.userInfo[@"Search"]];
            
            //InReplyToからの復帰用に保存しておく
            self.mentionsArray = [NSArray arrayWithArray:newTweet];
            self.timelineArray = [NSMutableArray arrayWithArray:newTweet];
            
            ASYNC_MAIN_QUEUE ^{
                
                [ActivityIndicator off];
                [wself.timeline reloadData];
                [wself scrollTimelineToTop:NO];
                [wself setOtherTweetsBarItems];
                [wself.timeline flashScrollIndicators];
            });
            
            dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
            dispatch_async(queue, ^ {
                
                [wself getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
                newTweet = nil;
            });
        }
        
    }@finally {
        
        ASYNC_MAIN_QUEUE ^{
            
            [wself finishLoad];
        });
    }
}

- (void)loadList:(NSNotification *)center {
    
    NSLog(@"loadList");
    
    __weak TimelineViewController *wself = self;
    
    @try {
        
        if ( ![center.userInfo[@"Type"] isEqualToString:@"List"] ) return;
        
        //Listタブ以外が選択されている場合は終了
        if ( _timelineSegment.selectedSegmentIndex != 3 ) return;
        
        _reloadButton.enabled = YES;
        
        NSArray *newTweet = [[NSArray alloc] initWithArray:center.userInfo[@"ResultData"]];
        
        //t.coを展開
        newTweet = [TWEntities replaceTcoAll:newTweet];
        
        //NG判定を行う
        newTweet = [TWNgTweet ngAll:newTweet];
        
        _currentList = [NSMutableArray arrayWithArray:newTweet];
        newTweet = nil;
        
        [_allLists setObject:[NSMutableArray arrayWithArray:_currentList]
                      forKey:[NSString stringWithString:APP_DELEGATE.listId]];
        
        self.timelineArray = [NSMutableArray arrayWithArray:_currentList];
        
        ASYNC_MAIN_QUEUE ^{
            
            [ActivityIndicator off];
            [wself.timeline reloadData];
            [wself scrollTimelineToTop:NO];
            [wself.timeline flashScrollIndicators];
        });
        
        dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
        dispatch_async(queue, ^ {
            
            [wself getIconWithTweetArray:[NSMutableArray arrayWithArray:wself.timelineArray]];
        });
        
    }@finally {
        
        ASYNC_MAIN_QUEUE ^{
            
            [wself finishLoad];
        });
    }
}

- (void)getIconWithTweetArray:(NSMutableArray *)tweetArray {
    
    //  NSLog(@"getIconWithTweetArray[%d]", tweetArray.count);
    //  NSLog(@"getIconWithTweetArray: %@", tweetArray);
    
    NSMutableDictionary *userList = [NSMutableDictionary dictionary];
    
    //重複ユーザーを消す
    for ( NSDictionary *tweet in tweetArray ) {
        
        NSString *tempScreenName = tweet[@"user"][@"screen_name"];
        
        if ( tempScreenName == nil ) {
            
            tempScreenName = tweet[@"screen_name"];
        }
        
        [userList setObject:[NSDictionary dictionaryWithDictionary:tweet]
                     forKey:[NSString stringWithString:tempScreenName]];
        
        if ( [tweet[@"retweeted_status"] boolForKey:@"id"] &&
            userList[tweet[@"retweeted_status"][@"user"][@"screen_name"]] == nil ) {
            
            [userList setObject:[NSDictionary dictionaryWithDictionary:tweet[@"retweeted_status"]]
                         forKey:[NSString stringWithString:tweet[@"retweeted_status"][@"user"][@"screen_name"]]];
        }
    }
    
    //  NSLog(@"getIconWithTweetArray delete duplicate user[%d], %@", userList.count, userList);
    
    for ( NSString *userName in userList.allKeys ) {
        
        NSDictionary *dic = userList[userName];
        
        if ( [[Share images] objectForKey:userName] == nil ) {
            
            //キャッシュされていない
            //NSLog(@"No Cache User: %@", userName);
            
            //アイコンのユーザー名
            __block NSString *screenName = dic[@"user"][@"screen_name"];
            
            if ( screenName == nil ) {
                
                screenName = dic[@"screen_name"];
            }
            
            //biggerサイズのURL
            NSString *biggerUrl = [TWIconBigger normal:dic[@"user"][@"profile_image_url"]];
            
            if ( biggerUrl == nil ) {
                
                biggerUrl = [TWIconBigger normal:dic[@"profile_image_url"]];
            }
            
            //検索用の名前
            __block NSString *searchName = [[NSString alloc] initWithFormat:@"%@_%@", screenName, [biggerUrl lastPathComponent]];
            
            if ( [APP_DELEGATE iconExist:searchName] ) {
                
                //アイコンファイルが保存済み
                //NSLog(@"File Saved: %@", userName);
                
                //アイコンファイルを読み込み
                __block UIImage *image = [[UIImage alloc] initWithContentsOfFile:FILE_PATH];
                
                if ( image != nil ) {
                    
                    [Share cacheImage:image
                              forName:[NSString stringWithString:screenName]
                     doneNotification:NO];
                    
                    int index = 0;
                    for ( NSDictionary *tweet in _timelineArray ) {
                        
                        NSString *currentScreenName = tweet[@"user"][@"screen_name"];
                        
                        if ( currentScreenName == nil ) {
                            
                            currentScreenName = tweet[@"screen_name"];
                        }
                        
                        if ( [currentScreenName isEqualToString:screenName] ) {
                            
                            [self refreshTimelineCell:[NSNumber numberWithInt:index]];
                        }
                        
                        index++;
                        
                        if ( 8 < index ) break;
                    }
                    
                    //自分のアイコンの場合は上部バーに設定
                    if ( [screenName isEqualToString:[TWAccounts currentAccountName]] ) {
                        
                        __weak TimelineViewController *wself = self;
                        
                        ASYNC_MAIN_QUEUE ^{
                            
                            wself.accountIconView.image = image;
                            image = nil;
                        });
                    }
                    
                    [ActivityIndicator off];
                    
                }else {
                    
                    [self requestProfileImageWithURL:[NSString stringWithString:biggerUrl]
                                          screenName:[NSString stringWithString:screenName]
                                          searchName:[NSString stringWithString:searchName]];
                }
                
            }else {
                
                //アイコンファイルが保存されていない
                [self requestProfileImageWithURL:[NSString stringWithString:biggerUrl]
                                      screenName:[NSString stringWithString:screenName]
                                      searchName:[NSString stringWithString:searchName]];
            }
            
        }else {
            
            //キャッシュ済み
            //NSLog(@"Cached User: %@", userName);
        }
    }
}

- (void)requestProfileImageWithURL:(NSString *)biggerUrl screenName:(NSString *)screenName searchName:(NSString *)searchName {
    
    if ( [screenName isNotEmpty] &&
        [biggerUrl isNotEmpty] &&
        [[biggerUrl lastPathComponent] isNotEmpty] &&
        [searchName isNotEmpty] ) {
        
        NSMutableDictionary *tempDic = BLANK_M_DIC;
        
        //ユーザー名を設定
        [tempDic setObject:[NSString stringWithString:screenName]
                    forKey:@"screen_name"];
        
        //アイコンURLを設定
        [tempDic setObject:[NSString stringWithString:biggerUrl]
                    forKey:@"profile_image_url"];
        
        //検索用の名前
        [tempDic setObject:[NSString stringWithString:searchName]
                    forKey:@"SearchName"];
        
        __weak TimelineViewController *wself = self;
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:biggerUrl]];
        request.userInfo = [NSDictionary dictionaryWithDictionary:tempDic];
        __block __weak ASIHTTPRequest *wRequest = request;
        
        [wRequest setCompletionBlock:^ {
            
            //NSLog(@"Request Finished");
            
            if ( ![APP_DELEGATE iconExist:searchName] ) {
                
                [wRequest.responseData writeToFile:[NSString stringWithString:FILE_PATH]
                                        atomically:YES];
            }
            
            NSString *receiveScreenName = [[NSString alloc] initWithString:wRequest.userInfo[@"screen_name"]];
            __block __weak NSString *wReceiveScreenName = receiveScreenName;
            
            UIImage *receiveImage = [[UIImage alloc] initWithData:wRequest.responseData];
            
            if ( receiveImage != nil ) {
                
                [Share cacheImage:receiveImage
                          forName:[NSString stringWithString:receiveScreenName]
                 doneNotification:NO];
                
                receiveImage = nil;
                
                if ( [screenName isEqualToString:[TWAccounts currentAccountName]] ) {
                    
                    ASYNC_MAIN_QUEUE ^{
                        
                        wself.accountIconView.image = [[Share images] imageForKey:wReceiveScreenName];
                        wReceiveScreenName = nil;
                    });
                }
                
                int index = 0;
                for ( NSDictionary *tweet in wself.timelineArray ) {
                    
                    NSString *currentScreenName = tweet[@"user"][@"screen_name"];
                    
                    if ( currentScreenName == nil ) {
                        
                        currentScreenName = tweet[@"screen_name"];
                    }
                    
                    if ( [currentScreenName isEqualToString:screenName] ) {
                        
                        [wself refreshTimelineCell:[NSNumber numberWithInt:index]];
                    }
                    
                    index++;
                }
            }
            
            wRequest = nil;
        }];
        
        [request startAsynchronous];
    }
}

- (void)changeAccount:(NSNotification *)notification {
    
    //Tweet画面でアカウントが切り替えられた際に呼ばれる
    NSLog(@"changeAccount");
    
    //UserStreamが有効な場合切断する
    if ( _userStream ) [self closeStream];
    
    //自分のアカウントを設定
    [self getMyAccountIcon];
    
    //List一覧のキャッシュを削除
    APP_DELEGATE.listAll = nil;
    APP_DELEGATE.listAll = BLANK_ARRAY;
    
    //タイムラインをアクティブアカウントの物に切り替え
    self.timelineArray = [NSMutableArray arrayWithArray:[TWTweets currentTimeline]];
    [_timeline reloadData];
    
    __weak TimelineViewController *wself = self;
    
    //リロードする
    DISPATCH_AFTER(0.1) ^{
        
        [wself createTimeline];
    });
}

- (void)refreshTimelineCell:(NSNumber *)index {
    
    int i = [index intValue];
    
    if ( _timelineArray[i] == nil ||
         _timelineArray.count - 1 < i ) return;
    
    //NSLog(@"refreshTimelineCell: %d", i);
    
    __weak TimelineViewController *wself = self;
    
    ASYNC_MAIN_QUEUE ^{
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
        [wself.timeline reloadRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationNone];
    });
}

- (void)copyTweetInUrl:(NSArray *)urlList {
    
    NSLog(@"copyTweetInUrl[%d]: %@", urlList.count, urlList);
    
    if ( urlList.count == 0 ) {
        
        [ShowAlert error:@"Tweet内にURLがありません。"];
        
    }else if ( urlList.count == 1 ) {
        
        [P_BOARD setString:[urlList objectAtIndex:0]];
        self.tweetInUrls = nil;
        _tweetInUrls = BLANK_ARRAY;
        
    }else if ( urlList.count == 2 ) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"Tweet内のURLをコピー"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:[urlList objectAtIndex:0],
                                [urlList objectAtIndex:1], nil];
        sheet.tag = 7;
        
        [sheet showInView:APP_DELEGATE.tabBarController.view];
        
    }else if ( urlList.count == 3 ) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"Tweet内のURLをコピー"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:[urlList objectAtIndex:0],
                                [urlList objectAtIndex:1],
                                [urlList objectAtIndex:2], nil];
        sheet.tag = 8;
        
        [sheet showInView:APP_DELEGATE.tabBarController.view];
        
    }else if ( urlList.count == 4 ) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"Tweet内のURLをコピー"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:[urlList objectAtIndex:0],
                                [urlList objectAtIndex:1],
                                [urlList objectAtIndex:2],
                                [urlList objectAtIndex:3], nil];
        sheet.tag = 9;
        
        [sheet showInView:APP_DELEGATE.tabBarController.view];
        
    }else if ( urlList.count == 5 ) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"Tweet内のURLをコピー"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:[urlList objectAtIndex:0],
                                [urlList objectAtIndex:1],
                                [urlList objectAtIndex:2],
                                [urlList objectAtIndex:3],
                                [urlList objectAtIndex:4], nil];
        sheet.tag = 10;
        
        [sheet showInView:APP_DELEGATE.tabBarController.view];
        
    }else if ( urlList.count >= 6 ) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"Tweet内のURLをコピー"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:[urlList objectAtIndex:0],
                                [urlList objectAtIndex:1],
                                [urlList objectAtIndex:2],
                                [urlList objectAtIndex:3],
                                [urlList objectAtIndex:4],
                                [urlList objectAtIndex:5], nil];
        sheet.tag = 11;
        
        [sheet showInView:APP_DELEGATE.tabBarController.view];
    }
}

- (void)checkTimelineCount:(BOOL)animated {
    
    int max = 400;
    if ( _searchStream ) max = 100;
    
    if ( _timelineArray.count > max ) {
        
        __weak TimelineViewController *wself = self;
        
        dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        dispatch_sync(queue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            while ( wself.timelineArray.count > max ) {
                
                [wself.timelineArray removeLastObject];
                
                if ( animated ) {
                    
                    [wself.timeline deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:wself.timelineArray.count - 1
                                                                                inSection:0]]
                                          withRowAnimation:UITableViewRowAnimationBottom];
                }
            }
            
            dispatch_semaphore_signal(semaphore);
            dispatch_release(semaphore);
        });
    }
}

#pragma mark - In reply to

- (void)getInReplyToChain:(NSDictionary *)tweetData {
    
    NSString *inReplyToId = tweetData[@"in_reply_to_status_id_str"];
    
    NSLog(@"getInReplyToChain: %@", inReplyToId);
    
    __weak TimelineViewController *wself = self;
    
    if ( ![EmptyCheck check:inReplyToId] ||
        [inReplyToId isEqualToString:@"END"] ) {
        
        //InReplyToIDがもうない場合は表示を行う
        
        if ( [EmptyCheck check:_inReplyTo] && _inReplyTo.count > 1 ) {
            
            NSLog(@"InReplyTo GET END");
            
            [self closeStream];
            
            dispatch_queue_t globalQueue = GLOBAL_QUEUE_DEFAULT;
            dispatch_async(globalQueue, ^{
                
                //表示開始
                ASYNC_MAIN_QUEUE ^{
                    
                    //t.coを展開
                    wself.inReplyTo = [TWEntities replaceTcoAll:wself.inReplyTo];
                    
                    [wself setOtherTweetsBarItems];
                    
                    wself.timelineArray = BLANK_M_ARRAY;
                    [wself.timeline reloadData];
                    
                    for ( NSDictionary *tweet in wself.inReplyTo ) {
                        
                        //タイムラインに追加
                        [wself.timelineArray insertObject:tweet
                                                  atIndex:0];
                        [wself.timeline insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                              withRowAnimation:UITableViewRowAnimationRight];
                    }
                    
                    //タイムラインからアイコンのURLを取得
                    dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
                    dispatch_async(queue, ^ {
                        
                        [wself getIconWithTweetArray:[NSMutableArray arrayWithArray:wself.timelineArray]];
                    });
                });
            });
        }
        
    }else {
        
        dispatch_queue_t globalQueue = GLOBAL_QUEUE_DEFAULT;
        dispatch_async(globalQueue, ^{
            
            [ActivityIndicator on];
            
            __block NSDictionary *findTweet = nil;
            
            [wself.timelineArray enumerateObjectsUsingBlock:
             ^( NSDictionary *searchTweet, NSUInteger index, BOOL *stop ) {
                 
                 NSString *searchTweetID = [[NSString alloc] initWithString:searchTweet[@"id_str"]];
                 
                 if ( [searchTweetID isNotEmpty] ) {
                     
                     if ( [searchTweetID isEqualToString:inReplyToId] ) {
                         
                         findTweet = [NSDictionary dictionaryWithDictionary:searchTweet];
                         [wself.inReplyTo insertObject:findTweet atIndex:0];
                         searchTweet = nil;
                         searchTweetID = nil;
                         *stop = YES;
                     }
                 }
                 
                 searchTweetID = nil;
             }];
            
            if ( findTweet != nil ) {
                
                NSLog(@"InReplyTo TL");
                
                [wself getInReplyToChain:findTweet];
                
            }else {
                
                NSLog(@"InReplyTo REST");
                
                [TWEvent getTweet:inReplyToId];
            }
        });
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //TableViewの要素数を返す
	return _timelineArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"cellForRowAtIndexPath: %d", indexPath.row);
    
    __weak NSDictionary *currentTweet = _timelineArray[indexPath.row];
    
    if ( [currentTweet[@"retweeted_status"] boolForKey:@"id"] ) {
        
        //公式RT
        __autoreleasing TimelineAttributedRTCell *cell = (TimelineAttributedRTCell *)[tableView dequeueReusableCellWithIdentifier:RT_CELL_IDENTIFIER];
        
        if ( cell == nil ) {
            
            cell = [[TimelineAttributedRTCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:RT_CELL_IDENTIFIER
                                                          forWidth:264];
            [cell.iconView addTarget:self
                              action:@selector(pushIcon:)
                    forControlEvents:UIControlEventTouchUpInside];
        }
        
        @autoreleasepool {
            
            //Tweetの本文
            __weak NSString *text = currentTweet[@"text"];
            
            //ID
            __weak NSString *screenName = currentTweet[@"retweeted_status"][@"user"][@"screen_name"];
            cell.iconView.buttonTitle = [NSString stringWithString:screenName];
            
            //ID - 日付 [クライアント名]
            __weak NSString *infoLabelText = currentTweet[@"info_text"];
            
            if ( [[Share images] objectForKey:screenName] != nil &&
                cell.iconView.layer.sublayers.count != 0 ) {
                
                [cell.iconView.layer.sublayers[0] setContents:(id)[[Share images] imageForKey:screenName].CGImage];
                
            }else {
                
                [cell.iconView.layer.sublayers[0] setContents:nil];
            }
            
            __weak NSString *userName = currentTweet[@"rt_user"];
            if ( [[Share images] objectForKey:userName] != nil &&
                cell.iconView.layer.sublayers.count != 0 ) {
                
                [cell.iconView.layer.sublayers[1] setContents:(id)[[Share images] imageForKey:userName].CGImage];
                
            }else {
                
                [cell.iconView.layer.sublayers[1] setContents:nil];
            }
            
            //Favoriteの色を変えて星をつける
            if ( [currentTweet boolForKey:@"favorited"] ) {
                
                infoLabelText = [NSMutableString stringWithFormat:@"★%@", infoLabelText];
            }
            
            CGFloat contentsHeight = [currentTweet integerForKey:@"contents_height"];
            
            //セルへの反映開始
            cell.infoLabel.text = [NSString stringWithString:infoLabelText];
            
            NSMutableAttributedString *mainText = [NSMutableAttributedString attributedStringWithString:text];
            [mainText setFont:[UIFont systemFontOfSize:12]];
            [mainText setTextColor:GREEN_COLOR range:NSMakeRange(0, text.length)];
            [mainText setTextAlignment:kCTLeftTextAlignment
                         lineBreakMode:kCTLineBreakByCharWrapping
                         maxLineHeight:14.0
                         minLineHeight:14.0
                        maxLineSpacing:1.0
                        minLineSpacing:1.0
                                 range:NSMakeRange(0, mainText.length)];
            cell.mainLabel.attributedText = mainText;
            
            //セルの高さを設定
            cell.mainLabel.frame = CGRectMake(54, 19, 264, contentsHeight);
        }
        
        return cell;
        
    }else {
        
        __autoreleasing TimelineAttributedCell *cell = (TimelineAttributedCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
        
        if ( cell == nil ) {
            
            cell = [[TimelineAttributedCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:CELL_IDENTIFIER
                                                        forWidth:264];
            [cell.iconView addTarget:self
                              action:@selector(pushIcon:)
                    forControlEvents:UIControlEventTouchUpInside];
        }
        
        @autoreleasepool {
            
            //Tweetの本文
            __weak NSString *text = currentTweet[@"text"];
            
            //ID
            __weak NSString *screenName = currentTweet[@"user"][@"screen_name"];
            cell.iconView.buttonTitle = [NSString stringWithString:screenName];
            
            //ID - 日付 [クライアント名]
            __weak NSString *infoLabelText = currentTweet[@"info_text"];
            
            if ( [[Share images] objectForKey:screenName] != nil &&
                cell.iconView.layer.sublayers.count != 0 &&
                [[cell.iconView.layer.sublayers.lastObject name] isEqualToString:@"Icon"] ) {
                
                [cell.iconView.layer.sublayers.lastObject setContents:(id)[[Share images] imageForKey:screenName].CGImage];
                
            }else {
                
                [cell.iconView.layer.sublayers.lastObject setContents:nil];
            }
            
            CGFloat contentsHeight = [currentTweet integerForKey:@"contents_height"];
            
            //ふぁぼられイベント用
            if ( currentTweet[@"FavEvent"] != nil ) {
                
                NSString *temp = [NSString stringWithString:infoLabelText];
                infoLabelText = [NSString stringWithFormat:@"【%@がお気に入りに追加】",
                                 currentTweet[@"addUser"]];
                
                text = [NSString stringWithFormat:@"%@\n%@", temp, text];
                contentsHeight = [text heightForContents:[UIFont systemFontOfSize:12.0]
                                                 toWidht:264
                                               minHeight:31
                                           lineBreakMode:NSLineBreakByCharWrapping];
                temp = nil;
            }
            
            //セルへの反映開始
            cell.infoLabel.text = [NSString stringWithString:infoLabelText];
            cell.infoLabel.textColor = [self getTextColor:[currentTweet integerForKey:@"text_color"]];
            
            NSMutableAttributedString *mainText = [NSMutableAttributedString attributedStringWithString:text];
            [mainText setFont:[UIFont systemFontOfSize:12]];
            [mainText setTextColor:[self getTextColor:[currentTweet integerForKey:@"text_color"]] range:NSMakeRange(0, text.length)];
            [mainText setTextAlignment:kCTLeftTextAlignment
                         lineBreakMode:kCTLineBreakByCharWrapping
                         maxLineHeight:14.0
                         minLineHeight:14.0
                        maxLineSpacing:1.0
                        minLineSpacing:1.0
                                 range:NSMakeRange(0, mainText.length)];
            cell.mainLabel.attributedText = mainText;
            
            //セルの高さを設定
            cell.mainLabel.frame = CGRectMake(54, 19, 264, contentsHeight);
        }
        
        return cell;
    }
}

- (UIColor *)getTextColor:(CellTextColor)color {
    
    if ( color == CellTextColorBlack ) return BLACK_COLOR;
    if ( color == CellTextColorRed )   return RED_COLOR;
    if ( color == CellTextColorBlue )  return BLUE_COLOR;
    if ( color == CellTextColorGreen ) return GREEN_COLOR;
    if ( color == CellTextColorGold )  return GOLD_COLOR;
    
    return BLACK_COLOR;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルの高さを設定
    __weak NSDictionary *currentTweet = _timelineArray[indexPath.row];
    
    if ( currentTweet[@"FavEvent"] != nil ) {
        
        return [[NSString stringWithFormat:@"【%@がお気に入りに追加】\n%@",
                 currentTweet[@"addUser"],
                 currentTweet[@"text"]]
                heightForContents:[UIFont systemFontOfSize:12]
                toWidht:264
                minHeight:31
                lineBreakMode:NSLineBreakByCharWrapping] + 25;
    }
    
    return [currentTweet[@"contents_height"] integerValue] + 25;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"didSelectRowAtIndexPath");
    
    //セルの選択状態を解除
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( !_webBrowserMode ) {
        
        //ピッカー表示中は何もしない
        if ( _pickerVisible ) return;
        
        if ( _showMenu ) {
            
            [self hideTimelineMenu:nil];
            
        }else {
            
            __weak TimelineViewController *wself = self;
            wself.showMenu = YES;
            wself.selectRow = indexPath.row;
            wself.selectTweet = [wself.timelineArray objectAtIndex:indexPath.row];
            
            if ( wself.selectTweet[@"FavEvent"] == nil ) {
                
                wself.topBar.userInteractionEnabled = NO;
                wself.timelineSegment.userInteractionEnabled = NO;
                
                wself.timelineMenu = [[TimelineMenu alloc] initWithTweet:wself.selectTweet];
                wself.timelineMenu.alpha = 0.0;
                [wself.view addSubview:wself.timelineMenu];
                
                DISPATCH_AFTER(0.1) ^{
                    
                    [UIView animateWithDuration:0.3
                                     animations:^{
                                         
                                         wself.timelineMenu.alpha = 1.0;
                                         wself.timelineMenu.frame = CGRectMake(wself.timelineMenu.frame.origin.x,
                                                                               0,
                                                                               wself.timelineMenu.frame.size.width,
                                                                               wself.timelineMenu.frame.size.height);
                                     }
                     ];
                });
                
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     
                                     wself.topBar.frame = CGRectMake(266,
                                                                     wself.topBar.frame.origin.y,
                                                                     wself.topBar.frame.size.width,
                                                                     wself.topBar.frame.size.height);
                                     
                                     wself.accountIconView.frame = CGRectMake(wself.accountIconView.frame.origin.x + 266,
                                                                              wself.accountIconView.frame.origin.y,
                                                                              wself.accountIconView.frame.size.width,
                                                                              wself.accountIconView.frame.size.height);
                                     
                                     wself.timelineSegment.frame = CGRectMake(266,
                                                                              wself.timelineSegment.frame.origin.y,
                                                                              wself.timelineSegment.frame.size.width,
                                                                              wself.timelineSegment.frame.size.height);
                                     
                                     wself.timeline.frame = CGRectMake(266,
                                                                       wself.timeline.frame.origin.y,
                                                                       wself.timeline.frame.size.width,
                                                                       wself.timeline.frame.size.height);
                                 }
                 ];
                
            }else {
                
                NSString *targetId = [[NSString alloc] initWithString:_selectTweet[@"id_str"]];
                NSString *favStarUrl = [[NSString alloc] initWithFormat:@"http://ja.favstar.fm/users/%@/status/%@",
                                        [TWAccounts currentAccountName],
                                        targetId];
                
                APP_DELEGATE.startupUrlList = [NSArray arrayWithObject:favStarUrl];
                
                [self openBrowser];
            }
        }
    }
}

//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
//
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//
//}

- (void)scrollTimelineForNewTweet:(NSString *)tweetID {
    
    __weak TimelineViewController *wself = self;
    
    dispatch_queue_t globalQueue = GLOBAL_QUEUE_DEFAULT;
    dispatch_async(globalQueue, ^{
        
        //Tweetがない場合はスクロールしない
        if ( wself.timelineArray == nil ||
            wself.timelineArray.count == 0 ) return;
        
        //スクロールするIDがない場合は終了
        if ( tweetID == nil ||
            [tweetID isEqualToString:@""] ) return;
        
        //スクロールするインデックスを検索
        int index = 0;
        BOOL find = NO;
        for ( NSDictionary *tweet in [TWTweets currentTimeline] ) {
            
            if ( tweet[@"id_str"] != nil &&
                [tweet[@"id_str"] isEqualToString:tweetID] ) {
                
                find = YES;
                break;
            }
            
            index++;
        }
        
        if ( find ) {
            
            if ( wself.timelineArray.count < index ||
                [wself.timelineArray objectAtIndex:index] == nil ) return;
            
            ASYNC_MAIN_QUEUE ^{
                
                //スクロールする
                [wself.timeline scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index
                                                                          inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom
                                              animated:YES];
            });
        }
    });
}

- (void)scrollTimelineToTop:(BOOL)animation {
    
    //Tweetがない場合はスクロールしない
    if ( _timelineArray == nil ||
        _timelineArray.count == 0 ) return;
    
    //一番上にスクロールする
    [_timeline scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                     atScrollPosition:UITableViewScrollPositionBottom
                             animated:animation];
}

- (void)scrollTimelineToBottom:(BOOL)animation {
    
    //Tweetがない場合はスクロールしない
    if ( _timelineArray == nil ||
        _timelineArray.count == 0 ) return;
    
    //一番下にスクロールする
    [_timeline scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_timelineArray.count - 1
                                                         inSection:0]
                     atScrollPosition:UITableViewScrollPositionBottom
                             animated:animation];
}

- (void)pushIcon:(TitleButton *)sender {
    
    //    NSLog(@"pushIcon: %d", sender.tag);
    
    if ( _showMenu ) {
        
        [self hideTimelineMenu:nil];
        
    }else {
        
        _alertSearchUserName = sender.buttonTitle;
        _selectAccount = _alertSearchUserName;
        
        //      NSLog(@"_alertSearchUserName: %@", _alertSearchUserName);
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"外部サービスやユーザー情報を開く"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"Twilog", @"TwilogSearch", @"favstar", @"Twitpic", @"UserTimeline", @"TwitterSearch", @"TwitterSearch(Stream)", nil];
        
        sheet.tag = 1;
        _alertSearchType = NO;
        
        [sheet showInView:APP_DELEGATE.tabBarController.view];
    }
}

- (void)openTimelineURL:(NSNotification *)notification {
    
    NSString *urlString = [[NSString alloc] initWithString:notification.userInfo[@"URL"]];
    
    if ( urlString == nil ) {
        
        return;
    }
    
    APP_DELEGATE.startupUrlList = @[urlString];
    [self openBrowser];
}

- (void)openTimelineImage:(NSNotification *)notification {
    
    if ( notification.userInfo[@"URL"] != nil ) {
        
        NSString *urlString = [[NSString alloc] initWithString:notification.userInfo[@"URL"]];
        
        [_imageWindow loadImage:urlString viewRect:_timeline.frame];
    }
}

- (void)timelineMenuAction:(NSNotification *)notification {
    
    [self hideTimelineMenu:notification];
}

- (void)hideTimelineMenu:(NSNotification *)notification {
    
    __weak TimelineViewController *wself = self;
    
    DISPATCH_AFTER(0.2) ^{
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             
                             wself.topBar.frame = CGRectMake(0,
                                                             wself.topBar.frame.origin.y,
                                                             wself.topBar.frame.size.width,
                                                             wself.topBar.frame.size.height);
                             
                             wself.accountIconView.frame = CGRectMake(142,
                                                                      wself.accountIconView.frame.origin.y,
                                                                      wself.accountIconView.frame.size.width,
                                                                      wself.accountIconView.frame.size.height);
                             
                             wself.timelineSegment.frame = CGRectMake(-4,
                                                                      wself.timelineSegment.frame.origin.y,
                                                                      wself.timelineSegment.frame.size.width,
                                                                      wself.timelineSegment.frame.size.height);
                             
                             wself.timeline.frame = CGRectMake(0,
                                                               wself.timeline.frame.origin.y,
                                                               wself.timeline.frame.size.width,
                                                               wself.timeline.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             
                             wself.showMenu = NO;
                             wself.topBar.userInteractionEnabled = YES;
                             wself.timelineSegment.userInteractionEnabled = YES;
                             
                             if ( wself.timelineMenu != nil ) [wself.timelineMenu removeFromSuperview];
                             [wself setTimelineMenu:nil];
                             
                             if ( notification.userInfo[@"Action"] != nil ) {
                                 
                                 __block NSUInteger actionNo = [notification.userInfo uintegerForKey:@"Action"];
                                 __block NSString *type = [notification.userInfo stringForKey:@"Type"];
                                 __block NSString *targetUser = nil;
                                 
                                 if ( [type isEqualToString:@"User"] ) {
                                     
                                     targetUser = [notification.userInfo stringForKey:@"TargetUser"];
                                 }
                                 
                                 dispatch_queue_t globalQueue = GLOBAL_QUEUE_DEFAULT;
                                 dispatch_async(globalQueue, ^{
                                     
                                     if ( [type isEqualToString:@"Main"] ) {
                                         
                                         switch ( actionNo ) {
                                                 
                                             case TimelineMenuActionReply:
                                                 [wself timelineMenuActionReply];
                                                 break;
                                                 
                                             case TimelineMenuActionFavorite:
                                                 [wself timelineMenuActionFavorite];
                                                 break;
                                                 
                                             case TimelineMenuActionReTweet:
                                                 [wself timelineMenuActionReTweet];
                                                 break;
                                                 
                                             case TimelineMenuActionFavRT:
                                                 [wself timelineMenuActionFavRT];
                                                 break;
                                                 
                                             case TimelineMenuActionSelectID:
                                                 [wself timelineMenuActionSelectID];
                                                 break;
                                                 
                                             case TimelineMenuActionNGTag:
                                                 [wself timelineMenuActionNGTag];
                                                 break;
                                                 
                                             case TimelineMenuActionNGClient:
                                                 [wself timelineMenuActionNGClient];
                                                 break;
                                                 
                                             case TimelineMenuActionInReplyTo:
                                                 [wself timelineMenuActionInReplyTo];
                                                 break;
                                                 
                                             case TimelineMenuActionCopy:
                                                 [wself timelineMenuActionCopy];
                                                 break;
                                                 
                                             case TimelineMenuActionDelete:
                                                 [wself timelineMenuActionDelete];
                                                 break;
                                                 
                                             case TimelineMenuActionEdit:
                                                 [wself timelineMenuActionEdit];
                                                 break;
                                                 
                                             case TimelineMenuActionUserMenu:
                                                 [wself timelineMenuActionUserMenu];
                                                 break;
                                                 
                                             default:
                                                 break;
                                         }
                                         
                                     }else if ( [type isEqualToString:@"Copy"] ) {
                                         
                                         switch ( actionNo ) {
                                                 
                                             case TimelineCopyMenuSTOT:
                                                 [wself timelineCopyMenuSTOT];
                                                 break;
                                                 
                                             case TimelineCopyMenuText:
                                                 [wself timelineCopyMenuText];
                                                 break;
                                                 
                                             case TimelineCopyMenuTweetURL:
                                                 [wself timelineCopyMenuTweetURL];
                                                 break;
                                                 
                                             case TimelineCopyMenuURL:
                                                 [wself timelineCopyMenuURL];
                                                 break;
                                                 
                                             default:
                                                 break;
                                         }
                                         
                                     }else if ( [type isEqualToString:@"User"] ) {
                                         
                                         [wself openTwitterService:targetUser serviceType:actionNo];
                                     }
                                 });
                             }
                         }
         ];
    });
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         
                         wself.timelineMenu.alpha = 0.0;
                         wself.timelineMenu.frame = CGRectMake(wself.timelineMenu.frame.origin.x,
                                                               wself.timelineMenu.frame.size.height,
                                                               wself.timelineMenu.frame.size.width,
                                                               wself.timelineMenu.frame.size.height);
                     }
     ];
}

- (void)receiveGrayViewDoneNotification:(NSNotification *)notification {
    
    NSLog(@"receiveGrayViewDoneNotification");
}

#pragma mark - ASIHTTPRequest

- (void)requestFinished:(ASIHTTPRequest *)request {
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    NSLog(@"requestFailed: %@", request.responseString);
    
    [ActivityIndicator off];
    
    if ( [InternetConnection enable] ) {
        
        //再送信
        NSURL *URL = [[NSURL alloc] initWithString:request.userInfo[@"profile_image_url"]];
        ASIHTTPRequest *reSendRequest = [[ASIHTTPRequest alloc] initWithURL:URL];
        reSendRequest.userInfo = request.userInfo;
        [reSendRequest setDelegate:self];
        [reSendRequest start];
    }
}

#pragma mark - IBAction

- (IBAction)pushPostButton:(UIBarButtonItem *)sender {
    
    //ピッカー表示中の場合は隠す
    if ( _pickerVisible ) [self hidePicker];
    
    APP_DELEGATE.tabChangeFunction = @"Post";
    self.tabBarController.selectedIndex = 0;
}

- (IBAction)pushReloadButton:(UIBarButtonItem *)sender {
    
    NSLog(@"pushReloadButton");
    
    //ピッカー表示中の場合は隠す
    if ( _pickerVisible ) [self hidePicker];
    
    //インターネット接続を確認
    if ( ![InternetConnection enable] ) return;
    
    //自分のアイコンを取得
    [self getMyAccountIcon];
    
    _reloadButton.enabled = NO;
    
    if ( _timelineSegment.selectedSegmentIndex == 0 ) {
        
        //タイムラインのセグメントが選択されている場合
        
        //アクティブアカウントのタイムラインを反映
        self.timelineArray = [NSMutableArray arrayWithArray:[TWTweets currentTimeline]];
        [_timeline reloadData];
        
        //リロード
        [self performSelectorInBackground:@selector(createTimeline) withObject:nil];
        
    }else if ( _timelineSegment.selectedSegmentIndex == 1 ) {
        
        //Mentionsを取得
        [TWGetTimeline performSelectorInBackground:@selector(mentions) withObject:nil];
        
    }else if ( _timelineSegment.selectedSegmentIndex == 2 ) {
        
        //Favoritesを取得
        [TWGetTimeline performSelectorInBackground:@selector(favotites) withObject:nil];
        
    }else if ( _timelineSegment.selectedSegmentIndex == 3 ) {
        
        if ( [APP_DELEGATE.listAll isNotEmpty] ) {
            
            [self finishLoad];
            return;
        }
        
        //リストを再読み込み
        [TWList getList:APP_DELEGATE.listId];
    }
}

- (IBAction)pushTimelineControlButton:(UIBarButtonItem *)sender {
    
    if ( _listMode ) {
        
        //ピッカー表示中の場合は隠す
        if ( _pickerVisible ) [self hidePicker];
        
        //Listモード中はList再選択を行う
        [self showListSelectView];
        
    }else if ( !_userStream && [InternetConnection enable] ) {
        
        //UserStream未接続かつインターネットに接続されている場合は接続する
        _userStream = YES;
        _timelineControlButton.enabled = NO;
        _userStreamFirstResponse = NO;
        
        __weak TimelineViewController *wself = self;
        
        DISPATCH_AFTER(0.6) ^{
            
            [wself openStream];
        });
        
    }else {
        
        //UserStream接続済み
        [self closeStream];
    }
}

- (IBAction)pushActionButton:(UIBarButtonItem *)sender {
    
    //ピッカー表示中の場合は隠す
    if ( _pickerVisible ) [self hidePicker];
    
    if ( sender != nil ) {
        
        _alertSearchUserName = [TWAccounts currentAccountName];
        _alertSearchType = YES;
        
    }else {
        
        _alertSearchType = NO;
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"外部サービスやユーザー情報を開く"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Twilog", @"TwilogSearch", @"favstar", @"Twitpic", @"UserTimeline", @"TwitterSearch", @"TwitterSearch(Stream)", nil];
    
    sheet.tag = 1;
    
    [sheet showInView:APP_DELEGATE.tabBarController.view];
}

- (IBAction)pushCloseOtherTweetsButton:(UIBarButtonItem *)sender {
    
    if ( _pickerVisible ) [self hidePicker];
    if ( _searchStream ) [self closeSearchStream];
    
    if ( !_searchStream ) {
        
        _listMode = NO;
        _otherTweetsMode = NO;
        [self setTimelineBarItems];
    }
    
    [self changeSegment:nil];
}

#pragma mark - UserStream

- (void)openStream {
    
    __weak TimelineViewController *wself = self;
    
    dispatch_queue_t userStreamQueue = GLOBAL_QUEUE_BACKGROUND;
    dispatch_async(userStreamQueue, ^{
        
        @autoreleasepool {
            
            NSLog(@"openStream");
            
            if ( [D boolForKey:@"USNoAutoLock"] ) [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            
            //UserStream接続リクエストの作成
            TWRequest *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://userstream.twitter.com/2/user.json"]
                                                     parameters:nil
                                                  requestMethod:TWRequestMethodPOST];
            
            //アカウントの設定
            [request setAccount:[TWAccounts currentAccount]];
            
            //接続開始
            wself.connection = [NSURLConnection connectionWithRequest:request.signedURLRequest
                                                             delegate:wself];
            [wself.connection start];
            
            // 終わるまでループさせる
            while ( wself.userStream ) {
                
//                @autoreleasepool {
                
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
//                }
            }
            
            request = nil;
        }
    });
}

- (void)closeStream {
    
    NSLog(@"closeStream");
    
    if ( [D boolForKey:@"USNoAutoLock"] ) [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    _userStream = NO;
    _userStreamFirstResponse = NO;
    
    __weak TimelineViewController *wself = self;
    
    ASYNC_MAIN_QUEUE ^{
        
        wself.timelineControlButton.enabled = YES;
        wself.timelineControlButton.image = wself.startImage;
    });
    
    if ( self.connection != nil ) {
        
        [self.connection cancel];
        [self.connection setDelegateQueue:nil];
        self.connection = nil;
    }
}

- (void)userStreamDelete:(NSDictionary *)receiveData {
    
    if ( _timelineArray.count == 0 ) return;
    
    __weak TimelineViewController *wself = self;
    __block int index = 0;
    __block BOOL find = NO;
    
    dispatch_queue_t globalQueue = GLOBAL_QUEUE_DEFAULT;
    dispatch_async(globalQueue, ^{
        
        //削除イベント
        NSString *deleteTweetId = [[NSString alloc] initWithString:receiveData[@"delete"][@"status"][@"id_str"]];
        
        //削除されたTweetを検索
        for ( NSDictionary *tweet in wself.timelineArray ) {
            
            if ( [tweet[@"id_str"] isEqualToString:deleteTweetId] ) {
                
                find = YES;
                break;
            }
            
            index++;
        }
        
        deleteTweetId = nil;
    });
    
    if ( find ) {
        
        SYNC_MAIN_QUEUE ^{
            
            //見つかった物を削除
            [wself.timelineArray removeObjectAtIndex:index];
            
            //タイムラインを保存
            [TWTweets saveCurrentTimeline:wself.timelineArray];
            
            [wself.timeline deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        });
    }
}

- (void)userStreamMyAddFavEvent:(NSDictionary *)receiveData {
    
    //自分のふぁぼりイベント
    NSString *favedTweetId = [[NSString alloc] initWithString:receiveData[@"target_object"][@"id_str"]];
    
    int index = 0;
    for ( NSDictionary *tweet in _timelineArray ) {
        
        if ( [tweet[@"id_str"] isEqualToString:favedTweetId] ) {
            
            __block NSMutableDictionary *favedTweet = [[NSMutableDictionary alloc] initWithDictionary:tweet];
            [favedTweet setObject:@"1"
                           forKey:@"favorited"];
            [favedTweet setObject:@(CellTextColorGold)
                           forKey:@"text_color"];
            
            NSString *infoText = [[NSString alloc] initWithString:[favedTweet stringForKey:@"info_text"]];
            infoText = [NSString stringWithFormat:@"★%@", infoText];
            [favedTweet setObject:[NSString stringWithString:infoText]
                           forKey:@"info_text"];
            infoText = nil;
            
            __weak TimelineViewController *wself = self;
            
            SYNC_MAIN_QUEUE ^{
                
                [wself.timelineArray replaceObjectAtIndex:index withObject:favedTweet];
                
                //タイムラインを保存
                [TWTweets saveCurrentTimeline:wself.timelineArray];
                
                //TL更新
                [wself.timeline reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationLeft];
                favedTweet = nil;
            });
            
            break;
        }
        
        index++;
    }
}

- (void)userStreamMyRemoveFavEvent:(NSDictionary *)receiveData {
    
    //自分のふぁぼり外しイベント
    NSString *favedTweetId = [[NSString alloc] initWithString:receiveData[@"target_object"][@"id_str"]];
    
    int index = 0;
    for ( NSDictionary *tweet in _timelineArray ) {
        
        if ( [tweet[@"id_str"] isEqualToString:favedTweetId] ) {
            
            __block NSMutableDictionary *favedTweet = [[NSMutableDictionary alloc] initWithDictionary:tweet];
            [favedTweet setObject:@"0"
                           forKey:@"favorited"];

            NSString *infoText = [[NSString alloc] initWithString:[favedTweet stringForKey:@"info_text"]];
            infoText = [infoText substringFromIndex:1];
            [favedTweet setObject:[NSString stringWithString:infoText]
                           forKey:@"info_text"];
            infoText = nil;
            
            [favedTweet setObject:@(CellTextColorBlue)
                           forKey:@"text_color"];
            
            __weak TimelineViewController *wself = self;
            
            SYNC_MAIN_QUEUE ^{
                
                [wself.timelineArray replaceObjectAtIndex:index withObject:favedTweet];
                favedTweet = nil;
                
                //タイムラインを保存
                [TWTweets saveCurrentTimeline:wself.timelineArray];
                
                //TL更新
                [wself.timeline reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationRight];
            });
            
            break;
        }
        
        index++;
    }
}

- (void)userStreamReceiveFavEvent:(NSDictionary *)receiveData {
    
    NSLog(@"%@", receiveData);
    
    __block NSMutableDictionary *favDic = BLANK_M_DIC;
    //user
    NSMutableDictionary *user = BLANK_M_DIC;
    
    //ふぁぼられた人
    NSString *favUser = [[NSString alloc] initWithString:receiveData[@"target"][@"screen_name"]];
    
    //ふぁぼられ人のアイコン
    NSString *favUserIcon = [[NSString alloc] initWithString:receiveData[@"target"][@"profile_image_url"]];
    
    //ふぁぼった人
    NSString *addUser = [[NSString alloc] initWithString:receiveData[@"source"][@"screen_name"]];
    
    //ふぁぼられたTweetの時間
    NSString *favTime = [[NSString alloc] initWithString:receiveData[@"target_object"][@"created_at"]];
    
    //ふぁぼられたTweet
    NSString *targetText = [[NSString alloc] initWithString:receiveData[@"target_object"][@"text"]];
    
    //ふぁぼられたID
    NSString *targetId = [[NSString alloc] initWithString:receiveData[@"target_object"][@"id_str"]];
    
    //クライアント
    NSString *favClient = [[NSString alloc] initWithString:receiveData[@"target_object"][@"source"]];
    
    NSString *infoText = [[NSString alloc] initWithString:receiveData[@"info_text"]];
    
    NSString *searchName = [[NSString alloc] initWithString:receiveData[@"search_name"]];
    
    if ( favUser == nil || favUserIcon == nil || favTime == nil || favClient == nil ||
        targetText == nil || targetId == nil || addUser == nil || infoText == nil || searchName == nil ) return;
    
    //辞書に追加
    //ふぁぼられイベントフラグ
    [favDic setObject:@"YES"
               forKey:@"FavEvent"];
    [user setObject:BLANK
             forKey:@"id_str"];
    [user setObject:[NSString stringWithString:favUser]
             forKey:@"screen_name"];
    [user setObject:[NSString stringWithString:favUserIcon]
             forKey:@"profile_image_url"];
    [favDic setObject:[NSString stringWithString:favTime]
               forKey:@"created_at"];
    [favDic setObject:[NSString stringWithString:favClient]
               forKey:@"source"];
    [favDic setObject:[NSMutableDictionary dictionaryWithDictionary:user]
               forKey:@"user"];
    [favDic setObject:[NSString stringWithString:targetText]
               forKey:@"text"];
    [favDic setObject:[NSString stringWithString:targetId]
               forKey:@"id_str"];
    [favDic setObject:@"1"
               forKey:@"favorited"];
    [favDic setObject:[NSString stringWithString:addUser]
               forKey:@"addUser"];
    [favDic setObject:[NSString stringWithString:infoText]
               forKey:@"info_text"];
    [favDic setObject:[NSString stringWithString:searchName]
               forKey:@"search_name"];
    [favDic setObject:@(CellTextColorGold)
               forKey:@"text_color"];
    
    //NSLog(@"favDic: %@", favDic);
    
    __weak TimelineViewController *wself = self;
    
    if ( [[Share images] objectForKey:favUser] == nil ) {
        
        __block NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        [tempDic setObject:favDic[@"user"][@"screen_name"]
                    forKey:@"screen_name"];
        [tempDic setObject:[TWIconBigger normal:favDic[@"user"][@"profile_image_url"]]
                    forKey:@"profile_image_url"];
        
        //アイコン取得
        dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
        dispatch_async(queue, ^ {
            
            [wself getIconWithTweetArray:[NSMutableArray arrayWithArray:@[tempDic]]];
            tempDic = nil;
        });
    }
    
    SYNC_MAIN_QUEUE ^{
        
        //タイムラインに追加
        wself.timelineArray = [wself.timelineArray appendToTop:@[favDic]
                                                 returnMutable:YES];
        favDic = nil;
        
        //タイムラインを保存
        [TWTweets saveCurrentTimeline:wself.timelineArray];
        
        //タイムラインを更新
        [wself.timeline insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationTop];
    });
}

- (void)userStreamReceiveTweet:(NSDictionary *)receiveData newTweet:(NSArray *)newTweet {
    
    __weak TimelineViewController *wself = self;
    __block NSArray *weakNewTweet = newTweet;
    
    SYNC_MAIN_QUEUE ^{
        
        [wself checkTimelineCount:YES];
        
        //タイムラインに追加
        wself.timelineArray = [wself.timelineArray appendOnlyNewToTop:weakNewTweet
                                                        returnMutable:YES];
        
        //タイムラインを保存
        [TWTweets saveCurrentTimeline:wself.timelineArray];
        
        [wself.timeline insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationTop];
    });
    
    //アイコン保存
    dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
    dispatch_async(queue, ^ {
        
        [wself getIconWithTweetArray:[NSMutableArray arrayWithArray:weakNewTweet]];
        weakNewTweet = nil;
    });
}

#pragma mark - SearchStream

- (void)openSearchStream:(NSString *)searchWord {
    
    if ( [searchWord isEmpty] ) return;
    
    __weak TimelineViewController *wself = self;
    __block NSString *weakSearchWord = searchWord;
    
    dispatch_queue_t userStreamQueue = GLOBAL_QUEUE_BACKGROUND;
    dispatch_async(userStreamQueue, ^{
        
        @autoreleasepool {
            
            //          NSLog(@"openSearchStream: %@", weakSearchWord);
            
            if ( [D boolForKey:@"USNoAutoLock"] ) [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            
            [wself setOtherTweetsBarItems];
            
            //リクエストパラメータを作成
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:[NSString stringWithString:weakSearchWord]
                       forKey:@"track"];
            [TWGetTimeline twitterSearch:weakSearchWord];
            
            //UserStream接続リクエストの作成
            TWRequest *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://stream.twitter.com/1.1/statuses/filter.json"]
                                                     parameters:params
                                                  requestMethod:TWRequestMethodPOST];
            
            //アカウントの設定
            [request setAccount:[TWAccounts currentAccount]];
            
            //接続開始
            wself.connection = [NSURLConnection connectionWithRequest:request.signedURLRequest
                                                             delegate:wself];
            [wself.connection start];
            
            [params removeAllObjects];
            
            [wself.searchStreamTemp removeAllObjects];
            [wself startSearchStreamTimer];
            
            // 終わるまでループさせる
            while ( wself.searchStream ) {
                
//                @autoreleasepool {
                
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
//                }
            }
            
            params = nil;
            request = nil;
            weakSearchWord = nil;
        }
    });
}

- (void)closeSearchStream {
    
    NSLog(@"closeSearchStream");
    
    if ( [D boolForKey:@"USNoAutoLock"] ) [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    _searchStream = NO;
    _userStreamFirstResponse = NO;
    
    __weak TimelineViewController *wself = self;
    
    ASYNC_MAIN_QUEUE ^{
        
        wself.timelineControlButton.enabled = YES;
        wself.timelineControlButton.image = wself.startImage;
    });
    
    [self stopSearchStreamTimer];
    
    if ( self.connection != nil ) {
        
        [self.connection cancel];
        [self.connection setDelegateQueue:nil];
        self.connection = nil;
    }
    
    [self setTimelineBarItems];
    
    [_timelineArray removeAllObjects];
    self.timelineArray = [NSMutableArray arrayWithArray:[TWTweets currentTimeline]];
    [_timeline reloadData];
}

- (void)searchStreamReceiveTweet:(NSDictionary *)receiveData {
    
    //NSLog(@"SearchStream: %@", receiveData);
    
    @try {
        
        [_searchStreamTemp addObject:receiveData];
        
    }@catch ( NSException *e ) {}
}

- (void)startSearchStreamTimer {
    
    NSLog(@"startSearchStreamTimer InterVal: %.3f", APP_DELEGATE.reloadInterval);
    
    _searchStreamTemp = [NSMutableArray array];
    _searchStreamTimer = [NSTimer scheduledTimerWithTimeInterval:APP_DELEGATE.reloadInterval
                                                          target:self
                                                        selector:@selector(checkSearchStreamTemp)
                                                        userInfo:nil
                                                         repeats:YES];
    [_searchStreamTimer fire];
}

- (void)stopSearchStreamTimer {
    
    NSLog(@"stopSearchStreamTimer");
    
    [_searchStreamTemp removeAllObjects];
    self.searchStreamTemp = nil;
    [_searchStreamTimer invalidate];
}

- (void)checkSearchStreamTemp {
    
    //NSLog(@"checkSearchStreamTemp");
    
    if ( _searchStreamTemp.count != 0 ) {
        
        __weak TimelineViewController *wself = self;
        
        dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
        dispatch_async(queue, ^{
            
            SYNC_MAIN_QUEUE ^{
                
                NSDictionary *newTweet = [[NSDictionary alloc] initWithDictionary:[wself.searchStreamTemp objectAtIndex:0]];
                [wself.searchStreamTemp removeObjectAtIndex:0];
                
                if ( newTweet != nil ) {
                    
                    [wself checkTimelineCount:YES];
                    
                    //タイムラインに追加
                    wself.timelineArray = [wself.timelineArray appendOnlyNewToTop:@[newTweet]
                                                                    returnMutable:YES];
                    [wself.timeline insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                          withRowAnimation:UITableViewRowAnimationTop];
                    
                    __block NSDictionary *weakNewTweet = newTweet;
                    
                    //アイコン保存
                    dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
                    dispatch_async(queue, ^ {
                        
                        [wself getIconWithTweetArray:[NSMutableArray arrayWithArray:@[weakNewTweet]]];
                        weakNewTweet = nil;
                    });
                }
            });
        });
    }
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSError *error = nil;
    __block NSMutableDictionary *receiveData =
    [[NSMutableDictionary alloc] initWithDictionary:
     [NSJSONSerialization JSONObjectWithData:data
                                     options:NSJSONReadingMutableLeaves
                                       error:&error]];
    
    @try {
        //          NSLog(@"receiveData[%d]: %@", receiveData.count, receiveData);
        //          NSLog(@"receiveDataCount: %d", receiveData.count);
        //          NSLog(@"event: %@", receiveData[@"event"]);
        
        //エラーは無視
        if ( error ) return;
        
        if ( !_userStreamFirstResponse ) {
            
            //接続初回のレスポンスは無視
            _userStreamFirstResponse = YES;
            
            return;
        }
        
        //定期的に送られてくる空データは無視
        if ( receiveData.count == 0 ) return;
        
        //接続初回のようなデータは無視
        if ( receiveData.count == 1 && receiveData[@"friends"] != nil ) return;
        
        if ( _searchStream ) {
            
            __weak TimelineViewController *wself = self;
            
            ASYNC_MAIN_QUEUE ^{
                
                //SearchStreamの場合
                [wself searchStreamReceiveTweet:[[TWEntities replaceTcoAll:@[receiveData]] objectAtIndex:0]];
            });
            
            return;
        }
        
        if ( receiveData.count == 1 && receiveData[@"delete"] != nil ) {
            
            NSLog(@"UserStream Delete Event");
            
            //削除イベント
            [self userStreamDelete:receiveData];
            return;
        }
        
        //更新アカウントを記憶
        _lastUpdateAccount = [TWAccounts currentAccountName];
        
        __block NSArray *newTweet = @[receiveData];
        
        //t.coを展開
        newTweet = [TWEntities replaceTcoAll:newTweet];
        
        if ( receiveData[@"event"] == nil &&
             receiveData[@"delete"] == nil ) {
            
            //NG判定を行う
            newTweet = [TWNgTweet ngAll:newTweet];
            
            //新着が無いので終了
            if ( newTweet.count == 0 ) {
                
                return;
            }
        }
        
        if ( receiveData[@"id_str"] != nil &&
             _timelineArray[0][@"id_str"] != nil ) {
            
            //重複する場合は無視
            if ( [receiveData[@"id_str"] isEqualToString:_timelineArray[0][@"id_str"]] ) {
                
                return;
            }
        }
        
        //      NSLog(@"newTweet: %@", newTweet);
        
        receiveData = [newTweet objectAtIndex:0];
        
        if ( receiveData.count != 1 && receiveData[@"delete"] == nil ) {
            
            if ( [receiveData[@"event"] isEqualToString:@"favorite"] &&
                 [receiveData[@"source"][@"screen_name"] isEqualToString:[TWAccounts currentAccountName]] ) {
                
                NSLog(@"UserStream Add Fav Event");
                
                //自分のふぁぼりイベント
                [self userStreamMyAddFavEvent:receiveData];
                
                return;
                
            }else if ( [receiveData[@"event"] isEqualToString:@"unfavorite"] &&
                       [receiveData[@"source"][@"screen_name"] isEqualToString:[TWAccounts currentAccountName]] ) {
                
                if ( _timelineArray.count == 0 ) {
                    
                    return;
                }
                
                NSLog(@"UserStream Remove Fav Event");
                
                //自分のふぁぼ外しイベント
                [self userStreamMyRemoveFavEvent:receiveData];
                return;
                
            }else if ( [receiveData[@"event"] isEqualToString:@"favorite"] ) {
                
                NSLog(@"UserStream Receive Fav Event");
                
                //ふぁぼられイベント
                [self userStreamReceiveFavEvent:receiveData];
                return;
                
            }else if ( receiveData[@"event"] != nil ) {
                
                return;
            }
            
            //以下通常Post向け処理
            [self userStreamReceiveTweet:receiveData newTweet:newTweet];
        }
        
    }@catch ( NSException *e ) {
        /* 例外は投げ捨てる物 */
    }@finally {
        receiveData = nil;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSLog(@"didReceiveResponse:%d, %lld", httpResponse.statusCode, response.expectedContentLength);
    
    if ( httpResponse.statusCode == 200 ) {
        
        _userStream = YES;
        _timelineControlButton.image = _stopImage;
        
    }else {
        
        [self closeStream];
        if ( _searchStream ) [self closeSearchStream];
    }
    
    _timelineControlButton.enabled = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"connectionDidFinishLoading");
    
    [self closeStream];
    if ( _searchStream ) [self closeSearchStream];
    [self pushReloadButton:nil];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"didFailWithError: %@", error);
    NSLog(@"TimelineCount: %d", _timelineArray.count);
    
    [self closeStream];
    if ( _searchStream ) [self closeSearchStream];
    [self pushReloadButton:nil];
}

#pragma mark - GestureRecognizer

- (IBAction)swipeTimelineRight:(UISwipeGestureRecognizer *)sender {
    
    NSLog(@"swipeTimelineRight");
    
    //ピッカー表示中の場合は隠す
    if ( _pickerVisible ) [self hidePicker];
    
    if ( _timelineSegment.selectedSegmentIndex == 3 ) {
        
        [self showListSelectView];
        
    }else {
        
        //InReplyTto表示中は何もしない
        if ( _otherTweetsMode ) return;
        
        int num = [D integerForKey:@"UseAccount"] - 1;
        
        if ( num < 0 ) return;
        
        int accountCount = [TWAccounts accountCount] - 1;
        
        if ( accountCount >= num ) {
            
            if ( _userStream ) [self closeStream];
            
            APP_DELEGATE.listAll = BLANK_ARRAY;
            APP_DELEGATE.listId = BLANK;
            
            [D setInteger:num forKey:@"UseAccount"];
            
            [self changeSegment:nil];
        }
    }
}

- (IBAction)swipeTimelineLeft:(UISwipeGestureRecognizer *)sender {
    
    NSLog(@"swipeTimelineLeft");
    
    //ピッカー表示中の場合は隠す
    if ( _pickerVisible ) [self hidePicker];
    
    if ( _showMenu ) {
        
        [self hideTimelineMenu:nil];
        return;
    }
    
    if ( _timelineSegment.selectedSegmentIndex == 3 ) return;
    
    //InReplyTto表示中は何もしない
    if ( _otherTweetsMode ) return;
    
    int num = [D integerForKey:@"UseAccount"] + 1;
    int accountCount = [TWAccounts accountCount] - 1;
    
    if ( accountCount >= num ) {
        
        if ( _userStream ) [self closeStream];
        
        APP_DELEGATE.listAll = BLANK_ARRAY;
        APP_DELEGATE.listId = BLANK;
        
        [D setInteger:num forKey:@"UseAccount"];
        
        [self changeSegment:nil];
    }
}

- (IBAction)longPressTimeline:(UILongPressGestureRecognizer *)sender {
    
    //ピッカー表示中の場合は隠す
    if ( _pickerVisible ) [self hidePicker];
    
    if ( _longPressControl == 0 ) {
        
        _longPressControl = 1;
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"ログ削除"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"現在のアカウントのTimelineログを削除", @"全てのTimelineログを削除",
                                @"全てのログとアイコンキャッシュを削除", @"タイムラインにNG情報を再適用", nil];
        
        sheet.tag = 2;
        
        [sheet showInView:APP_DELEGATE.tabBarController.view];
    }
}

#pragma mark - SegmentControl

- (IBAction)changeSegment:(UISegmentedControl *)sender {
    
    NSLog(@"changeSegment[%d]", _timelineSegment.selectedSegmentIndex);
    
    //ピッカー表示中の場合は隠す
    if ( _pickerVisible ) [self hidePicker];
    
    if ( _searchStream ) [self closeSearchStream];
    
    __weak TimelineViewController *wself = self;
    
    //InReplyTo表示中なら閉じる
    if ( _otherTweetsMode ) {
        
        [self pushCloseOtherTweetsButton:nil];
        
    }else {
        
        //インターネット接続を確認
        if ( ![InternetConnection enable] ) return;
        
        if ( _timelineSegment.selectedSegmentIndex == 0 ) {
            
            //Timelineに切り替わった
            self.timelineArray = [NSMutableArray arrayWithArray:[TWTweets currentTimeline]];
            
            ASYNC_MAIN_QUEUE ^{
                
                [wself.timeline reloadData];
                wself.listMode = NO;
                wself.timelineControlButton.image = wself.startImage;
                wself.timelineControlButton.enabled = YES;
            });
            
            self.mentionsArray = BLANK_ARRAY;
            
            [self pushReloadButton:nil];
            
        }else if ( _timelineSegment.selectedSegmentIndex == 1 ) {
            
            ASYNC_MAIN_QUEUE ^{
                
                wself.listMode = NO;
                wself.timelineControlButton.image = wself.startImage;
            });
            
            //Mentionsに切り替わった
            [TWGetTimeline performSelectorInBackground:@selector(mentions) withObject:nil];
            
        }else if ( _timelineSegment.selectedSegmentIndex == 2 ) {
            
            ASYNC_MAIN_QUEUE ^{
                
                wself.listMode = NO;
                wself.timelineControlButton.image = wself.startImage;
            });
            
            //Favoritesに切り替わった
            [TWGetTimeline performSelectorInBackground:@selector(favotites) withObject:nil];
            
        }else if ( _timelineSegment.selectedSegmentIndex == 3 ) {
            
            //リスト選択画面を表示
            [self timelineDidListChanged];
        }
    }
    
    ASYNC_MAIN_QUEUE ^{
        
        if ( wself.timelineSegment.selectedSegmentIndex != 0 &&
            wself.timelineSegment.selectedSegmentIndex != 3 ) {
            
            [wself.grayView start];
        }
    });
}

#pragma mark - ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    __weak TimelineViewController *wself = self;
    
    dispatch_queue_t globalQueue = GLOBAL_QUEUE_DEFAULT;
    dispatch_async(globalQueue, ^{
        
        if ( actionSheet.tag == 1 ) {
            
            [wself openTwitterService:_alertSearchUserName serviceType:buttonIndex];
            
        }else if ( actionSheet.tag == 2 ) {
            
            wself.longPressControl = 0;
            
            if ( buttonIndex != 3 && buttonIndex != 4 ) {
                
                ASYNC_MAIN_QUEUE ^{
                    
                    [wself.grayView forceEnd];
                    [wself closeStream];
                    
                    [wself.grayView removeFromSuperview];
                    [wself setGrayView:nil];
                    [wself.imageWindow removeFromSuperview];
                    [wself setImageWindow:nil];
                    
                    //タイムラインからログを削除
                    [wself.timelineArray removeAllObjects];
                    wself.timelineArray = nil;
                    wself.timelineArray = BLANK_M_ARRAY;
                    
                    CGRect timelineRect = wself.timeline.frame;
                    
                    for ( UIView *subView in wself.timeline.subviews ) {
                        
                        [subView removeAllSubViews];
                    }
                    
                    [wself.timeline removeAllSubViews];
                    
                    wself.timeline.delegate = nil;
                    wself.timeline.dataSource = nil;
                    [wself.timeline removeFromSuperview];
                    wself.timeline = nil;
                    
                    wself.timeline = [[UITableView alloc] initWithFrame:timelineRect style:UITableViewStylePlain];
                    wself.timeline.delegate = wself;
                    wself.timeline.dataSource = wself;
                    [wself.view addSubview:wself.timeline];
                    
                    [wself createPullDownRefreshHeader];
                    
                    wself.grayView = [ActivityGrayView grayViewWithTaskName:@"FirstLoad"];
                    [wself.view addSubview:wself.grayView];
                    
                    wself.imageWindow = [[ImageWindow alloc] init];
                    [wself.view addSubview:wself.imageWindow];
                    
                    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:wself action:@selector(swipeTimelineRight:)];
                    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
                    [wself.timeline addGestureRecognizer:swipeRight];
                    swipeRight = nil;
                    
                    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:wself action:@selector(swipeTimelineLeft:)];
                    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
                    [wself.timeline addGestureRecognizer:swipeLeft];
                    swipeLeft = nil;
                });
                
                if ( buttonIndex == 0 ) {
                    
                    //タイムラインを保存
                    [TWTweets saveCurrentTimeline:wself.timelineArray];
                    
                }else if ( buttonIndex == 1 || buttonIndex == 2 ) {
                    
                    //各アカウントのログを削除
                    for ( ACAccount *account in [TWAccounts twitterAccounts] ) {
                        
                        [[TWTweets timelines] setObject:[NSMutableArray array]
                                                 forKey:[NSString stringWithString:account.username]];
                    }
                    
                    APP_DELEGATE.listId = BLANK;
                    APP_DELEGATE.startupUrlList = nil;
                    APP_DELEGATE.startupUrlList = BLANK_ARRAY;
                    APP_DELEGATE.listAll = nil;
                    APP_DELEGATE.listAll = BLANK_ARRAY;
                    
                    [wself.requestedUser removeAllObjects];
                    
                    [[Share images] removeAllObjects];
                    
                    //タイムラインログを削除
                    wself.mentionsArray = nil;
                    wself.mentionsArray = BLANK_ARRAY;
                    [wself.allLists removeAllObjects];
                    wself.allLists = nil;
                    wself.allLists = BLANK_M_DIC;
                    
                    if ( buttonIndex == 2 ) {
                        
                        ASYNC_MAIN_QUEUE ^{
                            
                            wself.accountIconView.image = nil;
                        });
                        
                        //アイコンファイルを削除
                        [[NSFileManager defaultManager] removeItemAtPath:ICONS_DIRECTORY error:nil];
                        
                        //フォルダを再作成
                        [FILE_MANAGER createDirectoryAtPath:ICONS_DIRECTORY
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:nil];
                    }
                }
                
            }else if ( buttonIndex == 3 ) {
                
                //NG情報を再適用
                
                //NG判定を行う
                ASYNC_MAIN_QUEUE ^{
                    
                    dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
                    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
                    dispatch_sync(queue, ^{
                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                        
                        wself.timelineArray = [NSMutableArray arrayWithArray:[TWNgTweet ngAll:wself.timelineArray]];
                        
                        dispatch_semaphore_signal(semaphore);
                        dispatch_release(semaphore);
                    });
                    
                    [TWTweets saveCurrentTimeline:wself.timelineArray];
                    [wself.timeline reloadData];
                });
                
            }else {
                
                //キャンセル
                return;
            }
            
        }else if ( actionSheet.tag == 3 ) {
            
            if ( buttonIndex == wself.selectTweetIds.count ) {
                
                NSLog(@"buttonIndex == _selectTweetIds.count");
                
                wself.selectAccount = BLANK;
                wself.selectTweetIds = nil;
                wself.selectTweetIds = BLANK_ARRAY;
                return;
            }
            
            ASYNC_MAIN_QUEUE ^{
                
                wself.selectAccount = [wself.selectTweetIds objectAtIndex:buttonIndex];
                
                if ( [wself.selectAccount hasPrefix:@"@"] ) {
                    
                    //@から始まっている場合取り除く
                    wself.selectAccount = [wself.selectAccount substringFromIndex:1];
                }
                
                //前後の空白文字を取り除く
                wself.selectAccount = [DeleteWhiteSpace string:wself.selectAccount];
                
                wself.alertSearchUserName = [NSString stringWithString:wself.selectAccount];
                
                UIActionSheet *sheet = [[UIActionSheet alloc]
                                        initWithTitle:wself.selectAccount
                                        delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                        otherButtonTitles:@"外部サービスやユーザー情報を開く", @"フォロー関連", nil];
                
                sheet.tag = 4;
                [sheet showInView:APP_DELEGATE.tabBarController.view];
            });
            
        }else if ( actionSheet.tag == 4 ) {
            
            if ( buttonIndex == 0 ) {
                
                ASYNC_MAIN_QUEUE ^{
                    
                    [wself pushActionButton:nil];
                });
                
                //後処理
                wself.selectAccount = BLANK;
                wself.selectTweetIds = nil;
                wself.selectTweetIds = BLANK_ARRAY;
                
            }else if ( buttonIndex == 1 ) {
                
                ASYNC_MAIN_QUEUE ^{
                    
                    if ( [wself.selectAccount isEqualToString:[TWAccounts currentAccountName]] ) {
                        
                        [ShowAlert error:@"それはあなたです！"];
                        
                    }else {
                        
                        UIActionSheet *sheet = [[UIActionSheet alloc]
                                                initWithTitle:wself.selectAccount
                                                delegate:wself
                                                cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:@"スパム報告"
                                                otherButtonTitles:@"ブロック", @"ブロック解除", @"フォロー", @"フォロー解除", nil];
                        
                        sheet.tag = 5;
                        [sheet showInView:APP_DELEGATE.tabBarController.view];
                    }
                });
            }
            
        }else if ( actionSheet.tag == 5 ) {
            
            if ( buttonIndex == 0 ) {
                
                //スパム報告
                [TWFriends reportSpam:wself.selectAccount];
                
            }else if ( buttonIndex == 1 ) {
                
                //ブロック
                [TWFriends block:wself.selectAccount];
                
            }else if ( buttonIndex == 2 ) {
                
                //ブロック解除
                [TWFriends unblock:wself.selectAccount];
                
            }else if ( buttonIndex == 3 ) {
                
                //フォロー
                [TWFriends follow:wself.selectAccount];
                
            }else if ( buttonIndex == 4 ) {
                
                //フォロー解除
                [TWFriends unfollow:wself.selectAccount];
            }
            
        }else if ( actionSheet.tag == 6 ) {
            
        }else if ( actionSheet.tag >= 7 && actionSheet.tag <= 11 ) {
            
            int cancelIndex = actionSheet.tag - 5;
            
            //キャンセルボタンが押された
            if ( buttonIndex == cancelIndex ) {
                
                NSLog(@"Tweet in URL copy cancel");
                
                wself.tweetInUrls = BLANK_ARRAY;
                return;
            }
            
            NSLog(@"Copy URL: %@", [wself.tweetInUrls objectAtIndex:buttonIndex]);
            
            [P_BOARD setString:[wself.tweetInUrls objectAtIndex:buttonIndex]];
            wself.tweetInUrls = BLANK_ARRAY;
        }
    });
}

- (void)showTwitterAccountSelectActionSheet:(NSArray *)ids {
    
    NSLog(@"showTwitterAccountSelectActionSheet[%d]", ids.count);
    
    UIActionSheet *sheet = nil;
    
    if ( ids.count == 1 ) {
        
        _selectAccount = [ids objectAtIndex:0];
        
        if ( [_selectAccount hasPrefix:@"@"] ) {
            
            //@から始まっている場合取り除く
            _selectAccount = [_selectAccount substringFromIndex:1];
        }
        
        //前後の空白文字を取り除く
        _selectAccount = [DeleteWhiteSpace string:_selectAccount];
        
        _alertSearchUserName = _selectAccount;
        
        UIActionSheet *oneUserSheet = [[UIActionSheet alloc]
                                       initWithTitle:_selectAccount
                                       delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                       otherButtonTitles:@"外部サービスやユーザー情報を開く", @"フォロー関連", nil];
        
        oneUserSheet.tag = 4;
        [oneUserSheet showInView:APP_DELEGATE.tabBarController.view];
        oneUserSheet = nil;
        
        return;
        
    }else if ( ids.count == 2 ) {
        
        sheet = [[UIActionSheet alloc]
                 initWithTitle:@"ユーザー選択"
                 delegate:self
                 cancelButtonTitle:@"Cancel"
                 destructiveButtonTitle:nil
                 otherButtonTitles:[ids objectAtIndex:0],
                 [ids objectAtIndex:1], nil];
        
    }else if ( ids.count == 3 ) {
        
        sheet = [[UIActionSheet alloc]
                 initWithTitle:@"ユーザー選択"
                 delegate:self
                 cancelButtonTitle:@"Cancel"
                 destructiveButtonTitle:nil
                 otherButtonTitles:[ids objectAtIndex:0],
                 [ids objectAtIndex:1],
                 [ids objectAtIndex:2], nil];
        
    }else if ( ids.count == 4 ) {
        
        sheet = [[UIActionSheet alloc]
                 initWithTitle:@"ユーザー選択"
                 delegate:self
                 cancelButtonTitle:@"Cancel"
                 destructiveButtonTitle:nil
                 otherButtonTitles:[ids objectAtIndex:0],
                 [ids objectAtIndex:1],
                 [ids objectAtIndex:2],
                 [ids objectAtIndex:3], nil];
        
    }else if ( ids.count == 5 ) {
        
        sheet = [[UIActionSheet alloc]
                 initWithTitle:@"ユーザー選択"
                 delegate:self
                 cancelButtonTitle:@"Cancel"
                 destructiveButtonTitle:nil
                 otherButtonTitles:[ids objectAtIndex:0],
                 [ids objectAtIndex:1],
                 [ids objectAtIndex:2],
                 [ids objectAtIndex:3],
                 [ids objectAtIndex:4], nil];
        
    }else if ( ids.count >= 6 ) {
        
        sheet = [[UIActionSheet alloc]
                 initWithTitle:@"ユーザー選択"
                 delegate:self
                 cancelButtonTitle:@"Cancel"
                 destructiveButtonTitle:nil
                 otherButtonTitles:[ids objectAtIndex:0],
                 [ids objectAtIndex:1],
                 [ids objectAtIndex:2],
                 [ids objectAtIndex:3],
                 [ids objectAtIndex:4],
                 [ids objectAtIndex:5], nil];
    }
    
    if ( sheet != nil ) {
        
        sheet.tag = 3;
        [sheet showInView:APP_DELEGATE.tabBarController.view];
        sheet = nil;
    }
}

- (void)openTwitterService:(NSString *)username serviceType:(int)serviceType {
    
    if ( username == nil ||
        [username isEqualToString:@""] ) return;
    
    __weak TimelineViewController *wself = self;
    __block __weak NSString *weakUserName = username;
    
    APP_DELEGATE.reOpenUrl = BLANK;
    
    NSString *serviceUrl = nil;
    
    if ( serviceType == 0 ) {
        
        //Twilog
        serviceUrl = [NSString stringWithFormat:@"http://twilog.org/%@", username];
        
    }else if ( serviceType == 1 ) {
        
        ASYNC_MAIN_QUEUE ^{
            
            wself.alertSearch = nil;
            wself.alertSearch = [[UIAlertView alloc] initWithTitle:@"TwilogSearch"
                                                           message:@"\n"
                                                          delegate:wself
                                                 cancelButtonTitle:@"キャンセル"
                                                 otherButtonTitles:@"確定", nil];
            
            wself.alertSearch.tag = 0;
            
            wself.alertSearchText = nil;
            wself.alertSearchText = [[SSTextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
            [wself.alertSearchText setBackgroundColor:[UIColor whiteColor]];
            wself.alertSearchText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            wself.alertSearchText.delegate = wself;
            wself.alertSearchText.text = BLANK;
            wself.alertSearchText.tag = 0;
            
            [wself.alertSearch addSubview:wself.alertSearchText];
            [wself.alertSearch show];
            [wself.alertSearchText becomeFirstResponder];
        });
        
        return;
        
    }else if ( serviceType == 2 ) {
        
        //favstar
        serviceUrl = [NSString stringWithFormat:@"http://ja.favstar.fm/users/%@/recent", username];
        
    }else if ( serviceType == 3 ) {
        
        //Twitpic
        serviceUrl = [NSString stringWithFormat:@"http://twitpic.com/photos/%@", username];
        
    }else if ( serviceType == 4 ) {
        
        ASYNC_MAIN_QUEUE ^{
            
            if ( wself.alertSearchType ) {
                
                wself.alertSearch = nil;
                wself.alertSearch = [[UIAlertView alloc] initWithTitle:@"ID入力 (screen_name)"
                                                               message:@"\n"
                                                              delegate:wself
                                                     cancelButtonTitle:@"キャンセル"
                                                     otherButtonTitles:@"確定", nil];
                
                wself.alertSearch.tag = 1;
                
                wself.alertSearchText = nil;
                wself.alertSearchText = [[SSTextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
                [wself.alertSearchText setBackgroundColor:[UIColor whiteColor]];
                wself.alertSearchText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                wself.alertSearchText.delegate = wself;
                wself.alertSearchText.text = BLANK;
                wself.alertSearchText.tag = 1;
                
                [wself.alertSearch addSubview:wself.alertSearchText];
                [wself.alertSearch show];
                [wself.alertSearchText becomeFirstResponder];
                
            }else {
                
                [TWGetTimeline userTimeline:weakUserName];
                weakUserName = nil;
            }
        });
        
        return;
        
    }else if ( serviceType == 5 ) {
        
        ASYNC_MAIN_QUEUE ^{
            
            wself.otherTweetsMode = YES;
            
            if ( wself.alertSearchType ) {
                
                wself.alertSearch = nil;
                wself.alertSearch = [[UIAlertView alloc] initWithTitle:@"Twitter Search"
                                                               message:@"\n"
                                                              delegate:wself
                                                     cancelButtonTitle:@"キャンセル"
                                                     otherButtonTitles:@"確定", nil];
                
                wself.alertSearch.tag = 2;
                
                wself.alertSearchText = nil;
                wself.alertSearchText = [[SSTextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
                [wself.alertSearchText setBackgroundColor:[UIColor whiteColor]];
                wself.alertSearchText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                wself.alertSearchText.delegate = wself;
                wself.alertSearchText.text = BLANK;
                wself.alertSearchText.tag = 2;
                
                [wself.alertSearch addSubview:wself.alertSearchText];
                [wself.alertSearch show];
                [wself.alertSearchText becomeFirstResponder];
                
            }else {
                
                [TWGetTimeline twitterSearch:[CreateSearchURL encodeWord:weakUserName
                                                                encoding:kCFStringEncodingUTF8]];
                weakUserName = nil;
            }
        });
        
        return;
        
    }else if ( serviceType == 6 ) {
        
        ASYNC_MAIN_QUEUE ^{
            
            //UserStreamを切断
            if ( weakUserName ) [wself closeStream];
            
            if ( wself.timelineSegment.selectedSegmentIndex == 0 ) {
                
                [TWTweets saveCurrentTimeline:wself.timelineArray];
            }
            
            wself.searchStream =YES;
            
            wself.alertSearch = nil;
            wself.alertSearch = [[UIAlertView alloc] initWithTitle:@"Twitter Search(Stream)"
                                                           message:@"\n"
                                                          delegate:wself
                                                 cancelButtonTitle:@"キャンセル"
                                                 otherButtonTitles:@"確定", nil];
            
            wself.alertSearch.tag = 3;
            
            wself.alertSearchText = nil;
            wself.alertSearchText = [[SSTextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
            [wself.alertSearchText setBackgroundColor:[UIColor whiteColor]];
            wself.alertSearchText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            wself.alertSearchText.delegate = wself;
            wself.alertSearchText.text = BLANK;
            wself.alertSearchText.tag = 3;
            
            [wself.alertSearch addSubview:wself.alertSearchText];
            [wself.alertSearch show];
            [wself.alertSearchText becomeFirstResponder];
            weakUserName = nil;
        });
        
        return;
        
    }else {
        
        return;
    }
    
    APP_DELEGATE.startupUrlList = [NSArray arrayWithObject:serviceUrl];
    
    [self openBrowser];
}

- (void)timelineMenuActionReply {
    
    __weak TimelineViewController *wself = self;
    
    SYNC_MAIN_QUEUE ^{
        
        if ( wself.otherTweetsMode ) [wself pushCloseOtherTweetsButton:nil];
        
        [APP_DELEGATE.postData removeAllObjects];
        
        NSString *screenName = wself.selectTweet[@"user"][@"screen_name"];
        NSString *inReplyToId = [[NSString alloc] initWithString:wself.selectTweet[@"id_str"]];
        
        if ( screenName == nil || inReplyToId == nil ) return;
        
        [APP_DELEGATE.postData setObject:[NSString stringWithString:screenName]
                                  forKey:@"ScreenName"];
        [APP_DELEGATE.postData setObject:[NSString stringWithString:inReplyToId]
                                  forKey:@"InReplyToId"];
        
        APP_DELEGATE.tabChangeFunction = @"Reply";
        wself.tabBarController.selectedIndex = 0;
    });
}

- (void)timelineMenuActionFavorite {
    
    NSString *tweetId = _selectTweet[@"id_str"];
    BOOL favorited = [_selectTweet[@"favorited"] boolValue];
    
    if ( favorited ) {
        
        [TWEvent unFavorite:tweetId accountIndex:[D integerForKey:@"UseAccount"]];
        
    }else {
        
        [TWEvent favorite:tweetId accountIndex:[D integerForKey:@"UseAccount"]];
    }
}

- (void)timelineMenuActionReTweet {
    
    NSString *tweetId = _selectTweet[@"id_str"];
    [TWEvent reTweet:tweetId accountIndex:[D integerForKey:@"UseAccount"]];
}

- (void)timelineMenuActionFavRT {
    
    NSString *tweetId = _selectTweet[@"id_str"];
    [TWEvent favoriteReTweet:tweetId accountIndex:[D integerForKey:@"UseAccount"]];
}

- (void)timelineMenuActionSelectID {
    
    __weak TimelineViewController *wself = self;
    
    SYNC_MAIN_QUEUE ^{
        
        [wself showPickerView];
    });
}

- (void)timelineMenuActionNGTag {
    
    NSString *hashTag = [[_selectTweet stringForKey:@"text"] strWithRegExp:@"((?:\\A|\\z|[\x0009-\x000D\x0020\xC2\x85\u00A0\u1680\u180E\u2000-\u200A\u2028\u2029\u202F\u205F\u3000]|[\\[\\]［］()（）{}｛｝‘’“”\"\'｟｠⸨⸩「」｢｣『』〚〛⟦⟧〔〕❲❳〘〙⟬⟭〈〉〈〉⟨⟩《》⟪⟫<>＜＞«»‹›【】〖〗]|。|、|\\.|!))(#|＃)([a-z0-9_\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\u0400-\u04FF\u0500-\u0527\u1100-\u11FF\u3130-\u3185\uA960-\uA97F\uAC00-\uD7AF\uD7B0-\uD7FF\u30A1-\u30FA\uFF66-\uFF9D\uFF10-\uFF19\uFF21-\uFF3A\uFF41-\uFF5A\u3041-\u3096\u3400-\u4DBF\u4E00-\u9FFF\u020000-\u02A6DF\u02A700-\u02B73F\u02B740-\u02B81F\u02F800-\u02FA1F\u30FC\u3005]*[a-z_\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\u0400-\u04FF\u0500-\u0527\u1100-\u11FF\u3130-\u3185\uA960-\uA97F\uAC00-\uD7AF\uD7B0-\uD7FF\u30A1-\u30FA\uFF66-\uFF9D\uFF10-\uFF19\uFF21-\uFF3A\uFF41-\uFF5A\u3041-\u3096\u3400-\u4DBF\u4E00-\u9FFF\u020000-\u02A6DF\u02A700-\u02B73F\u02B740-\u02B81F\u02F800-\u02FA1F\u30FC\u3005][a-z0-9_\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\u0400-\u04FF\u0500-\u0527\u1100-\u11FF\u3130-\u3185\uA960-\uA97F\uAC00-\uD7AF\uD7B0-\uD7FF\u30A1-\u30FA\uFF66-\uFF9D\uFF10-\uFF19\uFF21-\uFF3A\uFF41-\uFF5A\u3041-\u3096\u3400-\u4DBF\u4E00-\u9FFF\u020000-\u02A6DF\u02A700-\u02B73F\u02B740-\u02B81F\u02F800-\u02FA1F\u30FC\u3005]*)(?=(?:\\A|\\z|[\x0009-\x000D\x0020\xC2\x85\u00A0\u1680\u180E\u2000-\u200A\u2028\u2029\u202F\u205F\u3000]|[\\[\\]［］()（）{}｛｝‘’“”\"\'｟｠⸨⸩「」｢｣『』〚〛⟦⟧〔〕❲❳〘〙⟬⟭〈〉〈〉⟨⟩《》⟪⟫<>＜＞«»‹›【】〖〗]|。|、|\\.|!))"];
    
    if ( [hashTag isNotEmpty] ) {
        
        NSMutableDictionary *addDic = [[NSMutableDictionary alloc] initWithDictionary:BLANK_M_DIC];
        
        //NGワード設定を読み込む
        NSMutableArray *ngWordArray = [[NSMutableArray alloc] initWithArray:[D objectForKey:@"NGWord"]];
        
        //NGワードに追加
        [addDic setObject:[NSString stringWithString:[DeleteWhiteSpace string:hashTag]]
                   forKey:@"Word"];
        [ngWordArray addObject:addDic];
        
        //設定に反映
        [D setObject:[NSMutableArray arrayWithArray:ngWordArray]
              forKey:@"NGWord"];
        
        //タイムラインにNGワードを適用
        self.timelineArray = [NSMutableArray arrayWithArray:[TWNgTweet ngWord:[NSArray arrayWithArray:_timelineArray]]];
        
        //タイムラインを保存
        [TWTweets saveCurrentTimeline:_timelineArray];
        
        __weak TimelineViewController *wself = self;
        
        ASYNC_MAIN_QUEUE ^{
            
            //リロード
            [wself.timeline reloadData];
        });
        
    }else {
        
        ASYNC_MAIN_QUEUE ^{
            
            [ShowAlert error:@"ハッシュタグが見つかりませんでした。"];
        });
    }
}

- (void)timelineMenuActionNGClient {
    
    NSMutableDictionary *addDic = [[NSMutableDictionary alloc] initWithDictionary:BLANK_M_DIC];
    
    NSString *clientName = [[NSString alloc] initWithString:[TWParser client:_selectTweet[@"source"]]];
    
    //NGクライアント設定を読み込む
    NSMutableArray *ngClientArray = [[NSMutableArray alloc] initWithArray:[D objectForKey:@"NGClient"]];
    
    if ( clientName == nil ) {
        
        return;
    }
    
    //NGクライアント
    [addDic setObject:[NSString stringWithString:clientName]
               forKey:@"Client"];
    [ngClientArray addObject:addDic];
    
    //NSLog(@"ngClientArray: %@", ngClientArray);
    
    [D setObject:[NSMutableArray arrayWithArray:ngClientArray]
          forKey:@"NGClient"];
    
    //タイムラインにNGワードを適用
    self.timelineArray = [NSMutableArray arrayWithArray:[TWNgTweet ngClient:[NSArray arrayWithArray:_timelineArray]]];
    
    //タイムラインを保存
    [TWTweets saveCurrentTimeline:_timelineArray];
    
    __weak TimelineViewController *wself = self;
    
    ASYNC_MAIN_QUEUE ^{
        
        //リロード
        [wself.timeline reloadData];
    });
}

- (void)timelineMenuActionInReplyTo {
    
    if ( _inReplyTo != nil || _inReplyTo.count != 0 ) {
        
        [self setInReplyTo:nil];
        _inReplyTo = [NSMutableArray array];
    }
    
    NSString *inReplyToId = _selectTweet[@"in_reply_to_status_id_str"];
    
    if ( [inReplyToId isNotEmpty] ) {
        
        NSLog(@"InReplyTo GET START");
        
        _otherTweetsMode = YES;
        
        [_inReplyTo addObject:_selectTweet];
        [self getInReplyToChain:_selectTweet];
        
    }else {
        
        ASYNC_MAIN_QUEUE ^{
            
            [ShowAlert error:@"InReplyToIDがありません。"];
        });
    }
}

- (void)timelineMenuActionCopy {
    
    __weak TimelineViewController *wself = self;
    
    ASYNC_MAIN_QUEUE ^{
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"Tweetをコピー"
                                delegate:wself
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"STOT形式", @"本文", @"TweetへのURL", @"Tweet内のURL", nil];
        
        sheet.tag = 6;
        [sheet showInView:APP_DELEGATE.tabBarController.view];
    });
}

- (void)timelineMenuActionDelete {
    
    if ( [_selectTweet[@"user"][@"screen_name"] isEqualToString:[TWAccounts currentAccountName]] ) {
        
        NSString *tweetId = _selectTweet[@"id_str"];
        [TWEvent destroy:tweetId];
        
    }else {
        
        ASYNC_MAIN_QUEUE ^{
            
            [ShowAlert error:@"自分のTweetではありません。"];
        });
    }
}

- (void)timelineMenuActionEdit {
    
    if ( [_selectTweet[@"user"][@"screen_name"] isEqualToString:[TWAccounts currentAccountName]] ) {
        
        [APP_DELEGATE.postData removeAllObjects];
        
        NSString *text = _selectTweet[@"text"];
        NSString *inReplyToId = _selectTweet[@"in_reply_to_status_id_str"];
        
        if  ( text == nil ) return;
        
        [APP_DELEGATE.postData setObject:[NSString stringWithString:text]
                                  forKey:@"Text"];
        
        if ( [inReplyToId isNotEmpty] ) {
        
            [APP_DELEGATE.postData setObject:[NSString stringWithString:inReplyToId]
                                      forKey:@"InReplyToId"];
        }
        
        APP_DELEGATE.tabChangeFunction = @"Edit";
        
        NSString *tweetId = _selectTweet[@"id_str"];
        [TWEvent destroy:tweetId];
        
        __weak TimelineViewController *wself = self;
        
        ASYNC_MAIN_QUEUE ^{
            
            if ( !wself.userStream ) {
                
                //削除
                [wself.timelineArray removeObjectAtIndex:wself.selectRow];
                
                //タイムラインを保存
                [TWTweets saveCurrentTimeline:wself.timelineArray];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:wself.selectRow
                                                            inSection:0];
                [wself.timeline deleteRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationBottom];
            }
            
            wself.tabBarController.selectedIndex = 0;
        });
        
    }else {
        
        ASYNC_MAIN_QUEUE ^{
            
            [ShowAlert error:@"自分のTweetではありません。"];
        });
    }
}

- (void)timelineMenuActionUserMenu {
    
    NSMutableArray *ids = [[NSMutableArray alloc] initWithArray:[_selectTweet[@"text"] twitterIds]];
    [ids insertObject:[NSString stringWithFormat:@"@%@", _selectTweet[@"user"][@"screen_name"]] atIndex:0];
    
    _selectTweetIds = [NSArray arrayWithArray:ids.deleteDuplicate];
    
    if ( ids.count == 0 ) {
        
        ids = nil;
        return;
    }
    
    ids = nil;
    __weak TimelineViewController *wself = self;
    
    ASYNC_MAIN_QUEUE ^{
        
        [wself showTwitterAccountSelectActionSheet:wself.selectTweetIds];
    });
}

- (void)timelineCopyMenuSTOT {
    
    NSString *tweetId = _selectTweet[@"id_str"];
    NSString *screenName = _selectTweet[@"user"][@"screen_name"];
    NSString *text = _selectTweet[@"text"];
    
    //公式RTであるか
    if ( _selectTweet[@"retweeted_status"][@"id"] ) {
        
        text = [TWEntities openTcoWithReTweet:_selectTweet];
        screenName = _selectTweet[@"retweeted_status"][@"user"][@"screen_name"];
        tweetId = _selectTweet[@"retweeted_status"][@"id_str"];
    }
    
    //STOT形式
    NSString *copyText = [[NSString alloc] initWithFormat:@"%@: %@ [https://twitter.com/%@/status/%@]",
                          screenName,
                          text,
                          screenName,
                          tweetId];
    [P_BOARD setString:copyText];
}

- (void)timelineCopyMenuText {
    
    NSString *text = _selectTweet[@"text"];
    
    //公式RTであるか
    if ( _selectTweet[@"retweeted_status"][@"id"] ) {
        
        text = [TWEntities openTcoWithReTweet:_selectTweet];
    }
    
    //本文
    [P_BOARD setString:text];
}

- (void)timelineCopyMenuTweetURL {
    
    NSString *screenName = _selectTweet[@"user"][@"screen_name"];
    NSString *tweetId = _selectTweet[@"id_str"];
    
    //公式RTであるか
    if ( _selectTweet[@"retweeted_status"][@"id"] ) {
        
        screenName = _selectTweet[@"retweeted_status"][@"user"][@"screen_name"];
        tweetId = _selectTweet[@"retweeted_status"][@"id_str"];
    }
    
    //URL
    [P_BOARD setString:[NSString stringWithFormat:@"https://twitter.com/%@/status/%@", screenName, tweetId]];
}

- (void)timelineCopyMenuURL {
    
    NSString *text = _selectTweet[@"text"];
    __block __weak NSString *weakText = text;
    
    if ( _selectTweet[@"retweeted_status"][@"id"] ) {
        
        text = [TWEntities openTcoWithReTweet:_selectTweet];
    }
    
    ASYNC_MAIN_QUEUE ^{
        
        //Tweet内のURL
        _tweetInUrls = [weakText urls];
        [self copyTweetInUrl:_tweetInUrls];
        weakText = nil;
    });
}

#pragma mark - UIPickerView

- (void)showPickerView {
    
    //NSLog(@"showPickerView");
    
    //表示フラグ
    _pickerVisible = YES;
    APP_DELEGATE.tabBarController.tabBar.userInteractionEnabled = NO;
    
    self.pickerBase = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                               SCREEN_HEIGHT,
                                                               SCREEN_WIDTH,
                                                               TOOL_BAR_HEIGHT + PICKER_HEIGHT)];
    _pickerBase.backgroundColor = [UIColor clearColor];
    [APP_DELEGATE.tabBarController.view addSubview:_pickerBase];
    
    self.pickerBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
                                                                 0,
                                                                 SCREEN_WIDTH,
                                                                 TOOL_BAR_HEIGHT)];
    _pickerBar.tintColor = _topBar.tintColor;
    
    self.pickerBarDoneButton = [[UIBarButtonItem alloc]
                                initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                target:self
                                action:@selector(pickerDone)];
    
    self.pickerBarCancelButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                  target:self
                                  action:@selector(pickerCancel)];
    
    [_pickerBar setItems:PICKER_BAR_ITEM animated:NO];
    [_pickerBase addSubview:_pickerBar];
    
    self.eventPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0,
                                                                      TOOL_BAR_HEIGHT,
                                                                      SCREEN_WIDTH,
                                                                      PICKER_HEIGHT)];
    _eventPicker.delegate = self;
    _eventPicker.dataSource = self;
    _eventPicker.showsSelectionIndicator = YES;
    [_pickerBase addSubview:_eventPicker];
    
    //アカウント初期値
    [_eventPicker selectRow:[D integerForKey:@"UseAccount"]
                inComponent:0
                   animated:NO];
    
    //イベント初期値
    [_eventPicker selectRow:1
                inComponent:1
                   animated:NO];
    
    _pickerBase.alpha = 0;
    _pickerBar.alpha = 0;
    _eventPicker.alpha = 0;
    
    __weak TimelineViewController *wself = self;
    
    //アニメーションさせつつ画面に表示
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         wself.pickerBase.frame = CGRectMake(0,
                                                             STATUS_BAR_HEIGHT + SCREEN_HEIGHT - TAB_BAR_HEIGHT - PICKER_HEIGHT - TOOL_BAR_HEIGHT,
                                                             SCREEN_WIDTH,
                                                             TOOL_BAR_HEIGHT + PICKER_HEIGHT);
                         
                         wself.pickerBase.alpha = 1;
                         wself.pickerBar.alpha = 1;
                         wself.eventPicker.alpha = 1;
                     }
     ];
}

- (void)pickerDone {
    
    //NSLog(@"pickerDone");
    
    int account = [_eventPicker selectedRowInComponent:0];
    int function = [_eventPicker selectedRowInComponent:1];
    NSString *tweetId = [[NSString alloc] initWithString:_selectTweet[@"id_str"]];
    
    //    NSLog(@"account: %d", account);
    //    NSLog(@"function: %d", function);
    
    [self performSelectorInBackground:@selector(hidePicker) withObject:nil];
    
    if ( function == 0 ) {
        
        BOOL favorited = [_selectTweet[@"favorited"] boolValue];
        
        if ( favorited ) {
            
            [TWEvent unFavorite:tweetId accountIndex:account];
            
        }else {
            
            [TWEvent favorite:tweetId accountIndex:account];
        }
        
    }else if ( function == 1 ) {
        
        [TWEvent reTweet:tweetId accountIndex:account];
        
    }else if ( function == 2 ) {
        
        [TWEvent favoriteReTweet:tweetId accountIndex:account];
    }
    
    [ActivityIndicator on];
}

- (void)pickerCancel {
    
    //NSLog(@"pickerCancel");
    
    [self hidePicker];
}

- (void)hidePicker {
    
    _pickerVisible = NO;
    APP_DELEGATE.tabBarController.tabBar.userInteractionEnabled = YES;
    
    __weak TimelineViewController *wself = self;
    
    //アニメーションさせつつ画面から消す
    [UIView animateWithDuration:0.4f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionNone
     
                     animations:^{
                         
                         wself.pickerBase.frame = CGRectMake(0,
                                                             SCREEN_HEIGHT,
                                                             SCREEN_WIDTH,
                                                             TOOL_BAR_HEIGHT + PICKER_HEIGHT);
                         
                         wself.pickerBase.alpha = 0;
                         wself.pickerBar.alpha = 0;
                         wself.eventPicker.alpha = 0;
                     }
     
                     completion:^( BOOL finished ){
                         
                         //NSLog(@"remove pickers");
                         wself.pickerBarCancelButton = nil;
                         wself.pickerBarDoneButton = nil;
                         
                         while ( wself.pickerBase.subviews.count ) {
                             
                             UIView *subView = wself.pickerBase.subviews.lastObject;
                             [subView removeFromSuperview];
                             subView = nil;
                         }
                         
                         [wself.pickerBase removeFromSuperview];
                         wself.pickerBase = nil;
                     }
     ];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    //列数を返す
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    //行数を返す
    if ( component == 0 ) {
        
        return [TWAccounts accountCount];
        
    }else{
        
        return 3;
    }
}


- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    
    //表示する内容を返す
    NSString * result = BLANK;
    
    if ( component == 0 ) {
        
        result = [TWAccounts selectAccount:row].username;
        
    }else {
        
        result = [@[@"Fav／UnFav", @"ReTweet", @"Fav+RT"] objectAtIndex:row];
    }
    
    return result;
}

#pragma mark - UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( [_alertSearchUserName hasPrefix:@"@"] ) {
        
        _alertSearchUserName = [_alertSearchUserName substringFromIndex:1];
    }
    
    //確定が押された
    if ( alertView.tag == 0 && buttonIndex == 1 ) {
        
        APP_DELEGATE.startupUrlList = [NSArray arrayWithObject:[CreateSearchURL twilog:_alertSearchUserName
                                                                            searchWord:_alertSearchText.text]];
        
        [self openBrowser];
        
    }else if ( alertView.tag == 1 && buttonIndex == 1 ) {
        
        _alertSearchText.text = [_alertSearchText.text deleteWhiteSpace];
        _alertSearchText.text = [_alertSearchText.text deleteWord:@"@"];
        
        if ( [_alertSearchText.text boolWithRegExp:@"[a-zA-Z0-9_]{1,15}"] ) {
            
            [TWGetTimeline userTimeline:_alertSearchText.text];
        }
        
    }else if ( alertView.tag == 2 && buttonIndex == 1 ) {
        
        [TWGetTimeline twitterSearch:[CreateSearchURL encodeWord:_alertSearchText.text
                                                        encoding:kCFStringEncodingUTF8]];
        
    }else if ( alertView.tag == 3 ) {
        
        if ( buttonIndex == 1 ) {
            
            if ( [_alertSearchText.text isNotEmpty] ) {
                
                [_timelineArray removeAllObjects];
                self.timelineArray = BLANK_M_ARRAY;
                [_timeline reloadData];
                
                __weak TimelineViewController *wself = self;
                
                DISPATCH_AFTER(0.6) ^{
                    
                    [wself openSearchStream: wself.alertSearchText.text];
                });
            }
        }
    }
}

#pragma mark - UIWebViewEx

- (void)openBrowser {
    
    NSLog(@"openBrowser");
    
    NSString *useragent = IPHONE_USERAGENT;
    
    if ( [[D objectForKey:@"UserAgent"] isEqualToString:@"FireFox"] ) {
        
        useragent = FIREFOX_USERAGENT;
        
    }else if ( [[D objectForKey:@"UserAgent"] isEqualToString:@"iPad"] ) {
        
        useragent = IPAD_USERAFENT;
    }
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:useragent, @"UserAgent", nil];
    [D registerDefaults:dictionary];
    dictionary = nil;
    
    _webBrowserMode = YES;
    APP_DELEGATE.reOpenUrl = BLANK;
    
    __weak TimelineViewController *wself = self;
    
    ASYNC_MAIN_QUEUE ^{
        
        WebViewExController *dialog = [[WebViewExController alloc] init];
        dialog.hidesBottomBarWhenPushed = YES;
        [wself.navigationController pushViewController:dialog
                                              animated:YES];
        dialog = nil;
    });
}

#pragma mark - UITextField

- (BOOL)textFieldShouldReturn:(SSTextField *)sender {
    
    //NSLog(@"Textfield Enter: %@", sender.text);
    
    if ( sender.tag == 0 ) {
        
        NSString *searchURL = [[NSString alloc] initWithString:[CreateSearchURL twilog:[TWAccounts currentAccountName] searchWord:_alertSearchText.text]];
        APP_DELEGATE.startupUrlList = [NSArray arrayWithObject:searchURL];
        
        [self openBrowser];
        searchURL = nil;
        
    }else if ( sender.tag == 1 ) {
        
        _alertSearchText.text = [_alertSearchText.text deleteWhiteSpace];
        _alertSearchText.text = [_alertSearchText.text deleteWord:@"@"];
        
        if ( [_alertSearchText.text boolWithRegExp:@"[a-zA-Z0-9_]{1,15}"] ) {
            
            [TWGetTimeline userTimeline:_alertSearchText.text];
        }
        
    }else if ( sender.tag == 2 ) {
        
        [TWGetTimeline twitterSearch:[CreateSearchURL encodeWord:_alertSearchText.text encoding:kCFStringEncodingUTF8]];
        
    }else if ( sender.tag == 3 ) {
        
        if ( [_alertSearchText.text isNotEmpty] ) {
            
            [_timelineArray removeAllObjects];
            self.timelineArray = BLANK_M_ARRAY;
            [_timeline reloadData];
            
            __weak TimelineViewController *wself = self;
            
            DISPATCH_AFTER(0.6) ^{
                
                [wself openSearchStream: wself.alertSearchText.text];
            });
        }
    }
    
    //キーボードを閉じる
    [_alertSearchText resignFirstResponder];
    
    //アラートを閉じる
    [_alertSearch dismissWithClickedButtonIndex:0 animated:YES];
    
    return YES;
}

#pragma mark - Notification

- (void)receiveProfile:(NSNotification *)notification {
    
    if ( [notification.userInfo[@"Result"] isEqualToString:@"Success"] ) {
        
        NSLog(@"receiveProfile Success");
        
        NSDictionary *result = [[NSDictionary alloc] initWithDictionary:notification.userInfo[@"Profile"]];
        
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        
        if ( result[@"screen_name"] != nil ) {
            
            NSString *screenName = result[@"screen_name"];
            __block __weak NSString *wScreenName = screenName;
            
            NSString *imageUrl = [[NSString alloc] initWithString:[TWIconBigger normal:result[@"profile_image_url"]]];
            NSString *fileName = [[NSString alloc] initWithString:[imageUrl lastPathComponent]];
            NSString *searchName = [[NSString alloc] initWithFormat:@"%@_%@", wScreenName, fileName];
            fileName = nil;
            
            if ( screenName == nil || searchName == nil ) return;
            
            [tempDic setObject:[NSString stringWithString:searchName]
                        forKey:@"SearchName"];
            searchName = nil;
            
            __weak TimelineViewController *wself = self;
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[TWIconBigger normal:result[@"profile_image_url"]]]];
            __block __weak ASIHTTPRequest *wRequest = request;
            
            request.userInfo = [NSDictionary dictionaryWithDictionary:tempDic];
            
            [wRequest setCompletionBlock:^ {
                
                NSString *savePath = [ICONS_DIRECTORY stringByAppendingPathComponent:wRequest.userInfo[@"SearchName"]];
                [wRequest.responseData writeToFile:savePath
                                        atomically:YES];
                savePath = nil;
                
                [Share cacheImage:[UIImage imageWithData:wRequest.responseData]
                          forName:[NSString stringWithString:wScreenName]
                 doneNotification:NO];
                
                wself.accountIconView.image = [UIImage imageWithData:wRequest.responseData];
                wScreenName = nil;
                wRequest = nil;
            }];
            
            [_requestedUser addObject:screenName];
            [wRequest startAsynchronous];
        }
        
    }else {
        
        NSLog(@"receiveProfile Error");
        
        [ShowAlert error:@"ユーザー情報の取得に失敗しました。"];
        _reloadButton.enabled = YES;
    }
}

- (void)receiveTweet:(NSNotification *)notification {
    
    if ( [notification.userInfo[@"Result"] isEqualToString:@"Success"] ) {
        
        [ActivityIndicator on];
        [_inReplyTo insertObject:notification.userInfo[@"Tweet"] atIndex:0];
        [self getInReplyToChain:notification.userInfo[@"Tweet"]];
        
    }else if ( [notification.userInfo[@"Result"] isEqualToString:@"AuthorizeError"] ) {
        
        [self getInReplyToChain:@{ @"in_reply_to_status_id_str" : @"END" }];
        
    }else {
        
        [ShowAlert error:@"Tweet取得中にエラーが発生しました。"];
    }
}

- (void)postDone:(NSNotification *)center {
    
    if ( APP_DELEGATE.postError.count != 0 ) {
        
        APP_DELEGATE.tabChangeFunction = @"PostError";
        _timelineSegment.selectedSegmentIndex = 0;
    }
}

- (void)destroyTweet:(NSNotification *)center {
    
    if ( center.userInfo[@"Tweet"][@"error"] != nil ) {
        
        [ShowAlert error:center.userInfo[@"Tweet"][@"error"]];
        return;
    }
    
    NSLog(@"deleteTweetId: %@", center.userInfo[@"Tweet"][@"id_str"]);
    
    //UserStream接続時は別の箇所で処理
    if ( _userStream ) return;
    
    //削除されたTweetを検索
    int index = 0;
    BOOL find = NO;
    for ( NSDictionary *tweet in _timelineArray ) {
        
        if ( [tweet[@"id_str"] isEqualToString:center.userInfo[@"Tweet"][@"id_str"]] ) {
            
            find = YES;
            
            break;
        }
        
        index++;
    }
    
    if ( find ) {
        
        ASYNC_MAIN_QUEUE ^{
            
            //見つかった物を削除
            [_timelineArray removeObjectAtIndex:index];
            
            //タイムラインを保存
            [TWTweets saveCurrentTimeline:_timelineArray];
            
            [_timeline deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                             withRowAnimation:UITableViewRowAnimationBottom];
        });
    }
}

- (void)receiveOfflineNotification:(NSNotification *)notification {
    
    NSLog(@"receiveOfflineNotification");
    
    _reloadButton.enabled = YES;
    if ( _userStream ) [self closeStream];
    if ( _searchStream ) [self closeSearchStream];
    if ( _isLoading ) [self finishLoad];
    [_grayView forceEnd];
}

- (void)enterBackground:(NSNotification *)notification {
    
    if ( [D boolForKey:@"EnterBackgroundUSDisConnect"] ) {
        
        if ( _userStream ) [self closeStream];
        if ( _searchStream ) [self closeSearchStream];
        if ( _connectionCheckTimer.isValid ) [self stopConnectionCheckTimer];
        if ( _onlineCheckTimer.isValid ) [self stopOnlineCheckTimer];
    }
}

- (void)becomeActive:(NSNotification *)notification {
    
    if ( _otherTweetsMode || _listMode ) return;
    
    if ( [D boolForKey:@"BecomeActiveUSConnect"] && _timelineSegment.selectedSegmentIndex == 0 ) {
        
        if ( !_userStream && !_searchStream ) [self pushReloadButton:nil];
    }
    
    APP_DELEGATE.pboardURLOpenTimeline = NO;
    
    if ( !_connectionCheckTimer.isValid ) [self startConnectionCheckTimer];
}

- (void)pboardNotification:(NSNotification *)notification {
    
    NSLog(@"Timeline pboardNotification: %@", notification.userInfo);
    
    //Timelineタブを開いていない場合は終了
    if ( APP_DELEGATE.tabBarController.selectedIndex != 1 ||
        APP_DELEGATE.browserOpenMode ) return;
    
    APP_DELEGATE.startupUrlList = [NSArray arrayWithObject:notification.userInfo[@"pboardURL"]];
    [self openBrowser];
}

#pragma mark - NSTimer

- (void)startConnectionCheckTimer {
    
    NSLog(@"startConnectionCheckTimer");
    
    _connectionCheckTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                             target:self
                                                           selector:@selector(checkConnection)
                                                           userInfo:nil
                                                            repeats:YES];
    [_connectionCheckTimer fire];
}

- (void)stopConnectionCheckTimer {
    
    NSLog(@"stopConnectionCheckTimer");
    
    [_connectionCheckTimer invalidate];
    self.connectionCheckTimer = nil;
}

- (void)checkConnection {
    
    //NSLog(@"checkConnection");
    
    if ( [InternetConnection disable] ) {
        
        [self stopConnectionCheckTimer];
        
        NSNotification *notification =
        [NSNotification notificationWithName:@"Offline"
                                      object:self
                                    userInfo:nil];
        
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        [self startOnlineCheckTimer];
    }
}

- (void)startOnlineCheckTimer {
    
    NSLog(@"startOnlineCheckTimer");
    
    _onlineCheckTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                         target:self
                                                       selector:@selector(checkOnline)
                                                       userInfo:nil
                                                        repeats:YES];
    [_onlineCheckTimer fire];
}

- (void)stopOnlineCheckTimer {
    
    NSLog(@"stopOnlineCheckTimer");
    
    [_onlineCheckTimer invalidate];
    self.onlineCheckTimer = nil;
}

- (void)checkOnline {
    
    //NSLog(@"checkOnline");
    
    if ( [InternetConnection isEnabled] ) {
        
        [self stopOnlineCheckTimer];
        
        NSNotification *notification =
        [NSNotification notificationWithName:@"BecomeOnline"
                                      object:self
                                    userInfo:nil];
        
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

#pragma mark - View

- (void)getMyAccountIcon {
    
    if ( [Share images].count == 0 ) {
        
        NSLog(@"icon file 0");
        
        //アイコンが1つもない場合は自分のアイコンがないので保存を行う
        [TWEvent getProfile:[TWAccounts currentAccountName]];
        return;
    }
    
    NSString *string = BLANK;
    BOOL find = NO;
    
    //NSLog(@"icons key: %@", array);
    
    NSArray *allKeys = [Share images].allKeys;
    
    for ( string in allKeys ) {
        
        if ( [string hasPrefix:[TWAccounts currentAccountName]] ) {
            
            NSLog(@"icon find");
            
            self.accountIconView.image = [[Share images] objectForKey:[TWAccounts currentAccountName]];
            find = YES;
            break;
        }
        
        if ( find ) break;
    }
    
    if ( !find ) {
        
        NSLog(@"icon not found");
        
        self.accountIconView.image = nil;
        [TWEvent getProfile:[TWAccounts currentAccountName]];
    }
}

- (void)setMyAccountIconCorner {
    
    [[_accountIconView layer] setMasksToBounds:YES];
    [[_accountIconView layer] setCornerRadius:5.0f];
}

- (void)timelineDidListChanged {
    
    //UserStream接続中の場合は切断する
    if ( _userStream ) [self closeStream];
    
    _reloadButton.enabled = YES;
    _timelineControlButton.enabled = YES;
    _listMode = YES;
    _timelineControlButton.image = _listImage;
    
    [TWTweets saveCurrentTimeline:_timelineArray];
    
    if ( [APP_DELEGATE.listId isNotEmpty] ) {
        
        self.timelineArray = [NSMutableArray arrayWithArray:_allLists[APP_DELEGATE.listId]];
        
    }else {
        
        self.timelineArray = BLANK_M_ARRAY;
    }
    
    [_timeline reloadData];
    
    if ( _timelineArray.count == 0 ) {
        
        [self showListSelectView];
    }
}

- (void)showListSelectView {
    
    ListViewController *dialog = [[ListViewController alloc] init];
    dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:dialog animated:YES];
}

- (void)setTimelineBarItems {
    
    _reloadButton.enabled = YES;
    [_topBar setItems:TOP_BAR animated:NO];
}

- (void)setOtherTweetsBarItems {
    
    _reloadButton.enabled = NO;
    [_topBar setItems:OTHER_TWEETS_BAR animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    
    //NSLog(@"%@: viewDidAppear", NSStringFromClass([self class]));
    
    [super viewDidAppear:animated];
    
    [_timeline flashScrollIndicators];
    
    if ( _webBrowserMode ) {
        
        _webBrowserMode = NO;
        
        if ( APP_DELEGATE.pcUaMode ) {
            
            APP_DELEGATE.pcUaMode = NO;
            [self openBrowser];
            return;
        }
    }
    
    if ( _listMode && [APP_DELEGATE.listId isNotEmpty] ) {
        
        if ( _userStream ) [self closeStream];
        
        if ( _allLists[APP_DELEGATE.listId] != nil ) {
            
            self.timelineArray = [NSMutableArray arrayWithArray:_allLists[APP_DELEGATE.listId]];
            
        }else {
            
            self.timelineArray = BLANK_M_ARRAY;
        }
        
        [_timeline reloadData];
        
        if ( _timelineArray.count == 0 ) {
            
            [TWList getList:APP_DELEGATE.listId];
            [_grayView start];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //NSLog(@"viewWillAppear");
    
    if ( ![_lastUpdateAccount isEqualToString:[TWAccounts currentAccountName]] &&
        [_lastUpdateAccount isNotEmpty] ) {
        
        self.viewWillAppear = YES;
        
        if ( _userStream ) [self closeStream];
        
        [self createTimeline];
    }
}

- (void)viewDidUnload {
    
    [self setTimelineMenu:nil];
    [self setGrayView:nil];
    [self setInReplyTo:nil];
    [self setCurrentList:nil];
    [self setSearchStreamTemp:nil];
    [self setAllLists:nil];
    [self setRequestedUser:nil];
    [self setMentionsArray:nil];
    [self setSelectTweetIds:nil];
    [self setTweetInUrls:nil];
    [self setSelectTweet:nil];
    
    [self setLastUpdateAccount:nil];
    [self setSelectAccount:nil];
    [self setAlertSearchUserName:nil];
    
    if ( _searchStreamTimer != nil ) {
        if ( [_searchStreamTimer isValid] ) {
            [_searchStreamTimer invalidate];
            [self setSearchStreamTimer:nil];
        }
    }
    
    if ( _connectionCheckTimer != nil ) {
        if ( [_connectionCheckTimer isValid] ) {
            [_connectionCheckTimer invalidate];
            [self setConnectionCheckTimer:nil];
        }
    }
    
    if ( _onlineCheckTimer != nil ) {
        if ( [_onlineCheckTimer isValid] ) {
            [_onlineCheckTimer invalidate];
            [self setOnlineCheckTimer:nil];
        }
    }
    
    [self setConnection:nil];
    [self setStartImage:nil];
    [self setStopImage:nil];
    [self setListImage:nil];
    
    [self setAlertSearch:nil];
    [self setAlertSearchText:nil];
    [self setPickerBar:nil];
    [self setEventPicker:nil];
    [self setPickerBarCancelButton:nil];
    [self setPickerBarDoneButton:nil];
    [self setHeaderView:nil];
    [self setPickerBase:nil];
    [self setActivityTable:nil];
    [self setImageWindow:nil];
    
    [self setTopBar:nil];
    [self setTimeline:nil];
    [self setFlexibleSpace:nil];
    [self setPostButton:nil];
    [self setTimelineControlButton:nil];
    [self setReloadButton:nil];
    [self setActionButton:nil];
    [self setCloseOtherTweetsButton:nil];
    [self setAccountIconView:nil];
    [self setFixedSpace:nil];
    [self setTimelineSegment:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotate {
    
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

@end
