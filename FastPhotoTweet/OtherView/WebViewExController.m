//
//  WebViewExController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/05/02.
//

/////////////////////////////
//////// ARC ENABLED ////////
/////////////////////////////

#import "WebViewExController.h"

#define TOP_BAR [NSArray arrayWithObjects:urlField, searchField, searchButton, nil]
#define BOTTOM_BAR [NSArray arrayWithObjects:closeButton, flexibleSpace, composeButton, flexibleSpace, reloadButton, flexibleSpace, backButton, flexibleSpace, forwardButton, flexibleSpace, bookmarkButton, flexibleSpace, menuButton, nil]
#define EXTENSIONS [NSArray arrayWithObjects:@"zip", @"mp4", @"mov", @"m4a", @"rar", @"dmg", @"deb", nil]

@implementation WebViewExController
@synthesize wv;
@synthesize topBar;
@synthesize urlField;
@synthesize searchField;
@synthesize bottomBar;
@synthesize closeButton;
@synthesize reloadButton;
@synthesize backButton;
@synthesize forwardButton;
@synthesize composeButton;
@synthesize menuButton;
@synthesize flexibleSpace;
@synthesize bookmarkButton;
@synthesize bytesLabel;
@synthesize progressBar;
@synthesize downloadCancelButton;
@synthesize searchButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self ) {
        
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        startupUrlList = appDelegate.startupUrlList;
        urlList = BLANK_ARRAY;
        
        if ( startupUrlList == nil ) [d objectForKey:@"HomePageURL"];
        
        retina4InchOffset = 0;
        
        if ( SCREEN_HEIGHT == 548 ) {
            
            NSLog(@"Retine 4inch");
            retina4InchOffset = 88;
        }
    }
    
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    [self setViewSize];
    
    NSLog(@"retina4InchOffset: %d", retina4InchOffset);
    
    pboard = [UIPasteboard generalPasteboard];
    
    grayView = [[GrayView alloc] init];
    [wv addSubview:grayView];
    
    reloadButtonImage = [UIImage imageNamed:@"reload.png"];
    stopButtonImage = [UIImage imageNamed:@"stop.png"];
    
    openBookmark = NO;
    fullScreen = NO;
    editing = NO;
    downloading = NO;
    loading = NO;
    
    //アプリがアクティブになった場合の通知を受け取る設定
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(becomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(pboardNotification:)
                               name:@"pboardNotification"
                             object:nil];
    
    notificationCenter = nil;
    
    d = [NSUserDefaults standardUserDefaults];

    searchField.clearsOnBeginEditing = [d boolForKey:@"ClearBrowserSearchField"];
    
    accessURL = BLANK;
    
    [self setSearchEngine];
    
    //ツールバーにボタンをセット
    [bottomBar setItems:BOTTOM_BAR animated:NO];
    
    appDelegate.browserOpenMode = YES;
    
    //URLSchemeダウンロード判定
    if ( [EmptyCheck check:appDelegate.urlSchemeDownloadUrl] ) {
        
        [self requestStart:appDelegate.urlSchemeDownloadUrl];
        
        return;
    }
    
    if ( appDelegate.pcUaMode ||
        [EmptyCheck string:appDelegate.reOpenUrl] ) {
        
        [wv loadRequestWithString:appDelegate.reOpenUrl];
        
        appDelegate.reOpenUrl = BLANK;
        appDelegate.pcUaMode = NO;
        
    }else {
     
        [self selectOpenUrl];
    }
}

