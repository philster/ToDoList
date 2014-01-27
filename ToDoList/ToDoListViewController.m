//
//  ToDoListViewController.m
//  ToDoList
//
//  Created by Phil Wee on 1/25/14.
//  Copyright (c) 2014 Philster. All rights reserved.
//

#import "ToDoListViewController.h"
#import "EditableCell.h"
#import "ToDoItem.h"

@interface ToDoListViewController ()

@property (nonatomic, strong) NSMutableArray *toDoItems;
@property (nonatomic, strong) UIBarButtonItem *tempLeftButtonItem;
@property (nonatomic, strong) UIBarButtonItem *tempRightButtonItem;

@end

@implementation ToDoListViewController

- (NSMutableArray *)toDoItems
{
    if (!_toDoItems) _toDoItems = [[NSMutableArray alloc] init];
    return _toDoItems;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.toDoItems = [[NSMutableArray alloc] initWithArray:[self loadData]];
        
        if (self.toDoItems.count < 1) {
            // create dummy todo list
            [self.toDoItems addObject:[[ToDoItem alloc] initWithText:@"Eat breakfast"]];
            [self.toDoItems addObject:[[ToDoItem alloc] initWithText:@"Go to the gym (yeah right)"]];
            [self.toDoItems addObject:[[ToDoItem alloc] initWithText:@"Pick up dry cleaning"]];
            [self.toDoItems addObject:[[ToDoItem alloc] initWithText:@"Multi \n line \n todo"]];
        }
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self setEditing:NO animated:YES];

    // Dismiss keyboard by touching background of UITableView
    // http://stackoverflow.com/questions/2321038/dismiss-keyboard-by-touching-background-of-uitableview
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
    
    self.title = @"To Do List";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    
    UINib *customNib = [UINib nibWithNibName:@"EditableCell" bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:@"MyEditableCell"];
}

#pragma mark - Dismiss keyboard

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.toDoItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MyEditableCell";
    EditableCell *cell = (EditableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    ToDoItem *toDoItem = self.toDoItems[indexPath.row];
    cell.toDoItemCell.text = toDoItem.text;
    cell.toDoItemCell.tag = indexPath.row;
    cell.toDoItemCell.delegate = self;
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self removeItemAtIndex:indexPath.row];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSObject *itemToMove = [self.toDoItems objectAtIndex:fromIndexPath.row];
    [self.toDoItems removeObjectAtIndex:fromIndexPath.row];
    [self.toDoItems insertObject:itemToMove atIndex:toIndexPath.row];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - Text view delegate methods

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return !self.isEditing;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // cache menu buttons
    self.tempLeftButtonItem = self.navigationItem.leftBarButtonItem;
    self.tempRightButtonItem = self.navigationItem.rightBarButtonItem;
    // create save & cancel buttons
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveItem:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelItem:)];
}

- (void)cancelItem:sender
{
    [self.view endEditing:YES];
}

- (void)saveItem:sender
{
    [self.view endEditing:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // restore cached menu buttons
    self.navigationItem.leftBarButtonItem = self.tempLeftButtonItem;
    self.navigationItem.rightBarButtonItem = self.tempRightButtonItem;
    
    // replace item
    ToDoItem *item = [[ToDoItem alloc] initWithText:textView.text];
    [self.toDoItems replaceObjectAtIndex:textView.tag withObject:item];
    // save data to user defaults
    [self saveData:self.toDoItems];
}

#pragma mark - Private methods

- (void)addItem:sender
{
    // create new item
    ToDoItem *item = [[ToDoItem alloc] init];
    [self.toDoItems insertObject:item atIndex:0];
    // refresh table view
    [self.tableView reloadData];
    // enter edit mode
    EditableCell *cell = (EditableCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.toDoItemCell becomeFirstResponder];
}

- (void)removeItemAtIndex:(NSUInteger)index
{
    [self.tableView beginUpdates];
    [self.toDoItems removeObjectAtIndex:index];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    // refresh table view
    [self.tableView reloadData];
    // save data to user defaults
    [self saveData:self.toDoItems];
}

- (NSArray *)loadData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *archiveArray = [userDefaults objectForKey:@"toDoItems"];

    NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:archiveArray.count];
    for (NSData *archive in archiveArray) {
        ToDoItem *item = [[ToDoItem alloc] initWithText:[NSKeyedUnarchiver unarchiveObjectWithData:archive]];
        [itemArray addObject:item];
    }
    
    return itemArray;
}

- (void)saveData:(NSArray *)items
{
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:items.count];
    for (ToDoItem *item in items) {
        NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:item.text];
        [archiveArray addObject:archive];
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:archiveArray forKey:@"toDoItems"];
    [userDefaults synchronize];
}


@end
