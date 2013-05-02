//
//  FullSizeImage.m
//  UtilityClass
//
//  Created by @peace3884 on 12/05/13.
//

#import "FullSizeImage.h"

#define BLANK @""

#define TWITTER_FULL_PATTERN @"https?://(mobile\\.)?twitter\\.com/[_a-zA-Z0-9]{1,15}/status/[0-9]+/photo/1"
#define PIXIV_FULL_PATTERN @"https?://(www\\.)?(touch\\.)?pixiv\\.net/member_illust\\.php\\?(mode=(medium|big)|illust_id=[0-9]+)&(illust_id=[0-9]+|mode=(medium|big))"

@implementation FullSizeImage

//画像共有サービスのURLを渡すと画像本体のURLを返す
+ (NSString *)urlString:(NSString *)urlString {
    
//    NSLog(@"originalUrl: %@", urlString);
    
    if ( urlString != nil && ![urlString isEqualToString:@""] ) {
        
        if ( [urlString hasPrefix:@"http://twitvid.com/"] || [urlString hasPrefix:@"http://www.twitvid.com/"] ) {
            
            NSString *lastPath = [urlString lastPathComponent];
            
            urlString = [NSString stringWithFormat:@"http://llphotos.twitvid.com/twitvidphotos/%@/%@/%@/%@.jpg",
                         [lastPath substringWithRange:NSMakeRange(0,1)],
                         [lastPath substringWithRange:NSMakeRange(1,1)],
                         [lastPath substringWithRange:NSMakeRange(2,1)],
                         lastPath];
            
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
            
            if ( xmlString == nil ) return urlString;
            
            
            
            NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"<image_link>.*</image_link>"
                                                                                    options:0
                                                                                      error:&error];
            
            NSTextCheckingResult *match = [regexp firstMatchInString:xmlString
                                                             options:0
                                                               range:NSMakeRange(0, xmlString.length)];
            
            if ( match.numberOfRanges != 0 ) {
                
                NSMutableString *tempString = [NSMutableString stringWithString:[xmlString substringWithRange:[match rangeAtIndex:0]]];
                
                if ( tempString != nil ) {
                    
                    [tempString replaceOccurrencesOfString:@"<image_link>"
                                                withString:@""
                                                   options:0
                                                     range:NSMakeRange(0, tempString.length)];
                    
                    [tempString replaceOccurrencesOfString:@"</image_link>"
                                                withString:@""
                                                   options:0
                                                     range:NSMakeRange(0, tempString.length)];
                    
                    urlString = [NSString stringWithString:tempString];
                }
            }
            
        }else if ( [urlString hasPrefix:@"http://ow.ly/i/"] ) {
            
            urlString = [NSString stringWithFormat:@"http://static.ow.ly/photos/normal/%@.jpg", [urlString lastPathComponent]];
            
        }else if ( [urlString hasPrefix:@"http://twitpic.com/"] &&          ![urlString hasPrefix:@"http://twitpic.com/photos/"] &&
                  ![urlString hasPrefix:@"http://twitpic.com/show"] &&      ![urlString hasPrefix:@"http://twitpic.com/account"] &&
                  ![urlString hasPrefix:@"http://twitpic.com/session"] &&   ![urlString hasPrefix:@"http://twitpic.com/events"] &&
                  ![urlString hasPrefix:@"http://twitpic.com/faces"] &&     ![urlString hasPrefix:@"http://twitpic.com/upload"] &&
                  ![urlString hasPrefix:@"http://twitpic.com/ad_"] &&       ![urlString hasSuffix:@".do"] &&
                  ![urlString isEqualToString:@"http://twitpic.com/"] &&
                  ![urlString boolWithRegExp:@"http://twitpic.com/[0-9a-zA-Z]+/full$"] ) {
            
            urlString = [NSString stringWithFormat:@"http://twitpic.com/show/full/%@", [urlString lastPathComponent]];
            
        }else if ( [urlString boolWithRegExp:@"http://instagr.?am(.com)?/p/"] ) {
            
            NSString *sourceCode = [FullSizeImage getSourceCode:[NSString stringWithFormat:@"http://instagr.am/api/v1/oembed/?url=%@", urlString]];
            
            NSDictionary *results = [sourceCode JSONValue];
            
            if ( results.count == 0 ) return urlString;
            
            urlString = [results objectForKey:@"url"];
            
        }else if ( [urlString boolWithRegExp:TWITTER_FULL_PATTERN] ) {
            
            NSString *originalUrl = urlString;
            
            NSString *sourceCode = [FullSizeImage getSourceCode:urlString];
            
            if ( sourceCode == nil ) return urlString;
            
            urlString = [sourceCode stringWithRegExp:@"https?://p(bs)?\\.twimg\\.com/(media/)?[-_\\.a-zA-Z0-9]+(:large)?"];
            
            if ( ![urlString hasSuffix:@":large"] ) {
                
                urlString = [NSString stringWithFormat:@"%@:large", urlString];
            }
            
            if ( [urlString isEqualToString:@":large"] ) urlString = originalUrl;
            
        }else if ( [urlString boolWithRegExp:@"https?://via.me/-[a-zA-Z0-9]+"] ) {
            
            NSString *sourceCode = [FullSizeImage getSourceCode:urlString];
            
            if ( sourceCode == nil ) return urlString;
            
            urlString = [sourceCode stringWithRegExp:@"https?://(s[0-9]\\.amazonaws\\.com/com\\.clixtr\\.picbounce|img\\.viame-cdn\\.com)/photos/[-a-zA-Z0-9]+/[a-z]600x600\\.(jpe?g|png)"];
            
        }else if ( [urlString boolWithRegExp:@"https?://img.ly/[a-zA-Z0-9]+"] ) {
            
            NSString *sourceCode = [FullSizeImage getSourceCode:urlString];
            
            if ( sourceCode == nil ) return urlString;
            
            NSString *target = [sourceCode stringWithRegExp:@"href=\"/images/[0-9]+/full\">Show Full View"];
            
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
            NSLog(@"%@", target);
            
            sourceCode = [FullSizeImage getSourceCode:target];
            
            if ( sourceCode == nil ) return urlString;
            
            urlString = [sourceCode stringWithRegExp:@"https?://s[0-9]\\.amazonaws\\.com/imgly_production/[0-9]+/original\\.(je?pg|png)"];
            NSLog(@"%@", urlString);
            
            if ( [urlString isEqualToString:@""] ) {
                
                urlString = [sourceCode stringWithRegExp:@"https?://(www.\\)?img\\.ly/system/uploads/([0-9]+/){3}original_image.\\(jpe?g|png)"];
            }
        
            NSLog(@"%@", urlString);
            
        }else if ( [urlString boolWithRegExp:PIXIV_FULL_PATTERN] ) {
            
            NSString *originalURL = urlString;
            urlString = [urlString replaceWord:@"mode=medium" replacedWord:@"mode=big"];
            NSString *sourceCode = [FullSizeImage getSourceCode:urlString];

            if ( [sourceCode rangeOfString:@"<a href=\"member_illust.php?mode=manga"].location != NSNotFound ) {
                
                urlString = originalURL;
                
            }else {
             
                NSString *fullUrl = [sourceCode stringWithRegExp:@"https?://i[0-9]+\\.pixiv\\.net/img[0-9]+/img/[-_a-zA-Z0-9]+/[0-9]+(_s)?\\.(jpe?g|png)"];
                
                if ( [fullUrl rangeOfString:@"_s."].location != NSNotFound ) {
                    
                    fullUrl = [fullUrl replaceWord:@"_s." replacedWord:@"."];
                }
                
                if ( ![fullUrl isEqualToString:@""] ) {
                    
                    urlString = fullUrl;
                }
            }
        }else if ( [urlString hasPrefix:@"http://campl.us/"] ) {
            
            NSString *sourceCode = [FullSizeImage getSourceCode:urlString];
            urlString = [sourceCode stringWithRegExp:@"https?://(www\\.)?pics\\.campl\\.us/f/[0-9]+/[-_\\.a-zA-Z0-9]+\\.(jpe?g|png)"];
        }
    }
    
