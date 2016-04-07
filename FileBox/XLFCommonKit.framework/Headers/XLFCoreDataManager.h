//
//  XLFCoreDataManager
//  XLFCommonKit
//
//  Created by Marike Jave on 14-9-4.
//  Copyright (c) 2014年 Marike Jave. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#define CoreDataName @"SystemDatabase";
/*!
 *@class XLFCoreDataManager
 *@super NSObject
 *@abstract coreDate数据操作单例
 */
@interface XLFCoreDataManager : NSObject{

@private

    NSMutableDictionary *myJidCache;

    int32_t pendingRequests;

    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
//    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectContext *mainThreadManagedObjectContext;

    NSMutableArray *willSaveManagedObjectContextBlocks;
    NSMutableArray *didSaveManagedObjectContextBlocks;

@protected

    NSString *databaseFileName;
    NSDictionary *storeOptions;
    NSUInteger saveThreshold;
    NSUInteger saveCount;

    BOOL autoRemovePreviousDatabaseFile;
    BOOL autoRecreateDatabaseFile;
    BOOL autoAllowExternalBinaryDataStorage;

    dispatch_queue_t storageQueue;
    void *storageQueueTag;
}

+ (instancetype)sharedInstance;

/**
 * Initializes a core data storage instance, backed by SQLite, with the given database store filename.
 * It is recommended your database filname use the "sqlite" file extension (e.g. "XMPPRoster.sqlite").
 * If you pass nil, a default database filename is automatically used.
 * This default is derived from the classname,
 * meaning subclasses will get a default database filename derived from the subclass classname.
 *
 * If you attempt to create an instance of this class with the same databaseFileName as another existing instance,
 * this method will return nil.
 **/
- (id)initWithDatabaseFilename:(NSString *)databaseFileName storeOptions:(NSDictionary *)storeOptions;

/**
 * Initializes a core data storage instance, backed by an in-memory store.
 **/
- (id)initWithInMemoryStore;

/**
 * Readonly access to the databaseFileName used during initialization.
 * If nil was passed to the init method, returns the actual databaseFileName being used (the default filename).
 **/
@property (readonly) NSString *databaseFileName;

/**
 * Readonly access to the databaseOptions used during initialization.
 * If nil was passed to the init method, returns the actual databaseOptions being used (the default databaseOptions).
 **/
@property (readonly) NSDictionary *storeOptions;

/**
 * The saveThreshold specifies the maximum number of unsaved changes to NSManagedObjects before a save is triggered.
 *
 * Since NSManagedObjectContext retains any changed objects until they are saved to disk
 * it is an important memory management concern to keep the number of changed objects within a healthy range.
 *
 * Default 500
 **/
@property (readwrite) NSUInteger saveThreshold;

/**
 * Provides access to the the thread-safe components of the CoreData stack.
 *
 * Please note:
 * The managedObjectContext is private to the storageQueue.
 * If you're on the main thread you can use the mainThreadManagedObjectContext.
 * Otherwise you must create and use your own managedObjectContext.
 *
 * If you think you can simply add a property for the private managedObjectContext,
 * then you need to go read the documentation for core data,
 * specifically the section entitled "Concurrency with Core Data".
 *
 * @see mainThreadManagedObjectContext
 **/
