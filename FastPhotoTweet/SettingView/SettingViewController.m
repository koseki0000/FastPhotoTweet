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
#define SECTION_0 5
//セクション1の項目数 (投稿関連設定)
#define SECTION_1 6
//セクション2の項目数 (その他の設定)
#define SECTION_2 1

//設定項目名
//画像関連設定
#define NAME_0  @"画像投稿時リサイズを行う"
#define NAME_1  @"リサイズ最大長辺"
#define NAME_2  @"画像形式"
#define NAME_3  @"Retina解像度画像のリサイズを行わない"
#define NAME_4  @"画像投稿先"
//投稿関連設定
#define NAME_5  @"NowPlaying時はFastPostを行う"
#define NAME_6  @"NowPlaying時はCallBackを行う"
#define NAME_7  @"NowPlayingにカスタム書式を使用"
#define NAME_8  @"カスタム書式を編集"
#define NAME_9  @"曲名とアルバム名が同じな場合サブ書式を使用"
#define NAME_10  @"サブ書式を編集"
//その他の設定
#define NAME_11 @"設定"

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
        actionSheetNo = 0;
        alertTextNo = 0;
        
        //設定項目名を持った可変長配列を生成
        settingArray = [NSMutableArray arrayWithObjects:NAME_0, NAME_1, NAME_2, NAME_3, 
                                                        NAME_4, NAME_5, NAME_6, NAME_7, 
                                                        NAME_8, NAME_9, NAME_10, NAME_11, nil];
        
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

