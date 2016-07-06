//
//  MSMenuBar.m
//  MSMenuBar
//
//  Created by limingshan on 16/5/30.
//  Copyright © 2016年 limingshan. All rights reserved.
//

// 获取CXMenuBar.bundle下的图片
#define MSMenuBarBundleName @"MSMenuBar.bundle"
#define MSMenuBarImagePathWithImageName(imageName) [MSMenuBarBundleName stringByAppendingPathComponent:imageName]
#define MSMenuBarImageWithImageName(imageName) [UIImage imageNamed:MSMenuBarImagePathWithImageName(imageName)]

#define kMenuEditButton_width 43
#define MSMenuInitTag 1000000
#define MSMenuBarTitleSpace 25

#import "MSMenuBar.h"

@implementation MSMenuBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //设置默认值
        [self _defaultValue];
    }
    return self;
}

#pragma mark ========= 菜单栏的设置 =========

//创建菜单栏
- (void)_initMenuBar {
    // 0.菜单栏背景视图
    _menuBarBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, _menuBarHeight)];
    _menuBarBgView.backgroundColor = [UIColor whiteColor];
    _menuBarBgView.layer.borderWidth = _menuLayerBorderWidth;
    _menuBarBgView.layer.borderColor = _menuLayerBorderColor.CGColor;
    [self addSubview:_menuBarBgView];
    // 1.创建菜单滚动视图
    _menuBarScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width - kMenuEditButton_width, _menuBarHeight)];
    _menuBarScrollView.delegate = self;
    _menuBarScrollView.showsHorizontalScrollIndicator = NO;
    _menuBarScrollView.showsVerticalScrollIndicator = NO;
    _menuBarScrollView.backgroundColor = [UIColor clearColor];
    [_menuBarBgView addSubview:_menuBarScrollView];
    // 2.创建左右遮罩视图
    // 左侧视图
    _maskLeftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, 20, _menuBarHeight - 2)];
    _maskLeftImageView.image = [[UIImage imageNamed:@"msmenuBar_l.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:10];
    [_menuBarBgView addSubview:_maskLeftImageView];
    // 右侧视图
    _maskRightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_menuBarScrollView.frame.size.width - 19, 1, 20, _menuBarHeight - 2)];
    _maskRightImageView.image = [[UIImage imageNamed:@"msmenuBar_r.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:10];
    [_menuBarBgView addSubview:_maskRightImageView];
    // 3.编辑按钮 team_edit-4.7@2x.png 46 46
    _menuEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _menuEditButton.frame = CGRectMake(_menuBarScrollView.frame.size.width, (_menuBarHeight - 23) / 2.0, kMenuEditButton_width, 23);
    [_menuEditButton setImage:[UIImage imageNamed:@"msmenuBar_edit.png"] forState:UIControlStateNormal];
    [_menuEditButton setImage:[UIImage imageNamed:@"team_edit-4.7.png"] forState:UIControlStateHighlighted];
    _menuEditButton.backgroundColor = [UIColor clearColor];
    [_menuEditButton addTarget:self action:@selector(MSMenuBarEidtButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_menuBarBgView addSubview:_menuEditButton];
    //菜单栏不发生自动滚动的临界值
    _scroll_max = self.bounds.size.width - _maskLeftImageView.bounds.size.width - kMenuEditButton_width - 50;
    // 4.选中下划线
    _menuSelectedLine = [[UIView alloc] initWithFrame:CGRectZero];
    _menuSelectedLine.backgroundColor = _menuTitleSelectedLineColor;
}

#pragma mark - 编辑按钮点击事件
- (void)MSMenuBarEidtButtonAction:(UIButton *)button {
    if ([_delegate respondsToSelector:@selector(msMenuBar:didEditButtonClicked:)]) {
        [_delegate msMenuBar:self didEditButtonClicked:button];
    }
}

//设置默认值
- (void)_defaultValue {
    _menuBarHeight = 40;
    _menuBarTitleNormalFont = [UIFont systemFontOfSize:14];
    _menuBarTitleSelectedFont = [UIFont boldSystemFontOfSize:14];
    _menuTitleSelectedLineColor = [UIColor blueColor];
    _menuTitleSelectedColor = [UIColor blueColor];
    _menuTitleNormalColor = [UIColor lightGrayColor];
    _menuLayerBorderWidth = 1;
    _menuLayerBorderColor = [UIColor blueColor];
}

//创建菜单栏
- (void)_initMenuBarItems {
    // 1.移除滑动视图所有的子视图
    for (UIView *subView in _menuBarScrollView.subviews) {
        // 从父视图上移除当前子视图
        [subView removeFromSuperview];
    }
    
    _allMenuCell = [NSMutableArray array];
    // 2.根据文本标题创建滑动视图的内容
    for (int i = 0; i < _menuTitles.count; i++) {
        // 01 创建文本视图
        UILabel *menuCell = [[UILabel alloc] initWithFrame:CGRectZero];
        //保存menuCell
        [_allMenuCell addObject:menuCell];
        menuCell.font = _menuBarTitleNormalFont;
        menuCell.textColor = _menuTitleNormalColor;
        menuCell.backgroundColor = [UIColor clearColor];
        menuCell.tag = MSMenuInitTag + i;
        // 添加点击事件
        menuCell.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(meneCellTapAction:)];
        [menuCell addGestureRecognizer:tap];
        // 02 设置文本内容
        menuCell.text = _menuTitles[i];
        // 设置视图文本内容自适应
        // 获取文本的尺寸
        CGSize menuTitleSize = [_menuTitles[i] sizeWithAttributes:@{NSFontAttributeName:_menuBarTitleSelectedFont}];
        menuCell.frame = CGRectMake(0, 0, menuTitleSize.width, _menuBarHeight - 2);
        // 03 获取前一个文本视图
        UILabel *beforeMenuCell = [_menuBarScrollView.subviews lastObject];
        CGFloat beforeMenuCell_right = beforeMenuCell.frame.origin.x + beforeMenuCell.frame.size.width;
        // 04 设置当前文本视图的大小和位置
        menuCell.frame = CGRectMake(beforeMenuCell_right + MSMenuBarTitleSpace, 0, menuCell.frame.size.width, _menuBarHeight - 2);
        [_menuBarScrollView addSubview:menuCell];
        // 05 设置滑动视图内容视图的大小
        if (i == _menuTitles.count - 1) {
            // 当前循环创建了最后一个文本视图
            // 获取当文本视图右边的位置
            CGFloat menuCell_right = menuCell.frame.origin.x + menuCell.frame.size.width;
            float contentSize_w = MAX(_menuBarScrollView.frame.size.width + 1, menuCell_right + MSMenuBarTitleSpace);
            _menuBarScrollView.contentSize = CGSizeMake(contentSize_w, _menuBarScrollView.frame.size.height);
        }
        // 06 设置选中视图位置和大小
        if (i == _menuCellSelectedIndex) {
            // 01 设置选中视图的大小和位置
            _menuSelectedLine.frame = CGRectMake(menuCell.frame.origin.x, _menuBarHeight - 3, menuCell.frame.size.width, 2);
            [_menuBarScrollView addSubview:_menuSelectedLine];
            // 02 设置选中文本
            menuCell.font = _menuBarTitleSelectedFont;
            menuCell.textColor = _menuTitleSelectedColor;
        }
    }
}

#pragma mark - TAP ACTION
- (void)meneCellTapAction:(UITapGestureRecognizer *)tap {
    if ([tap.view isKindOfClass:[UILabel class]]) {
        // 获取当前点击视图的位置
        NSInteger selectedIndex = tap.view.tag - MSMenuInitTag;
        self.selectedIndex = selectedIndex;
        _menuCellSelectedIndex = selectedIndex;
        
        //修改内容滚动视图的偏移量
        [UIView animateWithDuration:.25 animations:^{
            _contentScrollView.contentOffset = CGPointMake(_selectedIndex * _contentScrollView.bounds.size.width, 0);
        }];
        [self setScrollAnimation];
    }
}

/**
 * 菜单栏高度
 */
- (void)setMenuBarHeight:(CGFloat)menuBarHeight {
    _menuBarHeight = menuBarHeight;
    //创建菜单栏
    [self _initMenuBar];
}

/**
 * 菜单栏标题字体_默认
 */
- (void)setMenuBarTitleNormalFont:(UIFont *)menuBarTitleNormalFont {
    if (_menuBarTitleNormalFont != menuBarTitleNormalFont) {
        _menuBarTitleNormalFont = menuBarTitleNormalFont;
    }
    for (UIView *view in _menuBarScrollView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *menuCell = (UILabel *)view;
            if (menuCell.tag == MSMenuInitTag + _selectedIndex) {
                menuCell.font = _menuBarTitleSelectedFont;
            }else {
                menuCell.font = _menuBarTitleNormalFont;
            }
        }
    }
}

