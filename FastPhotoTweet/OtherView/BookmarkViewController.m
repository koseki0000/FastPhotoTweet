//
//  BookmarkViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/06/02.
//

#import "BookmarkViewController.h"

#define BLANK @""

@implementation BookmarkViewController
@synthesize topBar;
@synthesize closeButton;
@synthesize tv;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    d = [NSUserDefaults standardUserDefaults];
    
    if ( ![EmptyCheck check:[d dictionaryForKey:@"Bookmark"]] ) {
        
        [d setObject:[NSDictionary dictionary] forKey:@"Bookmark"];
    }
    
    bookMarkDic = [[NSMutableDictionary alloc] initWithDictionary:[d dictionaryForKey:@"Bookmark"]];
    bookMarkArray = [[NSMutableArray alloc] initWithArray:[bookMarkDic allKeys]];
}

- (IBAction)pushCloseButton:(id)sender {
    
    appDelegate.bookmarkUrl = BLANK;
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( actionSheetNo == 0 ) {
        
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        
        NSArray *keys = [bookMarkDic allKeys];
        NSArray *values = [bookMarkDic allValues];
        
        if ( buttonIndex == 0 ) {
            
            [pboard setString:[keys objectAtIndex:selectRow]];
            
        }else if ( buttonIndex == 1 ) {
        
            [pboard setString:[values objectAtIndex:selectRow]];
            
        }else if ( buttonIndex == 2 ) {
            
            [pboard setString:[NSString stringWithFormat:@"\"%@\" %@ ", 
                               [keys objectAtIndex:selectRow], 
                               [values objectAtIndex:selectRow]]];
        }
    }
}

/* TableView必須メソッド */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //TableViewの要素数を返す
	return [bookMarkArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //TableViewCellを生成
	static NSString *identifier = @"BookmarkCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 0;
    
    cell.textLabel.text = [bookMarkArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

    actionSheetNo = 0;
    selectRow = indexPath.row;
    
    NSArray *keys = [bookMarkDic allKeys];
    NSArray *values = [bookMarkDic allValues];
    
    NSString *title = [NSString stringWithFormat:@"%@\n%@", 
                       [keys objectAtIndex:selectRow], 
                       [values objectAtIndex:selectRow]];
    
    UIActionSheet *sheet = [[UIActionSheet alloc]
                            initWithTitle:title
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"タイトルをコピー", @"URLをコピー", @"タイトルとURLをコピー", nil];
    [sheet autorelease];
    [sheet showInView:self.view];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルの選択状態を解除
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //選択したURLを設定
    appDelegate.bookmarkUrl = [bookMarkDic objectForKey:[bookMarkArray objectAtIndex:indexPath.row]];
    
    //閉じる
    [self dismissModalViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [bookMarkDic removeObjectForKey:[bookMarkArray objectAtIndex:indexPath.row]];
    [d setObject:bookMarkDic forKey:@"Bookmark"];
    
    [bookMarkArray removeObjectAtIndex:indexPath.row];
    [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

/* TableView必須メソッドここまで */

- (void)dealloc {
    
    [bookMarkDic release];
    [bookMarkArray release];
    
    [topBar release];
    [closeButton release];
    [tv release];
    [super dealloc];
}

- (void)viewDidUnload {
    
    [self setTopBar:nil];
    [self setCloseButton:nil];
    [self setTv:nil];
    [super viewDidUnload];
}

@end
