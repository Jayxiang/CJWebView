//
//  WKVSJSViewController.m
//  CJWebView
//
//  Created by tet-cjx on 2018/1/16.
//  Copyright © 2018年 hyd-cjx. All rights reserved.
//

#import "WKVSJSViewController.h"
#import <WebKit/WebKit.h>
#import "CJHandlerVC.h"
#import "WKJSInterface.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define NavHeight ([[UIApplication sharedApplication] statusBarFrame].size.height + 44)
@interface WKVSJSViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler,UINavigationControllerDelegate,UIImagePickerControllerDelegate,WKURLSchemeHandler,WKJSInterfaceDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKUserContentController *userContentController;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nullable, copy) NSArray<NSHTTPCookie *> *cookies;
@property (nonatomic, strong) WKJSInterface *interface;
@end

@implementation WKVSJSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    [self initWebView];
    self.title = self.webView.title;
}
- (WKJSInterface *)interface {
    if (!_interface) {
        //    这样写为了避免内存泄漏,利用WKScriptMessageHandler写到另一个类.而且方便管理
        _interface = [[WKJSInterface alloc] initWithDelegate:self];
    }
    return _interface;
}
- (WKWebView *)interfaceWebview {
    if (self.webView) {
        return self.webView;
    }
    return nil;
}
- (UIViewController *)interfaceController {
    return self;
}
- (void)initWebView {
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    //偏好设置
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    
//    内容交互控制器
    WKUserContentController *user = [WKUserContentController new];
    [self.interface.allInterface enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [user addScriptMessageHandler:self.interface name:obj];
    }];
    self.userContentController = user;

    //    给h5设置cookie
    WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource: @"document.cookie='hq_http_usertoken=GojvvmpfnXXAQ6/HxBfMIQFJhWXOBYQfzhWCHpRABtI=;domain=hq-app-dev.zhongan.io;path=/'; "injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [user addUserScript:cookieScript];
    
//    iOS11后设置cookie
    if (@available(iOS 11.0, *)) {
//        这个特性允许你提供自定义的资源，这也可以实现离线缓存。例如你把所有的图片都放到app里面，然后网页加载图片时按照特定的scheme（比如：wk-app://name）来加载，然后在客户端代码中使用特定的SchemeHandler来解析即可。此处也要注意内存泄漏
        
        [configuration setURLSchemeHandler:[[WeakWKURLSchemeHandler alloc] initWithDelegate:self]  forURLScheme:@"wk-app"];
//
        NSMutableDictionary *fromappDict = [NSMutableDictionary dictionary];
        [fromappDict setObject:@"hq_http_usertoken" forKey:NSHTTPCookieName];
        [fromappDict setObject:@"GojvvmpfnXXAQ6/HxBfMIQFJhWXOBYQfzhWCHpRABtI=" forKey:NSHTTPCookieValue];
        [fromappDict setObject:@"hq-app-dev.zhongan.io" forKey:NSHTTPCookieDomain];
        [fromappDict setObject:@"https://hq-app-dev.zhongan.io" forKey:NSHTTPCookieOriginURL];
        [fromappDict setObject:@"/" forKey:NSHTTPCookiePath];
        [fromappDict setObject:@"0" forKey:NSHTTPCookieVersion];
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:fromappDict];
        [configuration.websiteDataStore.httpCookieStore setCookie:cookie completionHandler:^{

        }];
        
    } else {
        // Fallback on earlier versions
    
    }
    
    WKPreferences *preferences = [WKPreferences new];
    //    在iOS上默认为NO，表示不能自动通过窗口打开
    preferences.javaScriptCanOpenWindowsAutomatically = NO;
    //    页面显示最小字体
    preferences.minimumFontSize = 10;
    
    configuration.preferences = preferences;
    configuration.userContentController = self.userContentController;
//    设置是否使用内联播放器播放视频
    configuration.allowsInlineMediaPlayback = YES;
//    设置视频是否自动播放
    if (@available(iOS 10.0, *)) {
        configuration.mediaTypesRequiringUserActionForPlayback = YES;
    } else {
        // Fallback on earlier versions
    }
    
    configuration.processPool = [[WKProcessPool alloc] init];
    
    WKWebView *web = [[WKWebView alloc] initWithFrame:CGRectMake(0, NavHeight, kScreenWidth, kScreenHeight - NavHeight) configuration:configuration];
#if 1
    NSURL *url = [[NSBundle mainBundle] URLForResource:_name withExtension:@"html"];
#else
    NSURL *url = [NSURL URLWithString:@"https://hq-app-dev.zhongan.io/web/busscard"];
#endif
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //给请求头增加cookie
//    [request setValue:@"hq_http_usertoken=GojvvmpfnXXAQ6/HxBfMIQFJhWXOBYQfzhWCHpRABtI=;domain=hq-app-dev.zhongan.io" forHTTPHeaderField:@"Cookie"];
    [web loadRequest:request];
