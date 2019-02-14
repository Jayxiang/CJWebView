//
//  WKJSFunction.h
//  CJWebView
//
//  Created by tet-cjx on 2019/2/14.
//  Copyright © 2019 hyd-cjx. All rights reserved.
//

#ifndef WKJSFunction_h
#define WKJSFunction_h

@protocol WKJSFunction <NSObject>

/**
 *  调用相册相机
 *  callBack: 回调函数
 *  length:   图片大小
 */
- (void)takeUserImage:(id)body;

/**
 *  字典数据
 */
- (void)getDicDataByType:(id)body;

@end

#endif /* WKJSFunction_h */
