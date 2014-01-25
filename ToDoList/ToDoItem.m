//
//  ToDoItem.m
//  ToDoList
//
//  Created by Phil Wee on 1/25/14.
//  Copyright (c) 2014 Philster. All rights reserved.
//

#import "ToDoItem.h"

@implementation ToDoItem

- (id)initWithText:(NSString *)text {
    self = [super init];
    if (self) {
        self.text = text;
    }
    return self;
}

@end
