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

#define TOP_BAR [NSArray arrayWithObjects:actionButton, flexibleSpace, openStreamButton, flexibleSpace, reloadButton, flexibleSpace, postButton, nil]

#define BLANK @""

@implementation TimelineViewController
@synthesize topBar;
@synthesize timeline;
@synthesize flexibleSpace;
@synthesize postButton;
@synthesize openStreamButton;
@synthesize actionButton;
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
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    //投稿完了通知を受け取る設定
    [notificationCenter addObserver:self 
                           selector:@selector(loadTimeline:) 
                               name:@"GetTimeline" 
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
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    d = [NSUserDefaults standardUserDefaults];
    pboard = [UIPasteboard generalPasteboard];

    twAccount = [TWGetAccount getTwitterAccount];
    timelineArray = [NSMutableArray array];
    iconUrls = [NSMutableArray array];
    icons = [NSMutableDictionary dictionary];
    allTimelines = [NSMutableDictionary dictionary];
    sinceIds = [NSMutableDictionary dictionary];
    userStreamAccount = BLANK;
    
    startImage = [UIImage imageNamed:@"ForwardIcon.png"];
    stopImage = [UIImage imageNamed:@"stop.png"];
    openStreamButton.image = startImage;
    
    [topBar setItems:TOP_BAR animated:NO];
    
    userStream = NO;
    openStreamAfter = NO;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
													  initWithTarget:self 
                                                      action:@selector(handleLongPressGesture:)];
	longPressGesture.minimumPressDuration = 0.3;
	[timeline addGestureRecognizer:longPressGesture];
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
    ACAccount *account = [[ACAccount alloc] init];
    
    for ( account in twitterAccounts ) {
    
        [allTimelines setObject:[NSMutableArray array] forKey:account.username];
        [sinceIds setObject:BLANK forKey:account.username];
    }
    
    [self createTimeline];
}

#pragma mark - TimelineMethod

- (void)createTimeline {

    //NSLog(@"createTimeline");
    
    twAccount = [TWGetAccount getTwitterAccount];
    
    if ( [allTimelines objectForKey:twAccount.username] == nil ) {
        
        [allTimelines setObject:[NSMutableArray array] forKey:twAccount.username];
    }
    
    timelineArray = [allTimelines objectForKey:twAccount.username];
    
    appDelegate.sinceId = [sinceIds objectForKey:twAccount.username];
    
    [TWGetTimeline homeTimeline];
}

- (void)loadTimeline:(NSNotification *)center {
    
    //NSLog(@"loadTimeline");
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    dispatch_async( globalQueue, ^{
        dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
        dispatch_sync( syncQueue, ^{
            
            NSString *result = [center.userInfo objectForKey:@"Result"];
            
            if ( [result isEqualToString:@"TimelineSuccess"] ) {
                
                NSMutableArray *newTweet = [center.userInfo objectForKey:@"Timeline"];
                
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
                    
                    //アイコンのURLを取得
                    for ( NSDictionary *dic in timelineArray ) {
                        
                        NSString *screenName = [[dic objectForKey:@"user"] objectForKey:@"screen_name"];
                        NSString *fileName = [[TWIconBigger normal:[[dic objectForKey:@"user"] objectForKey:@"profile_image_url"]] lastPathComponent];
                        NSString *searchName = [NSString stringWithFormat:@"%@_%@", screenName, fileName];
                        
                        if ( [icons objectForKey:searchName] == nil ) {
                            
                            NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
                            [tempDic setObject:[[dic objectForKey:@"user"] objectForKey:@"screen_name"] forKey:@"screen_name"];
                            [tempDic setObject:[TWIconBigger normal:[[dic objectForKey:@"user"] objectForKey:@"profile_image_url"]] forKey:@"profile_image_url"];
                            [iconUrls addObject:tempDic];
                        }
                    }
                    
                    //NSLog(@"iconUrls: %@", iconUrls);
                    
                    //NSLog(@"Duplicate check");
                    //URL重複チェック
                    for ( int i = 0; i < iconUrls.count; i++ ) {
                        
                        NSString *currenString = [TWIconBigger normal:[[iconUrls objectAtIndex:i] objectForKey:@"profile_image_url"]];
                        
                        int index = 0;
                        for ( NSDictionary *temp in iconUrls ) {
                            
                            NSString *tempString = [TWIconBigger normal:[temp objectForKey:@"profile_image_url"]];
                            
                            if ( [tempString isEqualToString:currenString] && index != i ) {
                                
                                [iconUrls removeObjectAtIndex:i];
                                i--;
                                break;
                            }
                            
                            index++;
                        }
                    }
                    
                    //NSLog(@"iconUrls: %@", iconUrls);
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        reloadButton.enabled = YES;
                        
                        //更新アカウントを記憶
                        lastUpdateAccount = twAccount.username;
                        
                        //アイコン保存
                        [ActivityIndicator off];
                        [self saveIcon:iconUrls];
                        [timeline reloadData];
                        
                        //UserStream接続
                        //TODO: 設定でON, OFF
                        if ( !userStream ) [self pushOpenStreamButton:nil];
                    });
                    
                }else {
                    
                    reloadButton.enabled = YES;
                    
                    //UserStream接続
                    //TODO: 設定でON, OFF
                    if ( !userStream ) [self pushOpenStreamButton:nil];
                }
            }
        });
        
        dispatch_release(syncQueue);
    });
}

