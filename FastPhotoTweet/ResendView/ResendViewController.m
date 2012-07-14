//
//  ResendViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/04/28.
//

#import "ResendViewController.h"

#define BLANK @""

@implementation ResendViewController
@synthesize resendTable;
@synthesize bar;
@synthesize closeButton;
@synthesize trashButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    //NSLog(@"init ResendViewController");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self ) {
    
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //NSLog(@"viewDidLoad ResendViewController");
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (IBAction)pushTrashButton:(id)sender {
    
    [appDelegate.postError removeAllObjects];
    [resendTable reloadData];
}

- (IBAction)pushCloseButon:(id)sender {
    
    //再投稿モードを無効化
    appDelegate.resendMode = NO;
    
    [self dismissModalViewControllerAnimated:YES];
}

/* TableView必須メソッド */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //TableViewの要素数を返す
	return [appDelegate.postError count];
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
    
    NSArray *array = [appDelegate.postError objectAtIndex:indexPath.row];
    
    //NSLog(@"Resend[%d]: %@", array.count, array);

    if ( array.count == 4 ) {
        
        //NSLog(@"TextCell");
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [array objectAtIndex:1], 
                                                                    [array objectAtIndex:2]];
        
    }else if ( array.count == 5 ) {
        
        //NSLog(@"PhotoCell");
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [array objectAtIndex:1], 
                                                                    [array objectAtIndex:2]];
        
        cell.imageView.image = [array objectAtIndex:4];
        
    }else {
        
        //NSLog(@"Error");
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルの選択状態を解除
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    appDelegate.resendNumber = indexPath.row;
    
    //閉じる
    [self dismissModalViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [appDelegate.postError removeObjectAtIndex:indexPath.row];
    [resendTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

/* TableView必須メソッドここまで */

- (void)viewDidUnload {
    
    [self setBar:nil];
    [self setCloseButton:nil];
    [self setTrashButton:nil];
    [self setResendTable:nil];
    [super viewDidUnload];
}

- (void)dealloc {

    //NSLog(@"dealloc ResendViewController");
    
    [bar release];
    [closeButton release];
    [trashButton release];
    [resendTable release];
    [super dealloc];
}

@end