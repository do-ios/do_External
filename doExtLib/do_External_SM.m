//
//  do_External_SM.m
//  DoExt_API
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_External_SM.h"

#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doInvokeResult.h"
#import <UIKit/UIKit.h>
#import "doIOHelper.h"
#import "doIPage.h"
#import "doJsonHelper.h"
#import <MessageUI/MessageUI.h>
#import "doServiceContainer.h"
#import "doILogEngine.h"
#import <AddressBookUI/AddressBookUI.h>
#if __IPHONE_9_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    #import <Contacts/Contacts.h>
    #import <ContactsUI/ContactsUI.h>
#endif



@interface do_External_SM()<MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate,UIDocumentInteractionControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong) MFMailComposeViewController *mailVc;
@property (nonatomic,strong) UIViewController *currentVC;
@property (nonatomic,strong) doInvokeResult *myInvokeResult;
@property (nonatomic,strong) UIDocumentInteractionController *docVC;
@property (nonatomic,strong) MFMessageComposeViewController *msgVc;
@end
@implementation do_External_SM
#pragma mark - 方法
#pragma mark - 同步异步方法的实现
//同步
- (void)bulkSMS:(NSArray *)parms
{
    NSDictionary * _dictParas =[parms objectAtIndex:0];
    id<doIScriptEngine> ii =[parms objectAtIndex:1];
    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    NSArray *numbers = [doJsonHelper GetOneArray:_dictParas :@"number"];
    NSString *_message = [doJsonHelper GetOneText:_dictParas :@"body" :@""];
    if (!numbers || numbers.count == 0) {
        [[doServiceContainer Instance].LogEngine WriteDebug:@"number 不能为空"];
        return;
    }
    MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init];
    self.msgVc = controller;
    controller.messageComposeDelegate = self;
    controller.recipients = numbers;
    controller.body = _message;
    UIViewController *viewcontroller = (UIViewController *)ii.CurrentPage.PageView;
    NSString *path = [NSString stringWithFormat:@"sms://%@",@"10086"];
    BOOL canOpen = [self canOpenURL:path];
    [_invokeResult SetResultBoolean:canOpen];
    [viewcontroller presentViewController:controller animated:YES completion:^{
        
    }];
    //_invokeResult设置返回值
    
}
-(void)openApp:(NSArray *)parms
{
    NSDictionary * _dictParas =[parms objectAtIndex:0];
    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    NSString* _wakeupid = [doJsonHelper GetOneText:_dictParas :@"wakeupid" :@""];
    NSDictionary *_data = [doJsonHelper GetOneNode:_dictParas :@"data"];
    
    NSArray *_arr = [_data allKeys];
    NSMutableString *_openparms= [[NSMutableString alloc]init];
    for(NSString *_entry  in _arr)
    {
        NSString *key = _entry;
        NSString *value = [_data objectForKey:_entry];
        [_openparms appendString:[NSString stringWithFormat:@"%@&%@",key,value]];
    }
    [_invokeResult SetResultText:self.UniqueKey];
    [self openExternal:[NSString stringWithFormat:@"%@://%@",_wakeupid,_openparms]:_invokeResult];
}

//调用系统默认浏览器打开指定url
- (void) openURL:(NSArray*) parms
{
    NSDictionary * _dictParas =[parms objectAtIndex:0];
    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    NSString* callUrl = [doJsonHelper GetOneText:_dictParas :@"url" :@""];
//    NSString *openStr;
    //打开系统浏览器
//    if ([callUrl hasPrefix:@"http://"]||[callUrl hasPrefix:@"https://"]) {
//        openStr = callUrl;
//    } else if([callUrl hasPrefix:@"itms-services"])
//    {
//        openStr = callUrl;
//    }
//    else{
//        openStr = [NSString stringWithFormat:@"http://%@",callUrl];
//    }
    [self openExternal:callUrl :_invokeResult];
}

//拨打指定电话号码
- (void) openDial:(NSArray*) parms
{
    NSDictionary * _dictParas =[parms objectAtIndex:0];
    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    NSString* _url = [doJsonHelper GetOneText:_dictParas :@"number" :@""];
    [self openExternal:[NSString stringWithFormat:@"tel://%@",_url] :_invokeResult];
}

//打开系统通讯录
- (void) openContact:(NSArray*) parms
{
    //iOS 不支持
    id<doIScriptEngine> ii =[parms objectAtIndex:1];
    UIViewController *viewcontroller = (UIViewController *)ii.CurrentPage.PageView;

#if __IPHONE_9_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    CNContactPickerViewController *contactVc = [[CNContactPickerViewController alloc] init];
    [viewcontroller presentViewController:contactVc animated:YES completion:nil];
#else
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    [viewcontroller presentViewController:peoplePicker animated:YES completion:nil];
#endif
}
- (void)installApp:(NSArray *)parms
{
    //iOS不支持
}

