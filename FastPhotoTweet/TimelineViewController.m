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
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    d = [NSUserDefaults standardUserDefaults];
    pboard = [UIPasteboard generalPasteboard];

    twAccount = [TWGetAccount getTwitterAccount];
    timelineArray = [NSMutableArray array];
    iconUrls = [NSMutableArray array];
    icons = [NSMutableDictionary dictionary];
    allTimelines = [NSMutableDictionary dictionary];
    userStreamUser = BLANK;
    
    startImage = [UIImage imageNamed:@"ForwardIcon.png"];
    stopImage = [UIImage imageNamed:@"stop.png"];
    openStreamButton.image = startImage;
    
    [topBar setItems:TOP_BAR animated:NO];
    
    userStream = NO;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
													  initWithTarget:self 
                                                      action:@selector(handleLongPressGesture:)];
	longPressGesture.minimumPressDuration = 0.3;
	[timeline addGestureRecognizer:longPressGesture];
    
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
                    
                    appDelegate.sinceId = [[newTweet objectAtIndex:0] objectForKey:@"id_str"];
                    
                    int index = 0;
                    for ( id tweet in newTweet ) {
                        
                        [timelineArray insertObject:tweet atIndex:index];
                        index++;
                    }
                    
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
                        
                        //アイコン保存
                        [ActivityIndicator on];
                        [self saveIcon:iconUrls];
                        [timeline reloadData];
                    });
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
    
    NSString *screenName = [[currentTweet objectForKey:@"user"] objectForKey:@"screen_name"];
    NSString *jstDate = [TWParseTimeline date:[currentTweet objectForKey:@"created_at"]];
    NSString *clientName = [TWParseTimeline client:[currentTweet objectForKey:@"source"]];
    
    NSString *infoLabelText = [NSString stringWithFormat:@"%@ - %@ [%@]", screenName, jstDate, clientName];
    
    cell.infoLabel.text = infoLabelText;
    cell.textLabel.text = [TWEntities replace:currentTweet];
    
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
    
    NSString *screenName = [request.userInfo objectForKey:@"screen_name"];
    NSString *fileName = [TWIconBigger normal:request.url.absoluteString.lastPathComponent];
    NSData *receiveData = request.responseData;
    
    [ActivityIndicator off];
    [icons setObject:[UIImage imageWithData:receiveData] forKey:[NSString stringWithFormat:@"%@_%@", screenName, fileName]];
    [timeline reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
    NSLog(@"requestFailed");
}

#pragma mark - IBAction

- (IBAction)pushPostButton:(UIBarButtonItem *)sender {
    
    appDelegate.tabChangeFunction = @"Post";
    self.tabBarController.selectedIndex = 0;
}

- (IBAction)pushReloadButton:(UIBarButtonItem *)sender {
    
    if ( userStream ) [self pushOpenStreamButton:nil];
    
    [self createTimeline];
}

- (IBAction)pushOpenStreamButton:(UIBarButtonItem *)sender {
    
    
    if ( !userStream ) {
    
        //UserStream未接続
        userStream = YES;
        openStreamButton.image = stopImage;
        [self openStream];
        
    }else {
        
        //UserStream接続済み
        userStream = NO;
        openStreamButton.image = startImage;
        [self.connection cancel];
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
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    dispatch_async( globalQueue, ^{
        dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
        dispatch_sync( syncQueue, ^{
            
            twAccount = [TWGetAccount getTwitterAccount];
            
            //ユーザーを記憶
            userStreamUser = twAccount.username;
            
            TWRequest *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://userstream.twitter.com/2/user.json"] 
                                                     parameters:nil 
                                                  requestMethod:TWRequestMethodPOST];
            
            [request setAccount:twAccount];
            
            self.connection = [NSURLConnection connectionWithRequest:request.signedURLRequest delegate:self];
            [self.connection start];
            
            // 終わるまでループさせる
            while( userStream ) {
                
                [NSThread sleepForTimeInterval:0.05f];
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        });
        
        dispatch_release(syncQueue);
    });
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
    dispatch_async( globalQueue, ^{
        dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
        dispatch_sync( syncQueue, ^{
            
            @try {
                
                NSError *error = nil;
                NSMutableArray *receiveData = (NSMutableArray *)[NSJSONSerialization JSONObjectWithData:data
                                                                                                options:NSJSONReadingMutableLeaves 
                                                                                                  error:&error];
                
                //エラーは無視
                if ( error ) return;
                
                //Tweetのレスポンスは20
                if ( receiveData.count != 1 ) {
                    
                    //タイムラインに追加
                    [timelineArray insertObject:receiveData atIndex:0];
                    
                    //タイムラインを保存
                    [allTimelines setObject:timelineArray forKey:twAccount.username];
                    
                    //アイコンのURLを取得
                    NSDictionary *dic = (NSDictionary *)receiveData;
                    NSString *screenName = [[dic objectForKey:@"user"] objectForKey:@"screen_name"];
                    NSString *fileName = [TWIconBigger normal:[[[currentTweet objectForKey:@"user"] objectForKey:@"profile_image_url"] lastPathComponent]];
                    NSString *searchName = [NSString stringWithFormat:@"%@_%@", screenName, fileName];
                    
                    if ( [icons objectForKey:searchName] == nil ) {
                        
                        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
                        [tempDic setObject:[[dic objectForKey:@"user"] objectForKey:@"screen_name"] forKey:@"screen_name"];
                        [tempDic setObject:[TWIconBigger normal:[[dic objectForKey:@"user"] objectForKey:@"profile_image_url"]] forKey:@"profile_image_url"];
                        [iconUrls addObject:tempDic];
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
                        
                        //アイコン保存
                        [ActivityIndicator on];
                        [self saveIcon:iconUrls];
                        [timeline reloadData];
                    });
                }
                
            }@catch ( NSException *e ) { /* 例外は投げ捨てる物 */ }
        });
        
        dispatch_release(syncQueue);
    });
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSLog(@"didReceiveResponse:%d, %lld", httpResponse.statusCode, response.expectedContentLength);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"connectionDidFinishLoading:");
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"didFailWithError:%@", error);
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
                                    otherButtonTitles:@"URLを開く", nil];
            
            sheet.tag = 0;
            
            [sheet showInView:appDelegate.tabBarController.self.view];
        }
        
        longPressControl = 1;
        
    }else {
        
        longPressControl = 0;
    }
}

#pragma mark - ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( actionSheet.tag == 0 ) {
        
        longPressControl = 0;
        actionSheetVisible = NO;
        
        if ( buttonIndex == 0 ) {
            
            NSDictionary *dic = [timelineArray objectAtIndex:selectRow];
            NSString *text = [TWEntities replace:dic];
            [pboard setString:text];
            [d setObject:BLANK forKey:@"LastOpendPasteBoardURL"];
            appDelegate.tlUrlOpenMode = [NSNumber numberWithInt:1];
            
            appDelegate.tabChangeFunction = @"UrlOpen";
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
    }
}

#pragma mark - View

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    ACAccount *account = [TWGetAccount getTwitterAccount];
    
    if ( userStream && ![userStreamUser isEqualToString:account.username] ) {
        
        //NSLog(@"UserStream close");
        
        [self pushOpenStreamButton:nil];
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
