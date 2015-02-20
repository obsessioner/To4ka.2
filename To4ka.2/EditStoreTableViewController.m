//
//  EditStoreTableViewController.m
//  To4ka.2
//
//  Created by Air on 23.01.15.
//  Copyright (c) 2015 Bogdanov. All rights reserved.
//

#import "EditStoreTableViewController.h"
#import "StoreTableViewController.h"
#include <QuartzCore/QuartzCore.h>


@import AddressBook;

@interface EditStoreTableViewController () <UITextFieldDelegate>

@end

@implementation EditStoreTableViewController

@synthesize editStore;
@synthesize hideSecondPhoneSection;


-(void)viewDidLoad {
    
    [super viewDidLoad];
    
// [Get permission to access the AddressBook ...
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(nil, nil);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (!granted) {
                return;
            }
        });
    }
    CFRelease (addressBookRef);
//  ...Get permission to access the AddressBook]
    
    if ([_storeSecondPhoneNumber.text = editStore.storeSecondPhoneNumber length] == 0){
        hideSecondPhoneSection = YES;
    } else{
        hideSecondPhoneSection = NO;
    };
    
    for (UITextField *anyTextField in self.arreyTextField) {
        anyTextField.delegate = self;
    }
    
    _storeName.enabled = NO;
    _storePhoneNumber.enabled = NO;
    _storeSecondPhoneNumber.enabled = NO;
    _storeEmail.enabled = NO;
    _storeNoteView.editable = NO;
    
    self.addSecondStorePhoneNumberButtone.hidden = YES;
    
    _storeName.borderStyle = UITextBorderStyleNone;
    _storePhoneNumber.borderStyle = UITextBorderStyleNone;
    _storeSecondPhoneNumber.borderStyle = UITextBorderStyleNone;
    _storeEmail.borderStyle = UITextBorderStyleNone;
    
    _storeName.text = editStore.storeName;
    _storePhoneNumber.text = editStore.storePhoneNumber;
    _storeSecondPhoneNumber.text = editStore.storeSecondPhoneNumber;
    _storeEmail.text = editStore.storeEmail;
    _storeNoteView.text = editStore.storeNote;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - AddressBook Button AddStoreAddressBook

-(void)cantAddContactAlert{
    
    UIAlertView *cantAddContactAlert = [[UIAlertView alloc]
                                        initWithTitle: @"Cannot Add Contact"
                                        message: @"You must give the app permission to add the contact first."
                                        delegate:nil
                                        cancelButtonTitle: @"OK"
                                        otherButtonTitles: nil];
    [cantAddContactAlert show];
}

-(void)addToPhoneBook {
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted){
        //1 This checks to see if the user has either denied your app access to the AddressBook in the past, or it is restricted because of parental controls. In this case, all you can do is inform the user that you can’t add the contact because the app does not have permission.
        [self cantAddContactAlert];
        NSLog(@"Permission AddressBook Denied");
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        //2 This checks to see if the user has already given your app permission to use their AddressBook. In this case, you are free to modify the AddressBook however you want.
        [self createGroupAddressBook];
        [self addStoreToContacts];
        NSLog(@"Permission AddressBook Authorized");
    }
    else{ //ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined
        //3 This checks to see if the user hasn’t decided yet whether not to give permission to your app.
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            if (!granted){
                //4 executes only if the user denies permission when your app asks.
                [self cantAddContactAlert];
                // NSLog(@"Just denied");
                return;
            }
            //5 executes if the user gives permission for you to use the AddressBook.
            NSLog(@"Just Authorized AddressBook");
        });
        NSLog(@"Not Determined AddressBook");
    }
}

#pragma mark -
#pragma mark - AddressBook Create Group Phone Book


