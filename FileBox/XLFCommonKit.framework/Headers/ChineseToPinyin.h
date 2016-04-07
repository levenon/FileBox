

#import <UIKit/UIKit.h>

@interface ChineseToPinyin : NSObject {
    
}

+ (NSString *)pinyinFromChiniseString:(NSString *)string;
+ (char)sortSectionTitle:(NSString *)string;

@end

@interface NSString (ChineseToPinyin)

- (NSString *)pinyin;

@end