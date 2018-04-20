//
//  UseWebViewVC.h
//  CJWebView
//
//  Created by tet-cjx on 2018/1/16.
//  Copyright © 2018年 hyd-cjx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CJWebloadType) {
    CJWebloadTypeHTML,
    CJWebloadTypeTxt,
    CJWebloadTypePDF,
    CJWebloadTypeDOC
};

@interface UseWebViewVC : UIViewController

@property (nonatomic, assign) CJWebloadType loadType;

@end
