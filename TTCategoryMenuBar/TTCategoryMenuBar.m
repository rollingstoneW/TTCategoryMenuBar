//
//  TTCategoryMenuBar.m
//  TTKit
//
//  Created by rollingstoneW on 2019/7/1.
//  Copyright © 2019 TTKit. All rights reserved.
//

#import "TTCategoryMenuBar.h"
#import "TTCategoryMenuBarUtil.h"
#import "TTCategoryMenuBarOptionView.h"
#import "Masonry.h"
#import "TTCategoryMenuBarOptionItem+TTPrivate.h"

@interface  TTCategoryMenuBarBackgroundView : UIView <UIGestureRecognizerDelegate>
@property (nonatomic, strong) dispatch_block_t tapedBlock;
@end

@implementation TTCategoryMenuBarBackgroundView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapedAction)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tapedAction {
    !self.tapedBlock ?: self.tapedBlock();
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (CGRectContainsPoint(self.subviews.firstObject.frame, [gestureRecognizer locationInView:self])) {
        return NO;
    }
    return YES;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.alpha < 00.1 || self.hidden) {
        return NO;
    }
    return [super pointInside:point withEvent:event];
}

@end

@interface TTCategoryMenuBar () <TTCategoryMenuBarOptionViewDelegate>

@property (nonatomic, strong) UIView *barItemContainerView;
@property (nonatomic, strong) TTCategoryMenuBarBackgroundView *backgroundView;

@property (nonatomic,   weak) TTCategoryMenuBarOptionView *currentOptionView;
@property (nonatomic,   weak) UIButton *currentButtonItem;

@property (nonatomic, assign) BOOL isInCommiting;

@end

@implementation TTCategoryMenuBar

- (instancetype)initWithItems:(NSArray<TTCategoryMenuBarCategoryItem *> *)items
                      options:(NSArray<NSArray<TTCategoryMenuBarOptionItem *> *> *)options {
    if (self = [super initWithFrame:CGRectZero]) {
        _items = items;
        _options = options;
        
        self.barItemContainerView = [[UIView alloc] init];
        self.barItemContainerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.barItemContainerView];
        [self.barItemContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.bottomLine = [[UIView alloc] init];
        self.bottomLine.backgroundColor = TTCategoryMenuBarLineColor();
        [self addSubview:self.bottomLine];
        [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.height.equalTo(@(TTCategoryMenuBar1PX));
        }];
    }
    return self;
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self.backgroundView removeFromSuperview];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 已经布局完成
    if (!CGSizeEqualToSize(self.frame.size, CGSizeZero) && !self.barItemContainerView.subviews.count) {
        [self reloadItems];
    }
}

- (void)reloadItems:(NSArray<__kindof TTCategoryMenuBarCategoryItem *> *)items options:(NSArray<NSArray<__kindof TTCategoryMenuBarOptionItem *> *> *)options {
    self.items = items;
    self.options = options;
    [self reloadItems];
}

- (void)updateItem:(__kindof TTCategoryMenuBarCategoryItem *)item atCategory:(NSInteger)category {
    if (!item || category >= self.items.count) {
        return;
    }
    
    NSMutableArray *array = nil;
    if (item.shouldUseSelectedOptionTitle && [self.delegate respondsToSelector:@selector(categoryMenuBar:titleForSelectedOptions:atCategory:)]) {
        array = [NSMutableArray array];
        NSArray *options = self.options[category];
        for (TTCategoryMenuBarOptionItem *option in options) {
            BOOL added = NO;
            if (item.style == TTCategoryMenuBarCategoryStyleSingleList && [option isSelfSelected]) {
                added = YES;
                [array addObject:option];
            }
            // 如果子选项选中了，把他也包含进去
            if ([option loadSelectedChild] && !added) {
                [array addObject:option];
            }
        }
    }
    [self updateItem:item atCategory:category selectedOptions:array];
    for (TTCategoryMenuBarOptionItem *option in array) {
        //调用完selectedChildOptions，调用clearSelectedChildren清理selectedChildOptions数组
        [option clearSelectedChildren];
    }
}

