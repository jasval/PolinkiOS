//
//  RoomsViewController.swift
//  Polink
//
//  Created by Jose Saldana on 01/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RoomsViewController: UIViewController {

    private let toolbarLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private let lobbyCellIdentifier = "roomCell"
    private var currentLobbyAlertController: UIAlertController?
    private let db = Firestore.firestore()
    
    private var lobbyReference: CollectionReference {
        return db.collection("rooms")
    }
    
    private var rooms = [Rooms]()
    private var roomListener: ListenerRegistration?
    
    deinit {
        roomListener?.remove()
    }
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(style: .grouped)
        
        title = "Rooms"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isToolbarHidden = true
    }
    
    // MARK: - Actions
    
    
    // MARK: - Helpers
    
    private func createRoom() {
        guard let ac = currentLobbyAlertController else {
            return
        }
        guard let roomName = ac.textFields?.first?.text else {
            return
        }
        let room = Room(name: roomName)
        
    }
    
}