@property (strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 * Convenience method to get a managedObjectContext appropriate for use on the main thread.
 * This context should only be used from the main thread.
 *
 * NSManagedObjectContext is a light-weight thread-UNsafe component of the CoreData stack.
 * Thus a managedObjectContext should only be accessed from a single thread, or from a serialized queue.
 *
 * A managedObjectContext is associated with a persistent store.
 * In most cases the persistent store is an sqlite database file.
 * So think of a managedObjectContext as a thread-specific cache for the underlying database.
 *
 * This method lazily creates a proper managedObjectContext,
 * associated with the persistent store of this instance,
 * and configured to automatically merge changesets from other threads.
 **/
@property (strong, readonly) NSManagedObjectContext *mainThreadManagedObjectContext;

/**
 * The Previous Database File is removed before creating a persistant store.
 *
 * Default NO
 **/

@property (readwrite) BOOL autoRemovePreviousDatabaseFile;

/**
 * The Database File is automatically recreated if the persistant store cannot read it e.g. the model changed or the file became corrupt.
 * For greater control overide didNotAddPersistentStoreWithPath:
 *
 * Default NO
 **/
@property (readwrite) BOOL autoRecreateDatabaseFile;

/**
 * This method calls setAllowsExternalBinaryDataStorage:YES for all Binary Data Attributes in the Managed Object Model.
 * On OS Versions that do not support external binary data storage, this property does nothing.
 *
 * Default NO
 **/
@property (readwrite) BOOL autoAllowExternalBinaryDataStorage;

#pragma mark -  新对象
/*！
 @method CreateObjectWithTable
 @abstract 创建一个表对应的一个对象，用于生成一条新记录
 @param Table  需要创建的对象，所有对应的表
 @result 新记录对应的对象
 */
- (id)createObjectWithTable:(NSString*)table_name;
/*！
 @method insertObject
 @abstract  需要存储/插入/新添一条新记录
 @param Object 需要添加的记录
 @result  操作是否成功
 */
- (BOOL)insertObject:(NSManagedObject*)object;

/*！
 *@method         queryObjectsWithTable:condition:sortByKey:limit
 *@abstract       查询多条记录
 *@param table    需要查询的表
 *@param condition  查询条件，  eg   a == b  and  c != d
 *@param sortByKey  排序准则，  相当于SQL 中的  order by key
 *@param limit      限制查询的结果条数，  类似SQL语句中的limit
 *@param ascending  是否使用升序，默认值为 NO
 *@result NSManagedObject记录数组，如果不存在，则为nil
 */
- (NSArray*)queryObjectsWithTable:(NSString*)table_name;
- (NSArray*)queryObjectsWithTable:(NSString*)table_name condition:(NSString*)condition;
- (NSArray*)queryObjectsWithTable:(NSString*)table_name condition:(NSString*)condition sortByKey:(NSString*)key ascending:(BOOL)isAscending;
- (NSArray*)queryObjectsWithTable:(NSString*)table_name condition:(NSString*)condition sortByKey:(NSString*)key ascending:(BOOL)isAscending limit:(NSInteger)limit;

/*！
 *@method         queryObjectsWithTable:index:indexName:OtherCondition:
 *@abstract       查询指定索引的记录
 *@param table    需要查询的表
 *@param index      索引值，   eg 查询key为20的这条记录，这是 index 为 '20'
 *@param indexName  索引名称，eg 查询key为20的这条记录，这是 indexName 为 'key'
 *@param OtherCondition  查询条件，  eg   a == b  and  c != d
 *@result 查询对象的值，如果不存在，则为nil
  */
- (NSManagedObject*)queryObjectsWithTable:(NSString*)table_name index:(id)index indexName:(NSString*)indexName;
- (NSManagedObject*)queryObjectsWithTable:(NSString*)table_name index:(id)index indexName:(NSString*)indexName OtherCondition:(NSString*)otherCondition;
/*!
 *@method  deleteWithObject:
 *@abstract 删除一条记录
 *@discussion 注意：默认保存
 *@param object 需要删除的记录对应的对象
 *@result 操作是否成功
 */
- (BOOL)deleteWithObject:(NSManagedObject*)object;

/*!
 *@method  deleteWithObjects:
 *@abstract 删除多条记录
 *@discussion 注意：默认保存
 *@param object 需要删除的记录对应的对象
 *@result 操作是否成功
 */
- (BOOL)deleteWithObjects:(NSArray*)objects;

/*!
 *@method  deleteWithObject:
 *@abstract 删除一条记录，调用这个方法必须收到调用一次  savaContext 方法
 *@discussion 注意：默认不保存保存，需要调用一次 SavaContent方法
 *@param object 需要删除的记录对应的对象
 */
- (void)deleteNotSaveWithObject:(NSManagedObject *)object;
/*!
 *@method  saveContext
 *@abstract 持久化所有记录的变更，包括插入、更新等
*/
- (BOOL)saveContext;

@end
