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

#define NEW_CELL_IDENTIFIER @"TimelineStyledCell"
#define NEW_CELL_XIB_NAME @"TimelineStyledCellController"
#define OLD_CELL_IDENTIFIER @"TimelineCell"
#define OLD_CELL_XIB_NAME @"TimelineCellController"
#define CELL_IDENTIFIER @"TimelineAttributedCell"

#define BLACK_COLOR [UIColor blackColor]
#define GREEN_COLOR [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0]
#define BLUE_COLOR  [UIColor blueColor]
#define RED_COLOR   [UIColor redColor]
#define GOLD_COLOR  [UIColor colorWithRed:0.5 green:0.4 blue:0.0 alpha:1.0]

@implementation TimelineViewController
@synthesize appDelegate = _appDelegate;
@synthesize grayView = _grayView;
@synthesize topBar = _topBar;
@synthesize timeline = _timeline;
@synthesize flexibleSpace = _flexibleSpace;
@synthesize fixedSpace = _fixedSpace;
@synthesize postButton = _postButton;
@synthesize timelineControlButton = _timelineControlButton;
@synthesize actionButton = _actionButton;
@synthesize closeOtherTweetsButton = _closeOtherTweetsButton;
@synthesize accountIconView = _accountIconView;
@synthesize timelineSegment = _timelineSegment;
@synthesize reloadButton = _reloadButton;

@synthesize timelineArray = _timelineArray;
@synthesize inReplyTo = _inReplyTo;
@synthesize reqedUser = _reqedUser;
@synthesize iconUrls = _iconUrls;
@synthesize currentList = _currentList;
@synthesize searchStreamTemp = _searchStreamTemp;
@synthesize icons = _icons;
@synthesize allLists = _allLists;
@synthesize mentionsArray = _mentionsArray;
@synthesize selectTweetIds = _selectTweetIds;
@synthesize tweetInUrls = _tweetInUrls;
@synthesize currentTweet = _currentTweet;
@synthesize selectTweet = _selectTweet;
@synthesize lastUpdateAccount = _lastUpdateAccount;
@synthesize selectAccount = _selectAccount;
@synthesize alertSearchUserName = _alertSearchUserName;
@synthesize searchStreamTimer = _searchStreamTimer;
@synthesize connectionCheckTimer = _connectionCheckTimer;
@synthesize onlineCheckTimer = _onlineCheckTimer;
@synthesize connection = _connection;
@synthesize d = _d;
@synthesize fileManager = _fileManager;

@synthesize pboard = _pboard;
@synthesize startImage = _startImage;
@synthesize stopImage = _stopImage;
@synthesize listImage = _listImage;
@synthesize alertSearch = _alertSearch;
@synthesize alertSearchText = _alertSearchText;
@synthesize pickerBase = _pickerBase;
@synthesize pickerBar = _pickerBar;
@synthesize eventPicker = _eventPicker;
@synthesize pickerBarDoneButton = _pickerBarDoneButton;
@synthesize pickerBarCancelButton = _pickerBarCancelButton;
@synthesize headerView = _headerView;
@synthesize activityTable = _activityTable;
@synthesize imageWindow = _imageWindow;

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
    
    NSLog(@"viewDidLoad");
    
    //TimelineのTableViewの高さを設定する
    [self setTimelineHeight];
    
    //各種通知設定
    [self setNotifications];
    [self startConnectionCheckTimer];
    [self createPullDownRefreshHeader];
    
    _grayView = [ActivityGrayView grayViewWithTaskName:@"FirstLoad"];
    [self.view addSubview:_grayView];
    
    _imageWindow = [[ImageWindow alloc] init];
    [self.view addSubview:_imageWindow];
    
    //各種初期化
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _d = [NSUserDefaults standardUserDefaults];
    _fileManager = [NSFileManager defaultManager];
    _pboard = [UIPasteboard generalPasteboard];
    
    _timelineArray = BLANK_ARRAY;
    _inReplyTo = BLANK_M_ARRAY;
    _reqedUser = BLANK_M_ARRAY;
    _iconUrls = BLANK_M_ARRAY;
    _currentList = BLANK_M_ARRAY;
    _searchStreamTemp = BLANK_M_ARRAY;
    _icons = BLANK_M_DIC;
    _mentionsArray = BLANK_ARRAY;
    _allLists = BLANK_M_DIC;
    _selectTweet = BLANK_DIC;
    _selectAccount = BLANK;
    _alertSearchUserName = BLANK;
    
    self.searchStreamTimer = nil;
    
    _startImage = [UIImage imageNamed:@"ForwardIcon.png"];
    _stopImage = [UIImage imageNamed:@"stop.png"];
    _listImage = [UIImage imageNamed:@"list.png"];
    _timelineControlButton.image = _startImage;
    
    //ツールバーにボタンを設定
    [self setTimelineBarItems];
    
    userStream = NO;
    openStreamAfter = NO;
    userStreamFirstResponse = NO;
    pickerVisible = NO;
    
    //アイコン表示の角を丸める
    [self setMyAccountIconCorner];
    
    //アイコン保存用ディレクトリ確認
    BOOL isDir = NO;
    BOOL directoryExists = ( [_fileManager fileExistsAtPath:ICONS_DIRECTORY isDirectory:&isDir] && isDir );
    
    if ( !directoryExists ) {
        
        //存在しない場合作成
        [_fileManager createDirectoryAtPath:ICONS_DIRECTORY
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    
    //クラッシュログ保存用ディレクトリ確認
    isDir = NO;
    directoryExists = ( [_fileManager fileExistsAtPath:LOGS_DIRECTORY isDirectory:&isDir] && isDir );
    
    if ( !directoryExists ) {
        
        //存在しない場合作成
        [_fileManager createDirectoryAtPath:LOGS_DIRECTORY
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    
    //インターネット接続を確認
    if ( [InternetConnection disable] ) return;
    
    //タイムライン生成
    [self performSelectorInBackground:@selector(createTimeline) withObject:nil];
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
    _headerView = [[TTTableHeaderDragRefreshView alloc] initWithFrame:headerRect];
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
    
    if ( scrollView.dragging && !isLoading ) {
        
        if ( scrollView.contentOffset.y > REFRESH_DERAY &&
            scrollView.contentOffset.y < 0.0f ) {
            
            [_headerView setStatus:TTTableHeaderDragRefreshPullToReload];
            
        }else if ( scrollView.contentOffset.y < REFRESH_DERAY ) {
            
            [_headerView setStatus:TTTableHeaderDragRefreshReleaseToReload];
        }
    }
    
    if ( isLoading ) {
        
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
        !isLoading ) {
        
        [self startLoad];
    }
}

#pragma mark - PullDownRefresh

- (void)startLoad {
    
    NSLog(@"startLoad");
    
    [_headerView setStatus:TTTableHeaderDragRefreshLoading];
    
    if ( _reloadButton.isEnabled ) {
        
        [self performSelector:@selector(pushReloadButton:)
                   withObject:nil
                   afterDelay:0.1];
        
    }else {
        
        return;
    }
    
    isLoading = YES;
    
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
    isLoading = NO;
}

#pragma mark - TimelineMethod

- (void)createTimeline {
    
    NSLog(@"createTimeline");
    
    @autoreleasepool {
        
        //インターネット接続を確認
        if ( ![InternetConnection enable] ) return;
        
        if ( [TWAccounts currentAccount] == nil ) {
            
            [ShowAlert error:@"Twitterアカウントが取得できません。iPhoneの設定より登録の後、ご使用ください。"];
            return;
        }
        
        //アクティブアカウントのタイムラインを反映
        if ( _timelineArray != [TWTweets currentTimeline] ) {
            
            _timelineArray = [TWTweets currentTimeline];
        }
        
        if ( _timelineArray.count != 0 ) {
            
            //差分取得用にタイムライン最上部のTweetのIDを取得する
            BOOL find = NO;
            int i = 0;
            
            for ( NSDictionary *obj in _timelineArray ) {
                
                if ( [obj objectForKey:@"id_str"] != nil ) {
                    
                    find = YES;
                    break;
                }
                
                i++;
            }
            
            if ( find ) {
                
                [TWTweets saveSinceID:[[_timelineArray objectAtIndex:i] objectForKey:@"id_str"]];
            }
        }
        
        //タイムライン取得
        [TWGetTimeline homeTimeline];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            if ( _timelineArray.count == 0 ) [_grayView start];
        });
    }
}

- (void)loadTimeline:(NSNotification *)center {
    
    @autoreleasepool {
        dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
        dispatch_async( globalQueue, ^{
            dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
            @try {
                dispatch_sync( syncQueue, ^{
                    
                    NSLog(@"loadTimeline[%d], userStream[%@]", _timelineArray.count, userStream ? @"ON" : @"OFF");
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        [self finishLoad];
                    });
                    
                    //Timelineタブ以外が選択されている場合は終了
                    if ( _timelineSegment.selectedSegmentIndex != 0 ) return;
                    
                    if ( ![[center.userInfo objectForKey:@"Type"] isEqualToString:@"Timeline"] ) return;
                    
                    if ( ![[center.userInfo objectForKey:@"Account"] isEqualToString:[TWAccounts currentAccountName]] ) {
                        
                        NSLog(@"not active account reload");
                        
                        return;
                    }
                    
                    //自分のアイコンを設定
                    [self getMyAccountIcon];
                    
                    //更新アカウントを記憶
                    _lastUpdateAccount = [TWAccounts currentAccountName];
                    
                    NSString __autoreleasing *result = [center.userInfo objectForKey:@"Result"];
                    
                    if ( [result isEqualToString:@"TimelineSuccess"] ) {
                        
                        NSArray __autoreleasing *newTweet = [center.userInfo objectForKey:@"Timeline"];
                        
                        //NSLog(@"newTweet: %@", newTweet);
                        
                        if ( newTweet.count == 0 ) {
                            
                            NSLog(@"newTweet.count == 0");
                            
                            dispatch_async(dispatch_get_main_queue(), ^ {
                                
                                _reloadButton.enabled = YES;
                                
                                if ( viewWillAppear ) {
                                    
                                    viewWillAppear = NO;
                                    [_timeline reloadData];
                                }
                            });
                            
                            if ( [_d boolForKey:@"ReloadAfterUSConnect"] && !userStream ) {
                                
                                //UserStream接続
                                [self pushTimelineControlButton:nil];
                            }
                            
                            return;
                        }
                        
                        if ( [[newTweet objectAtIndex:0] objectForKey:@"errors"] != nil ) {
                            
                            NSLog(@"newTweet error");
                            
                            [ShowAlert error:@"タイムライン取得時にエラーが発生しました。"];
                            
                            if ( [_d boolForKey:@"ReloadAfterUSConnect"] && !userStream ) {
                                
                                //UserStream接続
                                [self pushTimelineControlButton:nil];
                            }
                            
                            return;
                        }
                        
                        //NG判定を行う
                        newTweet = [TWNgTweet ngAll:newTweet];
                        
                        if ( _timelineArray.count != 0 && newTweet.count != 0 ) {
                            
                            //重複する場合は削除
                            if ( [[[newTweet objectAtIndex:newTweet.count - 1] objectForKey:@"id_str"] isEqualToString:[[_timelineArray objectAtIndex:0] objectForKey:@"id_str"]] ) {
                                
                                NSMutableArray __autoreleasing *tempArray = [NSMutableArray arrayWithArray:newTweet];
                                [tempArray removeObjectAtIndex:newTweet.count - 1];
                                newTweet = [NSArray arrayWithArray:tempArray];
                            }
                        }
                        
                        if ( [EmptyCheck check:newTweet] ) {
                            
                            int index = 0;
                            for ( id tweet in newTweet ) {
                                
                                [_timelineArray insertObject:tweet atIndex:index];
                                index++;
                            }
                            
                            [self checkTimelineCount];
                            
                            //NSLog(@"%@", _timelineArray);
                            
                            //タイムラインを保存
                            [TWTweets saveCurrentTimeline:_timelineArray];
                            
                            dispatch_async(dispatch_get_main_queue(), ^ {
                                
                                _reloadButton.enabled = YES;
                                
                                [ActivityIndicator off];
                                
                                //タイムラインを再読み込み
                                [_timeline reloadData];
                                
                                //新着取得前の最新までスクロール
                                [self scrollTimelineForNewTweet];
                                
                                if ( [_d boolForKey:@"ReloadAfterUSConnect"] && !userStream ) {
                                    
                                    //UserStream接続
                                    [self performSelector:@selector(pushTimelineControlButton:) withObject:nil afterDelay:0.1];
                                }
                            });
                            
                            //タイムラインからアイコンのURLを取得
                            [self getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
                            
                        }else {
                            
                            dispatch_async(dispatch_get_main_queue(), ^ {
                                
                                _reloadButton.enabled = YES;
                                
                                if ( [_d boolForKey:@"ReloadAfterUSConnect"] && !userStream ) {
                                    
                                    //UserStream接続
                                    [self performSelector:@selector(pushTimelineControlButton:) withObject:nil afterDelay:0.1];
                                }
                                
                                //タイムライン表示を更新
                                [_timeline reloadData];
                            });
                        }
                        
                    }else if ( [result isEqualToString:@"TimelineError"] ) {
                        
                        _reloadButton.enabled = YES;
                    }
                });
                
            }@finally {
                
                dispatch_release(syncQueue);
            }
        });
    }
}

