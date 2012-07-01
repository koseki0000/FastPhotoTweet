//
//  HankakuKana.m
//  UtilityClass
//
//  Created by @peace3884 on 12/04/30.
//

#import "HankakuKana.h"

@implementation HankakuKana

+ (NSString *)kana:(id)string {
    
    NSMutableString *mString = [NSMutableString stringWithString:string];
    
	NSArray *originalChars = [NSArray arrayWithObjects:
							  @"ア", @"イ", @"ウ", @"エ", @"オ", 
							  @"カ", @"キ", @"ク", @"ケ", @"コ", 
							  @"サ", @"シ", @"ス", @"セ", @"ソ", 
							  @"タ", @"チ", @"ツ", @"テ", @"ト", 
							  @"ナ", @"ニ", @"ヌ", @"ネ", @"ノ", 
							  @"ハ", @"ヒ", @"フ", @"ヘ", @"ホ",
							  @"マ", @"ミ", @"ム", @"メ", @"モ",
							  @"ヤ", @"ユ", @"ヨ",
							  @"ラ", @"リ", @"ル", @"レ", @"ロ",
							  @"ワ", @"ヲ", @"ン",
							  @"ガ", @"ギ", @"グ", @"ゲ", @"ゴ",
							  @"ザ", @"ジ", @"ズ", @"ゼ", @"ゾ",
							  @"ダ", @"ヂ", @"ヅ", @"デ", @"ド",
							  @"バ", @"ビ", @"ブ", @"ベ", @"ボ",
							  @"パ", @"ピ", @"プ", @"ペ", @"ポ",
							  @"ァ", @"ィ", @"ゥ", @"ェ", @"ォ",
							  @"ャ", @"ュ", @"ョ", @"ッ",
							  @"ー", @"！", @"？", nil];
	
	NSArray *replaceChars = [NSArray arrayWithObjects:
							 @"ｱ", @"ｲ", @"ｳ", @"ｴ", @"ｵ", 
							 @"ｶ", @"ｷ", @"ｸ", @"ｹ", @"ｺ", 
							 @"ｻ", @"ｼ", @"ｽ", @"ｾ", @"ｿ", 
							 @"ﾀ", @"ﾁ", @"ﾂ", @"ﾃ", @"ﾄ", 
							 @"ﾅ", @"ﾆ", @"ﾇ", @"ﾈ", @"ﾉ", 
							 @"ﾊ", @"ﾋ", @"ﾌ", @"ﾍ", @"ﾎ",
							 @"ﾏ", @"ﾐ", @"ﾑ", @"ﾒ", @"ﾓ",
							 @"ﾔ", @"ﾕ", @"ﾖ",
							 @"ﾗ", @"ﾘ", @"ﾙ", @"ﾚ", @"ﾛ",
							 @"ﾜ", @"ｦ", @"ﾝ",
							 @"ｶﾞ", @"ｷﾞ", @"ｸﾞ", @"ｹﾞ", @"ｺﾞ",
							 @"ｻﾞ", @"ｼﾞ", @"ｽﾞ", @"ｾﾞ", @"ｿﾞ",
							 @"ﾀﾞ", @"ﾁﾞ", @"ﾂﾞ", @"ﾃﾞ", @"ﾄﾞ",
							 @"ﾊﾞ", @"ﾋﾞ", @"ﾌﾞ", @"ﾍﾞ", @"ﾎﾞ",
							 @"ﾊﾟ", @"ﾋﾟ", @"ﾌﾟ", @"ﾍﾟ", @"ﾎﾟ",
							 @"ｧ", @"ｨ", @"ｩ", @"ｪ", @"ｫ",
							 @"ｬ", @"ｭ", @"ｮ", @"ｯ",
							 @"-", @"!", @"?", nil];
	
	
    int i = 0;
    for ( NSString *original in originalChars ) {
        
        [mString replaceOccurrencesOfString:original 
                                 withString:[replaceChars objectAtIndex:i] 
                                    options:0 
                                      range:NSMakeRange(0, mString.length)];
        
        i++;
    }
    
	return (NSString *)mString;
}

