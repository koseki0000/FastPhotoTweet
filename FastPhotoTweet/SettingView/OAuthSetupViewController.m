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

        grayView = [[GrayView alloc] init];
        [wv addSubview:grayView];
        
        consumer = [((AppDelegate *)[[UIApplication sharedApplication] delegate]).oaConsumer retain];
    }
    
    return self;
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    
    NSLog(@"requestTokenTicket Finish");
    
    if ( ticket.didSucceed ) {
        
        NSLog(@"ticket.didSucceed OK");
        
        NSString *responseBody = [[NSString alloc] initWithData:data 
                                                       encoding:NSUTF8StringEncoding];
        
        OAToken *requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
        
        NSLog(@"requestToken key: %@", requestToken.key);
        NSLog(@"requestToken secret: %@", requestToken.secret);
        
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
        [d setObject:requestToken.key forKey:@"OAuthRequestTokenKey"];
        [d setObject:requestToken.secret forKey:@"OAuthRequestTokenSecret"];
        [d synchronize];

        [responseBody release];
        
        NSString *urlString = [NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.key];
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [wv loadRequest:req];
        [requestToken release];
        
    } else {
        
        NSLog(@"ticket.didSucceed Error");
        
        ShowAlert *alert = [[ShowAlert alloc] init];
        [alert error:@"RequestTokenError"];
        
        [self enableButton];
    }
    
    [grayView off];
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    
    NSLog(@"requestTokenTicket Error");
    
	ShowAlert *alert = [[ShowAlert alloc] init];
    [alert error:@"RequestTokenError"];
    
	[grayView off];
    
    [self enableButton];
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    
    NSLog(@"accessTokenTicket Finish");
    
    if ( ticket.didSucceed ) {
        
        NSLog(@"ticket.didSucceed OK");
        
		[grayView off];
		
		NSString *responseBody = [[NSString alloc] initWithData:data
														encoding:NSUTF8StringEncoding];
        
		OAToken *accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
		
        NSLog(@"accessToken key: %@", accessToken.key);
        NSLog(@"accessToken secret: %@", accessToken.secret);
        
		NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
		
        [d setObject:accessToken.key forKey:@"OAuthKey"];
        [d setObject:accessToken.secret forKey:@"OAuthSecret"];
		[d synchronize];
                
		[responseBody release];
		[accessToken release];
		
		[self dismissModalViewControllerAnimated:YES];
		
	} else {
        
        NSLog(@"ticket.didSucceed Error");
        
		ShowAlert *alert = [[ShowAlert alloc] init];
        [alert error:@"AccessTokenError"];
        
        [grayView off];
        
        [self enableButton];
	}
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    
    NSLog(@"accessTokenTicket Error");
    
    ShowAlert *alert = [[ShowAlert alloc] init];
    [alert error:@"AccessTokenError"];
    
	[grayView off];
    
    [self enableButton];
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    [self oaRequestStart];
}

- (void)oaRequestStart {
    
    NSLog(@"oaRequestStart");
    
    wv.delegate = self;
	pinField.text = @"";
	
	NSURL *oaUrlGetRequestToken = [[NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"] retain];
	
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
	
	[oaUrlGetRequestToken release];
	[oaReqGetRequestToken release];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType {
	
	[ActivityIndicator visible:YES];
    
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView*)webView {
	
	[ActivityIndicator visible:NO];
	
	if ([[[wv.request URL] absoluteString] isEqualToString:@"https://api.twitter.com/oauth/authorize"]) {

        [grayView on];
        
		[self performSelector:@selector(setPinCode) withObject:nil afterDelay:0.1];
	}
}

- (void)setPinCode {
	
    NSLog(@"setPinCode");
    
	NSData *response = [NSURLConnection sendSynchronousRequest:[wv request] 
                                             returningResponse:nil 
                                                         error:nil];
    
	NSString *responseString = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease];
	
	NSError *error = nil;
	NSTextCheckingResult *match;
	NSRegularExpression *regexp = 
    [NSRegularExpression regularExpressionWithPattern:@"<code>[0-9]+</code>"
											  options:0
												error:&error];
    
	if ( error == nil ) {
        
		match = [regexp firstMatchInString:responseString 
                                   options:0 
                                     range:NSMakeRange(0, responseString.length)];
	}
	
	if ( match.numberOfRanges != 0 ) {
        
		NSMutableString *pinString = [NSMutableString stringWithFormat:@"%@", [responseString substringWithRange:[match rangeAtIndex:0]]];
		[pinString replaceOccurrencesOfString:@"<code>" withString:@"" options:0 range:NSMakeRange(0, [pinString length] )];
		[pinString replaceOccurrencesOfString:@"</code>" withString:@"" options:0 range:NSMakeRange(0, [pinString length] )];
		pinField.text = pinString;
        
		[self performSelector:@selector(finish) withObject:nil afterDelay:0.1];
        
	}else {
        
        ShowAlert *alert = [[ShowAlert alloc] init];
        [alert error:@"PinCodeError"];
        
        [grayView off];
        
        [self enableButton];
	}
}

- (void)finish {
    
    NSLog(@"finish");
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
	if ( [pinField.text isEqualToString:@""] || 
         [d objectForKey:@"OAuthRequestTokenKey"] == nil ||
         [d objectForKey:@"OAuthRequestTokenSecret"] == nil ) {
        
        ShowAlert *alert = [[ShowAlert alloc] init];
        [alert error:@"UnknownError"];
        
        [self enableButton];
        
	} else {
        
		OAToken *oaRequestToken = [[OAToken alloc] initWithKey:[d objectForKey:@"OAuthRequestTokenKey"]
                                                        secret:[d objectForKey:@"OAuthRequestTokenSecret"]];
        
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
		
		pinField.text = @"";
		
		[oaRequestToken release];
		[oaUrlAccessToken release];
		[oaReqAccessToken release];
	}
    
	[grayView off];
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    
	[sender resignFirstResponder];
	return YES;
}

- (void)enableButton {
    
    doneButton.enabled = YES;
}

- (IBAction)pushCloseButton:(id)sender {
        
    [ActivityIndicator visible:NO];
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)pushDoneButton:(id)sender {
    
    [pinField resignFirstResponder];
    [self setPinCode];
}

- (void)viewDidUnload {

    [self setWv:nil];
    [self setBar:nil];
    [self setCloseButton:nil];
    [self setPinField:nil];
    [self setDoneButton:nil];
    
    [super viewDidUnload];
}

- (void)dealloc {
    
    NSLog(@"OAuthSetupView dealloc");
    
    [wv release];
    [bar release];
    [closeButton release];
    [pinField release];
    [doneButton release];
    
    [consumer release];
    
    [super dealloc];
}

@end
