//
//  ResendViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/04/28.
//

#import "ResendViewController.h"
#import "TWTweets.h"
#import "TWTweet.h"

#define BLANK @""

@implementation ResendViewController
@synthesize resendTable;
@synthesize bar;
@synthesize closeButton;
@synthesize trashButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    //NSLog(@"init ResendViewController");
    
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    
    if ( self ) {
    
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (IBAction)pushTrashButton:(id)sender {
    
    [[TWTweets sendedTweets] removeAllObjects];
    [resendTable reloadData];
}

- (IBAction)pushCloseButon:(id)sender {
    
    [self dismissModalViewController:self];
}

/* TableView必須メソッド */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //TableViewの要素数を返す
	return [[TWTweets sendedTweets] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//NSLog(@"CreateCell");
    
    //TableViewCellを生成
	static NSString *identifier = @"ResendCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {

        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }

    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 0;
    
    NSDictionary *resendData = [TWTweets sendedTweets][indexPath.row];
//    NSDictionary *saveTweet = @{@"UserName" : [TWAccounts currentAccountName],
//                                @"Parameters" : parameters,
//                                @"RequestType" : @(postRequestType)};
    
    //NSLog(@"Resend[%d]: %@", array.count, array);

    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",
                           resendData[@"UserName"], resendData[@"Parameters"][@"status"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルの選択状態を解除
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *resendData = [TWTweets sendedTweets][indexPath.row];
    NSString *accountName = resendData[@"UserName"];
    
    [[TWTweets manager] setText:resendData[@"Parameters"][@"status"]];
    [[TWTweets manager] setInReplyToID:resendData[@"Parameters"][@"in_reply_to_status_id"]];
    
    NSUInteger index = 0;
    BOOL find = NO;
    for ( ACAccount *account in [TWAccounts twitterAccounts] ) {
     
        if ( [account.username isEqualToString:accountName] ) {
            
            find = YES;
            break;
        }
        
        index++;
    }
    
    if ( find ) {
        
        [[NSUserDefaults standardUserDefaults] setInteger:index
                                                   forKey:@"UseAccount"];
        
        //アカウントが切り替わったことを通知
        NSNotification *notification =[NSNotification notificationWithName:@"ChangeAccount"
                                                                    object:self
                                                                  userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    [self dismissModalViewController:self];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[TWTweets sendedTweets] removeObjectAtIndex:indexPath.row];
    [resendTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                       withRowAnimation:UITableViewRowAnimationLeft];
}

/* TableView必須メソッドここまで */

- (void)viewDidUnload {
    
    [self setBar:nil];
    [self setCloseButton:nil];
    [self setTrashButton:nil];
    [self setResendTable:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotate {
    
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc {

    //NSLog(@"dealloc ResendViewController");
    
    [bar release];
    bar = nil;
    [closeButton release];
    closeButton = nil;
    [trashButton release];
    trashButton = nil;
    [resendTable release];
    resendTable = nil;
    
    [super dealloc];
}

@end