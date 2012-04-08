//
//  SettingViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/02/23.
//

#import "SettingViewController.h"

//セクション数
#define SECTION_COUNT 3
//セクション0の項目数 (画像関連設定)
#define SECTION_0 4
//セクション1の項目数 (投稿関連設定)
#define SECTION_1 5
//セクション2の項目数 (その他の設定)
#define SECTION_2 1

#define BLANK @""

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
        alertTextNo = 0;
        
        //設定項目を追加
        //画像関連設定
        [settingArray addObject:@"画像投稿時リサイズを行う"];
        [settingArray addObject:@"リサイズ最大長辺"];
        [settingArray addObject:@"画像形式"];
        [settingArray addObject:@"Retina解像度画像のリサイズを行わない"];
        
        //投稿関連設定
        [settingArray addObject:@"NowPlaying時は必ずCallBackを行う"];
        [settingArray addObject:@"NowPlayingにカスタム書式を使用"];
        [settingArray addObject:@"カスタム書式を編集"];
        [settingArray addObject:@"曲名とアルバム名が同じな場合サブ書式を使用"];
        [settingArray addObject:@"サブ書式を編集"];
        
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
    
    NSString *result = BLANK;
    
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
        
    }else if ( index == 4 ) {
        
        if ( [d boolForKey:@"NoResizeIphone4Ss"] ) {
            
            result = @"ON";
            
        }else {

            result = @"OFF";
        }
    
    }else if ( index == 5 ) {
        
        if ( [d boolForKey:@"NowPlayingEdit"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
        
    }else if ( index == 6 ) {
        //空のまま
    }else if ( index == 7 ) {
        
        if ( [d boolForKey:@"NowPlayingEditSub"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
        
    }else if ( index == 8 ) {
        //空のまま
    }
        
    return result;
}

/* TableView必須メソッド */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //NSLog(@"numberOfRowsInSection: %d", section);
    
    //各セクションの要素数を返す
    switch ( section ) {
		case 0:
			return SECTION_0;
            break;
            
		case 1:
			return SECTION_1;
            break;
            
        case 2:
			return SECTION_2;
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
    NSString *settingName = BLANK;
    int settingState = 0;
    
    switch ( indexPath.section ) {
        
        case 0:
            //画像関連設定
            settingName = [settingArray objectAtIndex:indexPath.row];
            settingState = indexPath.row;
            break;
        
        case 1:
            //投稿関連設定
            settingName = [settingArray objectAtIndex:indexPath.row + SECTION_0];
            settingState = indexPath.row + SECTION_0;
            break;
            
        case 2:
            //その他の設定
            settingName = [settingArray objectAtIndex:indexPath.row + SECTION_0 + SECTION_1];
            settingState = indexPath.row + SECTION_0 + SECTION_1;
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
            
        }else if ( indexPath.row == 3 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:@"Retina解像度画像のリサイズを行わない"
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
        }
        
    }else if ( indexPath.section == 1 ) {
        
        actionSheetNo = actionSheetNo + SECTION_0;
        
        if ( indexPath.row == 0 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:@"NowPlaying時は必ずCallBackを行う"
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            
        }else if ( indexPath.row == 1 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:@"NowPlayingにカスタム書式を使用"
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
        
        }else if ( indexPath.row == 2 ) {
            
            alertTextNo = 0;
            
            NSString *message = @"\n曲名[st] アーティスト名[ar]\nアルバム名[at] 再生数[pc] レート[rt]";
            NSString *alertMessage = BLANK;
            
            if ( [EmptyCheck check:[d objectForKey:@"NowPlayingEditText"]] ) {
                alertMessage = [d objectForKey:@"NowPlayingEditText"];
            }
            
            alert = [[UIAlertView alloc] initWithTitle:@"カスタム書式を編集" 
                                                            message:message
                                                           delegate:self 
                                                  cancelButtonTitle:@"キャンセル" 
                                                  otherButtonTitles:@"確定", nil];

            alertText = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
            [alertText setBackgroundColor:[UIColor whiteColor]];
            alertText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            alertText.delegate = self;
            alertText.text = alertMessage;
            
            [alert addSubview:alertText];
            [alert show];
            [alert release];
            [alertText becomeFirstResponder];
            [alertText release];
            
            return;
            
        }else if ( indexPath.row == 3 ) {
            
            sheet = [[UIActionSheet alloc]
                     initWithTitle:@"曲名とアルバム名が同じな場合サブ書式を使用"
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            
        }else if ( indexPath.row == 4 ) {
            
            alertTextNo = 1;
            
            NSString *alertMessage = BLANK;
            
            if ( [EmptyCheck check:[d objectForKey:@"NowPlayingEditTextSub"]] ) {
                alertMessage = [d objectForKey:@"NowPlayingEditTextSub"];
            }
            
            alert = [[UIAlertView alloc] initWithTitle:@"サブ書式を編集" 
                                               message:@"\n"
                                              delegate:self 
                                     cancelButtonTitle:@"キャンセル" 
                                     otherButtonTitles:@"確定", nil];
            
            alertText = [[UITextField alloc] initWithFrame:CGRectMake(12, 40, 260, 25)];
            [alertText setBackgroundColor:[UIColor whiteColor]];
            alertText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            alertText.delegate = self;
            alertText.text = alertMessage;
            
            [alert addSubview:alertText];
            [alert show];
            [alert release];
            [alertText becomeFirstResponder];
            [alertText release];
            
            return;
        }
    }
    
    [sheet autorelease];
    [sheet showInView:self.view];        
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //確定が押された
    if ( alertTextNo == 0 ) {

        if (buttonIndex == 1) {
            
            //カスタム書式を保存
            [d setObject:alertText.text forKey:@"NowPlayingEditText"];
        }
        
    }else if ( alertTextNo == 1 ) {
        
        //サブ書式を保存
        [d setObject:alertText.text forKey:@"NowPlayingEditTextSub"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    
    NSLog(@"Textfield Enter: %@", sender.text);
    
    if ( alertTextNo == 0 ) {
        
        //カスタム書式を保存
        [d setObject:alertText.text forKey:@"NowPlayingEditText"];
        
    }else if ( alertTextNo == 1 ) {
        
        //サブ書式を保存
        [d setObject:alertText.text forKey:@"NowPlayingEditTextSub"];
    }
    
    //アラートを閉じる
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    
    //キーボードを閉じる
    [sender resignFirstResponder];
    
    return YES;
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
    
    }else if ( actionSheetNo == 4 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"NoResizeIphone4Ss"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"NoResizeIphone4Ss"];
        }
    
    }else if ( actionSheetNo == 5 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"NowPlayingEdit"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"NowPlayingEdit"];
        }
    
    }else if ( actionSheetNo == 7 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"NowPlayingEditSub"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"NowPlayingEditSub"];
        }
    }
    
    //設定項目の表示を更新
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
	return SECTION_COUNT;
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
