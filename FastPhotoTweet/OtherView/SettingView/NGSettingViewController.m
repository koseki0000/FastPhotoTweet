//
//  NGSettingViewController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/07/15.
//

/////////////////////////////
//////// ARC ENABLED ////////
/////////////////////////////

#import "NGSettingViewController.h"

#define BLANK @""
#define BLANK_ARRAY [NSArray array]

@implementation NGSettingViewController
@synthesize sv;
@synthesize addButton;
@synthesize ngTypeSegment;
@synthesize ngWordField;
@synthesize userField;
@synthesize exclusionUserField;
@synthesize regexpLabel;
@synthesize regexpSwitch;
@synthesize addedNgSettings;
@synthesize reTweetSwitch;
@synthesize reTweetText;

#pragma mark - Initialize

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self ) {
        
        addButton = [[UIBarButtonItem alloc] initWithTitle:@"登録"
                                                     style:UIBarButtonItemStyleBordered
                                                    target:self
                                                    action:@selector(pushAddButton:)];
        addButton.enabled = NO;
        self.navigationItem.rightBarButtonItem = addButton;
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    ngWordField.text = BLANK;
    userField.text = BLANK;
    exclusionUserField.text = BLANK;
    
    if ( ![EmptyCheck check:[USER_DEFAULTS arrayForKey:@"NGWord"]] ) {
        [USER_DEFAULTS setObject:BLANK_ARRAY forKey:@"NGWord"];
    }
    
    if ( ![EmptyCheck check:[USER_DEFAULTS arrayForKey:@"NGName"]] ) {
        [USER_DEFAULTS setObject:BLANK_ARRAY forKey:@"NGName"];
    }
    
    if ( ![EmptyCheck check:[USER_DEFAULTS arrayForKey:@"NGClient"]] ) {
        [USER_DEFAULTS setObject:BLANK_ARRAY forKey:@"NGClient"];
    }
    
    ngSettingArray = [NSMutableArray arrayWithArray:[USER_DEFAULTS objectForKey:@"NGWord"]];
    
    [addedNgSettings flashScrollIndicators];
}

#pragma mark - IBAction

- (IBAction)doneButtonVisible:(UITextField *)sender {
    
    if ( reTweetSwitch.on &&
         [EmptyCheck string:userField.text] ) {
        
        addButton.enabled = YES;
        
    } else {
     
        if ( [EmptyCheck string:ngWordField.text] ) {
            
            addButton.enabled = YES;
            
        } else {
            
            addButton.enabled = NO;
        }
    }
}

- (IBAction)changeSegment:(UISegmentedControl *)sender {
 
    ngWordField.text = BLANK;
    userField.text = BLANK;
    exclusionUserField.text = BLANK;
    regexpSwitch.on = NO;
    addButton.enabled = NO;
    
    if ( ngTypeSegment.selectedSegmentIndex == 0 ) {
        
        userField.hidden = NO;
        exclusionUserField.hidden = NO;
        regexpSwitch.hidden = NO;
        regexpLabel.hidden = NO;
        reTweetText.hidden = NO;
        reTweetSwitch.hidden = NO;
        
        ngWordField.placeholder = @"NGワード (必須)";
        
        //NGワード設定を読み込む
        ngSettingArray = [NSMutableArray arrayWithArray:[USER_DEFAULTS objectForKey:@"NGWord"]];
        
    } else if ( ngTypeSegment.selectedSegmentIndex == 1 ) {
    
        userField.hidden = YES;
        exclusionUserField.hidden = YES;
        regexpSwitch.hidden = YES;
        regexpLabel.hidden = YES;
        reTweetText.hidden = YES;
        reTweetSwitch.hidden = YES;
        
        ngWordField.placeholder = @"NGネーム (必須)";
        
        //NGネーム設定を読み込む
        ngSettingArray = [NSMutableArray arrayWithArray:[USER_DEFAULTS objectForKey:@"NGName"]];
        
    } else if ( ngTypeSegment.selectedSegmentIndex == 2 ) {
        
        userField.hidden = YES;
        exclusionUserField.hidden = YES;
        regexpSwitch.hidden = YES;
        regexpLabel.hidden = YES;
        reTweetText.hidden = YES;
        reTweetSwitch.hidden = YES;

        ngWordField.placeholder = @"NGクライアント (必須)";
        
        //NGクライアント設定を読み込む
        ngSettingArray = [NSMutableArray arrayWithArray:[USER_DEFAULTS objectForKey:@"NGClient"]];
    }
    
    [addedNgSettings reloadData];
}