+ (NSString *)hiragana:(id)string {
    
    NSMutableString *mString = [NSMutableString stringWithString:string];
    
	NSArray *originalChars = [NSArray arrayWithObjects:
							  @"あ", @"い", @"う", @"え", @"お", 
							  @"か", @"き", @"く", @"け", @"こ", 
							  @"さ", @"し", @"す", @"せ", @"そ", 
							  @"た", @"ち", @"つ", @"て", @"と", 
							  @"な", @"に", @"ぬ", @"ね", @"の", 
							  @"は", @"ひ", @"ふ", @"へ", @"ほ",
							  @"ま", @"み", @"む", @"め", @"も",
							  @"や", @"ゆ", @"よ",
							  @"ら", @"り", @"る", @"れ", @"ろ",
							  @"わ", @"を", @"ん",
							  @"が", @"ぎ", @"ぐ", @"げ", @"ご",
							  @"ざ", @"じ", @"ず", @"ぜ", @"ぞ",
							  @"だ", @"ぢ", @"づ", @"で", @"ど",
							  @"ば", @"び", @"ぶ", @"べ", @"ぼ",
							  @"ぱ", @"ぴ", @"ぷ", @"ぺ", @"ぽ",
							  @"ぁ", @"ぃ", @"ぅ", @"ぇ", @"ぉ",
							  @"ゃ", @"ゅ", @"ょ", @"っ",
							  @"ー", @"！", @"？", nil];
	
	NSArray *replaceChars = [NSArray arrayWithObjects:
							 @"ｱ", @"ｲ", @"ｳ", @"ｴ", @"ｵ", 
							 @"ｶ", @"ｷ", @"ｸ", @"ｹ", @"ｺ", 
							 @"ｻ", @"ｼ", @"ｽ", @"ｾ", @"ｿ", 
							 @"ﾀ", @"ﾁ", @"ﾂ", @"ﾃ", @"ﾄ", 
							 @"ﾅ", @"ﾆ", @"ﾇ", @"ﾈ", @"ﾉ", 
							 @"ﾊ", @"ﾋ", @"ﾌ", @"ﾍ", @"ﾎ",
							 @"ﾏ", @"ﾐ", @"ﾑ", @"ﾒ", @"ﾓ",
							 @"ﾔ", @"ﾕ", @"ﾖ",
							 @"ﾗ", @"ﾘ", @"ﾙ", @"ﾚ", @"ﾛ",
							 @"ﾜ", @"ｦ", @"ﾝ",
							 @"ｶﾞ", @"ｷﾞ", @"ｸﾞ", @"ｹﾞ", @"ｺﾞ",
							 @"ｻﾞ", @"ｼﾞ", @"ｽﾞ", @"ｾﾞ", @"ｿﾞ",
							 @"ﾀﾞ", @"ﾁﾞ", @"ﾂﾞ", @"ﾃﾞ", @"ﾄﾞ",
							 @"ﾊﾞ", @"ﾋﾞ", @"ﾌﾞ", @"ﾍﾞ", @"ﾎﾞ",
							 @"ﾊﾟ", @"ﾋﾟ", @"ﾌﾟ", @"ﾍﾟ", @"ﾎﾟ",
							 @"ｧ", @"ｨ", @"ｩ", @"ｪ", @"ｫ",
							 @"ｬ", @"ｭ", @"ｮ", @"ｯ",
							 @"-", @"!", @"?", nil];
	
	
    int i = 0;
    for ( NSString *original in originalChars ) {
        
        [mString replaceOccurrencesOfString:original 
                                 withString:[replaceChars objectAtIndex:i] 
                                    options:0 
                                      range:NSMakeRange(0, mString.length)];
        
        i++;
    }
    
	return (NSString *)mString;
}

+ (NSString *)kanaHiragana:(id)string {
    
    NSString *result = nil;
    
    result = [HankakuKana kana:string];
    result = [HankakuKana hiragana:result];
    
    return  result;
}

@end