- (NSString *)getSettingState:(int)settingState {
    
    //NSLog(@"getSettingState: %d", index);
    
    NSString *result = BLANK;
    
    //画像投稿時リサイズを行う
    if ( settingState == 0 ) {
        
        if ( [d boolForKey:@"ResizeImage"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
        
    //リサイズ最大長辺
    }else if ( settingState == 1 ) {
        
        result = [NSString stringWithFormat:@"%d", [d integerForKey:@"ImageMaxSize"]];
        
    //画像形式
    }else if ( settingState == 2 ) {
        
        result = [NSString stringWithFormat:@"%@", [d objectForKey:@"SaveImageType"]];;
    
    //Retina解像度画像のリサイズを行わない
    }else if ( settingState == 3 ) {
        
        if ( [d boolForKey:@"NoResizeIphone4Ss"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
        
    //画像投稿先
    }else if ( settingState == 4 ) {
        
        result = [NSString stringWithFormat:@"%@", [d objectForKey:@"PhotoService"]];
        
    //NowPlaying時はFastPostを行う
    }else if ( settingState == 5 ) {
        
        if ( [d boolForKey:@"NowPlayingFastPost"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
        
    //NowPlaying時はCallBackを行う
    }else if ( settingState == 6 ) {
        
        if ( [d boolForKey:@"NowPlayingCallBack"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
        
    //NowPlayingにカスタム書式を使用
    }else if ( settingState == 7 ) {
        
        if ( [d boolForKey:@"NowPlayingEdit"] ) {
            
            result = @"ON";
            
        }else {
            
            result = @"OFF";
        }
        
    //カスタム書式を編集
    }else if ( settingState == 8 ) {
        
        //空のまま
        
    //曲名とアルバム名が同じな場合サブ書式を使用
    }else if ( settingState == 9 ) {
        
        if ( [d integerForKey:@"NowPlayingEditSub"] == 0 ) {
            
            result = @"ON\n(完全一致)";
            
        }else if ( [d integerForKey:@"NowPlayingEditSub"] == 1 ) {
            
            result = @"ON\n(前方一致)";
            
        }else if ( [d integerForKey:@"NowPlayingEditSub"] == 2 ) {    
            
            result = @"OFF";
        }
        
    //サブ書式を編集
    }else if ( settingState == 10 ) {
        
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
            
		case 1:
			return SECTION_1;
            
        case 2:
			return SECTION_2;
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
    
    if ( indexPath.section == 0 ) {
        settingState = indexPath.row;
    }else if ( indexPath.section == 1 ) {
        settingState = indexPath.row + SECTION_0;
    }else if ( indexPath.section == 2 ) {
        settingState = indexPath.row + SECTION_0 + SECTION_1;
    }
    
    settingName = [settingArray objectAtIndex:settingState];
        
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
            
            //画像投稿時リサイズを行う
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_0
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            
        }else if ( indexPath.row == 1 ) {
            
            //リサイズ最大長辺
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_1
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"320", @"640", @"800", @"960",@"1280", nil];
            
        }else if ( indexPath.row == 2 ) {
            
            //画像形式
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_2
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"JPG(Low)", @"JPG", @"JPG(High)", @"PNG", nil];
            
        }else if ( indexPath.row == 3 ) {
            
            //Retina解像度画像のリサイズを行わない
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_3
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            
        }else if ( indexPath.row == 4 ) {
            
            //画像投稿先
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_4
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"Twitter", @"img.ur(複数枚投稿可)", nil];
        }
        
    }else if ( indexPath.section == 1 ) {
        
        actionSheetNo = actionSheetNo + SECTION_0;
        
        if ( indexPath.row == 0 ) {
        
            //NowPlaying時はFastPostを行う
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_5
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            
        }else if ( indexPath.row == 1 ) {
            
            //NowPlaying時はCallBackを行う
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_6
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
            
        }else if ( indexPath.row == 2 ) {
            
            //NowPlayingにカスタム書式を使用
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_7
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON", @"OFF", nil];
        
        }else if ( indexPath.row == 3 ) {
            
            //カスタム書式を編集
            alertTextNo = 0;
            
            NSString *message = @"\n曲名[st] アーティスト名[ar]\nアルバム名[at] 再生数[pc] レート[rt]";
            NSString *alertMessage = BLANK;
            
            if ( [EmptyCheck check:[d objectForKey:@"NowPlayingEditText"]] ) {
                alertMessage = [d objectForKey:@"NowPlayingEditText"];
            }
            
            alert = [[UIAlertView alloc] initWithTitle:NAME_8 
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
            
        }else if ( indexPath.row == 4 ) {
            
            //曲名とアルバム名が同じな場合サブ書式を使用
            sheet = [[UIActionSheet alloc]
                     initWithTitle:NAME_9
                     delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:nil
                     otherButtonTitles:@"ON(完全一致)", @"ON(前方一致)", @"OFF", nil];
            
        }else if ( indexPath.row == 5 ) {
            
            //サブ書式を編集
            alertTextNo = 1;
            
            NSString *message = @"\n曲名[st] アーティスト名[ar]\nアルバム名[at] 再生数[pc] レート[rt]";
            NSString *alertMessage = BLANK;
            
            if ( [EmptyCheck check:[d objectForKey:@"NowPlayingEditTextSub"]] ) {
                alertMessage = [d objectForKey:@"NowPlayingEditTextSub"];
            }
            
            alert = [[UIAlertView alloc] initWithTitle:NAME_10 
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
            [d setBool:YES forKey:@"NoResizeIphone4Ss"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"NoResizeIphone4Ss"];
        }
        
    }else if ( actionSheetNo == 4 ) {
        if ( buttonIndex == 0 ) {
            [d setObject:@"Twitter" forKey:@"PhotoService"];
        }else if ( buttonIndex == 1 ) {
            [d setObject:@"img.ur" forKey:@"PhotoService"];
        }

    }else if ( actionSheetNo == 5 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"NowPlayingFastPost"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"NowPlayingFastPost"];
        }
        
    }else if ( actionSheetNo == 6 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"NowPlayingCallBack"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"NowPlayingCallBack"];
        }
    
    }else if ( actionSheetNo == 7 ) {
        if ( buttonIndex == 0 ) {
            [d setBool:YES forKey:@"NowPlayingEdit"];
        }else if ( buttonIndex == 1 ) {
            [d setBool:NO forKey:@"NowPlayingEdit"];
        }
    
//  }else if ( actionSheetNo == 8 ) {
    
    }else if ( actionSheetNo == 9 ) {
        if ( buttonIndex == 0 ) {
            [d setInteger:0 forKey:@"NowPlayingEditSub"];
        }else if ( buttonIndex == 1 ) {
            [d setInteger:1 forKey:@"NowPlayingEditSub"];
        }else if ( buttonIndex == 2 ) {
            [d setInteger:2 forKey:@"NowPlayingEditSub"];
        }
        
//  }else if ( actionSheetNo == 10 ) {
        
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
        
        case 1:
            return @"投稿関連設定";
            
        case 2:
            return @"その他の設定";
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
