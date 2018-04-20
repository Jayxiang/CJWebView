//
//  UseWebViewVC.m
//  CJWebView
//
//  Created by tet-cjx on 2018/1/16.
//  Copyright © 2018年 hyd-cjx. All rights reserved.
//

#import "UseWebViewVC.h"
#import <WebKit/WebKit.h>
@interface UseWebViewVC ()

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation UseWebViewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self creatView];
}

/**
 加载可用loadData或者loadFileURL和loadRequest
 而直接使用loadFileURL加载TXT会出现乱码
 用loadData还要注意MIMEType和编码格式
 但是用loadData加载doc一直是乱码没找到原因
 另外loadHTMLString可以加载HTML标签语言
 */
- (void)creatView {
    NSString *htmlString=@"<a>用我加载HTML语言<ol><li>HTML</li><li>PDF</li><li>TXT</li></ol>";
    WKWebView *web = [[WKWebView alloc] initWithFrame:self.view.bounds];
    NSString *name;
    NSString *mimeType;
    switch (_loadType) {
        case CJWebloadTypeTxt: {
            name = @"张小龙发布2018微信全新计划.txt";
            mimeType = @"text/plain";
            break;
        }
        case CJWebloadTypePDF: {
            name = @"编写高质量iOS代码的52个有效方法.pdf";
            mimeType = @"application/pdf";
            break;
        }
        case CJWebloadTypeDOC: {
            name = @"考勤.doc";
            mimeType = @"application/msword";
            break;
        }
        case CJWebloadTypeHTML: {
            name = @"考勤.doc";
            mimeType = @"application/msword";
            break;
        }
        default:
            break;
    }
    NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:nil];
    if (_loadType == CJWebloadTypeTxt) {
#if 1
        NSData *data = [NSData dataWithContentsOfURL:url];
        [web loadData:data MIMEType:mimeType characterEncodingName:@"UTF-8" baseURL:url];
#else
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [web loadRequest:request];
#endif
    } else {
        if (_loadType == CJWebloadTypeHTML) {
            [web loadHTMLString:htmlString baseURL:nil];
        } else {
            [web loadFileURL:url allowingReadAccessToURL:url];
        }
    }
    self.webView = web;
    [self.view addSubview:self.webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
