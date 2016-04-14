//
//  ViewController.h
//  KXmovieapp
//
//  Created by Kolyvan on 11.10.12.
//  Copyright (c)2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/KXmovie
//  this file is part of KXMovie
//  KXMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <UIKit/UIKit.h>

@class KXMovieDecoder;

extern NSString * const KXMovieParameterMinBufferedDuration;    // Float
extern NSString * const KXMovieParameterMaxBufferedDuration;    // Float
extern NSString * const KXMovieParameterDisableDeinterlacing;   // BOOL

@interface KXMovieViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

+ (id)movieViewControllerWithContentPath:(NSString *)path
                              parameters:(NSDictionary *)parameters;

@property (nonatomic, assign, readonly)BOOL playing;

- (void)play;
- (void)pause;

@end
