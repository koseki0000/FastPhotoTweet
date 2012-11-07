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

#define D [NSUserDefaults standardUserDefaults]
#define FILE_MANAGER [NSFileManager defaultManager]
#define P_BOARD [UIPasteboard generalPasteboard]
#define APP_DELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@implementation TimelineViewController
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
        
        dispatch_queue_t asyncQueue = GLOBAL_QUEUE_DEFAULT;
        dispatch_async(asyncQueue, ^{
            
            [self setDefault];
        });
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad");
    
    __block __weak TimelineViewController *weakSelf = self;
    
    dispatch_queue_t asyncQueue = GLOBAL_QUEUE_DEFAULT;
    dispatch_async(asyncQueue, ^{
        
        SYNC_MAIN_QUEUE ^{
            
            weakSelf.timelineControlButton.image = weakSelf.startImage;
            
            weakSelf.timelineSegment.frame = CGRectMake(-4,
                                                        weakSelf.timelineSegment.frame.origin.y,
                                                        weakSelf.timelineSegment.frame.size.width + 8,
                                                        weakSelf.timelineSegment.frame.size.height);
            
            weakSelf.grayView = [ActivityGrayView grayViewWithTaskName:@"FirstLoad"];
            [weakSelf.view addSubview:weakSelf.grayView];
            
            weakSelf.imageWindow = [[ImageWindow alloc] init];
            [weakSelf.view addSubview:weakSelf.imageWindow];
            
            [weakSelf setTimelineHeight];
            
            //ツールバーにボタンを設定
            [weakSelf setTimelineBarItems];
            
            //アイコン表示の角を丸める
            [weakSelf setMyAccountIconCorner];
            
            [weakSelf createPullDownRefreshHeader];
        });
        
        //各種通知設定
        [weakSelf setNotifications];
        
        //インターネット接続を確認
        if ( [InternetConnection disable] ) return;
        
        //タイムライン生成
        [weakSelf performSelectorInBackground:@selector(createTimeline) withObject:nil];
    });
}

- (void)setDefault {
    
    //各種初期化
    _timelineArray = BLANK_ARRAY;
    _inReplyTo = BLANK_M_ARRAY;
    _reqedUser = BLANK_M_ARRAY;
    _iconUrls = BLANK_M_ARRAY;
    _currentList = BLANK_M_ARRAY;
    _searchStreamTemp = BLANK_M_ARRAY;
    //    _icons = BLANK_M_DIC;
    _mentionsArray = BLANK_ARRAY;
    _allLists = BLANK_M_DIC;
    _selectTweet = BLANK_DIC;
    _selectAccount = BLANK;
    _alertSearchUserName = BLANK;
    
    _icons = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                       0,
                                       &kCFTypeDictionaryKeyCallBacks,
                                       &kCFTypeDictionaryValueCallBacks);
    
    _startImage = [UIImage imageNamed:@"ForwardIcon.png"];
    _stopImage = [UIImage imageNamed:@"stop.png"];
    _listImage = [UIImage imageNamed:@"list.png"];
    
    _userStream = NO;
    _userStreamFirstResponse = NO;
    _pickerVisible = NO;
    
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
        
        __block __weak TimelineViewController *weakSelf = self;
        
        DISPATCH_AFTER(0.1) ^{
            
            [weakSelf pushReloadButton:nil];
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
    
    NSLog(@"createTimeline");
    
    //インターネット接続を確認
    if ( ![InternetConnection enable] ) return;
    
    if ( [TWAccounts currentAccount] == nil ) {
        
        [ShowAlert error:@"Twitterアカウントが取得できません。iPhoneの設定より登録の後、ご使用ください。"];
        return;
    }
    
    __block __weak TimelineViewController *weakSelf = self;
    
    //アクティブアカウントのタイムラインを反映
    if ( _timelineArray != [TWTweets currentTimeline] ) {
        
        ASYNC_MAIN_QUEUE ^{
            
            weakSelf.timelineArray = [TWTweets currentTimeline];
            [weakSelf.timeline reloadData];
        });
    }
    
    ASYNC_MAIN_QUEUE ^{
        
        if ( weakSelf.timelineArray.count == 0 ) {
            
            [weakSelf.grayView start];
            weakSelf.firstLoad = YES;
        }
    });
    
    //タイムライン取得
    [TWGetTimeline homeTimeline];
}

- (void)loadTimeline:(NSNotification *)center {
    
    @autoreleasepool {
        
        __block __weak TimelineViewController *weakSelf = self;
        
        dispatch_queue_t globalQueue = GLOBAL_QUEUE_DEFAULT;
        dispatch_async(globalQueue, ^{
            
            NSLog(@"loadTimeline[%d], userStream[%@]", weakSelf.timelineArray.count, weakSelf.userStream ? @"ON" : @"OFF");
            
            ASYNC_MAIN_QUEUE ^{
                
                [weakSelf finishLoad];
            });
            
            //Timelineタブ以外が選択されている場合は終了
            if ( weakSelf.timelineSegment.selectedSegmentIndex != 0 ) return;
            if ( ![[center.userInfo objectForKey:@"Type"] isEqualToString:@"Timeline"] ) return;
            if ( ![[center.userInfo objectForKey:@"Account"] isEqualToString:[TWAccounts currentAccountName]] ) return;
            
            //自分のアイコンを設定
            [weakSelf getMyAccountIcon];
            
            //更新アカウントを記憶
            weakSelf.lastUpdateAccount = [TWAccounts currentAccountName];
            
            NSString *result = [[NSString alloc] initWithString:[center.userInfo objectForKey:@"Result"]];
            
            if ( [result isEqualToString:@"TimelineSuccess"] ) {
                
                NSArray *newTweet = [[NSArray alloc] initWithArray:[center.userInfo objectForKey:@"Timeline"]];
                
                //NSLog(@"newTweet: %@", newTweet);
                
                if ( newTweet.count == 0 ) {
                    
                    NSLog(@"newTweet.count == 0");
                    
                    ASYNC_MAIN_QUEUE ^{
                        
                        weakSelf.reloadButton.enabled = YES;
                        
                        if ( weakSelf.viewWillAppear ) {
                            
                            weakSelf.viewWillAppear = NO;
                            [weakSelf.timeline reloadData];
                        }
                    });
                    
                    if ( [D boolForKey:@"ReloadAfterUSConnect"] && !weakSelf.userStream ) {
                        
                        //UserStream接続
                        [weakSelf pushTimelineControlButton:nil];
                    }
                    
                    return;
                }
                
                if ( [[newTweet objectAtIndex:0] objectForKey:@"errors"] != nil ) {
                    
                    NSLog(@"newTweet error");
                    
                    [ShowAlert error:@"タイムライン取得時にエラーが発生しました。"];
                    
                    if ( [D boolForKey:@"ReloadAfterUSConnect"] && !weakSelf.userStream ) {
                        
                        //UserStream接続
                        [weakSelf pushTimelineControlButton:nil];
                    }
                    
                    return;
                }
                
                //NG判定を行う
                newTweet = [TWNgTweet ngAll:newTweet];
                
                if ( [newTweet isNotEmpty] ) {
                    
                    NSString *scrollTweetID = nil;
                    
                    if ( [weakSelf.timelineArray isNotEmpty] ) {
                        
                        scrollTweetID = [[NSString alloc] initWithString:[[weakSelf.timelineArray objectAtIndex:0] objectForKey:@"id_str"]];
                    }
                    
                    weakSelf.timelineArray = [weakSelf.timelineArray appendOnlyNewToTop:newTweet
                                                                               forXPath:@"id_str"
                                                                          returnMutable:YES];
                    
                    //タイムラインを保存
                    [TWTweets saveCurrentTimeline:weakSelf.timelineArray];
                    
                    [weakSelf checkTimelineCount:NO];
                    
                    __block __weak NSString *weakScrollTweetID = scrollTweetID;
                    
                    ASYNC_MAIN_QUEUE ^{
                        
                        weakSelf.reloadButton.enabled = YES;
                        
                        [ActivityIndicator off];
                        
                        //タイムラインを再読み込み
                        [weakSelf.timeline reloadData];
                        
                        if ( weakSelf.firstLoad && [D boolForKey:@"TimelineFirstLoad"] ) {
                            
                            [weakSelf scrollTimelineToBottom:YES];
                            weakSelf.firstLoad = NO;
                            
                        }else {
                            
                            //新着取得前の最新までスクロール
                            [weakSelf scrollTimelineForNewTweet:weakScrollTweetID];
                        }
                        
                        [weakSelf.timeline flashScrollIndicators];
                        
                        if ( [D boolForKey:@"ReloadAfterUSConnect"] && !weakSelf.userStream ) {
                            
                            //UserStream接続
                            DISPATCH_AFTER(0.1) ^{
                                
                                [weakSelf pushTimelineControlButton:nil];
                            });
                        }
                    });
                    
                    //タイムラインからアイコンのURLを取得
                    [weakSelf getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
                    
                }else {
                    
                    ASYNC_MAIN_QUEUE ^{
                        
                        weakSelf.reloadButton.enabled = YES;
                        
                        if ( [D boolForKey:@"ReloadAfterUSConnect"] && !weakSelf.userStream ) {
                            
                            //UserStream接続
                            DISPATCH_AFTER(0.1) ^{
                                
                                [weakSelf pushTimelineControlButton:nil];
                            });
                        }
                        
                        //タイムライン表示を更新
                        [weakSelf.timeline reloadData];
                    });
                }
                
            }else if ( [result isEqualToString:@"TimelineError"] ) {
                
                weakSelf.reloadButton.enabled = YES;
            }
        });
    }
}