- (void)selectOpenUrl {
    
    //NSLog(@"startupUrlList: %@", startupUrlList);
    //NSLog(@"pboard: %@", [RegularExpression urls:pboard.string]);
    
    if ( appDelegate.tabBarController.selectedIndex == 1 ) {
        
        //NSLog(@"タイムラインから開いている場合はスタートアップURLを優先");
        
        [self selectUrl];
        
    }else {
        
        //NSLog(@"タイムラインから開かれていない場合");
        
        if ( [d boolForKey:@"OpenPasteBoardURL"] ) {
            
            //NSLog(@"ペーストボードからURLを開く設定が有効な場合: %@", [d objectForKey:@"LastOpendPasteBoardURL"]);
            
            //ペーストボードのURLを取得
            urlList = [RegularExpression urls:pboard.string];
            
            if ( startupUrlList.count == 1 && urlList.count == 0 ) {
                
                //NSLog(@"ペーストボードにURLが存在しない場合");
                
                [wv loadRequestWithString:[startupUrlList objectAtIndex:0]];
                
            }else if ( startupUrlList.count == 0 && urlList.count == 1 ) {
                
                //NSLog(@"スタートアップURLがなく、ペーストボードにURLが1つ存在する場合");
                
                if ( [[urlList objectAtIndex:0] isEqualToString:[d objectForKey:@"LastOpendPasteBoardURL"]] ) {
                
                    [wv loadRequestWithString:[d objectForKey:@"HomePageURL"]];
                    
                }else {
                    
                    [wv loadRequestWithString:[urlList objectAtIndex:0]];
                    [d setObject:[urlList objectAtIndex:0] forKey:@"LastOpendPasteBoardURL"];
                }
                
            }else if ( startupUrlList.count == 1 && urlList.count == 1 ) {
                
                //NSLog(@"ペーストボードにURLが1つ存在する場合");
                
                if ( [[startupUrlList objectAtIndex:0] isEqualToString:[d objectForKey:@"HomePageURL"]] ) {
                    
                    //NSLog(@"スタートアップURLがホームページだった場合はペーストボードのURLを優先して判定");
                    
                    if ( [[urlList objectAtIndex:0] isEqualToString:[d objectForKey:@"LastOpendPasteBoardURL"]] ) {
                        
                        //NSLog(@"直前にペーストボードから開いたURLだった場合はスタートアップURLを開く");
                        
                        [wv loadRequestWithString:[startupUrlList objectAtIndex:0]];
                        
                    }else {
                        
                        //NSLog(@"直前にペーストボードから開いたURLではない場合開く");
                        
                        [wv loadRequestWithString:[urlList objectAtIndex:0]];
                        [d setObject:[urlList objectAtIndex:0] forKey:@"LastOpendPasteBoardURL"];
                    }
                    
                }else {
                    
                    //NSLog(@"スタートアップURLがホームページのURLではなかった場合選択して表示");
                    
                    if ( [[startupUrlList objectAtIndex:0] isEqualToString:[urlList objectAtIndex:0]] ) {
                        
                        [wv loadRequestWithString:[startupUrlList objectAtIndex:0]];
                        
                    }else {
                        
                        actionSheetNo = 15;
                        
                        UIActionSheet *sheet = [[UIActionSheet alloc]
                                                initWithTitle:@"URL展開選択"
                                                delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:nil
                                                otherButtonTitles:@"アプリ指定URLを開く", @"ペーストボードから開く", nil];
                        [sheet showInView:self.view];
                    }
                }
                
            }else if ( startupUrlList.count == 1 && urlList.count > 1 ) {
                
                //NSLog(@"ペーストボードにURLが複数個ある場合");
                
                if ( [[startupUrlList objectAtIndex:0] isEqualToString:[d objectForKey:@"HomePageURL"]] ) {
                    
                    //NSLog(@"スタートアップURLがホームページだった場合はペーストボードのURLを優先して判定");
                    
                    startupUrlList = urlList;
                    [self selectUrl];
                    
                }else {
                    
                    //NSLog(@"スタートアップURLがホームページではなかった場合、確認を表示");
                    actionSheetNo = 15;
                    
                    UIActionSheet *sheet = [[UIActionSheet alloc]
                                            initWithTitle:@"URL展開選択"
                                            delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            destructiveButtonTitle:nil
                                            otherButtonTitles:@"アプリ指定URLを開く", @"ペーストボードから開く", nil];
                    [sheet showInView:self.view];
                }
                
            }else if ( startupUrlList.count > 1 && urlList.count == 0 ) {
                
                //NSLog(@"スタートアップURLが複数個あり、ペーストボードにURLがない場合");
                
                //URLを選択して表示
                [self selectUrl];
                
            }else if ( startupUrlList.count > 1 && urlList.count != 0 ) {
                
                //NSLog(@"スタートアップURLとペーストボードにURLが複数個ある場合");
                
                actionSheetNo = 15;
                
                UIActionSheet *sheet = [[UIActionSheet alloc]
                                        initWithTitle:@"URL展開選択"
                                        delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                        otherButtonTitles:@"アプリ指定URLを開く", @"ペーストボードから開く", nil];
                [sheet showInView:self.view];
                
            }else {
                
                //NSLog(@"その他の場合");
                
                [wv loadRequestWithString:[d objectForKey:@"HomePageURL"]];
            }
            
        }else {
            
            //NSLog(@"ペーストボードからURLを開く設定が無効な場合");
            
            if ( startupUrlList.count == 1 ) {
                
                //NSLog(@"URLが1つの場合は開く");
                [wv loadRequestWithString:[startupUrlList objectAtIndex:0]];
                
            }else if ( startupUrlList.count > 1 ) {
                
                //NSLog(@"URLが複数個の場合は選択して開く");
                [self selectUrl];
                
            }else {
                
                //NSLog(@"その他の場合はホームページを開く");
                [wv loadRequestWithString:[d objectForKey:@"HomePageURL"]];
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //NSLog(@"viewWillAppear");
    
    if ( openBookmark ) {
        
        openBookmark = NO;
        
        if ( [EmptyCheck check:appDelegate.bookmarkUrl] ) {
            
            //ブックマークで選択したURLを読み込み
            [wv loadRequestWithString:appDelegate.bookmarkUrl];
            appDelegate.bookmarkUrl = BLANK;
        }
    }
}

- (void)selectUrl {
    
    UIActionSheet *sheet;
    
    if (startupUrlList.count == 1 ) {
        
        [wv loadRequestWithString:[startupUrlList objectAtIndex:0]];
        
    }else if (startupUrlList.count == 2 ) {
        
        actionSheetNo = 2;
        
        sheet = [[UIActionSheet alloc]
                                initWithTitle:@"URL選択"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:[startupUrlList objectAtIndex:0], 
                                [startupUrlList objectAtIndex:1], nil];
        [sheet showInView:self.view];
        
    }else if (startupUrlList.count == 3 ) {
        
        actionSheetNo = 3;
        
        sheet = [[UIActionSheet alloc]
                                initWithTitle:@"URL選択"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:[startupUrlList objectAtIndex:0], 
                                [startupUrlList objectAtIndex:1], 
                                [startupUrlList objectAtIndex:2], nil];
        [sheet showInView:self.view];
        
    }else if (startupUrlList.count == 4 ) {
        
        actionSheetNo = 4;
        
        sheet = [[UIActionSheet alloc]
                                initWithTitle:@"URL選択"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:[startupUrlList objectAtIndex:0], 
                                [startupUrlList objectAtIndex:1], 
                                [startupUrlList objectAtIndex:2], 
                                [startupUrlList objectAtIndex:3], nil];
        [sheet showInView:self.view];
        
    }else if (startupUrlList.count == 5 ) {
        
        actionSheetNo = 5;
        
        sheet = [[UIActionSheet alloc]
                                initWithTitle:@"URL選択"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:[startupUrlList objectAtIndex:0], 
                                [startupUrlList objectAtIndex:1], 
                                [startupUrlList objectAtIndex:2], 
                                [startupUrlList objectAtIndex:3],
                                [startupUrlList objectAtIndex:4], nil];
        [sheet showInView:self.view];
        
    }else if (startupUrlList.count >= 6 ) {
        
        actionSheetNo = 6;
        
        sheet = [[UIActionSheet alloc]
                                initWithTitle:@"URL選択"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:[startupUrlList objectAtIndex:0], 
                                [startupUrlList objectAtIndex:1], 
                                [startupUrlList objectAtIndex:2], 
                                [startupUrlList objectAtIndex:3],
                                [startupUrlList objectAtIndex:4],
                                [startupUrlList objectAtIndex:5], nil];
        [sheet showInView:self.view];
    }
    
    sheet = nil;
}

- (void)pboardNotification:(NSNotification *)notification {
    
    NSLog(@"Browser pboardNotification: %@", notification.userInfo);
    
    //ブラウザを開いていない場合は終了
    if ( !appDelegate.browserOpenMode ) return;
    
    //NSLog(@"Browser pboardNotification: %@", notification.userInfo);
    
    [wv loadRequestWithString:[notification.userInfo objectForKey:@"pboardURL"]];
}

- (void)becomeActive:(NSNotification *)notification {
    
    if ( appDelegate.willResignActiveBrowser ) {
        
        appDelegate.willResignActiveBrowser = NO;
        
        return;
    }
    
    //URLSchemeダウンロード判定
    if ( [EmptyCheck check:appDelegate.urlSchemeDownloadUrl] ) {
        
        [self requestStart:appDelegate.urlSchemeDownloadUrl];
        
        return;
    }
    
    if ( appDelegate.pboardURLOpenBrowser ) {
     
        appDelegate.pboardURLOpenBrowser = NO;
        return;
    }
    
    if ( !showActionSheet ) {
     
        showActionSheet = YES;
        
        actionSheetNo = 14;
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"動作選択"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"Tweet", @"FastGoogle", @"ペーストボードのURLを開く", nil];
        
        [sheet showInView:self.view];
        sheet = nil;
    }
}

- (void)setSearchEngine {
    
    if ( ![EmptyCheck check:[d objectForKey:@"SearchEngine"]] ) [d setObject:@"Google" forKey:@"SearchEngine"];
    
    searchField.placeholder = [d objectForKey:@"SearchEngine"];
}

- (IBAction)pushSearchButton:(id)sender {
    
    actionSheetNo = 0;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"検索エンジン切り替え"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Google", @"Amazon", @"Yahoo!オークション", 
                                              @"Wikipedia", @"Twitter検索", @"Wikipedia (Suggestion)", nil];
    [sheet showInView:self.view];
    sheet = nil;
}

- (IBAction)pushComposeButton:(id)sender {
 
    if ( downloading ) {
        
        actionSheetNo = 12;
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"ファイルダウンロード中です。\nダウンロードは継続されますが、閉じた場合はキャンセルが出来なくなります。"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"ブラウザを閉じる", nil];
        [sheet showInView:self.view];
        sheet = nil;
        
    }else {
    
        [self resetUserAgent];
        
        appDelegate.startupUrlList = BLANK_ARRAY;
        appDelegate.reOpenUrl = accessURL;
        
        if ( [appDelegate.firmwareVersion hasPrefix:@"6"] ) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else {
            
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}

- (IBAction)pushCloseButton:(id)sender {
    
    if ( downloading ) {
        
        actionSheetNo = 11;
        
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:@"ファイルダウンロード中です。\nダウンロードは継続されますが、閉じた場合はキャンセルが出来なくなります。"
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"ブラウザを閉じる", nil];
        [sheet showInView:self.view];
        sheet = nil;
        
    }else {
     
        [self resetUserAgent];
        
        appDelegate.startupUrlList = BLANK_ARRAY;
        appDelegate.reOpenUrl = BLANK;
        
        if ( [appDelegate.firmwareVersion hasPrefix:@"6"] ) {
        
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else {
            
            [self dismissModalViewControllerAnimated:YES];
        }
    }
}

- (IBAction)pushReloadButton:(id)sender {
    
    if ( [InternetConnection enable] ) {
        
        if ( loading ) {
            
            [wv stopLoading];
            [ActivityIndicator off];
            reloadButton.image = reloadButtonImage;
            
        }else {
            
            [wv loadRequestWithString:accessURL];
        }
    }
}

- (IBAction)pushBackButton:(id)sender {
    
    if ( [InternetConnection enable] ) [wv goBack];
}

- (IBAction)pushForwardButton:(id)sender {
    
    if ( [InternetConnection enable] ) [wv goForward];
}

- (IBAction)pushMenuButton:(id)sender {
    
    actionSheetNo = 1;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"機能選択"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"開いているページを投稿", @"選択文字を引用して投稿", 
                                              @"選択文字で検索", @"保存", @"ブックマークに登録",
                                              @"Safariで開く", @"ホームページを変更", @"FastEverで開く", 
                                              @"PC版UAで開き直す", nil];
    [sheet showInView:self.view];
    sheet = nil;
}

- (IBAction)pushBookmarkButton:(id)sender {
    
    openBookmark = YES;
    
    BookmarkViewController *dialog = [[BookmarkViewController alloc] init];
    dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:dialog animated:YES];
    dialog = nil;
}

