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

@property(nonatomic, strong, readonly) FBMovieDecoder  *decoder;

- (id)initWithFrame:(CGRect)frame decoder:(FBMovieDecoder *)decoder;

- (void)render:(FBVideoFrame *)frame;

@end
