//
//  TTCategoryMenuBarOptionItem+TTPrivate.m
//  TTRabbit
//
//  Created by 滚石 on 2020/3/28.
//

#import "TTCategoryMenuBarOptionItem+TTPrivate.h"
#import <objc/runtime.h>

#if __has_include(<YYModel/NSObject+YYModel.h>)
#import <YYModel/NSObject+YYModel.h>
#elif __has_include(<YYKit/NSObject+YYModel.h>)
#import <YYKit/NSObject+YYModel.h>
#endif

@implementation TTCategoryMenuBarOptionItem (TTPrivate)

- (BOOL)hasSelectedChild {
    if (self.childOptions.count) {
        for (TTCategoryMenuBarOptionItem *child in self.childOptions) {
            if (child.childOptions.count == 0) {
                // 没有子列表，看自己有没有选中
                if ([child isSelfSelected]) {
                    return YES;
                }
            } else {
                // 如果有子列表，看子列表有没有选中
                if ([child hasSelectedChild]) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (BOOL)loadSelectedChild {
    if (self.childOptions.count) {
        for (TTCategoryMenuBarOptionItem *child in self.childOptions) {
            if ([child loadSelectedChild] && ![self.selectedChildOptions containsObject:child]) {
                [self.selectedChildOptions addObject:child];
            }
        }
        return self.selectedChildOptions.count;
    } else {
        return [self isSelfSelected];
    }
}

- (BOOL)isSelfSelected {
    if ([self respondsToSelector:@selector(isSelected)]) {
        return [(id)self isSelected];
    }
    return NO;
}

- (void)clearSelectedChildren {
    [self.selectedChildOptions removeAllObjects];
    self.selectedChildOptions = nil;
    for (TTCategoryMenuBarOptionItem *child in self.childOptions) {
        [child clearSelectedChildren];
    }
}

- (void)selectChild:(TTCategoryMenuBarOptionItem *)child {
    if (!child || ![self.childOptions containsObject:child] || [self.selectedChildOptions containsObject:child]) {
        return;
    }
    // 选项列表
    if ([child isKindOfClass:[TTCategoryMenuBarListOptionItem class]]) {
        TTCategoryMenuBarListOptionItem *listItem = (TTCategoryMenuBarListOptionItem *)child;
        if (listItem.isSelectAll) {
            [self selectAllChild:listItem];
        } else {
            listItem.isSelected = YES;
            [self.selectedChildOptions addObject:listItem];
            if (self.selectedChildOptions.count == self.childOptions.count) {
                [self selectAllChild:nil];
            }
        }
    } else if ([child isKindOfClass:[TTCategoryMenuBarSectionOptionItem class]]) {
        TTCategoryMenuBarSectionOptionItem *sectionItem = (TTCategoryMenuBarSectionOptionItem *)child;
        if (sectionItem.isSelectAll) {
            [self selectAllChild:sectionItem];
        } else {
            sectionItem.isSelected = YES;
            [self.selectedChildOptions addObject:sectionItem];
            // 设置子选项是否全部选中
            if (self.selectedChildOptions.count == self.childOptions.count) {
                [self selectAllChild:nil];
            }
        }
    }
}

- (void)selectAllChild:(TTCategoryMenuBarOptionItem *)selectAllItem {
    selectAllItem = selectAllItem ?: [self _selectAllItem];
    
    if ([self _unselectedOthersWhenSelected:selectAllItem]) {
        for (TTCategoryMenuBarOptionItem *selectedItem in self.selectedChildOptions) {
            [selectedItem reset];
        }
        [self.selectedChildOptions removeAllObjects];
        [selectAllItem _setIsSelected:YES];
        [self.selectedChildOptions addObject:selectAllItem];
    } else if (self.childOptions.count) {
        for (TTCategoryMenuBarOptionItem *item in self.childOptions) {
            if (![self.selectedChildOptions containsObject:item]) {
                [item _setIsSelected:YES];
                [self.selectedChildOptions addObject:item];
            }
        }
    }
    self.isChildrenAllSelected = YES;
}

- (void)unselectedIfNoChildSelected {
    if (self.childOptions.count > 0 && ![self hasSelectedChild] && self.isSelfSelected) {
        [self _setIsSelected:NO];
        for (TTCategoryMenuBarOptionItem *child in self.childOptions) {
            [child unselectedIfNoChildSelected];
        }
    }
}

- (BOOL)_unselectedOthersWhenSelected:(TTCategoryMenuBarOptionItem *)selectAllItem {
    if ([selectAllItem isKindOfClass:[TTCategoryMenuBarListOptionItem class]]) {
        return [(TTCategoryMenuBarListOptionItem *)self unselectsOthersWhenSelected];
    } else if ([self isKindOfClass:[TTCategoryMenuBarSectionItem class]]) {
        return [(TTCategoryMenuBarSectionItem *)self unselectsOthersWhenSelectAll];
    }
    return NO;
}

- (void)_setIsSelected:(BOOL)isSelected {
    if ([self respondsToSelector:@selector(setIsSelected:)]) {
        [(id)self setIsSelected:isSelected];
    }
}

- (TTCategoryMenuBarOptionItem *)_selectAllItem {
    for (TTCategoryMenuBarOptionItem *item in self.childOptions) {
        if ([item respondsToSelector:@selector(isSelectAll)]) {
            if ([(id)item isSelectAll]) {
                return item;
            }
        }
    }
    return nil;
}

- (void)reset {
    [self resetFrom:nil];
}

- (void)resetFrom:(TTCategoryMenuBarOptionItem *)item {
    // 如果选中的数据和自己相同，则不取消自己的选中状态
    if ((item.relatedItem && item.relatedItem == self) || (self.relatedItem && self.relatedItem == item)) {
        return;
    }
    if ([self respondsToSelector:@selector(setIsSelected:)]) {
        [(id)self setIsSelected:NO];
    }
    self.isChildrenAllSelected = NO;
    [self.selectedChildOptions removeAllObjects];
    for (TTCategoryMenuBarOptionItem *child in self.childOptions) {
        [child resetFrom:item];
    }
}

- (instancetype)deepCopy {
#if __has_include(<YYModel/NSObject+YYModel.h>)
    TTCategoryMenuBarOptionItem *copyItem = [self yy_modelCopy];
#elif __has_include(<YYKit/NSObject+YYModel.h>)
    TTCategoryMenuBarOptionItem *copyItem = [self modelCopy];
#endif
    if (copyItem.childOptions) {
        NSMutableArray *copyChildOptions = [NSMutableArray array];
        [self.childOptions enumerateObjectsUsingBlock:^(__kindof TTCategoryMenuBarOptionItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [copyChildOptions addObject:[obj deepCopy]];
        }];
        copyItem.childOptions = copyChildOptions.copy;
        
        // 如果有子选项，但是没有任何子选项被选中，就取消选中
        if (![copyItem hasSelectedChild] && copyItem.isSelfSelected) {
            [copyItem _setIsSelected:NO];
        }
//        NSLog(@"father_deep_copy_%@,selected:%ld", copyItem.title, copyItem.isSelfSelected);
    } else {
//        NSLog(@"child_deep_copy_%@,selected:%ld", copyItem.title, copyItem.isSelfSelected);
    }
    return copyItem;
}

+ (NSArray<TTCategoryMenuBarOptionItem *> *)deepCopyOptions:(NSArray<TTCategoryMenuBarOptionItem *> *)options {
    if (!options) {
        return nil;
    }
    NSMutableArray *copyOptions = [NSMutableArray array];
    [options enumerateObjectsUsingBlock:^(TTCategoryMenuBarOptionItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [copyOptions addObject:[obj deepCopy]];
    }];
    return copyOptions.copy;
}

@end

@implementation TTCategoryMenuBarCategoryItem (TTPrivate)

- (NSArray<TTCategoryMenuBarOptionItem *> *)lastSubmitedOptions {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setLastSubmitedOptions:(NSArray<TTCategoryMenuBarOptionItem *> *)lastSubmitedOptions {
    objc_setAssociatedObject(self, @selector(lastSubmitedOptions), lastSubmitedOptions, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
