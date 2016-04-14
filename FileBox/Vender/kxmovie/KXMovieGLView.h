//
//  ESGLView.h
//  KXmovie
//
//  Created by Kolyvan on 22.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/KXmovie
//  this file is part of KXMovie
//  KXMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <UIKit/UIKit.h>

@class KXVideoFrame;
@class KXMovieDecoder;

@interface KXMovieGLView : UIView

- (id) initWithFrame:(CGRect)frame
             decoder: (KXMovieDecoder *) decoder;

- (void) render: (KXVideoFrame *) frame;

@end
