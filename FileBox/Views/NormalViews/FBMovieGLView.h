//
//  ESGLView.h
//  FBMovie
//
//  Created by Kolyvan on 22.10.12.
//  Copyright (c)2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/FBMovie
//  this file is part of FBMovie
//  FBMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <UIKit/UIKit.h>

#import "FBMovieRenderView.h"

@class FBVideoFrame;
@class FBMovieDecoder;

@interface FBMovieGLView :UIView<FBMovieRenderView>

@property(nonatomic, strong, readonly) FBMovieDecoder  *decoder;

- (id)initWithFrame:(CGRect)frame
             decoder:(FBMovieDecoder *)decoder;

- (void)render:(FBVideoFrame *)frame;

@end