-(void)createGroupAddressBook {
    
    NSString *newGroupName = @"To4ka";
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    if (addressBook){
        BOOL groupNameIsEqual = NO;
        
        CFArrayRef allGroups = ABAddressBookCopyArrayOfAllGroups(addressBook);
        if (allGroups){
            for (int index=0; index<CFArrayGetCount(allGroups); index++){
                ABRecordRef group = CFArrayGetValueAtIndex(allGroups, index);
                NSString *groupName = (__bridge NSString *)ABRecordCopyValue(group,
                                                                             kABGroupNameProperty);
                
                if ([groupName isEqualToString:newGroupName]) {
                    groupNameIsEqual = YES;
                    break;
                }
            }
        }
        CFRelease(allGroups);
        
        if (groupNameIsEqual) {
            NSLog(@"This Group in AddressBook Already Exists");
        }
        else {
            ABRecordRef group = ABGroupCreate();
            if (!group){
                NSLog(@"Error Creating Group in AddressBook");
                return;
            }
            
            CFErrorRef error = nil;
            BOOL couldSetGroupName = ABRecordSetValue(group,
                                                      kABGroupNameProperty,
                                                      (__bridge CFStringRef)newGroupName,
                                                      &error);
            if (couldSetGroupName){
                if (ABAddressBookAddRecord(addressBook, group, &error)){
                    NSLog(@"New Group in AddressBook Added");
                    [self saveAddressBook:addressBook];
                } else {
                    NSLog(@"Unable Add New Group in AddressBook");
                }
            }
            else {
                NSLog(@"Error Installing Name Group");
            }
        }
        CFRelease(addressBook);
    }
}

#pragma mark -
#pragma mark - AddressBook Store Info For Phone Book


-(void)addStoreToContacts {
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    if (addressBook) {
        
        NSString *phone = _storePhoneNumber.text;
        NSString *store = _storeName.text;
        NSString *note = _storeNoteView.text;
        NSString *secondPhone = _storeSecondPhoneNumber.text;
        NSString *email = _storeEmail.text;
        
        ABRecordRef person = ABPersonCreate();
        if (!person) {
            NSLog(@"Can Not Create Store");
            return;
        }
        
        CFErrorRef error = nil;
        
        
        BOOL couldSetCompanyName = ABRecordSetValue(person,
                                                    kABPersonOrganizationProperty,
                                                    (__bridge CFStringRef) store,
                                                    &error);
        BOOL couldSetNotes = ABRecordSetValue(person,
                                              kABPersonNoteProperty,
                                              (__bridge CFStringRef) note,
                                              &error);
        
        
        ABMutableMultiValueRef emailSet = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel (emailSet,
                                      (__bridge CFStringRef) email,
                                      kABWorkLabel,
                                      NULL);
        ABRecordSetValue(person, kABPersonEmailProperty, emailSet, nil);
        CFRelease(emailSet);
        
        ABMutableMultiValueRef phones = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(phones,
                                     (__bridge CFStringRef)phone,
                                     kABPersonPhoneMainLabel,
                                     NULL);
        ABMultiValueAddValueAndLabel(phones,
                                     (__bridge CFStringRef)secondPhone,
                                     kABPersonPhoneMobileLabel,
                                     NULL);
        
        BOOL couldSetPhoneNumber = ABRecordSetValue(person,
                                                    kABPersonPhoneProperty,
                                                    phones,
                                                    &error);
        CFRelease(phones);
        
        if (couldSetCompanyName && couldSetPhoneNumber && couldSetNotes && emailSet) {
            NSLog(@"Connection Whith AddressBook");
        }
        
        if (ABAddressBookAddRecord(addressBook, person, &error)) {
            NSLog(@"Store Added To AddressBook");
        }
        
        [self saveAddressBook:addressBook];
        
        //Add to Group
        CFArrayRef allGroups = ABAddressBookCopyArrayOfAllGroups(addressBook);
        if (allGroups){
            for (int index=0; index<CFArrayGetCount(allGroups); index++){
                ABRecordRef group = CFArrayGetValueAtIndex(allGroups, index);
                NSString *groupName = (__bridge NSString *)
                ABRecordCopyValue(group, kABGroupNameProperty);
                
                if ([groupName isEqualToString:@"To4ka"]) {
                    if (ABGroupAddMember(group, person, &error)) {
                        
                        NSLog(@"Store Added To Group");
                    }
                    else {
                        NSLog(@"Failed! Store Failed Add To Group");
                    }
                    break;
                }
            }
        }
        CFRelease(allGroups);
        [self saveGroupAddressBook:addressBook];
        //Adding In Group
        CFRelease(addressBook);
    }
}

#pragma mark -
#pragma mark - AddressBook Save Method To Phone Book Group & Person