- (void)loadUserTimeline:(NSNotification *)center {
    
    NSLog(@"loadUserTimeline");
    
    __block __weak TimelineViewController *weakSelf = self;
    
    ASYNC_MAIN_QUEUE ^{
        
        [weakSelf finishLoad];
    });
    
    if ( ![[center.userInfo objectForKey:@"Type"] isEqualToString:@"UserTimeline"] ) return;
    
    //レスポンスが空の場合は何もしない
    if ( [[center.userInfo objectForKey:@"UserTimeline"] count] == 0 ) return;
    
    //UserStream接続中の場合は切断する
    if ( _userStream ) [self closeStream];
    
    _timelineControlButton.enabled = NO;
    
    if ( [[center.userInfo objectForKey:@"Result"] isEqualToString:@"UserTimelineSuccess"] ) {
        
        NSArray *newTweet = [[NSArray alloc] initWithArray:[center.userInfo objectForKey:@"UserTimeline"]];
        
        //NSLog(@"newTweet: %@", newTweet);
        
        NSLog(@"UserTimeline: %dTweet", newTweet.count);
        
        //NG判定を行う
        newTweet = [TWNgTweet ngAll:newTweet];
        
        //InReplyToからの復帰用に保存しておく
        _mentionsArray = newTweet;
        
        _timelineArray = [NSMutableArray arrayWithArray:newTweet];
        
        //タイムラインからアイコンのURLを取得
        [self getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
        
        ASYNC_MAIN_QUEUE ^{
            
            [ActivityIndicator off];
            
            [weakSelf setOtherTweetsBarItems];
            
            //タイムラインを再読み込み
            [weakSelf.timeline reloadData];
            
            [weakSelf scrollTimelineToTop:NO];
            
            [weakSelf.timeline flashScrollIndicators];
        });
        
    }else {
        
        [ShowAlert error:@"UserTimelineが読み込めませんでした。"];
    }
}

- (void)loadMentions:(NSNotification *)center {
    
    NSLog(@"loadMentions");
    
    __block __weak TimelineViewController *weakSelf = self;
    
    ASYNC_MAIN_QUEUE ^{
        
        [weakSelf finishLoad];
    });
    
    if ( ![[center.userInfo objectForKey:@"Type"] isEqualToString:@"Mentions"] ) return;
    
    //Mentionsタブ以外が選択されている場合は終了
    if ( _timelineSegment.selectedSegmentIndex != 1 ) return;
    
    //UserStream接続中の場合は切断する
    if ( _userStream ) [self closeStream];
    
    _reloadButton.enabled = YES;
    _timelineControlButton.enabled = NO;
    
    if ( [[center.userInfo objectForKey:@"Result"] isEqualToString:@"MentionsSuccess"] ) {
        
        NSArray *newTweet = [[NSArray alloc] initWithArray:[center.userInfo objectForKey:@"Mentions"]];
        
        //t.coを展開
        newTweet = [TWEntities replaceTcoAll:newTweet];
        
        //NG判定を行う
        newTweet = [TWNgTweet ngAll:newTweet];
        
        //InReplyToからの復帰用に保存しておく
        _mentionsArray = newTweet;
        
        _timelineArray = [NSMutableArray arrayWithArray:newTweet];
        
        //タイムラインからアイコンのURLを取得
        [self getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
        
        newTweet = nil;
        
        ASYNC_MAIN_QUEUE ^{
            
            [ActivityIndicator off];
            
            //タイムラインを再読み込み
            [weakSelf.timeline reloadData];
            
            [weakSelf scrollTimelineToTop:NO];
            
            [weakSelf.timeline flashScrollIndicators];
        });
    }
}

- (void)loadFavorites:(NSNotification *)center {
    
    NSLog(@"loadFavorites");
    
    __block __weak TimelineViewController *weakSelf = self;
    
    ASYNC_MAIN_QUEUE ^{
        
        [weakSelf finishLoad];
    });
    
    if ( ![[center.userInfo objectForKey:@"Type"] isEqualToString:@"Favorites"] ) return;
    
    //Favoritesタブ以外が選択されている場合は終了
    if ( _timelineSegment.selectedSegmentIndex != 2 ) return;
    
    //UserStream接続中の場合は切断する
    if ( _userStream ) [self closeStream];
    
    _timelineControlButton.enabled = NO;
    _reloadButton.enabled = YES;
    
    NSString *result = [[NSString alloc] initWithString:[center.userInfo objectForKey:@"Result"]];
    
    if ( [result isEqualToString:@"FavoritesSuccess"] ) {
        
        NSArray *newTweet = [[NSArray alloc] initWithArray:[center.userInfo objectForKey:@"Favorites"]];
        
        //t.coを展開
        newTweet = [TWEntities replaceTcoAll:newTweet];
        
        //InReplyToからの復帰用に保存しておく
        _mentionsArray = newTweet;
        
        _timelineArray = [NSMutableArray arrayWithArray:newTweet];
        
        //タイムラインからアイコンのURLを取得
        [self getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
        
        ASYNC_MAIN_QUEUE ^{
            
            [ActivityIndicator off];
            
            //タイムラインを再読み込み
            [weakSelf.timeline reloadData];
            
            [weakSelf scrollTimelineToTop:NO];
            
            [weakSelf.timeline flashScrollIndicators];
        });
    }
}

- (void)loadSearch:(NSNotification *)center {
    
    NSLog(@"loadSearch");
    
    __block __weak TimelineViewController *weakSelf = self;
    
    ASYNC_MAIN_QUEUE ^{
        
        [weakSelf finishLoad];
    });
    
    if ( ![[center.userInfo objectForKey:@"Type"] isEqualToString:@"Search"] ) return;
    
    //UserStream接続中の場合は切断する
    if ( _userStream ) [self closeStream];
    
    _timelineControlButton.enabled = NO;
    
    NSString *result = [[NSString alloc] initWithString:[center.userInfo objectForKey:@"Result"]];
    
    if ( [result isEqualToString:@"SearchSuccess"] ) {
        
        NSArray *newTweet = [[NSArray alloc] initWithArray:[center.userInfo objectForKey:@"Search"]];
        
        //InReplyToからの復帰用に保存しておく
        _mentionsArray = newTweet;
        
        _timelineArray = [NSMutableArray arrayWithArray:newTweet];
        
        //タイムラインからアイコンのURLを取得
        [self getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
        
        [ActivityIndicator off];
        
        [self setOtherTweetsBarItems];
        
        ASYNC_MAIN_QUEUE ^{
            
            [ActivityIndicator off];
            
            //タイムラインを再読み込み
            [weakSelf.timeline reloadData];
            
            [weakSelf scrollTimelineToTop:NO];
            
            [weakSelf.timeline flashScrollIndicators];
        });
    }
}

- (void)loadList:(NSNotification *)center {
    
    NSLog(@"loadList");
    
    __block __weak TimelineViewController *weakSelf = self;
    
    ASYNC_MAIN_QUEUE ^{
        
        [weakSelf finishLoad];
    });
    
    if ( ![[center.userInfo objectForKey:@"Type"] isEqualToString:@"List"] ) return;
    
    //Listタブ以外が選択されている場合は終了
    if ( _timelineSegment.selectedSegmentIndex != 3 ) return;
    
    _reloadButton.enabled = YES;
    
    NSArray *newTweet = [[NSArray alloc] initWithArray:[center.userInfo objectForKey:@"ResultData"]];
    
    //t.coを展開
    newTweet = [TWEntities replaceTcoAll:newTweet];
    
    //NG判定を行う
    newTweet = [TWNgTweet ngAll:newTweet];
    
    _currentList = [NSMutableArray arrayWithArray:newTweet];
    
    [_allLists setObject:_currentList forKey:APP_DELEGATE.listId];
    
    _timelineArray = _currentList;
    
    //タイムラインからアイコンのURLを取得
    [self getIconWithTweetArray:_timelineArray];
    
    ASYNC_MAIN_QUEUE ^{
        
        [ActivityIndicator off];
        
        //タイムラインを再読み込み
        [weakSelf.timeline reloadData];
        
        [weakSelf scrollTimelineToTop:NO];
        
        [weakSelf.timeline flashScrollIndicators];
    });
}

- (void)getIconWithTweetArray:(NSMutableArray *)tweetArray {
    
    //    NSLog(@"getIconWithTweetArray[%d]", tweetArray.count);
    
    NSMutableSet *addUser = [NSMutableSet set];
    NSMutableSet *addIconUrls = [NSMutableSet setWithArray:_iconUrls];
    __block __weak TimelineViewController *weakSelf = self;
    
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
        
        //検索用の名前
        NSString *searchName = [[NSString alloc] initWithFormat:@"%@_%@", screenName, [biggerUrl lastPathComponent]];
        
        if ( [APP_DELEGATE iconExist:searchName] ) {
            
            //アイコンファイルを読み込み
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:FILE_PATH];
            
            if ( image != nil ) {
                
                CFDictionarySetValue(_icons, (CFStringRef)searchName, image.CGImage);
                
                //自分のアイコンの場合は上部バーに設定
                if ( [screenName isEqualToString:[TWAccounts currentAccountName]] ) {
                    
                    weakSelf.accountIconView.image = image;
                }
                
                [ActivityIndicator off];
            }
            
        }else {
            
            //保存されていないアイコンを保存する
            if ( CFDictionaryGetValue(_icons, (CFStringRef)searchName) == nil ) {
                
                //各情報が空でないかチェック
                if ( [screenName isNotEmpty] &&
                    [biggerUrl isNotEmpty] &&
                    [[biggerUrl lastPathComponent] isNotEmpty] &&
                    [searchName isNotEmpty] ) {
                    
                    NSMutableDictionary *tempDic = BLANK_M_DIC;
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
    
    _iconWorking = YES;
    
    for ( id user in addUser ) {
        
        [_reqedUser addObject:user];
    }
    
    //アイコン保存開始
    if ( addIconUrls.count != 0 ) {
        
        _iconUrls = [NSMutableArray arrayWithArray:[addIconUrls allObjects]];
        
        _iconWorking = NO;
        
        [self getIconWithSequential];
        
    }else {
        
        _iconWorking = NO;
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
    
    __block __weak TimelineViewController *weakSelf = self;
    
    if ( _iconWorking ) {
        
        DISPATCH_AFTER(0.1) ^{
            
            [weakSelf getIconWithSequential];
        });
        
    }else {
        
        //アイコンのURLを取得
        NSDictionary *dic = [[NSDictionary alloc] initWithDictionary:[_iconUrls objectAtIndex:0]];
        NSString *biggerUrl = [[NSString alloc] initWithString:[dic objectForKey:@"profile_image_url"]];
        
        //アイコンダウンロード開始
        NSURL *URL = [[NSURL alloc] initWithString:biggerUrl];
        ASIHTTPRequest *reSendRequest = [[ASIHTTPRequest alloc] initWithURL:URL];
        reSendRequest.userInfo = dic;
        [reSendRequest setDelegate:self];
        [reSendRequest start];
        
        dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        dispatch_async(queue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            if ( [weakSelf.iconUrls isNotEmpty] ) {
                
                [weakSelf.iconUrls removeObjectAtIndex:0];
            }
            
            dispatch_semaphore_signal(semaphore);
            dispatch_release(semaphore);
        });
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
    _timelineArray = [TWTweets currentTimeline];
    [_timeline reloadData];
    
    __block __weak TimelineViewController *weakSelf = self;
    
    //リロードする
    DISPATCH_AFTER(0.1) ^{
        
        [weakSelf createTimeline];
    });
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
        
        [sheet showInView:APP_DELEGATE.tabBarController.self.view];
        
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
        
        [sheet showInView:APP_DELEGATE.tabBarController.self.view];
        
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
        
        [sheet showInView:APP_DELEGATE.tabBarController.self.view];
        
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
        
        [sheet showInView:APP_DELEGATE.tabBarController.self.view];
        
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
        
        [sheet showInView:APP_DELEGATE.tabBarController.self.view];
    }
}

