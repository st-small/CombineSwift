import Combine
import Foundation

class Todo: Equatable, Hashable, CustomStringConvertible {
    var id = UUID()
    var text: String
    var completed = false
    
    init(text: String) {
        self.text = text
    }
    
    var description: String {
        text + (completed ? "☑️" : "◻️")
    }
    
    static func ==(lhs: Todo, rhs: Todo) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}

class TodoStore: ObservableObject {
    
    private(set) var todos: [Todo] = [] {
        didSet {
            objectWillChange.send()
        }
    }
    
    init() {
        // load from disk, db, etc...
    }
    
    func add(_ todo: Todo) {
        todos.append(todo)
    }
    
    func remove(_ todo: Todo) {
        guard let index = todos.firstIndex(of: todo) else { return }
        todos.remove(at: index)
    }
    
    func complete(_ todo: Todo) {
        todo.completed = true
        objectWillChange.send()
    }
}

let store = TodoStore()

class Today {
    
    let store: TodoStore
    var cancellables = Set<AnyCancellable>()
    
    init(store: TodoStore) {
        self.store = store
        store.objectWillChange.sink { [unowned self] in
            printTodos(store.todos)
        }
        .store(in: &cancellables)
    }
    
    private func printTodos(_ todos: [Todo]) {
        print(todos)
    }
}

let today = Today(store: store)
store.add(Todo(text: "Record a video"))
store.add(Todo(text: "Go to the doctor"))

let todo = Todo(text: "Buy some milk")
store.add(todo)
store.complete(todo)