/**
 * 菜单栏标题字体_选中
 */
- (void)setMenuBarTitleSelectedFont:(UIFont *)menuBarTitleSelectedFont {
    if (_menuBarTitleSelectedFont != menuBarTitleSelectedFont) {
        _menuBarTitleSelectedFont = menuBarTitleSelectedFont;
    }
    for (UIView *view in _menuBarScrollView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *menuCell = (UILabel *)view;
            if (menuCell.tag == MSMenuInitTag + _selectedIndex) {
                menuCell.font = _menuBarTitleSelectedFont;
            }else {
                menuCell.font = _menuBarTitleNormalFont;
            }
        }
    }
}

/**
 * 菜单栏标题字体颜色_选中
 */
- (void)setMenuTitleSelectedColor:(UIColor *)menuTitleSelectedColor {
    if (_menuTitleSelectedColor != menuTitleSelectedColor) {
        _menuTitleSelectedColor = menuTitleSelectedColor;
    }
    for (UIView *view in _menuBarScrollView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *menuCell = (UILabel *)view;
            if (menuCell.tag == MSMenuInitTag + _selectedIndex) {
                menuCell.textColor = _menuTitleSelectedColor;
            }else {
                menuCell.textColor = _menuTitleNormalColor;
            }
        }
    }
}

