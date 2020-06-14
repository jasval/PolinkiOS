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

class RoomsViewController: UITableViewController {

    private let toolbarLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private let roomCellIdentifier = "roomCell"
    private var currentRoomAlertController: UIAlertController?
    
    private let db = Firestore.firestore()
    
    // Before it was a CollectionReference with -- return db.collection("chats")
    private var roomReference: DocumentReference {
        return db.collection("chats").document(currentUser.uid).collection("private").document("userData")
    }
    
    
    private var rooms = [Room]()
    private var roomListener: ListenerRegistration?
    
    private let currentUser: User
    
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: roomCellIdentifier)
        
        // Customise what items appear in the toolbar and how they are organised
        toolbarItems = [
            UIBarButtonItem(customView: toolbarLabel),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(startNewConversation)),
        ]
        toolbarLabel.text = "Rooms"
        
        roomListener = roomReference.addSnapshotListener(includeMetadataChanges: false, listener: { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            guard let chats = snapshot.get("activeChats") as! Array<String>? else {
                print("No active chats for this user!")
            }
            
            
            
            //        roomListener = roomReference.addSnapshotListener({ querySnapshot, error in
            //            guard let snapshot = querySnapshot else {
            //                print("Error listeneing for channel updates: \(error?.localizedDescription ?? "No error")")
            //                return
            //            }
            //            snapshot.documentChanges.forEach { (change) in
            //                self.handleDocumentChange(change)
            //            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isToolbarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isToolbarHidden = true
    }
    
    // MARK: - Actions
    
    // Run same method to start a conversation as defined in a super duper manager class
    @objc func startNewConversation() {
        print("Starting a new conversation")
        return
    }
    
    // MARK: - Helpers
    
    private func createRoom() {
        guard let ac = currentRoomAlertController else {
            return
        }
        guard let roomName = ac.textFields?.first?.text else {
            return
        }
        
        let room = Room(name: roomName)
        roomReference.addDocument(data: room.representation) {
            error in
            if let e = error {
                print("Error saving room: \(e.localizedDescription)")
            }
        }
        
    }
    
    // Adding a new chatroom to table
    private func addRoomToTable(_ room: Room) {
        guard !rooms.contains(room) else {
            return
        }
        
        rooms.append(room)
        rooms.sort()
        
        guard let index = rooms.firstIndex(of: room) else {
            return
        }
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    // Modifying an existing chatroom to our table
    private func updateRoomInTable(_ room: Room) {
        guard let index = rooms.firstIndex(of: room) else {
            return
        }
        
        rooms[index] = room
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    // Removing a room from our table
    private func removeRoomFromTable(_ room: Room) {
        guard let index = rooms.firstIndex(of: room) else {
            return
        }
        
        rooms.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    // handling any change to our rooms in order to update the UI
    private func handleDocumentChange(_ change: DocumentChange) {
      guard let room = Room(document: change.document) else {
        return
      }

      switch change.type {
        
      case .added:
        addRoomToTable(room)
        
      case .modified:
        updateRoomInTable(room)
      
      case .removed:
        removeRoomFromTable(room)
      }
    }
}
// MARK: - TableViewDelegate

extension RoomsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
}
