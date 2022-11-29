import RxSwift

let disposeBag = DisposeBag()


// (아래부터는 시퀀스들을 합치는 방법)

// zip
// zip은 묶인 Observable들의 결과값을 쌍으로 묶어서 내보내줍니다.
// 쌍이 맞지 않은 결과값은 쌍이 맞을 때까지 방출될 수 없게 됩니다.
// zip으로 묶이는 Observable들은 데이터 타입이 달라도 상관이 없습니다.
print("- - - - - zip - - - - -")

enum Whose {
    case mine
    case yours
}

let almond = Observable<String>.of("HoneyButter", "Wasabi", "MintChoco", "Corn", "Buldak")
let whose = Observable<Whose>.of(.mine, .mine, .yours, .mine, .mine)

let almondEating = Observable
    .zip(almond, whose) { almond, whose in
        return almond + " is \(whose)"
    }

almondEating
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// merge
// 2개 이상의 Observable을 하나의 Observable로 만들어주며, merge하려는 Observable의 타입이 같아야 합니다.
// merge한 시퀀스들을 동시에 subscribe하고 element가 들어오는 즉시 방출되어 어떤 것이 먼저 들어올지 순서를 알 수는 없습니다.
// 내부 시퀀스들이 모두 complete가 될 때 merge시퀀스가 종료가 되며,
// 내부 시퀀스들 중 하나가 error를 방출시키면 merge Observable은 바로 error를 relay하고 종료시켜버립니다.
print("- - - - - merge(1) - - - - -")

enum Almond {
    case honeyButter
    case wasabi
    case mintChoco
    case buldak
    case corn
    case garlic
    case onion
    case caramel
}

let almond1 = Observable<Almond>.from([.honeyButter, .wasabi, .mintChoco, .buldak])
let almond2 = Observable<Almond>.from([.corn, .garlic, .onion, .caramel])

Observable.of(almond1, almond2)
    .merge()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
 
// merge(maxConcurrent:): maxConcurrent만큼의 Observable만 동시에 받음
// 아래처럼 maxConcurrent를 1로 설정하면,
// 첫번째 Observable(almond1)이 끝나야 두번째 Observable(almond2)를 subscribe하게 되어 순서가 보장됩니다.
// 네트워크 요청이 많을 때 리소스 제한을 하거나, 연결수를 제한하기 위해 쓸 수 있음.
print("- - - - - merge(2) - - - - -")

Observable.of(almond1, almond2)
    .merge(maxConcurrent: 1)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// combineLatest
// 2개 이상의 Observable을 묶어주는데, 각 Observable이 마지막으로 방출한 Element를 묶어서 방출시켜줍니다.
// 최대 8개까지 묶는 것이 가능합니다.
// 여러 개의 TextField값을 하나의 Observable로 조합하여 관리하는 상황에서 유용합니다.
print("- - - - - combineLatest - - - - -")
let dateFormat = PublishSubject<DateFormatter.Style>()
let current = Observable<Date>.of(Date())

let currentDateString = Observable
    .combineLatest(
        dateFormat,
        current,
        resultSelector: { format, date -> String in
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = format
            return dateFormatter.string(from: date)
        }
    )

currentDateString
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

dateFormat.onNext(.short)
dateFormat.onNext(.long)


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// (여기부터는 시퀀스에 시퀀스를 Append하는 방법들)

// startWith: 초기값이 필요한 상황일 때, 현재 상태와 함꼐 초기값을 넣어줌
// startWith의 위치는 subscribe 이전 어디라도 영향이 없음.
print("- - - - - startWith - - - - -")

let almondPackage = Observable<Almond>.of(.honeyButter, .wasabi, .corn)

almondPackage
    .enumerated()
    .map { index, element in
        "(\(index+1)) \(element)"
    }
    .startWith("(0) \(Almond.garlic)")
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// concat
// 두개이상의 시퀀스를 이어붙이고 싶을 때 사용합니다.
// concat에서는 두가지 방법이 있습니다.
// (1) 새 Observalble에 concat으로 2개의 Observable을 넣는 방법
print("- - - - - concat(1) - - - - -")

let package1 = Observable<Almond>.of(.wasabi, .onion, .honeyButter)
let package2 = Observable<Almond>.of(.caramel, .corn, .garlic)

let packageSet = Observable
    .concat([package1, package2])

packageSet
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// (2) Observable에 concat을 이용해 second Observable을 지정하는 방법
print("- - - - - concat(2) - - - - -")
package1
    .concat(package2)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)


// concatMap
// flatMap과 유사하지만,
// 각각의 시퀀스가 다음 시퀀스가 구독되기 전에 모두 Complete되는 것을 보장해줍니다.
// 첫번째 들어온 내부 Observable이 종료될 때까지 두번째 들어온 내부 Observable이 subscribe되는것을 막아줍니다.
// 첫번째 들어온 내부 Observable이 종료되면 두번째 내부 Observable을 subscribe하기 시작합니다.
print("- - - - - concatMap - - - - -")

