//
//  FBVideoPlayerControlView
//

#import <UIKit/UIKit.h>

@class FBVideoPlayer;

@interface FBVideoPlayerControlView : UIView

@property(nonatomic, assign, getter = evIsControlDisplay)   BOOL          evControlDisplay;

@property(nonatomic, assign, getter = evIsLockedScreen)     BOOL          evLockedScreen;

@property(nonatomic, assign, readonly) FBVideoPlayer  *evVideoPlayer;

- (instancetype)initWithVideoPlayer:(FBVideoPlayer *)videoPlayer;

@end
