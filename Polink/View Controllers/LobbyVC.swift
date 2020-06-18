//
//  LobbyVC.swift
//  Polink
//
//  Created by Jose Saldana on 01/06/2020.
//  Copyright © 2020 Jose Saldana. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LobbyVC: UITableViewController {

    private let toolbarLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private let roomCellIdentifier = "roomCell"
    private var currentRoomAlertController: UIAlertController?
    
    private let db = Firestore.firestore()
        
    private var roomReference: CollectionReference {
        return db.collection("chats")
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
    
    required init?(coder: NSCoder) {
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
        
        
        roomListener = roomReference.whereField("participants", arrayContainsAny: [Participant.init(uid: currentUser.uid)]).addSnapshotListener(includeMetadataChanges: false, listener: { (QuerySnapshot, error) in
            guard let snapshot = QuerySnapshot else {
                print("Error listening for room updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            
            snapshot.documentChanges.forEach { (change) in
                self.handleDocumentChange(change)
            }
            
        })
        
//            //        roomListener = roomReference.addSnapshotListener({ querySnapshot, error in
//            //            guard let snapshot = querySnapshot else {
//            //                print("Error listeneing for channel updates: \(error?.localizedDescription ?? "No error")")
//            //                return
//            //            }
//            //            snapshot.documentChanges.forEach { (change) in
//            //                self.handleDocumentChange(change)
//            //            }
//        })
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
    
    // Needs to be revised in order to implement
    private func createRoom() {
//        guard let ac = currentRoomAlertController else {
//            return
//        }
//        guard let roomName = ac.textFields?.first?.text else {
//            return
//        }
//
//        let room = Room(name: roomName)
//        roomReference.addDocument(data: room.representation) {
//            error in
//            if let e = error {
//                print("Error saving room: \(e.localizedDescription)")
//            }
//        }
//
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
        //      guard let room = Room(document: change.document) else {
        //        return
        //      }
        do {
            guard let room:Room = try change.document.decoded() else {return}
            
            switch change.type {
                
            case .added:
                addRoomToTable(room)
                
            case .modified:
                updateRoomInTable(room)
                
            case .removed:
                removeRoomFromTable(room)
            }
        } catch {
            print("There was a problem handling the document change and decoding into room object: \(error.localizedDescription)")
        }
    }
}
// MARK: - TableViewDelegate

extension LobbyVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: roomCellIdentifier, for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        
        // Name to be shown in the table is the randomised name of the other participant
        let interlocutor: Participant? = rooms[indexPath.row].participants.first { (Participant) -> Bool in
            Participant.uid != currentUser.uid
            }
        
        cell.textLabel?.text = interlocutor?.randomUsername
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = rooms[indexPath.row]
        
        // Create a sender from participants data
        let rootSender = room.participants.first { (Participant) -> Bool in
            Participant.uid == currentUser.uid
        }
        
        let sender = Sender(senderId: rootSender?.uid ?? currentUser.uid, displayName: rootSender?.randomUsername)
        // Push view controller passing the user and the room in question
        let vc = ChatVC(user: sender, room: room)
        navigationController?.pushViewController(vc, animated: true)
    }
}
