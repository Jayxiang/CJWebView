//
//  CJHandlerVC.h
//  CJWebView
//
//  Created by tet-cjx on 2018/1/17.
//  Copyright © 2018年 hyd-cjx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@protocol WKDelegate <NSObject>

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;
@end

@interface CJHandlerVC : UIViewController<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKDelegate> delegate;

@end
