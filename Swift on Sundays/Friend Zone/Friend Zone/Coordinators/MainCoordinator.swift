//
//  MainCoordinator.swift
//  Friend Zone
//
//  Created by Jakub Charvat on 30/05/2020.
//  Copyright © 2020 jakcharvat. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = [ ]
    var navigationController: UINavigationController
    
    var selectedFriendIndex: Int?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = RootVC.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
}


//MARK: - Showing Friends
extension MainCoordinator {
    func showFriend(_ friend: Friend, from index: Int) {
        selectedFriendIndex = index
        
        let vc = FriendVC.instantiate()
        vc.coordinator = self
        vc.friend = friend
        navigationController.pushViewController(vc, animated: true)
    }
}


//MARK: - Updating Friends
extension MainCoordinator {
    func updateFriend(_ newFriend: Friend) {
        guard let vc = navigationController.viewControllers.first as? RootVC else { return }
        guard let index = selectedFriendIndex else { return }
        vc.updateFriend(newFriend, at: index)
    }
}