- (void)saveIcon:(NSMutableArray *)tweetData {
    
    //NSLog(@"saveIcon");
    
    NSURL *URL = nil;
    ASIFormDataRequest *request = nil;
    
    for ( NSDictionary *dic in tweetData ) {
        
        NSString *urlString = [TWIconBigger normal:[dic objectForKey:@"profile_image_url"]];
        
        if ( [urlString isEqualToString:@""] ) continue;
        
        URL = [NSURL URLWithString:urlString];
        request = [[ASIFormDataRequest alloc] initWithURL:URL];
        request.userInfo = [NSDictionary dictionaryWithObject:[dic objectForKey:@"screen_name"] forKey:@"screen_name"];
        
        [request setDelegate:self];
        [request start];
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //TableViewの要素数を返す
	return [timelineArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSLog(@"Cell: %d", indexPath.row);
    
    //TableViewCellを生成
	static NSString *identifier = @"TimelineCell";
	TimelineCell *cell = (TimelineCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	cell.infoLabel.textColor = [UIColor blackColor];
	cell.textLabel.textColor = [UIColor blackColor];
    
	if ( cell == nil ) {
        
		TimelineCellController *controller = [[TimelineCellController alloc] initWithNibName:identifier bundle:nil];
		cell = (TimelineCell *)controller.view;
	}
    
    currentTweet = [timelineArray objectAtIndex:indexPath.row];
    
    NSString *myAccountName = twAccount.username;
    NSString *screenName = [[currentTweet objectForKey:@"user"] objectForKey:@"screen_name"];
    NSString *jstDate = [TWParseTimeline JSTDate:[currentTweet objectForKey:@"created_at"]];
    NSString *clientName = [TWParseTimeline client:[currentTweet objectForKey:@"source"]];
    NSString *infoLabelText = [NSString stringWithFormat:@"%@ - %@ [%@]", screenName, jstDate, clientName];
    BOOL favorited = [[currentTweet objectForKey:@"favorited"] boolValue];
    BOOL retweeted = [[currentTweet objectForKey:@"retweeted"] boolValue];
    
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
        
    }else {
        
        cell.infoLabel.textColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    //Replyの色を変える
    if ( [RegularExpression boolRegExp:cell.textLabel.text regExpPattern:[NSString stringWithFormat:@"@%@", myAccountName]] ) {
        
        cell.infoLabel.textColor = [UIColor redColor];
        cell.textLabel.textColor = [UIColor redColor];
    }
    
    //ReTweerの色を変える
    if ( retweeted ) {
        
        cell.infoLabel.textColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0];
        cell.textLabel.textColor = [UIColor colorWithRed:0.0 green:0.4 blue:0.0 alpha:1.0];
    }
    
    //Favoriteの色を変えて星をつける
    if ( favorited ) {
        
        infoLabelText = [NSMutableString stringWithFormat:@"★%@",infoLabelText];
        cell.infoLabel.textColor = [UIColor colorWithRed:0.5 green:0.4 blue:0.0 alpha:1.0];
        cell.textLabel.textColor = [UIColor colorWithRed:0.5 green:0.4 blue:0.0 alpha:1.0];
    }
    
    cell.infoLabel.text = infoLabelText;
    cell.textLabel.text = [TWEntities replace:currentTweet];
    cell.textLabel.frame = CGRectMake(54, 22, 264, [self heightForContents:cell.textLabel.text]);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルの高さを設定
    currentTweet = [timelineArray objectAtIndex:indexPath.row];
    
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
                                        
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルの選択状態を解除
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = [timelineArray objectAtIndex:indexPath.row];
    NSString *screenName = [[dic objectForKey:@"user"] objectForKey:@"screen_name"];
    NSString *inReplyToId = [dic objectForKey:@"id_str"];
    
    [appDelegate.postData setObject:screenName forKey:@"ScreenName"];
    [appDelegate.postData setObject:inReplyToId forKey:@"InReplyToId"];
    
    appDelegate.tabChangeFunction = @"Reply";
    self.tabBarController.selectedIndex = 0;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//}

#pragma mark - ASIHTTPRequest

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    dispatch_async( globalQueue, ^{
        dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
        dispatch_sync( syncQueue, ^{
    
            NSString *screenName = [request.userInfo objectForKey:@"screen_name"];
            NSString *fileName = [TWIconBigger normal:request.url.absoluteString.lastPathComponent];
            NSData *receiveData = request.responseData;
            
            [ActivityIndicator off];
            [icons setObject:[UIImage imageWithData:receiveData] forKey:[NSString stringWithFormat:@"%@_%@", screenName, fileName]];
            
            int index = 0;
            for ( NSDictionary *tweet in timelineArray ) {
                
                if ( [[[tweet objectForKey:@"user"] objectForKey:@"screen_name"] isEqualToString:screenName] ) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        //TL更新
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                        NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
                        [timeline reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                    });
                }
                
                index++;
            }
        });
        
        dispatch_release(syncQueue);
    });
    
    //取得開始したアイコンURLを削除
    int index = 0;
    BOOL delete = NO;
    for ( NSDictionary *iconUrlsDic in iconUrls ) {
        
        if ( [[iconUrlsDic objectForKey:@"profile_image_url"] isEqualToString:request.url.absoluteString] ) {
            
            delete = YES;
            break;
        }
        
        index++;
    }
    
    if ( delete ) {
        
        [iconUrls removeObjectAtIndex:index];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    //NSLog(@"requestFailed");
    [ActivityIndicator off];
}

#pragma mark - IBAction

- (IBAction)pushPostButton:(UIBarButtonItem *)sender {
    
    appDelegate.tabChangeFunction = @"Post";
    self.tabBarController.selectedIndex = 0;
}

- (IBAction)pushReloadButton:(UIBarButtonItem *)sender {
    
    reloadButton.enabled = NO;
    
    if ( userStream ) [self pushOpenStreamButton:nil];
    
    [self createTimeline];
}

- (IBAction)pushOpenStreamButton:(UIBarButtonItem *)sender {
    
    
    if ( !userStream ) {
    
        //UserStream未接続
        userStream = YES;
        openStreamButton.enabled = NO;
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
                            otherButtonTitles:@"Twilog", @"favstar", nil];
    
    sheet.tag = 1;
    
    [sheet showInView:appDelegate.tabBarController.self.view];
}

#pragma mark - UserStream

- (void)openStream {
    
    //NSLog(@"openStream");
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    dispatch_async( globalQueue, ^{
        dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
        dispatch_sync( syncQueue, ^{
            
            twAccount = [TWGetAccount getTwitterAccount];
            
            //ユーザーを記憶
            userStreamAccount = twAccount.username;
            
            TWRequest *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://userstream.twitter.com/2/user.json"] 
                                                     parameters:nil 
                                                  requestMethod:TWRequestMethodPOST];
            
            [request setAccount:twAccount];
            
            self.connection = [NSURLConnection connectionWithRequest:request.signedURLRequest delegate:self];
            [self.connection start];
            
            // 終わるまでループさせる
            while( userStream ) {
                
                [NSThread sleepForTimeInterval:0.001f];
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        });
        
        dispatch_release(syncQueue);
    });
}

- (void)closeStream {
    
    //NSLog(@"closeStream");
    
    userStream = NO;
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
                NSMutableDictionary *receiveData = (NSMutableDictionary *)[NSJSONSerialization JSONObjectWithData:data
                                                                                                          options:NSJSONReadingMutableLeaves 
                                                                                                            error:&error];
                
//                NSLog(@"receiveData(%d): %@", receiveData.count, receiveData);
//                NSLog(@"event: %@", [receiveData objectForKey:@"event"]);
                
                //エラーは無視
                if ( error ) return;
                
                //Tweetのレスポンスは20
                if ( receiveData.count != 1 ) {
                    
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
                                    [timeline reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                                });
                                
                                break;
                            }
                            
                            index++;
                        }
                        
                        return;
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        //タイムラインに追加
                        [timelineArray insertObject:receiveData atIndex:0];
                        
                        //タイムラインを保存
                        [allTimelines setObject:timelineArray forKey:twAccount.username];
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                        NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];
                        [timeline insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
                    });
                        
                    //IDを記憶
                    if ( ![[receiveData objectForKey:@"id_str"] isEqualToString:BLANK] ) {
                        
                        [sinceIds setObject:[receiveData objectForKey:@"id_str"] forKey:twAccount.username];
                    }
                    
                    //アイコンのURLを取得
                    NSString *screenName = [[receiveData objectForKey:@"user"] objectForKey:@"screen_name"];
                    NSString *fileName = [TWIconBigger normal:[[[currentTweet objectForKey:@"user"] objectForKey:@"profile_image_url"] lastPathComponent]];
                    NSString *searchName = [NSString stringWithFormat:@"%@_%@", screenName, fileName];
                    
                    if ( [icons objectForKey:searchName] == nil ) {
                        
                        if ( [EmptyCheck check:[[receiveData objectForKey:@"user"] objectForKey:@"screen_name"]] ) {
                            
                            NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
                            [tempDic setObject:screenName forKey:@"screen_name"];
                            [tempDic setObject:[TWIconBigger normal:[[receiveData objectForKey:@"user"] objectForKey:@"profile_image_url"]] forKey:@"profile_image_url"];
                            [iconUrls addObject:tempDic];
                        }
                    }
                    
                    //URL重複チェック
                    for ( int i = 0; i < iconUrls.count; i++ ) {
                        
                        NSString *currenString = [TWIconBigger normal:[[iconUrls objectAtIndex:i] objectForKey:@"profile_image_url"]];
                        
                        int index = 0;
                        for ( NSDictionary *temp in iconUrls ) {
                            
                            if ( [[temp objectForKey:@"profile_image_url"] isEqualToString:currenString] && index != i ) {
                                
                                [iconUrls removeObjectAtIndex:i];
                                i--;
                                break;
                            }
                            
                            index++;
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        
                        //更新アカウントを記憶
                        lastUpdateAccount = twAccount.username;
                        
                        //アイコン保存
                        [ActivityIndicator on];
                        [self saveIcon:iconUrls];
                    });
                    
                }else {
                    
                    if ( [[receiveData objectForKey:@"event"] isEqualToString:@"favorite"] ) {
                        
                        NSMutableDictionary *favDic = [NSMutableDictionary dictionary];
                        
                        //user
                        NSMutableDictionary *user = [NSMutableDictionary dictionary];
                        [user setObject:[[receiveData objectForKey:@"source"] objectForKey:@"screen_name"] forKey:@"screen_name"];
                        [user setObject:[[receiveData objectForKey:@"source"] objectForKey:@"profile_image_url"] forKey:@"profile_image_url"];
                        [user setObject:BLANK forKey:@"id_str"];
                        
                        //ふぁぼられたTweet
                        NSString *targetText = [[receiveData objectForKey:@"target_object"] objectForKey:@"text"];
                        
                        //辞書に追加
                        [favDic setObject:@"YES" forKey:@"FavEvent"];
                        [favDic setObject:user forKey:@"user"];
                        [favDic setObject:[[receiveData objectForKey:@"target_object"] objectForKey:@"created_at"] forKey:@"created_at"];
                        [favDic setObject:[[receiveData objectForKey:@"target_object"] objectForKey:@"source"] forKey:@"source"];
                        [favDic setObject:[NSString stringWithFormat:@"お気に入りに追加されました\n%@", targetText] forKey:@"text"];
                        
                        //NSLog(@"favDic: %@", favDic);
                        
                        NSString *screenName = [[favDic objectForKey:@"user"] objectForKey:@"screen_name"];
                        NSString *fileName = [[TWIconBigger normal:[[favDic objectForKey:@"user"] objectForKey:@"profile_image_url"]] lastPathComponent];
                        NSString *searchName = [NSString stringWithFormat:@"%@_%@", screenName, fileName];
                        
                        if ( [icons objectForKey:searchName] == nil ) {
                            
                            NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
                            [tempDic setObject:[[favDic objectForKey:@"user"] objectForKey:@"screen_name"] forKey:@"screen_name"];
                            [tempDic setObject:[TWIconBigger normal:[[favDic objectForKey:@"user"] objectForKey:@"profile_image_url"]] forKey:@"profile_image_url"];
                            [iconUrls addObject:tempDic];
                            
                            [self saveIcon:iconUrls];
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
     
        openStreamButton.enabled = YES;
        openStreamButton.image = stopImage;
        
    }else {
        
        userStream = NO;
        openStreamButton.enabled = YES;
        openStreamButton.image = startImage;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    //NSLog(@"connectionDidFinishLoading:");
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    //NSLog(@"didFailWithError:%@", error);
    openStreamButton.enabled = YES;
    [self closeStream];
}

#pragma mark - GestureRecognizer

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)sender {
    
    CGPoint swipeLocation = [sender locationInView:timeline];
    NSIndexPath *swipedIndexPath = [timeline indexPathForRowAtPoint:swipeLocation];
    selectRow = swipedIndexPath.row;

    if ( longPressControl == 0 ) {
        
        if ( !actionSheetVisible ) {
            
            actionSheetVisible = YES;
            
            UIActionSheet *sheet = [[UIActionSheet alloc]
                                    initWithTitle:@"機能選択"
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:@"URLを開く", @"Favorite/UnFavorite", @"ReTweet", @"Fav+RT", nil];
            
            sheet.tag = 0;
            
            [sheet showInView:appDelegate.tabBarController.self.view];
        }
        
        longPressControl = 1;
        
    }else {
        
        longPressControl = 0;
    }
}

- (IBAction)swipeTimelineRight:(UISwipeGestureRecognizer *)sender {
    
    //NSLog(@"swipeTimelineRight");
    
    int num = [d integerForKey:@"UseAccount"] - 1;
    
    if ( num < 0 ) return;
    
    int accountCount = [TWGetAccount getTwitterAccountCount] - 1;
    
    //NSLog(@"num: %d accountCount: %d", num, accountCount);
    
    if ( accountCount >= num ) {
     
        if ( userStream ) [self closeStream];
        
        //NSLog(@"ChangeAccount: %@", twAccount.username);
        
        twAccount = [TWGetAccount getTwitterAccount:num];
        [d setInteger:num forKey:@"UseAccount"];
        
        //NSLog(@"%@", twAccount.username);
        
        timelineArray = [allTimelines objectForKey:twAccount.username];
        
        [timeline reloadData];
        [self createTimeline];
    }
}

- (IBAction)swipeTimelineLeft:(UISwipeGestureRecognizer *)sender {
    
    //NSLog(@"swipeTimelineLeft");
    
    int num = [d integerForKey:@"UseAccount"] + 1;
    int accountCount = [TWGetAccount getTwitterAccountCount] - 1;
    
    //NSLog(@"num: %d accountCount: %d", num, accountCount);
    
    if ( accountCount >= num ) {
        
        if ( userStream ) [self closeStream];
        
        //NSLog(@"ChangeAccount: %@", twAccount.username);
        
        twAccount = [TWGetAccount getTwitterAccount:num];
        [d setInteger:num forKey:@"UseAccount"];
        
        //NSLog(@"%@", twAccount.username);
        
        timelineArray = [allTimelines objectForKey:twAccount.username];
        
        [timeline reloadData];
        [self createTimeline];
    }
}

#pragma mark - ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( actionSheet.tag == 0 ) {
        
        longPressControl = 0;
        actionSheetVisible = NO;
        
        NSDictionary *dic = [timelineArray objectAtIndex:selectRow];
        NSString *tweetId = [[timelineArray objectAtIndex:selectRow] objectForKey:@"id_str"];
        
        if ( buttonIndex == 0 ) {
            
            NSString *text = [TWEntities replace:dic];
            [pboard setString:text];
            [d setObject:BLANK forKey:@"LastOpendPasteBoardURL"];
            appDelegate.tlUrlOpenMode = [NSNumber numberWithInt:1];
            
            appDelegate.tabChangeFunction = @"UrlOpen";
            self.tabBarController.selectedIndex = 0;
            
        }else if ( buttonIndex == 1 ) {
            
            BOOL favorited = [[dic objectForKey:@"favorited"] boolValue];
            
            if ( favorited ) {
                
                [TWEvent unFavorite:tweetId];
                
            }else {
                
                [TWEvent favorite:tweetId];
            }
            
        }else if ( buttonIndex == 2 ) {
            
            [TWEvent reTweet:tweetId];
            
        }else if ( buttonIndex == 3 ) {
            
            [TWEvent favoriteReTweet:tweetId];
        }
    
    }else if ( actionSheet.tag == 1 ) {
        
        NSString *serviceUrl = nil;
        
        if ( buttonIndex == 0 ) {
        
            //Twilog
            serviceUrl = [NSString stringWithFormat:@"http://twilog.org/%@", twAccount.username];
            
        }else if ( buttonIndex == 1 ) {
        
            //favstar
            serviceUrl = [NSString stringWithFormat:@"http://ja.favstar.fm/users/%@/recent", twAccount.username];
            
        }else {
            
            return;
        }
        
        [pboard setString:serviceUrl];
        [d setObject:BLANK forKey:@"LastOpendPasteBoardURL"];
        appDelegate.tlUrlOpenMode = [NSNumber numberWithInt:1];
        
        appDelegate.tabChangeFunction = @"UrlOpen";
        self.tabBarController.selectedIndex = 0;
    }
}

#pragma mark - Notification

- (void)enterBackground:(NSNotification *)notification {
    
    //NSLog(@"enterBackground");
    if ( userStream ) [self closeStream];
}

- (void)becomeActive:(NSNotification *)notification {
    
    if ( !userStream ) [TWGetTimeline homeTimeline];
}

#pragma mark - View

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //NSLog(@"viewWillAppear");
    
    ACAccount *account = [TWGetAccount getTwitterAccount];
    
    if ( userStream && ![userStreamAccount isEqualToString:account.username] ) {
        
        //NSLog(@"UserStream close");
        
        [self closeStream];
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
    [super viewDidUnload];
}

- (void)dealloc {

}

@end