-(void)saveAddressBook:(ABAddressBookRef)addressBook {
    
    if (ABAddressBookHasUnsavedChanges(addressBook)) {
        CFErrorRef error = nil;
        if (ABAddressBookSave(addressBook, &error)){
            
            NSLog(@"Store Saved To AddressBook");
        }
        else {
            UIAlertView *cantDisAddContactAlert = [[UIAlertView alloc]
                                                   initWithTitle: @"Sorry"
                                                   message: @"Can Not Add Store To AddressBook"
                                                   delegate:nil
                                                   cancelButtonTitle: @"OK"
                                                   otherButtonTitles: nil];
            [cantDisAddContactAlert show];
        }
    }
}

-(void)saveGroupAddressBook:(ABAddressBookRef)addressBook {
    
    if (ABAddressBookHasUnsavedChanges(addressBook)) {
        CFErrorRef error = nil;
        
        if (ABAddressBookSave(addressBook, &error)){
            NSLog(@"Store in Group Added To AddressBook");
        }
        else {
            NSLog(@"Can Not Add Store in Group To AddressBook");
        }
    }
}

#pragma mark -
#pragma mark - Hiden Second Phone Number Section


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 2 && hideSecondPhoneSection) {
        return 0;
    }
    else {
        return [super tableView:tableView heightForHeaderInSection:section];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 2 && hideSecondPhoneSection) {
        cell.hidden = YES;
        return 0;
    }
    else {
        cell.hidden = NO;
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

#pragma mark -
#pragma mark - Button Add Second Phone Number Button


- (IBAction)addSecondPhoneNumber:(id)sender {
    
    hideSecondPhoneSection = NO;
    [self.tableView reloadData];
    [self.storeSecondPhoneNumber becomeFirstResponder];
    self.addSecondStorePhoneNumberButtone.hidden = YES;
}

#pragma mark -
#pragma mark - Check Text Field for Validation Email


-(BOOL)checkEmailTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet *validation = [NSCharacterSet characterSetWithCharactersInString:@"?±~!#$%^,/|&*()<>=+{}][:;'\" \\"];
    NSArray * components = [string componentsSeparatedByCharactersInSet:validation];
    
    if ([components count] > 1) {
        return NO;
    }
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (([newString rangeOfString:@"@"].length) < 1) {
        self.atPresent = NO;
    }
    if ([newString length] < 2 && [string isEqualToString:@"@"]) {
        return NO;
    }
    if ([newString length] > 30) {
        return NO;
    }
    if (self.atPresent && [string isEqualToString:@"@"]) {
        return NO;
    }
    if ([string isEqualToString:@"@"]) {
        self.atPresent = YES;
    }
    textField.text = newString;
    return NO;
}

