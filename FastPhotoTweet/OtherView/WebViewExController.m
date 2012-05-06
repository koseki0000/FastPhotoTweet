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

#define TOP_BAR [NSArray arrayWithObjects:nil]
#define BOTTOM_BAR [NSArray arrayWithObjects:closeButton, flexibleSpace, reloadButton, flexibleSpace, backButton, flexibleSpace, forwardButton, flexibleSpace, composeButton, flexibleSpace, menuButton, nil]

#define BLANK @""

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
@synthesize searchButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    //メモリ管理が正常になるらしい呪文(本来は電話番号やら住所の文字の自動リンク)
    wv.dataDetectorTypes = UIDataDetectorTypeNone;

    grayView = [[GrayView alloc] init];
    [wv addSubview:grayView];
    
    //アプリがアクティブになった場合の通知を受け取る設定
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(becomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    
    d = [NSUserDefaults standardUserDefaults];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if ( [d boolForKey:@"ClearBrowserSearchField"] ) {
     
        searchField.clearsOnBeginEditing = YES;
        
    }else {
        
        searchField.clearsOnBeginEditing = NO;
    }
    
    accessURL = BLANK;
    //[accessURL retain];
    
    [self setSearchEngine];
    
    //ツールバーにボタンをセット
    [bottomBar setItems:BOTTOM_BAR animated:NO];
    
    //ページをロード
    [wv loadRequestWithString:appDelegate.openURL];
    
    appDelegate.isBrowserOpen = [NSNumber numberWithInt:1];
}

- (void)becomeActive:(NSNotification *)notification {
    
    NSLog(@"WebViewEx becomeActive");
    NSLog(@"fastGoogleMode: %d webPageShareMode: %d", [appDelegate.fastGoogleMode intValue], [appDelegate.webPageShareMode intValue]);
    
    if ( [appDelegate.fastGoogleMode intValue] == 1 ) {
        
        [wv loadRequestWithString:appDelegate.openURL];
        
        appDelegate.fastGoogleMode = [NSNumber numberWithInt:0];
        
    }else if ( [appDelegate.webPageShareMode intValue] == 1 ) {
        
        appDelegate.webPageShareMode = [NSNumber numberWithInt:0];
        
        [self pushComposeButton:nil];
    }
}

- (void)setSearchEngine {
    
    if ( ![EmptyCheck check:[d objectForKey:@"SearchEngine"]] ) {
        
        NSLog(@"Set GoogleEngine");
        
        [d setObject:@"Google" forKey:@"SearchEngine"];
    }
    
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
                                              @"Wikipedia", @"Twitter検索", nil];
    [sheet showInView:self.view];
}

- (IBAction)pushComposeButton:(id)sender {
 
    appDelegate.openURL = [[wv.request URL] absoluteString];
    
    [self closeWebView];
}

- (IBAction)pushCloseButton:(id)sender {
    
    appDelegate.openURL = [d objectForKey:@"HomePageURL"];
    
    [self closeWebView];
}

- (void)closeWebView {
    appDelegate.isBrowserOpen = [NSNumber numberWithInt:0];
    
    if ( wv.loading ) [wv stopLoading];
    wv.delegate = nil;
    [wv removeFromSuperview];
    
    [ActivityIndicator visible:NO];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)pushReloadButton:(id)sender {
    
    if ( [self reachability] ) {
        
        [wv loadRequestWithString:accessURL];
    }
}

- (IBAction)pushBackButton:(id)sender {
    
    if ( [self reachability] ) {
        
        [wv goBack];
    }
}

- (IBAction)pushForwardButton:(id)sender {
    
    if ( [self reachability] ) {
        
        [wv goForward];
    }
}

- (IBAction)pushMenuButton:(id)sender {
    
    actionSheetNo = 1;
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:@"機能選択"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"開いているページを投稿", @"ホームページを変更", @"Safariで開く", @"保存", nil];
    [sheet showInView:self.view];
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
        
        searchURL = @"http://ja.wikipedia.org/wiki/";
        
    }else if ( [[d objectForKey:@"SearchEngine"] isEqualToString:@"Twitter"] ) {
        
        searchURL = @"https://mobile.twitter.com/searches?q=";
    }
    
    NSString *encodedSearchWord = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
                                                                                                (__bridge CFStringRef)searchField.text, 
                                                                                                NULL, 
                                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]", 
                                                                                                kCFStringEncodingUTF8);
    
    NSLog(@"URL: %@", [NSString stringWithFormat:@"%@%@", searchURL, encodedSearchWord]);
    
    [wv loadRequestWithString:[NSString stringWithFormat:@"%@%@", searchURL, encodedSearchWord]];
}

