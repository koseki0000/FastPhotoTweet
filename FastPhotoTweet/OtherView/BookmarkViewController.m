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
    
    if ( ![EmptyCheck check:[d arrayForKey:@"Bookmark"]] ) {
        
        [d setObject:[NSArray array] forKey:@"Bookmark"];
    }

    bookMarkArray = [[NSMutableArray alloc] initWithArray:[d arrayForKey:@"Bookmark"]];
}

- (IBAction)pushCloseButton:(id)sender {
    
    appDelegate.bookmarkUrl = BLANK;
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ( actionSheetNo == 0 ) {
        
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        
        NSDictionary *selectBookmark = [bookMarkArray objectAtIndex:selectRow];
        
        NSLog(@"%@", selectBookmark);
        
        if ( buttonIndex == 0 ) {
            
            [pboard setString:[selectBookmark objectForKey:@"Title"]];
            
        }else if ( buttonIndex == 1 ) {
        
            [pboard setString:[selectBookmark objectForKey:@"URL"]];
            
        }else if ( buttonIndex == 2 ) {
            
            [pboard setString:[NSString stringWithFormat:@"\"%@\" %@ ", 
                               [selectBookmark objectForKey:@"Title"], 
                               [selectBookmark objectForKey:@"URL"]]];
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
    
    NSDictionary *bookmark = [bookMarkArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [bookmark objectForKey:@"Title"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

    actionSheetNo = 0;
    selectRow = indexPath.row;
    
    NSDictionary *bookmark = [bookMarkArray objectAtIndex:selectRow];
    
    NSString *title = [NSString stringWithFormat:@"%@\n%@", 
                       [bookmark objectForKey:@"Title"], 
                       [bookmark objectForKey:@"URL"]];
    
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
    NSDictionary *bookmark = [bookMarkArray objectAtIndex:indexPath.row];
    appDelegate.bookmarkUrl = [bookmark objectForKey:@"URL"];
    
    //閉じる
    [self dismissModalViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [bookMarkArray removeObjectAtIndex:indexPath.row];
    [d setObject:bookMarkArray forKey:@"Bookmark"];
    
    [tv deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

/* TableView必須メソッドここまで */

- (void)dealloc {
    
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