#pragma mark -
#pragma mark - Check Text Field for Validation Phone


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    BOOL yesOrNot = TRUE;
    if ([textField isEqual:self.storePhoneNumber]) {
        yesOrNot = [self checkPhoneTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    if ([textField isEqual:self.storeSecondPhoneNumber]) {
        yesOrNot = [self checkPhoneTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    if ([textField isEqual:self.storeEmail]) {
        yesOrNot = [self checkEmailTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    return yesOrNot;
}

#pragma mark -
#pragma mark - UITextFieldDelegate Phone Number


-(BOOL)checkPhoneTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet* validationSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSArray* components = [string componentsSeparatedByCharactersInSet:validationSet];
    
    if ([components count] > 1) {
        return NO;
    }
    NSString* newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray* validComponents = [newString componentsSeparatedByCharactersInSet:validationSet];
    newString = [validComponents componentsJoinedByString:@""];
    NSMutableString* resultString = [NSMutableString string];
    
    static const int localNumberMaxLenght = 7;
    static const int areaCodeMaxLenght = 3;
    static const int countryMaxLenght = 2;
    
    if ([newString length] > localNumberMaxLenght + areaCodeMaxLenght + countryMaxLenght) {
        return NO;
    }
    
    NSInteger localNumberLenght = MIN([newString length], localNumberMaxLenght);
    
    if (localNumberLenght > 0) {
        
        NSString* number = [newString substringFromIndex:(int)[newString length] - localNumberLenght];
        
        [resultString appendString:number];
        
        if ([resultString length] > 3) {
            [resultString insertString:@"-" atIndex:3];
        }
    }
    if ([newString length] > localNumberMaxLenght) {
        
        NSInteger areaCodeLenght = MIN((int)[newString length] - localNumberMaxLenght, areaCodeMaxLenght);
        NSRange areaRange = NSMakeRange((int)[newString length] - localNumberMaxLenght - areaCodeLenght, areaCodeLenght);
        NSString* area = [newString substringWithRange:areaRange];
        area = [NSString stringWithFormat:@"(%@) ", area];
        [resultString insertString:area atIndex:0];
        
    }
    if ([newString length] > localNumberMaxLenght + areaCodeMaxLenght) {
        
        NSInteger countryCodeLenght = MIN((int)[newString length] - localNumberMaxLenght - areaCodeMaxLenght, countryMaxLenght);
        
        NSRange countryCodeRange = NSMakeRange(0, countryCodeLenght);
        
        NSString* countryCode = [newString substringWithRange:countryCodeRange];
        
        countryCode = [NSString stringWithFormat:@"+%@ ", countryCode];
        [resultString insertString:countryCode atIndex:0];
    }
    textField.text = resultString;
    return NO;
}

#pragma mark -
#pragma mark - Return key


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:self.storeName]) {
        [self.storePhoneNumber becomeFirstResponder];
    }
    if ((self.hideSecondPhoneSection == YES) &&
        ([textField isEqual:self.storePhoneNumber])){
        [self.storeEmail becomeFirstResponder];
    }
    else if ((self.hideSecondPhoneSection == NO) &&
             ([textField isEqual:self.storePhoneNumber])){
        [self.storeSecondPhoneNumber becomeFirstResponder];
    }
    if ([textField isEqual:self.storeSecondPhoneNumber]) {
        [self.storeEmail becomeFirstResponder];
    }
    if ([textField isEqual:self.storeEmail]) {
        [self.storeNoteView becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark -
#pragma mark - Check For Same Store & PhoneNumber Length For AddressBook


-(void)checkStorePhoneNumber{
        
        if (!([_storePhoneNumber.text length] > 0 || [_storeSecondPhoneNumber.text length] > 0)) {
            NSLog(@"Empty Phone Number");
        }
        else {
            
            [self addToPhoneBook];
        }
    }

-(NSManagedObjectContext*) managedObjectContext {
    return [(AppDelegate*)[[UIApplication sharedApplication]delegate]managedObjectContext];
}

-(BOOL)uniqueEntityExistsWithEnityName {
    
    BOOL returnValue = NO;
    
//    editStore.storeName = _storeName.text;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Store"];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"storeName = [cd] %@",_storeName.text];
    
//    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"storeName = [cd] %@ AND storePhoneNumber = [cd] %@ AND storeSecondPhoneNumber = [cd] %@ AND storeEmail = [cd] %@ AND storeNote = [cd] %@",_storeName.text, _storePhoneNumber.text, _storeSecondPhoneNumber.text, _storeEmail.text, _storeNoteView.text];
    
    NSSortDescriptor *store = [[NSSortDescriptor alloc] initWithKey:@"storeName" ascending:YES];
    
    [request setSortDescriptors: @[store]];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *matches = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    NSLog(@"request = %@",predicate);
    
    if (!matches) {
        NSLog(@"Error: Couldn't execute fetch request %@", error);
    }
    else if([matches count] > 1) {
        
        NSString *existStore = [NSString stringWithFormat:@"Could Be Only One %@ Store", _storeName.text];
        
        UIAlertView *exist = [[UIAlertView alloc]initWithTitle:@"Store Exists in Your Records"
                                                       message:existStore
                                                      delegate:nil
                                             cancelButtonTitle:@"Ok"
                                             otherButtonTitles:nil];
        [exist show];
        
        NSLog(@"Error: Have more than %lu records",
              (unsigned long)[matches count]);
        returnValue = YES;
    }
    else {
        
        NSLog(@"%lu object in record", (unsigned long)[matches count]);
        
        [self oldStoreDelete];
        
        [self checkStorePhoneNumber];
        
        editStore.storeName = _storeName.text;
        editStore.storePhoneNumber = _storePhoneNumber.text;
        editStore.storeSecondPhoneNumber = _storeSecondPhoneNumber.text;
        editStore.storeEmail = _storeEmail.text;
        editStore.storeNote = _storeNoteView.text;
        
        [super saveAndDissmiss];
        
        returnValue = YES;
    }
    return returnValue;
}

#pragma mark -
#pragma mark - oldStoreDelete

-(void)oldStoreDelete{
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    
    CFArrayRef groups = ABAddressBookCopyArrayOfAllGroups(addressBook);
    CFIndex numGroups = CFArrayGetCount(groups);
    for(CFIndex idx=0; idx<numGroups; ++idx) {
        
        ABRecordRef groupItem = CFArrayGetValueAtIndex(groups, idx);
        
        NSString *name = (__bridge NSString *)(ABRecordCopyValue(groupItem, kABGroupNameProperty));
        if ([name isEqualToString:@"To4ka"])
            
        {
            CFArrayRef members = ABGroupCopyArrayOfAllMembers(groupItem);
            if(members) {
                NSUInteger count = CFArrayGetCount(members);
                for(NSUInteger idx=0; idx<count; ++idx) {
                    
                    ABRecordRef person = CFArrayGetValueAtIndex(members, idx);
                    NSString *storeName = (__bridge NSString *)ABRecordCopyValue(person,
                                                                            kABPersonOrganizationProperty);
                    NSString *lookingStoreName = [NSString stringWithFormat:@"%@",editStore.storeName];
                    
                    if ([storeName isEqualToString:lookingStoreName]) {
                        ABAddressBookRemoveRecord(addressBook, person,nil);
                        NSLog(@"Delated");
                    }
                }
                CFRelease(members);
            }
        }
    }
    ABAddressBookSave(addressBook, nil);
    CFRelease(groups);
    CFRelease(addressBook);
}

#pragma mark -
#pragma mark - Cance And Save


-(IBAction)cancel:(UIBarButtonItem *)sender {
    [super cancelAndDismiss];
}

- (IBAction)editSave:(UIBarButtonItem *)sender {
    if ([_editSaveButton.title isEqualToString:@"Edit"]) {
        NSLog(@"Edit Button Has Been Pressed!");
        
        [self setTitle:@"Edit Store"];
        
        _storeName.enabled = YES;
        _storePhoneNumber.enabled = YES;
        _storeSecondPhoneNumber.enabled = YES;
        _storeEmail.enabled = YES;
        _storeNoteView.editable = YES;
        
        if (!([_storeSecondPhoneNumber.text = editStore.storeSecondPhoneNumber length] == 0)){
            self.addSecondStorePhoneNumberButtone.hidden = YES;
        } else{
            self.addSecondStorePhoneNumberButtone.hidden = NO;
        };

        [self.tableView reloadData];
        
        _storeName.borderStyle = UITextBorderStyleRoundedRect;
        _storePhoneNumber.borderStyle = UITextBorderStyleRoundedRect;
        _storeSecondPhoneNumber.borderStyle = UITextBorderStyleRoundedRect;
        _storeEmail.borderStyle = UITextBorderStyleRoundedRect;
        
        _editSaveButton.title = @"Save";
        
        [self textViewStyle];
    }
    else {
        
        _storeName.enabled = NO;
        _storePhoneNumber.enabled = NO;
        _storeSecondPhoneNumber.enabled = NO;
        _storeEmail.enabled = NO;
        _storeNoteView.editable = NO;
        
        _storeName.borderStyle = UITextBorderStyleNone;
        _storePhoneNumber.borderStyle = UITextBorderStyleNone;
        _storeSecondPhoneNumber.borderStyle = UITextBorderStyleNone;
        _storeEmail.borderStyle = UITextBorderStyleNone;
        
        _editSaveButton.title = @"Edit";
        
        if ([_storeName.text length] == 0)
        {
            UIAlertView *empty = [[UIAlertView alloc]initWithTitle:@"Fill Up The Form"
                                                           message:@""
                                                          delegate:nil
                                                 cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
            [empty show];
        }
        else {
            [self uniqueEntityExistsWithEnityName];
        }
    }
}

#pragma mark -
#pragma mark - TextView Style


-(void)textViewStyle{
    
    [[self.storeNoteView layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [[self.storeNoteView layer] setBorderWidth:.4];
    [[self.storeNoteView layer] setCornerRadius:8.0f];
}

@end