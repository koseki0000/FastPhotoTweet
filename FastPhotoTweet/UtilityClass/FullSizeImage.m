//
//  FullSizeImage.m
//  UtilityClass
//
//  Created by @peace3884 on 12/05/13.
//

#import "FullSizeImage.h"

#define BLANK @""

@implementation FullSizeImage

//画像共有サービスのURLを渡すと画像本体のURLを返す
+ (NSString *)urlString:(NSString *)urlString {
    
    //NSLog(@"originalUrl: %@", urlString);
    
    if ( [urlString hasPrefix:@"http://twitvid.com/"] || [urlString hasPrefix:@"http://www.twitvid.com/"] ) {
        
        NSMutableString *mString = [NSMutableString stringWithString:urlString];
        [mString replaceOccurrencesOfString:@"www." 
                                 withString:BLANK 
                                    options:0 
                                      range:NSMakeRange(0, [mString length] )];
        
        [mString replaceOccurrencesOfString:@"http://twitvid.com/" 
                                 withString:BLANK 
                                    options:0 
                                      range:NSMakeRange(0, [mString length] )];

        NSString *imageID1 = [mString substringWithRange:NSMakeRange(0,1)];
        NSString *imageID2 = [mString substringWithRange:NSMakeRange(1,1)];
        NSString *imageID3 = [mString substringWithRange:NSMakeRange(2,1)];
        urlString = [NSString stringWithFormat:@"http://llphotos.twitvid.com/twitvidphotos/%@/%@/%@/%@.jpg", imageID1, imageID2, imageID3, mString];
    
    }else if ( [urlString hasPrefix:@"http://lockerz.com/"] ) {
        
        urlString = [NSString stringWithFormat:@"http://api.plixi.com/api/tpapi.svc/imagefromurl?size=big&url=%@", urlString];
    
    }else if ([urlString hasPrefix:@"http://p.twipple.jp/"]) {
        
        urlString = [NSString stringWithFormat:@"http://p.twpl.jp/show/orig/%@", [urlString lastPathComponent]];
    
    }else if ( [urlString hasPrefix:@"http://yfrog.com/"] ) {
        
        NSString *yfrogReqUrl = [NSString stringWithFormat:@"http://yfrog.com/api/xmlInfo?path=%@", [urlString lastPathComponent]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:yfrogReqUrl]];
        NSError *error = nil;
        NSData *response = [NSURLConnection sendSynchronousRequest:request 
                                                 returningResponse:nil 
                                                             error:&error];
        
        NSString *xmlString = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] autorelease];
        
        NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"<image_link>.*</image_link>"
                                                                                options:0
                                                                                  error:&error];
        
        NSTextCheckingResult *match = [regexp firstMatchInString:xmlString 
                                                         options:0 
                                                           range:NSMakeRange(0, xmlString.length)];
        
        if ( match.numberOfRanges != 0 ) {
            
            NSMutableString *tempString = [NSMutableString stringWithString:[xmlString substringWithRange:[match rangeAtIndex:0]]];
            
            [tempString replaceOccurrencesOfString:@"<image_link>"
                                     withString:@""
                                        options:0
                                          range:NSMakeRange(0, tempString.length)];
            
            [tempString replaceOccurrencesOfString:@"</image_link>"
                                        withString:@""
                                           options:0
                                             range:NSMakeRange(0, tempString.length)];
            
            urlString = (NSString *)tempString;
        }
        
    }else if ( [urlString hasPrefix:@"http://ow.ly/i/"] ) {
        
        urlString = [NSString stringWithFormat:@"http://static.ow.ly/photos/normal/%@.jpg", [urlString lastPathComponent]];
        
    }else if ( [urlString hasPrefix:@"http://twitpic.com/"] && ![urlString hasPrefix:@"http://twitpic.com/photos/"] && 
              ![urlString hasPrefix:@"http://twitpic.com/show"] && ![urlString hasPrefix:@"http://twitpic.com/account"] && 
              ![urlString hasPrefix:@"http://twitpic.com/session"] && ![urlString hasPrefix:@"http://twitpic.com/events"] &&
              ![urlString hasPrefix:@"http://twitpic.com/faces"] && ![urlString hasPrefix:@"http://twitpic.com/upload"] && 
              ![urlString hasPrefix:@"http://twitpic.com/ad_"] && ![urlString hasSuffix:@".do"] &&
              ![urlString isEqualToString:@"http://twitpic.com/"] &&
              ![RegularExpression boolWithRegExp:urlString regExpPattern:@"http://twitpic.com/[0-9a-zA-Z]+/full$"] ) {
        
        urlString = [NSString stringWithFormat:@"http://twitpic.com/show/full/%@", [urlString lastPathComponent]];
        
    }else if ( [urlString hasPrefix:@"http://instagr.am/p/"] ) {
        
        NSString *sourceCode = [FullSizeImage getSourceCode:[NSString stringWithFormat:@"http://instagr.am/api/v1/oembed/?url=%@", urlString]];
        
        NSDictionary *results = [sourceCode JSONValue];
        
        if ( results.count == 0 ) return urlString;
        
		urlString = [results objectForKey:@"url"];
        
    }else if ( [RegularExpression boolWithRegExp:urlString regExpPattern:@"https?://(mobile\\.)?twitter\\.com/[_a-zA-Z0-9]{1,15}/status/[0-9]+/photo/1"] ) {
        
        NSString *originalUrl = urlString;
        
        NSString *sourceCode = [FullSizeImage getSourceCode:urlString];
        
        if ( sourceCode == nil ) return urlString;
        
        urlString = [RegularExpression strWithRegExp:sourceCode
                                   regExpPattern:@"https?://p(bs)?\\.twimg\\.com/(media/)?[-_\\.a-zA-Z0-9]+(:large)?"];
        
        if ( ![urlString hasSuffix:@":large"] ) {
            
            urlString = [NSString stringWithFormat:@"%@:large", urlString];
        }
        
        if ( [urlString isEqualToString:@":large"] ) urlString = originalUrl;
        
    }else if ( [RegularExpression boolWithRegExp:urlString regExpPattern:@"https?://via.me/-[a-zA-Z0-9]+"] ) {
        
        NSString *sourceCode = [FullSizeImage getSourceCode:urlString];
        
        if ( sourceCode == nil ) return urlString;
    
        urlString = [RegularExpression strWithRegExp:sourceCode 
                                   regExpPattern:@"https?://(s[0-9]\\.amazonaws\\.com/com\\.clixtr\\.picbounce|img\\.viame-cdn\\.com)/photos/[-a-zA-Z0-9]+/[a-z]600x600\\.(jpe?g|png)"];
    
    }else if ( [RegularExpression boolWithRegExp:urlString regExpPattern:@"https?://img.ly/[a-zA-Z0-9]+"] ) {
        
        NSString *sourceCode = [FullSizeImage getSourceCode:urlString];
        
        if ( sourceCode == nil ) return urlString;
        
        NSString *target = [RegularExpression strWithRegExp:sourceCode
                                              regExpPattern:@"href=\"/images/[0-9]+/full\">Show Full View"];
        
        NSMutableString *tempString = [NSMutableString stringWithString:target];
        
        [tempString replaceOccurrencesOfString:@"href=\""
                                    withString:@""
                                       options:0
                                         range:NSMakeRange(0, tempString.length)];

        [tempString replaceOccurrencesOfString:@"\">Show Full View"
                                    withString:@""
                                       options:0
                                         range:NSMakeRange(0, tempString.length)];
        
        target = [NSString stringWithFormat:@"http://img.ly%@", tempString];
        
        sourceCode = [FullSizeImage getSourceCode:target];
        
        if ( sourceCode == nil ) return urlString;
        
        urlString = [RegularExpression strWithRegExp:sourceCode
                                       regExpPattern:@"https?://s[0-9]\\.amazonaws\\.com/imgly_production/[0-9]+/original\\.(je?pg|png)"];
    }
    
    //NSLog(@"fullUrl: %@", urlString);
    
    return urlString;
}