- (IBAction)enterSearchField:(id)sender {
    
    if ( [searchField.text isEqualToString:BLANK] ) {
        
        [searchField resignFirstResponder];
        
        return;
    }
    
    NSString *searchURL = nil;
    
    if ( [[d objectForKey:@"SearchEngine"] isEqualToString:@"Google"] ) {
        
        searchURL = @"http://www.google.co.jp/search?q=";
        
    }else if ( [[d objectForKey:@"SearchEngine"] isEqualToString:@"Amazon"] ) {
        
        searchURL = @"http://www.amazon.co.jp/s/field-keywords=";
        
    }else if ( [[d objectForKey:@"SearchEngine"] isEqualToString:@"Yahoo!オークション"] ) {
        
        searchURL = @"http://auctions.search.yahoo.co.jp/search?tab_ex=commerce&rkf=1&p=";
        
    }else if ( [[d objectForKey:@"SearchEngine"] isEqualToString:@"Wikipedia"] ) {
        
        searchURL = @"http://ja.m.wikipedia.org/wiki/";
        
    }else if ( [[d objectForKey:@"SearchEngine"] isEqualToString:@"Twitter"] ) {
        
        searchURL = @"https://mobile.twitter.com/search?q=";
    
    }else if ( [[d objectForKey:@"SearchEngine"] isEqualToString:@"Wikipedia (Suggestion)"] ) {
        
        searchURL = @"http://google.com/complete/search?output=toolbar&hl=ja&q=";
    }
    
    NSString *encodedSearchWord = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
                                                                                                (__bridge CFStringRef)searchField.text, 
                                                                                                NULL, 
                                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]", 
                                                                                                kCFStringEncodingUTF8);
    
    if ( ![[d objectForKey:@"SearchEngine"] isEqualToString:@"Wikipedia (Suggestion)"] ) {
        
        [wv loadRequestWithString:[NSString stringWithFormat:@"%@%@", searchURL, encodedSearchWord]];
        searchURL = nil;
        encodedSearchWord = nil;
    
    }else {
        
        dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
        dispatch_async( globalQueue, ^{
            dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
            dispatch_sync( syncQueue, ^{
                
                [ActivityIndicator on];
                
                NSString *xmlString = [[NSString alloc] initWithContentsOfURL:
                                       [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", searchURL, encodedSearchWord]]
                                                                     encoding:NSShiftJISStringEncoding
                                                                        error:nil];
                
                NSString *suggestion = [RegularExpression strWithRegExp:xmlString
                                                      regExpPattern:@"<suggestion data=\".{1,50}\"/><num_queries"];
                xmlString = nil;
                
                if ( ![EmptyCheck check:suggestion] ) {
                    
                    [ShowAlert error:@"サジェストがありません。"];
                    suggestion = nil;
                    return;
                }
                
                suggestion = [ReplaceOrDelete deleteWordReturnStr:suggestion deleteWord:@"<suggestion data=\""];
                suggestion = [ReplaceOrDelete deleteWordReturnStr:suggestion deleteWord:@"\"/><num_queries"];
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    //UIの更新
                    searchField.text = suggestion;
                    searchField.placeholder = @"Wikipedia";
                    [d setObject:@"Wikipedia" forKey:@"SearchEngine"];
                    [self enterSearchField:nil];
                    [ActivityIndicator off];
                });
                
                suggestion = nil;
            });
            
            dispatch_release(syncQueue);
        });
    }
}

- (IBAction)enterURLField:(id)sender {
    
    if ( [urlField.text isEqualToString:BLANK] ) {
        
        [urlField resignFirstResponder];
        
        return;
    }
    
    NSString *encodedUrl = [DeleteWhiteSpace string:urlField.text];
    [wv loadRequestWithString:encodedUrl];
    
    encodedUrl = nil;
}

- (IBAction)onUrlField: (id)sender {
    
    //URLフィールドが選択された場合はプロトコルありの物に差し替える
    urlField.text = [wv.request URL].absoluteString;
    
    editing = NO;

    [self setViewSize];
}

- (IBAction)leaveUrlField: (id)sender {
    
    //URLフィールドから選択が外れた場合はプロトコルなしの表示にする
    urlField.text = [ProtocolCutter url:urlField.text];
    
    editing = NO;
    
    [self setViewSize];
}

- (IBAction)onSearchField: (id)sender {
    
    editing = YES;
    
    [self setViewSize];
}

- (IBAction)leaveSearchField: (id)sender {
    
    editing = NO;
    
    [self setViewSize];
}