- (void)loadUserTimeline:(NSNotification *)center {
    
    NSLog(@"loadUserTimeline");
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        [self finishLoad];
    });
    
    if ( ![[center.userInfo objectForKey:@"Type"] isEqualToString:@"UserTimeline"] ) return;
    
    //レスポンスが空の場合は何もしない
    if ( [[center.userInfo objectForKey:@"UserTimeline"] count] == 0 ) return;
    
    //UserStream接続中の場合は切断する
    if ( userStream ) [self closeStream];
    
    _timelineControlButton.enabled = NO;
    
    NSString *result = [center.userInfo objectForKey:@"Result"];
    
    if ( [result isEqualToString:@"UserTimelineSuccess"] ) {
        
        NSArray *newTweet = [center.userInfo objectForKey:@"UserTimeline"];
        
        //NSLog(@"newTweet: %@", newTweet);
        
        NSLog(@"UserTimeline: %dTweet", newTweet.count);
        
        //NG判定を行う
        newTweet = [TWNgTweet ngAll:newTweet];
        
        //InReplyToからの復帰用に保存しておく
        _mentionsArray = newTweet;
        
        _timelineArray = [NSMutableArray arrayWithArray:newTweet];
        
        //タイムラインからアイコンのURLを取得
        [self getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [ActivityIndicator off];
            
            [self setOtherTweetsBarItems];
            
            //タイムラインを再読み込み
            [_timeline reloadData];
            
            [self scrollTimelineToTop:NO];
        });
        
    }else {
        
        [ShowAlert error:@"UserTimelineが読み込めませんでした。"];
    }
}

- (void)loadMentions:(NSNotification *)center {
    
    NSLog(@"loadMentions");
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        [self finishLoad];
    });
    
    if ( ![[center.userInfo objectForKey:@"Type"] isEqualToString:@"Mentions"] ) return;
    
    //Mentionsタブ以外が選択されている場合は終了
    if ( _timelineSegment.selectedSegmentIndex != 1 ) return;
    
    //UserStream接続中の場合は切断する
    if ( userStream ) [self closeStream];
    
    _reloadButton.enabled = YES;
    _timelineControlButton.enabled = NO;
    
    NSString *result = [center.userInfo objectForKey:@"Result"];
    
    if ( [result isEqualToString:@"MentionsSuccess"] ) {
        
        NSArray *newTweet = [center.userInfo objectForKey:@"Mentions"];
        
        //t.coを展開
        newTweet = [TWEntities replaceTcoAll:newTweet];
        
        //NG判定を行う
        newTweet = [TWNgTweet ngAll:newTweet];
        
        //InReplyToからの復帰用に保存しておく
        _mentionsArray = newTweet;
        
        _timelineArray = [NSMutableArray arrayWithArray:newTweet];
        
        //タイムラインからアイコンのURLを取得
        [self getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [ActivityIndicator off];
            
            //タイムラインを再読み込み
            [_timeline reloadData];
            
            [self scrollTimelineToTop:NO];
        });
    }
}

- (void)loadFavorites:(NSNotification *)center {
    
    NSLog(@"loadFavorites");
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        [self finishLoad];
    });
    
    if ( ![[center.userInfo objectForKey:@"Type"] isEqualToString:@"Favorites"] ) return;
    
    //Favoritesタブ以外が選択されている場合は終了
    if ( _timelineSegment.selectedSegmentIndex != 2 ) return;
    
    //UserStream接続中の場合は切断する
    if ( userStream ) [self closeStream];
    
    _timelineControlButton.enabled = NO;
    _reloadButton.enabled = YES;
    
    NSString *result = [center.userInfo objectForKey:@"Result"];
    
    if ( [result isEqualToString:@"FavoritesSuccess"] ) {
        
        NSArray *newTweet = [center.userInfo objectForKey:@"Favorites"];
        
        //t.coを展開
        newTweet = [TWEntities replaceTcoAll:newTweet];
        
        //InReplyToからの復帰用に保存しておく
        _mentionsArray = newTweet;
        
        _timelineArray = [NSMutableArray arrayWithArray:newTweet];
        
        //タイムラインからアイコンのURLを取得
        [self getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [ActivityIndicator off];
            
            //タイムラインを再読み込み
            [_timeline reloadData];
            
            [self scrollTimelineToTop:NO];
        });
    }
}

- (void)loadSearch:(NSNotification *)center {
    
    NSLog(@"loadSearch");
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        [self finishLoad];
    });
    
    if ( ![[center.userInfo objectForKey:@"Type"] isEqualToString:@"Search"] ) return;
    
    //UserStream接続中の場合は切断する
    if ( userStream ) [self closeStream];
    
    _timelineControlButton.enabled = NO;
    
    NSString *result = [center.userInfo objectForKey:@"Result"];
    
    if ( [result isEqualToString:@"SearchSuccess"] ) {
        
        NSArray *newTweet = [center.userInfo objectForKey:@"Search"];
        
        //InReplyToからの復帰用に保存しておく
        _mentionsArray = newTweet;
        
        _timelineArray = [NSMutableArray arrayWithArray:newTweet];
        
        //タイムラインからアイコンのURLを取得
        [self getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
        
        [ActivityIndicator off];
        
        [self setOtherTweetsBarItems];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [ActivityIndicator off];
            
            //タイムラインを再読み込み
            [_timeline reloadData];
            
            [self scrollTimelineToTop:NO];
        });
    }
}

- (void)loadList:(NSNotification *)center {
    
    NSLog(@"loadList");
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        [self finishLoad];
    });
    
    if ( ![[center.userInfo objectForKey:@"Type"] isEqualToString:@"List"] ) return;
    
    //Listタブ以外が選択されている場合は終了
    if ( _timelineSegment.selectedSegmentIndex != 3 ) return;
    
    _reloadButton.enabled = YES;
    
    NSArray *newTweet = [center.userInfo objectForKey:@"ResultData"];
    
    //t.coを展開
    newTweet = [TWEntities replaceTcoAll:newTweet];
    
    //NG判定を行う
    newTweet = [TWNgTweet ngAll:newTweet];
    
    _currentList = [NSMutableArray arrayWithArray:newTweet];
    
    [_allLists setObject:_currentList forKey:_appDelegate.listId];
    
    _timelineArray = _currentList;
    
    //タイムラインからアイコンのURLを取得
    [self getIconWithTweetArray:_timelineArray];
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        [ActivityIndicator off];
        
        //タイムラインを再読み込み
        [_timeline reloadData];
        
        [self scrollTimelineToTop:NO];
    });
}

- (void)getIconWithTweetArray:(NSMutableArray *)tweetArray {
    
    //NSLog(@"getIconWithTweetArray");
    
    NSMutableSet *addUser = [NSMutableSet set];
    NSMutableSet *addIconUrls = [NSMutableSet setWithArray:_iconUrls];
    
    for ( NSDictionary *dic in tweetArray ) {
        
        @autoreleasepool {
            
            //アイコンのユーザー名
            NSString __autoreleasing *screenName = [[dic objectForKey:@"user"] objectForKey:@"screen_name"];
            
            if ( ![EmptyCheck string:screenName] ) {
                
                screenName = [dic objectForKey:@"screen_name"];
            }
            
            //biggerサイズのURL
            NSString __autoreleasing *biggerUrl = [TWIconBigger normal:[[dic objectForKey:@"user"] objectForKey:@"profile_image_url"]];
            
            if ( ![EmptyCheck string:biggerUrl] ) {
                
                //URLをbiggersサイズに変換する
                biggerUrl = [TWIconBigger normal:[dic objectForKey:@"profile_image_url"]];
            }
            
            //検索用の名前
            NSString __autoreleasing *searchName = [NSString stringWithFormat:@"%@_%@", screenName, [biggerUrl lastPathComponent]];
            
            if ( [_appDelegate iconExist:searchName] ) {
                
                //アイコンファイルを読み込み
                UIImage __autoreleasing *image = [UIImage imageWithContentsOfFile:FILE_PATH];
                
                if ( image != nil ) {
                    
                    [_icons setObject:image forKey:searchName];
                    
                    //自分のアイコンの場合は上部バーに設定
                    if ( [screenName isEqualToString:[TWAccounts currentAccountName]] ) {
                        
                        _accountIconView.image = image;
                    }
                    
                    [ActivityIndicator off];
                }
                
            }else {
                
                //保存されていないアイコンを保存する
                if ( [_icons objectForKey:searchName] == nil ) {
                    
                    //各情報が空でないかチェック
                    if ( [EmptyCheck string:screenName] &&
                         [EmptyCheck string:biggerUrl] &&
                         [EmptyCheck string:[biggerUrl lastPathComponent]] &&
                         [EmptyCheck string:searchName] ) {
                        
                        NSMutableDictionary __autoreleasing *tempDic = BLANK_M_DIC;
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
            
            if ( screenName != nil ) {
                
                //リクエストを行ったユーザーを追加
                [addUser addObject:screenName];
            }
        }
    }
    
    iconWorking = YES;
    
    for ( id user in addUser ) {
        
        [_reqedUser addObject:user];
    }
    
    //アイコン保存開始
    if ( addIconUrls.count != 0 ) {
        
        _iconUrls = [NSMutableArray arrayWithArray:[addIconUrls allObjects]];
        
        iconWorking = NO;
        
        [self getIconWithSequential];
        
    }else {
        
        iconWorking = NO;
    }
    
    [ActivityIndicator off];
}

- (void)getIconWithSequential {
    
    //NSLog(@"getIconWithSequential");
    
    //保存すべきURLが無ければ終了
    if ( _iconUrls.count == 0 ) {
        
        [ActivityIndicator off];
        
        return;
    }
    
    if ( iconWorking ) {
        
        [self performSelector:@selector(getIconWithSequential) withObject:nil afterDelay:0.1];
        
    }else {
        
        //アイコンのURLを取得
        NSDictionary *dic = [_iconUrls objectAtIndex:0];
        NSString *biggerUrl = [dic objectForKey:@"profile_image_url"];
        
        //アイコンダウンロード開始
        NSURL *URL = [NSURL URLWithString:biggerUrl];
        ASIHTTPRequest *reSendRequest = [[ASIHTTPRequest alloc] initWithURL:URL];
        reSendRequest.userInfo = dic;
        [reSendRequest setDelegate:self];
        [reSendRequest start];
        
        [_iconUrls removeObjectAtIndex:0];
    }
}

- (void)changeAccount:(NSNotification *)notification {
    
    //Tweet画面でアカウントが切り替えられた際に呼ばれる
    
    NSLog(@"changeAccount");
    
    //UserStreamが有効な場合切断する
    if ( userStream ) [self closeStream];
    
    //自分のアカウントを設定
    [self getMyAccountIcon];
    
    //List一覧のキャッシュを削除
    _appDelegate.listAll = nil;
    _appDelegate.listAll = BLANK_ARRAY;
    
    //タイムラインをアクティブアカウントの物に切り替え
    _timelineArray = [TWTweets currentTimeline];
    [_timeline reloadData];
    
    //リロードする
    [self performSelector:@selector(createTimeline) withObject:nil afterDelay:0.1];
}

- (void)refreshTimelineCell:(NSNumber *)index {
    
    int i = [index intValue];
    
    //NSLog(@"refreshTimelineCell: %d", i);
    
    if ( [_timelineArray objectAtIndex:i] == nil ||
        _timelineArray.count - 1 < i ) return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    [_timeline reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)copyTweetInUrl:(NSArray *)urlList {
    
    NSLog(@"copyTweetInUrl[%d]: %@", urlList.count, urlList);
    
    if (urlList.count == 0 ) {
        
        [ShowAlert error:@"Tweet内にURLがありません。"];
        
    }else if (urlList.count == 1 ) {
        
        [_pboard setString:[urlList objectAtIndex:0]];
        self.tweetInUrls = nil;
        _tweetInUrls = BLANK_ARRAY;
        
    }else if (urlList.count == 2 ) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"Tweet内のURLをコピー"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:[urlList objectAtIndex:0],
                                [urlList objectAtIndex:1], nil];
        sheet.tag = 7;
        
        [sheet showInView:_appDelegate.tabBarController.self.view];
        
    }else if (urlList.count == 3 ) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"Tweet内のURLをコピー"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:[urlList objectAtIndex:0],
                                [urlList objectAtIndex:1],
                                [urlList objectAtIndex:2], nil];
        sheet.tag = 8;
        
        [sheet showInView:_appDelegate.tabBarController.self.view];
        
    }else if (urlList.count == 4 ) {
        
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
        
        [sheet showInView:_appDelegate.tabBarController.self.view];
        
    }else if (urlList.count == 5 ) {
        
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
        
        [sheet showInView:_appDelegate.tabBarController.self.view];
        
    }else if (urlList.count >= 6 ) {
        
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
        
        [sheet showInView:_appDelegate.tabBarController.self.view];
    }
}

