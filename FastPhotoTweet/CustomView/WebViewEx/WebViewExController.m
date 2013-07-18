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
#import "NSObject+EmptyCheck.h"

#define TOP_BAR [NSArray arrayWithObjects:urlField, searchField, searchButton, nil]
#define BOTTOM_BAR [NSArray arrayWithObjects:closeButton, flexibleSpace, composeButton, flexibleSpace, reloadButton, flexibleSpace, backButton, flexibleSpace, forwardButton, flexibleSpace, bookmarkButton, flexibleSpace, menuButton, nil]
#define EXTENSIONS [NSArray arrayWithObjects:@"zip", @"mp4", @"mov", @"m4a", @"rar", @"dmg", @"deb", nil]

#define APP_DELEGATE ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define P_BOARD [UIPasteboard generalPasteboard]
#define D [NSUserDefaults standardUserDefaults]

@implementation WebViewExController
@synthesize alert;
@synthesize alertText;
@synthesize reloadButtonImage;
@synthesize stopButtonImage;
@synthesize accessURL;
@synthesize loadStartURL;
@synthesize saveFileName;
@synthesize downloadUrl;
@synthesize asyncConnection;
@synthesize asyncData;
@synthesize startupUrlList;
@synthesize urlList;

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

- (id)initWithURL:(NSString *)URL {
    
    self = [super initWithNibName:NSStringFromClass([WebViewExController class])
                           bundle:nil];
    
    if ( self ) {
        
        if ( [URL isEmpty] ) {
         
            URL = [D objectForKey:@"HomePageURL"];
        }
        
        startupUrlList = @[URL];
        urlList = BLANK_ARRAY;
        
        retina4InchOffset = 0;
        
        if ( SCREEN_HEIGHT == 548 ) {
            
            NSLog(@"Retine 4inch");
            retina4InchOffset = 88;
        }
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    
    if ( self ) {
        
        startupUrlList = APP_DELEGATE.startupUrlList;
        urlList = BLANK_ARRAY;
        
        if ( startupUrlList == nil ) [D objectForKey:@"HomePageURL"];
        
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
    
    [self.wv setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    
    self.grayView = [[GrayView alloc] init];
    [_wv addSubview:_grayView];
    
    self.reloadButtonImage = [UIImage imageNamed:@"reload.png"];
    self.stopButtonImage = [UIImage imageNamed:@"stop.png"];
    
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
    
    searchField.clearsOnBeginEditing = [D boolForKey:@"ClearBrowserSearchField"];
    
    accessURL = BLANK;
    
    [self setSearchEngine];
    
    //ツールバーにボタンをセット
    [bottomBar setItems:BOTTOM_BAR animated:NO];
    
    APP_DELEGATE.browserOpenMode = YES;
    
    //URLSchemeダウンロード判定
    if ( [EmptyCheck check:APP_DELEGATE.urlSchemeDownloadUrl] ) {
        
        [self requestStart:APP_DELEGATE.urlSchemeDownloadUrl];
        return;
    }
    
    if (( APP_DELEGATE.pcUaMode ||
         [EmptyCheck string:APP_DELEGATE.reOpenUrl] ) &&
          APP_DELEGATE.tabBarController.selectedIndex != 1 ) {
        
        [_wv loadRequestWithString:APP_DELEGATE.reOpenUrl];
        
        APP_DELEGATE.reOpenUrl = BLANK;
        APP_DELEGATE.pcUaMode = NO;
        
    } else {
     
        [self selectOpenUrl];
    }
}

- (oneway void)selectOpenUrl {
    
    //NSLog(@"startupUrlList: %@", startupUrlList);
    
    if ( APP_DELEGATE.tabBarController.selectedIndex == 1 ) {
        
        //NSLog(@"タイムラインから開いている場合はスタートアップURLを優先");
        
        [self selectUrl];
        
    } else {
        
        //NSLog(@"タイムラインから開かれていない場合");
        
        if ( [D boolForKey:@"OpenPasteBoardURL"] ) {
            
            //NSLog(@"ペーストボードからURLを開く設定が有効な場合: %@", [D objectForKey:@"LastOpendPasteBoardURL"]);
            
            //ペーストボードのURLを取得
            urlList = [P_BOARD.string URLs];
            
            if ( startupUrlList.count == 1 && urlList.count == 0 ) {
                
                //NSLog(@"ペーストボードにURLが存在しない場合");
                
                [_wv loadRequestWithString:[startupUrlList objectAtIndex:0]];
                
            }else if ( startupUrlList.count == 0 && urlList.count == 1 ) {
                
                //NSLog(@"スタートアップURLがなく、ペーストボードにURLが1つ存在する場合");
                
                if ( [[urlList objectAtIndex:0] isEqualToString:[D objectForKey:@"LastOpendPasteBoardURL"]] ) {
                
                    [_wv loadRequestWithString:[D objectForKey:@"HomePageURL"]];
                    
                } else {
                    
                    [_wv loadRequestWithString:[urlList objectAtIndex:0]];
                    [D setObject:[urlList objectAtIndex:0] forKey:@"LastOpendPasteBoardURL"];
                }
                
            }else if ( startupUrlList.count == 1 && urlList.count == 1 ) {
                
                //NSLog(@"ペーストボードにURLが1つ存在する場合");
                
                if ( [[startupUrlList objectAtIndex:0] isEqualToString:[D objectForKey:@"HomePageURL"]] ) {
                    
                    //NSLog(@"スタートアップURLがホームページだった場合はペーストボードのURLを優先して判定");
                    
                    if ( [[urlList objectAtIndex:0] isEqualToString:[D objectForKey:@"LastOpendPasteBoardURL"]] ) {
                        
                        //NSLog(@"直前にペーストボードから開いたURLだった場合はスタートアップURLを開く");
                        
                        [_wv loadRequestWithString:[startupUrlList objectAtIndex:0]];
                        
                    } else {
                        
                        //NSLog(@"直前にペーストボードから開いたURLではない場合開く");
                        
                        [_wv loadRequestWithString:[urlList objectAtIndex:0]];
                        [D setObject:[urlList objectAtIndex:0] forKey:@"LastOpendPasteBoardURL"];
                    }
                    
                } else {
                    
                    //NSLog(@"スタートアップURLがホームページのURLではなかった場合選択して表示");
                    
                    if ( [[startupUrlList objectAtIndex:0] isEqualToString:[urlList objectAtIndex:0]] ) {
                        
                        [_wv loadRequestWithString:[startupUrlList objectAtIndex:0]];
                        
                    } else {
                        
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
                
                if ( [[startupUrlList objectAtIndex:0] isEqualToString:[D objectForKey:@"HomePageURL"]] ) {
                    
                    //NSLog(@"スタートアップURLがホームページだった場合はペーストボードのURLを優先して判定");
                    
                    startupUrlList = urlList;
                    [self selectUrl];
                    
                } else {
                    
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
                
            } else {
                
                //NSLog(@"その他の場合");
                
                [_wv loadRequestWithString:[D objectForKey:@"HomePageURL"]];
            }
            
        } else {
            
            //NSLog(@"ペーストボードからURLを開く設定が無効な場合");
            
            if ( startupUrlList.count == 1 ) {
                
                //NSLog(@"URLが1つの場合は開く");
                [_wv loadRequestWithString:[startupUrlList objectAtIndex:0]];
                
            }else if ( startupUrlList.count > 1 ) {
                
                //NSLog(@"URLが複数個の場合は選択して開く");
                [self selectUrl];
                
            } else {
                
                //NSLog(@"その他の場合はホームページを開く");
                [_wv loadRequestWithString:[D objectForKey:@"HomePageURL"]];
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    //NSLog(@"viewWillAppear");
    
    if ( openBookmark ) {
        
        openBookmark = NO;
        
        if ( [EmptyCheck check:APP_DELEGATE.bookmarkUrl] ) {
            
            //ブックマークで選択したURLを読み込み
            [_wv loadRequestWithString:APP_DELEGATE.bookmarkUrl];
            APP_DELEGATE.bookmarkUrl = BLANK;
        }
    }
}

- (oneway void)selectUrl {
    
    UIActionSheet *sheet;
    
    if (startupUrlList.count == 1 ) {
        
        [_wv loadRequestWithString:[startupUrlList objectAtIndex:0]];
        
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
    
    if ( [self.view window] != nil ) {
        
        [self.wv loadRequestWithString:[notification.userInfo objectForKey:@"pboardURL"]];
    }
}

- (void)becomeActive:(NSNotification *)notification {
    
    if ( APP_DELEGATE.willResignActiveBrowser ) {
        
        APP_DELEGATE.willResignActiveBrowser = NO;
        
        return;
    }
    
    //URLSchemeダウンロード判定
    if ( [EmptyCheck check:APP_DELEGATE.urlSchemeDownloadUrl] ) {
        
        [self requestStart:APP_DELEGATE.urlSchemeDownloadUrl];
        
        return;
    }
    
    if ( APP_DELEGATE.pboardURLOpenBrowser ) {
     
        APP_DELEGATE.pboardURLOpenBrowser = NO;
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
    
    if ( ![EmptyCheck check:[D objectForKey:@"SearchEngine"]] ) [D setObject:@"Google" forKey:@"SearchEngine"];
    
    searchField.placeholder = [D objectForKey:@"SearchEngine"];
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
        
    } else {
    
        [self resetUserAgent];
        
        APP_DELEGATE.startupUrlList = BLANK_ARRAY;
        APP_DELEGATE.reOpenUrl = accessURL;
        
        ASYNC_MAIN_QUEUE ^{
            
            [self.navigationController popViewControllerAnimated:YES];
        });
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
        
    } else {
     
        [self resetUserAgent];
        
        APP_DELEGATE.startupUrlList = BLANK_ARRAY;
        APP_DELEGATE.reOpenUrl = BLANK;
        
        ASYNC_MAIN_QUEUE ^{
            
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}

- (IBAction)pushReloadButton:(id)sender {
    
    if ( [InternetConnection enable] ) {
        
        if ( loading ) {
            
            [_wv stopLoading];
            [ActivityIndicator off];
            reloadButton.image = reloadButtonImage;
            
        } else {
            
            [_wv loadRequestWithString:accessURL];
        }
    }
}

- (IBAction)pushBackButton:(id)sender {
    
    if ( [InternetConnection enable] ) [_wv goBack];
}

- (IBAction)pushForwardButton:(id)sender {
    
    if ( [InternetConnection enable] ) [_wv goForward];
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
                                              @"ブログ広告除去を試みる", @"ホームページを変更", @"FastEverで開く",
                                              @"PC版UAで開き直す", @"Safariで開く", nil];
    [sheet showInView:self.view];
    sheet = nil;
}

- (IBAction)pushBookmarkButton:(id)sender {
    
    openBookmark = YES;
    
    BookmarkViewController *dialog = [[BookmarkViewController alloc] init];
    dialog.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self showModalViewController:dialog];
    dialog = nil;
}

- (IBAction)enterSearchField:(id)sender {
    
    if ( [searchField.text isEqualToString:BLANK] ) {
        
        [searchField resignFirstResponder];
        
        return;
    }
    
    NSString *searchURL = nil;
    
    if ( [[D objectForKey:@"SearchEngine"] isEqualToString:@"Google"] ) {
        
        searchURL = @"http://www.google.co.jp/search?q=";
        
    }else if ( [[D objectForKey:@"SearchEngine"] isEqualToString:@"Amazon"] ) {
        
        searchURL = @"http://www.amazon.co.jp/s/field-keywords=";
        
    }else if ( [[D objectForKey:@"SearchEngine"] isEqualToString:@"Yahoo!オークション"] ) {
        
        searchURL = @"http://auctions.search.yahoo.co.jp/search?tab_ex=commerce&rkf=1&p=";
        
    }else if ( [[D objectForKey:@"SearchEngine"] isEqualToString:@"Wikipedia"] ) {
        
        searchURL = @"http://ja.m.wikipedia.org/wiki/";
        
    }else if ( [[D objectForKey:@"SearchEngine"] isEqualToString:@"Twitter"] ) {
        
        searchURL = @"https://mobile.twitter.com/search?q=";
    
    }else if ( [[D objectForKey:@"SearchEngine"] isEqualToString:@"Wikipedia (Suggestion)"] ) {
        
        searchURL = @"http://google.com/complete/search?output=toolbar&hl=ja&q=";
    }
    
    NSString *encodedSearchWord = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
                                                                                                (__bridge CFStringRef)searchField.text, 
                                                                                                NULL, 
                                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]", 
                                                                                                kCFStringEncodingUTF8);
    
    if ( ![[D objectForKey:@"SearchEngine"] isEqualToString:@"Wikipedia (Suggestion)"] ) {
        
        [_wv loadRequestWithString:[NSString stringWithFormat:@"%@%@", searchURL, encodedSearchWord]];
        searchURL = nil;
        encodedSearchWord = nil;
    
    } else {
        
        dispatch_queue_t globalQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 );
        dispatch_async( globalQueue, ^{
            dispatch_queue_t syncQueue = dispatch_queue_create( "info.ktysne.fastphototweet", NULL );
            dispatch_sync( syncQueue, ^{
                
                [ActivityIndicator on];
                
                NSString *xmlString = [[NSString alloc] initWithContentsOfURL:
                                       [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", searchURL, encodedSearchWord]]
                                                                     encoding:NSShiftJISStringEncoding
                                                                        error:nil];
                
                NSString *suggestion = [xmlString stringWithRegExp:@"<suggestion data=\".{1,50}\"/><num_queries"];
                xmlString = nil;
                
                if ( ![EmptyCheck check:suggestion] ) {
                    
                    [ShowAlert error:@"サジェストがありません。"];
                    suggestion = nil;
                    return;
                }
                
                suggestion = [suggestion deleteWord:@"<suggestion data=\""];
                suggestion = [suggestion deleteWord:@"\"/><num_queries"];
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    //UIの更新
                    searchField.text = suggestion;
                    searchField.placeholder = @"Wikipedia";
                    [D setObject:@"Wikipedia" forKey:@"SearchEngine"];
                    [self enterSearchField:nil];
                    [ActivityIndicator off];
                });
                
                suggestion = nil;
            });
        });
    }
}

- (IBAction)enterURLField:(id)sender {
    
    if ( [urlField.text isEqualToString:BLANK] ) {
        
        [urlField resignFirstResponder];
        
        return;
    }
    
    NSString *encodedUrl = [DeleteWhiteSpace string:urlField.text];
    [_wv loadRequestWithString:encodedUrl];
    
    encodedUrl = nil;
}

- (IBAction)onUrlField: (id)sender {
    
    //URLフィールドが選択された場合はプロトコルありの物に差し替える
    urlField.text = [_wv.request URL].absoluteString;
    
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
    NSString *copyURL = [[_wv.request URL] absoluteString];
    
    if ( ![EmptyCheck string:copyURL] ) {

        if ( ![EmptyCheck string:loadStartURL] ) {
            
            if ( ![EmptyCheck string:[startupUrlList objectAtIndex:0]] ) {
             
                copyURL = [urlList objectAtIndex:0];
                
            } else {
                
                copyURL = [startupUrlList objectAtIndex:0];
            }
            
        } else {
            
            copyURL = loadStartURL;
        }
    }
    
    if ( copyURL != nil ) {
     
        UIActionSheet *sheet = [[UIActionSheet alloc]
                                initWithTitle:[NSString stringWithFormat:@"%@\n%@", _wv.pageTitle, copyURL]
                                delegate:self
                                cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:nil
                                otherButtonTitles:@"タイトルをコピー", @"URLをコピー", @"タイトルとURLをコピー", nil];
        [sheet showInView:self.view];
        
        copyURL = nil;
        sheet = nil;
    }
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
        } else {
            return;
        }
        
        searchField.placeholder = searchEngineName;
        [D setObject:searchEngineName forKey:@"SearchEngine"];
        [searchField becomeFirstResponder];
        
    }else if ( actionSheetNo == 1 ) {
        
        if ( buttonIndex == 0 ) {
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                NSString *postText = BLANK;
                
                if ( [urlField.text boolWithRegExp:@"(https?://)?shindanmaker.com/[0-9]+"] ) {
                    
                    NSLog(@"Shindanmaker Post");
                    
                    NSData *wvData = [NSURLConnection sendSynchronousRequest:[_wv request]
                                                            returningResponse:nil
                                                                        error:nil];
                    
                    if ( wvData != nil ) {
                        
                        postText = [[NSString alloc] initWithData:wvData
                                                         encoding:NSUTF8StringEncoding];
                        
                        postText = [postText deleteWord:@"\n"];
                        postText = [postText replaceWord:@"\t" replacedWord:@" "];
                        postText = [postText replaceWord:@"  " replacedWord:@" "];
                        postText = [postText stringWithRegExp:@"this.select...>.{1,140}?<.textarea>"];
                        postText = [postText deleteWord:@"this.select()\">"];
                        postText = [postText deleteWord:@"</textarea>"];
                        
                    } else {
                        
                        [ShowAlert error:@"データ取得に失敗しました。"];
                        
                        return;
                    }
                    
                } else {
                    
                    if ( [EmptyCheck check:[D objectForKey:@"WebPagePostFormat"]] ) {
                        
                        postText = [D objectForKey:@"WebPagePostFormat"];
                        
                    } else {
                        
                        postText = @" \"[title]\" [url] ";
                        [D setObject:postText forKey:@"WebPagePostFormat"];
                    }
                    
                    postText = [postText replaceWord:@"[title]" replacedWord:_wv.pageTitle];
                    
                    NSString *copyURL = [[_wv.request URL] absoluteString];
                    
                    if ( ![EmptyCheck string:copyURL] ) {
                        
                        if ( ![EmptyCheck string:loadStartURL] ) {
                            
                            if ( ![EmptyCheck string:[startupUrlList objectAtIndex:0]] ) {
                                
                                copyURL = [urlList objectAtIndex:0];
                                
                            } else {
                                
                                copyURL = [startupUrlList objectAtIndex:0];
                            }
                            
                        } else {
                            
                            copyURL = loadStartURL;
                        }
                    }
                    
                    postText = [postText replaceWord:@"[url]" replacedWord:copyURL];
                }
                
                NSNotification *notification = [NSNotification notificationWithName:@"SetTweetViewText"
                                                                             object:nil
                                                                           userInfo:@{@"Text":postText}];
                [[NSNotificationCenter defaultCenter] postNotification:notification];
                
                if ( APP_DELEGATE.tabBarController.selectedIndex == 0 ) {
                    
                    [self pushComposeButton:nil];
                    
                } else {
                 
                    APP_DELEGATE.tabBarController.selectedIndex = 0;
                }
            });
            
        }else if ( buttonIndex == 1 ) {
            
            //NSLog(@"selectString: %@", _wv.selectString);
            
            if ( [EmptyCheck check:_wv.selectString] ) {
                
                actionSheetNo = 7;
                
                UIActionSheet *sheet = [[UIActionSheet alloc]
                                        initWithTitle:@"引用投稿"
                                        delegate:self
                                        cancelButtonTitle:@"Cancel"
                                        destructiveButtonTitle:nil
                                        otherButtonTitles:@"選択文字を投稿", @"選択文字に引用符を付けて投稿",
                                        @"URL･タイトルと選択文字を投稿", nil];
                [sheet showInView:self.view];
                
            } else {
                
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
                NSString *documentTitle = _wv.pageTitle;
                
                NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@".*[0-9,]+×[0-9,]+ ?(pixels|ピクセル)$" 
                                                                                        options:0 
                                                                                          error:&error];
                
                NSTextCheckingResult *match = [regexp firstMatchInString:documentTitle 
                                                                 options:0 
                                                                   range:NSMakeRange(0, documentTitle.length)];
                
                @autoreleasepool {
                    
                    [_grayView performSelectorInBackground:@selector(on) withObject:nil];
                }
                
                if ( match.numberOfRanges != 0 ) {
                    
                    //NSLog(@"Image save");
                    
                    @autoreleasepool {
                        
                        //画像保存開始
                        [self performSelectorInBackground:@selector(saveImage) withObject:nil];
                    }
                    
                } else {
                    
                    //NSLog(@"File save");
                    
                    //ファイル保存開始
                    [self selectDownloadUrl];
                }
            }
            
        }else if ( buttonIndex == 4 ) {
            
            if ( ![EmptyCheck check:[D arrayForKey:@"Bookmark"]] ) {
                
                [D setObject:BLANK_ARRAY forKey:@"Bookmark"];
            }
            
            NSMutableArray *bookMarkArray = [[NSMutableArray alloc] initWithArray:[D arrayForKey:@"Bookmark"]];
            
            //登録済みURLのチェック
            BOOL check = YES;
            for ( NSDictionary *dic in bookMarkArray ) {
                
                if ( [[dic objectForKey:@"URL"] isEqualToString:[[_wv.request URL] absoluteString]] ) {
                    
                    check = NO;
                }
            }
            
            if ( check ) {
                
                NSMutableDictionary *addBookmark = [NSMutableDictionary dictionaryWithObject:_wv.pageTitle forKey:@"Title"];
                [addBookmark setValue:[[_wv.request URL] absoluteString] forKey:@"URL"];
                
                [bookMarkArray addObject:addBookmark];
                
                [D setObject:bookMarkArray forKey:@"Bookmark"];
                
            } else {
                
                [ShowAlert error:@"登録済みのURLです。"];
            }
            
        }else if ( buttonIndex == 5 ) {
            
            NSString *useragent = IPHONE_USERAGENT;
            
            if ( [[D objectForKey:@"UserAgent"] isEqualToString:@"FireFox"] ) {
                
                useragent = FIREFOX_USERAGENT;
                
            }else if ( [[D objectForKey:@"UserAgent"] isEqualToString:@"iPad"] ) {
                
                useragent = IPAD_USERAFENT;
            }
            
            NSString *adDeleteUrl = [NSString stringWithString:accessURL];
            NSURL *URL = [NSURL URLWithString:adDeleteUrl];
            
            ASIHTTPRequest *httpRequest = [ASIHTTPRequest requestWithURL:URL];
            ASIHTTPRequest *wHttpRequest = httpRequest;
            
            [httpRequest setUserAgentString:useragent];
            
            [httpRequest setCompletionBlock:^ {
                
                NSString *sourceCode = nil;
                
                int encodingList[] = {
                    
                    NSUTF8StringEncoding,           // UTF-8
                    NSShiftJISStringEncoding,       // Shift_JIS
                    NSJapaneseEUCStringEncoding,    // EUC-JP
                    NSISO2022JPStringEncoding,      // JIS
                    NSUnicodeStringEncoding,        // Unicode
                    NSASCIIStringEncoding           // ASCII
                };
                
                NSInteger max = sizeof( encodingList ) / sizeof( encodingList[0] );
                
                for ( NSInteger i = 0; i < max; i++ ) {
                    
                    sourceCode = [[NSString alloc] initWithData:wHttpRequest.responseData
                                                       encoding:encodingList[i]];
                    
                    if ( sourceCode != nil ) break;
                }
                
                if ( sourceCode != nil ) {
                    
                    sourceCode = [sourceCode replaceWord:@"width='300' height='250'><a href='http://d.href.asia/nw/d/ck.php"
                                            replacedWord:@"width='0' height='0'><a href='http://d.href.asia/nw/d/ck.php"];
                    sourceCode = [sourceCode deleteWord:@"accesstrade.net"];
                    sourceCode = [sourceCode deleteWord:@"adingo.jp"];
                    sourceCode = [sourceCode deleteWord:@"amoad.com"];
                    sourceCode = [sourceCode deleteWord:@"spstatic.ameba.jp"];
                    sourceCode = [sourceCode deleteWord:@"searchteria.co.jp/ad"];
                    sourceCode = [sourceCode deleteWord:@"ad.douga-kan.com"];
                    sourceCode = [sourceCode deleteWord:@"mo.preaf.jp"];
                    sourceCode = [sourceCode deleteWord:@"adlantis"];
                    sourceCode = [sourceCode deleteWord:@"ad-stir.com"];
                    sourceCode = [sourceCode deleteWord:@"adpimg.yicha.jp"];
                    sourceCode = [sourceCode deleteWord:@"static.adroute.focas.jp"];
                    sourceCode = [sourceCode deleteWord:@"ad.searchteria.co.jp"];
                    sourceCode = [sourceCode deleteWord:@"ad.maist.jp"];
                    sourceCode = [sourceCode deleteWord:@"adclr.jp"];
                    sourceCode = [sourceCode deleteWord:@"blog.fc2.com/adclick"];
                    sourceCode = [sourceCode deleteWord:@"aimg.fc2.com"];
                    sourceCode = [sourceCode deleteWord:@"i.amoad.com"];
                    sourceCode = [sourceCode deleteWord:@"i-mobile.co.jp"];
                    sourceCode = [sourceCode deleteWord:@"imobile_"];
                    sourceCode = [sourceCode deleteWord:@"microad.jp"];
                    sourceCode = [sourceCode deleteWord:@"AdLantisLoader.js"];
                    sourceCode = [sourceCode deleteWord:@"AdLoader.js"];
                    sourceCode = [sourceCode deleteWord:@"adstir.js"];
                    sourceCode = [sourceCode deleteWord:@"adssp.js"];
                    sourceCode = [sourceCode deleteWord:@"asad.js"];
                    sourceCode = [sourceCode deleteWord:@"smtad.js"];
                    sourceCode = [sourceCode deleteWord:@"ads.js"];
                    sourceCode = [sourceCode deleteWord:@"show_ad"];
                    sourceCode = [sourceCode deleteWord:@"trigger_liv.js"];
                    sourceCode = [sourceCode deleteWord:@"ajs.php"];
                    sourceCode = [sourceCode deleteWord:@"js/ad.js"];
                    sourceCode = [sourceCode deleteWord:@"Spad.js"];
                    sourceCode = [sourceCode deleteWord:@"spad.js"];
                    sourceCode = [sourceCode deleteWord:@"j.sprout-ad.com"];
                    sourceCode = [sourceCode deleteWord:@"api.unthem.com"];
                    sourceCode = [sourceCode deleteWord:@"anchovy.js"];
                    sourceCode = [sourceCode deleteWord:@"bongore.js"];
                    sourceCode = [sourceCode deleteWord:@"chorizo.js"];
                    
//                    NSLog(@"sourceCode: %@", sourceCode);
                    
                    [_wv loadHTMLString:sourceCode baseURL:URL];
                }
            }];
            
            [httpRequest startAsynchronous];
            
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
            
                if ( [EmptyCheck check:_wv.selectString] ) {
                    
                    reqUrl = [NSString stringWithFormat:@"fastever://?text=%@\n%@\n>>%@\n", _wv.pageTitle, accessURL, _wv.selectString];
                    
                } else {
                    
                    reqUrl = [NSString stringWithFormat:@"fastever://?text=%@\n%@\n", _wv.pageTitle, accessURL];
                }
                
                [[UIApplication sharedApplication] openURL:
                 [NSURL URLWithString:(__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                            (__bridge CFStringRef)reqUrl, 
                                                                                                            NULL, 
                                                                                                            NULL, 
                                                                                                            kCFStringEncodingUTF8)]];
            
            } else {
                
                [ShowAlert error:@"FastEverをインストール後使用してください。"];
            }
        
        //PC版UAで開き直す
        }else if ( buttonIndex == 8 ) {
            
            APP_DELEGATE.pcUaMode = YES;
            [D setObject:@"FireFox" forKey:@"UserAgent"];
            [self pushComposeButton:nil];
        
        }else if ( buttonIndex == 9 ) {
            
            //Safariで開く
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:accessURL]];
        }
        
    }else if ( actionSheetNo == 2 || actionSheetNo == 3 || actionSheetNo == 4 || actionSheetNo == 5 || actionSheetNo == 6 ) {
        
        if ( buttonIndex == actionSheetNo ) {
            
            //キャンセルされた場合はホームページを開く
            [_wv loadRequestWithString:[D objectForKey:@"HomePageURL"]];
            
        } else {
            
            //選択されたURLを開く
            [_wv loadRequestWithString:[startupUrlList objectAtIndex:buttonIndex]];
        }
        
    }else if ( actionSheetNo == 7 ) {
        
        NSString *quoteText = @"";
        
        if ( buttonIndex == 0 ) {
        
            if ( ![EmptyCheck check:_wv.selectString] ) return;
            
            quoteText = _wv.selectString;
            [self pushComposeButton:nil];
        
        }else if ( buttonIndex == 1 ) {
        
            if ( ![EmptyCheck check:_wv.selectString] ) return;
            
            quoteText = [NSString stringWithFormat:@">>%@", _wv.selectString];
            [self pushComposeButton:nil];
        
        }else if ( buttonIndex == 2 ) {
        
            if ( ![EmptyCheck check:_wv.selectString] ) return;
            
            if ( [EmptyCheck check:[D objectForKey:@"QuoteFormat"]] ) {
                
                quoteText = [D objectForKey:@"QuoteFormat"];
                
            } else {
                
                quoteText = @" \"[title]\" [url] >>[quote]";
                [D setObject:quoteText
                      forKey:@"QuoteFormat"];
            }
            
            NSString *copyURL = [[_wv.request URL] absoluteString];
            
            if ( ![EmptyCheck string:copyURL] ) {
                
                if ( ![EmptyCheck string:loadStartURL] ) {
                    
                    if ( ![EmptyCheck string:[startupUrlList objectAtIndex:0]] ) {
                        
                        copyURL = [urlList objectAtIndex:0];
                        
                    } else {
                        
                        copyURL = [startupUrlList objectAtIndex:0];
                    }
                    
                } else {
                    
                    copyURL = loadStartURL;
                }
            }
            
            quoteText = [quoteText replaceWord:@"[title]" replacedWord:_wv.pageTitle];
            quoteText = [quoteText replaceWord:@"[url]" replacedWord:copyURL];
            quoteText = [quoteText replaceWord:@"[quote]" replacedWord:_wv.selectString];
            
            [self pushComposeButton:nil];
        
        } else {
            
            APP_DELEGATE.postTextType = BLANK;
        }
    
        NSNotification *notification = [NSNotification notificationWithName:@"SetTweetViewText"
                                                                     object:nil
                                                                   userInfo:@{@"Text":quoteText}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            APP_DELEGATE.tabBarController.selectedIndex = 0;
        });
        
    }else if ( actionSheetNo == 8 ) {
        
        if ( [EmptyCheck check:_wv.selectString] ) {
            
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
            } else {
                return;
            }
            
            searchField.text = _wv.selectString;
            searchField.placeholder = searchEngineName;
            [D setObject:searchEngineName forKey:@"SearchEngine"];
            
            [self enterSearchField:nil];
        }
    
    }else if ( actionSheetNo == 9 ) {
        
        if ( buttonIndex == 0 ) {
            
            [self requestStart:accessURL];
            
        }else if ( buttonIndex == 1 ) {
            
            [self requestStart:urlField.text];
            
        } else {
            
            [_grayView off];
        }
        
    }else if ( actionSheetNo == 10 ) {
        
        if ( buttonIndex == 0 ) {
            
            [self requestStart:accessURL];
            
        }else if ( buttonIndex == 1 ) {
            
            [self requestStart:[NSString stringWithFormat:@"http://%@", urlField.text]];
            
        }else if ( buttonIndex == 2 ) {
            
            [self requestStart:[NSString stringWithFormat:@"https://%@", urlField.text]];
            
        } else {
            
            [_grayView off];
        }
    
    }else if ( actionSheetNo == 11 ) {
        
        if ( buttonIndex == 0 ) {
            
            [self resetUserAgent];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }else if ( actionSheetNo == 12 ) {
        
        if ( buttonIndex == 0 ) {
            
            [self resetUserAgent];
            [self dismissViewControllerAnimated:YES completion:nil];
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
                
                APP_DELEGATE.postText = P_BOARD.string;
                
                [self pushComposeButton:nil];
                
            }else if ( buttonIndex == 1 ) {
                
                [_wv loadRequestWithString:[CreateSearchURL google:P_BOARD.string]];
                
            }else if ( buttonIndex == 2 ) {
                
                [self selectOpenUrl];
            }
            
        }@catch ( NSException *e ) {}
        
    }else if ( actionSheetNo == 15 ) {
        
        if ( buttonIndex == 0 ) {
            
        }else if ( buttonIndex == 1 ) {
            
            //ペーストボードから開く場合
            startupUrlList = urlList;
            
        } else {
            
            //キャンセルされた場合はホームページを開く
            [_wv loadRequestWithString:[D objectForKey:@"HomePageURL"]];
            
            return;
        }
        
        [self selectUrl];
        
    }else if ( actionSheetNo == 16 ) {
        
        NSString *copyURL = [[_wv.request URL] absoluteString];
        
        if ( ![EmptyCheck string:copyURL] ) copyURL = loadStartURL;
        
        if ( buttonIndex == 0 ) {
            
            [P_BOARD setString:_wv.pageTitle];
            
        }else if ( buttonIndex == 1 ) {
            
            [P_BOARD setString:copyURL];
            
        }else if ( buttonIndex == 2 ) {
            
            [P_BOARD setString:[NSString stringWithFormat:@"\"%@\" %@", _wv.pageTitle, copyURL]];
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
        
    } else {
        
        [ShowAlert title:@"保存完了" message:@"カメラロールに保存しました。"];
    }
    
    [_grayView off];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( alertTextNo == 1 ) {
    
        if ( buttonIndex == 1 ) {
     
            //NSLog(@"SetHomePage: %@", alertText.text);
            [D setObject:alertText.text forKey:@"HomePageURL"];
            
            alertTextNo = 0;
            alertText.text = BLANK;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender {

    //NSLog(@"textFieldShouldReturn");
    
    if ( alertTextNo == 1 ) {
    
        //NSLog(@"SetHomePage: %@", alertText.text);
        [D setObject:alertText.text forKey:@"HomePageURL"];
        
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
//    if ( navigationType == UIWebViewNavigationTypeLinkClicked ) {
//        
//        NSLog(@"LinkClicked");
//    }
    
    if ( [EmptyCheck string:request.URL.absoluteString] ) {
        
        accessURL = request.URL.absoluteString;
    }
    
    //広告をブロック
    if ( [ADBlock check:accessURL] ) return NO;
    
    //NSLog(@"%@", [[request URL] absoluteString]);
    
    //フルサイズ取得が有効
    if ( [D boolForKey:@"FullSizeImage"] ) {
        
        //画像サービスのURLかスキャン
        NSString *fullSizeImageUrl = [FullSizeImage urlString:accessURL];
        
        //スキャン済みURLが変わっていたらアクセスし直し
        if ( ![fullSizeImageUrl isEqualToString:accessURL] ) {
            
            //NSLog(@"FullSizeImage ReAccess");
            [_wv loadRequestWithString:fullSizeImageUrl];
            
            return NO;
        }
    }
    
    //Amazonのアフィリンクの場合無効化して再アクセス
    if ( [accessURL boolWithRegExp:@"https?://(www\\.)?amazon\\.co\\.jp/((exec/obidos|o)/ASIN|dp|gp/product)/[A-Z0-9]{10}.*(/|[\\?&]tag=)[-_a-zA-Z0-9]+-22/?"] ) {
        
        NSString *affiliateCuttedUrl = [AmazonAffiliateCutter string:accessURL];
        
        if ( ![affiliateCuttedUrl isEqualToString:accessURL] ) {
            
            //NSLog(@"Affiliate cutted access: %@", affiliateCuttedUrl);
            [_wv loadRequestWithString:affiliateCuttedUrl];
            
            return NO;
        }
    }
    
    if ( [accessURL boolWithRegExp:@"about:blank|https?://.*"] ) {
        
        //そのままアクセス出来そうなURL
        //NSLog(@"http(s) address");
        
    } else {
        
        //NSLog(@"not http(s) address");
        
        NSURL *URL = [NSURL URLWithString:accessURL];
        BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:URL];
        
        if ( canOpen ) {
            
            //URLScheme
            NSLog(@"scheme");
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [[UIApplication sharedApplication] openURL:URL];
            
            return NO;
            
        } else {
            
            //そのままアクセス出来なそうでURLSchemeでもない
            //http://を付けてみる
            NSLog(@"add protocol");
            
            [_wv loadRequestWithString:[NSString stringWithFormat:@"http://%@", accessURL]];
            
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
    
    _wv.canGoBack ? ( backButton.enabled = YES ) : ( backButton.enabled = NO );
    _wv.canGoForward ? ( forwardButton.enabled = YES ) : ( forwardButton.enabled = NO );
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
        
    } else {
        
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
            
        } else {
            
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
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        
        if ( [request.URL.absoluteString rangeOfString:@"pixiv.net"].location != NSNotFound ) {
            
            [request setValue:@"http://www.pixiv.net/" forHTTPHeaderField:@"Referer"];
            [request setHTTPShouldHandleCookies:NO];
        }
        
        //ダウンロードリクエスト開始
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
        
    } else {
     
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
    
    [_grayView off];
    asyncData = nil;
    asyncConnection = nil;
    downloading = NO;
    bytesLabel.hidden = YES;
    progressBar.hidden = YES;
    downloadCancelButton.hidden = YES;
    APP_DELEGATE.urlSchemeDownloadUrl = BLANK;
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
    if ( !APP_DELEGATE.pcUaMode && ![[D objectForKey:@"UserAgentReset"] isEqualToString:@"OFF"] ) {
        
        //NSLog(@"Reset: %@", [D objectForKey:@"UserAgentReset"]);
        
        [D setObject:[D objectForKey:@"UserAgentReset"] forKey:@"UserAgent"];
    }
}

- (void)rotateView:(int)mode {
 
    //NSLog(@"rotateView: %d", mode);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.05];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationRepeatCount:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];

    //縦
    if ( mode == 0 ) {
        
        if ( fullScreen ) {
            
            topBar.frame = CGRectMake(0, -44, SCREEN_WIDTH, TOOL_BAR_HEIGHT);
            _wv.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            bottomBar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, TOOL_BAR_HEIGHT);
            
            if ( editing ) {
                
                urlField.frame = CGRectMake(12, -44, 75, 31);
                searchField.frame = CGRectMake(97, -44, 180, 31);
                
            } else {
                
                urlField.frame = CGRectMake(12, -44, 180, 31);
                searchField.frame = CGRectMake(202, -44, 75, 31);
            }
            
        } else {
            
            topBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, TOOL_BAR_HEIGHT);
            _wv.frame = CGRectMake(0, TOOL_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - TOOL_BAR_HEIGHT * 2);
            bottomBar.frame = CGRectMake(0, SCREEN_HEIGHT - TOOL_BAR_HEIGHT, SCREEN_WIDTH, TOOL_BAR_HEIGHT);
            
            if ( editing ) {
                
                urlField.frame = CGRectMake(12, 7, 75, 31);
                searchField.frame = CGRectMake(97, 7, 180, 31);
                
            } else {
                
                urlField.frame = CGRectMake(12, 7, 180, 31);
                searchField.frame = CGRectMake(202, 7, 75, 31);
            }    
        }
     
    //横
    } else {
        
        if ( fullScreen ) {

            topBar.frame = CGRectMake(0, -44, SCREEN_HEIGHT, TOOL_BAR_HEIGHT);
            _wv.frame = CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH);
            bottomBar.frame = CGRectMake(0, SCREEN_WIDTH, SCREEN_HEIGHT, TOOL_BAR_HEIGHT);
            
            if ( editing ) {
                
                urlField.frame = CGRectMake(12, -44, 135, 31);
                searchField.frame = CGRectMake(157, -44, 280 + retina4InchOffset, 31);
                
            } else {
                
                urlField.frame = CGRectMake(12, -44, 280 + retina4InchOffset, 31);
                searchField.frame = CGRectMake(302, -44, 135, 31);
            }
            
        } else {

            topBar.frame = CGRectMake(0, 0, SCREEN_HEIGHT, TOOL_BAR_HEIGHT);
            _wv.frame = CGRectMake(0, TOOL_BAR_HEIGHT, SCREEN_HEIGHT, SCREEN_WIDTH - TOOL_BAR_HEIGHT * 2);
            bottomBar.frame = CGRectMake(0, SCREEN_WIDTH - TOOL_BAR_HEIGHT, SCREEN_HEIGHT, TOOL_BAR_HEIGHT);
            
            if ( editing ) {
                
                urlField.frame = CGRectMake(12, 7, 135, 31);
                searchField.frame = CGRectMake(157, 7, 280 + retina4InchOffset, 31);
                
            } else {
                
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
        
    } else {
        
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
            
        } else {
            
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

- (void)adBlock {
    
}

- (void)setViewSize {
    
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] < 6.0 ) {
        
        NSLog(@"setViewSize iOS5");
        
    } else {
        
        NSLog(@"setViewSize iOS6");
        
        //画面回転に伴ったUIの変更や処理をここで行う
        if ( ORIENTATION == UIDeviceOrientationLandscapeRight ||
             ORIENTATION == UIDeviceOrientationLandscapeLeft ) {
            
            //左右
            [self rotateView:1];
            
        } else {
            
            //縦
            [self rotateView:0];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    
    NSLog(@"%s", __func__);
    
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    
    NSLog(@"%s", __func__);
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    
    NSLog(@"%s", __func__);
    
//    APP_DELEGATE.browserOpenMode = NO;
//    APP_DELEGATE.urlSchemeDownloadUrl = BLANK;
//    
//    [self setTopBar:nil];
//    [self setBottomBar:nil];
//    [self setSearchButton:nil];
//    [self setCloseButton:nil];
//    [self setReloadButton:nil];
//    [self setBackButton:nil];
//    [self setForwardButton:nil];
//    [self setMenuButton:nil];
//    [self setFlexibleSpace:nil];
//    [self setUrlField:nil];
//    [self setSearchField:nil];
//    [self setComposeButton:nil];
//    [self setBytesLabel:nil];
//    [self setProgressBar:nil];
//    [self setDownloadCancelButton:nil];
//    [self setBookmarkButton:nil];
    
    [super viewDidUnload];
}

- (void)dealloc {
    
    NSLog(@"%s", __func__);
    
    APP_DELEGATE.browserOpenMode = NO;
    APP_DELEGATE.urlSchemeDownloadUrl = BLANK;
    
    if ( _wv.loading ) [_wv stopLoading];
    _wv.delegate = nil;

    REMOVE_SAFETY(_wv);
    REMOVE_SAFETY(urlField);
    REMOVE_SAFETY(searchField);
    REMOVE_SAFETY(topBar);
    REMOVE_SAFETY(bottomBar);
    REMOVE_SAFETY(bytesLabel);
    REMOVE_SAFETY(progressBar);
    REMOVE_SAFETY(downloadCancelButton);
}

@end