- (IBAction)pushAddButton:(UIBarButtonItem *)sender {
    
    if ( ![EmptyCheck string:ngWordField.text] ) {
        
        //必須項目未入力
        [ShowAlert error:@"必須項目が入力されていません。"];
        [ngWordField becomeFirstResponder];
        
    } else {
        
        NSMutableDictionary *addDic = [NSMutableDictionary dictionary];
        
        //NG情報の登録を行う
        if ( ngTypeSegment.selectedSegmentIndex == 0 ) {
            
            if ( [EmptyCheck string:userField.text] && [EmptyCheck string:exclusionUserField.text] && 
                 [userField.text isEqualToString:exclusionUserField.text] ) {
                
                [ShowAlert error:@"NG指定ユーザーと除外ユーザーは同じに出来ません。"];
                
                return;
            }
            
            //NGワード設定を読み込む
            NSMutableArray *ngWordArray = [NSMutableArray arrayWithArray:[USER_DEFAULTS objectForKey:@"NGWord"]];
            
            //NGワード
            [addDic setObject:ngWordField.text forKey:@"Word"];
            
            if ( [EmptyCheck string:userField.text] ) {
                
                NSMutableString *removeAtMarkString = [NSMutableString stringWithString:userField.text];
                [removeAtMarkString replaceOccurrencesOfString:@"@" 
                                         withString:@"" 
                                            options:0 
                                              range:NSMakeRange(0, removeAtMarkString.length)];
                
                //指定ユーザーNG
                [addDic setObject:removeAtMarkString forKey:@"User"];
            }
            
            if ( [EmptyCheck string:exclusionUserField.text] ) {
                
                NSMutableString *removeAtMarkString = [NSMutableString stringWithString:exclusionUserField.text];
                [removeAtMarkString replaceOccurrencesOfString:@"@" 
                                                    withString:@"" 
                                                       options:0 
                                                         range:NSMakeRange(0, removeAtMarkString.length)];
                
                //指定ユーザーNG除外
                [addDic setObject:removeAtMarkString forKey:@"ExclusionUser"];
            }
            
            if ( regexpSwitch.on ) {
                
                //正規表現
                [addDic setObject:@"YES" forKey:@"RegExp"];
            }
            
            if ( reTweetSwitch.on ) {
                
                //ReTweet
                [addDic setObject:@"YES" forKey:@"ReTweet"];
            }
            
            [ngWordArray addObject:addDic];
            
            //NSLog(@"ngWordArray: %@", ngWordArray);
            
            [USER_DEFAULTS setObject:ngWordArray forKey:@"NGWord"];
            
            ngSettingArray = ngWordArray;
            
        } else if ( ngTypeSegment.selectedSegmentIndex == 1 ) {
            
            ngWordField.text = [ngWordField.text deleteWhiteSpace];
            ngWordField.text = [ngWordField.text deleteWord:@"@"];
            
            //NGネーム設定を読み込む
            NSMutableArray *ngNameArray = [NSMutableArray arrayWithArray:[USER_DEFAULTS objectForKey:@"NGName"]];
            
            //NGネーム
            [addDic setObject:ngWordField.text forKey:@"User"];
            
            [ngNameArray addObject:addDic];
            
            //NSLog(@"ngNameArray: %@", ngNameArray);
            
            [USER_DEFAULTS setObject:ngNameArray forKey:@"NGName"];
            
            ngSettingArray = ngNameArray;
            
        } else if ( ngTypeSegment.selectedSegmentIndex == 2 ) {
            
            //NGクライアント設定を読み込む
            NSMutableArray *ngClientArray = [NSMutableArray arrayWithArray:[USER_DEFAULTS objectForKey:@"NGClient"]];
            
            //NGクライアント
            [addDic setObject:ngWordField.text forKey:@"Client"];
            
            [ngClientArray addObject:addDic];
            
            //NSLog(@"ngClientArray: %@", ngClientArray);
            
            [USER_DEFAULTS setObject:ngClientArray forKey:@"NGClient"];
            
            ngSettingArray = ngClientArray;
        }
        
        //初期化
        ngWordField.text = BLANK;
        userField.text = BLANK;
        exclusionUserField.text = BLANK;
        addButton.enabled = NO;
        regexpSwitch.on = NO;
        reTweetSwitch.on = NO;
        
        [addedNgSettings reloadData];
    }
}