- (void)checkTimelineCount {
    
    //    int max = 400;
    //    if ( searchStream ) max = 100;
    //
    //    @synchronized(self) {
    //
    //        while ( _timelineArray.count > max ) {
    //
    //            //NSLog(@"checkTimelineCount: %d", _timelineArray.count);
    //
    //            [_timelineArray removeLastObject];
    //            [_timeline deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_timelineArray.count - 1 inSection:0]]
    //                            withRowAnimation:UITableViewRowAnimationBottom];
    //        }
    //    }
}

#pragma mark - In reply to

- (void)getInReplyToChain:(NSDictionary *)tweetData {
    
    NSString *inReplyToId = [tweetData objectForKey:@"in_reply_to_status_id_str"];
    
    NSLog(@"getInReplyToChain: %@", inReplyToId);
    
    if ( ![EmptyCheck check:inReplyToId] || [inReplyToId isEqualToString:@"END"] ) {
        
        //InReplyToIDがもうない場合は表示を行う
        
        if ( [EmptyCheck check:_inReplyTo] && _inReplyTo.count > 1 ) {
            
            NSLog(@"InReplyTo GET END");
            
            [self closeStream];
            
            dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
            dispatch_async( globalQueue, ^{
                dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
                dispatch_sync( syncQueue, ^{
                    
                    //表示開始
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        //t.coを展開
                        _inReplyTo = [TWEntities replaceTcoAll:_inReplyTo];
                        
                        [self setOtherTweetsBarItems];
                        
                        _timelineArray = BLANK_M_ARRAY;
                        [_timeline reloadData];
                        
                        [NSThread sleepForTimeInterval:0.1f];
                        
                        for ( NSDictionary *tweet in _inReplyTo ) {
                            
                            //タイムラインに追加
                            [_timelineArray insertObject:tweet atIndex:0];
                            [_timeline insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                        }
                        
                        //タイムラインからアイコンのURLを取得
                        [self getIconWithTweetArray:[NSMutableArray arrayWithArray:_timelineArray]];
                    });
                });
                
                dispatch_release(syncQueue);
            });
        }
        
    }else {
        
        BOOL find = NO;
        NSDictionary *findTweet = BLANK_DIC;
        
        for ( NSDictionary *searchTweet in _timelineArray ) {
            
            NSString *searchTweetID = [searchTweet objectForKey:@"id_str"];
            
            if ( [EmptyCheck check:searchTweetID] ) {
                
                if ( [searchTweetID isEqualToString:inReplyToId] ) {
                    
                    find = YES;
                    findTweet = searchTweet;
                    [_inReplyTo insertObject:findTweet atIndex:0];
                }
            }
            
            if ( find ) break;
        }
        
        [ActivityIndicator on];
        
        if ( find ) {
            
            NSLog(@"InReplyTo TL");
            
            [self getInReplyToChain:findTweet];
            
        }else {
            
            NSLog(@"InReplyTo REST");
            
            [TWEvent getTweet:inReplyToId];
        }
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //TableViewの要素数を返す
	return [_timelineArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"cellForRowAtIndexPath: %d", indexPath.row);
    
    TimelineAttributedCell *cell = (TimelineAttributedCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    
    @autoreleasepool {
        
        if ( cell == nil ) {
            
            cell = [[TimelineAttributedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
            
            [cell.iconView addTarget:self action:@selector(pushIcon:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        _currentTweet = [_timelineArray objectAtIndex:indexPath.row];
        
        BOOL reTweet = [[_currentTweet objectForKey:@"retweeted_status"] boolForKey:@"id"];
        
        CellTextColor textColor = CellTextColorBlack;
        
        //ReTweetの色変えと本文の調整は先にやっておく
        if ( reTweet ) {
            
            textColor = CellTextColorGreen;
        }
        
        //Tweetの本文
        NSString __autoreleasing *text = [_currentTweet objectForKey:@"text"];
        
        //ID
        NSString __autoreleasing *screenName = [[_currentTweet objectForKey:@"user"] objectForKey:@"screen_name"];
        cell.iconView.buttonTitle = screenName;
        
        //ID - 日付 [クライアント名]
        NSString __autoreleasing *infoLabelText = [_currentTweet objectForKey:@"info_text"];
        
        //アイコン検索用
        NSString __autoreleasing *searchName = [_currentTweet objectForKey:@"search_name"];
        
        if ( [_icons objectForKey:searchName] != nil &&
            cell.iconView.layer.sublayers.count != 0 &&
            [[cell.iconView.layer.sublayers.lastObject name] isEqualToString:@"Icon"] ) {
            
            [cell.iconView.layer.sublayers.lastObject setContents:(id)[[_icons objectForKey:searchName] CGImage]];
            
        }else {
            
            [cell.iconView.layer.sublayers.lastObject setContents:nil];
        }
        
        //自分の発言の色を変える
        if ( [screenName isEqualToString:[TWAccounts currentAccountName]] &&
            !reTweet ) {
            
            textColor = CellTextColorBlue;
        }
        
        //Replyの色を変える
        if ( [text rangeOfString:[TWAccounts currentAccount].accountDescription].location != NSNotFound &&
            !reTweet ) {
            
            textColor = CellTextColorRed;
        }
        
        //Favoriteの色を変えて星をつける
        if ( [_currentTweet boolForKey:@"favorited"] &&
            !reTweet ) {
            
            infoLabelText = [NSMutableString stringWithFormat:@"★%@", infoLabelText];
            textColor = CellTextColorGold;
        }
        
        //ふぁぼられイベント用
        if ( [_currentTweet objectForKey:@"FavEvent"] != nil ) {
            
            NSString __autoreleasing *temp = infoLabelText;
            infoLabelText = [NSString stringWithFormat:@"【%@がお気に入りに追加】",
                             [_currentTweet objectForKey:@"addUser"]];
            
            text = [NSString stringWithFormat:@"%@\n%@", temp, text];
        }
        
        //セルへの反映開始
        cell.infoLabel.text = infoLabelText;
        cell.infoLabel.textColor = [self getTextColor:textColor];
        
        NSMutableAttributedString *mainText = [NSMutableAttributedString attributedStringWithString:text];
        [mainText setFont:[UIFont systemFontOfSize:12]];
        [mainText setTextColor:[self getTextColor:textColor] range:NSMakeRange(0, text.length)];
        [mainText setTextAlignment:kCTLeftTextAlignment
                     lineBreakMode:kCTLineBreakByCharWrapping
                     maxLineHeight:14.0
                     minLineHeight:14.0
                    maxLineSpacing:1.0
                    minLineSpacing:1.0
                             range:NSMakeRange(0, mainText.length)];
        cell.mainLabel.attributedText = mainText;
        
        //セルの高さを設定
        cell.mainLabel.frame = CGRectMake(54, 19, 264, [self heightForContents:text]);
    }
    
    return cell;
}

- (UIColor *)getTextColor:(int)color {
    
    if ( color == CellTextColorBlack ) return BLACK_COLOR;
    if ( color == CellTextColorRed )   return RED_COLOR;
    if ( color == CellTextColorBlue )  return BLUE_COLOR;
    if ( color == CellTextColorGreen ) return GREEN_COLOR;
    if ( color == CellTextColorGold )  return GOLD_COLOR;
    
    return BLACK_COLOR;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルの高さを設定
    _currentTweet = [_timelineArray objectAtIndex:indexPath.row];
    
    if ( [_currentTweet objectForKey:@"FavEvent"] != nil ) {
        
        return [self heightForContents:[NSString stringWithFormat:@"【%@がお気に入りに追加】\n%@",
                                        [_currentTweet objectForKey:@"addUser"],
                                        [_currentTweet objectForKey:@"text"]]] + 25;
    }
    
    return [self heightForContents:[_currentTweet objectForKey:@"text"]] + 25;
}

- (CGFloat)heightForContents:(NSString *)contents {
    
    //標準フォント12.0pxで横264pxの範囲に表示した際の縦幅
	CGSize labelSize = [contents sizeWithFont:[UIFont systemFontOfSize:12.0]
                            constrainedToSize:CGSizeMake(264, 20000)
                                lineBreakMode:NSLineBreakByCharWrapping];
	
    CGFloat height = labelSize.height;
    
    //アイコン表示があるため、最低31px必要
    if ( height < 31 ) height = 31;
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"didSelectRowAtIndexPath");
    
    //セルの選択状態を解除
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( !webBrowserMode ) {
        
        //ピッカー表示中は何もしない
        if ( pickerVisible ) return;
        
        selectRow = indexPath.row;
        _selectTweet = [_timelineArray objectAtIndex:indexPath.row];
        
        if ( [_selectTweet objectForKey:@"FavEvent"] == nil ) {
            
            UIActionSheet *sheet = [[UIActionSheet alloc]
                                    initWithTitle:@"機能選択"
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:@"URLを開く", @"Reply", @"Favorite／UnFavorite", @"ReTweet",
                                    @"Fav+RT", @"IDとFav,RTを選択", @"ハッシュタグをNG", @"クライアントをNG", @"InReplyTo", @"Tweetをコピー",
                                    @"Tweetを削除", @"Tweetを編集", @"ユーザーメニュー", nil];
            
            sheet.tag = 0;
            
            [sheet showInView:_appDelegate.tabBarController.self.view];
            
        }else {
            
            NSString *targetId = [_selectTweet objectForKey:@"id_str"];
            NSString *favStarUrl = [NSString stringWithFormat:@"http://ja.favstar.fm/users/%@/status/%@",[TWAccounts currentAccountName], targetId];
            
            _appDelegate.startupUrlList = [NSArray arrayWithObject:favStarUrl];
            
            [self openBrowser];
        }
    }
}

//- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
//
//}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//
//}

- (void)scrollTimelineForNewTweet {
    
    //Tweetがない場合はスクロールしない
    if ( _timelineArray == nil ||
         _timelineArray.count == 0 ) return;
    
    //スクロールするIDがない場合は終了
    if ( ![EmptyCheck check:[TWTweets currentSinceID]] ) return;
    
    //スクロールするインデックスを検索
    int index = 0;
    BOOL find = NO;
    for ( NSDictionary *tweet in [TWTweets currentTimeline] ) {
        
        if ( [tweet objectForKey:@"id_str"] != nil &&
            [[tweet objectForKey:@"id_str"] isEqualToString:[TWTweets currentSinceID]] ) {
            
            find = YES;
            break;
        }
        
        index++;
    }
    
    if ( find ) {
        
        if ( _timelineArray.count < index ||
            [_timelineArray objectAtIndex:index] == nil ) return;
        
        //スクロールする
        [_timeline scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
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

- (void)pushIcon:(TitleButton *)sender {
    
//    NSLog(@"pushIcon: %d", sender.tag);
    
    _alertSearchUserName = sender.buttonTitle;
    _selectAccount = _alertSearchUserName;
    
//    NSLog(@"_alertSearchUserName: %@", _alertSearchUserName);
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"外部サービスやユーザー情報を開く"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Twilog", @"TwilogSearch", @"favstar", @"Twitpic", @"UserTimeline", @"TwitterSearch", @"TwitterSearch(Stream)", nil];
    
    sheet.tag = 1;
    
    [sheet showInView:_appDelegate.tabBarController.self.view];
}

- (void)openTimelineURL:(NSNotification *)notification {
    
    NSString *urlString = [notification.userInfo objectForKey:@"URL"];
    
    if ( urlString == nil )return;
    
    _appDelegate.startupUrlList = @[urlString];
    [self openBrowser];
}

- (void)openTimelineImage:(NSNotification *)notification {
    
    NSString *urlString = [notification.userInfo objectForKey:@"URL"];
    
    if ( urlString == nil )return;
    
    [_imageWindow loadImage:urlString viewRect:_timeline.frame];
}

- (void)receiveGrayViewDoneNotification:(NSNotification *)notification {
    
    NSLog(@"receiveGrayViewDoneNotification");
}

#pragma mark - ASIHTTPRequest

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    @autoreleasepool {
        dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
        dispatch_async( globalQueue, ^{
            dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
            dispatch_sync( syncQueue, ^{
                
                NSString __autoreleasing *screenName = [request.userInfo objectForKey:@"screen_name"];
                NSString __autoreleasing *searchName = [request.userInfo objectForKey:@"SearchName"];
                UIImage __autoreleasing *receiveImage = [UIImage imageWithData:request.responseData];
                
                if  ( receiveImage != nil ) {
                    
                    [_icons setObject:receiveImage forKey:searchName];
                    
                    if ( ![_appDelegate iconExist:searchName] ) {
                        
                        [request.responseData writeToFile:FILE_PATH atomically:YES];
                    }
                    
                    if ( _timelineArray.count != 0 ) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            NSArray __autoreleasing *tempTimelineArray = [NSArray arrayWithArray:_timelineArray];
                            int index = 0;
                            
                            for ( NSDictionary *tweet in tempTimelineArray ) {
                                
                                if ( [[[tweet objectForKey:@"user"] objectForKey:@"screen_name"] isEqualToString:screenName] ) {
                                    
                                    //TL更新
                                    [self refreshTimelineCell:[NSNumber numberWithInt:index]];
                                }
                                
                                //自分のアイコンの場合はツールバーにも設定
                                if ( [screenName isEqualToString:[TWAccounts currentAccountName]] ) {
                                    
                                    //アカウントアイコンを設定
                                    _accountIconView.image = [UIImage imageWithContentsOfFile:FILE_PATH];
                                }
                                
                                index++;
                            }
                        });
                    }
                
                }else {
                    
                    NSLog(@"receiveImage nil");
                }
                
                [self getIconWithSequential];
                
            });
            
            dispatch_release(syncQueue);
        });
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    NSLog(@"requestFailed: %@", request.responseString);
    
    [ActivityIndicator off];
    
    if ( [InternetConnection enable] ) {
        
        //再送信
        NSURL *URL = [NSURL URLWithString:[request.userInfo objectForKey:@"profile_image_url"]];
        ASIHTTPRequest *reSendRequest = [[ASIHTTPRequest alloc] initWithURL:URL];
        reSendRequest.userInfo = request.userInfo;
        [reSendRequest setDelegate:self];
        [reSendRequest start];
    }
}

#pragma mark - IBAction

- (IBAction)pushPostButton:(UIBarButtonItem *)sender {
    
    //ピッカー表示中の場合は隠す
    if ( pickerVisible ) [self hidePicker];
    
    _appDelegate.tabChangeFunction = @"Post";
    self.tabBarController.selectedIndex = 0;
}

- (IBAction)pushReloadButton:(UIBarButtonItem *)sender {
    
    NSLog(@"pushReloadButton");
    
    //ピッカー表示中の場合は隠す
    if ( pickerVisible ) [self hidePicker];
    
    //インターネット接続を確認
    if ( ![InternetConnection enable] ) return;
    
    //自分のアイコンを取得
    [self getMyAccountIcon];
    
    _reloadButton.enabled = NO;
    
    if ( _timelineSegment.selectedSegmentIndex == 0 ) {
        
        //タイムラインのセグメントが選択されている場合
        
        //アクティブアカウントのタイムラインを反映
        _timelineArray = [TWTweets currentTimeline];
        [_timeline reloadData];
        
        //リロード
        [self performSelectorInBackground:@selector(createTimeline) withObject:nil];
//      [self createTimeline];
        
    }else if ( _timelineSegment.selectedSegmentIndex == 1 ) {
        
        //Mentionsを取得
        [TWGetTimeline performSelectorInBackground:@selector(mentions) withObject:nil];
//      [TWGetTimeline mentions];
        
    }else if ( _timelineSegment.selectedSegmentIndex == 2 ) {
        
        //Favoritesを取得
        [TWGetTimeline performSelectorInBackground:@selector(favotites) withObject:nil];
//      [TWGetTimeline favotites];
        
    }else if ( _timelineSegment.selectedSegmentIndex == 3 ) {
        
        if ( [EmptyCheck check:_appDelegate.listAll] ) {
            
            [self finishLoad];
            return;
        }
        
        //リストを再読み込み
        [TWList getList:_appDelegate.listId];
    }
}

- (IBAction)pushTimelineControlButton:(UIBarButtonItem *)sender {
    
    if ( listMode ) {
        
        //ピッカー表示中の場合は隠す
        if ( pickerVisible ) [self hidePicker];
        
        //Listモード中はList再選択を行う
        [self showListSelectView];
        
    }else if ( !userStream && [InternetConnection enable] ) {
        
        //UserStream未接続かつインターネットに接続されている場合は接続する
        userStream = YES;
        _timelineControlButton.enabled = NO;
        userStreamFirstResponse = NO;
        [self performSelectorInBackground:@selector(openStream) withObject:nil];
        
    }else {
        
        //UserStream接続済み
        [self closeStream];
    }
}

- (IBAction)pushActionButton:(UIBarButtonItem *)sender {
    
    //ピッカー表示中の場合は隠す
    if ( pickerVisible ) [self hidePicker];
    
    if ( sender != nil ) {
        
        _alertSearchUserName = [TWAccounts currentAccountName];
        alertSearchType = YES;
        
    }else {
        
        alertSearchType = NO;
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"外部サービスやユーザー情報を開く"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Twilog", @"TwilogSearch", @"favstar", @"Twitpic", @"UserTimeline", @"TwitterSearch", @"TwitterSearch(Stream)", nil];
    
    sheet.tag = 1;
    
    [sheet showInView:_appDelegate.tabBarController.self.view];
}

- (IBAction)pushCloseOtherTweetsButton:(UIBarButtonItem *)sender {
    
    //ピッカー表示中の場合は隠す
    if ( pickerVisible ) [self hidePicker];
    
    if ( searchStream ) {
        
        [self closeSearchStream];
        [self performSelector:@selector(changeSegment:) withObject:nil afterDelay:0.1];
        return;
    }
    
    listMode = NO;
    otherTweetsMode = NO;
    [self setTimelineBarItems];
    
    [self performSelector:@selector(changeSegment:) withObject:nil afterDelay:0.1];
}

#pragma mark - UserStream

- (void)openStream {
    
    @autoreleasepool {
        
        NSLog(@"openStream");
        
        if ( [_d boolForKey:@"USNoAutoLock"] ) [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        //UserStream接続リクエストの作成
        TWRequest __autoreleasing *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://userstream.twitter.com/2/user.json"]
                                                                 parameters:nil
                                                              requestMethod:TWRequestMethodPOST];
        
        //アカウントの設定
        [request setAccount:[TWAccounts currentAccount]];
        
        //接続開始
        self.connection = [NSURLConnection connectionWithRequest:request.signedURLRequest delegate:self];
        [self.connection start];
        
        // 終わるまでループさせる
        while ( userStream ) {
            
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
    }
}

- (void)closeStream {
    
    NSLog(@"closeStream");
    
    if ( [_d boolForKey:@"USNoAutoLock"] ) [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    userStream = NO;
    userStreamFirstResponse = NO;
    _timelineControlButton.enabled = YES;
    _timelineControlButton.image = _startImage;
    
    if ( self.connection != nil ) {
        
        [self.connection cancel];
        [self.connection setDelegateQueue:nil];
        self.connection = nil;
    }
}

- (void)userStreamDelete:(NSDictionary *)receiveData {
    
    if ( _timelineArray.count == 0 ) return;
    
    //削除イベント
    NSString *deleteTweetId = [[[receiveData objectForKey:@"delete"] objectForKey:@"status"] objectForKey:@"id_str"];
    
    //削除されたTweetを検索
    int index = 0;
    BOOL find = NO;
    for ( NSDictionary *tweet in _timelineArray ) {
        
        if ( [[tweet objectForKey:@"id_str"] isEqualToString:deleteTweetId] ) {
            
            find = YES;
            
            break;
        }
        
        index++;
    }
    
    if ( find ) {
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            //見つかった物を削除
            [_timelineArray removeObjectAtIndex:index];
            
            //タイムラインを保存
            [TWTweets saveCurrentTimeline:_timelineArray];
            
            [_timeline deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        });
    }
}

- (void)userStreamMyAddFavEvent:(NSDictionary *)receiveData {
    
    //自分のふぁぼりイベント
    NSString *favedTweetId = [[receiveData objectForKey:@"target_object"] objectForKey:@"id_str"];
    
    int index = 0;
    for ( NSDictionary *tweet in _timelineArray ) {
        
        if ( [[tweet objectForKey:@"id_str"] isEqualToString:favedTweetId] ) {
            
            NSMutableDictionary *favedTweet = [NSMutableDictionary dictionaryWithDictionary:tweet];
            [favedTweet setObject:@"1" forKey:@"favorited"];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                [_timelineArray replaceObjectAtIndex:index withObject:favedTweet];
                
                //タイムラインを保存
                [TWTweets saveCurrentTimeline:_timelineArray];
                
                //TL更新
                [_timeline reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            });
            
            break;
        }
        
        index++;
    }
}

- (void)userStreamMyRemoveFavEvent:(NSDictionary *)receiveData {
    
    //自分のふぁぼり外しイベント
    NSString *favedTweetId = [[receiveData objectForKey:@"target_object"] objectForKey:@"id_str"];
    
    int index = 0;
    for ( NSDictionary *tweet in _timelineArray ) {
        
        if ( [[tweet objectForKey:@"id_str"] isEqualToString:favedTweetId] ) {
            
            NSMutableDictionary *favedTweet = [NSMutableDictionary dictionaryWithDictionary:tweet];
            [favedTweet setObject:@"0" forKey:@"favorited"];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                [_timelineArray replaceObjectAtIndex:index withObject:favedTweet];
                
                //タイムラインを保存
                [TWTweets saveCurrentTimeline:_timelineArray];
                
                //TL更新
                [_timeline reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
            });
            
            break;
        }
        
        index++;
    }
}

- (void)userStreamReceiveFavEvent:(NSDictionary *)receiveData {
    
    NSMutableDictionary *favDic = BLANK_M_DIC;
    //user
    NSMutableDictionary *user = BLANK_M_DIC;
    
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
    
    NSString *infoText = [receiveData objectForKey:@"info_text"];
    
    NSString *searchName = [receiveData objectForKey:@"search_name"];
    
    if ( favUser == nil || favUserIcon == nil || favTime == nil || favClient == nil ||
        targetText == nil || targetId == nil || addUser == nil || infoText == nil || searchName == nil ) return;
    
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
    [favDic setObject:infoText forKey:@"info_text"];
    [favDic setObject:searchName forKey:@"search_name"];
    
    //NSLog(@"favDic: %@", favDic);
    
    if ( [_icons objectForKey:favUser] == nil ) {
        
        NSMutableDictionary *tempDic = BLANK_M_DIC;
        [tempDic setObject:[[favDic objectForKey:@"user"] objectForKey:@"screen_name"] forKey:@"screen_name"];
        [tempDic setObject:[TWIconBigger normal:[[favDic objectForKey:@"user"] objectForKey:@"profile_image_url"]] forKey:@"profile_image_url"];
        
        //アイコン取得
        [self getIconWithTweetArray:[NSMutableArray arrayWithObject:tempDic]];
        
        [tempDic removeAllObjects];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        //タイムラインに追加
        [_timelineArray insertObject:favDic atIndex:0];
        
        //タイムラインを保存
        [TWTweets saveCurrentTimeline:_timelineArray];
        
        //タイムラインを更新
        [_timeline insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    });
}

- (void)userStreamReceiveTweet:(NSDictionary *)receiveData newTweet:(NSArray *)newTweet {
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        [self checkTimelineCount];
        
        //タイムラインに追加
        [_timelineArray insertObject:receiveData atIndex:0];
        
        //タイムラインを保存
        [TWTweets saveCurrentTimeline:_timelineArray];
        
        [_timeline insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
    });
    
    //IDを記憶
    if ( [receiveData objectForKey:@"id_str"] != nil ) {
        
        [TWTweets saveSinceID:[receiveData objectForKey:@"id_str"]];
        
        //アイコン保存
        [self getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
    }
}

#pragma mark - SearchStream

- (void)openSearchStream:(NSString *)searchWord {
    
    @autoreleasepool {
        
        NSLog(@"openSearchStream: %@", searchWord);
        
        if ( [_d boolForKey:@"USNoAutoLock"] ) [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
        [self setOtherTweetsBarItems];
        
        //リクエストパラメータを作成
        NSMutableDictionary __autoreleasing *params = [[NSMutableDictionary alloc] init];
        
        if ( searchWord == nil ) {
            
            return;
        }
        
        [params setObject:searchWord forKey:@"track"];
        
        //UserStream接続リクエストの作成
        TWRequest __autoreleasing *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://stream.twitter.com/1.1/statuses/filter.json"]
                                                 parameters:params
                                              requestMethod:TWRequestMethodPOST];
        
        //アカウントの設定
        [request setAccount:[TWAccounts currentAccount]];
        
        //接続開始
        self.connection = [NSURLConnection connectionWithRequest:request.signedURLRequest delegate:self];
        [self.connection start];
        
        [params removeAllObjects];
        
        [_searchStreamTemp removeAllObjects];
        [self startSearchStreamTimer];
        
        // 終わるまでループさせる
        while ( searchStream ) {
            
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        }
    }
}

- (void)closeSearchStream {
    
    NSLog(@"closeSearchStream");
    
    if ( [_d boolForKey:@"USNoAutoLock"] ) [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    searchStream = NO;
    userStreamFirstResponse = NO;
    _timelineControlButton.enabled = YES;
    _timelineControlButton.image = _startImage;
    
    [self stopSearchStreamTimer];
    
    if ( self.connection != nil ) {
        
        [self.connection cancel];
        [self.connection setDelegateQueue:nil];
        self.connection = nil;
    }
    
    [self setTimelineBarItems];
    
    [_timelineArray removeAllObjects];
    _timelineArray = [TWTweets currentTimeline];
    [_timeline reloadData];
}

- (void)searchStreamReceiveTweet:(NSDictionary *)receiveData {
    
    //NSLog(@"SearchStream: %@", receiveData);
    
    @try {
        
        //重複する場合は無視
        if ( _timelineArray.count != 0 ) {
            
            if ( [[receiveData objectForKey:@"id_str"] isEqualToString:[[_timelineArray objectAtIndex:0] objectForKey:@"id_str"]] ) return;
        }
        
        [_searchStreamTemp addObject:receiveData];
        
    }@catch ( NSException *e ) {}
}

- (void)startSearchStreamTimer {
    
    NSLog(@"startSearchStreamTimer InterVal: %.3f", _appDelegate.reloadInterval);
    
    _searchStreamTemp = [NSMutableArray array];
    _searchStreamTimer = [NSTimer scheduledTimerWithTimeInterval:_appDelegate.reloadInterval
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
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        if ( _searchStreamTemp.count != 0 ) {
            
            NSDictionary *newTweet = [_searchStreamTemp objectAtIndex:0];
            [_searchStreamTemp removeObjectAtIndex:0];
            
            if ( newTweet != nil ) {
                
                [self checkTimelineCount];
                
                //タイムラインに追加
                [_timelineArray insertObject:newTweet atIndex:0];
                [_timeline insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                
                //アイコン保存
                [self getIconWithTweetArray:[NSMutableArray arrayWithArray:@[newTweet]]];
            }
        }
    });
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    @autoreleasepool {
        @try {
            
            NSError *error = nil;
            NSMutableDictionary __autoreleasing *receiveData = [NSMutableDictionary dictionaryWithDictionary:
                                                                [NSJSONSerialization JSONObjectWithData:data
                                                                                                options:NSJSONReadingMutableLeaves
                                                                                                  error:&error]];
            
            //          NSLog(@"receiveData[%d]: %@", receiveData.count, receiveData);
            //          NSLog(@"receiveDataCount: %d", receiveData.count);
            //          NSLog(@"event: %@", [receiveData objectForKey:@"event"]);
            
            //エラーは無視
            if ( error ) return;
            
            if ( !userStreamFirstResponse ) {
                
                //接続初回のレスポンスは無視
                userStreamFirstResponse = YES;
                
                return;
            }
            
            //定期的に送られてくる空データは無視
            if ( receiveData.count == 0 ) return;
            
            //接続初回のようなデータは無視
            if ( receiveData.count == 1 && [receiveData objectForKey:@"friends"] != nil ) return;
            
            if ( searchStream ) {
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    //SearchStreamの場合
                    [self searchStreamReceiveTweet:[[TWEntities replaceTcoAll:@[receiveData]] objectAtIndex:0]];
                });
                
                return;
            }
            
            if ( receiveData.count == 1 && [receiveData objectForKey:@"delete"] != nil ) {
                
                NSLog(@"UserStream Delete Event");
                
                //削除イベント
                [self userStreamDelete:receiveData];
                
                return;
            }
            
            //更新アカウントを記憶
            NSString __autoreleasing *myAccountName = [TWAccounts currentAccountName];
            _lastUpdateAccount = myAccountName;
            
            NSArray __autoreleasing *newTweet = [NSArray arrayWithObject:receiveData];
            
            if ( [receiveData objectForKey:@"event"] == nil &&
                [receiveData objectForKey:@"delete"] == nil ) {
                
                //NG判定を行う
                newTweet = [TWNgTweet ngAll:newTweet];
                
                //新着が無いので終了
                if ( newTweet.count == 0 ) return;
            }
            
            if ( [receiveData objectForKey:@"id_str"] != nil &&
                [[_timelineArray objectAtIndex:0] objectForKey:@"id_str"] != nil ) {
                
                //重複する場合は無視
                if ( [[receiveData objectForKey:@"id_str"] isEqualToString:[[_timelineArray objectAtIndex:0] objectForKey:@"id_str"]] ) return;
            }
            
            //t.coを展開
            newTweet = [TWEntities replaceTcoAll:newTweet];
            
            //          NSLog(@"newTweet: %@", newTweet);
            
            receiveData = [newTweet objectAtIndex:0];
            
            if ( receiveData.count != 1 && [receiveData objectForKey:@"delete"] == nil ) {
                
                if ( [[receiveData objectForKey:@"event"] isEqualToString:@"favorite"] &&
                    [[[receiveData objectForKey:@"source"] objectForKey:@"screen_name"] isEqualToString:myAccountName] ) {
                    
                    NSLog(@"UserStream Add Fav Event");
                    
                    //自分のふぁぼりイベント
                    [self userStreamMyAddFavEvent:receiveData];
                    
                    return;
                    
                }else if ( [[receiveData objectForKey:@"event"] isEqualToString:@"unfavorite"] &&
                          [[[receiveData objectForKey:@"source"] objectForKey:@"screen_name"] isEqualToString:myAccountName] ) {
                    
                    if ( _timelineArray.count == 0 ) return;
                    
                    NSLog(@"UserStream Remove Fav Event");
                    
                    //自分のふぁぼ外しイベント
                    [self userStreamMyRemoveFavEvent:receiveData];
                    
                    return;
                    
                }else if ( [[receiveData objectForKey:@"event"] isEqualToString:@"favorite"] ) {
                    
                    NSLog(@"UserStream Receive Fav Event");
                    
                    //ふぁぼられイベント
                    [self userStreamReceiveFavEvent:receiveData];
                    
                    return;
                    
                }else if ( [receiveData objectForKey:@"event"] != nil ) {
                    
                    //その他
                    return;
                }
                
                //以下通常Post向け処理
                [self userStreamReceiveTweet:receiveData newTweet:newTweet];
            }
            
        }@catch ( NSException *e ) { /* 例外は投げ捨てる物 */ }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSLog(@"didReceiveResponse:%d, %lld", httpResponse.statusCode, response.expectedContentLength);
    
    if ( httpResponse.statusCode == 200 ) {
        
        userStream = YES;
        _timelineControlButton.image = _stopImage;
        
    }else {
        
        [self closeStream];
        if ( searchStream ) [self closeSearchStream];
    }
    
    _timelineControlButton.enabled = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"connectionDidFinishLoading");
    
    [self closeStream];
    if ( searchStream ) [self closeSearchStream];
    [self pushReloadButton:nil];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"didFailWithError: %@", error);
    NSLog(@"TimelineCount: %d", _timelineArray.count);
    
    [self closeStream];
    [self closeSearchStream];
    [self pushReloadButton:nil];
}

#pragma mark - GestureRecognizer

- (IBAction)swipeTimelineRight:(UISwipeGestureRecognizer *)sender {
    
    NSLog(@"swipeTimelineRight");
    
    //ピッカー表示中の場合は隠す
    if ( pickerVisible ) [self hidePicker];
    
    if ( _timelineSegment.selectedSegmentIndex == 3 ) {
        
        [self showListSelectView];
        
    }else {
     
        //InReplyTto表示中は何もしない
        if ( otherTweetsMode ) return;
        
        int num = [_d integerForKey:@"UseAccount"] - 1;
        
        if ( num < 0 ) return;
        
        int accountCount = [TWAccounts accountCount] - 1;
        
        if ( accountCount >= num ) {
            
            if ( userStream ) [self closeStream];
            
            _appDelegate.listAll = BLANK_ARRAY;
            _appDelegate.listId = BLANK;
            
            [_d setInteger:num forKey:@"UseAccount"];
            
            [self performSelector:@selector(changeSegment:) withObject:nil afterDelay:0.1];
        }
    }
}

- (IBAction)swipeTimelineLeft:(UISwipeGestureRecognizer *)sender {
    
    NSLog(@"swipeTimelineLeft");
    
    //ピッカー表示中の場合は隠す
    if ( pickerVisible ) [self hidePicker];
    
    if ( _timelineSegment.selectedSegmentIndex == 3 ) return;
    
    //InReplyTto表示中は何もしない
    if ( otherTweetsMode ) return;
    
    int num = [_d integerForKey:@"UseAccount"] + 1;
    int accountCount = [TWAccounts accountCount] - 1;
    
    if ( accountCount >= num ) {
        
        if ( userStream ) [self closeStream];
        
        _appDelegate.listAll = BLANK_ARRAY;
        _appDelegate.listId = BLANK;
        
        [_d setInteger:num forKey:@"UseAccount"];
        
        [self performSelector:@selector(changeSegment:) withObject:nil afterDelay:0.1];
    }
}

- (IBAction)longPressTimeline:(UILongPressGestureRecognizer *)sender {
    
    //ピッカー表示中の場合は隠す
    if ( pickerVisible ) [self hidePicker];
    
    if ( longPressControl == 0 ) {
        
        longPressControl = 1;
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"ログ削除"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"現在のアカウントのTimelineログを削除", @"全てのTimelineログを削除",
                                @"全てのログとアイコンキャッシュを削除", @"タイムラインにNG情報を再適用", nil];
        
        sheet.tag = 2;
        
        [sheet showInView:_appDelegate.tabBarController.self.view];
    }
}

#pragma mark - SegmentControl

- (IBAction)changeSegment:(UISegmentedControl *)sender {
    
    NSLog(@"changeSegment[%d]", _timelineSegment.selectedSegmentIndex);
    
    //ピッカー表示中の場合は隠す
    if ( pickerVisible ) [self hidePicker];
    
    if ( searchStream ) [self closeSearchStream];
    
    //InReplyTo表示中なら閉じる
    if ( otherTweetsMode ) {
        
        [self pushCloseOtherTweetsButton:nil];
        
    }else {
        
        //インターネット接続を確認
        if ( ![InternetConnection enable] ) return;
        
        if ( _timelineSegment.selectedSegmentIndex == 0 ) {
            
            //Timelineに切り替わった
            _timelineArray = [TWTweets currentTimeline];
            [_timeline reloadData];
            
            listMode = NO;
            _timelineControlButton.image = _startImage;
            _timelineControlButton.enabled = YES;
            
            _mentionsArray = BLANK_ARRAY;
            
            [self pushReloadButton:nil];
            
        }else if ( _timelineSegment.selectedSegmentIndex == 1 ) {
            
            listMode = NO;
            _timelineControlButton.image = _startImage;
            
            //Mentionsに切り替わった
            [TWGetTimeline performSelectorInBackground:@selector(mentions) withObject:nil];
            
        }else if ( _timelineSegment.selectedSegmentIndex == 2 ) {
            
            listMode = NO;
            _timelineControlButton.image = _startImage;
            
            //Favoritesに切り替わった
            [TWGetTimeline performSelectorInBackground:@selector(favotites) withObject:nil];
            
        }else if ( _timelineSegment.selectedSegmentIndex == 3 ) {
            
            //リスト選択画面を表示
            [self timelineDidListChanged];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        if ( _timelineSegment.selectedSegmentIndex != 0 &&
             _timelineSegment.selectedSegmentIndex != 3 ) {
            
            [_grayView start];
        }
    });
}

#pragma mark - ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    dispatch_async( globalQueue, ^{
        dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
        dispatch_sync( syncQueue, ^{
            
            NSString *tweetId = [_selectTweet objectForKey:@"id_str"];
            NSString *screenName = [[_selectTweet objectForKey:@"user"] objectForKey:@"screen_name"];
            NSString *text = [_selectTweet objectForKey:@"text"];
            
            if ( actionSheet.tag == 0 ) {
                
                //NSLog(@"_selectTweet: %@", _selectTweet);
                
                if ( buttonIndex == 0 ) {
                    
                    _appDelegate.startupUrlList = [RegularExpression urls:text];
                    
                    NSLog(@"startupUrlList[%d]: %@", _appDelegate.startupUrlList.count, _appDelegate.startupUrlList);
                    
                    if ( _appDelegate.startupUrlList.count == 0 || _appDelegate.startupUrlList == nil ) {
                        
                        //開くべきURLがない
                        
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            
                            [ShowAlert error:@"URLがありません。"];
                        });
                        
                    }else {
                        
                        _appDelegate.reOpenUrl = BLANK;
                        
                        //開くべきURLがある場合ブラウザを開く
                        [self openBrowser];
                    }
                    
                }else if ( buttonIndex == 1 ) {
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        if ( otherTweetsMode ) [self pushCloseOtherTweetsButton:nil];
                        
                        [_appDelegate.postData removeAllObjects];
                        
                        NSString *inReplyToId = [_selectTweet objectForKey:@"id_str"];
                        
                        if ( screenName == nil || inReplyToId == nil ) return;
                        
                        [_appDelegate.postData setObject:screenName forKey:@"ScreenName"];
                        [_appDelegate.postData setObject:inReplyToId forKey:@"InReplyToId"];
                        
                        _appDelegate.tabChangeFunction = @"Reply";
                        self.tabBarController.selectedIndex = 0;
                    });
                    
                }else if ( buttonIndex == 2 ) {
                    
                    BOOL favorited = [[_selectTweet objectForKey:@"favorited"] boolValue];
                    
                    if ( favorited ) {
                        
                        [TWEvent unFavorite:tweetId accountIndex:[_d integerForKey:@"UseAccount"]];
                        
                    }else {
                        
                        [TWEvent favorite:tweetId accountIndex:[_d integerForKey:@"UseAccount"]];
                    }
                    
                }else if ( buttonIndex == 3 ) {
                    
                    [TWEvent reTweet:tweetId accountIndex:[_d integerForKey:@"UseAccount"]];
                    
                }else if ( buttonIndex == 4 ) {
                    
                    [TWEvent favoriteReTweet:tweetId accountIndex:[_d integerForKey:@"UseAccount"]];
                    
                }else if ( buttonIndex == 5) {
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        [self performSelector:@selector(showPickerView) withObject:nil afterDelay:0.1];
                    });
                    
                }else if ( buttonIndex == 6 ) {
                    
                    NSString *hashTag = [RegularExpression strWithRegExp:[_selectTweet objectForKey:@"text"] regExpPattern:@"((?:\\A|\\z|[\x0009-\x000D\x0020\xC2\x85\u00A0\u1680\u180E\u2000-\u200A\u2028\u2029\u202F\u205F\u3000]|[\\[\\]［］()（）{}｛｝‘’“”\"\'｟｠⸨⸩「」｢｣『』〚〛⟦⟧〔〕❲❳〘〙⟬⟭〈〉〈〉⟨⟩《》⟪⟫<>＜＞«»‹›【】〖〗]|。|、|\\.|!))(#|＃)([a-z0-9_\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\u0400-\u04FF\u0500-\u0527\u1100-\u11FF\u3130-\u3185\uA960-\uA97F\uAC00-\uD7AF\uD7B0-\uD7FF\u30A1-\u30FA\uFF66-\uFF9D\uFF10-\uFF19\uFF21-\uFF3A\uFF41-\uFF5A\u3041-\u3096\u3400-\u4DBF\u4E00-\u9FFF\u020000-\u02A6DF\u02A700-\u02B73F\u02B740-\u02B81F\u02F800-\u02FA1F\u30FC\u3005]*[a-z_\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\u0400-\u04FF\u0500-\u0527\u1100-\u11FF\u3130-\u3185\uA960-\uA97F\uAC00-\uD7AF\uD7B0-\uD7FF\u30A1-\u30FA\uFF66-\uFF9D\uFF10-\uFF19\uFF21-\uFF3A\uFF41-\uFF5A\u3041-\u3096\u3400-\u4DBF\u4E00-\u9FFF\u020000-\u02A6DF\u02A700-\u02B73F\u02B740-\u02B81F\u02F800-\u02FA1F\u30FC\u3005][a-z0-9_\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\u0400-\u04FF\u0500-\u0527\u1100-\u11FF\u3130-\u3185\uA960-\uA97F\uAC00-\uD7AF\uD7B0-\uD7FF\u30A1-\u30FA\uFF66-\uFF9D\uFF10-\uFF19\uFF21-\uFF3A\uFF41-\uFF5A\u3041-\u3096\u3400-\u4DBF\u4E00-\u9FFF\u020000-\u02A6DF\u02A700-\u02B73F\u02B740-\u02B81F\u02F800-\u02FA1F\u30FC\u3005]*)(?=(?:\\A|\\z|[\x0009-\x000D\x0020\xC2\x85\u00A0\u1680\u180E\u2000-\u200A\u2028\u2029\u202F\u205F\u3000]|[\\[\\]［］()（）{}｛｝‘’“”\"\'｟｠⸨⸩「」｢｣『』〚〛⟦⟧〔〕❲❳〘〙⟬⟭〈〉〈〉⟨⟩《》⟪⟫<>＜＞«»‹›【】〖〗]|。|、|\\.|!))"];
                    
                    if ( [EmptyCheck string:hashTag] ) {
                        
                        NSMutableDictionary *addDic = BLANK_M_DIC;
                        
                        //NGワード設定を読み込む
                        NSMutableArray *ngWordArray = [NSMutableArray arrayWithArray:[_d objectForKey:@"NGWord"]];
                        
                        //NGワードに追加
                        [addDic setObject:[DeleteWhiteSpace string:hashTag] forKey:@"Word"];
                        [ngWordArray addObject:addDic];
                        
                        //設定に反映
                        [_d setObject:ngWordArray forKey:@"NGWord"];
                        
                        //タイムラインにNGワードを適用
                        _timelineArray = [NSMutableArray arrayWithArray:[TWNgTweet ngWord:[NSArray arrayWithArray:_timelineArray]]];
                        
                        //タイムラインを保存
                        [TWTweets saveCurrentTimeline:_timelineArray];
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            //リロード
                            [_timeline reloadData];
                        });
                        
                    }else {
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            [ShowAlert error:@"ハッシュタグが見つかりませんでした。"];
                        });
                    }
                    
                }else if ( buttonIndex == 7 ) {
                    
                    NSMutableDictionary *addDic = BLANK_M_DIC;
                    
                    NSString *clientName = [TWParser client:[_selectTweet objectForKey:@"source"]];
                    
                    //NGクライアント設定を読み込む
                    NSMutableArray *ngClientArray = [NSMutableArray arrayWithArray:[_d objectForKey:@"NGClient"]];
                    
                    if ( clientName == nil ) return;
                    
                    //NGクライアント
                    [addDic setObject:clientName forKey:@"Client"];
                    
                    [ngClientArray addObject:addDic];
                    
                    //NSLog(@"ngClientArray: %@", ngClientArray);
                    
                    [_d setObject:ngClientArray forKey:@"NGClient"];
                    
                    //タイムラインにNGワードを適用
                    _timelineArray = [NSMutableArray arrayWithArray:[TWNgTweet ngClient:[NSArray arrayWithArray:_timelineArray]]];
                    
                    //タイムラインを保存
                    [TWTweets saveCurrentTimeline:_timelineArray];
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        //リロード
                        [_timeline reloadData];
                    });
                    
                }else if ( buttonIndex == 8 ) {
                    
                    [_inReplyTo removeAllObjects];
                    
                    NSString *inReplyToId = [_selectTweet objectForKey:@"in_reply_to_status_id_str"];
                    
                    if ( [EmptyCheck check:inReplyToId] ) {
                        
                        NSLog(@"InReplyTo GET START");
                        
                        otherTweetsMode = YES;
                        
                        [_inReplyTo addObject:_selectTweet];
                        [self getInReplyToChain:_selectTweet];
                        
                    }else {
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            [ShowAlert error:@"InReplyToIDがありません。"];
                        });
                    }
                    
                }else if ( buttonIndex == 9 ) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        UIActionSheet *sheet = [[UIActionSheet alloc]
                                                initWithTitle:@"Tweetをコピー"
                                                delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                otherButtonTitles:@"STOT形式", @"本文", @"TweetへのURL", @"Tweet内のURL", nil];
                        
                        sheet.tag = 6;
                        [sheet showInView:_appDelegate.tabBarController.self.view];
                    });
                    
                }else if ( buttonIndex == 10 ) {
                    
                    if ( [[[_selectTweet objectForKey:@"user"] objectForKey:@"screen_name"] isEqualToString:[TWAccounts currentAccountName]] ) {
                        
                        [TWEvent destroy:tweetId];
                        
                    }else {
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            [ShowAlert error:@"自分のTweetではありません。"];
                        });
                    }
                    
                }else if ( buttonIndex == 11 ) {
                    
                    if ( [[[_selectTweet objectForKey:@"user"] objectForKey:@"screen_name"] isEqualToString:[TWAccounts currentAccountName]] ) {
                        
                        [_appDelegate.postData removeAllObjects];
                        
                        NSString *inReplyToId = [_selectTweet objectForKey:@"in_reply_to_status_id_str"];
                        
                        if  ( text == nil || inReplyToId == nil ) return;
                        
                        [_appDelegate.postData setObject:text forKey:@"Text"];
                        [_appDelegate.postData setObject:inReplyToId forKey:@"InReplyToId"];
                        
                        _appDelegate.tabChangeFunction = @"Edit";
                        
                        NSString *tweetId = [_selectTweet objectForKey:@"id_str"];
                        [TWEvent destroy:tweetId];
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            if ( !userStream ) {
                                
                                //削除
                                [_timelineArray removeObjectAtIndex:selectRow];
                                
                                //タイムラインを保存
                                [TWTweets saveCurrentTimeline:_timelineArray];
                                
                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selectRow inSection:0];
                                [_timeline deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                            }
                            
                            self.tabBarController.selectedIndex = 0;
                        });
                        
                    }else {
                        
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            [ShowAlert error:@"自分のTweetではありません。"];
                        });
                    }
                    
                }else if ( buttonIndex == 12 ) {
                    
                    NSMutableArray *ids = [RegularExpression twitterIds:[_selectTweet objectForKey:@"text"]];
                    [ids insertObject:[NSString stringWithFormat:@"@%@", [[_selectTweet objectForKey:@"user"] objectForKey:@"screen_name"]] atIndex:0];
                    
                    _selectTweetIds = ids.deleteDuplicate;
                    
                    if ( ids.count == 0 ) return;
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        [self showTwitterAccountSelectActionSheet:_selectTweetIds];
                    });
                }
                
            }else if ( actionSheet.tag == 1 ) {
                
                [self openTwitterService:_alertSearchUserName serviceType:buttonIndex];
                
            }else if ( actionSheet.tag == 2 ) {
                
                
                longPressControl = 0;
                
                if ( buttonIndex != 3 && buttonIndex != 4 ) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        [_grayView forceEnd];
                        [self closeStream];
                        
                        //タイムラインからログを削除
                        [_timelineArray removeAllObjects];
                        self.timelineArray = nil;
                        _timelineArray = BLANK_M_ARRAY;
                        
                        [_timeline reloadData];
                    });
                    
                    if ( buttonIndex == 0 ) {
                        
                        //SinceIDを削除
                        [[TWTweets sinceIDs] removeAllObjects];
                        
                        for ( ACAccount *account in [TWAccountsBase manager].twitterAccounts ) {
                            
                            [[TWTweets sinceIDs] setObject:@"" forKey:account.username];
                        }
                        
                        //タイムラインを保存
                        [TWTweets saveCurrentTimeline:_timelineArray];
                        
                    }else if ( buttonIndex == 1 || buttonIndex == 2 ) {
                        
                        //各アカウントのログを削除
                        for ( ACAccount *account in [TWAccounts twitterAccounts] ) {
                            
                            [[TWTweets timelines] setObject:[NSMutableArray array] forKey:account.username];
                            [[TWTweets sinceIDs] setObject:@"" forKey:account.username];
                        }
                        
                        _appDelegate.listId = BLANK;
                        _appDelegate.startupUrlList = nil;
                        _appDelegate.startupUrlList = BLANK_ARRAY;
                        _appDelegate.listAll = nil;
                        _appDelegate.listAll = BLANK_ARRAY;
                        
                        //タイムラインログを削除
                        self.mentionsArray = nil;
                        _mentionsArray = BLANK_ARRAY;
                        [_allLists removeAllObjects];
                        self.allLists = nil;
                        _allLists = BLANK_M_DIC;
                        
                        if ( buttonIndex == 2 ) {
                            
                            dispatch_async(dispatch_get_main_queue(), ^ {
                                
                                _accountIconView.image = nil;
                            });
                            
                            [_icons removeAllObjects];
                            self.icons = nil;
                            _icons = BLANK_M_DIC;
                            [_iconUrls removeAllObjects];
                            self.iconUrls = nil;
                            _iconUrls = BLANK_M_ARRAY;
                            [_reqedUser removeAllObjects];
                            self.reqedUser = nil;
                            _reqedUser = BLANK_M_ARRAY;
                            
                            //アイコンファイルを削除
                            [[NSFileManager defaultManager] removeItemAtPath:ICONS_DIRECTORY error:nil];
                            
                            //フォルダを再作成
                            [_fileManager createDirectoryAtPath:ICONS_DIRECTORY
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:nil];
                        }
                        
                    }else if ( buttonIndex == 3 ) {
                        
                        //NG情報を再適用
                        
                        //NG判定を行う
                        dispatch_async(dispatch_get_main_queue(), ^ {
                            
                            _timelineArray = [TWNgTweet ngAll:_timelineArray];
                            [TWTweets saveCurrentTimeline:_timelineArray];
                            [_timeline reloadData];
                        });
                        
                    }else {
                        
                        //キャンセル
                        return;
                    }
                }
                
            }else if ( actionSheet.tag == 3 ) {
                
                if ( buttonIndex == _selectTweetIds.count ) {
                    
                    NSLog(@"buttonIndex == _selectTweetIds.count");
                    
                    _selectAccount = BLANK;
                    self.selectTweetIds = nil;
                    _selectTweetIds = BLANK_ARRAY;
                    return;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    _selectAccount = [_selectTweetIds objectAtIndex:buttonIndex];
                    
                    if ( [_selectAccount hasPrefix:@"@"] ) {
                        
                        //@から始まっている場合取り除く
                        _selectAccount = [_selectAccount substringFromIndex:1];
                    }
                    
                    //前後の空白文字を取り除く
                    _selectAccount = [DeleteWhiteSpace string:_selectAccount];
                    
                    _alertSearchUserName = _selectAccount;
                    
                    UIActionSheet *sheet = [[UIActionSheet alloc]
                                            initWithTitle:_selectAccount
                                            delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                            otherButtonTitles:@"外部サービスやユーザー情報を開く", @"フォロー関連", nil];
                    
                    sheet.tag = 4;
                    [sheet showInView:_appDelegate.tabBarController.self.view];
                });
                
            }else if ( actionSheet.tag == 4 ) {
                
                if ( buttonIndex == 0 ) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        [self pushActionButton:nil];
                    });
                    
                    //後処理
                    _selectAccount = BLANK;
                    self.selectTweetIds = nil;
                    _selectTweetIds = BLANK_ARRAY;
                    
                }else if ( buttonIndex == 1 ) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        if ( [_selectAccount isEqualToString:[TWAccounts currentAccountName]] ) {
                            
                            [ShowAlert error:@"それはあなたです！"];
                            
                        }else {
                            
                            UIActionSheet *sheet = [[UIActionSheet alloc]
                                                    initWithTitle:_selectAccount
                                                    delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    destructiveButtonTitle:@"スパム報告"
                                                    otherButtonTitles:@"ブロック", @"ブロック解除", @"フォロー", @"フォロー解除", nil];
                            
                            sheet.tag = 5;
                            [sheet showInView:_appDelegate.tabBarController.self.view];
                        }
                    });
                }
                
            }else if ( actionSheet.tag == 5 ) {
                
                if ( buttonIndex == 0 ) {
                    
                    //スパム報告
                    [TWFriends reportSpam:_selectAccount];
                    
                }else if ( buttonIndex == 1 ) {
                    
                    //ブロック
                    [TWFriends block:_selectAccount];
                    
                }else if ( buttonIndex == 2 ) {
                    
                    //ブロック解除
                    [TWFriends unblock:_selectAccount];
                    
                }else if ( buttonIndex == 3 ) {
                    
                    //フォロー
                    [TWFriends follow:_selectAccount];
                    
                }else if ( buttonIndex == 4 ) {
                    
                    //フォロー解除
                    [TWFriends unfollow:_selectAccount];
                }
                
            }else if ( actionSheet.tag == 6 ) {
                
                //公式RTであるか
                if ( [[_selectTweet objectForKey:@"retweeted_status"] objectForKey:@"id"] ) {
                    
                    text = [TWEntities openTcoWithReTweet:_selectTweet];
                    screenName = [[[_selectTweet objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"screen_name"];
                    tweetId = [[_selectTweet objectForKey:@"retweeted_status"] objectForKey:@"id_str"];
                }
                
                if ( buttonIndex == 0 ) {
                    
                    //STOT形式
                    NSString *copyText = [NSString stringWithFormat:@"%@: %@ [https://twitter.com/%@/status/%@]", screenName, text, screenName, tweetId];
                    [_pboard setString:copyText];
                    
                }else if ( buttonIndex == 1 ) {
                    
                    //本文
                    [_pboard setString:text];
                    
                }else if ( buttonIndex == 2 ) {
                    
                    //URL
                    [_pboard setString:[NSString stringWithFormat:@"https://twitter.com/%@/status/%@", screenName, tweetId]];
                    
                }else if ( buttonIndex == 3 ) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        //Tweet内のURL
                        _tweetInUrls = [RegularExpression urls:text];
                        [self copyTweetInUrl:_tweetInUrls];
                    });
                }
                
            }else if ( actionSheet.tag >= 7 && actionSheet.tag <= 11 ) {
                
                int cancelIndex = actionSheet.tag - 5;
                
                //キャンセルボタンが押された
                if ( buttonIndex == cancelIndex ) {
                    
                    NSLog(@"Tweet in URL copy cancel");
                    
                    _tweetInUrls = BLANK_ARRAY;
                    
                    return;
                }
                
                NSLog(@"Copy URL: %@", [_tweetInUrls objectAtIndex:buttonIndex]);
                
                [_pboard setString:[_tweetInUrls objectAtIndex:buttonIndex]];
                _tweetInUrls = BLANK_ARRAY;
            }
        });
        
        dispatch_release(syncQueue);
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
        [oneUserSheet showInView:_appDelegate.tabBarController.self.view];
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
        [sheet showInView:_appDelegate.tabBarController.self.view];
        sheet = nil;
    }
}

