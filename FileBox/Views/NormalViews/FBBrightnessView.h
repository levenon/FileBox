//
//  FBBrightnessView.h
//

#import <UIKit/UIKit.h>

@interface FBBrightnessView : UIView

+ (FBBrightnessView *)shareInstance;

- (void)efRegisterObserver;

- (void)efDeregisterObserver;

@end