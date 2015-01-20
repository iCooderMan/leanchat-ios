//
//  Utils.m
//  AVOSChatDemo
//
//  Created by lzw on 14-10-24.
//  Copyright (c) 2014年 AVOS. All rights reserved.
//

#import "CDUtils.h"
#import "CDCommonDefine.h"
#import <CommonCrypto/CommonDigest.h>

@implementation CDUtils

+(void)alert:(NSString*)msg{
    UIAlertView *alertView=[[UIAlertView alloc]
                             initWithTitle:nil message:msg delegate:nil
                             cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

+(void)alertError:(NSError*)error{
    [CDUtils alert:[error localizedDescription]];
}

+(void)filterError:(NSError*)error callback:(CDBlock)callback{
    if(error && error.code!=kAVErrorCacheMiss){
        [CDUtils alertError:error];
    }else{
        if(callback){
            callback();
        }
    }
}

+(void)logError:(NSError*)error callback:(CDBlock)callback{
    if(error){
        NSLog(@"%@",[error localizedDescription]);
    }else{
        callback();
    }
}

+(NSMutableArray*)setToArray:(NSMutableSet*)set{
    return [[NSMutableArray alloc] initWithArray:[set allObjects]];
}

+(NSString*)md5OfString:(NSString*)s{
    const char *ptr = [s UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(ptr, strlen(ptr), md5Buffer);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}


+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(UIImage *)roundImage:(UIImage *) image toSize:(CGSize)size radius: (float) radius;
{
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    
    CGRect rect=CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    
    [[UIBezierPath bezierPathWithRoundedRect:rect
                                cornerRadius:radius] addClip];
    // Draw your image
    [image drawInRect:rect];
    
    // Get the image, here setting the UIImageView image
    UIImage* rounded = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    return rounded;
}

+(void)pickImageFromPhotoLibraryAtController:(UIViewController*)controller{
    UIImagePickerControllerSourceType srcType=UIImagePickerControllerSourceTypePhotoLibrary;
    NSArray* mediaTypes=[UIImagePickerController availableMediaTypesForSourceType:srcType];
    if([UIImagePickerController isSourceTypeAvailable:srcType] && [mediaTypes count]>0){
        UIImagePickerController* ctrler=[[UIImagePickerController alloc] init];
        ctrler.mediaTypes=mediaTypes;
        ctrler.delegate=(id)controller;
        ctrler.allowsEditing=YES;
        ctrler.sourceType=srcType;
        [controller presentViewController:ctrler animated:YES completion:nil];
    }else{
        [CDUtils alert:@"no image picker available"];
    }
}

+(NSArray*)reverseArray:(NSArray*)originArray{
    NSMutableArray* array=[NSMutableArray arrayWithCapacity:[originArray count]];
    NSEnumerator* enumerator=[originArray reverseObjectEnumerator];
    for(id element in enumerator){
        [array addObject:element];
    }
    return array;
}

+(void)runInMainQueue:(void (^)())queue{
    dispatch_async(dispatch_get_main_queue(), queue);
}

+(void)runInGlobalQueue:(void (^)())queue{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), queue);
}

+(void)runAfterSecs:(float)secs block:(void (^)())block{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, secs*NSEC_PER_SEC), dispatch_get_main_queue(), block);
}

+(void)postNotification:(NSString*)name{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

+(void)notifyGroupUpdate{
    [CDUtils postNotification:NOTIFICATION_GROUP_UPDATED];
}

#pragma mark - view util

+(UIActivityIndicatorView*)showIndicatorAtView:(UIView*)hookView{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = CGPointMake(hookView.frame.size.width * 0.5, hookView.frame.size.height * 0.5-50);
    [hookView addSubview:indicator];
    [hookView bringSubviewToFront:indicator];
    indicator.hidden=NO;
    [indicator startAnimating];
    return indicator;
}

+(void)showNetworkIndicator{
    UIApplication* app=[UIApplication sharedApplication];
    app.networkActivityIndicatorVisible=YES;
}

+(void)hideNetworkIndicator{
    UIApplication* app=[UIApplication sharedApplication];
    app.networkActivityIndicatorVisible=NO;
}

+(void)hideNetworkIndicatorAndAlertError:(NSError*)error{
    [self hideNetworkIndicator];
    [CDUtils alertError:error];
}

+(void)setCellMarginsZero:(UITableViewCell*)cell{
    if([cell respondsToSelector:@selector(layoutMargins)]){
        cell.layoutMargins=UIEdgeInsetsZero;
    }
}

+(void)setTableViewMarginsZero:(UITableView*)view{
    if(SYSTEM_VERSION<8){
        if ([view respondsToSelector:@selector(setSeparatorInset:)]) {
            [view setSeparatorInset:UIEdgeInsetsZero];
        }
    }else{
        if ([view respondsToSelector:@selector(layoutMargins)]) {
            view.layoutMargins = UIEdgeInsetsZero;
        }
    }
}

+(void)stopRefreshControl:(UIRefreshControl*)refreshControl{
    if(refreshControl!=nil && [[refreshControl class] isSubclassOfClass:[UIRefreshControl class]]){
        [refreshControl endRefreshing];
    }
}

#pragma mark - AVUtil

+(void)setPolicyOfAVQuery:(AVQuery*)query isNetwokOnly:(BOOL)onlyNetwork{
    [query setCachePolicy:onlyNetwork ? kAVCachePolicyNetworkOnly : kAVCachePolicyNetworkElseCache];
}

+(NSString*)uuid{
    NSString *chars=@"abcdefghijklmnopgrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    assert(chars.length==62);
    int len=chars.length;
    NSMutableString* result=[[NSMutableString alloc] init];
    for(int i=0;i<24;i++){
        int p=arc4random_uniform(len);
        NSRange range=NSMakeRange(p, 1);
        [result appendString:[chars substringWithRange:range]];
    }
    return result;
}

+ (int)getDurationOfAudioPath:(NSString *)path {
    int duration;
    NSError* error;
    NSDictionary* fileAttrs=[[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if(error==nil){
        unsigned long long size=[fileAttrs fileSize];
        int oneSecSize=3000;
        duration=(int)(size*1.0f/oneSecSize+1);
    }else{
        [CDUtils alertError:error];
    }
    return duration;
}

+ (void)downloadWithUrl:(NSString *)url toPath:(NSString *)path {
    NSData* data=[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:url]];
    NSError* error;
    [data writeToFile:path options:NSDataWritingAtomic error:&error];
    if(error==nil){
        NSLog(@"writeSucceed");
    }else{
        NSLog(@"error when download file");
    }
}

+ (BOOL)connected
{
    CDReachability *reachability = [CDReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

@end