/**
 * 菜单栏标题字体颜色_默认
 */
- (void)setMenuTitleNormalColor:(UIColor *)menuTitleNormalColor {
    if (_menuTitleNormalColor!= menuTitleNormalColor) {
        _menuTitleNormalColor = menuTitleNormalColor;
    }
    for (UIView *view in _menuBarScrollView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *menuCell = (UILabel *)view;
            if (menuCell.tag == MSMenuInitTag + _selectedIndex) {
                menuCell.textColor = _menuTitleSelectedColor;
            }else {
                menuCell.textColor = _menuTitleNormalColor;
            }
        }
    }
}

/**
 * 菜单栏标题选中下划线颜色
 */
- (void)setMenuTitleSelectedLineColor:(UIColor *)menuTitleSelectedLineColor {
    if (_menuTitleSelectedLineColor != menuTitleSelectedLineColor) {
        _menuTitleSelectedLineColor = menuTitleSelectedLineColor;
    }
    _menuSelectedLine.backgroundColor = _menuTitleSelectedLineColor;
}

/*
 * 菜单栏的表框的颜色
 */
- (void)setMenuLayerBorderColor:(UIColor *)menuLayerBorderColor {
    if (_menuLayerBorderColor != menuLayerBorderColor) {
        _menuLayerBorderColor = menuLayerBorderColor;
    }
    _menuBarBgView.layer.borderColor = _menuLayerBorderColor.CGColor;
}

/*
 * 菜单栏的表框的宽度
 */
- (void)setMenuLayerBorderWidth:(CGFloat)menuLayerBorderWidth {
    _menuLayerBorderWidth = menuLayerBorderWidth;
    _menuBarBgView.layer.borderWidth = _menuLayerBorderWidth;
}

/*
 *  菜单栏控件选中按钮索引位置
 */
- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self setScrollAnimation];
}
/*
 * 菜单栏的背景颜色
 */
- (void)setMenuBarBgColor:(UIColor *)menuBarBgColor {
    if (_menuBarBgColor != menuBarBgColor) {
        _menuBarBgColor = menuBarBgColor;
    }
    _menuBarBgView.backgroundColor = _menuBarBgColor;
}

/*
 * 菜单栏是否显示遮罩视图
 */
- (void)setIsShowMaskViews:(BOOL)isShowMaskViews {
    _isShowMaskViews = isShowMaskViews;
    if (_isShowMaskViews == YES) {
        _maskLeftImageView.hidden = NO;
        _maskRightImageView.hidden = NO;
    }else {
        _maskLeftImageView.hidden = YES;
        _maskRightImageView.hidden = YES;
    }
}

#pragma mark ============ 标题数组 ============

- (void)setMenuTitles:(NSArray *)menuTitles {
    if (_menuTitles != menuTitles) {
        _menuTitles = menuTitles;
    }
    [self _initMenuBarItems];
}

#pragma mark ========= 内容视图的设置 =========

//创建内容视图
- (void)_initContentScrollView {
    _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _menuBarBgView.bounds.size.height, self.bounds.size.width, self.bounds.size.height - _menuBarBgView.bounds.size.height)];
    _contentScrollView.contentSize = CGSizeMake(_menuTitles.count * self.bounds.size.width, self.bounds.size.height - _menuBarBgView.bounds.size.height);
    _contentScrollView.showsVerticalScrollIndicator = NO;
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    _contentScrollView.pagingEnabled = YES;
    _contentScrollView.delegate = self;
    _contentScrollView.backgroundColor = [UIColor clearColor];
    
    _contentScrollView.contentOffset = CGPointMake(_menuCellSelectedIndex * self.bounds.size.width, 0);
    
    [self addSubview:_contentScrollView];
}

/*
 *  内容视图数组
 */
- (void)setContentViews:(NSArray *)contentViews {
    if (_contentViews != contentViews) {
        _contentViews = contentViews;
    }
    //创建内容滚动视图
    [self _initContentScrollView];
    
    //移除之前的视图
    for (UIView *view in _contentScrollView.subviews) {
        [view removeFromSuperview];
    }
    //创建视图
    for (int i = 0; i < _contentViews.count; i ++) {
        UIView *view = _contentViews[i];
        view.frame = CGRectMake(i * _contentScrollView.bounds.size.width, 0, _contentScrollView.bounds.size.width, _contentScrollView.bounds.size.height);
        [_contentScrollView addSubview:view];
    }
}

#pragma mark -  菜单栏添加标题 内容视图添加视图

- (void)addMenuTitle:(NSString *)menuTitle contentView:(UIView *)contentView {
    //添加菜单栏标题
    NSMutableArray *menuTitles = [_menuTitles mutableCopy];
    [menuTitles addObject:menuTitle];
    self.menuTitles = menuTitles;
    //添加内容视图
    NSMutableArray *contentViews = [_contentViews mutableCopy];
    [contentViews addObject:contentView];
    self.contentViews = contentViews;
}

#pragma mark -  菜单栏移除标题 内容视图移除视图

- (void)removeMenuTitleAndContentViewWithIndex:(NSInteger)removeIndex {
    //得到要删掉的标题
    UILabel *currentMenuCell = _allMenuCell[removeIndex];
    //得到之前的标题
    UILabel *lastMenuCell = _allMenuCell[removeIndex - 1];

    //如果下划线在要删掉标题上
    if (_menuSelectedLine.frame.origin.x == currentMenuCell.frame.origin.x) {
        //设置选中下划线的位置
        [UIView animateWithDuration:.25 animations:^{
            _menuSelectedLine.frame = CGRectMake(lastMenuCell.frame.origin.x, _menuBarHeight - 3, lastMenuCell.frame.size.width, 2);
        }];
        
        //内容视图切换
        _contentScrollView.contentOffset = CGPointMake((removeIndex - 1) * _contentScrollView.bounds.size.width, 0);
    }else {
        //下划线不在要删掉标题上
    }
    
    //移除菜单栏标题
    NSString *removeTitle = _menuTitles[removeIndex];
    NSMutableArray *menuTitles = [_menuTitles mutableCopy];
    [menuTitles removeObject:removeTitle];
    self.menuTitles = menuTitles;
    
    //移除内容视图
    //移除数组中的视图
    NSMutableArray *contentViews = [_contentViews mutableCopy];
    UIView *contentRomoveView = contentViews[removeIndex];
    //在内容视图滚动视图上移除
    [contentRomoveView removeFromSuperview];
    [contentViews removeObject:contentRomoveView];
    self.contentViews = contentViews;
}

