extension SQLBenchmarker {
    internal func testPlanets() throws {
        defer {
            _ = try? conn.drop(table: Planet.self)
                .ifExists()
                .run().wait()
            _ = try? conn.drop(table: Galaxy.self)
                .ifExists()
                .run().wait()
        }
        
        try conn.create(table: Galaxy.self)
            .column(for: \Galaxy.id, .primaryKey)
            .column(for: \Galaxy.name)
            .run().wait()
        
        try conn.create(table: Planet.self)
            .ifNotExists()
            .column(for: \Planet.id, .primaryKey)
            .column(for: \Planet.galaxyID, .references(\Galaxy.id))
            .run().wait()
        
        try conn.alter(table: Planet.self)
            .column(for: \Planet.name, .default(.literal(.string("Unamed Planet"))))
            .run().wait()
        
        try conn.create(index: "test_index").on(\Planet.name)
            .unique()
            .run().wait()
        
        try conn.insert(into: Galaxy.self)
            .value(Galaxy(name: "Milky Way"))
            .run().wait()
        
        let a = try conn.select().all().from(Galaxy.self)
            .where(\Galaxy.name == "Milky Way")
            .groupBy(\Galaxy.id)
            .orderBy(\Galaxy.name, .descending)
            .all(decoding: Galaxy.self).wait()
        print(a)
        
        let galaxyID = 1
        try conn.insert(into: Planet.self)
            .value(Planet(name: "Earth", galaxyID: galaxyID))
            .run().wait()
        
        try conn.insert(into: Planet.self)
            .values([
                Planet(name: "Mercury", galaxyID: galaxyID),
                Planet(name: "Venus", galaxyID: galaxyID),
                Planet(name: "Mars", galaxyID: galaxyID),
                Planet(name: "Jpuiter", galaxyID: galaxyID),
                Planet(name: "Pluto", galaxyID: galaxyID)
                ])
            .run().wait()
        
        try conn.select()
            .column(.count(\Planet.name))
            .from(Planet.self)
            .where(\Planet.galaxyID, .equal, 5)
            .run().wait()

        try conn.select()
            .column(.count(.all))
            .from(Planet.self)
            .where(\Planet.galaxyID, .equal, 5)
            .run().wait()

        try conn.select()
            .column(.sum(\Planet.id), as: "id_sum")
            .from(Planet.self)
            .where(\Planet.galaxyID, .equal, 5)
            .run().wait()
        
        try conn.select()
            .column(.coalesce(.sum(\Planet.id), 0), as: "id_sum")
            .from(Planet.self)
            .where(\Planet.galaxyID, .equal, 5_000_000)
            .run().wait()
        
        try conn.update(Planet.self)
            .where(\Planet.name == "Jpuiter")
            .set(["name": "Jupiter"])
            .run().wait()
        
        let selectC = try conn.select().all()
            .from(Planet.self)
            .join(\Planet.galaxyID, to: \Galaxy.id)
            .all(decoding: Planet.self, Galaxy.self)
            .wait()
        print(selectC)
        
        try conn.update(Galaxy.self)
            .set(\Galaxy.name, to: "Milky Way 2")
            .where(\Galaxy.name == "Milky Way")
            .run().wait()
        
        try conn.delete(from: Galaxy.self)
            .where(\Galaxy.name == "Milky Way")
            .run().wait()
        
        let b = try conn.select()
            .column(.count(as: .identifier("c")))
            .from(Galaxy.self)
            .all().wait()
        print(b)
    }
}
