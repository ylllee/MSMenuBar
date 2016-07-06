//
//  ViewController.m
//  MSMenuBar
//
//  Created by limingshan on 16/7/6.
//  Copyright © 2016年 limingshan. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 1.标题
    self.title = @"MenuBar";
    // 2.取消滑动视图内填充
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    // 3.获取菜单栏标题
    //获取json数据
    NSString *json_path = [[NSBundle mainBundle] pathForResource:@"MenuTitleJson" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:json_path];
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSArray *titles1 = result[@"menuTitles"];
    NSArray *titles2 = result[@"selfTitles"];
    NSMutableArray *menuTitles = [[NSMutableArray alloc] initWithArray:titles1];
    [menuTitles addObjectsFromArray:titles2];
    _menuTitles = menuTitles;
    // 4.创建菜单栏
    [self _initMenuBar];
}

// 4.创建菜单栏
- (void)_initMenuBar {
    if (_menuBar == nil) {
        _menuBar = [[MSMenuBar alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
        _menuBar.backgroundColor = [UIColor clearColor];
        _menuBar.delegate = self;
        _menuBar.menuBarHeight = kMenu_height;
        _menuBar.menuTitleSelectedLineColor = kTitleSelectedColor;
        _menuBar.menuBarTitleNormalFont = [UIFont systemFontOfSize:kMenuTitle_font];
        _menuBar.menuBarTitleSelectedFont = [UIFont boldSystemFontOfSize:kMenuTitle_font];
        _menuBar.menuTitleNormalColor = [UIColor blackColor];
        _menuBar.menuTitleSelectedColor = kTitleSelectedColor;
        _menuBar.menuLayerBorderWidth = 1;
        _menuBar.menuLayerBorderColor = kColorWith(214, 215, 220, 1);
    }
    //菜单栏标题数组
    _menuBar.menuTitles = _menuTitles;
    
    // 5.创建内容视图
    [self _initContentViews];
    
    [self.view addSubview:_menuBar];
}

// 5.创建内容视图
- (void)_initContentViews {
    NSMutableArray *contentViews = [NSMutableArray array];
    for (int i = 0; i < _menuBar.menuTitles.count; i ++) {
        //创建表视图
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.tag = kContentView + i;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [contentViews addObject:tableView];
    }
    _menuBar.contentViews = contentViews;
    _contentViews = contentViews;
}

#pragma mark - UITabelViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 50;
}

//单元格高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"第%ld行",indexPath.row + 1];
    return cell;
}
#pragma mark - UITableViewDelegate
//选中单元格
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //取消选中样式
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //点击单元格事件
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
