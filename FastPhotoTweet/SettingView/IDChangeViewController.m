//
//  SettingViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "IDChangeViewController.h"

@interface IDChangeViewController ()

@end

@implementation IDChangeViewController
@synthesize topBar;
@synthesize closeButton;
@synthesize tv;
@synthesize sv;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self ) {
        
        NSLog(@"SettingView init");
        
        //初期化処理
        ACAccountStore *accountStore = [[[ACAccountStore alloc] init] autorelease];
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
        
        if ( twitterAccounts != 0 ) {
    
            //可変長配列の初期化
            accountList = [NSMutableArray array];
            
            //アカウントが存在する場合screen_nameを保存
            for ( int i = 0; i < twitterAccounts.count; i++ ) {
                
                ACAccount *twAccount = [[twitterAccounts objectAtIndex:i] retain];
                [accountList addObject:twAccount.username];
                [twAccount release];
            }
            
            [accountList retain];
            NSLog(@"accountList: %@", accountList);
        }
        
        NSLog(@"AccountCount: %d", accountList.count);
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"SettingView viewDidLoad");
}

- (IBAction)pushCloseButton:(id)sender {
    
    NSLog(@"SettingView close");
    
    //閉じる
    [self dismissModalViewControllerAnimated:YES];
}

/* TableView必須メソッド */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //TableViewの要素数(Twitterアカウント数)を返す
	return [accountList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	NSLog(@"CreateCell");
    
    //TableViewCellを生成
	static NSString *identifier = @"TableViewCell";
	TableViewCell *cell = (TableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	cell.numberLabel.textColor = [UIColor blackColor];
	cell.textLabel.textColor = [UIColor blackColor];
    
	if (cell == nil) {
        
		TableViewCellController *controller = [[TableViewCellController alloc] initWithNibName:identifier bundle:nil];
		cell = (TableViewCell *)controller.view;
		[controller autorelease];
	}
    
    //テキストをセット
    cell.numberLabel.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];
    cell.textLabel.text = [accountList objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルの選択状態を解除
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //使用アカウント情報を保存
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    [d setInteger:indexPath.row forKey:@"UseAccount"];
    
    //閉じる
    [self dismissModalViewControllerAnimated:YES];
}

/* TableView必須メソッドここまで */

- (void)viewDidUnload {
    
    [self setSv:nil];
    [self setTopBar:nil];
    [self setCloseButton:nil];
    [self setTv:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    
    [accountList release];
    
    [sv release];
    [topBar release];
    [closeButton release];
    [tv release];
    [super dealloc];
}

@end