- (void)openTwitterService:(NSString *)username serviceType:(int)serviceType {
    
    if ( ![EmptyCheck string:username] ) return;
    
    _appDelegate.reOpenUrl = BLANK;
    
    NSString *serviceUrl = nil;
    
    if ( serviceType == 0 ) {
        
        //Twilog
        serviceUrl = [NSString stringWithFormat:@"http://twilog.org/%@", username];
        
    }else if ( serviceType == 1 ) {
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            self.alertSearch = nil;
            _alertSearch = [[UIAlertView alloc] initWithTitle:@"TwilogSearch"
                                                     message:@"\n"
                                                    delegate:self
                                           cancelButtonTitle:@"キャンセル"
                                           otherButtonTitles:@"確定", nil];
            
            _alertSearch.tag = 0;
            
            self.alertSearchText = nil;
            _alertSearchText = [[SSTextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
            [_alertSearchText setBackgroundColor:[UIColor whiteColor]];
            _alertSearchText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _alertSearchText.delegate = self;
            _alertSearchText.text = BLANK;
            _alertSearchText.tag = 0;
            
            [_alertSearch addSubview:_alertSearchText];
            [_alertSearch show];
            [_alertSearchText becomeFirstResponder];
        });
        
        return;
        
    }else if ( serviceType == 2 ) {
        
        //favstar
        serviceUrl = [NSString stringWithFormat:@"http://ja.favstar.fm/users/%@/recent", username];
        
    }else if ( serviceType == 3 ) {
        
        //Twitpic
        serviceUrl = [NSString stringWithFormat:@"http://twitpic.com/photos/%@", username];
        
    }else if ( serviceType == 4 ) {
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            if ( alertSearchType ) {
                
                self.alertSearch = nil;
                _alertSearch = [[UIAlertView alloc] initWithTitle:@"ID入力 (screen_name)"
                                                         message:@"\n"
                                                        delegate:self
                                               cancelButtonTitle:@"キャンセル"
                                               otherButtonTitles:@"確定", nil];
                
                _alertSearch.tag = 1;
                
                self.alertSearchText = nil;
                _alertSearchText = [[SSTextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
                [_alertSearchText setBackgroundColor:[UIColor whiteColor]];
                _alertSearchText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                _alertSearchText.delegate = self;
                _alertSearchText.text = BLANK;
                _alertSearchText.tag = 1;
                
                [_alertSearch addSubview:_alertSearchText];
                [_alertSearch show];
                [_alertSearchText becomeFirstResponder];
                
            }else {
                
                [TWGetTimeline userTimeline:username];
            }
        });
        
        return;
        
    }else if ( serviceType == 5 ) {
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            otherTweetsMode = YES;
            
            if ( alertSearchType ) {
                
                self.alertSearch = nil;
                _alertSearch = [[UIAlertView alloc] initWithTitle:@"Twitter Search"
                                                         message:@"\n"
                                                        delegate:self
                                               cancelButtonTitle:@"キャンセル"
                                               otherButtonTitles:@"確定", nil];
                
                _alertSearch.tag = 2;
                
                self.alertSearchText = nil;
                _alertSearchText = [[SSTextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
                [_alertSearchText setBackgroundColor:[UIColor whiteColor]];
                _alertSearchText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                _alertSearchText.delegate = self;
                _alertSearchText.text = BLANK;
                _alertSearchText.tag = 2;
                
                [_alertSearch addSubview:_alertSearchText];
                [_alertSearch show];
                [_alertSearchText becomeFirstResponder];
                
            }else {
                
                [TWGetTimeline twitterSearch:[CreateSearchURL encodeWord:username
                                                                encoding:kCFStringEncodingUTF8]];
            }
        });
        
        return;
        
    }else if ( serviceType == 6 ) {
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            //UserStreamを切断
            if ( username ) [self closeStream];
            
            if ( _timelineSegment.selectedSegmentIndex == 0 ) {
                
                [TWTweets saveCurrentTimeline:_timelineArray];
            }
            
            [_timelineArray removeAllObjects];
            _timelineArray = BLANK_M_ARRAY;
            [_timeline reloadData];
            
            searchStream =YES;
            
            self.alertSearch = nil;
            _alertSearch = [[UIAlertView alloc] initWithTitle:@"Twitter Search(Stream)"
                                                     message:@"\n"
                                                    delegate:self
                                           cancelButtonTitle:@"キャンセル"
                                           otherButtonTitles:@"確定", nil];
            
            _alertSearch.tag = 3;
            
            self.alertSearchText = nil;
            _alertSearchText = [[SSTextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
            [_alertSearchText setBackgroundColor:[UIColor whiteColor]];
            _alertSearchText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            _alertSearchText.delegate = self;
            _alertSearchText.text = BLANK;
            _alertSearchText.tag = 3;
            
            [_alertSearch addSubview:_alertSearchText];
            [_alertSearch show];
            [_alertSearchText becomeFirstResponder];
        });
        
        return;
        
    }else {
        
        return;
    }
    
    _appDelegate.startupUrlList = [NSArray arrayWithObject:serviceUrl];
    
    [self openBrowser];
}