//    [web loadFileURL:url allowingReadAccessToURL:url];
    web.UIDelegate = self;
    web.navigationDelegate = self;
//    标识是否支持左、右swipe手势是否可以前进、后退默认NO
//    web.allowsBackForwardNavigationGestures = YES;
    //开启手势需要禁止系统手势
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    //自定义UA
    web.customUserAgent = @"CJWebView/1.0.0";
    self.webView = web;
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, NavHeight, kScreenWidth,2)];
    self.progressView.backgroundColor = [UIColor blueColor];
    //设置进度条的高度，下面这句代码表示进度条的宽度变为原来的1倍，高度变为原来的1.5倍.
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    UIBarButtonItem *goNext = [[UIBarButtonItem alloc] initWithTitle:@"前进" style:UIBarButtonItemStyleDone target:self action:@selector(goFarward)];
    UIBarButtonItem *goBack = [[UIBarButtonItem alloc] initWithTitle:@"后退" style:UIBarButtonItemStyleDone target:self action:@selector(goBack)];
    self.navigationItem.rightBarButtonItems = @[goBack,goNext];
}

- (void)goBack{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (void)goFarward {
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}
#pragma mark - 清理缓存
- (void)clearWebViewCache {
    // 这里的 iOS9Later 包含iOS 9
    if (@available(iOS 9.0, *)) {
        //尽量在主线程操作
        dispatch_async(dispatch_get_main_queue(), ^{
            //所有缓存
            //        NSSet *types = [WKWebsiteDataStore allWebsiteDataTypes];
            NSSet *type = [NSSet setWithArray:@[WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache]];
            NSDate *date = [NSDate date];
            [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:type modifiedSince:date completionHandler:^{}];
        });
    } else {
        NSString *libPath = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject;
        NSString *cookiePath = [libPath stringByAppendingString:@"/Cookies"];
        [[NSFileManager defaultManager] removeItemAtPath:cookiePath error:nil];
    }
}

#pragma mark - WKScriptMessageHandler
//可以获得传递过来的参数
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"%@", message);
    if ([message.name isEqualToString:@"getDicDataByType"]) {
        [self getDicDataByType:message.body];
    } else if ([message.name isEqualToString:@"takeUserImage"]) {
        [self takeUserImage];
    }
}
//请求照片
- (void)takeUserImage {
    UIImagePickerController *image = [[UIImagePickerController alloc] init];
    image.allowsEditing = YES;
    image.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    image.delegate = self;
    [self presentViewController:image animated:YES completion:nil];
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
        [self.webView evaluateJavaScript:jsStr1 completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSLog(@"%@----%@",result, error);
        }];
    });
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}
//请求字典数据
- (void)getDicDataByType:(NSString *)rtype{
    // 将结果返回给js
    NSString *jsStr = [NSString stringWithFormat:@"onAreaChooseResult('%@')",@"中国"];
    [self.webView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        NSLog(@"%@----%@",result, error);
    }];
}

#pragma mark - WKNavigationDelegate
// 决定导航的动作，通常用于处理跨域的链接能否导航。WebKit对跨域进行了安全检查限制，不允许跨域，因此我们要对不能跨域的链接单独处理。但是，对于Safari是允许跨域的，不用这么处理。
// 这个是决定是否Request
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //如果是跳转一个新页面
    //这样HTML里面的链接可以跳转
    if (navigationAction.targetFrame == nil) {
        //过滤图片加载
        NSString *jsonStr = @"[{\"trigger\":{\"url-filter\": \".*\",\"resource-type\":[\"image\"]},\"action\":{\"type\":\"block\"}}]";
        if (@available(iOS 11.0, *)) {
            [[WKContentRuleListStore defaultStore] compileContentRuleListForIdentifier:@"demoRuleList" encodedContentRuleList:jsonStr completionHandler:^(WKContentRuleList *list, NSError *error) {
                [webView.configuration.userContentController addContentRuleList:list];
                [webView loadRequest:navigationAction.request];
            }];
        } else {
            // Fallback on earlier versions
            [webView loadRequest:navigationAction.request];
        }
        NSLog(@"%@",navigationAction);
    }
    
//    或者
    NSString *hostname = navigationAction.request.URL.host.lowercaseString;
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated
        && ![hostname containsString:@".baidu.com"]) {
        // 对于跨域，需要手动跳转
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        
        // 不允许web内跳转
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    if (navigationAction.navigationType == WKNavigationTypeBackForward) {
        //判断是返回类型
        NSLog(@"返回");
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}
// 当main frame的导航开始请求时，会调用此方法
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"开始加载网页");
    //开始加载网页时展示出progressView
    self.progressView.hidden = NO;
    //开始加载网页的时候将progressView的Height恢复为1.5倍
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
}

// 当main frame接收到服务重定向时，会回调此方法或接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"开始接收请求");
}

