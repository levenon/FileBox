//
//  XLFLog.h
//  XLFCommonKit
//  Add a Preprocessor Macro in Build : DEBUG
//
//  Created by Marike Jave on 14-10-11.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//

#ifndef XCODE_COLORS
#define XCODE_COLORS
#endif

#ifndef _NIFLOG_DEFINE_
#define _NIFLOG_DEFINE_

#define XCODE_COLORS_ESCAPE @"\033["
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color
#define DDLogRedColor       @"255,0,0;"
#define DDLogGrayColor      @"125,125,125;"
#define DDLogBlackColor     @"0,0,0;"
#define DDLogWhitColor      @"255,255,255;"
#define DDLogYellowColor    @"255,255,0;"
#define DDLogBlueColor      @"131,201,153;"
#define DDLogGreenColor     @"0,130,18;"
#define DDLogBrownColor     @"153,102,51;"

#ifdef XCODE_COLORS

#define _NIFLog(info, fmt, bgColor, fgColor, ...)  NSLog((XCODE_COLORS_ESCAPE  @"bg" bgColor XCODE_COLORS_ESCAPE @"fg" fgColor info XCODE_COLORS_RESET @"\n%s %s  [Line:%d] \n" XCODE_COLORS_ESCAPE @"fg" fgColor fmt XCODE_COLORS_RESET @"\n\n"),__FILE__,__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__)

#else

#define _NIFLog(info,fmt,bgColor,fgColor, ...) NSLog(( info @"\n%s %s [Line:%d] \n" fmt @"\n\n"),__FILE__,__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__)

#endif

#ifdef DEBUG

#define NIF_LOG(log)           _NIFLog(@"=========== INFO ===========", log,DDLogWhitColor, DDLogGrayColor,nil)
#define NIF_INFO(fmt, ...)     _NIFLog(@"=========== INFO ===========", fmt,DDLogWhitColor, DDLogGrayColor, ##__VA_ARGS__)
#define NIF_WARN(fmt, ...)     _NIFLog(@"!!========= WARN =========!!", fmt, DDLogWhitColor, DDLogBlueColor, ##__VA_ARGS__)
#define NIF_ERROR(fmt, ...)    _NIFLog(@"!!!======== ERROR =========!!!", fmt, DDLogWhitColor, DDLogRedColor, ##__VA_ARGS__)
#define NIF_DEBUG(fmt, ...)    _NIFLog(@"!========== DEBUG ==========!", fmt, DDLogWhitColor, DDLogBrownColor, ##__VA_ARGS__)
#define NIF_SUCCESS(fmt, ...)  _NIFLog(@"!========== SUCCESS ==========!", fmt, DDLogWhitColor, DDLogGreenColor, ##__VA_ARGS__)

#define NIF_CONDITION(condition, operator)  if(condition){ operator; }

#else
#define NIF_LOG(log)            ((void)0)
#define NIF_INFO(fmt, ...)      ((void)0)
#define NIF_WARN(fmt, ...)      ((void)0)
#define NIF_ERROR(fmt, ...)     ((void)0)
#define NIF_DEBUG(fmt, ...)     ((void)0)
#define NIF_SUCCESS(fmt, ...)   ((void)0)

#define NIF_CONDITION(condition, operator)  ((void)0)

#endif

#endif
