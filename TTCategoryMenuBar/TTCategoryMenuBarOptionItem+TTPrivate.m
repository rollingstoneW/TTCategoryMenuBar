//
//  TTCategoryMenuBarOptionItem+TTPrivate.m
//  TTRabbit
//
//  Created by 滚石 on 2020/3/28.
//

#import "TTCategoryMenuBarOptionItem+TTPrivate.h"

@implementation TTCategoryMenuBarOptionItem (TTPrivate)

- (BOOL)hasSelectedChild {
    if (self.childOptions.count) {
        for (TTCategoryMenuBarOptionItem *child in self.childOptions) {
            if ([child isSelfSelected]) {
                return YES;
            }
            if ([child hasSelectedChild]) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)loadSelectedChild {
    if (self.childOptions.count) {
        for (TTCategoryMenuBarOptionItem *child in self.childOptions) {
            if ([child loadSelectedChild]) {
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

@end
