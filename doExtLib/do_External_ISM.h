//
//  do_External_IMethod.h
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol do_External_ISM <NSObject>

//实现同步或异步方法，parms中包含了所需用的属性
@required
- (void)bulkSMS:(NSArray *)parms;
- (void)installApp:(NSArray *)parms;
- (void)openApp:(NSArray *)parms;
- (void)openContact:(NSArray *)parms;
- (void)openDial:(NSArray *)parms;
- (void)openFile:(NSArray *)parms;
- (void)openMail:(NSArray *)parms;
- (void)openSMS:(NSArray *)parms;
- (void)openURL:(NSArray *)parms;
- (void)openSystemSetting:(NSArray *)parms;
- (void)existApp:(NSArray *)parms;

@end