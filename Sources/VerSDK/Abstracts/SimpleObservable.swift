final class SimpleObservable<T> {
    
    var value: T {
        didSet { subscriber?(value) }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    var subscriber: ((T) -> Void)?
    
    func bind(subscriber: ((T) -> Void)?) {
        self.subscriber = subscriber
        subscriber?(value)
    }
}
