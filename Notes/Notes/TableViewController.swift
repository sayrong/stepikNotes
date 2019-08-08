//
//  TableViewController.swift
//  Notes
//
//  Created by Dima on 20/07/2019.
//  Copyright © 2019 Babette Alvyn sharp. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var model: FileNotebook!
    let reuseIdentifier = "customNotesCell"
    //очереди для выполнения
    let dbQueue = OperationQueue()
    let backendQueue = OperationQueue()
    let agregateQueue = OperationQueue()
    
    private var token: String = ""
    
    //Opertaion func
    private func loadNotes() {
        let loadOperation = LoadNotesOperation(notebook: model, backendQueue: backendQueue, dbQueue: dbQueue)
        loadOperation.completionBlock = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        self.agregateQueue.addOperation(loadOperation)
    }
    
    private func saveNotes(note: Note, model: FileNotebook) {
        let saveOp = SaveNoteOperation(note: note, notebook: model, backendQueue: backendQueue, dbQueue: dbQueue)
        saveOp.completionBlock = {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        self.agregateQueue.addOperation(saveOp)
    }
    
    private func updateNotes(noteToDel: Note, newNote: Note, model: FileNotebook) {
        let remove = RemoveNoteOperation(note: noteToDel, notebook: model, backendQueue: backendQueue, dbQueue: dbQueue)
        remove.completionBlock = {
            let saveOp = SaveNoteOperation(note: newNote, notebook: self.model, backendQueue: self.backendQueue, dbQueue: self.dbQueue)
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
        let remove = RemoveNoteOperation(note: noteToDel, notebook: model, backendQueue: backendQueue, dbQueue: dbQueue)
        self.agregateQueue.addOperation(remove)
    }
    
    //пока не используется
    //просто для заполнения пустой модели
    private func setupTestingContent(_ model: FileNotebook) {
        model.loadFromFile()
        if model.notes.isEmpty {
            model.add(Note(uid: UUID().uuidString, title: "Последние задание на курсе iOS начинаем", content: "Было довольно интересно. Но курс определенно не рассчитан на новичков. Больше всего запомнилось задание с ColorPicker. Оно было довольно сложное, но интересное.", color: UIColor.red, importance: .important, destructDate: Date(timeIntervalSinceNow: 60 * 60 * 24 + 1)))
            model.add(Note(uid: UUID().uuidString, title: "Погода в Москве", content: "В последнее время не переставая льют дожди. Это может быть даже и хорошо, так как особо не тянет на улицу гулять. Можно посвятить время домашних делам.", color: UIColor.white, importance: .normal, destructDate: nil))
            model.add(Note(uid: UUID().uuidString, title: "Как переехать в Silicon valley", content: "Именно такой ролик я только что смотрел на youtube. Это канал резидента Comedy Таира. Показывали нескольких героев, которые благополучно туда переехали. Один работает в facebook, у другого своя игровая студия, третий какой-то мутный advice инвестор, а четвертый инженер из tesla.", color: UIColor.blue, importance: .normal, destructDate: nil))
            model.add(Note(title: "Сериалы", content: "Закончил смотреть Видоизмененный углерод. Довольно интересный. С первых серий заметно затягивает, но потом уже спокойно смотришь и ждешь развязки. Не скажу, что это лучший сериал. Мир дикого запада намного больше зацепил, как по сюжету, так и по музыкальному сопровождению и эффектам.", importance: .normal))
            model.add(Note(title: "Потоки информации", content: "Немного напрягает, что большую часть информации я получаю из каких-либо видео материалов. И если подумать, то это информация пустая, которую ты через 5 мин забудешь и не вспомнишь. Но именно туда ты инвестируешь свое время. На развлечение и картинки. То есть ты как бы являешься пассивной стороной, куда по шлангу закачают информацию. Может стоит начать думать своей головой, записывать свои мысли и больше читать.", importance: .unimportant))
            model.saveToFile()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Заметки"
        model = FileNotebook(filename: "myNotes")
        self.tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewNote))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(makeEditable))
        
        //так как операции зависят друг от друга, лучше использовать serial очередь
        //ну и в concurrent возможно схватить краш
        backendQueue.maxConcurrentOperationCount = 1
        dbQueue.maxConcurrentOperationCount = 1
        agregateQueue.maxConcurrentOperationCount = 1
        //загружаем заметки через NSOperation
        loadNotes()
        let requestTokenViewController = AuthViewController()
        //requestTokenViewController.delegate = self
        present(requestTokenViewController, animated: false, completion: nil)
    }
    
    @objc private func makeEditable() {
        self.tableView.isEditing = !tableView.isEditing
    }
    
    @objc private func createNewNote() {
        self.performSegue(withIdentifier: "editSegue", sender: self)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return model.notes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TableViewCell
        let note = model.notes[indexPath.row]
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
        if editingStyle == .delete {
            let note = model.notes[indexPath.row]
            deleteNote(noteToDel: note)
            self.tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EditNoteViewController, segue.identifier == "editSegue" {
            if let index = sender as? IndexPath {
                vc.noteToEdit = model.notes[index.row]
            }
            vc.completion = returnFromNoteEdit(vc:)
        }
    }
    
    func returnFromNoteEdit(vc: EditNoteViewController) {
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
    func handleTokenChanged(token: String) {
        self.token = token
        print("New token - \(token)")
    }
}
