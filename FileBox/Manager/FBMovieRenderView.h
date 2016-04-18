//
//  FBMovieRenderView
//  FileBox
//
//  Created by Marke Jave on 16/4/15.
//  Copyright © 2016年 Marike Jave. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FBMovieDecoder.h"

@protocol FBMovieRenderView <NSObject>

- (void)epSetupWithDecoder:(FBMovieDecoder *)decoder;

- (void)epRenderWithFrame:(FBMovieFrame *)frame;

- (void)epDecoder:(FBMovieDecoder *)decoder didFailedSetupWithError:(NSError *)error;

@end