#pragma mark - UIPickerView

- (void)showPickerView {
    
    //NSLog(@"showPickerView");
    
    //表示フラグ
    pickerVisible = YES;
    _appDelegate.tabBarController.tabBar.userInteractionEnabled = NO;
    
    _pickerBase = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                          SCREEN_HEIGHT,
                                                          SCREEN_WIDTH,
                                                          TOOL_BAR_HEIGHT + PICKER_HEIGHT)];
    _pickerBase.backgroundColor = [UIColor clearColor];
    [_appDelegate.tabBarController.self.view addSubview:_pickerBase];
    
    _pickerBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
                                                            0,
                                                            SCREEN_WIDTH,
                                                            TOOL_BAR_HEIGHT)];
    _pickerBar.tintColor = _topBar.tintColor;
    
    _pickerBarDoneButton = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                           target:self
                           action:@selector(pickerDone)];
    
    _pickerBarCancelButton = [[UIBarButtonItem alloc]
                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                             target:self
                             action:@selector(pickerCancel)];
    
    [_pickerBar setItems:PICKER_BAR_ITEM animated:NO];
    [_pickerBase addSubview:_pickerBar];
    
    _eventPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0,
                                                                 TOOL_BAR_HEIGHT,
                                                                 SCREEN_WIDTH,
                                                                 PICKER_HEIGHT)];
    _eventPicker.delegate = self;
    _eventPicker.dataSource = self;
    _eventPicker.showsSelectionIndicator = YES;
    [_pickerBase addSubview:_eventPicker];
    
    //アカウント初期値
    [_eventPicker selectRow:[_d integerForKey:@"UseAccount"] inComponent:0 animated:NO];
    
    //イベント初期値
    [_eventPicker selectRow:0 inComponent:1 animated:NO];
    
    _pickerBase.alpha = 0;
    _pickerBar.alpha = 0;
    _eventPicker.alpha = 0;
    
    //アニメーションさせつつ画面に表示
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         
                         _pickerBase.frame = CGRectMake(0,
                                                       STATUS_BAR_HEIGHT + SCREEN_HEIGHT - TAB_BAR_HEIGHT - PICKER_HEIGHT - TOOL_BAR_HEIGHT,
                                                       SCREEN_WIDTH,
                                                       TOOL_BAR_HEIGHT + PICKER_HEIGHT);
                         
                         _pickerBase.alpha = 1;
                         _pickerBar.alpha = 1;
                         _eventPicker.alpha = 1;
                         
                     }
                     completion:nil
     ];
}

