//
//  ViewController.m
//  CJWebView
//
//  Created by tet-cjx on 2018/1/16.
//  Copyright © 2018年 hyd-cjx. All rights reserved.
//

#import "ViewController.h"
#import "UseWebViewVC.h"
#import "WKVSJSViewController.h"
#import "WebViewJavascriptBridgeTest.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *webTableView;
@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self creatView];
    self.title = @"CJWebView";
}
- (void)creatView {
    self.dataArr = @[@"加载HTML",@"加载PDF",@"加载TXT",@"加载doc",@"加载视频",@"原生交互",@"WebViewJavascriptBridge交互"];
    UITableView *table = [[UITableView alloc] initWithFrame:self.view.bounds];
    table.delegate = self;
    table.dataSource = self;
    table.tableFooterView = [UIView new];
    self.webTableView = table;
    [self.view addSubview:self.webTableView];
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"web"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"web"];
    }
    cell.textLabel.text = self.dataArr[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 4) {
        WKVSJSViewController *js = [[WKVSJSViewController alloc] init];
        js.name = @"VideoTest";
        [self.navigationController pushViewController:js animated:YES];
        return;
    }
    if (indexPath.row == 5) {
        WKVSJSViewController *js = [[WKVSJSViewController alloc] init];
        js.name = @"test";
        [self.navigationController pushViewController:js animated:YES];
        return;
    }
    if (indexPath.row == 6) {
        WebViewJavascriptBridgeTest *js = [[WebViewJavascriptBridgeTest alloc] init];
        [self.navigationController pushViewController:js animated:YES];
        return;
    }
    UseWebViewVC *web = [[UseWebViewVC alloc] init];
    if (indexPath.row == 0) {
        web.loadType = CJWebloadTypeHTML;
    } else if (indexPath.row == 1) {
        web.loadType = CJWebloadTypePDF;
    } else if (indexPath.row == 2) {
        web.loadType = CJWebloadTypeTxt;
    } else if (indexPath.row == 3) {
        web.loadType = CJWebloadTypeDOC;
    }
    [self.navigationController pushViewController:web animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