- (IBAction)enterURLField:(id)sender {
    
    if ( [urlField.text isEqualToString:BLANK] ) {
        
        [urlField resignFirstResponder];
        return;
    }
    
    if ( [RegularExpression boolRegExp:urlField.text regExpPattern:@"^https?://.*"] ) {
        
        NSLog(@"http(s) address");
        
        [wv loadRequestWithString:urlField.text];
        
    }else {
        
        NSLog(@"not http(s) address");
        
        BOOL canOpen = NO;
        
        canOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlField.text]];
        
        if ( canOpen ) {
            
            NSLog(@"scheme");
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlField.text]];
            
        }else {
            
            NSLog(@"add protocol");
            
            [wv loadRequestWithString:[NSString stringWithFormat:@"http://%@", urlField.text]];
        }
    }
}

- (IBAction)onUrlField: (id)sender {
    
    //URLフィールドが選択された場合はプロトコルありの物に差し替える
    urlField.text = [wv.request URL].absoluteString;
    
    [UITextField beginAnimations:nil context:nil];
    [UITextField setAnimationDuration:0.1];
    [UITextField setAnimationDelay:0.0];
    [UITextField setAnimationRepeatCount:1.0];
    [UITextField setAnimationCurve:UIViewAnimationCurveLinear];
    urlField.frame = CGRectMake(12, 7, 180, 31);
    searchField.frame = CGRectMake(202, 7, 75, 31);
    [UITextField commitAnimations];
}

- (IBAction)leaveUrlField: (id)sender {
    
    //URLフィールドから選択が外れた場合はプロトコルなしの表示にする
    urlField.text = [ProtocolCutter url:urlField.text];
    
    [UITextField beginAnimations:nil context:nil];
    [UITextField setAnimationDuration:0.1];
    [UITextField setAnimationDelay:0.0];
    [UITextField setAnimationRepeatCount:1.0];
    [UITextField setAnimationCurve:UIViewAnimationCurveLinear];
    urlField.frame = CGRectMake(12, 7, 180, 31);
    searchField.frame = CGRectMake(202, 7, 75, 31);
    [UITextField commitAnimations];
}

- (IBAction)onSearchField: (id)sender {
    
    [UITextField beginAnimations:nil context:nil];
    [UITextField setAnimationDuration:0.05];
    [UITextField setAnimationDelay:0.0];
    [UITextField setAnimationRepeatCount:1.0];
    [UITextField setAnimationCurve:UIViewAnimationCurveLinear];
    urlField.frame = CGRectMake(12, 7, 75, 31);
    searchField.frame = CGRectMake(97, 7, 180, 31);
    [UITextField commitAnimations];
}

- (IBAction)leaveSearchField: (id)sender {
    
    [UITextField beginAnimations:nil context:nil];
    [UITextField setAnimationDuration:0.05];
    [UITextField setAnimationDelay:0.0];
    [UITextField setAnimationRepeatCount:1.0];
    [UITextField setAnimationCurve:UIViewAnimationCurveLinear];
    urlField.frame = CGRectMake(12, 7, 180, 31);
    searchField.frame = CGRectMake(202, 7, 75, 31);
    [UITextField commitAnimations];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
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
        }else {
            return;
        }
        
        searchField.placeholder = searchEngineName;
        [d setObject:searchEngineName forKey:@"SearchEngine"];
        [searchField becomeFirstResponder];
        
    }else if ( actionSheetNo == 1 ) {
        
        if ( buttonIndex == 0 ) {
            
            appDelegate.postText = [NSString stringWithFormat:@"\"%@\" %@", wv.pageTitle, [[wv.request URL] absoluteString]];
            [self pushComposeButton:nil];
            
        }else if ( buttonIndex == 1 ) {
            
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
        
        }else if ( buttonIndex == 2 ) {
            
            //Safariで開く
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:accessURL]];
            
        }else if ( buttonIndex == 3 ) {
            
            if ( ![urlField.text isEqualToString:@""] ) {
                
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
                    
                    NSLog(@"Image save");
                
                    @autoreleasepool {
                        
                        //画像保存開始
                        [self performSelectorInBackground:@selector(saveImage) withObject:nil];
                    }
                    
                }else {
                    
                    NSLog(@"File save");
                    
                    //ファイル保存開始
                    [self requestStart];
                }
            }
        }
    }
}

