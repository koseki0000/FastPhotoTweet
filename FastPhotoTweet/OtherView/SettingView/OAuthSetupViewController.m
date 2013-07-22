//
//  OAuthSetupViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/04/21.
//

#import "OAuthSetupViewController.h"
#import "AppDelegate.h"

@implementation OAuthSetupViewController
@synthesize bar;
@synthesize closeButton;
@synthesize pinField;
@synthesize doneButton;
@synthesize wv;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self ) {
        
        wv.frame = CGRectMake(0,
                              TOOL_BAR_HEIGHT,
                              SCREEN_WIDTH,
                              SCREEN_HEIGHT - TOOL_BAR_HEIGHT);
        
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    //OAConsumer設定
    consumer = [[OAConsumer alloc] initWithKey:OAUTH_KEY 
                                        secret:OAUTH_SECRET];
    
    grayView = [[GrayView alloc] init];
    [self.view addSubview:grayView];
    [grayView on];
    
    [self oaRequestStart];
}

- (void)oaRequestStart {
    
    //NSLog(@"oaRequestStart");
    
    wv.delegate = self;
	pinField.text = BLANK;
	
	NSURL *oaUrlGetRequestToken = [NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"];
	
	OAMutableURLRequest *oaReqGetRequestToken = 
    [[OAMutableURLRequest alloc] initWithURL:oaUrlGetRequestToken
									consumer:consumer
									   token:nil
									   realm:nil
						   signatureProvider:nil];
    
	[oaReqGetRequestToken setHTTPMethod:@"POST"];
	
	OADataFetcher *oaFetGetRequestToken = [[OADataFetcher alloc] init];
	
	[oaFetGetRequestToken fetchDataWithRequest:oaReqGetRequestToken
                                      delegate:self
                             didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                               didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
	
	[oaReqGetRequestToken release];
    [oaFetGetRequestToken release];
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    
    //NSLog(@"requestTokenTicket Finish");
    
    if ( ticket.didSucceed ) {
        
        //NSLog(@"ticket.didSucceed OK");
        
        NSString *responseBody = [[NSString alloc] initWithData:data 
                                                       encoding:NSUTF8StringEncoding];
        
        OAToken *requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        
        //keyとsecretを暗号化
        NSString *key = [UUIDEncryptor encryption:requestToken.key];
        NSString *secret = [UUIDEncryptor encryption:requestToken.secret];
        
        //NSLog(@"requestToken key: %@", requestToken.key);
        //NSLog(@"requestToken secret: %@", requestToken.secret);
        
        //暗号化したkeyとsecretを保存
        [USER_DEFAULTS setObject:key forKey:@"OAuthRequestTokenKey"];
        [USER_DEFAULTS setObject:secret forKey:@"OAuthRequestTokenSecret"];
        [USER_DEFAULTS synchronize];

        [responseBody release];
        
        NSString *urlString = [NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.key];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [wv loadRequest:req];
        [requestToken release];
        
    } else {
        
        //NSLog(@"ticket.didSucceed Error");
        
        [ShowAlert error:@"リクエストトークンの取得に失敗しました。"];
        
        [self enableButton];
    }
    
    [grayView off];
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    
    //NSLog(@"requestTokenTicket Error");
    
    [ShowAlert error:@"リクエストトークンの取得に失敗しました。"];
        
    [self enableButton];
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    
    //NSLog(@"accessTokenTicket Finish");
    
    if ( ticket.didSucceed ) {
        
        //NSLog(@"ticket.didSucceed OK");
        		
		NSString *responseBody = [[NSString alloc] initWithData:data
														encoding:NSUTF8StringEncoding];
        
		OAToken *accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		
        //NSLog(@"accessToken key: %@", accessToken.key);
        //NSLog(@"accessToken secret: %@", accessToken.secret);
        
        if ( ![EmptyCheck check:[USER_DEFAULTS dictionaryForKey:@"OAuthAccount"]] ) {
            
            //NSLog(@"init OAuthAccountDictionary");
            [USER_DEFAULTS setObject:[NSDictionary dictionary] forKey:@"OAuthAccount"];
        }
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[USER_DEFAULTS dictionaryForKey:@"OAuthAccount"]];
        
        int count = [USER_DEFAULTS integerForKey:@"AccountCount"];
        count++;
        [USER_DEFAULTS setInteger:count forKey:@"AccountCount"];
        
        //keyとsecretを暗号化
        NSString *key = [UUIDEncryptor encryption:accessToken.key];
        NSString *secret = [UUIDEncryptor encryption:accessToken.secret];
        
        NSArray *accountData = [NSArray arrayWithObjects:key, secret, nil];
        [dic setObject:accountData forKey:[NSString stringWithFormat:@"OAuthAccount_%d", count]];
        
        NSMutableDictionary *saveDic = [[[NSMutableDictionary alloc] initWithDictionary:dic] autorelease];
        [USER_DEFAULTS setObject:saveDic forKey:@"OAuthAccount"];
        
		[USER_DEFAULTS synchronize];
        
		[responseBody release];
		[accessToken release];
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.twitpicLinkMode = YES;
        
        [grayView off];
        [self dismissViewControllerAnimated:YES completion:nil];
		
	} else {
        
        //NSLog(@"ticket.didSucceed Error");
        
        [ShowAlert error:@"アクセストークンの取得に失敗しました。"];
        
        [self enableButton];
	}
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    
    //NSLog(@"accessTokenTicket Error");
    
    [ShowAlert error:@"アクセストークンの取得に失敗しました。"];
    
    [self enableButton];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType {
	
    //NSLog(@"URL: %@", [request URL].absoluteString);
    
	[ActivityIndicator visible:YES];
    
    if ( [[request URL].absoluteString isEqualToString:@"https://api.twitter.com/oauth/authorize"] ) {

        //NSLog(@"authorize");
        
        [grayView on];
    }
    
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
	
	[ActivityIndicator visible:NO];
	
	if ([[wv.request URL].absoluteString isEqualToString:@"https://api.twitter.com/oauth/authorize"]) {

		[self performSelector:@selector(setPinCode) withObject:nil afterDelay:0.1];
	}
}

- (void)setPinCode {
	
    //NSLog(@"setPinCode");
    
    NSError *error = nil;
    
	NSData *response = [NSURLConnection sendSynchronousRequest:[wv request] 
                                             returningResponse:nil 
                                                         error:&error];
    
	NSString *responseString = [[[NSString alloc] initWithData:response 
                                                      encoding:NSUTF8StringEncoding] autorelease];
	
	NSTextCheckingResult *match;
	NSRegularExpression *regexp = 
    [NSRegularExpression regularExpressionWithPattern:@"<code>[0-9]+</code>"
											  options:0
												error:&error];
    
	if ( error == nil ) {
        
		match = [regexp firstMatchInString:responseString 
                                   options:0 
                                     range:NSMakeRange(0, responseString.length)];
	} else {
        
        [ShowAlert error:@"PINコードが不正です。"];
        
        return;
    }
	
	if ( match.numberOfRanges != 0 ) {
        
		NSMutableString *pinString = [NSMutableString stringWithFormat:@"%@", [responseString substringWithRange:[match rangeAtIndex:0]]];
		[pinString replaceOccurrencesOfString:@"<code>" withString:BLANK options:0 range:NSMakeRange(0, [pinString length] )];
		[pinString replaceOccurrencesOfString:@"</code>" withString:BLANK options:0 range:NSMakeRange(0, [pinString length] )];
		pinField.text = pinString;
        
		[self performSelector:@selector(finish) withObject:nil afterDelay:0.1];
        
	} else {
        
        [ShowAlert error:@"PINコードが不正です。"];
                
        [self enableButton];
	}
}

- (void)finish {
    
    //NSLog(@"finish");
    
	if ( [pinField.text isEqualToString:BLANK] || 
         [USER_DEFAULTS objectForKey:@"OAuthRequestTokenKey"] == nil ||
         [USER_DEFAULTS objectForKey:@"OAuthRequestTokenSecret"] == nil ) {
        
        [ShowAlert unknownError];
        
        [self enableButton];
        
	} else {
        
		OAToken *oaRequestToken = [[OAToken alloc] initWithKey:[UUIDEncryptor decryption:[USER_DEFAULTS objectForKey:@"OAuthRequestTokenKey"]]
                                                        secret:[UUIDEncryptor decryption:[USER_DEFAULTS objectForKey:@"OAuthRequestTokenSecret"]]];
        
		NSURL *oaUrlAccessToken = [[NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"] retain];
		
		OAMutableURLRequest *oaReqAccessToken = [[OAMutableURLRequest alloc] initWithURL:oaUrlAccessToken 
																				   consumer:consumer 
																					  token:oaRequestToken
																					  realm:nil
																		  signatureProvider:nil];
		[oaReqAccessToken setHTTPMethod:@"POST"];
		[oaReqAccessToken setHTTPBody:[[NSString stringWithFormat:@"oauth_verifier=%@", pinField.text] dataUsingEncoding:NSUTF8StringEncoding]];
		
		OADataFetcher *oaFetAccessToken = [[OADataFetcher alloc] init];
		
		[oaFetAccessToken fetchDataWithRequest:oaReqAccessToken
										 delegate:self
								didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
								  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
		
		pinField.text = BLANK;
		
		[oaRequestToken release];
		[oaUrlAccessToken release];
		[oaReqAccessToken release];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    
	[sender resignFirstResponder];
	return YES;
}

- (void)enableButton {
    
    doneButton.enabled = YES;
    [grayView off];
}

- (IBAction)pushCloseButton:(id)sender {
        
    [ActivityIndicator visible:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pushDoneButton:(id)sender {
    
    [pinField resignFirstResponder];
    
    if ( [EmptyCheck string:pinField.text] ) [self setPinCode];
}

- (void)viewDidUnload {

    [self setWv:nil];
    [self setBar:nil];
    [self setCloseButton:nil];
    [self setPinField:nil];
    [self setDoneButton:nil];
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotate {
    
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {
    
    //NSLog(@"OAuthSetupView dealloc");
    
    if ( wv.loading ) [wv stopLoading];

    wv.delegate = nil;
    [wv removeFromSuperview];
    
    [grayView release];
    [bar release];
    [closeButton release];
    [pinField release];
    [doneButton release];
    
    [consumer release];
    
    [super dealloc];
}

@end
