//
//  FBAudioPlayer
//  FBMovie
//
//  Created by Kolyvan on 23.10.12.
//  Copyright (c)2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/FBMovie
//  this file is part of FBMovie
//  FBMovie is licenced under the LGPL v3, see lgpl-3.0.txt


#import <CoreFoundation/CoreFoundation.h>

typedef void (^FBAudioPlayerOutputBlock)(float *data, UInt32 numFrames, UInt32 numChannels);


@interface FBAudioPlayer :NSObject

@property (nonatomic, readonly, assign)  UInt32             numOutputChannels;
@property (nonatomic, readonly, assign)  Float64            samplingRate;
@property (nonatomic, readonly, assign)  UInt32             numBytesPerSample;
@property (nonatomic, readonly, assign)  Float32            outputVolume;
@property (nonatomic, readonly, assign)  BOOL               playing;
@property (nonatomic, readonly, strong)  NSString           *audioRoute;

@property (nonatomic, copy  )            FBAudioPlayerOutputBlock outputBlock;

- (BOOL)activateAudioSession;
- (void)deactivateAudioSession;
- (BOOL)play;
- (void)pause;


@end