- (void)saveImage {
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:accessURL]];
    UIImage *image = [[UIImage alloc] initWithData:data];
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), nil);
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
     
            NSLog(@"SetHomePage: %@", alertText.text);
            [d setObject:alertText.text forKey:@"HomePageURL"];
            
            alertTextNo = 0;
            alertText.text = BLANK;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender {

    NSLog(@"textFieldShouldReturn");
    
    if ( alertTextNo == 1 ) {
    
        NSLog(@"SetHomePage: %@", alertText.text);
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
    
    //NSLog(@"URL: %@", [[request URL] absoluteString]);
    
    accessURL = [[request URL] absoluteString];
    
    urlField.text = [ProtocolCutter url:[[request URL] absoluteString]];
    [ActivityIndicator visible:YES];
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    accessURL = [[webView.request URL] absoluteString];
    
    [ActivityIndicator visible:NO];
    [self updateWebBrowser];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    if ( error.code != -999 ) {
     
        NSLog(@"%@", error.description);
        
        [ShowAlert error:error.localizedDescription];
        
        [ActivityIndicator visible:NO];
        [self updateWebBrowser];
    }
}

- (void)updateWebBrowser {
    
    urlField.text = [ProtocolCutter url:[[wv.request URL] absoluteString]];

    [self backForwordButtonVisible];
}

- (void)backForwordButtonVisible {
    
    if ( wv.canGoBack ) {
		backButton.enabled = YES;
	}else {
		backButton.enabled = NO;
	}
	
	if ( wv.canGoForward ) {
		forwardButton.enabled = YES;
	}else {
		forwardButton.enabled = NO;
	}
}

/* WebViewここまで */

/* 非同期通信ダウンロード */

- (void)requestStart {
    
    NSLog(@"requestStart: %@", accessURL);
    
    //キャッシュの削除
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    
    asyncConnection = nil;
    asyncData = nil;
    
    saveFileName = [accessURL lastPathComponent]; 
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:accessURL]];
    asyncConnection = [[NSURLConnection alloc] initWithRequest:request 
                                                      delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    NSLog(@"didReceiveResponse: %lldbytes", [response expectedContentLength]);
    
	asyncData = [[NSMutableData alloc] initWithData:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{

    //NSLog(@"didReceiveData");
    
	[asyncData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {

    NSLog(@"didFailWithError");
    
    [ShowAlert error:@"ダウンロードに失敗しました。"];
    [grayView off];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"connectionDidFinishLoading");
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *savePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:saveFileName];
    [manager createFileAtPath:savePath 
                     contents:asyncData 
                   attributes:nil];
    
    [ShowAlert title:@"保存完了" message:@"アプリ内ドキュメントフォルダに保存されました。ファイルへはPCのiTunesからアクセス出来ます。"];
    [grayView off];
}

/* 非同期通信ダウンロードここまで */

- (BOOL)reachability {
    
    BOOL result = NO;
    
    if ( [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable ) {
        
        result = YES;
        
    }else {
        
        [ShowAlert error:@"インターネットに接続されていません。"];
    }
    
    return result;
}

- (void)viewDidUnload {
    
    NSLog(@"WebViewExController viewDidUnload");
    
    appDelegate.isBrowserOpen = [NSNumber numberWithInt:0];
    appDelegate.fastGoogleMode = [NSNumber numberWithInt:0];
    appDelegate.webPageShareMode = [NSNumber numberWithInt:0];
    appDelegate.openURL = [d objectForKey:@"HomePageURL"];
    
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
    [super viewDidUnload];
}

//- (void)dealloc {
//    
//    NSLog(@"WebViewExController dealloc");
//    
//    appDelegate.isBrowserOpen = [NSNumber numberWithInt:0];
//    
//    [accessURL release];
//    
//    [topBar release];
//    [bottomBar release];
//    [searchButton release];
//    [closeButton release];
//    [reloadButton release];
//    [backButton release];
//    [forwardButton release];
//    [menuButton release];
//    [flexibleSpace release];
//    [urlField release];
//    [searchField release];
//    [composeButton release];
//    
//    if ( wv.loading ) [wv stopLoading];
//    wv.delegate = nil;
//    [wv release];
//
//    [super dealloc];
//}

@end