- (void)updateItem:(__kindof TTCategoryMenuBarCategoryItem *)item atCategory:(NSInteger)category selectedOptions:(NSArray *)options {
    UIButton *button = [self menuButtonItemAtCategory:category];
    NSAttributedString *normal = item.attributedTitle ? [[NSAttributedString alloc] initWithString:item.attributedTitle.string attributes:item.titleAttributes]: [[NSAttributedString alloc] initWithString:item.title ?: @""
                                                                                        attributes:item.titleAttributes];
    NSAttributedString *selected = item.selectedAttributedTitle ? [[NSAttributedString alloc] initWithString:item.selectedAttributedTitle.string attributes:item.selectedTitleAttributes]:
    [[NSAttributedString alloc] initWithString:item.title ?: @"" attributes:item.selectedTitleAttributes];
    
    [button setAttributedTitle:normal forState:UIControlStateNormal];
    [button setAttributedTitle:selected forState:UIControlStateSelected];
    [button setAttributedTitle:selected forState:UIControlStateSelected | UIControlStateHighlighted];
    button.selected = item.isSelected;
    if (item.shouldUseSelectedOptionTitle) {
        NSAttributedString *selectedTitle;
        if ([self.delegate respondsToSelector:@selector(categoryMenuBar:titleForSelectedOptions:atCategory:)]) {
            id title = [self.delegate categoryMenuBar:self titleForSelectedOptions:options atCategory:category];
            if ([title isKindOfClass:[NSString class]]) {
                selectedTitle = [[NSAttributedString alloc] initWithString:title attributes:item.titleAttributes];
            } else if ([title isKindOfClass:[NSAttributedString class]]) {
                selectedTitle = title;
            }
        } else {
            selectedTitle = [self firstSelectedTitleInCategory:category withSelectedOptions:options];
        }
        if (selectedTitle) {
            [button setAttributedTitle:selectedTitle forState:UIControlStateSelected];
            [button setAttributedTitle:selectedTitle forState:UIControlStateSelected | UIControlStateHighlighted];
        }
    }
    if (item.icon) {
        [button setImage:item.icon forState:UIControlStateNormal];
        [button setImage:item.selectedIcon forState:UIControlStateSelected];
        [self layoutBarItem:button space:item.iconTitleSpace];
    }
}

- (void)reloadItems {
    if (self.items.count != self.options.count) {
        NSAssert(NO, @"items数量要和options数量保持一致");
        return;
    }
    [self dismissOptionView:NO isCommit:self.isInCommiting];
    [self.barItemContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    UIButton *lastButton;
    for (NSInteger i = 0; i < self.items.count; i++) {
        TTCategoryMenuBarCategoryItem *item = self.items[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        [button addTarget:self action:@selector(categoryClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.barItemContainerView addSubview:button];
        [self updateItem:item atCategory:i];
        if (i != self.items.count - 1) {
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = item.separatorLineColor;
            [button addSubview:line];
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(button).inset(item.separatorLineIndent);
                make.right.equalTo(button);
                make.width.equalTo(@(1));
            }];
        }
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(lastButton ? lastButton.mas_right : self.barItemContainerView);
            make.top.bottom.equalTo(self.barItemContainerView);
            if (lastButton) {
                make.width.equalTo(lastButton);
            }
            if (i == self.items.count - 1) {
                make.right.equalTo(self.barItemContainerView);
            }
        }];
        if ([self.delegate respondsToSelector:@selector(categoryMenuBar:configButtonItem:atCategory:)]) {
            [self.delegate categoryMenuBar:self configButtonItem:button atCategory:i];
        }
        lastButton = button;
    }
}

- (void)categoryClicked:(UIButton *)button {
    [self categoryClicked:button fromTouch:YES];
}