- (void)pickerDone {
    
    //NSLog(@"pickerDone");
    
    int account = [_eventPicker selectedRowInComponent:0];
    int function = [_eventPicker selectedRowInComponent:1];
    NSString *tweetId = [_selectTweet objectForKey:@"id_str"];
    
    //    NSLog(@"account: %d", account);
    //    NSLog(@"function: %d", function);
    
    [self performSelectorInBackground:@selector(hidePicker) withObject:nil];
    
    if ( function == 0 ) {
        
        BOOL favorited = [[_selectTweet objectForKey:@"favorited"] boolValue];
        
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
    
    pickerVisible = NO;
    _appDelegate.tabBarController.tabBar.userInteractionEnabled = YES;
    
    //アニメーションさせつつ画面から消す
    [UIView animateWithDuration:0.4f
                          delay:0.0f
                        options:UIViewAnimationOptionTransitionNone
     
                     animations:^{
                         
                         _pickerBase.frame = CGRectMake(0,
                                                       SCREEN_HEIGHT,
                                                       SCREEN_WIDTH,
                                                       TOOL_BAR_HEIGHT + PICKER_HEIGHT);
                         
                         _pickerBase.alpha = 0;
                         _pickerBar.alpha = 0;
                         _eventPicker.alpha = 0;
                     }
     
                     completion:^( BOOL finished ){
                         
                         //NSLog(@"remove pickers");
                         self.pickerBarCancelButton = nil;
                         self.pickerBarDoneButton = nil;
                         
                         while ( _pickerBase.subviews.count ) {
                             
                             UIView *subView = _pickerBase.subviews.lastObject;
                             [subView removeFromSuperview];
                             subView = nil;
                         }
                         
                         [_pickerBase removeFromSuperview];
                         self.pickerBase = nil;
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
        
        _appDelegate.startupUrlList = [NSArray arrayWithObject:[CreateSearchURL twilog:_alertSearchUserName
                                                                            searchWord:_alertSearchText.text]];
        
        [self openBrowser];
        
    }else if ( alertView.tag == 1 && buttonIndex == 1 ) {
        
        _alertSearchText.text = [DeleteWhiteSpace string:_alertSearchText.text];
        _alertSearchText.text = [ReplaceOrDelete deleteWordReturnStr:_alertSearchText.text
                                                         deleteWord:@"@"];
        
        if ( [RegularExpression boolWithRegExp:_alertSearchText.text
                                 regExpPattern:@"[a-zA-Z0-9_]{1,15}"] ) {
            
            [TWGetTimeline userTimeline:_alertSearchText.text];
        }
        
    }else if ( alertView.tag == 2 && buttonIndex == 1 ) {
        
        [TWGetTimeline twitterSearch:[CreateSearchURL encodeWord:_alertSearchText.text
                                                        encoding:kCFStringEncodingUTF8]];
        
    }else if ( alertView.tag == 3 ) {
        
        [self performSelectorInBackground:@selector(openSearchStream:) withObject:_alertSearchText.text];
    }
    
    [self setAlertSearchText:nil];
    [self setAlertSearch:nil];
}

#pragma mark - UIWebViewEx

- (void)openBrowser {
    
    NSLog(@"openBrowser");
    
    NSString *useragent = IPHONE_USERAGENT;
    
    if ( [[_d objectForKey:@"UserAgent"] isEqualToString:@"FireFox"] ) {
        
        useragent = FIREFOX_USERAGENT;
        
    }else if ( [[_d objectForKey:@"UserAgent"] isEqualToString:@"iPad"] ) {
        
        useragent = IPAD_USERAFENT;
    }
    
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:useragent, @"UserAgent", nil];
    [_d registerDefaults:dictionary];
    
    webBrowserMode = YES;
    _appDelegate.reOpenUrl = BLANK;
    
    dispatch_async(dispatch_get_main_queue(), ^ {
        
        WebViewExController *dialog = [[WebViewExController alloc] init];
        dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [_appDelegate.tabBarController.self presentModalViewController:dialog animated:YES];
    });
}

#pragma mark - UITextField

- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    
    //NSLog(@"Textfield Enter: %@", sender.text);
    
    if ( sender.tag == 0 ) {
        
        NSString *searchURL = [CreateSearchURL twilog:[TWAccounts currentAccountName] searchWord:_alertSearchText.text];
        _appDelegate.startupUrlList = [NSArray arrayWithObject:searchURL];
        
        [self openBrowser];
        
    }else if ( sender.tag == 1 ) {
        
        _alertSearchText.text = [DeleteWhiteSpace string:_alertSearchText.text];
        _alertSearchText.text = [ReplaceOrDelete deleteWordReturnStr:_alertSearchText.text deleteWord:@"@"];
        
        if ( [RegularExpression boolWithRegExp:_alertSearchText.text regExpPattern:@"[a-zA-Z0-9_]{1,15}"] ) {
            
            [TWGetTimeline userTimeline:_alertSearchText.text];
        }
        
    }else if ( sender.tag == 2 ) {
        
        [TWGetTimeline twitterSearch:[CreateSearchURL encodeWord:_alertSearchText.text encoding:kCFStringEncodingUTF8]];
        
    }else if ( sender.tag == 3 ) {
        
        [self openSearchStream:_alertSearchText.text];
    }
    
    //キーボードを閉じる
    [sender resignFirstResponder];
    
    //アラートを閉じる
    [_alertSearch dismissWithClickedButtonIndex:0 animated:YES];
    
    [self setAlertSearchText:nil];
    [self setAlertSearch:nil];
    
    return YES;
}

