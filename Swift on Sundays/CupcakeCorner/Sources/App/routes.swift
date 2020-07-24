import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get { req -> Future<View> in
        
        struct PageData: Content {
            let cupcakes: [Cupcake]
            let orders: [Order]
        }
        
        let cakes = Cupcake.query(on: req).all()
        let orders = Order.query(on: req).all()
        
        return flatMap(to: View.self, cakes, orders) { cupcakes, orders in
            let pageData = PageData(cupcakes: cupcakes, orders: orders)
            
            return try req.view().render("home", pageData)
        }
    }
    
    
    router.post(Cupcake.self, at: "add") { req, cupcake -> Future<Response> in
        return cupcake.save(on: req).map(to: Response.self) { cupcake in
            return req.redirect(to: "/")
        }
    }
    
    
    router.get("cupcakes") { req -> Future<[Cupcake]> in
        return Cupcake.query(on: req).sort(\.name).all()
    }
    
    
    router.post(Order.self, at: "order") { req, order -> Future<Order> in
        var orderCopy = order
        orderCopy.date = Date()
        return orderCopy.save(on: req)
    }
}
