interface Duration exposes [
        add,
        Duration,
        fromDays,
        fromHours,
        fromMicroseconds,
        fromMilliseconds,
        fromMinutes,
        fromNanoseconds,
        fromSeconds,
        fromWeeks,
        getDays,
        zero,
        getHours,
        getMinutes,
        getNanoseconds,
        getSeconds,
        getWeeks,
    ] imports [
        Utils,
    ]

## An amount of time measured to the nanosecond.
##
## The maximum value of this type is Num.maxI64 seconds + 999_999_999 nanoseconds, approximately 292 billion years.
## The minimum value of this type is Num.minI64 seconds + 999_999_999 nanoseconds, approximately -292 billion years.
Duration : { seconds : I64, nanoseconds : U32 }

# Constructors

## Zero duration.
zero = { seconds: 0, nanoseconds: 0 }

## Convert a number of nanoseconds to a duration.
fromNanoseconds : I64 -> Duration
fromNanoseconds = \nanoseconds ->
    (seconds, nanosecondsRemainder) = Utils.flooredIntegerDivisionAndModulus nanoseconds (Utils.secondsToNanoseconds 1)
    if Num.isNegative nanosecondsRemainder then
        {
            seconds: (seconds - 1),
            nanoseconds: Num.toU32 ((Utils.secondsToNanoseconds 1) + nanosecondsRemainder),
        }
    else
        {
            seconds: seconds,
            nanoseconds: Num.toU32 nanosecondsRemainder,
        }

expect
    out = fromNanoseconds 123
    out == { seconds: 0, nanoseconds: 123 }

expect
    out = fromNanoseconds -123
    out == { seconds: -1, nanoseconds: 999_999_877 }

## Convert a number of milliseconds to a duration.
fromMilliseconds : I64 -> Duration
fromMilliseconds = \milliseconds ->
    (seconds, millisecondsRemainder) = Utils.flooredIntegerDivisionAndModulus milliseconds (Utils.millisecondsToNanoseconds 1)
    if Num.isNegative millisecondsRemainder then
        {
            seconds: (seconds - 1),
            nanoseconds: Num.toU32 ((Utils.secondsToNanoseconds 1) + (Utils.millisecondsToNanoseconds millisecondsRemainder)),
        }
    else
        {
            seconds: seconds,
            nanoseconds: Num.toU32 (Utils.millisecondsToNanoseconds millisecondsRemainder),
        }

expect
    out = fromMilliseconds 123
    out == { seconds: 0, nanoseconds: 123_000_000 }

expect
    out = fromMilliseconds -123
    out == { seconds: -1, nanoseconds: 877_000_000 }

## Convert a number of microseconds to a duration.
fromMicroseconds : I64 -> Duration
fromMicroseconds = \microseconds ->
    (seconds, microsecondsRemainder) = Utils.flooredIntegerDivisionAndModulus microseconds (Utils.secondsToMicroseconds 1)
    if Num.isNegative microsecondsRemainder then
        {
            seconds: (seconds - 1),
            nanoseconds: Num.toU32 ((Utils.secondsToNanoseconds 1) + (Utils.microsecondsToNanoseconds microsecondsRemainder)),
        }
    else
        {
            seconds: seconds,
            nanoseconds: Num.toU32 (Utils.microsecondsToNanoseconds microsecondsRemainder),
        }

expect
    out = fromMicroseconds 123
    out == { seconds: 0, nanoseconds: 123_000 }

expect
    out = fromMicroseconds -123
    out == { seconds: -1, nanoseconds: 999_877_000 }

## Convert a number of seconds to a duration.
fromSeconds : I64 -> Duration
fromSeconds = \seconds -> { seconds, nanoseconds: 0 }

expect
    out = fromSeconds 123
    out == { seconds: 123, nanoseconds: 0 }

## Convert a number of minutes to a duration.
fromMinutes : I64 -> Duration
fromMinutes = \minutes -> { seconds: Utils.minutesToSeconds minutes, nanoseconds: 0 }

expect
    out = fromMinutes 123
    out == { seconds: 7380, nanoseconds: 0 }

## Convert a number of hours to a duration.
fromHours : I64 -> Duration
fromHours = \hours -> { seconds: Utils.hoursToSeconds hours, nanoseconds: 0 }