#pragma mark - Notification

- (void)receiveProfile:(NSNotification *)notification {
    
    if ( [[notification.userInfo objectForKey:@"Result"] isEqualToString:@"Success"] ) {
        
        NSDictionary *result = [notification.userInfo objectForKey:@"Profile"];
        
        NSMutableDictionary *tempDic = BLANK_M_DIC;
        
        NSString *screenName = [result objectForKey:@"screen_name"];
        NSString *biggerUrl = [TWIconBigger normal:[result objectForKey:@"profile_image_url"]];
        NSString *fileName = [biggerUrl lastPathComponent];
        NSString *searchName = [NSString stringWithFormat:@"%@_%@", screenName, fileName];
        
        if ( screenName == nil || biggerUrl == nil || searchName == nil ) return;
        
        [tempDic setObject:screenName forKey:@"screen_name"];
        [tempDic setObject:biggerUrl forKey:@"profile_image_url"];
        [tempDic setObject:searchName forKey:@"SearchName"];
        
        [self getIconWithTweetArray:[NSMutableArray arrayWithObject:tempDic]];
        
    }else {
        
        [ShowAlert error:@"ユーザー情報の取得に失敗しました。"];
        _reloadButton.enabled = YES;
    }
}

- (void)receiveTweet:(NSNotification *)notification {
    
    if ( [[notification.userInfo objectForKey:@"Result"] isEqualToString:@"Success"] ) {
        
        [ActivityIndicator on];
        [_inReplyTo insertObject:[notification.userInfo objectForKey:@"Tweet"] atIndex:0];
        [self getInReplyToChain:[notification.userInfo objectForKey:@"Tweet"]];
        
    }else if ( [[notification.userInfo objectForKey:@"Result"] isEqualToString:@"AuthorizeError"] ) {
        
        [self getInReplyToChain:@{ @"in_reply_to_status_id_str" : @"END" }];
        
    }else {
        
        [ShowAlert error:@"Tweet取得中にエラーが発生しました。"];
    }
}

