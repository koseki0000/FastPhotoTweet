//
//  ListViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 12/09/09.
//

#import "ListViewController.h"

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

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.listId = BLANK;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    //リスト一覧取得完了を受け取る設定
    [notificationCenter addObserver:self
                           selector:@selector(receiveListAll:)
                               name:@"ReceiveListAll"
                             object:nil];
    
    if ( appDelegate.listAll.count == 0 ) {
    
        //取得済みリストがない場合は取得
        [TWList getListAll];
        
    }else {
        
        //取得済みリストがある場合は表示
        listAll = appDelegate.listAll;
    }
}

- (void)receiveListAll:(NSNotification *)center {
    
    listAll = [center.userInfo objectForKey:@"ResultData"];
    appDelegate.listAll = listAll;
    
    NSLog(@"listData: %d", listAll.count);
    
    [listTable reloadData];
}

- (IBAction)pushCloseButton:(id)sender {
    
    if ( [appDelegate.firmwareVersion hasPrefix:@"6"] ) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }else {
        
        [self dismissModalViewControllerAnimated:YES];
    }
}

/* TableView必須メソッド */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //TableViewの要素数を返す
	return [listAll count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//NSLog(@"CreateCell");
    
    //TableViewCellを生成
	static NSString *identifier = @"ListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 0;
    
    cell.textLabel.text = [[listAll objectAtIndex:indexPath.row] objectForKey:@"full_name"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルの選択状態を解除
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //リストIDを記憶
    appDelegate.listId = [[listAll objectAtIndex:indexPath.row] objectForKey:@"id_str"];
    
    //閉じる
    if ( [appDelegate.firmwareVersion hasPrefix:@"6"] ) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }else {
        
        [self dismissModalViewControllerAnimated:YES];
    }
}

/* TableView必須メソッドここまで */

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