- (IBAction)doubleTapUrlField:(id)sender {
    
    NSLog(@"doubleTapUrlField");
    
    [urlField resignFirstResponder];
    
    actionSheetNo = 16;
    NSString *copyURL = [[wv.request URL] absoluteString];
    
    if ( ![EmptyCheck string:copyURL] ) {

        if ( ![EmptyCheck string:loadStartURL] ) {
            
            if ( ![EmptyCheck string:[startupUrlList objectAtIndex:0]] ) {
             
                copyURL = [urlList objectAtIndex:0];
                
            }else {
                
                copyURL = [startupUrlList objectAtIndex:0];
            }
            
        }else {
            
            copyURL = loadStartURL;
        }
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:[NSString stringWithFormat:@"%@\n%@", wv.pageTitle, copyURL]
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"タイトルをコピー", @"URLをコピー", @"タイトルとURLをコピー", nil];
    [sheet showInView:self.view];
    
    copyURL = nil;
    sheet = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //NSLog(@"No: %d Index: %d", actionSheetNo, buttonIndex);
    
    if ( actionSheetNo == 0 ) {
        
        NSString *searchEngineName = nil;
        
        if ( buttonIndex == 0 ) {
            searchEngineName = @"Google";
        }else if ( buttonIndex == 1 ) {
            searchEngineName = @"Amazon";
        }else if ( buttonIndex == 2 ) {
            searchEngineName = @"Yahoo!オークション";
        }else if ( buttonIndex == 3 ) {
            searchEngineName = @"Wikipedia";
        }else if ( buttonIndex == 4 ) {
            searchEngineName = @"Twitter";
        }else if ( buttonIndex == 5 ) {
            searchEngineName = @"Wikipedia (Suggestion)";
        }else {
            return;
        }
        
        searchField.placeholder = searchEngineName;
        [d setObject:searchEngineName forKey:@"SearchEngine"];
        [searchField becomeFirstResponder];
        
    }else if ( actionSheetNo == 1 ) {
        
        if ( buttonIndex == 0 ) {
            
            NSString *postText = BLANK;
            
            if ( [RegularExpression boolWithRegExp:urlField.text regExpPattern:@"(https?://)?shindanmaker.com/[0-9]+"] ) {
                
                NSLog(@"Shindanmaker Post");
                
                NSData *wvData = [NSURLConnection sendSynchronousRequest:[wv request]
                                                       returningResponse:nil
                                                                   error:nil];
                
                postText = [[NSString alloc] initWithData:wvData
                                                 encoding:NSUTF8StringEncoding];
                
                postText = [ReplaceOrDelete deleteWordReturnStr:postText deleteWord:@"\n"];
                postText = [ReplaceOrDelete replaceWordReturnStr:postText replaceWord:@"\t" replacedWord:@" "];
                postText = [ReplaceOrDelete replaceWordReturnStr:postText replaceWord:@"  " replacedWord:@" "];
                postText = [RegularExpression strWithRegExp:postText regExpPattern:@"this.select...>.{1,140}?<.textarea>"];
                postText = [ReplaceOrDelete deleteWordReturnStr:postText deleteWord:@"this.select()\">"];
                postText = [ReplaceOrDelete deleteWordReturnStr:postText deleteWord:@"</textarea>"];
                
                //NSLog(@"postText: %@", postText);
                
                if ( ![EmptyCheck string:postText] ) {
                    
                    [ShowAlert error:@"データ取得に失敗しました。"];
                    
                    return;
                }
                
            }else {
                
                if ( [EmptyCheck check:[d objectForKey:@"WebPagePostFormat"]] ) {
                    
                    postText = [d objectForKey:@"WebPagePostFormat"];
                    
                }else {
                    
                    postText = @" \"[title]\" [url] ";
                    [d setObject:postText forKey:@"WebPagePostFormat"];
                }
                
                postText = [ReplaceOrDelete replaceWordReturnStr:postText
                                                     replaceWord:@"[title]"
                                                    replacedWord:wv.pageTitle];
                
                NSString *copyURL = [[wv.request URL] absoluteString];
                
                if ( ![EmptyCheck string:copyURL] ) {
                    
                    if ( ![EmptyCheck string:loadStartURL] ) {
                        
                        if ( ![EmptyCheck string:[startupUrlList objectAtIndex:0]] ) {
                            
                            copyURL = [urlList objectAtIndex:0];
                            
                        }else {
                            
                            copyURL = [startupUrlList objectAtIndex:0];
                        }
                        
                    }else {
                        
                        copyURL = loadStartURL;
                    }
                }
                
                postText = [ReplaceOrDelete replaceWordReturnStr:postText
                                                     replaceWord:@"[url]"
                                                    replacedWord:copyURL];
            }
            
            appDelegate.tabBarController.selectedIndex = 0;
            
            appDelegate.postTextType = @"WebPage";
            appDelegate.postText = postText;
            
            [self pushComposeButton:nil];
            
        }else if ( buttonIndex == 1 ) {
            
            //NSLog(@"selectString: %@", wv.selectString);
            
            appDelegate.tabBarController.selectedIndex = 0;
            
            if ( [EmptyCheck check:wv.selectString] ) {
                
                actionSheetNo = 7;
                
                UIActionSheet *sheet = [[UIActionSheet alloc]
                                        initWithTitle:@"引用投稿"
                                        delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                        otherButtonTitles:@"選択文字を投稿", @"選択文字に引用符を付けて投稿",
                                        @"URL･タイトルと選択文字を投稿", nil];
                [sheet showInView:self.view];
                
            }else {
                
                [ShowAlert error:@"文字が選択されていません。"];
            }
        
        }else if ( buttonIndex == 2 ) {
            
            actionSheetNo = 8;
            
            UIActionSheet *sheet = [[UIActionSheet alloc]
                                    initWithTitle:@"選択文字検索"
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:@"Google", @"Amazon", @"Yahoo!オークション", 
                                    @"Wikipedia", @"Twitter検索", @"Wikipedia (Suggestion)", nil];
            [sheet showInView:self.view];
        
        }else if ( buttonIndex == 3 ) {
            
            if ( [EmptyCheck check:urlField.text] ) {
                
                NSError *error = nil;
                NSString *documentTitle = wv.pageTitle;
                
                NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@".*[0-9,]+×[0-9,]+ ?(pixels|ピクセル)$" 
                                                                                        options:0 
                                                                                          error:&error];
                
                NSTextCheckingResult *match = [regexp firstMatchInString:documentTitle 
                                                                 options:0 
                                                                   range:NSMakeRange(0, documentTitle.length)];
                
                @autoreleasepool {
                    
                    [grayView performSelectorInBackground:@selector(on) withObject:nil];
                }
                
                if ( match.numberOfRanges != 0 ) {
                    
                    //NSLog(@"Image save");
                    
                    @autoreleasepool {
                        
                        //画像保存開始
                        [self performSelectorInBackground:@selector(saveImage) withObject:nil];
                    }
                    
                }else {
                    
                    //NSLog(@"File save");
                    
                    //ファイル保存開始
                    [self selectDownloadUrl];
                }
            }
            
        }else if ( buttonIndex == 4 ) {
            
            if ( ![EmptyCheck check:[d arrayForKey:@"Bookmark"]] ) {
                
                [d setObject:BLANK_ARRAY forKey:@"Bookmark"];
            }
            
            NSMutableArray *bookMarkArray = [[NSMutableArray alloc] initWithArray:[d arrayForKey:@"Bookmark"]];
            
            //登録済みURLのチェック
            BOOL check = YES;
            for ( NSDictionary *dic in bookMarkArray ) {
                
                if ( [[dic objectForKey:@"URL"] isEqualToString:[[wv.request URL] absoluteString]] ) {
                    
                    check = NO;
                }
            }
            
            if ( check ) {
                
                NSMutableDictionary *addBookmark = [NSMutableDictionary dictionaryWithObject:wv.pageTitle forKey:@"Title"];
                [addBookmark setValue:[[wv.request URL] absoluteString] forKey:@"URL"];
                
                [bookMarkArray addObject:addBookmark];
                
                [d setObject:bookMarkArray forKey:@"Bookmark"];
                
            }else {
                
                [ShowAlert error:@"登録済みのURLです。"];
            }
            
        }else if ( buttonIndex == 5 ) {
            
            //Safariで開く
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:accessURL]];
        
        }else if ( buttonIndex == 6 ) {
            
            alertTextNo = 1;
            
            alert = [[UIAlertView alloc] initWithTitle:@"ホームページURL" 
                                               message:@"\n"
                                              delegate:self 
                                     cancelButtonTitle:@"キャンセル" 
                                     otherButtonTitles:@"確定", nil];
            
            alertText = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
            [alertText setBackgroundColor:[UIColor whiteColor]];
            alertText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            alertText.delegate = self;
            
            [alert addSubview:alertText];
            [alert show];
            [alertText becomeFirstResponder];
            
        }else if ( buttonIndex == 7 ) {
            
            if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fastever://"]] ) {
                
                NSString *reqUrl = BLANK;
            
                if ( [EmptyCheck check:wv.selectString] ) {
                    
                    reqUrl = [NSString stringWithFormat:@"fastever://?text=%@\n%@\n>>%@\n", wv.pageTitle, accessURL, wv.selectString];
                    
                }else {
                    
                    reqUrl = [NSString stringWithFormat:@"fastever://?text=%@\n%@\n", wv.pageTitle, accessURL];
                }
                
                [[UIApplication sharedApplication] openURL:
                 [NSURL URLWithString:(__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                            (__bridge CFStringRef)reqUrl, 
                                                                                                            NULL, 
                                                                                                            NULL, 
                                                                                                            kCFStringEncodingUTF8)]];
            
            }else {
                
                [ShowAlert error:@"FastEverをインストール後使用してください。"];
            }
        
        //PC版UAで開き直す
        }else if ( buttonIndex == 8 ) {
            
            appDelegate.pcUaMode = YES;
            [d setObject:@"FireFox" forKey:@"UserAgent"];
            [self pushComposeButton:nil];
        }
        
    }else if ( actionSheetNo == 2 || actionSheetNo == 3 || actionSheetNo == 4 || actionSheetNo == 5 || actionSheetNo == 6 ) {
        
        if ( buttonIndex == actionSheetNo ) {
            
            //キャンセルされた場合はホームページを開く
            [wv loadRequestWithString:[d objectForKey:@"HomePageURL"]];
            
        }else {
            
            //選択されたURLを開く
            [wv loadRequestWithString:[startupUrlList objectAtIndex:buttonIndex]];
        }
        
    }else if ( actionSheetNo == 7 ) {
        
        appDelegate.postTextType = @"Quote";
        
        if ( buttonIndex == 0 ) {
        
            if ( ![EmptyCheck check:wv.selectString] ) return;
            
            appDelegate.postText = wv.selectString;
            [self pushComposeButton:nil];
        
        }else if ( buttonIndex == 1 ) {
        
            if ( ![EmptyCheck check:wv.selectString] ) return;
            
            appDelegate.postText = [NSString stringWithFormat:@">>%@", wv.selectString];
            [self pushComposeButton:nil];
        
        }else if ( buttonIndex == 2 ) {
        
            if ( ![EmptyCheck check:wv.selectString] ) return;
            
            NSString *postText = BLANK;
            
            if ( [EmptyCheck check:[d objectForKey:@"QuoteFormat"]] ) {
                
                postText = [d objectForKey:@"QuoteFormat"];
                
            }else {
                
                postText = @" \"[title]\" [url] >>[quote]";
                [d setObject:postText forKey:@"QuoteFormat"];
            }
            
            NSString *copyURL = [[wv.request URL] absoluteString];
            
            if ( ![EmptyCheck string:copyURL] ) {
                
                if ( ![EmptyCheck string:loadStartURL] ) {
                    
                    if ( ![EmptyCheck string:[startupUrlList objectAtIndex:0]] ) {
                        
                        copyURL = [urlList objectAtIndex:0];
                        
                    }else {
                        
                        copyURL = [startupUrlList objectAtIndex:0];
                    }
                    
                }else {
                    
                    copyURL = loadStartURL;
                }
            }
            
            postText = [ReplaceOrDelete replaceWordReturnStr:postText 
                                                 replaceWord:@"[title]" 
                                                replacedWord:wv.pageTitle];
            
            postText = [ReplaceOrDelete replaceWordReturnStr:postText 
                                                 replaceWord:@"[url]" 
                                                replacedWord:copyURL];
            
            postText = [ReplaceOrDelete replaceWordReturnStr:postText 
                                                 replaceWord:@"[quote]" 
                                                replacedWord:wv.selectString];
            
            appDelegate.postText = postText;
            
            [self pushComposeButton:nil];
        
        }else {
            
            appDelegate.postTextType = BLANK;
        }
    
    }else if ( actionSheetNo == 8 ) {
        
        if ( [EmptyCheck check:wv.selectString] ) {
            
            NSString *searchEngineName = nil;
            
            if ( buttonIndex == 0 ) {
                searchEngineName = @"Google";
            }else if ( buttonIndex == 1 ) {
                searchEngineName = @"Amazon";
            }else if ( buttonIndex == 2 ) {
                searchEngineName = @"Yahoo!オークション";
            }else if ( buttonIndex == 3 ) {
                searchEngineName = @"Wikipedia";
            }else if ( buttonIndex == 4 ) {
                searchEngineName = @"Twitter";
            }else if ( buttonIndex == 5 ) {
                searchEngineName = @"Wikipedia (Suggestion)";
            }else {
                return;
            }
            
            searchField.text = wv.selectString;
            searchField.placeholder = searchEngineName;
            [d setObject:searchEngineName forKey:@"SearchEngine"];
            
            [self enterSearchField:nil];
        }
    
    }else if ( actionSheetNo == 9 ) {
        
        if ( buttonIndex == 0 ) {
            
            [self requestStart:accessURL];
            
        }else if ( buttonIndex == 1 ) {
            
            [self requestStart:urlField.text];
            
        }else {
            
            [grayView off];
        }
        
    }else if ( actionSheetNo == 10 ) {
        
        if ( buttonIndex == 0 ) {
            
            [self requestStart:accessURL];
            
        }else if ( buttonIndex == 1 ) {
            
            [self requestStart:[NSString stringWithFormat:@"http://%@", urlField.text]];
            
        }else if ( buttonIndex == 2 ) {
            
            [self requestStart:[NSString stringWithFormat:@"https://%@", urlField.text]];
            
        }else {
            
            [grayView off];
        }
    
    }else if ( actionSheetNo == 11 ) {
        
        if ( buttonIndex == 0 ) {
            
            [self resetUserAgent];
            
            if ( [appDelegate.firmwareVersion hasPrefix:@"6"] ) {
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }else {
                
                [self dismissModalViewControllerAnimated:YES];
            }
        }
        
    }else if ( actionSheetNo == 12 ) {
        
        if ( buttonIndex == 0 ) {
            
            [self resetUserAgent];
            
            if ( [appDelegate.firmwareVersion hasPrefix:@"6"] ) {
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }else {
                
                [self dismissModalViewControllerAnimated:YES];
            }
        }
    
    }else if ( actionSheetNo == 13 ) {
        
        [ActivityIndicator off];
        
        if ( buttonIndex == 0 ) {
            
            [self requestStart:downloadUrl];
        }
        
    }else if ( actionSheetNo == 14 ) {
        
        showActionSheet = NO;
        
        @try {
            
            if ( buttonIndex == 0 ) {
                
                appDelegate.postText = pboard.string;
                
                [self pushComposeButton:nil];
                
            }else if ( buttonIndex == 1 ) {
                
                [wv loadRequestWithString:[CreateSearchURL google:pboard.string]];
                
            }else if ( buttonIndex == 2 ) {
                
                [self selectOpenUrl];
            }
            
        }@catch ( NSException *e ) {}
        
    }else if ( actionSheetNo == 15 ) {
        
        if ( buttonIndex == 0 ) {
            
        }else if ( buttonIndex == 1 ) {
            
            //ペーストボードから開く場合
            startupUrlList = urlList;
            
        }else {
            
            //キャンセルされた場合はホームページを開く
            [wv loadRequestWithString:[d objectForKey:@"HomePageURL"]];
            
            return;
        }
        
        [self selectUrl];
        
    }else if ( actionSheetNo == 16 ) {
        
        NSString *copyURL = [[wv.request URL] absoluteString];
        
        if ( ![EmptyCheck string:copyURL] ) copyURL = loadStartURL;
        
        if ( buttonIndex == 0 ) {
            
            [pboard setString:wv.pageTitle];
            
        }else if ( buttonIndex == 1 ) {
            
            [pboard setString:copyURL];
            
        }else if ( buttonIndex == 2 ) {
            
            [pboard setString:[NSString stringWithFormat:@"\"%@\" %@", wv.pageTitle, copyURL]];
        }
    }
}