+ (NSString *)getSourceCode:(NSString *)urlString {
    
    NSError *error = nil;
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSData *response = [NSURLConnection sendSynchronousRequest:request 
                                             returningResponse:nil 
                                                         error:&error];
    
    int encodingList[] = {
        
        NSUTF8StringEncoding,			// UTF-8
        NSShiftJISStringEncoding,		// Shift_JIS
        NSJapaneseEUCStringEncoding,	// EUC-JP
        NSISO2022JPStringEncoding,		// JIS
        NSUnicodeStringEncoding,		// Unicode
        NSASCIIStringEncoding			// ASCII
    };
    
    NSString *dataStr = nil;
    int max = sizeof( encodingList ) / sizeof( encodingList[0] );
    
    for ( int i = 0; i < max; i++ ) {
        
        dataStr = [[[NSString alloc] initWithData:response encoding:encodingList[i]] autorelease];
        
        if ( dataStr != nil ) break;
    }
    
    if ( error ) [ShowAlert error:error.localizedDescription];
    
    return dataStr;
}

+ (BOOL)checkImageUrl:(NSString *)urlString {
    
    BOOL result = NO;
    
    if ( [urlString hasPrefix:@"http://twitvid.com/"] || [urlString hasPrefix:@"http://www.twitvid.com/"] ) {
        result = YES;
    }else if ( [urlString hasPrefix:@"http://lockerz.com/"] ) {
        result = YES;
    }else if ([urlString hasPrefix:@"http://p.twipple.jp/"]) {
        result = YES;
    }else if ( [urlString hasPrefix:@"http://yfrog.com/"] ) {
        result = YES;
    }else if ( [urlString hasPrefix:@"http://ow.ly/i/"] ) {
        result = YES;
    }else if ( [urlString hasPrefix:@"http://twitpic.com/"] && ![urlString hasPrefix:@"http://twitpic.com/photos/"] &&
              ![urlString hasPrefix:@"http://twitpic.com/show"] && ![urlString hasPrefix:@"http://twitpic.com/account"] &&
              ![urlString hasPrefix:@"http://twitpic.com/session"] && ![urlString hasPrefix:@"http://twitpic.com/events"] &&
              ![urlString hasPrefix:@"http://twitpic.com/faces"] && ![urlString hasPrefix:@"http://twitpic.com/upload"] &&
              ![urlString hasPrefix:@"http://twitpic.com/ad_"] && ![urlString hasSuffix:@".do"] &&
              ![urlString isEqualToString:@"http://twitpic.com/"] &&
              ![RegularExpression boolWithRegExp:urlString regExpPattern:@"http://twitpic.com/[0-9a-zA-Z]+/full$"] ) {
        result = YES;
    }else if ( [urlString hasPrefix:@"http://instagr.am/p/"] ) {
        result = YES;
    }else if ( [RegularExpression boolWithRegExp:urlString regExpPattern:@"https?://(mobile\\.)?twitter\\.com/[_a-zA-Z0-9]{1,15}/status/[0-9]+/photo/1"] ) {
        result = YES;
    }else if ( [RegularExpression boolWithRegExp:urlString regExpPattern:@"https?://via.me/-[a-zA-Z0-9]+"] ) {
        result = YES;
    }else if ( [RegularExpression boolWithRegExp:urlString regExpPattern:@"https?://img.ly/[a-zA-Z0-9]+"] ) {
        result = YES;
    }
    
    if ( [RegularExpression boolWithRegExp:[urlString lowercaseString] regExpPattern:@"\\.(jpe?g|png|gif)$"] ) {
        result = YES;
    }
    
    return result;
}

@end
