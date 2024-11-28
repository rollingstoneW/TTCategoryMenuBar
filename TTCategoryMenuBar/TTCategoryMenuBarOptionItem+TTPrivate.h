//
//  TTCategoryMenuBarOptionItem+TTPrivate.h
//  TTRabbit
//
//  Created by 滚石 on 2020/3/28.
//

#import "TTCategoryMenuItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTCategoryMenuBarOptionItem (TTPrivate)

// 是否有子选项选中了
- (BOOL)hasSelectedChild;

// 是否被选中了
- (BOOL)isSelfSelected;

// 加载selectedChildOptions，在TTCategoryMenuBarOptionView外部调用此方法，后面一定要调用clearSelectedChildren
- (BOOL)loadSelectedChild;

// 清理selectedChildOptions
- (void)clearSelectedChildren;

// 选中子选项，会自动处理子选项间的互斥关系，自动处理子选项是否全选
- (void)selectChild:(TTCategoryMenuBarOptionItem *)child;
// 全选子选项
- (void)selectAllChild:(TTCategoryMenuBarOptionItem *)selectedAllItem;

// 如果有子选项，但是没有任何子选项被选中，就取消选中
- (void)unselectedIfNoChildSelected;

// 重置
- (void)reset;
- (void)resetFrom:(TTCategoryMenuBarOptionItem *)item;

- (instancetype)deepCopy;

+ (NSArray<TTCategoryMenuBarOptionItem *> *)deepCopyOptions:(NSArray<TTCategoryMenuBarOptionItem *> *)options;

@end

@interface TTCategoryMenuBarCategoryItem (TTPrivate)

@property (nonatomic, strong, nullable) NSArray<TTCategoryMenuBarOptionItem *> *lastSubmitedOptions;

@property (nonatomic, strong, nullable) NSArray<TTCategoryMenuBarOptionItem *> *initializedOptions;

@end

NS_ASSUME_NONNULL_END
