//
//  Shop.h
//  To4ka.2
//
//  Created by Air on 03.02.15.
//  Copyright (c) 2015 Bogdanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Employee;

@interface Shop : NSManagedObject

@property (nonatomic, retain) NSString * shopEmail;
@property (nonatomic, retain) NSString * shopName;
@property (nonatomic, retain) NSString * shopNote;
@property (nonatomic, retain) NSString * shopPhoneNumber;
@property (nonatomic, retain) NSString * shopSecondPhoneNumber;
@property (nonatomic, retain) NSSet *employee;
@end

@interface Shop (CoreDataGeneratedAccessors)

- (void)addEmployeeObject:(Employee *)value;
- (void)removeEmployeeObject:(Employee *)value;
- (void)addEmployee:(NSSet *)values;
- (void)removeEmployee:(NSSet *)values;

@end