- (void)categoryClicked:(UIButton *)button fromTouch:(BOOL)fromTouch {
    TTCategoryMenuBarCategoryItem *item = self.items[button.tag];
    BOOL isDimming = self.backgroundView.alpha == 1;
    BOOL isButtonSelected = button.isSelected;
    UIButton *currentButtonItem = self.currentButtonItem;
    [self dismissOptionView:(button == self.currentButtonItem || item.style == TTCategoryMenuBarCategoryStyleNoneData) isCommit:NO];

    if (item.style == TTCategoryMenuBarCategoryStyleNoneData) {
        if (button.isSelected) {
            button.selected = item.isSelected = NO;
            self.currentButtonItem = nil;
            if (fromTouch && [self.delegate respondsToSelector:@selector(categoryMenuBar:didDeSelectCategory:)]) {
                [self.delegate categoryMenuBar:self didDeSelectCategory:button.tag];
            }
        } else {
            button.selected = item.isSelected = YES;
            self.currentButtonItem = button;
            if (fromTouch && [self.delegate respondsToSelector:@selector(categoryMenuBar:didSelectCategory:)]) {
                [self.delegate categoryMenuBar:self didSelectCategory:button.tag];
            }
        }
    } else {
        if (button != currentButtonItem || !isButtonSelected) {
            button.selected = item.isSelected = YES;
            self.currentButtonItem = button;
            if (fromTouch && [self.delegate respondsToSelector:@selector(categoryMenuBar:didSelectCategory:)]) {
                [self.delegate categoryMenuBar:self didSelectCategory:button.tag];
            }
            if (item.style != TTCategoryMenuBarCategoryStyleNoneData) {
                // 如果之前有蒙层，接着使用之前的蒙层，避免突兀
                self.backgroundView.alpha = isDimming;
                [self showOptionView];
            }
        }
    }
}

- (void)showOptionViewAtCategory:(NSInteger)category {
    if (self.items.count > category) {
        UIButton *button = self.barItemContainerView.subviews[category];
        button.selected = NO;
        [self categoryClicked:button fromTouch:NO];
    }
}

- (void)dismissCurrentOptionView {
    if (self.currentButtonItem) {
        [self categoryClicked:self.currentButtonItem fromTouch:NO];
    }
}

- (void)showOptionView {
    TTCategoryMenuBarCategoryItem *item = self.items[self.currentButtonItem.tag];
    TTCategoryMenuBarOptionView *optionView;
    switch (item.style) {
        case TTCategoryMenuBarCategoryStyleSingleList:
            optionView = [[TTCategoryMenuBarSingleListOptionView alloc] initWithCategory:item options:self.options[self.currentButtonItem.tag]];
            break;
        case TTCategoryMenuBarCategoryStyleDoubleList:
            optionView = [[TTCategoryMenuBarDoubleListOptionView alloc] initWithCategory:item options:self.options[self.currentButtonItem.tag]];
            break;
        case TTCategoryMenuBarCategoryStyleTripleList:
            optionView = [[TTCategoryMenuBarTripleListOptionView alloc] initWithCategory:item options:self.options[self.currentButtonItem.tag]];
            break;
        case TTCategoryMenuBarCategoryStyleSectionList:
            optionView = [[TTCategoryMenuBarSectionListView alloc] initWithCategory:item options:self.options[self.currentButtonItem.tag]];
            break;
        case TTCategoryMenuBarCategoryStyleCustom:
            if ([self.delegate respondsToSelector:@selector(categoryMenuBar:optionViewAtIndex:)]) {
                optionView = [self.delegate categoryMenuBar:self optionViewAtIndex:self.currentButtonItem.tag];
            }
            break;
        default:
            break;
    }
    if (optionView) {
        [self loadBackgroundViewIfNeeded];
        self.currentOptionView = optionView;
        optionView.delegate = self;
//        [self insertSubview:self.backgroundView belowSubview:self.barItemContainerView];
        [self.backgroundView addSubview:optionView];
        // 把初始数据写入上次提交的数据
        [self setInitialDataToLastSubmitedOptionsIfNeeded:item];
        // 记录初始数据
        [self recordInitialDataIfNeeded:item];
        
        [optionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.barItemContainerView.mas_bottom);
            make.left.right.equalTo(self.backgroundView);
        }];
        
        if ([self.delegate respondsToSelector:@selector(categoryMenuBar:willShowOptionView:atCategory:)]) {
            [self.delegate categoryMenuBar:self willShowOptionView:optionView atCategory:self.currentButtonItem.tag];
        }
        [self layoutIfNeeded];
        
        [optionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.barItemContainerView.mas_bottom).offset(0);
            make.left.right.equalTo(self.backgroundView);
        }];
        
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:.25 animations:^{
            [self rotateItemIcon:self.currentButtonItem];
            self.backgroundView.alpha = 1;
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.userInteractionEnabled = YES;
        }];
    }
}

