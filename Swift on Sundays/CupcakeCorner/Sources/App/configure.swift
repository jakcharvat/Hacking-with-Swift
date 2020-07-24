import Vapor
import Leaf
import Fluent
import FluentSQLite

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // LEAF Template rendering
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    // SQLite DB
    /// Get the current wording directory
    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)
    
    try services.register(FluentSQLiteProvider())
    
    var dbConfig = DatabasesConfig()
    let db = try SQLiteDatabase(storage: .file(path: "\(directoryConfig.workDir)cupcakes.db"))
    dbConfig.add(database: db, as: .sqlite)
    services.register(dbConfig)
    
    // Migrations
    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: Cupcake.self, database: DatabaseIdentifier<Cupcake.Database>.sqlite)
    migrationConfig.add(model: Order.self, database: DatabaseIdentifier<Order.Database>.sqlite)
    services.register(migrationConfig)
}