// 当main frame开始加载数据失败时，会回调
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"开始加载失败---%@",error);
    self.progressView.hidden = YES;
}

// 当main frame的web当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"内容返回");
}
// 当main frame导航完成时，会回调
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"加载完成");
    
    [webView evaluateJavaScript:@"document.cookie = 'hq_http_usertoken=GojvvmpfnXXAQ6/HxBfMIQFJhWXOBYQfzhWCHpRABtI=;domain=hq-app-dev.zhongan.io;path=/'" completionHandler:^(id result, NSError *error) {
        NSLog(@"%@%@",result,error);
    }];
    
    self.title = webView.title;
    if (@available(iOS 11.0, *)) {
        [webView.configuration.websiteDataStore.httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
            NSLog(@"%@",cookies);
        }];
    } else {
        // Fallback on earlier versions
    }
}

// 当main frame最后下载数据失败时，会回调
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"最终加载失败---%@",error);
}

/* 对于HTTPS的都会触发此代理，如果不要求验证，传默认就行
 如果需要证书验证，与使用AFN进行HTTPS证书验证是一样的 */
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
        
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}

// 当 WKWebView 总体内存占用过大，页面即将白屏的时候，系统会调用上面的回调函数，我们在该函数里执行[webView reload](这个时候 webView.URL 取值尚不为 nil）解决白屏问题。在一些高内存消耗的页面可能会频繁刷新当前页面，H5侧也要做相应的适配操作。
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    [webView reload];
}


// 决定是否接收响应
// 这个是决定是否接收response
// 要获取response，通过WKNavigationResponse对象获取
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
//    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
//    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
//    //读取wkwebview中的cookie 方法1
//    for (NSHTTPCookie *cookie in cookies) {
//        //        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//        NSLog(@"wkwebview中的cookie:%@", cookie);
//    }
//    //读取wkwebview中的cookie 方法2 读取Set-Cookie字段
//    NSString *cookieString = [[response allHeaderFields] valueForKey:@"Set-Cookie"];
//    NSLog(@"wkwebview中的cookie:%@", cookieString);
////
//    //看看存入到了NSHTTPCookieStorage了没有
//    NSHTTPCookieStorage *cookieJar2 = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    for (NSHTTPCookie *cookie in cookieJar2.cookies) {
//        NSLog(@"NSHTTPCookieStorage中的cookie%@", cookie);
//    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark - WKUIDelegate
//提供用原生控件显示网页的方法回调。
// 创建新的webview
// 可以指定配置对象、导航动作对象、window特性
//- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
//
//}
// webview关闭时回调注意iOS9后
- (void)webViewDidClose:(WKWebView *)webView {
    NSLog(@"close");
}

//当把JS返回给控制器,然后弹窗就是这样设计的
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    completionHandler(@"http");
}
// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    completionHandler(YES);
}
//支持预览 也就是3D Touch
//- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo {
//    NSLog(@"%@",elementInfo.linkURL);
//    return NO;
//}
//- (nullable UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id <WKPreviewActionItem>> *)previewActions {
//    UIViewController *controller = [UIViewController new];
//    controller.view.frame = self.view.frame;
//    NSMutableArray *actionArr = [NSMutableArray array];
//    for (id i in previewActions) {
//        NSLog(@"%@",i);
//    }
//    [webView loadRequest:[NSURLRequest requestWithURL:elementInfo.linkURL]];
//    [controller.view addSubview:webView];
//    return controller;
//}
//- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController {
//
//}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"%f",self.webView.estimatedProgress);
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.webView.estimatedProgress;
        if (self.progressView.progress == 1) {
            /*
             *添加一个简单的动画，将progressView的Height变为1.4倍
             *动画时长0.25s，延时0.3s后开始动画
             *动画结束后将progressView隐藏
             */
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                self.progressView.hidden = YES;
            }];
        }
    }
}
- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.interface.allInterface enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.userContentController removeScriptMessageHandlerForName:obj];
    }];
    NSLog(@"%s",__func__);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//开始加载特定资源时调用
- (void)webView:(nonnull WKWebView *)webView startURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask  API_AVAILABLE(ios(11.0)){
    NSString *str = urlSchemeTask.request.URL.absoluteString;
    UIImage *image = [UIImage imageNamed:[self getImageName:str]];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:@"image/jpeg" expectedContentLength:imageData.length textEncodingName:nil];
    [urlSchemeTask didReceiveResponse:response];
    [urlSchemeTask didReceiveData:imageData];
    [urlSchemeTask didFinish];
}
- (NSString *)getImageName:(NSString *)str {
    if ([str hasPrefix:@"wk-app://"]) {
        NSRange range = [str rangeOfString:@"wk-app://"];
        return [str substringFromIndex:range.length];
    }
    return nil;
}
//停止载特定资源时调用
- (void)webView:(nonnull WKWebView *)webView stopURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask  API_AVAILABLE(ios(11.0)){
    urlSchemeTask = nil;
}

@end