- (IBAction)pushCloseButton:(UIBarButtonItem *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    
    if ( ![EmptyCheck string:sender.text] ) {
        
        [sender resignFirstResponder];
        
        return YES;
    }
    
    if ( sender.tag == 0 ) {
        
        if ( ngTypeSegment.selectedSegmentIndex == 0 ) {
            
            //NGワードの場合
            
            if ( regexpSwitch.on ) {
                
                NSString *testString = @"test";
                NSError *error = nil;
                NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:ngWordField.text
                                                                                        options:0 
                                                                                          error:&error];
                
                NSTextCheckingResult *match = [regexp firstMatchInString:testString 
                                                                 options:0 
                                                                   range:NSMakeRange(0, testString.length)];
                
                if ( match.numberOfRanges != 0 ) {}
            }
            
        } else if ( ngTypeSegment.selectedSegmentIndex == 1 ) {
            
        } else if ( ngTypeSegment.selectedSegmentIndex == 2 ) {
            
        }
        
    } else if ( sender.tag == 1 || sender.tag == 2 ) {
        
    }
    
    [sender resignFirstResponder];
    
    return YES;
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //TableViewの要素数を返す
	return [ngSettingArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//TableViewCellを生成
	static NSString *identifier = @"NGSettingCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    NSMutableString *cellString = [NSMutableString string];
    NSDictionary *currentNg = [ngSettingArray objectAtIndex:indexPath.row];
    
    if ( ngTypeSegment.selectedSegmentIndex == 0 ) {

        [cellString appendString:@"NGワード: "];
        [cellString appendString:[currentNg objectForKey:@"Word"]];
        [cellString appendString:@"\n"];
        
        if ( [EmptyCheck string:[currentNg objectForKey:@"User"]] ) {
            
            [cellString appendString:[NSString stringWithFormat:@"ユーザー指定: %@", [currentNg objectForKey:@"User"]]];
            [cellString appendString:@"\n"];
        }
        
        if ( [EmptyCheck string:[currentNg objectForKey:@"ExclusionUser"]] ) {
            
            [cellString appendString:[NSString stringWithFormat:@"除外ユーザー: %@", [currentNg objectForKey:@"ExclusionUser"]]];
            [cellString appendString:@"\n"];
        }
        
        if ( [[currentNg objectForKey:@"RegExp"] isEqualToString:@"YES"] ) {
            
            [cellString appendString:@"正規表現: 有効"];
            [cellString appendString:@"\n"];
        }
        
        if ( [[currentNg objectForKey:@"ReTweet"] isEqualToString:@"YES"] ) {
            
            [cellString appendString:@"ReTweetのみ: 有効"];
        }
        
    } else if ( ngTypeSegment.selectedSegmentIndex == 1 ) {
        
        cellString = [NSMutableString stringWithFormat:@"NGユーザー: %@", [currentNg objectForKey:@"User"]];
        
    } else if ( ngTypeSegment.selectedSegmentIndex == 2 ) {
        
        cellString = [NSMutableString stringWithFormat:@"NGクライアント: %@", [currentNg objectForKey:@"Client"]];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = cellString;
    cell.textLabel.frame = CGRectMake(0, 0, 320, [self heightForContents:cellString]);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableString *cellString = [NSMutableString string];
    NSDictionary *currentNg = [ngSettingArray objectAtIndex:indexPath.row];
    
    if ( ngTypeSegment.selectedSegmentIndex == 0 ) {
        
        [cellString appendString:@"NGワード: "];
        [cellString appendString:[currentNg objectForKey:@"Word"]];
        [cellString appendString:@"\n"];
        
        if ( [EmptyCheck string:[currentNg objectForKey:@"User"]] ) {
            
            [cellString appendString:[NSString stringWithFormat:@"ユーザー指定: %@", [currentNg objectForKey:@"User"]]];
            [cellString appendString:@"\n"];
        }
        
        if ( [EmptyCheck string:[currentNg objectForKey:@"ExclusionUser"]] ) {
            
            [cellString appendString:[NSString stringWithFormat:@"除外ユーザー: %@", [currentNg objectForKey:@"ExclusionUser"]]];
            [cellString appendString:@"\n"];
        }
        
        if ( [[currentNg objectForKey:@"RegExp"] isEqualToString:@"YES"] ) {
            
            [cellString appendString:@"正規表現: 有効"];
            [cellString appendString:@"\n"];
        }
        
        if ( [[currentNg objectForKey:@"ReTweet"] isEqualToString:@"YES"] ) {
            
            [cellString appendString:@"ReTweet: 有効"];
        }
        
    } else if ( ngTypeSegment.selectedSegmentIndex == 1 ) {
        
        cellString = [NSMutableString stringWithFormat:@"NGユーザー: %@", [currentNg objectForKey:@"User"]];
        
    } else if ( ngTypeSegment.selectedSegmentIndex == 2 ) {
        
        cellString = [NSMutableString stringWithFormat:@"NGクライアント: %@", [currentNg objectForKey:@"Client"]];
    }
    
    //NSLog(@"[%d]%@", indexPath.row , cellString);
    
    return [self heightForContents:cellString];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //セルの選択状態を解除
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ( ngTypeSegment.selectedSegmentIndex == 0 ) {
    
        NSDictionary *dic = [ngSettingArray objectAtIndex:indexPath.row];
        
        ngWordField.text = [dic objectForKey:@"Word"];
        
        if ( [EmptyCheck string:[dic objectForKey:@"User"]] ) {
            
            userField.text = [dic objectForKey:@"User"];
        }
    
        if ( [EmptyCheck string:[dic objectForKey:@"ExclusionUser"]] ) {
            
            exclusionUserField.text = [dic objectForKey:@"ExclusionUser"];
        }
        
        if ( [EmptyCheck string:[dic objectForKey:@"RegExp"]] ) {
            
            regexpSwitch.on = YES;
        }
        
        if ( [EmptyCheck string:[dic objectForKey:@"ReTweet"]] ) {
            
            reTweetSwitch.on = YES;
        }
        
        [ngSettingArray removeObjectAtIndex:indexPath.row];
        
        [USER_DEFAULTS setObject:ngSettingArray forKey:@"NGWord"];
        
    } else if ( ngTypeSegment.selectedSegmentIndex == 1 ) {
    
        NSDictionary *dic = [ngSettingArray objectAtIndex:indexPath.row];
        
        if ( [EmptyCheck string:[dic objectForKey:@"User"]] ) {
            
            ngWordField.text = [dic objectForKey:@"User"];
        }
        
        [ngSettingArray removeObjectAtIndex:indexPath.row];
        
        [USER_DEFAULTS setObject:ngSettingArray forKey:@"NGName"];
    
    } else if ( ngTypeSegment.selectedSegmentIndex == 2 ) {
        
        NSDictionary *dic = [ngSettingArray objectAtIndex:indexPath.row];
        
        if ( [EmptyCheck string:[dic objectForKey:@"ExclusionUser"]] ) {
            
            ngWordField.text = [dic objectForKey:@"ExclusionUser"];
        }
        
        [ngSettingArray removeObjectAtIndex:indexPath.row];
        
        [USER_DEFAULTS setObject:ngSettingArray forKey:@"NGClient"];
    }
    
    [addedNgSettings reloadData];
    
    addButton.enabled = YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *deleteType = nil;
    
    if ( ngTypeSegment.selectedSegmentIndex == 0 ) {
        
        deleteType = @"NGWord";
        
    } else if ( ngTypeSegment.selectedSegmentIndex == 1 ) {
        
        deleteType = @"NGName";
        
    } else if ( ngTypeSegment.selectedSegmentIndex == 2 ) {
        
        deleteType = @"NGClient";
    }
    
    NSMutableArray *deleteArray = [NSMutableArray arrayWithArray:[USER_DEFAULTS objectForKey:deleteType]];
    [deleteArray removeObjectAtIndex:indexPath.row];
    [USER_DEFAULTS setObject:deleteArray forKey:deleteType];
    
    [ngSettingArray removeObjectAtIndex:indexPath.row];
    
    [addedNgSettings deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (CGFloat)heightForContents:(NSString *)contents {
    
	CGSize labelSize = [contents sizeWithFont:[UIFont systemFontOfSize:14.0]
                            constrainedToSize:CGSizeMake(264, 20000)
                                lineBreakMode:NSLineBreakByWordWrapping];
	
    return labelSize.height + 18;
}

#pragma mark - View

- (void)viewDidUnload {
    
    [self setNgTypeSegment:nil];
    [self setNgWordField:nil];
    [self setUserField:nil];
    [self setExclusionUserField:nil];
    [self setRegexpLabel:nil];
    [self setRegexpSwitch:nil];
    [self setAddedNgSettings:nil];
    [self setAddButton:nil];
    [self setSv:nil];
    [self setReTweetText:nil];
    [self setReTweetSwitch:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotate {
    
    if ( [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait ) return YES;
    
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    
    return UIInterfaceOrientationMaskPortrait;
}

@end
