//
//  TTCategoryMenubarOptionButtonConfig.h
//  TTCategoryMenuBar
//
//  Created by ByteDance on 19/9/2024.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TTCategoryMenubarOptionButtonState) {
    TTCategoryMenubarOptionButtonStateNormal,
    TTCategoryMenubarOptionButtonStateHasSelectedItems,
};

typedef NS_ENUM(NSUInteger, TTCategoryMenubarOptionButtonStyle) {
    TTCategoryMenubarOptionButtonStyleReset,
    TTCategoryMenubarOptionButtonStyleDone,
};

// 重置类型
typedef NS_ENUM(NSUInteger, TTCategoryMenuBarCategoryResetStyle) {
    // 点击不重置
    TTCategoryMenuBarCategoryResetNone,
    // 点击重置全部，取消所有选中的选项
    TTCategoryMenuBarCategoryResetAll,
    // 点击重置到上一次提交时的数据
    TTCategoryMenuBarCategoryResetToLastCommit,
};

@interface TTCategoryMenubarOptionButtonBackgroundConfig : NSObject

// 背景颜色
@property (nonatomic, strong) UIColor *backgroundColor;
// 边界颜色
@property (nonatomic, strong) UIColor *borderColor;
// 边界线宽度
@property (nonatomic, assign) CGFloat borderWidth;
// 圆角
@property (nonatomic, assign) CGFloat cornerRadius;

@end

@interface TTCategoryMenubarOptionButtonTitleConfig : NSObject

// 标题，优先级最低
@property (nonatomic, copy) NSString *title;
// 标题格式，如果不为空，使用titleFormat和选择的选项个数生成字符串，例如 确定(查看%ld项)，优先级高于title
@property (nonatomic, copy) NSString *titleFormat;
// 根据选择的选项，自定义标题，优先级最高
@property (nonatomic, copy) NSAttributedString *(^customTitle)(NSInteger selectedCount);
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *titleFont;

@end

@interface TTCategoryMenubarOptionButtonIconConfig : NSObject

@property (nonatomic, copy) UIImage *image;

// 图标尺寸，如果为0, 0，则使用image自有尺寸
@property (nonatomic, assign) CGSize size;

// 图标是否在左边
@property (nonatomic, assign) BOOL isIconLeft;

// 图标和标题间距
@property (nonatomic, assign) CGFloat iconTitleGap;

@end


@interface TTCategoryMenubarOptionButtonConfig : NSObject

@property (nonatomic, assign) TTCategoryMenubarOptionButtonStyle style;

// 按钮高度，0为自适应高度
@property (nonatomic, assign) CGFloat height;
// 按钮宽度，0则自适应宽度，insetHorizontal和gap优先级高于宽度，如果宽度多与剩余宽度，则为剩余宽度。如果宽度少于剩余宽度，则忽略gap限制
@property (nonatomic, assign) CGFloat width;
// 按钮宽度占optionView比例，0则自适应宽度
@property (nonatomic, assign) CGFloat widthRatio;

@property (nonatomic, assign) TTCategoryMenuBarCategoryResetStyle resetStyle;

- (void)setBackgroundConfig:(TTCategoryMenubarOptionButtonBackgroundConfig *)config forState:(TTCategoryMenubarOptionButtonState)state;
- (TTCategoryMenubarOptionButtonBackgroundConfig *)backgroundConfigForState:(TTCategoryMenubarOptionButtonState)state;

- (void)setTitleConfig:(TTCategoryMenubarOptionButtonTitleConfig *)config forState:(TTCategoryMenubarOptionButtonState)state;
- (TTCategoryMenubarOptionButtonTitleConfig *)titleConfigForState:(TTCategoryMenubarOptionButtonState)state;

- (void)setIconConfig:(TTCategoryMenubarOptionButtonIconConfig *)config forState:(TTCategoryMenubarOptionButtonState)state;
- (TTCategoryMenubarOptionButtonIconConfig *)iconConfigForState:(TTCategoryMenubarOptionButtonState)state;

@end


@interface TTCategoryMenubarOptionButtonsConfig : NSObject

// 左右距离边界距离
@property (nonatomic, assign) CGFloat insetHorizontal;
// 按钮和按钮的距离
@property (nonatomic, assign) CGFloat buttonGap;
// 按钮顶部距离按钮容器距离
@property (nonatomic, assign) CGFloat buttonTop;
// 按钮底部距离按钮容器距离
@property (nonatomic, assign) CGFloat buttonBottom;
// 按钮容器顶部分割线颜色
@property (nonatomic, strong) UIColor *buttonContainerTopBorderColor;
// 按钮容器顶部分割线宽度
@property (nonatomic, assign) CGFloat buttonContainerTopBorderWidth;

// 没有东西选中时，是否需要禁用确定按钮
@property (nonatomic, assign) BOOL shouldDisableDoneButtonWhenEmpty;

@property (nonatomic, copy, readonly) NSArray<TTCategoryMenubarOptionButtonConfig *> *buttons;

- (void)setButtonConfig:(TTCategoryMenubarOptionButtonConfig *)config forStyle:(TTCategoryMenubarOptionButtonStyle)style;

- (TTCategoryMenubarOptionButtonConfig *)buttonConfigForStyle:(TTCategoryMenubarOptionButtonStyle)style;

+ (instancetype)defaultConfig;
+ (instancetype)onlyDoneConfig;

@end
