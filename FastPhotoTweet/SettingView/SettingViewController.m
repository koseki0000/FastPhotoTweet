//
//  SettingViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "SettingViewController.h"

@implementation SettingViewController
@synthesize tv;
@synthesize bar;
@synthesize saveButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    //初期化処理
    if ( self ) {

        NSLog(@"SettingView init");
        
        d = [NSUserDefaults standardUserDefaults];
        settingArray = [NSMutableArray array];
        actionSheetNo = 0;
        
        //設定項目を追加
        //画像関連設定
        [settingArray addObject:@"画像投稿時リサイズを行う"];
        [settingArray addObject:@"リサイズ最大長辺"];
        [settingArray addObject:@"画像形式"];
        
        //投稿関連設定
        [settingArray addObject:@"NowPlaying時は必ずCallBackを行う"];
        
        //その他の設定
        [settingArray addObject:@"設定"];
        
        [settingArray retain];
    }
    
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
}

- (IBAction)pushDoneButton:(id)sender {
    
    NSLog(@"pushDoneButton");
    
    //閉じる    
    [settingArray release];
    [self dismissModalViewControllerAnimated:YES];
}

- (NSString *)getSettingState:(int)index {
    
    //NSLog(@"getSettingState: %d", index);
    
    NSString *result = @"";
    
    if ( index == 0 ) {
        
        if ( [d boolForKey:@"ResizeImage"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
        
    }else if ( index == 1 ) {
        
        result = [NSString stringWithFormat:@"%d", [d integerForKey:@"ImageMaxSize"]];
        
    }else if ( index == 2 ) {
        
        result = [NSString stringWithFormat:@"%@", [d objectForKey:@"SaveImageType"]];;
    
    }else if ( index == 3 ) {
        
        if ( [d boolForKey:@"NowPlayingCallBack"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
        
    }
        
    return result;
}

/* TableView必須メソッド */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //NSLog(@"numberOfRowsInSection: %d", section);
    
    //各セクションの要素数を返す
    switch ( section ) {
		case 0:
			return 3;
            break;
            
		case 1:
			return 1;
            break;
            
        case 2:
			return 1;
            break;
	}
    
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//NSLog(@"CreateCell");
    
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
    
    //セルのラベルサイズを設定
    cell.numberLabel.frame =    CGRectMake(  5, 0, 200, 44);
    cell.textLabel.frame =      CGRectMake(215, 0,  90, 44);
    
    //テキストをセット
    NSString *settingName = @"";
    int settingState = 0;
    
    switch ( indexPath.section ) {
        
        case 0:
            //画像関連設定
            settingName = [settingArray objectAtIndex:indexPath.row];
            settingState = indexPath.row;
            break;
        
        case 1:
            //投稿関連設定
            settingName = [settingArray objectAtIndex:indexPath.row + 3];
            settingState = indexPath.row + 3;
            break;
            
        case 2:
            //その他の設定
            settingName = [settingArray objectAtIndex:indexPath.row + 4];
            settingState = indexPath.row + 4;
            break;
    }
    
    cell.numberLabel.text = settingName;
    cell.textLabel.text = [self getSettingState:settingState];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルの選択状態を解除
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //for debug
    if ( indexPath.section == 2 ) {
        return;
    }
    
    actionSheetNo = indexPath.row;
    
    UIActionSheet *sheet;
    
    if ( indexPath.section == 0 ) {
        
        if ( indexPath.row == 0 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:@"画像投稿時リサイズを行う"
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            
        }else if ( indexPath.row == 1 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:@"リサイズ最大長辺"
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"320", @"640", @"800", @"960",@"1280", nil];
            
        }else if ( indexPath.row == 2 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:@"画像形式"
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"JPG(Low)", @"JPG", @"JPG(High)", @"PNG", nil];
            
        }
        
    }else if ( indexPath.section == 1 ) {
        
        actionSheetNo = actionSheetNo + 3;
        
        if ( indexPath.row == 0 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:@"NowPlaying時は必ずCallBackを行う"
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
        }
    }
    
    [sheet autorelease];
    [sheet showInView:self.view];        
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //NSLog(@"actionSheet: %d, buttonIndex: %d", actionSheetNo, buttonIndex);
    
    if ( actionSheetNo == 0 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"ResizeImage"];
        }else {
            [d setBool:NO forKey:@"ResizeImage"];
        }
        
    }else if ( actionSheetNo == 1 ) {
        if ( buttonIndex == 0 ) {
            [d setInteger:320 forKey:@"ImageMaxSize"];
        }else if ( buttonIndex == 1 ) {
            [d setInteger:640 forKey:@"ImageMaxSize"];
        }else if ( buttonIndex == 2 ) {
            [d setInteger:800 forKey:@"ImageMaxSize"];
        }else if ( buttonIndex == 3 ) {
            [d setInteger:960 forKey:@"ImageMaxSize"];
        }else if ( buttonIndex == 4 ) {
            [d setInteger:1280 forKey:@"ImageMaxSize"];
        }
        
    }else if ( actionSheetNo == 2 ) {
        if ( buttonIndex == 0 ) {
            [d setObject:@"JPG(Low)" forKey:@"SaveImageType"];
        }else if ( buttonIndex == 1 ) {
            [d setObject:@"JPG" forKey:@"SaveImageType"];
        }else if ( buttonIndex == 2 ) {
            [d setObject:@"JPG(High)" forKey:@"SaveImageType"];
        }else if ( buttonIndex == 3 ) {
            [d setObject:@"PNG" forKey:@"SaveImageType"];
        }
        
    }else if ( actionSheetNo == 3 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"NowPlayingCallBack"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"NowPlayingCallBack"];
        }
    }
    
    [tv reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    //NSLog(@"titleForHeaderInSection");
    
    //セクションのタイトルを決定
    switch ( section ) {
            
        case 0:
            return @"画像関連設定";
            break;
        
        case 1:
            return @"投稿関連設定";
            break;
            
        case 2:
            return @"その他の設定";
            break;
    }
    
    return nil;
} 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //NSLog(@"numberOfSectionsInTableView");
    
    //セクションの数を設定
	return 3;
}

/* TableView必須メソッドここまで */

- (void)viewDidUnload {
    
    [self setTv:nil];
    [self setBar:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    
    NSLog(@"SettingView dealloc");
    
    [tv release];
    [bar release];
    [saveButton release];
    [super dealloc];
}

@end
