//
//  WKJSInterface.h
//  CJWebView
//
//  Created by tet-cjx on 2018/5/28.
//  Copyright © 2018年 hyd-cjx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "WKJSFunction.h"

@protocol WKJSInterfaceDelegate <NSObject>

- (WKWebView *)interfaceWebview;
- (UIViewController *)interfaceController;

@end

@interface WKJSInterface : NSObject<WKScriptMessageHandler>

- (instancetype)initWithDelegate:(id<WKJSInterfaceDelegate>)delegate;

@property (nonatomic, weak) id<WKJSInterfaceDelegate> delegate;

@property (nonatomic, copy) NSArray *allInterface;

+ (NSArray<NSString *> *)methodListWithProtocol:(Protocol *)protocol;

@end

API_AVAILABLE(ios(11.0))
@interface WeakWKURLSchemeHandler : NSObject<WKURLSchemeHandler>

- (instancetype)initWithDelegate:(id<WKURLSchemeHandler>)delegate;

@property (nonatomic, weak) id<WKURLSchemeHandler> delegate;

@end
