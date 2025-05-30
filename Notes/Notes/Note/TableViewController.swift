//
//  TableViewController.swift
//  Notes
//
//  Created by Dima on 20/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import UIKit
import CoreData

protocol TablePresenterProtocol {
    
}

class TableViewController: UITableViewController {

    var model: NoteStorageProtocol? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    let reuseIdentifier = "customNotesCell"
    let dbQueue = OperationQueue()
    let backendQueue = OperationQueue()
    let agregateQueue = OperationQueue()
    
    //костыль для первого запуска и показа Auth
    private var first = true
    
    private func saveNotes(note: Note, model: NoteStorageProtocol) {
        let saveOp = SaveNoteOperation(note: note, notebook: model, backendQueue: backendQueue, dbQueue: dbQueue)
        saveOp.completionBlock = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        self.agregateQueue.addOperation(saveOp)
    }
    
    private func updateNotes(noteToDel: Note, newNote: Note, model: NoteStorageProtocol) {
        let remove = RemoveNoteOperation(note: noteToDel, notebook: model, backendQueue: backendQueue, dbQueue: dbQueue)
        remove.completionBlock = {
            let saveOp = SaveNoteOperation(note: newNote, notebook: model, backendQueue: self.backendQueue, dbQueue: self.dbQueue)
            saveOp.completionBlock = {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            self.agregateQueue.addOperation(saveOp)
        }
        self.agregateQueue.addOperation(remove)
    }
    
    private func deleteNote(noteToDel: Note) {
        guard let model = model else { return }
        let remove = RemoveNoteOperation(note: noteToDel, notebook: model, backendQueue: backendQueue, dbQueue: dbQueue)
        self.agregateQueue.addOperation(remove)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Заметки"
        //FileNotebook(filename: "myNotes")
        self.tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewNote))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(makeEditable))
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if first {
            if NetworkManager.shared().token.isEmpty {
                let requestTokenViewController = AuthViewController(delegate: self)
                present(requestTokenViewController, animated: true)
            }
        }
        first = false
    }
    
    
    
    @objc private func makeEditable() {
        self.tableView.isEditing = !tableView.isEditing
    }
    
    @objc private func createNewNote() {
        self.performSegue(withIdentifier: "editSegue", sender: self)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model?.notes.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TableViewCell
        let note = model!.notes[indexPath.row]
        cell.colorView.backgroundColor = note.color
        cell.customTitle.text = note.title
        cell.customDescription?.text = note.content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "editSegue", sender: indexPath)
    }
    
    //для удаления со свайпом влево
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let model = model else { return }
        if editingStyle == .delete {
            let note = model.notes[indexPath.row]
            let remove = RemoveNoteOperation(note: note, notebook: model, backendQueue: backendQueue, dbQueue: dbQueue)
            //должно быть консистентное состояние иначе можем словить краш
            //сначала удаляем данные, потом удаляем и таблицы
            remove.completionBlock = {
                DispatchQueue.main.async {
                    self.tableView.deleteRows(at: [indexPath], with: .left)
                }
            }
            self.agregateQueue.addOperation(remove)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditNoteViewController, segue.identifier == "editSegue" {
            if let index = sender as? IndexPath {
                vc.noteToEdit = model?.notes[index.row]
            }
            vc.completion = returnFromNoteEdit(vc:)
        }
    }
    
    func returnFromNoteEdit(vc: EditNoteViewController) {
        guard let model = model else { return }
        //условия для новой заметки
        guard let name = vc.noteName.text,
            let content = vc.noteText.text,
            !name.isEmpty, !content.isEmpty
        else {
            return
        }
        var color = UIColor.white
        if vc.colorRect2.selected { color = vc.colorRect2.backgroundColor! }
        else if vc.colorRect3.selected { color = vc.colorRect3.backgroundColor! }
        else if vc.colorRect4.selected {color = vc.colorRect4.backgroundColor! }
        //вернувшиеся заметка
        let date = vc.destroyDateSwitch.isOn ? vc.datePicker.date : nil
        let newNote = Note(uid: UUID().uuidString, title: name, content: content, color: color, importance: .normal, destructDate: date)
        //если в editController указана модель, то заметка уже есть. Проверяем изменения
        if let noteToEdit = vc.noteToEdit {
            for note in model.notes {
                if note.uid == noteToEdit.uid {
                    if isNoteChange(note: note, new: newNote) {
                        updateNotes(noteToDel: note, newNote: newNote, model: model)
                    } else {
                        return
                    }
                }
            }
        //в противном случае просто добавляем
        } else {
           saveNotes(note: newNote, model: model)
        }
    }
    
    private func isNoteChange(note: Note, new: Note) -> Bool {
        let changedTitle = note.title != new.title
        let changedContent = note.content != new.content
        let changedDate = note.selfDestructDate != new.selfDestructDate
        let changedColor = note.color != new.color
        return changedTitle || changedContent || changedDate || changedColor
    }

}

extension TableViewController: AuthViewControllerDelegate {
    func handleTokenChanged(token: String?) {
        guard let token = token else {
            print("Problem with token")
            return
        }
        NetworkManager.shared().token = token
        print("New token - \(token)")
    }
    
    //Opertaion func
    func loadNotes() {
        guard let model = model else { return }
        let loadOperation = LoadNotesOperation(notebook: model, backendQueue: backendQueue, dbQueue: dbQueue)
        loadOperation.completionBlock = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        self.agregateQueue.addOperation(loadOperation)
    }
    
}
