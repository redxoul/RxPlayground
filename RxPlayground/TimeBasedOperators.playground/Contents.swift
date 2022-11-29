import RxSwift

// Time Based Operator
// 한꺼번에 동작시키면 로그를 확인하기 어려워서 주석으로 막아놓았습니다.

let disposeBag = DisposeBag()

//  replay
// subscribe를 했을 때, replay대상이 이전에 방출했던 element를 buffer만큼 다시 방출시켜주는 Operator입니다.
// replay를 지정해주고 connect()를 호출해주어야 합니다.
print("- - - - - replay - - - - -")
//let shinee = PublishSubject<String>()
//let replay = shinee.replay(2)
//replay.connect() // replay와 같은 연산자들은 connect를 해주어야 함
//
//shinee.onNext("링딩동 링딩동")
//shinee.onNext("링디기딩디기딩딩딩")
//
//replay
//    .subscribe(onNext: {
//        print($0)
//    })
//    .disposed(by: disposeBag)


//  replayAll
// replay와 같지만 buffer가 무한한 버전입니다. subscribe이전에 방출되었던 모든 Element를 방출합니다.
// 마찬가지로 connect()를 해주어야 합니다.
print("- - - - - replayAll - - - - -")
//let teajina = PublishSubject<String>()
//let replayAll = teajina.replayAll()
//replayAll.connect()
//
//teajina.onNext("진진자라")
//teajina.onNext("지리지리자")
//teajina.onNext("진진자라")
//teajina.onNext("지리지리자")
//
//replayAll
//    .subscribe(onNext: {
//        print($0)
//    })
//    .disposed(by: disposeBag)

// buffer
// timeSpan, count, scheduler 세가지 요소를 받습니다.
// 지정한 scheduler에서 timeSpan 시간동안 count만큼의 버퍼만큼 쌓아서 배열로 방출시킵니다.
print("- - - - - buffer - - - - -")
//let source = PublishSubject<String>()
//var count = 0
//let timer = DispatchSource.makeTimerSource()
//timer.schedule(deadline: .now() + 2, repeating: .seconds(1))
//timer.setEventHandler {
//    count += 1
//    source.onNext("\(count)")
//}
//timer.resume()
//
//source
//    .buffer(
//        timeSpan: .seconds(2),
//        count: 2,
//        scheduler: MainScheduler.instance
//    )
//    .subscribe(onNext: {
//        print($0)
//    })
//    .disposed(by: disposeBag)

// window
// buffer와 동작이 유사하지만 배열대신 Observable로 방출을 합니다.
print("- - - - - window - - - - -")
//let maxCreatingObservable = 2
//
//let window = PublishSubject<String>()
//
//var windowCount = 0
//let windowTimerSource = DispatchSource.makeTimerSource()
//windowTimerSource.schedule(deadline: .now()+2, repeating: .seconds(1))
//windowTimerSource.setEventHandler {
//    windowCount += 1
//    window.onNext("\(windowCount)")
//}
//windowTimerSource.resume()
//
//window
//    .window(timeSpan: .seconds(2),
//            count: maxCreatingObservable,
//            scheduler: MainScheduler.instance)
//    .flatMap { windowObservable -> Observable<(index: Int, element: String)> in
//        return windowObservable.enumerated()
//    }
//    .subscribe(onNext: {
//        print("\($0.index)번째 Observable element: \($0.element)")
//    })
//    .disposed(by: disposeBag)


// delaySubscription
// subscription을 지정한 시간만큼 delay시킵니다.
print("- - - - - delaySubscription - - - - -")
//let delaySource = PublishSubject<String>()
//
//var delayCount = 0
//let delayTimesource = DispatchSource.makeTimerSource()
//delayTimesource.schedule(deadline: .now()+2, repeating: .seconds(1))
//delayTimesource.setEventHandler {
//    delayCount += 1
//    delaySource.onNext("\(delayCount)")
//}
//delayTimesource.resume()
//
//delaySource
//    .delaySubscription(.seconds(5), scheduler: MainScheduler.instance)
//    .subscribe(onNext: { // subscribe를 지연
//        print($0)
//    })
//    .disposed(by: disposeBag)

// delay
// 시퀀스를 지정한 시간만큼 지연시킵니다. 이벤트 방출이 지연됩니다.
print("- - - - - delay - - - - -")
//let delaySubject = PublishSubject<Int>()
//
//var delayCount = 0
//let delayTimesouce = DispatchSource.makeTimerSource()
//delayTimesouce.schedule(deadline: .now(), repeating: .seconds(1))
//delayTimesouce.setEventHandler {
//    delayCount += 1
//    delaySubject.onNext(delayCount)
//}
//delayTimesouce.resume()
//
//delaySubject
//    .delay(.seconds(5), scheduler: MainScheduler.instance) // 이벤트 방출을 지연
//    .subscribe(onNext: {
//        print($0)
//    })
//    .disposed(by: disposeBag)

// interval
// DispatchSource, Timer와 같은 역할을 Rx로 구현한 Operator입니다.
print("- - - - - interval - - - - -")
//Observable<Int>
//    .interval(.seconds(3), scheduler: MainScheduler.instance)
//    .subscribe(onNext: {
//        print($0) // of 등으로 시퀀스를 구현하지 않아도 타입추론으로 Int타입의 숫자들을 방출
//    })
//    .disposed(by: disposeBag)

// timer
// interval과 유사하지만. 좀더 디테일하게 설정이 가능합니다.
// dueTime으로 첫 Element를 내보내는 시간을, period로 그 다음 Element들을 방출할 주기를 설정하고 scheduler를 설정할 수 있습니다.
// DispatchSource, Timer보다 좀 더 직관적으로 작성하기 좋습니다.
print("- - - - - timer - - - - -")
//Observable<Int>
//    .timer(.seconds(5),
//           period: .seconds(2),
//           scheduler: MainScheduler.instance)
//    .subscribe(onNext: {
//        print($0)
//    })
//    .disposed(by: disposeBag)

// timeout
// 정해진 시간 내에 이벤트를 방출시키지 않으면 timeout error를 방출시키는 Operator입니다.
print("- - - - - timeout - - - - -")
//import RxCocoa
//import PlaygroundSupport
//
//let pushForNoError = UIButton(type: .system)
//pushForNoError.setTitle("Push!!", for: .normal)
//pushForNoError.sizeToFit()
//
//PlaygroundPage.current.liveView = pushForNoError // Playground에 UIButton을 테스트하기 위함
//
//pushForNoError.rx.tap
//    .do(onNext: {
//        print("tap")
//    })
//    .timeout(.seconds(5), scheduler: MainScheduler.instance)
//    .subscribe {
//        print($0)
//    }
//    .disposed(by: disposeBag)