- (void)dismissOptionView:(BOOL)animated isCommit:(BOOL)isCommit {
    if (!self.currentOptionView || !self.currentOptionView.superview) {
        return;
    }
    NSInteger idx = [self.items indexOfObject:self.currentOptionView.categoryItem];
    if (idx != NSNotFound) {
        [self resetToLastSubmitedOptionsIfNeeded:idx isCommit:isCommit];
    }
    
    BOOL isSelected = (self.currentOptionView.selectedOptions.count > 0 && self.currentOptionView.categoryItem.hasSubmitData) || self.currentOptionView.categoryItem.style == TTCategoryMenuBarCategoryStyleNoneData ;
    self.currentOptionView.categoryItem.isSelected = isSelected;
    self.currentButtonItem.selected = isSelected;
    if (isSelected) {
        self.currentButtonItem.selected = YES;
    } else {
        if (self.currentOptionView.categoryItem.shouldUseSelectedTitleWhenUnselected && self.currentOptionView.categoryItem.hasSubmitData) {
            self.currentButtonItem.selected = YES;
        } else {
            self.currentButtonItem.selected = NO;
        }
    }
    [self layoutBarItem:self.currentButtonItem space:self.currentOptionView.categoryItem.iconTitleSpace];
    
    [self.currentOptionView clearSelectedOptions];
    [self.currentOptionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.barItemContainerView.mas_bottom).offset(-self.currentOptionView.frame.size.height);
    }];
    
    
    dispatch_block_t callDidDismiss = ^{
        NSInteger idx = [self.items indexOfObject:self.currentOptionView.categoryItem];
        if (idx != NSNotFound) {
            if ([self.delegate respondsToSelector:@selector(categoryMenuBar:didDismissOptionView:atCategory:isCommit:)]) {
                [self.delegate categoryMenuBar:self didDismissOptionView:self.currentOptionView atCategory:idx isCommit:isCommit];
            }
        }
    };
    
    if (animated) {
        self.userInteractionEnabled = NO;
        [UIView animateWithDuration:.25 animations:^{
            self.backgroundView.alpha = 0;
            [self layoutIfNeeded];
            [self resetItemIcon:self.currentButtonItem];
        } completion:^(BOOL finished) {
            self.currentButtonItem = nil;
            self.userInteractionEnabled = YES;
            callDidDismiss();
            [self.currentOptionView removeFromSuperview];
        }];
    } else {
        [self resetItemIcon:self.currentButtonItem];
        callDidDismiss();
        [self.currentOptionView removeFromSuperview];
        self.backgroundView.alpha = 0;
        self.currentButtonItem = nil;
    }
}

- (UIButton *)menuButtonItemAtCategory:(NSInteger)category {
    if (self.barItemContainerView.subviews.count > category) {
        return self.barItemContainerView.subviews[category];
    }
    return nil;
}

- (void)resetItemIcon:(UIButton *)button {
    if (self.items[button.tag].shouldIconAutoRotate) {
        button.imageView.transform = CGAffineTransformIdentity;
    }
}

