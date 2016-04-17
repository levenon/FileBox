//
//  ViewController.h
//  FBMovieapp
//
//  Created by Kolyvan on 11.10.12.
//  Copyright (c)2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/FBMovie
//  this file is part of FBMovie
//  FBMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <UIKit/UIKit.h>

@class FBMovieParameter;

@interface FBMovieViewController :UIViewController<UITableViewDataSource, UITableViewDelegate>

+ (id)movieViewControllerWithContentPath:(NSString *)path
                               parameter:(FBMovieParameter *)parameter;

@property (nonatomic, assign, readonly) BOOL playing;

- (void)play;
- (void)pause;

@end
