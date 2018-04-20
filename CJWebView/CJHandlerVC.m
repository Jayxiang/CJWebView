//
//  CJHandlerVC.m
//  CJWebView
//
//  Created by tet-cjx on 2018/1/17.
//  Copyright © 2018年 hyd-cjx. All rights reserved.
//

#import "CJHandlerVC.h"

@interface CJHandlerVC ()

@end

@implementation CJHandlerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([self.delegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