- (void)saveImage {
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:accessURL]];
    UIImage *image = [[UIImage alloc] initWithData:data];
    UIImageWriteToSavedPhotosAlbum(image, 
                                   self, 
                                   @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), 
                                   nil);
    image = nil;
}

- (void)savingImageIsFinished:(UIImage *)image
     didFinishSavingWithError:(NSError *)error
                  contextInfo:(void *)contextInfo {
    
    if( error ){
        
        [ShowAlert error:@"保存に失敗しました。"];
        
    }else {
        
        [ShowAlert title:@"保存完了" message:@"カメラロールに保存しました。"];
    }
    
    [grayView off];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( alertTextNo == 1 ) {
    
        if ( buttonIndex == 1 ) {
     
            //NSLog(@"SetHomePage: %@", alertText.text);
            [d setObject:alertText.text forKey:@"HomePageURL"];
            
            alertTextNo = 0;
            alertText.text = BLANK;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender {

    //NSLog(@"textFieldShouldReturn");
    
    if ( alertTextNo == 1 ) {
    
        //NSLog(@"SetHomePage: %@", alertText.text);
        [d setObject:alertText.text forKey:@"HomePageURL"];
        
        alertTextNo = 0;
        alertText.text = BLANK;
        
        //キーボードを閉じる
        [sender resignFirstResponder];
        
        //アラートを閉じる
        [alert dismissWithClickedButtonIndex:1 animated:YES];
    }
    
    return YES;
}

/* WebView */

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType {
    
    if ( [EmptyCheck string:request.URL.absoluteString] ) {
        
        accessURL = request.URL.absoluteString;
    }
    
    //広告をブロック
    if ( [ADBlock check:accessURL] ) return NO;
    
    //NSLog(@"%@", [[request URL] absoluteString]);
    
    //フルサイズ取得が有効
    if ( [d boolForKey:@"FullSizeImage"] ) {
        
        //画像サービスのURLかスキャン
        NSString *fullSizeImageUrl = [FullSizeImage urlString:accessURL];
        
        //スキャン済みURLが変わっていたらアクセスし直し
        if ( ![fullSizeImageUrl isEqualToString:accessURL] ) {
            
            //NSLog(@"FullSizeImage ReAccess");
            [wv loadRequestWithString:fullSizeImageUrl];
            
            return NO;
        }
    }
    
    //Amazonのアフィリンクの場合無効化して再アクセス
    if ( [RegularExpression boolWithRegExp:accessURL
                         regExpPattern:@"https?://(www\\.)?amazon\\.co\\.jp/((exec/obidos|o)/ASIN|dp|gp/product)/[A-Z0-9]{10}.*(/|[\\?&]tag=)[-_a-zA-Z0-9]+-22/?"] ) {
        
        NSString *affiliateCuttedUrl = [AmazonAffiliateCutter string:accessURL];
        
        if ( ![affiliateCuttedUrl isEqualToString:accessURL] ) {
            
            //NSLog(@"Affiliate cutted access: %@", affiliateCuttedUrl);
            [wv loadRequestWithString:affiliateCuttedUrl];
            
            return NO;
        }
    }
    
    if ( [RegularExpression boolWithRegExp:accessURL regExpPattern:@"about:blank|https?://.*"] ) {
        
        //そのままアクセス出来そうなURL
        //NSLog(@"http(s) address");
        
    }else {
        
        //NSLog(@"not http(s) address");
        
        NSURL *URL = [NSURL URLWithString:accessURL];
        BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:URL];
        
        if ( canOpen ) {
            
            //URLScheme
            NSLog(@"scheme");
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [[UIApplication sharedApplication] openURL:URL];
            
            return NO;
            
        }else {
            
            //そのままアクセス出来なそうでURLSchemeでもない
            //http://を付けてみる
            NSLog(@"add protocol");
            
            [wv loadRequestWithString:[NSString stringWithFormat:@"http://%@", accessURL]];
            
            return NO;
        }
    }
    
    //保存メニューを表示するかチェック
    [self performSelectorInBackground:@selector(showDownloadMenu:) withObject:accessURL];
    
    loading = YES;
    
    if ( ![[[request URL] absoluteString] isEqualToString:@"about:blank"] ) {
        
        //NSLog(@"%@", [[request URL] absoluteString]);
        
        urlField.text = [ProtocolCutter url:request.URL.absoluteString];
    }
    
    [ActivityIndicator on];
    [self updateWebBrowser];
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    accessURL = webView.request.URL.absoluteString;
    urlField.text = [ProtocolCutter url:webView.request.URL.absoluteString];
    
    loading = NO;
    [ActivityIndicator off];
    [self updateWebBrowser];
    
    //[self adBlock];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    if ( [EmptyCheck string:webView.request.URL.absoluteString] ) {
        
        accessURL = webView.request.URL.absoluteString;
    }
    
    loadStartURL = webView.request.URL.absoluteString;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if ( error.code != -999 && error.code != 102 && error.code != 204) {
        
        //NSLog(@"%@", error.description);
        
        [ShowAlert error:error.localizedDescription];
        
        loading = NO;
        [ActivityIndicator off];
        [self updateWebBrowser];
    }
}

- (void)updateWebBrowser {
    
    //NSLog(@"updateWebBrowser");

    [self backForwordButtonVisible];
    [self reloadStopButton];
}

- (void)reloadStopButton {
    
    loading ? ( reloadButton.image = stopButtonImage ) : ( reloadButton.image = reloadButtonImage );
}

- (void)backForwordButtonVisible {
    
    wv.canGoBack ? ( backButton.enabled = YES ) : ( backButton.enabled = NO );
    wv.canGoForward ? ( forwardButton.enabled = YES ) : ( forwardButton.enabled = NO );
}

/* WebViewここまで */

- (void)selectDownloadUrl {
    
    if ( [accessURL hasSuffix:@"/"] ) {
        
        if ( [[NSString stringWithFormat:@"http://%@/", urlField.text] isEqualToString:accessURL] ||
            [[NSString stringWithFormat:@"https://%@/", urlField.text] isEqualToString:accessURL] ) {
            
            [self requestStart:accessURL];
            
            return;
        }
    }
    
    if ( [[NSString stringWithFormat:@"http://%@", urlField.text] isEqualToString:accessURL] ||
         [[NSString stringWithFormat:@"https://%@", urlField.text] isEqualToString:accessURL] ) {
        
        [self requestStart:accessURL];
        
    }else {
        
        NSString *buttonTitle0 = accessURL;
        NSString *buttonTitle1 = nil;
        NSString *buttonTitle2 = nil;
        
        if ( [urlField.text hasPrefix:@"http"] ) {
            
            buttonTitle1 = urlField.text;
            
            actionSheetNo = 9;
            
            UIActionSheet *sheet = [[UIActionSheet alloc]
                                    initWithTitle:@"保存URL選択"
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:buttonTitle0, buttonTitle1, nil];
            
            [sheet showInView:self.view];
            sheet = nil;
            
        }else {
            
            buttonTitle1 = [NSString stringWithFormat:@"http://%@", urlField.text];
            buttonTitle2 = [NSString stringWithFormat:@"https://%@", urlField.text];
            
            actionSheetNo = 10;
            
            UIActionSheet *sheet = [[UIActionSheet alloc]
                                    initWithTitle:@"保存URL選択"
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:buttonTitle0, buttonTitle1, buttonTitle2, nil];
            
            [sheet showInView:self.view];
            sheet = nil;
        }
    }
}

/* 非同期通信ダウンロード */

- (void)requestStart:(NSString *)url {
    
    //NSLog(@"requestStart: %@", url);
    
    @try {
        
        //URLのチェック
        if ( ![EmptyCheck check:url] ) {
            
            [ShowAlert error:@"URLがありません。"];
            return;
        }
        
        if ( downloading ) {
            
            [ShowAlert title:@"ダウンロード進行中" message:@"現在ダウンロードしているファイルが完了した後やり直してください。"];
            return;
        }
        
        //キャッシュの削除
        NSURLCache *cache = [NSURLCache sharedURLCache];
        [cache removeAllCachedResponses];
        
        //ダウンロード進捗表示用のラベルとバーを表示
        bytesLabel.hidden = NO;
        progressBar.hidden = NO;
        downloadCancelButton.hidden = NO;
        
        //初期化
        downloading = YES;
        bytesLabel.text = @"0 / 0 bytes";
        totalbytes = 0.0;
        loadedbytes = 0.0;
        asyncConnection = nil;
        asyncData = nil;
        
        //ファイル名を生成
        saveFileName = [url lastPathComponent]; 
        
        //ダウンロードリクエスト開始
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        asyncConnection = [[NSURLConnection alloc] initWithRequest:request 
                                                          delegate:self];
        
    }@catch ( NSException *e ) {
        
        [ShowAlert unknownError];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSLog(@"didReceiveResponse:%d, %lldbytes", httpResponse.statusCode, response.expectedContentLength);
    
    if ( httpResponse.statusCode == 200 ) {
        
        //データを初期化
        asyncData = [[NSMutableData alloc] initWithData:0];
        
        //総ファイルサイズをセット
        totalbytes = [response expectedContentLength];
        
    }else {
     
        [ShowAlert error:@"不明なエラー"];
        [self endDownload];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{

    //NSLog(@"didReceiveData");
    
    //受信したデータを追加
	[asyncData appendData:data];
    
    //受信したデータサイズを追加
    loadedbytes += [data length];
    
    //UIの更新
    [progressBar setProgress:(loadedbytes / totalbytes)];
    bytesLabel.text = [NSString stringWithFormat:@"%.0f / %.0f bytes", loadedbytes, totalbytes];
}

- (IBAction)pushDownloadCancelButton:(id)sender {
    
    [asyncConnection cancel];

    [ShowAlert title:saveFileName message:@"ダウンロードを中断しました。"];
    
    [self endDownload];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    //NSLog(@"didFailWithError");
    
    [ShowAlert error:@"ダウンロードに失敗しました。"];
    
    [self endDownload];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    //NSLog(@"connectionDidFinishLoading");
    
    //Documentフォルダにデータを保存
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *savePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:saveFileName];
    [manager createFileAtPath:savePath 
                     contents:asyncData 
                   attributes:nil];
    
    [ShowAlert title:@"保存完了" 
             message:@"アプリ内ドキュメントフォルダに保存されました。ファイルへはPCのiTunesからアクセス出来ます。"];
    
    [self endDownload];
}

- (void)endDownload {
    
    [grayView off];
    asyncData = nil;
    asyncConnection = nil;
    downloading = NO;
    bytesLabel.hidden = YES;
    progressBar.hidden = YES;
    downloadCancelButton.hidden = YES;
    appDelegate.urlSchemeDownloadUrl = BLANK;
}

- (void)showDownloadMenu:(NSString *)url {
    
    BOOL result = NO;
    NSString *extension = [[url pathExtension] lowercaseString];
    
    for ( NSString *temp in EXTENSIONS ) {
        
        if ( [temp isEqualToString:extension] ) {
            
            downloadUrl = url;
            actionSheetNo = 13;
            
            UIActionSheet *sheet = [[UIActionSheet alloc]
                                    initWithTitle:@"保存確認"
                                    delegate:self
                                    cancelButtonTitle:@"Cancel"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles:@"保存する", nil];
            
            [sheet showInView:self.view];
            sheet = nil;
            
            result = YES;
        }
        
        if ( result ) break;
    }
}

/* 非同期通信ダウンロードここまで */

- (void)resetUserAgent {
    
    //NSLog(@"resetUserAgent");
    
    //「PC版UAで開き直す」ではなく、リセット設定がONでなく、空でない
    if ( !appDelegate.pcUaMode && ![[d objectForKey:@"UserAgentReset"] isEqualToString:@"OFF"] ) {
        
        //NSLog(@"Reset: %@", [d objectForKey:@"UserAgentReset"]);
        
        [d setObject:[d objectForKey:@"UserAgentReset"] forKey:@"UserAgent"];
    }
}

- (void)rotateView:(int)mode {
 
    NSLog(@"rotateView: %d", mode);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.05];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationRepeatCount:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];

    //縦
    if ( mode == 0 ) {
        
        if ( fullScreen ) {
            
            topBar.frame = CGRectMake(0, -44, SCREEN_WIDTH, TOOL_BAR_HEIGHT);
            wv.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            bottomBar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, TOOL_BAR_HEIGHT);
            
            if ( editing ) {
                
                urlField.frame = CGRectMake(12, -44, 75, 31);
                searchField.frame = CGRectMake(97, -44, 180, 31);
                
            }else {
                
                urlField.frame = CGRectMake(12, -44, 180, 31);
                searchField.frame = CGRectMake(202, -44, 75, 31);
            }
            
        }else {
            
            topBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, TOOL_BAR_HEIGHT);
            wv.frame = CGRectMake(0, TOOL_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - TOOL_BAR_HEIGHT * 2);
            bottomBar.frame = CGRectMake(0, SCREEN_HEIGHT - TOOL_BAR_HEIGHT, SCREEN_WIDTH, TOOL_BAR_HEIGHT);
            
            if ( editing ) {
                
                urlField.frame = CGRectMake(12, 7, 75, 31);
                searchField.frame = CGRectMake(97, 7, 180, 31);
                
            }else {
                
                urlField.frame = CGRectMake(12, 7, 180, 31);
                searchField.frame = CGRectMake(202, 7, 75, 31);
            }    
        }
     
    //横
    }else {
        
        if ( fullScreen ) {

            topBar.frame = CGRectMake(0, -44, SCREEN_HEIGHT, TOOL_BAR_HEIGHT);
            wv.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
            bottomBar.frame = CGRectMake(0, SCREEN_WIDTH, SCREEN_HEIGHT, TOOL_BAR_HEIGHT);
            
            if ( editing ) {
                
                urlField.frame = CGRectMake(12, -44, 135, 31);
                searchField.frame = CGRectMake(157, -44, 280 + retina4InchOffset, 31);
                
            }else {
                
                urlField.frame = CGRectMake(12, -44, 280 + retina4InchOffset, 31);
                searchField.frame = CGRectMake(302, -44, 135, 31);
            }
            
        }else {

            topBar.frame = CGRectMake(0, 0, SCREEN_HEIGHT, TOOL_BAR_HEIGHT);
            wv.frame = CGRectMake(0, TOOL_BAR_HEIGHT, SCREEN_HEIGHT, SCREEN_WIDTH - TOOL_BAR_HEIGHT * 2);
            bottomBar.frame = CGRectMake(0, SCREEN_WIDTH - TOOL_BAR_HEIGHT, SCREEN_HEIGHT, TOOL_BAR_HEIGHT);
            
            if ( editing ) {
                
                urlField.frame = CGRectMake(12, 7, 135, 31);
                searchField.frame = CGRectMake(157, 7, 280 + retina4InchOffset, 31);
                
            }else {
                
                urlField.frame = CGRectMake(12, 7, 280 + retina4InchOffset, 31);
                searchField.frame = CGRectMake(302 + retina4InchOffset, 7, 135, 31);
            }
        }
    }
    
    [UIView commitAnimations];
}

