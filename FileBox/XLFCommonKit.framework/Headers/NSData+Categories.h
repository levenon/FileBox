//
//  NSData+Categories.h
//  XLFCommonKit
//
//  Created by Marike Jave on 15/9/23.
//  Copyright © 2015年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(Categories)

+ (NSData *) dataWithBase64EncodedString:(NSString *) string;
- (id) initWithBase64EncodedString:(NSString *) string;

- (NSString *) base64EncodingString;
- (NSString *) base64EncodingStringWithLineLength:(unsigned int) lineLength;
- (NSString *) urlEncodedString;

@end