- (void)rotateItemIcon:(UIButton *)button {
    if (self.items[button.tag].shouldIconAutoRotate) {
        button.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
}

- (void)categoryBarOptionViewDidResetOptions:(__kindof TTCategoryMenuBarOptionView *)categoryBarOptionView {
    NSInteger idx = [self.items indexOfObject:categoryBarOptionView.categoryItem];
    // 重置完之后，optionView里的options是深拷贝生成的新的数组，需要替换掉self.options，保持两个地方是同一份数据，避免改了一个地方，另一个地方不生效
    if (idx != NSNotFound && categoryBarOptionView.options != self.options[idx]) {
        NSMutableArray *newOptionsArray = self.options.mutableCopy;
        NSArray *newOptions = categoryBarOptionView.options;
        [newOptionsArray replaceObjectAtIndex:idx withObject:newOptions];
        self.options = newOptionsArray.copy;
    }
    if ([self.delegate respondsToSelector:@selector(categoryMenuBar:didResetCategory:)]) {
        [self.delegate categoryMenuBar:self didResetCategory:self.currentButtonItem.tag];
    }
}

- (void)categoryBarOptionView:(__kindof TTCategoryMenuBarOptionView *)categoryBarOptionView
             didCommitOptions:(NSArray<TTCategoryMenuBarOptionItem *> *)options {
    
    // 不论关闭弹窗时需要还原，还是点击重置按钮时需要还原，都需要记录提交的数据
    if (categoryBarOptionView.categoryItem.shouldResetToLastSubmitWhenDismiss
        || categoryBarOptionView.categoryItem.resetStyle == TTCategoryMenuBarCategoryResetToLastCommit) {
        // 使用深拷贝
        categoryBarOptionView.categoryItem.lastSubmitedOptions = [TTCategoryMenuBarOptionItem deepCopyOptions:categoryBarOptionView.options];
    }
    
    self.isInCommiting = YES;
    if ([self.delegate respondsToSelector:@selector(categoryMenuBar:didCommitCategoryOptions:atCategory:)]) {
        [self.delegate categoryMenuBar:self didCommitCategoryOptions:options atCategory:self.currentButtonItem.tag];
    }
    if (options.count > 0) {
        categoryBarOptionView.categoryItem.hasSubmitData = YES;
    }
    [self dismissOptionView:YES isCommit:YES];
    
    self.isInCommiting = NO;
}

- (void)categoryBarOptionView:(TTCategoryMenuBarOptionView *)optionView selectedOptionsDidChange:(NSArray *)selectedOptions {
    if (self.currentButtonItem) {
        TTCategoryMenuBarCategoryItem *item = self.items[self.currentButtonItem.tag];
        [self updateItem:item atCategory:self.currentButtonItem.tag selectedOptions:selectedOptions];
    }
   
    if ([self.delegate respondsToSelector:@selector(categoryMenuBar:optionView:selectedOptionsDidChange:)]) {
        [self.delegate categoryMenuBar:self optionView:optionView selectedOptionsDidChange:selectedOptions];
    }
}

- (void)categoryBarOptionView:(TTCategoryMenuBarOptionView *)optionView didSelectAtSection:(NSInteger)section index:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(categoryMenuBar:didSelectAtSection:index:atCategory:)]) {
        [self.delegate categoryMenuBar:self didSelectAtSection:section index:index atCategory:self.currentButtonItem.tag];
    }
}

- (void)categoryBarOptionView:(TTCategoryMenuBarOptionView *)optionView didDeselectAtSection:(NSInteger)section index:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(categoryMenuBar:didDeselectAtSection:index:atCategory:)]) {
        [self.delegate categoryMenuBar:self didDeselectAtSection:section index:index atCategory:self.currentButtonItem.tag];
    }
}

- (NSAttributedString *)firstSelectedTitleInCategory:(NSInteger)index withSelectedOptions:(NSArray *)selectedOptions {
    if (index >= self.options.count) { return nil; }
    
    NSArray *options = selectedOptions ?: self.options[index];
    for (TTCategoryMenuBarOptionItem *child in options) {
        NSAttributedString *title = [self firstSelectedTitleInOption:child];
        if (title) {
            return title;
        }
    }
    return nil;
}

- (NSAttributedString *)firstSelectedTitleInOption:(TTCategoryMenuBarOptionItem *)item {
    BOOL(^isOptionSelected)(TTCategoryMenuBarOptionItem *) = ^BOOL(TTCategoryMenuBarOptionItem *item){
        if ([item respondsToSelector:@selector(isSelected)]) {
            return [(id)item isSelected];
        }
        return NO;
    };
    // 子选项全选，或者没有子选项并选中了自己
    if (item.isChildrenAllSelected || (!item.childOptions.count && isOptionSelected(item))) {
        return item.selectedAttributedTitle ?: [[NSAttributedString alloc] initWithString:item.title ?: @"" attributes:item.selectedTitleAttributes];
    }
    for (TTCategoryMenuBarOptionItem *child in item.childOptions) {
        NSAttributedString *title = [self firstSelectedTitleInOption:child];
        if (title) {
            return title;
        }
    }
    return nil;
}

- (void)setInitialDataToLastSubmitedOptionsIfNeeded:(TTCategoryMenuBarCategoryItem *)item {
    // 不需要在弹窗关闭时还原数据，就不用存储
    if (!item.shouldResetToLastSubmitWhenDismiss) {
        return;
    }
    // 已经记录过提交数据，不用存储
    if (item.lastSubmitedOptions) {
        return;
    }
    NSInteger idx = [self.items indexOfObject:item];
    if (idx == NSNotFound || idx >= self.options.count) {
        return;
    }
    NSArray *options = self.options[idx];
    item.lastSubmitedOptions = [TTCategoryMenuBarOptionItem deepCopyOptions:options];
}

