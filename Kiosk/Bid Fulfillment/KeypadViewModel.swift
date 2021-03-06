import Foundation
import ReactiveCocoa
import Swift_RAC_Macros

let KeypadViewModelMaxValue = 1_000_000

public class KeypadViewModel: NSObject {
    
    dynamic private var intValue: Int = 0
    dynamic private var stringValue: String = ""
    
    //MARK: - Signals
    
    public lazy var intValueSignal: RACSignal = {
        RACObserve(self, "intValue")
    }()
    
    public lazy var stringValueSignal: RACSignal = {
        RACObserve(self, "stringValue")
    }()
    
    // MARK: - Commands
    
    // I have no idea why, but if you try and use `[weak self]` in the closure definition of a RACCommand, the compiler segfaults ¯\_(ツ)_/¯
    
    public lazy var deleteCommand: RACCommand = {
        let localSelf = self
        return RACCommand { [weak localSelf] _ -> RACSignal! in
            localSelf?.deleteSignal() ?? RACSignal.empty()
        }
    }()

    public lazy var clearCommand: RACCommand = {
        let localSelf = self
        return RACCommand { [weak localSelf] _ -> RACSignal! in
            localSelf?.clearSignal() ?? RACSignal.empty()
        }
    }()
    
    public lazy var addDigitCommand: RACCommand = {
        let localSelf = self
        return RACCommand { [weak localSelf] (input) -> RACSignal! in
            return localSelf?.addDigitSignal(input as Int) ?? RACSignal.empty()
        }
    }()
}

private extension KeypadViewModel {
    func deleteSignal() -> RACSignal {
        return RACSignal.createSignal { [weak self] (subscriber) -> RACDisposable! in
            if let strongSelf = self {
                strongSelf.intValue = Int(strongSelf.intValue/10)
                if countElements(strongSelf.stringValue) > 0 {
                    strongSelf.stringValue = dropLast(strongSelf.stringValue)
                }
            }
            subscriber.sendCompleted()
            return nil
        }
    }
    
    func clearSignal() -> RACSignal {
        return  RACSignal.createSignal { [weak self] (subscriber) -> RACDisposable! in
            self?.intValue = 0
            self?.stringValue = ""
            subscriber.sendCompleted()
            return nil
        }
    }
    
    func addDigitSignal(input: Int) -> RACSignal {
        return RACSignal.createSignal { [weak self] (subscriber) -> RACDisposable! in
            if let strongSelf = self {
                let newValue = (10 * (strongSelf.intValue ?? 0)) + input
                if (newValue < KeypadViewModelMaxValue) {
                    strongSelf.intValue = newValue
                    strongSelf.stringValue = "\(strongSelf.stringValue)\(input)"
                }
            }
            subscriber.sendCompleted()
            return nil
        }
    }
}