//    NSLog(@"fullUrl: %@", urlString);
    
    return urlString;
}

+ (NSString *)getSourceCode:(NSString *)urlString {
    
    NSError *error = nil;
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    if ( [urlString rangeOfString:@"pixiv.net"].location != NSNotFound ) {
     
        if ( [urlString rangeOfString:@"touch"].location != NSNotFound ) {
            
            [request setValue:@"http://www.touch.pixiv.net/" forHTTPHeaderField:@"Referer"];
            
        }else {
            
            [request setValue:@"http://www.pixiv.net/" forHTTPHeaderField:@"Referer"];
        }
    }
    
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
              ![urlString boolWithRegExp:@"http://twitpic.com/[0-9a-zA-Z]+/full$"] ) {
        result = YES;
    }else if ( [urlString boolWithRegExp:@"http://instagr.?am(.com)?/p/"] ) {
        result = YES;
    }else if ( [urlString boolWithRegExp:TWITTER_FULL_PATTERN] ) {
        result = YES;
    }else if ( [urlString boolWithRegExp:@"https?://via.me/-[a-zA-Z0-9]+"] ) {
        result = YES;
    }else if ( [urlString boolWithRegExp:@"https?://img.ly/[a-zA-Z0-9]+"] ) {
        result = YES;
    }else if ( [urlString boolWithRegExp:PIXIV_FULL_PATTERN] ) {
        result = YES;
    }else if ( [urlString hasPrefix:@"http://campl.us/"] ) {
        result = YES;
    }
    
    if ( [[urlString lowercaseString] boolWithRegExp:@"\\.(jpe?g|png|gif)"] ) {
        result = YES;
    }
    
    return result;
}

+ (BOOL)isSocialService:(NSString *)urlString {
    
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
              ![urlString boolWithRegExp:@"http://twitpic.com/[0-9a-zA-Z]+/full$"] ) {
        result = YES;
    }else if ( [urlString boolWithRegExp:@"http://instagr.?am(.com)?/p/"] ) {
        result = YES;
    }else if ( [urlString boolWithRegExp:TWITTER_FULL_PATTERN] ) {
        result = YES;
    }else if ( [urlString boolWithRegExp:@"https?://via.me/-[a-zA-Z0-9]+"] ) {
        result = YES;
    }else if ( [urlString boolWithRegExp:@"https?://img.ly/[a-zA-Z0-9]+"] ) {
        result = YES;
    }else if ( [urlString boolWithRegExp:PIXIV_FULL_PATTERN] ) {
        result = YES;
    }else if ( [urlString hasPrefix:@"http://campl.us/"] ) {
        result = YES;
    }
    
    return result;
}

@end