#pragma mark - 更新菜单栏标题和内容视图

- (void)reloadMenuBarWithMenuTitles:(NSArray *)menuTitles contentViews:(NSArray *)contentViews {
    self.menuTitles = menuTitles;
    self.contentViews = contentViews;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _menuBarScrollView) {//菜单栏的滚动视图
        
    }else if (scrollView == _contentScrollView) {//内容视图的滚动视图
        NSInteger page = scrollView.contentOffset.x / self.bounds.size.width;
        self.selectedIndex = page;
        _menuCellSelectedIndex = page;
    }
}

#pragma mark - 滑动效果
- (void)setScrollAnimation {
    //修改标题文本的字体
    for (int i = 0; i < _menuBarScrollView.subviews.count; i ++) {
        UIView *view = _menuBarScrollView.subviews[i];
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *menuCell = (UILabel *)view;
            if (menuCell.tag == _selectedIndex + MSMenuInitTag) {
                menuCell.font = _menuBarTitleSelectedFont;
                menuCell.textColor = _menuTitleSelectedColor;
                //设置选中下划线的位置
                [UIView animateWithDuration:.25 animations:^{
                    _menuSelectedLine.frame = CGRectMake(menuCell.frame.origin.x, _menuBarHeight - 3, menuCell.frame.size.width, 2);
                }];
                //判断菜单栏是否需要滚动
                CGFloat selectedLineX = _menuSelectedLine.frame.origin.x;
                if (selectedLineX > [UIScreen mainScreen].bounds.size.width / 2.0)                                                                                                 {
                    //下划线的X超过了半屏
                    //得到当前标题的X和W
                    CGFloat currentCellX = menuCell.frame.origin.x;
                    if (i == _menuTitles.count) {
                        //显示最后一个标题需要的偏移量
                        CGFloat lastContentOffsetX = _menuBarScrollView.contentSize.width - (self.bounds.size.width - kMenuEditButton_width);
                        [UIView animateWithDuration:.25 animations:^{
                            _menuBarScrollView.contentOffset = CGPointMake(lastContentOffsetX, 0);
                        }];
                    }else {
                        //下一个标题及以后剩下的宽度
                        CGFloat remainLastWidth = _menuBarScrollView.contentSize.width - currentCellX ;
                        if (remainLastWidth < [UIScreen mainScreen].bounds.size.width / 2.0 - kMenuEditButton_width - _maskRightImageView.bounds.size.width) {
                            
                        }else {
                            //菜单栏选中标题滚动到中央
                            [UIView animateWithDuration:.25 animations:^{
                                _menuBarScrollView.contentOffset = CGPointMake(selectedLineX - [UIScreen mainScreen].bounds.size.width / 2.0 + menuCell.bounds.size.width / 2.0, 0);
                            }];
                        }
                    }
                }else if (selectedLineX < [UIScreen mainScreen].bounds.size.width / 2.0) {
                    //下划线的X没超过半屏
                    [UIView animateWithDuration:.25 animations:^{
                        _menuBarScrollView.contentOffset = CGPointMake(0, 0);
                    }];
                }
            }else {
                menuCell.textColor = _menuTitleNormalColor;
                menuCell.font = _menuBarTitleNormalFont;
            }
        }
    }
}








































@end