expect
    out = fromHours 123
    out == { seconds: 442_800, nanoseconds: 0 }

## Convert a number of days to a duration.
fromDays : I64 -> Duration
fromDays = \days -> { seconds: Utils.daysToSeconds days, nanoseconds: 0 }

expect
    out = fromDays 123
    out == { seconds: 10_627_200, nanoseconds: 0 }

## Convert a number of weeks to a duration.
fromWeeks : I64 -> Duration
fromWeeks = \weeks -> { seconds: Utils.weeksToSeconds weeks, nanoseconds: 0 }

expect
    out = fromWeeks 123
    out == { seconds: 74_390_400, nanoseconds: 0 }

# Methods

## getNanosecondsModSecond
getNanosecondsModSecond : Duration -> U32
getNanosecondsModSecond = \duration -> duration.nanoseconds

## Get the number of nanoseconds in the duration.
getNanoseconds : Duration -> I64
getNanoseconds = \duration ->
    seconds = getSeconds duration
    nanoseconds = getNanosecondsModSecond duration
    (Utils.secondsToNanoseconds seconds) + (if Num.isPositive seconds then 1 else -1) * (Num.toI64 nanoseconds)

expect
    out = getNanoseconds { seconds: 1, nanoseconds: 0 }
    out == 1_000_000_000

expect
    out = getNanoseconds { seconds: -1, nanoseconds: 0 }
    out == -1_000_000_000

expect
    out = getNanoseconds { seconds: 1, nanoseconds: 500_000_000 }
    out == 1_500_000_000

expect
    out = getNanoseconds { seconds: -1, nanoseconds: 500_000_000 }
    out == -500_000_000

## Get the number of whole seconds in the duration, rounded towards zero.
getSeconds : Duration -> I64
getSeconds = \duration ->
    if (Num.isNegative duration.seconds) && (Num.isPositive duration.nanoseconds) then
        duration.seconds + 1
    else
        duration.seconds

expect
    out = getSeconds { seconds: 1, nanoseconds: 0 }
    out == 1

expect
    out = getSeconds { seconds: -1, nanoseconds: 0 }
    out == -1

expect
    out = getSeconds { seconds: 0, nanoseconds: 500_000_000 }
    out == 0

expect
    out = getSeconds { seconds: 1, nanoseconds: 500_000_000 }
    out == 1

expect
    out = getSeconds { seconds: -1, nanoseconds: 500_000_000 }
    out == 0

## Get the number of whole minutes in the duration, rounded towards zero.
getMinutes : Duration -> I64
getMinutes = \duration -> (getSeconds duration) // (Utils.minutesToSeconds 1)

## Get the number of whole hours in the duration, rounded towards zero.
getHours : Duration -> I64
getHours = \duration -> (getSeconds duration) // (Utils.hoursToSeconds 1)

## Get the number of whole days in the duration, rounded towards zero.
getDays : Duration -> I64
getDays = \duration -> (getSeconds duration) // (Utils.daysToSeconds 1)

## Get the number of whole weeks in the duration, rounded towards zero.
getWeeks : Duration -> I64
getWeeks = \duration -> (getSeconds duration) // (Utils.weeksToSeconds 1)

## Add two durations together.
add : Duration, Duration -> Duration
add = \a, b ->
    seconds = a.seconds + b.seconds
    nanoseconds = a.nanoseconds + b.nanoseconds
    if (nanoseconds >= (Utils.secondsToNanoseconds 1)) then
        { seconds: seconds + 1, nanoseconds: nanoseconds - (Utils.secondsToNanoseconds 1) }
    else
        { seconds, nanoseconds }

expect
    oneSecond = { seconds: 1, nanoseconds: 0 }
    twoSeconds = { seconds: 2, nanoseconds: 0 }
    threeSeconds = { seconds: 3, nanoseconds: 0 }
    out = add oneSecond twoSeconds
    out == threeSeconds

expect
    oneAndAHalfSeconds = { seconds: 1, nanoseconds: 500_000_000 }
    threeSeconds = { seconds: 3, nanoseconds: 0 }
    out = add oneAndAHalfSeconds oneAndAHalfSeconds
    out == threeSeconds