- (IBAction)fullScreenGesture:(id)sender {
        
    if ( fullScreen ) {
     
        fullScreen = NO;
        
    }else {
        
        fullScreen = YES;
    }
    
    [self setViewSize];
}

- (BOOL)shouldAutorotate {
    
//    NSLog(@"shouldAutorotate");
//    NSLog(@"ORIENTATION: %d", ORIENTATION);
    
    if ( ORIENTATION == UIDeviceOrientationUnknown ||
         ORIENTATION == UIDeviceOrientationPortrait ||
         ORIENTATION == UIDeviceOrientationLandscapeLeft ||
         ORIENTATION == UIDeviceOrientationLandscapeRight ) {
        
        //画面回転に伴ったUIの変更や処理をここで行う
        if ( ORIENTATION == UIDeviceOrientationUnknown ||
             ORIENTATION == UIDeviceOrientationPortrait ) {
        
            //縦
            [self rotateView:0];
            
        }else {
            
            //左右
            [self rotateView:1];
        }
        
        //画面回転を許可する
        return YES;
    }
    
    //画面回転を許可しない
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    
//    NSLog(@"supportedInterfaceOrientations");
    
    //Portrait, LandscapeLeft, LandscapeRight の場合画面回転を許可する
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if ( interfaceOrientation == UIInterfaceOrientationPortrait ) {
        
        [self rotateView:0];
        
        return YES;
        
    }else if ( interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
               interfaceOrientation == UIInterfaceOrientationLandscapeRight ) {
        
        [self rotateView:1];
                
        return YES;
        
    }else if ( interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ) {
        
        return NO;
    }
    
    return YES;
}

