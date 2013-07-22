//
//  ListViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 12/09/09.
//

#import "ListViewController.h"
#import "TWAccounts.h"
#import "TWTweets.h"
#import "FPTRequest.h"

@interface ListViewController ()

@property (strong, nonatomic) NSArray *lists;

@end

@implementation ListViewController
@synthesize topBar;
@synthesize closeButton;
@synthesize listTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self ) {

    }
    
    return self;
}

- (id)initWithListSelectMode:(BOOL)listSelectMode {
    
    self = [super init];
    
    if ( self ) {
        
        [self setListSelectMode:listSelectMode];
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    //リスト一覧取得完了を受け取る設定
    [notificationCenter addObserver:self
                           selector:@selector(receiveListAll:)
                               name:LISTS_LIST_DONE_NOTIFICATION
                             object:nil];
    
    if ( [[[TWTweets manager] lists] count] == 0 ) {
    
        //取得済みリストがない場合は取得
        NSMutableDictionary *parameters = [@{} mutableCopy];
        
        [parameters setObject:[TWAccounts currentAccountName]
                       forKey:@"screen_name"];
        
        [FPTRequest requestWithGetType:FPTGetRequestTypeListsList
                            parameters:parameters];
        
    } else {
        
        //取得済みリストがある場合は表示
        [self setLists:[[TWTweets manager] lists]];
    }
}

- (void)receiveListAll:(NSNotification *)center {
    
    [self setLists:[center.userInfo objectForKey:RESPONSE_DATA]];
    [[TWTweets manager] setLists:[center.userInfo objectForKey:RESPONSE_DATA]];
    
    NSLog(@"listData: %d", [[[TWTweets manager] lists] count]);
    
    [listTable reloadData];
}

- (IBAction)pushCloseButton:(id)sender {
    
    [self dismissModalViewController:self];
}

/* TableView必須メソッド */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //TableViewの要素数を返す
	return [self.lists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//NSLog(@"CreateCell");
    
    //TableViewCellを生成
	static NSString *identifier = @"ListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
    }
    
    [cell.textLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [cell.textLabel setNumberOfLines:0];
    [cell.textLabel setText:self.lists[indexPath.row][@"full_name"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルの選択状態を解除
	[tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    if ( self.listSelectMode ) {
        
        NSLog(@"SelectTimelineList: %@ : %@", [TWAccounts currentAccountName], [[self.lists objectAtIndex:indexPath.row] objectForKey:@"id_str"]);
        
        NSMutableDictionary *accounts = [[USER_DEFAULTS dictionaryForKey:@"TimelineList"] mutableCopy];
        
        [accounts setObject:[[self.lists objectAtIndex:indexPath.row] objectForKey:@"id_str"]
                     forKey:[TWAccounts currentAccountName]];
        
        [USER_DEFAULTS setObject:accounts
                          forKey:@"TimelineList"];
        
    } else {
        
        //リストIDを記憶
        [[TWTweets manager] setListID:self.lists[indexPath.row][@"id_str"]];
    }
    
    //閉じる
    [self pushCloseButton:nil];
}

/* TableView必須メソッドここまで */

- (BOOL)shouldAutorotate {
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidUnload {
    
    [self setTopBar:nil];
    [self setCloseButton:nil];
    [self setListTable:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    
    [self setTopBar:nil];
    [self setCloseButton:nil];
    [self setListTable:nil];
}

@end
