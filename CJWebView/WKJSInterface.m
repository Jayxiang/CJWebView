//
//  WKJSInterface.m
//  CJWebView
//
//  Created by tet-cjx on 2018/5/28.
//  Copyright © 2018年 hyd-cjx. All rights reserved.
//

#import "WKJSInterface.h"
@interface WKJSInterface()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@end

@implementation WKJSInterface

- (instancetype)initWithDelegate:(id<WKJSInterfaceDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}
//请求照片
- (void)takeUserImage:(id)body {
    UIImagePickerController *image = [[UIImagePickerController alloc] init];
    image.allowsEditing = YES;
    image.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    image.delegate = self;
    [self.delegate.interfaceController presentViewController:image animated:YES completion:nil];
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    NSString *url = [NSString stringWithFormat:@"http://pic.58pic.com/58pic/16/62/63/97m58PICyWM_1024.jpg"];
#if 0
    NSString *patchDocument = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *imageFile = [NSString stringWithFormat:@"%@/Images", patchDocument];
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/", imageFile];
    NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"image.jpg"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.25);
    [imageData writeToFile:imageFile atomically:YES];
    NSData *imageData1 = [NSData dataWithContentsOfFile:imagePath];//imagePath :沙盒图片路径
    NSString *imageSource = [NSString stringWithFormat:@"data:image/jpg;base64,%@",[imageData1 base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]];
    //直接传字典 js不能解析,可以将字典转为data再转为json
    NSString *jsStr1 = [NSString stringWithFormat:@"HQAppUploadResult({\"url\":\"%@\",\"local\":\"%@\"})",url,imageSource];
#else
    //当图片放到doc下在真机下并不能加载,而放到tmp下则可以
    NSString *path_document = NSHomeDirectory();
    NSString *imagePath = [path_document stringByAppendingString:@"/tmp/mychoose.jpg"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.25);
    [imageData writeToFile:imagePath atomically:YES];
    NSString *jsStr1 = [NSString stringWithFormat:@"HQAppUploadResult({\"url\":\"%@\",\"local\":\"%@\"})",url,imagePath];
#endif
    dispatch_after(0.2, dispatch_get_main_queue(), ^{
        [self.delegate.interfaceWebview evaluateJavaScript:jsStr1 completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSLog(@"%@----%@",result, error);
        }];
    });
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)getDicDataByType:(id)body {
    // 将结果返回给js
    NSString *jsStr = [NSString stringWithFormat:@"onAreaChooseResult('%@')",body];
    [self.delegate.interfaceWebview evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}
#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString *selName = [NSString stringWithFormat:@"%@:", message.name];
    SEL sel = NSSelectorFromString(selName);
    if ([self respondsToSelector:sel]) {
        [self performSelector:sel withObject:message.body afterDelay:0];
    }
}
- (NSArray *)allInterface {
    if (!_allInterface) {
        _allInterface = @[@"takeUserImage",@"getDicDataByType"];
    }
    return _allInterface;
}
- (void)dealloc {
    NSLog(@"%s",__func__);
}
@end

@implementation WeakWKURLSchemeHandler

- (instancetype)initWithDelegate:(id<WKURLSchemeHandler>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}
- (void)webView:(WKWebView *)webView startURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask {
    [self.delegate webView:webView startURLSchemeTask:urlSchemeTask];
}
- (void)webView:(WKWebView *)webView stopURLSchemeTask:(id <WKURLSchemeTask>)urlSchemeTask {
    [self.delegate webView:webView startURLSchemeTask:urlSchemeTask];
}
@end