- (void)checkTimelineCount:(BOOL)animated {
    
    int max = 400;
    if ( _searchStream ) max = 100;
    
    __block __weak TimelineViewController *weakSelf = self;
    
    while ( weakSelf.timelineArray.count > max ) {
        
        dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
        
        dispatch_sync(queue, ^{
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            [weakSelf.timelineArray removeLastObject];
            
            if ( animated ) {
                
                [weakSelf.timeline deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.timelineArray.count - 1 inSection:0]]
                                         withRowAnimation:UITableViewRowAnimationBottom];
            }
            
            dispatch_semaphore_signal(semaphore);
            dispatch_release(semaphore);
        });
    }
}

#pragma mark - In reply to

- (void)getInReplyToChain:(NSDictionary *)tweetData {
    
    NSString *inReplyToId = [tweetData objectForKey:@"in_reply_to_status_id_str"];
    __block __weak NSString *weakInReplyToId = inReplyToId;
    __block __weak TimelineViewController *weakSelf = self;
    
    NSLog(@"getInReplyToChain: %@", weakInReplyToId);
    
    if ( ![EmptyCheck check:weakInReplyToId] || [weakInReplyToId isEqualToString:@"END"] ) {
        
        //InReplyToIDがもうない場合は表示を行う
        
        if ( [EmptyCheck check:_inReplyTo] && _inReplyTo.count > 1 ) {
            
            NSLog(@"InReplyTo GET END");
            
            [self closeStream];
            
            dispatch_queue_t globalQueue = GLOBAL_QUEUE_DEFAULT;
            dispatch_async(globalQueue, ^{
                
                //表示開始
                ASYNC_MAIN_QUEUE ^{
                    
                    //t.coを展開
                    weakSelf.inReplyTo = [TWEntities replaceTcoAll:weakSelf.inReplyTo];
                    
                    [weakSelf setOtherTweetsBarItems];
                    
                    weakSelf.timelineArray = BLANK_M_ARRAY;
                    [weakSelf.timeline reloadData];
                    
                    for ( NSDictionary *tweet in weakSelf.inReplyTo ) {
                        
                        //タイムラインに追加
                        [weakSelf.timelineArray insertObject:tweet atIndex:0];
                        [weakSelf.timeline insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                    }
                    
                    //タイムラインからアイコンのURLを取得
                    [self getIconWithTweetArray:[NSMutableArray arrayWithArray:weakSelf.timelineArray]];
                });
            });
        }
        
    }else {
        
        dispatch_queue_t globalQueue = GLOBAL_QUEUE_DEFAULT;
        dispatch_async(globalQueue, ^{
            
            [ActivityIndicator on];
            
            BOOL find = NO;
            NSDictionary *findTweet = BLANK_DIC;
            
            for ( NSDictionary *searchTweet in weakSelf.timelineArray ) {
                
                NSString *searchTweetID = [[NSString alloc] initWithString:[searchTweet objectForKey:@"id_str"]];
                
                if ( [searchTweetID isNotEmpty] ) {
                    
                    if ( [searchTweetID isEqualToString:weakInReplyToId] ) {
                        
                        find = YES;
                        findTweet = searchTweet;
                        [weakSelf.inReplyTo insertObject:findTweet atIndex:0];
                    }
                }
                
                if ( find ) break;
            }
            
            if ( find ) {
                
                NSLog(@"InReplyTo TL");
                
                [weakSelf getInReplyToChain:findTweet];
                
            }else {
                
                NSLog(@"InReplyTo REST");
                
                [TWEvent getTweet:weakInReplyToId];
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
        NSString *text = [_currentTweet objectForKey:@"text"];
        
        //ID
        NSString *screenName = [[_currentTweet objectForKey:@"user"] objectForKey:@"screen_name"];
        cell.iconView.buttonTitle = screenName;
        
        //ID - 日付 [クライアント名]
        NSString *infoLabelText = [_currentTweet objectForKey:@"info_text"];
        
        //アイコン検索用
        NSString *searchName = [_currentTweet objectForKey:@"search_name"];
        
        if ( CFDictionaryGetValue(_icons, (CFStringRef)searchName) != nil &&
            cell.iconView.layer.sublayers.count != 0 &&
            [[cell.iconView.layer.sublayers.lastObject name] isEqualToString:@"Icon"] ) {
            
            [cell.iconView.layer.sublayers.lastObject setContents:CFDictionaryGetValue(_icons, (CFStringRef)searchName)];
            
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
            
            NSString *temp = infoLabelText;
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
    
    if ( !_webBrowserMode ) {
        
        //ピッカー表示中は何もしない
        if ( _pickerVisible ) return;
        
        _selectRow = indexPath.row;
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
            
            [sheet showInView:APP_DELEGATE.tabBarController.self.view];
            
        }else {
            
            NSString *targetId = [[NSString alloc] initWithString:[_selectTweet objectForKey:@"id_str"]];
            NSString *favStarUrl = [[NSString alloc] initWithFormat:@"http://ja.favstar.fm/users/%@/status/%@",
                                    [TWAccounts currentAccountName],
                                    targetId];
            
            APP_DELEGATE.startupUrlList = [NSArray arrayWithObject:favStarUrl];
            
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

- (void)scrollTimelineForNewTweet:(NSString *)tweetID {
    
    __block __weak NSString *weakTweetID = tweetID;
    __block __weak TimelineViewController *weakSelf = self;
    
    dispatch_queue_t globalQueue = GLOBAL_QUEUE_DEFAULT;
    dispatch_async(globalQueue, ^{
        
        //Tweetがない場合はスクロールしない
        if ( weakSelf.timelineArray == nil ||
            weakSelf.timelineArray.count == 0 ) return;
        
        //スクロールするIDがない場合は終了
        if ( weakTweetID == nil ||
            [weakTweetID isEqualToString:@""] ) return;
        
        //スクロールするインデックスを検索
        int index = 0;
        BOOL find = NO;
        for ( NSDictionary *tweet in [TWTweets currentTimeline] ) {
            
            if ( [tweet objectForKey:@"id_str"] != nil &&
                [[tweet objectForKey:@"id_str"] isEqualToString:weakTweetID] ) {
                
                find = YES;
                break;
            }
            
            index++;
        }
        
        if ( find ) {
            
            if ( weakSelf.timelineArray.count < index ||
                [weakSelf.timelineArray objectAtIndex:index] == nil ) return;
            
            ASYNC_MAIN_QUEUE ^{
                
                //スクロールする
                [weakSelf.timeline scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
    [_timeline scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_timelineArray.count - 1 inSection:0]
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
    _alertSearchType = NO;
    
    [sheet showInView:APP_DELEGATE.tabBarController.self.view];
}

- (void)openTimelineURL:(NSNotification *)notification {
    
    NSString *urlString = [[NSString alloc] initWithString:[notification.userInfo objectForKey:@"URL"]];
    
    if ( urlString == nil ) {
        
        return;
    }
    
    APP_DELEGATE.startupUrlList = @[urlString];
    [self openBrowser];
}

- (void)openTimelineImage:(NSNotification *)notification {
    
    NSString *urlString = [[NSString alloc] initWithString:[notification.userInfo objectForKey:@"URL"]];
    
    if ( urlString == nil ) {
        
        return;
    }
    
    [_imageWindow loadImage:urlString viewRect:_timeline.frame];
}

- (void)receiveGrayViewDoneNotification:(NSNotification *)notification {
    
    NSLog(@"receiveGrayViewDoneNotification");
}

#pragma mark - ASIHTTPRequest

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    __block __weak ASIHTTPRequest *weakRequest = request;
    __block __weak TimelineViewController *weakSelf = self;
    
    dispatch_queue_t globalQueue = GLOBAL_QUEUE_DEFAULT;
    dispatch_async(globalQueue, ^{
        
        NSString *screenName = [[NSString alloc] initWithString:[weakRequest.userInfo objectForKey:@"screen_name"]];
        NSString *searchName = [[NSString alloc] initWithString:[weakRequest.userInfo objectForKey:@"SearchName"]];
        UIImage *receiveImage = [[UIImage alloc] initWithData:weakRequest.responseData];
        
        __block __weak NSString *weakScreenName = screenName;
        
        if  ( receiveImage != nil ) {
            
            CFDictionarySetValue(weakSelf.icons, (CFStringRef)searchName, receiveImage.CGImage);
            
            if ( ![APP_DELEGATE iconExist:searchName] ) {
                
                [request.responseData writeToFile:FILE_PATH atomically:YES];
            }
            
            if ( weakSelf.timelineArray.count != 0 ) {
                
                NSArray *tempTimelineArray = [[NSArray alloc] initWithArray:[NSArray arrayWithArray:weakSelf.timelineArray]];
                int index = 0;
                
                for ( NSDictionary *tweet in tempTimelineArray ) {
                    
                    if ( [[[tweet objectForKey:@"user"] objectForKey:@"screen_name"] isEqualToString:weakScreenName] ) {
                        
                        ASYNC_MAIN_QUEUE ^{
                            
                            //TL更新
                            [weakSelf refreshTimelineCell:[NSNumber numberWithInt:index]];
                        });
                    }
                    
                    //自分のアイコンの場合はツールバーにも設定
                    if ( [weakScreenName isEqualToString:[TWAccounts currentAccountName]] ) {
                        
                        ASYNC_MAIN_QUEUE ^{
                            
                            //アカウントアイコンを設定
                            if ( weakSelf.accountIconView == nil ) {
                                
                                weakSelf.accountIconView = [[UIImageView alloc] initWithFrame:CGRectMake(142, 5, 36, 36)];
                                weakSelf.accountIconView.contentMode = UIViewContentModeScaleAspectFit;
                                weakSelf.accountIconView.image = [UIImage imageWithContentsOfFile:FILE_PATH];
                                [weakSelf setMyAccountIconCorner];
                                
                            }else {
                                
                                weakSelf.accountIconView.image = [UIImage imageWithContentsOfFile:FILE_PATH];
                            }
                        });
                    }
                    
                    index++;
                }
            }
            
        }else {
            
            NSLog(@"receiveImage nil");
        }
        
        [weakSelf getIconWithSequential];
    });
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    NSLog(@"requestFailed: %@", request.responseString);
    
    [ActivityIndicator off];
    
    if ( [InternetConnection enable] ) {
        
        //再送信
        NSURL *URL = [[NSURL alloc] initWithString:[request.userInfo objectForKey:@"profile_image_url"]];
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
        _timelineArray = [TWTweets currentTimeline];
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
        [self openStream];
        
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
    
    [sheet showInView:APP_DELEGATE.tabBarController.self.view];
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
    
    __block __weak TimelineViewController *weakSelf = self;
    
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
            weakSelf.connection = [NSURLConnection connectionWithRequest:request.signedURLRequest delegate:weakSelf];
            [weakSelf.connection start];
            
            // 終わるまでループさせる
            while ( weakSelf.userStream ) {
                
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
        }
    });
}

- (void)closeStream {
    
    NSLog(@"closeStream");
    
    if ( [D boolForKey:@"USNoAutoLock"] ) [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    _userStream = NO;
    _userStreamFirstResponse = NO;
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
    
    __block __weak TimelineViewController *weakSelf = self;
    __block int index = 0;
    __block BOOL find = NO;
    
    dispatch_queue_t globalQueue = GLOBAL_QUEUE_DEFAULT;
    dispatch_async(globalQueue, ^{
        
        //削除イベント
        NSString *deleteTweetId = [[NSString alloc] initWithString:[[[receiveData objectForKey:@"delete"] objectForKey:@"status"] objectForKey:@"id_str"]];
        
        //削除されたTweetを検索
        for ( NSDictionary *tweet in weakSelf.timelineArray ) {
            
            if ( [[tweet objectForKey:@"id_str"] isEqualToString:deleteTweetId] ) {
                
                find = YES;
                break;
            }
            
            index++;
        }
    });
    
    if ( find ) {
        
        SYNC_MAIN_QUEUE ^{
            
            //見つかった物を削除
            [weakSelf.timelineArray removeObjectAtIndex:index];
            
            //タイムラインを保存
            [TWTweets saveCurrentTimeline:weakSelf.timelineArray];
            
            [weakSelf.timeline deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        });
    }
}

- (void)userStreamMyAddFavEvent:(NSDictionary *)receiveData {
    
    //自分のふぁぼりイベント
    NSString *favedTweetId = [[NSString alloc] initWithString:[[receiveData objectForKey:@"target_object"] objectForKey:@"id_str"]];
    
    __block __weak TimelineViewController *weakSelf = self;
    __block __weak NSString *weakFavedTweetId = favedTweetId;
    
    int index = 0;
    for ( NSDictionary *tweet in weakSelf.timelineArray ) {
        
        if ( [[tweet objectForKey:@"id_str"] isEqualToString:weakFavedTweetId] ) {
            
            NSMutableDictionary *favedTweet = [[NSMutableDictionary alloc] initWithDictionary:tweet];
            [favedTweet setObject:@"1" forKey:@"favorited"];
            
            SYNC_MAIN_QUEUE ^{
                
                [weakSelf.timelineArray replaceObjectAtIndex:index withObject:favedTweet];
                
                //タイムラインを保存
                [TWTweets saveCurrentTimeline:weakSelf.timelineArray];
                
                //TL更新
                [weakSelf.timeline reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            });
            
            break;
        }
        
        index++;
    }
}

- (void)userStreamMyRemoveFavEvent:(NSDictionary *)receiveData {
    
    //自分のふぁぼり外しイベント
    NSString *favedTweetId = [[NSString alloc] initWithString:[[receiveData objectForKey:@"target_object"] objectForKey:@"id_str"]];
    
    __block __weak TimelineViewController *weakSelf = self;
    __block __weak NSString *weakFavedTweetId = favedTweetId;
    
    int index = 0;
    for ( NSDictionary *tweet in weakSelf.timelineArray ) {
        
        if ( [[tweet objectForKey:@"id_str"] isEqualToString:weakFavedTweetId] ) {
            
            NSMutableDictionary *favedTweet = [[NSMutableDictionary alloc] initWithDictionary:tweet];
            [favedTweet setObject:@"0" forKey:@"favorited"];
            
            SYNC_MAIN_QUEUE ^{
                
                [weakSelf.timelineArray replaceObjectAtIndex:index withObject:favedTweet];
                
                //タイムラインを保存
                [TWTweets saveCurrentTimeline:weakSelf.timelineArray];
                
                //TL更新
                [weakSelf.timeline reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
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
    NSString *favUser = [[NSString alloc] initWithString:[[receiveData objectForKey:@"target"] objectForKey:@"screen_name"]];
    
    //ふぁぼられ人のアイコン
    NSString *favUserIcon = [[NSString alloc] initWithString:[[receiveData objectForKey:@"target"] objectForKey:@"profile_image_url"]];
    
    //ふぁぼった人
    NSString *addUser = [[NSString alloc] initWithString:[[receiveData objectForKey:@"source"] objectForKey:@"screen_name"]];
    
    //ふぁぼられたTweetの時間
    NSString *favTime = [[NSString alloc] initWithString:[[receiveData objectForKey:@"target_object"] objectForKey:@"created_at"]];
    
    //ふぁぼられたTweet
    NSString *targetText = [[NSString alloc] initWithString:[[receiveData objectForKey:@"target_object"] objectForKey:@"text"]];
    
    //ふぁぼられたID
    NSString *targetId = [[NSString alloc] initWithString:[[receiveData objectForKey:@"target_object"] objectForKey:@"id_str"]];
    
    //クライアント
    NSString *favClient = [[NSString alloc] initWithString:[[receiveData objectForKey:@"target_object"] objectForKey:@"source"]];
    
    NSString *infoText = [[NSString alloc] initWithString:[receiveData objectForKey:@"info_text"]];
    
    NSString *searchName = [[NSString alloc] initWithString:[receiveData objectForKey:@"search_name"]];
    
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
    
    if ( CFDictionaryGetValue(_icons, (CFStringRef)favUser) == nil ) {
        
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        [tempDic setObject:[[favDic objectForKey:@"user"] objectForKey:@"screen_name"] forKey:@"screen_name"];
        [tempDic setObject:[TWIconBigger normal:[[favDic objectForKey:@"user"] objectForKey:@"profile_image_url"]] forKey:@"profile_image_url"];
        
        //アイコン取得
        [self getIconWithTweetArray:[NSMutableArray arrayWithObject:tempDic]];
    }
    
    __block __weak TimelineViewController *weakSelf = self;
    
    SYNC_MAIN_QUEUE ^{
        
        //タイムラインに追加
        weakSelf.timelineArray = [weakSelf.timelineArray appendToTop:@[favDic] returnMutable:YES];
        
        //タイムラインを保存
        [TWTweets saveCurrentTimeline:weakSelf.timelineArray];
        
        //タイムラインを更新
        [weakSelf.timeline insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                 withRowAnimation:UITableViewRowAnimationTop];
    });
}

- (void)userStreamReceiveTweet:(NSDictionary *)receiveData newTweet:(NSArray *)newTweet {
    
    __block __weak TimelineViewController *weakSelf = self;
    
    SYNC_MAIN_QUEUE ^{
        
        [weakSelf checkTimelineCount:YES];
        
        //タイムラインに追加
        weakSelf.timelineArray = [weakSelf.timelineArray appendOnlyNewToTop:newTweet returnMutable:YES];
        
        //タイムラインを保存
        [TWTweets saveCurrentTimeline:weakSelf.timelineArray];
        
        [weakSelf.timeline insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]
                                 withRowAnimation:UITableViewRowAnimationTop];
    });
    
    //アイコン保存
    [weakSelf getIconWithTweetArray:[NSMutableArray arrayWithArray:newTweet]];
}

#pragma mark - SearchStream

- (void)openSearchStream:(NSString *)searchWord {
    
    __block __weak TimelineViewController *weakSelf = self;
    
    dispatch_queue_t userStreamQueue = GLOBAL_QUEUE_BACKGROUND;
    dispatch_async(userStreamQueue, ^{
        
        @autoreleasepool {
            
            NSLog(@"openSearchStream: %@", searchWord);
            
            if ( [D boolForKey:@"USNoAutoLock"] ) [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            
            [weakSelf setOtherTweetsBarItems];
            
            //リクエストパラメータを作成
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            
            if ( searchWord == nil ) {
                
                return;
            }
            
            [TWGetTimeline twitterSearch:searchWord];
            
            [params setObject:searchWord forKey:@"track"];
            
            //UserStream接続リクエストの作成
            TWRequest *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://stream.twitter.com/1.1/statuses/filter.json"]
                                                     parameters:params
                                                  requestMethod:TWRequestMethodPOST];
            
            //アカウントの設定
            [request setAccount:[TWAccounts currentAccount]];
            
            //接続開始
            weakSelf.connection = [NSURLConnection connectionWithRequest:request.signedURLRequest delegate:self];
            [weakSelf.connection start];
            
            [params removeAllObjects];
            
            [weakSelf.searchStreamTemp removeAllObjects];
            [weakSelf startSearchStreamTimer];
            
            // 終わるまでループさせる
            while ( weakSelf.searchStream ) {
                
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            }
        }
    });
}

- (void)closeSearchStream {
    
    NSLog(@"closeSearchStream");
    
    if ( [D boolForKey:@"USNoAutoLock"] ) [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    _searchStream = NO;
    _userStreamFirstResponse = NO;
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
        
        __block __weak TimelineViewController *weakSelf = self;
        
        dispatch_queue_t queue = GLOBAL_QUEUE_DEFAULT;
        dispatch_async(queue, ^{
            
            SYNC_MAIN_QUEUE ^{
                
                NSDictionary *newTweet = [[NSDictionary alloc] initWithDictionary:[weakSelf.searchStreamTemp objectAtIndex:0]];
                [weakSelf.searchStreamTemp removeObjectAtIndex:0];
                
                if ( newTweet != nil ) {
                    
                    [weakSelf checkTimelineCount:YES];
                    
                    //タイムラインに追加
                    weakSelf.timelineArray = [weakSelf.timelineArray appendOnlyNewToTop:@[newTweet] returnMutable:YES];
                    [weakSelf.timeline insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                    
                    //アイコン保存
                    [weakSelf getIconWithTweetArray:[NSMutableArray arrayWithArray:@[newTweet]]];
                }
            });
        });
    }
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    @try {
        
        NSError *error = nil;
        NSMutableDictionary *receiveData =
        [[NSMutableDictionary alloc] initWithDictionary:
         [NSJSONSerialization JSONObjectWithData:data
                                         options:NSJSONReadingMutableLeaves
                                           error:&error]];
        
        //          NSLog(@"receiveData[%d]: %@", receiveData.count, receiveData);
        //          NSLog(@"receiveDataCount: %d", receiveData.count);
        //          NSLog(@"event: %@", [receiveData objectForKey:@"event"]);
        
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
        if ( receiveData.count == 1 && [receiveData objectForKey:@"friends"] != nil ) return;
        
        if ( _searchStream ) {
            
            __block __weak TimelineViewController *weakSelf = self;
            
            ASYNC_MAIN_QUEUE ^{
                
                //SearchStreamの場合
                [weakSelf searchStreamReceiveTweet:[[TWEntities replaceTcoAll:@[receiveData]] objectAtIndex:0]];
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
        _lastUpdateAccount = [TWAccounts currentAccountName];
        
        NSArray *newTweet = @[receiveData];
        
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
                [[[receiveData objectForKey:@"source"] objectForKey:@"screen_name"] isEqualToString:[TWAccounts currentAccountName]] ) {
                
                NSLog(@"UserStream Add Fav Event");
                
                //自分のふぁぼりイベント
                [self userStreamMyAddFavEvent:receiveData];
                
                return;
                
            }else if ( [[receiveData objectForKey:@"event"] isEqualToString:@"unfavorite"] &&
                      [[[receiveData objectForKey:@"source"] objectForKey:@"screen_name"] isEqualToString:[TWAccounts currentAccountName]] ) {
                
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
        
        [sheet showInView:APP_DELEGATE.tabBarController.self.view];
    }
}

#pragma mark - SegmentControl

- (IBAction)changeSegment:(UISegmentedControl *)sender {
    
    NSLog(@"changeSegment[%d]", _timelineSegment.selectedSegmentIndex);
    
    //ピッカー表示中の場合は隠す
    if ( _pickerVisible ) [self hidePicker];
    
    if ( _searchStream ) [self closeSearchStream];
    
    //InReplyTo表示中なら閉じる
    if ( _otherTweetsMode ) {
        
        [self pushCloseOtherTweetsButton:nil];
        
    }else {
        
        //インターネット接続を確認
        if ( ![InternetConnection enable] ) return;
        
        if ( _timelineSegment.selectedSegmentIndex == 0 ) {
            
            //Timelineに切り替わった
            _timelineArray = [TWTweets currentTimeline];
            [_timeline reloadData];
            
            _listMode = NO;
            _timelineControlButton.image = _startImage;
            _timelineControlButton.enabled = YES;
            
            _mentionsArray = BLANK_ARRAY;
            
            [self pushReloadButton:nil];
            
        }else if ( _timelineSegment.selectedSegmentIndex == 1 ) {
            
            _listMode = NO;
            _timelineControlButton.image = _startImage;
            
            //Mentionsに切り替わった
            [TWGetTimeline performSelectorInBackground:@selector(mentions) withObject:nil];
            
        }else if ( _timelineSegment.selectedSegmentIndex == 2 ) {
            
            _listMode = NO;
            _timelineControlButton.image = _startImage;
            
            //Favoritesに切り替わった
            [TWGetTimeline performSelectorInBackground:@selector(favotites) withObject:nil];
            
        }else if ( _timelineSegment.selectedSegmentIndex == 3 ) {
            
            //リスト選択画面を表示
            [self timelineDidListChanged];
        }
    }
    
    __block __weak TimelineViewController *weakSelf = self;
    
    ASYNC_MAIN_QUEUE ^{
        
        if ( weakSelf.timelineSegment.selectedSegmentIndex != 0 &&
            weakSelf.timelineSegment.selectedSegmentIndex != 3 ) {
            
            [weakSelf.grayView start];
        }
    });
}

#pragma mark - ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    __block __weak TimelineViewController *weakSelf = self;
    
    dispatch_queue_t globalQueue = GLOBAL_QUEUE_DEFAULT;
    dispatch_async(globalQueue, ^{
        
        NSString *tweetId = [weakSelf.selectTweet objectForKey:@"id_str"];
        NSString *screenName = [[weakSelf.selectTweet objectForKey:@"user"] objectForKey:@"screen_name"];
        NSString *text = [weakSelf.selectTweet objectForKey:@"text"];
        
        if ( actionSheet.tag == 0 ) {
            
            //NSLog(@"_selectTweet: %@", _selectTweet);
            
            if ( buttonIndex == 0 ) {
                
                APP_DELEGATE.startupUrlList = [text urls];
                
                NSLog(@"startupUrlList[%d]: %@", APP_DELEGATE.startupUrlList.count, APP_DELEGATE.startupUrlList);
                
                if ( APP_DELEGATE.startupUrlList.count == 0 || APP_DELEGATE.startupUrlList == nil ) {
                    
                    //開くべきURLがない
                    
                    SYNC_MAIN_QUEUE ^{
                        
                        [ShowAlert error:@"URLがありません。"];
                    });
                    
                }else {
                    
                    APP_DELEGATE.reOpenUrl = BLANK;
                    
                    //開くべきURLがある場合ブラウザを開く
                    [weakSelf openBrowser];
                }
                
            }else if ( buttonIndex == 1 ) {
                
                SYNC_MAIN_QUEUE ^{
                    
                    if ( weakSelf.otherTweetsMode ) [weakSelf pushCloseOtherTweetsButton:nil];
                    
                    [APP_DELEGATE.postData removeAllObjects];
                    
                    NSString *inReplyToId = [[NSString alloc] initWithString:[weakSelf.selectTweet objectForKey:@"id_str"]];
                    
                    if ( screenName == nil || inReplyToId == nil ) return;
                    
                    [APP_DELEGATE.postData setObject:screenName forKey:@"ScreenName"];
                    [APP_DELEGATE.postData setObject:inReplyToId forKey:@"InReplyToId"];
                    
                    APP_DELEGATE.tabChangeFunction = @"Reply";
                    weakSelf.tabBarController.selectedIndex = 0;
                });
                
            }else if ( buttonIndex == 2 ) {
                
                BOOL favorited = [[weakSelf.selectTweet objectForKey:@"favorited"] boolValue];
                
                if ( favorited ) {
                    
                    [TWEvent unFavorite:tweetId accountIndex:[D integerForKey:@"UseAccount"]];
                    
                }else {
                    
                    [TWEvent favorite:tweetId accountIndex:[D integerForKey:@"UseAccount"]];
                }
                
            }else if ( buttonIndex == 3 ) {
                
                [TWEvent reTweet:tweetId accountIndex:[D integerForKey:@"UseAccount"]];
                
            }else if ( buttonIndex == 4 ) {
                
                [TWEvent favoriteReTweet:tweetId accountIndex:[D integerForKey:@"UseAccount"]];
                
            }else if ( buttonIndex == 5) {
                
                SYNC_MAIN_QUEUE ^{
                    
                    DISPATCH_AFTER(0.1) ^{
                        
                        [weakSelf showPickerView];
                    });
                });
                
            }else if ( buttonIndex == 6 ) {
                
                NSString *hashTag = [[weakSelf.selectTweet stringForKey:@"text"] strWithRegExp:@"((?:\\A|\\z|[\x0009-\x000D\x0020\xC2\x85\u00A0\u1680\u180E\u2000-\u200A\u2028\u2029\u202F\u205F\u3000]|[\\[\\]［］()（）{}｛｝‘’“”\"\'｟｠⸨⸩「」｢｣『』〚〛⟦⟧〔〕❲❳〘〙⟬⟭〈〉〈〉⟨⟩《》⟪⟫<>＜＞«»‹›【】〖〗]|。|、|\\.|!))(#|＃)([a-z0-9_\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\u0400-\u04FF\u0500-\u0527\u1100-\u11FF\u3130-\u3185\uA960-\uA97F\uAC00-\uD7AF\uD7B0-\uD7FF\u30A1-\u30FA\uFF66-\uFF9D\uFF10-\uFF19\uFF21-\uFF3A\uFF41-\uFF5A\u3041-\u3096\u3400-\u4DBF\u4E00-\u9FFF\u020000-\u02A6DF\u02A700-\u02B73F\u02B740-\u02B81F\u02F800-\u02FA1F\u30FC\u3005]*[a-z_\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\u0400-\u04FF\u0500-\u0527\u1100-\u11FF\u3130-\u3185\uA960-\uA97F\uAC00-\uD7AF\uD7B0-\uD7FF\u30A1-\u30FA\uFF66-\uFF9D\uFF10-\uFF19\uFF21-\uFF3A\uFF41-\uFF5A\u3041-\u3096\u3400-\u4DBF\u4E00-\u9FFF\u020000-\u02A6DF\u02A700-\u02B73F\u02B740-\u02B81F\u02F800-\u02FA1F\u30FC\u3005][a-z0-9_\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\u0400-\u04FF\u0500-\u0527\u1100-\u11FF\u3130-\u3185\uA960-\uA97F\uAC00-\uD7AF\uD7B0-\uD7FF\u30A1-\u30FA\uFF66-\uFF9D\uFF10-\uFF19\uFF21-\uFF3A\uFF41-\uFF5A\u3041-\u3096\u3400-\u4DBF\u4E00-\u9FFF\u020000-\u02A6DF\u02A700-\u02B73F\u02B740-\u02B81F\u02F800-\u02FA1F\u30FC\u3005]*)(?=(?:\\A|\\z|[\x0009-\x000D\x0020\xC2\x85\u00A0\u1680\u180E\u2000-\u200A\u2028\u2029\u202F\u205F\u3000]|[\\[\\]［］()（）{}｛｝‘’“”\"\'｟｠⸨⸩「」｢｣『』〚〛⟦⟧〔〕❲❳〘〙⟬⟭〈〉〈〉⟨⟩《》⟪⟫<>＜＞«»‹›【】〖〗]|。|、|\\.|!))"];
                
                if ( [hashTag isNotEmpty] ) {
                    
                    NSMutableDictionary *addDic = [[NSMutableDictionary alloc] initWithDictionary:BLANK_M_DIC];
                    
                    //NGワード設定を読み込む
                    NSMutableArray *ngWordArray = [[NSMutableArray alloc] initWithArray:[D objectForKey:@"NGWord"]];
                    
                    //NGワードに追加
                    [addDic setObject:[DeleteWhiteSpace string:hashTag] forKey:@"Word"];
                    [ngWordArray addObject:addDic];
                    
                    //設定に反映
                    [D setObject:ngWordArray forKey:@"NGWord"];
                    
                    //タイムラインにNGワードを適用
                    weakSelf.timelineArray = [NSMutableArray arrayWithArray:[TWNgTweet ngWord:[NSArray arrayWithArray:weakSelf.timelineArray]]];
                    
                    //タイムラインを保存
                    [TWTweets saveCurrentTimeline:weakSelf.timelineArray];
                    
                    ASYNC_MAIN_QUEUE ^{
                        
                        //リロード
                        [weakSelf.timeline reloadData];
                    });
                    
                }else {
                    
                    ASYNC_MAIN_QUEUE ^{
                        
                        [ShowAlert error:@"ハッシュタグが見つかりませんでした。"];
                    });
                }
                
            }else if ( buttonIndex == 7 ) {
                
                NSMutableDictionary *addDic = [[NSMutableDictionary alloc] initWithDictionary:BLANK_M_DIC];
                
                NSString *clientName = [[NSString alloc] initWithString:[TWParser client:[weakSelf.selectTweet objectForKey:@"source"]]];
                
                //NGクライアント設定を読み込む
                NSMutableArray *ngClientArray = [[NSMutableArray alloc] initWithArray:[D objectForKey:@"NGClient"]];
                
                if ( clientName == nil ) {
                    
                    return;
                }
                
                //NGクライアント
                [addDic setObject:clientName forKey:@"Client"];
                
                [ngClientArray addObject:addDic];
                
                //NSLog(@"ngClientArray: %@", ngClientArray);
                
                [D setObject:ngClientArray forKey:@"NGClient"];
                
                //タイムラインにNGワードを適用
                weakSelf.timelineArray = [NSMutableArray arrayWithArray:[TWNgTweet ngClient:[NSArray arrayWithArray:weakSelf.timelineArray]]];
                
                //タイムラインを保存
                [TWTweets saveCurrentTimeline:weakSelf.timelineArray];
                
                ASYNC_MAIN_QUEUE ^{
                    
                    //リロード
                    [weakSelf.timeline reloadData];
                });
                
            }else if ( buttonIndex == 8 ) {
                
                if ( weakSelf.inReplyTo != nil || weakSelf.inReplyTo.count != 0 ) {
                    
                    [weakSelf setInReplyTo:nil];
                    weakSelf.inReplyTo = [NSMutableArray array];
                }
                
                NSString *inReplyToId = [weakSelf.selectTweet objectForKey:@"in_reply_to_status_id_str"];
                
                if ( [inReplyToId isNotEmpty] ) {
                    
                    NSLog(@"InReplyTo GET START");
                    
                    weakSelf.otherTweetsMode = YES;
                    
                    [weakSelf.inReplyTo addObject:weakSelf.selectTweet];
                    [weakSelf getInReplyToChain:weakSelf.selectTweet];
                    
                }else {
                    
                    ASYNC_MAIN_QUEUE ^{
                        
                        [ShowAlert error:@"InReplyToIDがありません。"];
                    });
                }
                
            }else if ( buttonIndex == 9 ) {
                
                ASYNC_MAIN_QUEUE ^{
                    
                    UIActionSheet *sheet = [[UIActionSheet alloc]
                                            initWithTitle:@"Tweetをコピー"
                                            delegate:weakSelf
                                            cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                            otherButtonTitles:@"STOT形式", @"本文", @"TweetへのURL", @"Tweet内のURL", nil];
                    
                    sheet.tag = 6;
                    [sheet showInView:APP_DELEGATE.tabBarController.self.view];
                });
                
            }else if ( buttonIndex == 10 ) {
                
                if ( [[[weakSelf.selectTweet objectForKey:@"user"] objectForKey:@"screen_name"] isEqualToString:[TWAccounts currentAccountName]] ) {
                    
                    [TWEvent destroy:tweetId];
                    
                }else {
                    
                    ASYNC_MAIN_QUEUE ^{
                        
                        [ShowAlert error:@"自分のTweetではありません。"];
                    });
                }
                
            }else if ( buttonIndex == 11 ) {
                
                if ( [[[weakSelf.selectTweet objectForKey:@"user"] objectForKey:@"screen_name"] isEqualToString:[TWAccounts currentAccountName]] ) {
                    
                    [APP_DELEGATE.postData removeAllObjects];
                    
                    NSString *inReplyToId = [weakSelf.selectTweet objectForKey:@"in_reply_to_status_id_str"];
                    
                    if  ( text == nil || inReplyToId == nil ) return;
                    
                    [APP_DELEGATE.postData setObject:text forKey:@"Text"];
                    [APP_DELEGATE.postData setObject:inReplyToId forKey:@"InReplyToId"];
                    
                    APP_DELEGATE.tabChangeFunction = @"Edit";
                    
                    NSString *tweetId = [weakSelf.selectTweet objectForKey:@"id_str"];
                    [TWEvent destroy:tweetId];
                    
                    ASYNC_MAIN_QUEUE ^{
                        
                        if ( !weakSelf.userStream ) {
                            
                            //削除
                            [weakSelf.timelineArray removeObjectAtIndex:weakSelf.selectRow];
                            
                            //タイムラインを保存
                            [TWTweets saveCurrentTimeline:weakSelf.timelineArray];
                            
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.selectRow inSection:0];
                            [weakSelf.timeline deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                        }
                        
                        weakSelf.tabBarController.selectedIndex = 0;
                    });
                    
                }else {
                    
                    ASYNC_MAIN_QUEUE ^{
                        
                        [ShowAlert error:@"自分のTweetではありません。"];
                    });
                }
                
            }else if ( buttonIndex == 12 ) {
                
                NSMutableArray *ids = [[NSMutableArray alloc] initWithArray:[[weakSelf.selectTweet objectForKey:@"text"] twitterIds]];
                [ids insertObject:[NSString stringWithFormat:@"@%@", [[weakSelf.selectTweet objectForKey:@"user"] objectForKey:@"screen_name"]] atIndex:0];
                
                weakSelf.selectTweetIds = ids.deleteDuplicate;
                
                if ( ids.count == 0 ) return;
                
                ASYNC_MAIN_QUEUE ^{
                    
                    [weakSelf showTwitterAccountSelectActionSheet:weakSelf.selectTweetIds];
                });
            }
            
        }else if ( actionSheet.tag == 1 ) {
            
            [weakSelf openTwitterService:weakSelf.alertSearchUserName serviceType:buttonIndex];
            
        }else if ( actionSheet.tag == 2 ) {
            
            weakSelf.longPressControl = 0;
            
            if ( buttonIndex != 3 && buttonIndex != 4 ) {
                
                ASYNC_MAIN_QUEUE ^{
                    
                    [weakSelf.grayView forceEnd];
                    [weakSelf closeStream];
                    
                    //タイムラインからログを削除
                    [weakSelf.timelineArray removeAllObjects];
                    weakSelf.timelineArray = nil;
                    weakSelf.timelineArray = BLANK_M_ARRAY;
                    
                    [weakSelf.timeline reloadData];
                });
                
                if ( buttonIndex == 0 ) {
                    
                    //タイムラインを保存
                    [TWTweets saveCurrentTimeline:weakSelf.timelineArray];
                    
                }else if ( buttonIndex == 1 || buttonIndex == 2 ) {
                    
                    //各アカウントのログを削除
                    for ( ACAccount *account in [TWAccounts twitterAccounts] ) {
                        
                        [[TWTweets timelines] setObject:[NSMutableArray array] forKey:account.username];
                    }
                    
                    APP_DELEGATE.listId = BLANK;
                    APP_DELEGATE.startupUrlList = nil;
                    APP_DELEGATE.startupUrlList = BLANK_ARRAY;
                    APP_DELEGATE.listAll = nil;
                    APP_DELEGATE.listAll = BLANK_ARRAY;
                    
                    //タイムラインログを削除
                    weakSelf.mentionsArray = nil;
                    weakSelf.mentionsArray = BLANK_ARRAY;
                    [weakSelf.allLists removeAllObjects];
                    weakSelf.allLists = nil;
                    weakSelf.allLists = BLANK_M_DIC;
                    
                    if ( buttonIndex == 2 ) {
                        
                        ASYNC_MAIN_QUEUE ^{
                            
                            weakSelf.accountIconView.image = nil;
                        });
                        
                        CFDictionaryRemoveAllValues(weakSelf.icons);
                        
                        [weakSelf.iconUrls removeAllObjects];
                        weakSelf.iconUrls = nil;
                        weakSelf.iconUrls = BLANK_M_ARRAY;
                        [weakSelf.reqedUser removeAllObjects];
                        weakSelf.reqedUser = nil;
                        weakSelf.reqedUser = BLANK_M_ARRAY;
                        
                        //アイコンファイルを削除
                        [[NSFileManager defaultManager] removeItemAtPath:ICONS_DIRECTORY error:nil];
                        
                        //フォルダを再作成
                        [FILE_MANAGER createDirectoryAtPath:ICONS_DIRECTORY
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:nil];
                    }
                    
                }else if ( buttonIndex == 3 ) {
                    
                    //NG情報を再適用
                    
                    //NG判定を行う
                    ASYNC_MAIN_QUEUE ^{
                        
                        weakSelf.timelineArray = [TWNgTweet ngAll:weakSelf.timelineArray];
                        [TWTweets saveCurrentTimeline:weakSelf.timelineArray];
                        [weakSelf.timeline reloadData];
                    });
                    
                }else {
                    
                    //キャンセル
                    return;
                }
            }
            
        }else if ( actionSheet.tag == 3 ) {
            
            if ( buttonIndex == weakSelf.selectTweetIds.count ) {
                
                NSLog(@"buttonIndex == _selectTweetIds.count");
                
                weakSelf.selectAccount = BLANK;
                weakSelf.selectTweetIds = nil;
                weakSelf.selectTweetIds = BLANK_ARRAY;
                return;
            }
            
            ASYNC_MAIN_QUEUE ^{
                
                weakSelf.selectAccount = [weakSelf.selectTweetIds objectAtIndex:buttonIndex];
                
                if ( [weakSelf.selectAccount hasPrefix:@"@"] ) {
                    
                    //@から始まっている場合取り除く
                    weakSelf.selectAccount = [weakSelf.selectAccount substringFromIndex:1];
                }
                
                //前後の空白文字を取り除く
                weakSelf.selectAccount = [DeleteWhiteSpace string:weakSelf.selectAccount];
                
                weakSelf.alertSearchUserName = weakSelf.selectAccount;
                
                UIActionSheet *sheet = [[UIActionSheet alloc]
                                        initWithTitle:weakSelf.selectAccount
                                        delegate:weakSelf
                                        cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                        otherButtonTitles:@"外部サービスやユーザー情報を開く", @"フォロー関連", nil];
                
                sheet.tag = 4;
                [sheet showInView:APP_DELEGATE.tabBarController.self.view];
            });
            
        }else if ( actionSheet.tag == 4 ) {
            
            if ( buttonIndex == 0 ) {
                
                ASYNC_MAIN_QUEUE ^{
                    
                    [weakSelf pushActionButton:nil];
                });
                
                //後処理
                weakSelf.selectAccount = BLANK;
                weakSelf.selectTweetIds = nil;
                weakSelf.selectTweetIds = BLANK_ARRAY;
                
            }else if ( buttonIndex == 1 ) {
                
                ASYNC_MAIN_QUEUE ^{
                    
                    if ( [weakSelf.selectAccount isEqualToString:[TWAccounts currentAccountName]] ) {
                        
                        [ShowAlert error:@"それはあなたです！"];
                        
                    }else {
                        
                        UIActionSheet *sheet = [[UIActionSheet alloc]
                                                initWithTitle:weakSelf.selectAccount
                                                delegate:weakSelf
                                                cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:@"スパム報告"
                                                otherButtonTitles:@"ブロック", @"ブロック解除", @"フォロー", @"フォロー解除", nil];
                        
                        sheet.tag = 5;
                        [sheet showInView:APP_DELEGATE.tabBarController.self.view];
                    }
                });
            }
            
        }else if ( actionSheet.tag == 5 ) {
            
            if ( buttonIndex == 0 ) {
                
                //スパム報告
                [TWFriends reportSpam:weakSelf.selectAccount];
                
            }else if ( buttonIndex == 1 ) {
                
                //ブロック
                [TWFriends block:weakSelf.selectAccount];
                
            }else if ( buttonIndex == 2 ) {
                
                //ブロック解除
                [TWFriends unblock:weakSelf.selectAccount];
                
            }else if ( buttonIndex == 3 ) {
                
                //フォロー
                [TWFriends follow:weakSelf.selectAccount];
                
            }else if ( buttonIndex == 4 ) {
                
                //フォロー解除
                [TWFriends unfollow:weakSelf.selectAccount];
            }
            
        }else if ( actionSheet.tag == 6 ) {
            
            //公式RTであるか
            if ( [[weakSelf.selectTweet objectForKey:@"retweeted_status"] objectForKey:@"id"] ) {
                
                text = [TWEntities openTcoWithReTweet:weakSelf.selectTweet];
                screenName = [[[weakSelf.selectTweet objectForKey:@"retweeted_status"] objectForKey:@"user"] objectForKey:@"screen_name"];
                tweetId = [[weakSelf.selectTweet objectForKey:@"retweeted_status"] objectForKey:@"id_str"];
            }
            
            if ( buttonIndex == 0 ) {
                
                //STOT形式
                NSString *copyText = [[NSString alloc] initWithFormat:@"%@: %@ [https://twitter.com/%@/status/%@]",
                                      screenName,
                                      text,
                                      screenName,
                                      tweetId];
                [P_BOARD setString:copyText];
                
            }else if ( buttonIndex == 1 ) {
                
                //本文
                [P_BOARD setString:text];
                
            }else if ( buttonIndex == 2 ) {
                
                //URL
                [P_BOARD setString:[NSString stringWithFormat:@"https://twitter.com/%@/status/%@", screenName, tweetId]];
                
            }else if ( buttonIndex == 3 ) {
                
                ASYNC_MAIN_QUEUE ^{
                    
                    //Tweet内のURL
                    weakSelf.tweetInUrls = [text urls];
                    [weakSelf copyTweetInUrl:weakSelf.tweetInUrls];
                });
            }
            
        }else if ( actionSheet.tag >= 7 && actionSheet.tag <= 11 ) {
            
            int cancelIndex = actionSheet.tag - 5;
            
            //キャンセルボタンが押された
            if ( buttonIndex == cancelIndex ) {
                
                NSLog(@"Tweet in URL copy cancel");
                
                weakSelf.tweetInUrls = BLANK_ARRAY;
                
                return;
            }
            
            NSLog(@"Copy URL: %@", [weakSelf.tweetInUrls objectAtIndex:buttonIndex]);
            
            [P_BOARD setString:[weakSelf.tweetInUrls objectAtIndex:buttonIndex]];
            weakSelf.tweetInUrls = BLANK_ARRAY;
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
        [oneUserSheet showInView:APP_DELEGATE.tabBarController.self.view];
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
        [sheet showInView:APP_DELEGATE.tabBarController.self.view];
        sheet = nil;
    }
}