struct Taster {
    var tasting: PublishSubject<Almond>
}

let almondTasting = Taster(tasting: PublishSubject<Almond>())
let almondTasting2 = Taster(tasting: PublishSubject<Almond>())

let tasting = PublishSubject<Taster>()

tasting
    .concatMap { Taster in
        Taster.tasting
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

tasting.onNext(almondTasting)
tasting.onNext(almondTasting2)
almondTasting.tasting.onNext(.honeyButter)
almondTasting2.tasting.onNext(.mintChoco) // 첫번째 subscribe가 완료되기 전이라 무시
almondTasting.tasting.onNext(.corn)
almondTasting.tasting.onNext(.buldak)
almondTasting.tasting.onCompleted() // 첫번쨰 subscribe 완료
almondTasting2.tasting.onNext(.caramel)
almondTasting2.tasting.onNext(.garlic)

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// 트리거 역할을 하는 Operator들
// withLatestFrom
// 트리거 역할을 하는 Observable의 값이 방출이 될 때,
// 해당 Element를 Second Observable의 최신값과 함께 방출되도록 하는 Operator입니다.
// 화면에서 사용자 입력을 받고, 버튼을 눌렀을 때 최신 입력값을 전달하고자 하는 상황에서 쓰일 수 있습니다.
print("- - - - - withLatestFrom - - - - -")
enum CasherAction {
    case scan
}

let strangeCasher = PublishSubject<CasherAction>()
let customer = PublishSubject<Almond>()

strangeCasher
    .withLatestFrom(customer) { "\($0) \($1)" }
    .distinctUntilChanged() // 변동이 있을 때만 방출되도록 함
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

customer.onNext(.honeyButter)
strangeCasher.onNext(.scan)

customer.onNext(.wasabi)
customer.onNext(.corn)
customer.onNext(.buldak)
strangeCasher.onNext(.scan)

strangeCasher.onNext(.scan)

// sample
// withLatestFrom과 distinctUntilChanged를 합쳐놓은 Operator입니다.
// 트리거 Observable이 방출이 되었을 때, Second Observable의 최신 Element와 함께 방출이 되지만, 값의 변동이 없다면 방출이 되지 않습니다.
print("- - - - - sample - - - - -")
let strangeCasher2 = PublishSubject<CasherAction>()
let customer2 = PublishSubject<Almond>()

customer2
    .sample(strangeCasher2)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

customer2.onNext(.wasabi)
strangeCasher2.onNext(.scan)
customer2.onNext(.corn)
strangeCasher2.onNext(.scan)
customer2.onNext(.buldak)
customer2.onNext(.honeyButter)
strangeCasher2.onNext(.scan)
strangeCasher2.onNext(.scan)

// amb
// amb는 ambiguous(애매모호한)의 약자입니다.
// 두 Observable 중 어느것을 Subscribe할지 애매매호할 때 유용합니다.
// 두개의 Observable로부터 Element가 방출될 때를 기다렸다가,
// 먼저 Element를 방출한 Observable만 Subscribe 되고 나머지 Observable은 무시됩니다.
print("- - - - - amb - - - - -")

let challenger1 = PublishSubject<String>()
let challenger2 = PublishSubject<String>()

let Referee = challenger1.amb(challenger2)

Referee
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

challenger2.onNext("1")
challenger1.onNext("2")
challenger1.onNext("3")
challenger2.onNext("4")
challenger1.onNext("5")
challenger2.onNext("6")

// switchLatest
// 외부의 Observable이 마지막으로 방출한 내부 Observable에서만 Element가 방출됩니다.
print("- - - - - switchLatest - - - - -")
let student1 = PublishSubject<String>()
let student2 = PublishSubject<String>()
let student3 = PublishSubject<String>()

let handsUp = PublishSubject<Observable<String>>()

let classRoom = handsUp.switchLatest()

classRoom
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

handsUp.onNext(student1)
student1.onNext("student1: 손들고 발표")
student2.onNext("student2: 손 안들고 말함")

handsUp.onNext(student2)
student2.onNext("student2: 손들고 발표")
student1.onNext("student1: 손 안들고 말함")

// reduce
// Swift의 Collection타입에서 제공하는 reduce와 동일한 기능의 Operator입니다.
print("- - - - - reduce - - - - -")
Observable.from((1...10))
    .reduce(0) { summary, newValue in
        return summary + newValue
    }
//    .reduce(0, accumulator: +)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)


// scan
// reduce와 유사하지만, reduce의 과정마다 Element를 방출시켜줍니다.
print("- - - - - scan - - - - -")
Observable.from((1...10))
    .scan(0, accumulator: +)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

