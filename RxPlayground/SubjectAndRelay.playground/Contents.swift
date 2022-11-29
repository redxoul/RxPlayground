import RxSwift
import RxRelay

// Subject
// Observable이자 Observer역할을 모두 할 수 있고
// create 이후에도 Observable의 외부에서 동적으로 원하는 값을 추가할 수 있는 시퀀스입니다.

// PublishSubject
// 빈 상태로 시작해서 새로운 값을 subscriber에 방출합니다.
// subscriber는 이미 지나간 값은 받지 못하고 구독 이후 발생한 값부터 받습니다.
print("- - - - - PublishSubject - - - - -")
let disposeBag = DisposeBag()

let publishSubject = PublishSubject<String>()
publishSubject.onNext("(1) 안녕하세요!")

let subscriber1 = publishSubject
    .subscribe(onNext: {
        print("sub1: \($0)")
    })
//    .disposed(by: disposeBag)

publishSubject.onNext("(2) Hello!?")
publishSubject.onNext("(3) Hello!?!?")

subscriber1.dispose()

let subscriber2 = publishSubject
    .subscribe(onNext: {
        print("sub2: \($0)")
    })
    .disposed(by: disposeBag)

publishSubject.onNext("(4) Hello!?!?!?")
publishSubject.onCompleted()

publishSubject.onNext("(5) Hello!?!?!?!?")

//subscriber2.dispose()

publishSubject
    .subscribe {
        print("sub3: ", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

publishSubject.onNext("(6) Hello!?!?!?!?!?")


// BehaviorSubject
// 하나의 초기값을 가진 상태로 시작해서 새로운 subscriber에게 초기값이나 최신값을 방출합니다.
// subscriber는 구독하면 지난 방출 값 중 최신의 값을 next이벤트로 받고 시작합니다.
// 초기값을 넣을 수 없다면 PublishSubject를 사용하거나 Element를 옵셔널로 설정하면 됩니다.
print("- - - - - BehaviorSubject - - - - -")
enum SubjectError: Error {
    case someError
}

let behaviorSubject = BehaviorSubject<String>(value: "(0) init")

behaviorSubject
    .subscribe {
        print("sub1: ", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

behaviorSubject.onNext("(1) first")

behaviorSubject
    .subscribe {
        print("sub2: ", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

//behaviorSubject
//    .onError(SubjectError.someError)

if let value = try? behaviorSubject.value() { // 최신 값을 가져올 수 있습니다.
    print("value: ", value)
}

// ReplaySubject
// buffer를 두고 초기화하고, bufferSize 만큼의 값을 유지하면서 새로운 subscriber에세 방출합니다.
// subscriber는 구독하면 지난 방출 값 중 세팅된 사이즈 만큼 버퍼에 쌓인 값을 받고 시작합니다.
// 버퍼에 쌓인 만큼 메모리를 차지하고 있기 때문에 사용시 주의가 필요합니다. 메모리에 엄청난 부하를 줄 수 있습니다.

print("- - - - - ReplaySubject - - - - -")

let replaySubject = ReplaySubject<String>.create(bufferSize: 2)

replaySubject.onNext("(1) first")
replaySubject.onNext("(2) second")

replaySubject
    .subscribe {
        print("sub1: ", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

replaySubject.onNext("(3) third")

replaySubject
    .subscribe {
        print("sub2: ", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

replaySubject.onNext("(4) fourth")
replaySubject.onError(SubjectError.someError)
replaySubject.dispose()

replaySubject
    .subscribe {
        print("sub3: ", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

// asyncSubject
// completed이벤트가 발생할 때까지 observer들은 아무 Element를 받을 수 없습니다.
// (1) completed이벤트가 발생하면 마지막으로 발생했던 next이벤트를 받거나,
// (2) next이벤트가 발생된 적이 있었더라도, error이벤트로 종료가 되면 아무런 Element도 받지 못하고 error이벤트를 받고 종료됩니다.
print("- - - - - AsyncSubject (1) - - - - -")
let asyncSubject = AsyncSubject<String>()

asyncSubject
    .subscribe {
        print("sub1: ", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

asyncSubject.onNext("(1) first")
asyncSubject.onNext("(2) second")
asyncSubject.onNext("(3) third")

asyncSubject.onCompleted()

print("- - - - - AsyncSubject (2) - - - - -")
let asyncSubject2 = AsyncSubject<String>()

asyncSubject2
    .subscribe {
        print("sub2: ", $0.element ?? $0)
    }
    .disposed(by: disposeBag)

asyncSubject2.onNext("(1) first")
asyncSubject2.onNext("(2) second")
asyncSubject2.onNext("(3) third")

asyncSubject2.onError(SubjectError.someError)


// Relay는 절대로 종료(error, complete)되지 않는 Subject입니다.
// 오직 값을 받을 수만 있기 때문에 next이벤트 대신 accept이벤트를 방출합니다.

// publishRelay
// PublishSubject와 동일하지만, accept이벤트만 방출하는 Relay입니다.
print("- - - - - PublishRelay  - - - - -")

let publishRelay = PublishRelay<String>()

publishRelay.accept("(1) first accept")

publishRelay
    .subscribe(onNext: {
        print("sub: ", $0)
    })
    .disposed(by: disposeBag)

publishRelay.accept("(2) second accept")

// behaviorRelay
// BehaviorSubject와 동일하지만, accept이벤트만 방출하는 Relay입니다.
print("- - - - - BehaviorRelay  - - - - -")

let behaviorRelay = BehaviorRelay<String>(value: "(0) init value")

behaviorRelay
    .subscribe(onNext: {
        print("sub1: ", $0)
    })
    .disposed(by: disposeBag)

behaviorRelay.accept("(1) first accept")

behaviorRelay
    .subscribe(onNext: {
        print("sub2: ", $0)
    })
    .disposed(by: disposeBag)

behaviorRelay.accept("(2) second accept")

// replayRelay
// ReplaySubject와 동일하지만, accept이벤트만 방출하는 Relay입니다.
print("- - - - - ReplayRelay  - - - - -")
let replayRelay = ReplayRelay<String>.create(bufferSize: 2)

replayRelay.accept("(1) first accept")

replayRelay
    .subscribe(onNext: {
        print("sub1: ", $0)
    })
    .disposed(by: disposeBag)

replayRelay.accept("(2) second accept")



replayRelay
    .subscribe(onNext: {
        print("sub2: ", $0)
    })
    .disposed(by: disposeBag)