- (void)openTwitterService:(NSString *)username serviceType:(int)serviceType {
    
    if ( username == nil ||
        [username isEqualToString:@""] ) return;
    
    APP_DELEGATE.reOpenUrl = BLANK;
    
    NSString *serviceUrl = nil;
    
    if ( serviceType == 0 ) {
        
        //Twilog
        serviceUrl = [NSString stringWithFormat:@"http://twilog.org/%@", username];
        
    }else if ( serviceType == 1 ) {
        
        __block __weak TimelineViewController *weakSelf = self;
        
        ASYNC_MAIN_QUEUE ^{
            
            weakSelf.alertSearch = nil;
            weakSelf.alertSearch = [[UIAlertView alloc] initWithTitle:@"TwilogSearch"
                                                              message:@"\n"
                                                             delegate:weakSelf
                                                    cancelButtonTitle:@"キャンセル"
                                                    otherButtonTitles:@"確定", nil];
            
            weakSelf.alertSearch.tag = 0;
            
            weakSelf.alertSearchText = nil;
            weakSelf.alertSearchText = [[SSTextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
            [weakSelf.alertSearchText setBackgroundColor:[UIColor whiteColor]];
            weakSelf.alertSearchText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            weakSelf.alertSearchText.delegate = weakSelf;
            weakSelf.alertSearchText.text = BLANK;
            weakSelf.alertSearchText.tag = 0;
            
            [weakSelf.alertSearch addSubview:weakSelf.alertSearchText];
            [weakSelf.alertSearch show];
            [weakSelf.alertSearchText becomeFirstResponder];
        });
        
        return;
        
    }else if ( serviceType == 2 ) {
        
        //favstar
        serviceUrl = [NSString stringWithFormat:@"http://ja.favstar.fm/users/%@/recent", username];
        
    }else if ( serviceType == 3 ) {
        
        //Twitpic
        serviceUrl = [NSString stringWithFormat:@"http://twitpic.com/photos/%@", username];
        
    }else if ( serviceType == 4 ) {
        
        __block __weak TimelineViewController *weakSelf = self;
        
        ASYNC_MAIN_QUEUE ^{
            
            if ( weakSelf.alertSearchType ) {
                
                weakSelf.alertSearch = nil;
                weakSelf.alertSearch = [[UIAlertView alloc] initWithTitle:@"ID入力 (screen_name)"
                                                                  message:@"\n"
                                                                 delegate:weakSelf
                                                        cancelButtonTitle:@"キャンセル"
                                                        otherButtonTitles:@"確定", nil];
                
                weakSelf.alertSearch.tag = 1;
                
                self.alertSearchText = nil;
                weakSelf.alertSearchText = [[SSTextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
                [weakSelf.alertSearchText setBackgroundColor:[UIColor whiteColor]];
                weakSelf.alertSearchText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                weakSelf.alertSearchText.delegate = weakSelf;
                weakSelf.alertSearchText.text = BLANK;
                weakSelf.alertSearchText.tag = 1;
                
                [weakSelf.alertSearch addSubview:weakSelf.alertSearchText];
                [weakSelf.alertSearch show];
                [weakSelf.alertSearchText becomeFirstResponder];
                
            }else {
                
                [TWGetTimeline userTimeline:username];
            }
        });
        
        return;
        
    }else if ( serviceType == 5 ) {
        
        __block __weak TimelineViewController *weakSelf = self;
        
        ASYNC_MAIN_QUEUE ^{
            
            weakSelf.otherTweetsMode = YES;
            
            if ( weakSelf.alertSearchType ) {
                
                weakSelf.alertSearch = nil;
                weakSelf.alertSearch = [[UIAlertView alloc] initWithTitle:@"Twitter Search"
                                                                  message:@"\n"
                                                                 delegate:weakSelf
                                                        cancelButtonTitle:@"キャンセル"
                                                        otherButtonTitles:@"確定", nil];
                
                weakSelf.alertSearch.tag = 2;
                
                weakSelf.alertSearchText = nil;
                weakSelf.alertSearchText = [[SSTextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
                [weakSelf.alertSearchText setBackgroundColor:[UIColor whiteColor]];
                weakSelf.alertSearchText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                weakSelf.alertSearchText.delegate = weakSelf;
                weakSelf.alertSearchText.text = BLANK;
                weakSelf.alertSearchText.tag = 2;
                
                [weakSelf.alertSearch addSubview:weakSelf.alertSearchText];
                [weakSelf.alertSearch show];
                [weakSelf.alertSearchText becomeFirstResponder];
                
            }else {
                
                [TWGetTimeline twitterSearch:[CreateSearchURL encodeWord:username
                                                                encoding:kCFStringEncodingUTF8]];
            }
        });
        
        return;
        
    }else if ( serviceType == 6 ) {
        
        __block __weak TimelineViewController *weakSelf = self;
        
        ASYNC_MAIN_QUEUE ^{
            
            //UserStreamを切断
            if ( username ) [weakSelf closeStream];
            
            if ( weakSelf.timelineSegment.selectedSegmentIndex == 0 ) {
                
                [TWTweets saveCurrentTimeline:weakSelf.timelineArray];
            }
            
            weakSelf.searchStream =YES;
            
            weakSelf.alertSearch = nil;
            weakSelf.alertSearch = [[UIAlertView alloc] initWithTitle:@"Twitter Search(Stream)"
                                                              message:@"\n"
                                                             delegate:weakSelf
                                                    cancelButtonTitle:@"キャンセル"
                                                    otherButtonTitles:@"確定", nil];
            
            weakSelf.alertSearch.tag = 3;
            
            weakSelf.alertSearchText = nil;
            weakSelf.alertSearchText = [[SSTextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
            [weakSelf.alertSearchText setBackgroundColor:[UIColor whiteColor]];
            weakSelf.alertSearchText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            weakSelf.alertSearchText.delegate = weakSelf;
            weakSelf.alertSearchText.text = BLANK;
            weakSelf.alertSearchText.tag = 3;
            
            [weakSelf.alertSearch addSubview:weakSelf.alertSearchText];
            [weakSelf.alertSearch show];
            [weakSelf.alertSearchText becomeFirstResponder];
        });
        
        return;
        
    }else {
        
        return;
    }
    
    APP_DELEGATE.startupUrlList = [NSArray arrayWithObject:serviceUrl];
    
    [self openBrowser];
}

#pragma mark - UIPickerView

- (void)showPickerView {
    
    //NSLog(@"showPickerView");
    
    //表示フラグ
    _pickerVisible = YES;
    APP_DELEGATE.tabBarController.tabBar.userInteractionEnabled = NO;
    
    _pickerBase = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                           SCREEN_HEIGHT,
                                                           SCREEN_WIDTH,
                                                           TOOL_BAR_HEIGHT + PICKER_HEIGHT)];
    _pickerBase.backgroundColor = [UIColor clearColor];
    [APP_DELEGATE.tabBarController.self.view addSubview:_pickerBase];
    
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
    [_eventPicker selectRow:[D integerForKey:@"UseAccount"] inComponent:0 animated:NO];
    
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
    NSString *tweetId = [[NSString alloc] initWithString:[_selectTweet objectForKey:@"id_str"]];
    
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
    
    _pickerVisible = NO;
    APP_DELEGATE.tabBarController.tabBar.userInteractionEnabled = YES;
    
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
                _timelineArray = BLANK_M_ARRAY;
                [_timeline reloadData];
                
                [self openSearchStream: _alertSearchText.text];
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
    
    _webBrowserMode = YES;
    APP_DELEGATE.reOpenUrl = BLANK;
    
    ASYNC_MAIN_QUEUE ^{
        
        WebViewExController *dialog = [[WebViewExController alloc] init];
        dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [APP_DELEGATE.tabBarController.self presentModalViewController:dialog animated:YES];
    });
}

#pragma mark - UITextField

- (BOOL)textFieldShouldReturn:(SSTextField *)sender {
    
    //NSLog(@"Textfield Enter: %@", sender.text);
    
    if ( sender.tag == 0 ) {
        
        NSString *searchURL = [[NSString alloc] initWithString:[CreateSearchURL twilog:[TWAccounts currentAccountName] searchWord:_alertSearchText.text]];
        APP_DELEGATE.startupUrlList = [NSArray arrayWithObject:searchURL];
        
        [self openBrowser];
        
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
            _timelineArray = BLANK_M_ARRAY;
            [_timeline reloadData];
            
            [self openSearchStream:_alertSearchText.text];
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
    
    if ( [[notification.userInfo objectForKey:@"Result"] isEqualToString:@"Success"] ) {
        
        NSDictionary *result = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"Profile"]];
        
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithDictionary:BLANK_M_DIC];
        
        NSString *screenName = [[NSString alloc] initWithString:[result objectForKey:@"screen_name"]];
        NSString *biggerUrl = [[NSString alloc] initWithString:[TWIconBigger normal:[result objectForKey:@"profile_image_url"]]];
        NSString *fileName = [[NSString alloc] initWithString:[biggerUrl lastPathComponent]];
        NSString *searchName = [[NSString alloc] initWithFormat:@"%@_%@", screenName, fileName];
        
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
    
    if ( APP_DELEGATE.postError.count != 0 ) {
        
        APP_DELEGATE.tabChangeFunction = @"PostError";
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
    if ( _userStream ) return;
    
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
        
        __block __weak TimelineViewController *weakSelf = self;
        
        ASYNC_MAIN_QUEUE ^{
            
            //見つかった物を削除
            [weakSelf.timelineArray removeObjectAtIndex:index];
            
            //タイムラインを保存
            [TWTweets saveCurrentTimeline:weakSelf.timelineArray];
            
            [weakSelf.timeline deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
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
    
    APP_DELEGATE.startupUrlList = [NSArray arrayWithObject:[notification.userInfo objectForKey:@"pboardURL"]];
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
    
    if ( _icons == nil ||
        [(__bridge NSMutableDictionary *)_icons count] == 0 ) {
        
        NSLog(@"icon file 0");
        
        //アイコンが1つもない場合は自分のアイコンがないので保存を行う
        [TWEvent getProfile:[TWAccounts currentAccountName]];
        
        return;
    }
    
    NSString *string = BLANK;
    BOOL find = NO;
    
    //NSLog(@"icons key: %@", array);
    
    NSArray *allKeys = [(__bridge NSMutableDictionary *)_icons allKeys];
    
    for ( string in allKeys ) {
        
        if ( [string boolWithRegExp:[NSString stringWithFormat:@"%@_", [TWAccounts currentAccountName]]] ) {
            
            NSLog(@"icon find");
            
            self.accountIconView.image = [UIImage imageWithCGImage:(__bridge CGImageRef)((id)CFDictionaryGetValue(_icons, (CFStringRef)string))];
            
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
        
        _timelineArray = [_allLists objectForKey:APP_DELEGATE.listId];
        
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
        
        if ( [_allLists objectForKey:APP_DELEGATE.listId] != nil ) {
            
            _timelineArray = [_allLists objectForKey:APP_DELEGATE.listId];
            
        }else {
            
            _timelineArray = BLANK_M_ARRAY;
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
        
        _viewWillAppear = YES;
        
        if ( _userStream ) [self closeStream];
        
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
