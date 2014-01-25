//
//  ToDoItem.h
//  ToDoList
//
//  Created by Phil Wee on 1/25/14.
//  Copyright (c) 2014 Philster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoItem : NSObject

@property (nonatomic, strong) NSString *text;

- (id)initWithText:(NSString *)text;

@end