- (void)adBlock {
    
    NSLog(@"adBlock");
    
//    [wv stringByEvaluatingJavaScriptFromString:@"var delads=document.getElementsByTagName(\\'div\\');for(i=0;i<delads.length;i++){if(delads[i].className==\\'_naver_ad_area\\'){delads[i].style.display=none}}"];
//    [wv stringByEvaluatingJavaScriptFromString:@"var delads=document.getElementsByTagName(\\'div\\');for(i=0;i<delads.length;i++){if(delads[i].className==\\'adlantis_sp_sticky_container\\'){delads[i].style.display=none}}"];
    
    
//    [wv stringByEvaluatingJavaScriptFromString:
//     @"var delads=document.getElementsByClassName(\"_naver_ad_area\");for(i=0;i<delads.length;i++){delads[i].style.display=none}"];
//    
//    [wv stringByEvaluatingJavaScriptFromString:
//     @"var delads=document.getElementsByClassName(\"adlantis_sp_sticky_container\");for(i=0;i<delads.length;i++){delads[i].style.display=none}"];
}

- (void)setViewSize {
    
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] < 6.0 ) {
        
        NSLog(@"setViewSize iOS5");
        [self shouldAutorotateToInterfaceOrientation:ORIENTATION];
        
    }else {
        
        NSLog(@"setViewSize iOS6");
        
        //画面回転に伴ったUIの変更や処理をここで行う
        if ( ORIENTATION == UIDeviceOrientationLandscapeRight ||
             ORIENTATION == UIDeviceOrientationLandscapeLeft ) {
            
            //左右
            [self rotateView:1];
            
        }else {
            
            //縦
            [self rotateView:0];
        }
    }
}