- (void)postDone:(NSNotification *)center {
    
    if ( _appDelegate.postError.count != 0 ) {
        
        _appDelegate.tabChangeFunction = @"PostError";
        _timelineSegment.selectedSegmentIndex = 0;
    }
}

- (void)destroyTweet:(NSNotification *)center {
    
    if ( [[center.userInfo objectForKey:@"Tweet"] objectForKey:@"error"] != nil ) {
        
        [ShowAlert error:[[center.userInfo objectForKey:@"Tweet"] objectForKey:@"error"]];
        return;
    }
    
    NSLog(@"deleteTweetId: %@", [[center.userInfo objectForKey:@"Tweet"] objectForKey:@"id_str"]);
    
    //UserStream接続時は別の箇所で処理
    if ( userStream ) return;
    
    //削除されたTweetを検索
    int index = 0;
    BOOL find = NO;
    for ( NSDictionary *tweet in _timelineArray ) {
        
        if ( [[tweet objectForKey:@"id_str"] isEqualToString:[[center.userInfo objectForKey:@"Tweet"] objectForKey:@"id_str"]] ) {
            
            find = YES;
            
            break;
        }
        
        index++;
    }
    
    if ( find ) {
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            //見つかった物を削除
            [_timelineArray removeObjectAtIndex:index];
            
            //タイムラインを保存
            [TWTweets saveCurrentTimeline:_timelineArray];
            
            [_timeline deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        });
    }
}

- (void)receiveOfflineNotification:(NSNotification *)notification {
    
    NSLog(@"receiveOfflineNotification");
    
    _reloadButton.enabled = YES;
    if ( userStream ) [self closeStream];
    if ( searchStream ) [self closeSearchStream];
    if ( isLoading ) [self finishLoad];
    [_grayView forceEnd];
}

- (void)enterBackground:(NSNotification *)notification {
    
    if ( [_d boolForKey:@"EnterBackgroundUSDisConnect"] ) {
        
        if ( userStream ) [self closeStream];
        if ( searchStream ) [self closeSearchStream];
        if ( _connectionCheckTimer.isValid ) [self stopConnectionCheckTimer];
        if ( _onlineCheckTimer.isValid ) [self stopOnlineCheckTimer];
    }
}

- (void)becomeActive:(NSNotification *)notification {
    
    if ( otherTweetsMode || listMode ) return;
    
    if ( [_d boolForKey:@"BecomeActiveUSConnect"] && _timelineSegment.selectedSegmentIndex == 0 ) {
        
        if ( !userStream && !searchStream ) [self pushReloadButton:nil];
    }
    
    _appDelegate.pboardURLOpenTimeline = NO;
    
    if ( !_connectionCheckTimer.isValid ) [self startConnectionCheckTimer];
}

- (void)pboardNotification:(NSNotification *)notification {
    
    NSLog(@"Timeline pboardNotification: %@", notification.userInfo);
    
    //Timelineタブを開いていない場合は終了
    if ( _appDelegate.tabBarController.selectedIndex != 1 ||
        _appDelegate.browserOpenMode ) return;
    
    _appDelegate.startupUrlList = [NSArray arrayWithObject:[notification.userInfo objectForKey:@"pboardURL"]];
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
    
    _accountIconView.image = nil;
    
    if ( _icons == nil || _icons.count == 0 ) {
        
        //アイコンが1つもない場合は自分のアイコンがないので保存を行う
        [TWEvent getProfile:[TWAccounts currentAccountName]];
        
        NSLog(@"icon file 0");
        
        return;
    }
    
    NSString *string = BLANK;
    BOOL find = NO;
    
    //NSLog(@"icons key: %@", array);
    
    for ( string in [_icons allKeys] ) {
        
        if ( [RegularExpression boolWithRegExp:string regExpPattern:[NSString stringWithFormat:@"%@_", [TWAccounts currentAccountName]]] ) {
            
            NSLog(@"icon find");

            _accountIconView.image = [_icons objectForKey:string];
            find = YES;
            
            break;
        }
        
        if ( find ) break;
    }
    
    if ( !find ) {
        
        NSLog(@"icon not found");
        
        [TWEvent getProfile:[TWAccounts currentAccountName]];
    }
}

- (void)setMyAccountIconCorner {
    
    [[_accountIconView layer] setMasksToBounds:YES];
    [[_accountIconView layer] setCornerRadius:5.0f];
}

- (void)timelineDidListChanged {
    
    //UserStream接続中の場合は切断する
    if ( userStream ) [self closeStream];
    
    _reloadButton.enabled = YES;
    _timelineControlButton.enabled = YES;
    listMode = YES;
    _timelineControlButton.image = _listImage;
    
    [TWTweets saveCurrentTimeline:_timelineArray];
    
    if ( [EmptyCheck string:_appDelegate.listId] ) {
        
        _timelineArray = [_allLists objectForKey:_appDelegate.listId];
        
    }else {
        
        _timelineArray = BLANK_M_ARRAY;
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
    
    [super viewDidAppear:animated];
    
    //NSLog(@"viewDidAppear");
    
    if ( webBrowserMode ) {
        
        webBrowserMode = NO;
        
        if ( _appDelegate.pcUaMode ) {
            
            _appDelegate.pcUaMode = NO;
            
            [self openBrowser];
            
            return;
        }
    }
    
    if ( listMode && [EmptyCheck string:_appDelegate.listId] ) {
        
        if ( userStream ) [self closeStream];
        
        if ( [_allLists objectForKey:_appDelegate.listId] != nil ) {
            
            _timelineArray = [_allLists objectForKey:_appDelegate.listId];
            
        }else {
            
            _timelineArray = BLANK_M_ARRAY;
        }
        
        [_timeline reloadData];
        
        if ( _timelineArray.count == 0 ) {
         
            [TWList getList:_appDelegate.listId];
            [_grayView start];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //NSLog(@"viewWillAppear");
    
    if ( ![_lastUpdateAccount isEqualToString:[TWAccounts currentAccountName]] && [EmptyCheck string:_lastUpdateAccount] ) {
        
        viewWillAppear = YES;
        
        if ( userStream ) [self closeStream];
        
        [self createTimeline];
    }
}

- (void)viewDidUnload {
    
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

- (void)dealloc {
    
    [self setConnection:nil];
    
    [self.view removeAllSubViews];
}

@end
