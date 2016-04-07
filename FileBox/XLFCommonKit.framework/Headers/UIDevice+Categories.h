//
//  UIDevice+Categories.h
//  XLFCommonKit
//
//  Created by Marike Jave on 14-10-27.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  根据设备类型 返回相应的值
 *  全拼  select by device model
 */
#define sbdm(deviceModelType,vIphone4,vIphone5,vIphone6,vIphone6p)    \
        deviceModelType & UIDeviceModelPhone4All ? vIphone4 : ( deviceModelType & UIDeviceModelPhone5All ? vIphone5 : ( deviceModelType & UIDeviceModelPhone6 ? vIphone6 : vIphone6p ) )

/**
 *  是否iPhone6s plus
 */
#define IS_iPhone6sp                                         (([UIDevice deviceModelType]&UIDeviceModelPhone6sPlus)&&YES)

/**
 *  是否iPhone6s
 */
#define IS_iPhone6s                                          (([UIDevice deviceModelType]&UIDeviceModelPhone6s)&&YES)

/**
 *  是否iPhone6 plus
 */
#define IS_iPhone6p                                         (([UIDevice deviceModelType]&UIDeviceModelPhone6Plus)&&YES)

/**
 *  是否iPhone6
 */
#define IS_iPhone6                                          (([UIDevice deviceModelType]&UIDeviceModelPhone6)&&YES)

/**
 *  是否iPhone5
 */
//#define IS_iPhone5                                          ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640,    1136),[[UIScreen mainScreen] currentMode].size) : NO)
#define IS_iPhone5                                          (([UIDevice deviceModelType]&UIDeviceModelPhone5All)&&YES)
/**
 *  是否iPhone4
 */
//#define IS_iPhone4                                          [[[UIDevice deviceModel] lowercaseString]  hasPrefix:@"iphone4"]
#define IS_iPhone4                                          (([UIDevice deviceModelType]&UIDeviceModelPhone4All)&&YES)

/**
 *  是否iPod
 */
#define IS_IPOD                                             (([UIDevice deviceModelType]&UIDeviceModelPodAll)&&YES)

typedef NS_ENUM(UInt64, UIDeviceModel){
    
    UIDeviceModelUnknown        = 0,

    UIDeviceModelSimulator      = 1<<0,
    
    UIDeviceModelPhone          = 1<<0,  // 已淘汰
    UIDeviceModelPhone1G        = 1<<0,  // 已淘汰
    UIDeviceModelPhone3G        = 1<<0,  // 已淘汰
    UIDeviceModelPhone3GS       = 1<<0,  // 已淘汰

    UIDeviceModelPhone4         = 1<<1,
    UIDeviceModelPhone4S        = 1<<2,
    UIDeviceModelPhone4All      = UIDeviceModelPhone4 | UIDeviceModelPhone4S,
    
    UIDeviceModelPhone5         = 1<<3,
    UIDeviceModelPhone5C        = 1<<4,
    UIDeviceModelPhone5S        = 1<<5,
    UIDeviceModelPhone5All      = UIDeviceModelPhone5 | UIDeviceModelPhone5C | UIDeviceModelPhone5S,
    
    UIDeviceModelPhone6         = 1<<6,
    UIDeviceModelPhone6Plus     = 1<<7,
    UIDeviceModelPhone6All      = UIDeviceModelPhone6 | UIDeviceModelPhone6Plus,
    
    UIDeviceModelPhone6s        = 1<<8,
    UIDeviceModelPhone6sPlus    = 1<<9,
    UIDeviceModelPhone6sAll     = UIDeviceModelPhone6s | UIDeviceModelPhone6sPlus,
    
    UIDeviceModelPhoneAll       = 0xfff, // 0000 0000 0000 0000 1111 1111 1111
    
    UIDeviceModelPod            = 1<<13, // 已淘汰
    UIDeviceModelPod1           = 1<<13, // 已淘汰
    UIDeviceModelPod2           = 1<<13, // 已淘汰
    UIDeviceModelPod3           = 1<<13, // 已淘汰
    UIDeviceModelPod4           = 1<<13, // 已淘汰
    UIDeviceModelPod5           = 1<<13, // 已淘汰
    
    UIDeviceModelPodAll         = 0x1000, // 0000 0000 0000 0001 0000 0000 0000
    
    UIDeviceModelPad            = 1<<14, 
    UIDeviceModelPad3G          = 1<<15,
    UIDeviceModelPadWifi        = 1<<16,
    UIDeviceModelPad2           = 1<<17,
    UIDeviceModelPadMini1G      = 1<<18,
    UIDeviceModelPad3           = 1<<19,
    UIDeviceModelPad4           = 1<<20,
    UIDeviceModelPadAir         = 1<<21,
    UIDeviceModelPadAirMiniRetina=1<<22,
    UIDeviceModelPadAir2        = 1<<23,
    UIDeviceModelPadPro         = 1<<24,
    
    UIDeviceModelPadAll         = 0x3ffe0000, // 0000 0011 1111 1111 1110 0000 0000 0000
    
    UIDeviceModelWatch          = 1<<25,
    UIDeviceModelWatch2         = 1<<26,
    
    UIDeviceModelWatchAll       = 0xfc000000, // 1111 1100 0000 0000 0000 0000 0000 0000
};

@interface UIDevice(Categories)

/**
 *  获取设备标识号
 *  @return 设备标识号
 */
+(NSString *)deviceIdentifier;

/**
 *  获取设备用户名
 *  @return 设备用户名
 */
+(NSString *)deviceName;

/**
 *  获取设备类别
 *
 *  @return 设备类别
 */
+(NSString *)deviceModel;

/**
 *  获取设备类型
 *
 *  @return 设备类型
 */
+(UIDeviceModel)deviceModelType;

/**
 *  获取设备类别版本
 *
 *  @return 设备类别版本
 */
+(NSString *)deviceLocalizedModel;

/**
 *  获取设备操作系统名称
 *
 *  @return 设备操作系统名称
 */
+(NSString *)deviceSystemName;

/**
 *  获取设备操作系统版本
 *
 *  @return 获取设备操作系统版本
 */
+(NSString *)deviceSystemVersion;

@end