- (void)viewDidUnload {
    
    //NSLog(@"WebViewExController viewDidUnload");
    
    appDelegate.browserOpenMode = NO;
    appDelegate.urlSchemeDownloadUrl = BLANK;
    
    [self setTopBar:nil];
    [self setBottomBar:nil];
    [self setSearchButton:nil];
    [self setCloseButton:nil];
    [self setReloadButton:nil];
    [self setBackButton:nil];
    [self setForwardButton:nil];
    [self setMenuButton:nil];
    [self setFlexibleSpace:nil];
    [self setUrlField:nil];
    [self setSearchField:nil];
    [self setComposeButton:nil];
    [self setWv:nil];
    [self setBytesLabel:nil];
    [self setProgressBar:nil];
    [self setDownloadCancelButton:nil];
    [self setBookmarkButton:nil];
    
    [super viewDidUnload];
}

- (void)dealloc {
    
    NSLog(@"WebViewExController dealloc");
    
    appDelegate.browserOpenMode = NO;
    appDelegate.urlSchemeDownloadUrl = BLANK;
    
    if ( wv.loading ) [wv stopLoading];
    wv.delegate = nil;
    
    appDelegate = nil;
    pboard = nil;
    alert = nil;
    alertText = nil;
    reloadButtonImage = nil;
    stopButtonImage = nil;
    d = nil;
    accessURL = nil;
    loadStartURL = nil;
    saveFileName = nil;
    asyncConnection = nil;
    asyncData = nil;;
    startupUrlList = nil;
    urlList = nil;
    
    [self removeAllSubViews];
    
    [ActivityIndicator visible:NO];
}

@end