- (void)recordInitialDataIfNeeded:(TTCategoryMenuBarCategoryItem *)item {
    if (item.resetStyle != TTCategoryMenuBarCategoryResetToInit) {
        return;
    }
    // 如果已经记录过了，就不再记录
    if (item.initializedOptions) {
        return;
    }
    NSInteger idx = [self.items indexOfObject:item];
    if (idx == NSNotFound || idx >= self.options.count) {
        return;
    }
    NSArray *options = self.options[idx];
    item.initializedOptions = [TTCategoryMenuBarOptionItem deepCopyOptions:options];
}

- (void)resetToLastSubmitedOptionsIfNeeded:(NSInteger)idx isCommit:(BOOL)isCommit {
    if (self.options.count > idx) {
        BOOL shouldResetToLastSubmit = self.currentOptionView.categoryItem.shouldResetToLastSubmitWhenDismiss
        && self.currentOptionView.categoryItem.lastSubmitedOptions;
        // 重置，把模型还原为上次提交时记录的模型
        if (!isCommit && shouldResetToLastSubmit) {
            NSMutableArray *newOptionsArray = self.options.mutableCopy;
            NSArray *newOptions = [TTCategoryMenuBarOptionItem deepCopyOptions:self.currentOptionView.categoryItem.lastSubmitedOptions];
            [newOptionsArray replaceObjectAtIndex:idx withObject:newOptions];
            self.options = newOptionsArray.copy;

            // 在隐藏的时候，不刷新列表，避免用户看到选项变动
            // 需要更新选项列表，是因为隐藏的时候，会根据列表的选中内容调整标题
            [self.currentOptionView updateOptions:newOptions needReloadData:YES];
        } else {
           // 如果有父选项打开了，但是没有选中任何子选项，把此父选项取消选中
            NSArray *options = self.options[idx];
            for (TTCategoryMenuBarOptionItem *option in options) {
                [option unselectedIfNoChildSelected];
            }
        }
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    [self.barItemContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(contentInset);
    }];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (_backgroundView.alpha) {
        if (CGRectContainsPoint(self.backgroundView.frame, point)) {
            return YES;
        }
    }
    return [super pointInside:point withEvent:event];
}

- (void)layoutBarItem:(UIButton *)button space:(CGFloat)space {
    CGSize imageSize = button.imageView.image.size;
    CGSize titleSize;
    if (button.titleLabel.attributedText) {
        titleSize = [button.titleLabel.attributedText size];
    } else {
        titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:button.titleLabel.font}];
    }

    CGFloat insetAmount = ABS(space / 2.0);
    if (space > 0) {
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -insetAmount, 0, insetAmount);
        button.titleEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, -insetAmount);
        button.contentEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, insetAmount);
    } else {
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageSize.width + insetAmount), 0, imageSize.width + insetAmount);
        button.imageEdgeInsets = UIEdgeInsetsMake(0, titleSize.width + insetAmount, 0, -(titleSize.width + insetAmount));
        button.contentEdgeInsets = UIEdgeInsetsMake(0, insetAmount, 0, insetAmount);
    }
}

- (void)loadBackgroundViewIfNeeded {
    UIView *containerView = self.optionViewContainerView ?: self;
    if (!self.backgroundView && self.superview) {
        self.backgroundView = [[TTCategoryMenuBarBackgroundView alloc] init];
        self.backgroundView.alpha = 0;
        __weak __typeof(self) weakSelf = self;
        self.backgroundView.tapedBlock = ^{
            [weakSelf dismissOptionView:YES isCommit:NO];
        };
        [containerView addSubview:self.backgroundView];
    }
    
    [self.backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.barItemContainerView.mas_bottom);
        make.left.right.equalTo(containerView);
        make.bottom.equalTo(self.optionViewContainerView ?: self.superview);
    }];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self intrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(TTCategoryMenuBarScreenWidth, TTCategoryMenuBarHeight);
}

@end