#pragma  mark - iOS9 不支持
- (void)existApp:(NSArray *)parms
{
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //参数字典_dictParas
//    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    //自己的代码实现
    
    doInvokeResult *_invokeResult = [parms objectAtIndex:2];
    //_invokeResult设置返回值
    NSString *key = [doJsonHelper GetOneText:_dictParas :@"key" :@""];
    BOOL isExist;
    @try
    {
        isExist = [[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:key]];
    } @catch (NSException *exception)
    {
        isExist = NO;
    }
    
    [_invokeResult SetResultBoolean:isExist];
}
- (void)openFile:(NSArray *)parms
{
    //参数字典_dictParas
    NSDictionary *_dictParas = [parms objectAtIndex:0];
    //脚本引擎
    id<doIScriptEngine> _scritEngine = [parms objectAtIndex:1];
    
    _myInvokeResult = [parms objectAtIndex:2];
    NSString *filePath = [doJsonHelper GetOneText:_dictParas :@"path" :@""];
    //获得沙盒路径
    NSString *fileUrl = [doIOHelper GetLocalFileFullPath:_scritEngine.CurrentPage.CurrentApp :filePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExit = [fileManager fileExistsAtPath:fileUrl isDirectory:nil];
    [_myInvokeResult SetResultBoolean:isExit];
    if (!isExit) {
        return;
    }
    NSURL *url = [NSURL fileURLWithPath:fileUrl];
    UIDocumentInteractionController *docVC = [UIDocumentInteractionController interactionControllerWithURL:url];
    docVC.delegate = self;
    self.docVC = docVC;
    // 获得当前控制器，跳转
    id<doIPage>pageModel = _scritEngine.CurrentPage;
    UIViewController *currentVC = (UIViewController *)pageModel.PageView;
    self.currentVC = currentVC;
    CGRect navRect = currentVC.navigationController.navigationBar.frame;
    navRect.size = CGSizeMake(1500.0f, 100.0f);
    [docVC presentOpenInMenuFromRect:navRect inView:currentVC.view animated:YES];
    
}
- (void)rightBarBtnClick:(UINavigationItem *)item
{
    [self.currentVC dismissViewControllerAnimated:YES completion:nil];
}
- (void) openMail:(NSArray*) parms
{
    NSDictionary * _dictParas =[parms objectAtIndex:0];
    id<doIScriptEngine> _scriptEngine =[parms objectAtIndex:1];
    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    MFMailComposeViewController * mailVC = [[MFMailComposeViewController alloc]init];
    mailVC.mailComposeDelegate = self;
    self.mailVc = mailVC;
    NSString *subject =[doJsonHelper GetOneText:_dictParas :@"subject" :@""];
    NSString *body = [doJsonHelper GetOneText:_dictParas :@"body" :@""];
    NSString *cc =[doJsonHelper GetOneText:_dictParas :@"to" :@""];
    [mailVC setSubject:subject];
    [mailVC setMessageBody:body isHTML:NO];
    [mailVC setToRecipients:[NSArray arrayWithObjects:cc, nil]];
    UIViewController *viewcontroller = (UIViewController *)_scriptEngine.CurrentPage.PageView;
    NSString *path = [NSString stringWithFormat:@"mailto://%@",cc];
    BOOL canOpen = [self canOpenURL:path];
    [_invokeResult SetResultBoolean:canOpen];
    [viewcontroller presentViewController:mailVC animated:YES completion:^{
        
    }];
}

- (void) openSMS:(NSArray*) parms
{
    NSDictionary * _dictParas =[parms objectAtIndex:0];
    id<doIScriptEngine> ii =[parms objectAtIndex:1];
    doInvokeResult * _invokeResult = [parms objectAtIndex:2];
    NSString *_number =[doJsonHelper GetOneText:_dictParas :@"number" :@""];
    NSString *_message = [doJsonHelper GetOneText:_dictParas :@"body" :@""];
    MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init];
    self.msgVc = controller;
    controller.messageComposeDelegate = self;
    controller.recipients = [NSArray arrayWithObject:_number];
    controller.body = _message;
    UIViewController *viewcontroller = (UIViewController *)ii.CurrentPage.PageView;
    NSString *path = [NSString stringWithFormat:@"sms://%@",_number];
    BOOL canOpen = [self canOpenURL:path];
    [_invokeResult SetResultBoolean:canOpen];
    [viewcontroller presentViewController:controller animated:YES completion:^{
        
    }];
}

- (void)openSystemSetting:(NSArray *)parms
{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }else {
        NSURL*url=[NSURL URLWithString:@"prefs:root=LOCATION_SERVICES"];
        [[UIApplication sharedApplication] openURL:url];
    }
    
}


- (BOOL) canOpenURL:(NSString *)urlStr
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]])
    {
        return YES;
    }
    else
    {
        return NO;
        
    }
}
-(void)openExternal:(NSString *)_url : (doInvokeResult *)_invokeResult
{
    
    BOOL isSuccess = [[UIApplication sharedApplication]openURL:[NSURL URLWithString:_url]];
    [_invokeResult SetResultBoolean:isSuccess];
}


-(UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
    return self.currentVC;
}
- (UIView*)documentInteractionControllerViewForPreview:(UIDocumentInteractionController*)controller
{
    return self.currentVC.view;
}
- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController*)controller
{
    
    return self.currentVC.view.frame;
}

#pragma -mark -
#pragma -mark MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    //发送，或者取消，都回到应用
    [controller dismissViewControllerAnimated:YES completion:nil];
    //没有回调  不做处理  必须实现 不然有警告
}
#pragma -mark -
#pragma -mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
