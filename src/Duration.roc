interface Duration exposes [
        add,
        Duration,
        from,
        fromDays,
        fromHours,
        fromMicroseconds,
        fromMilliseconds,
        fromMinutes,
        fromNanoseconds,
        fromSeconds,
        fromWeeks,
        getDays,
        getHours,
        getMinutes,
        getNanoseconds,
        getSeconds,
        getWeeks,
        max,
        min,
        zero,
    ] imports [
        Utils,
        Conversion,
    ]

## An amount of time measured to the nanosecond.
##
## The maximum value of this type is Num.maxI64 seconds + 999_999_999 nanoseconds, approximately 292 billion years.
## The minimum value of this type is Num.minI64 seconds + 999_999_999 nanoseconds, approximately -292 billion years.
Duration : { seconds : I64, nanoseconds : U32 }

# Constructors

## Zero duration.
zero = { seconds: 0, nanoseconds: 0 }

## The maximum possible duration, approximately 292 billion years
max : Duration
max = { seconds: Num.maxI64, nanoseconds: 999_999_999 }

## The minimum possible duration, approximately -292 billion years.
min : Duration
min = { seconds: Num.minI64, nanoseconds: 0 }

## Convert a number of nanoseconds to a duration.
fromNanoseconds : I64 -> Duration
fromNanoseconds = \nanoseconds ->
    (seconds, nanosecondsRemainder) = Utils.flooredIntegerDivisionAndModulus nanoseconds Conversion.nanosecondsInASecond
    if Num.isNegative nanosecondsRemainder then
        {
            seconds: (seconds - 1),
            nanoseconds: Num.toU32 (Conversion.nanosecondsInASecond + nanosecondsRemainder),
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
    (seconds, millisecondsRemainder) = Utils.flooredIntegerDivisionAndModulus milliseconds Conversion.nanosecondsInAMillisecond
    if Num.isNegative millisecondsRemainder then
        {
            seconds: (seconds - 1),
            nanoseconds: Num.toU32 (Conversion.nanosecondsInASecond + (Conversion.millisecondsToNanoseconds millisecondsRemainder)),
        }
    else
        {
            seconds: seconds,
            nanoseconds: Num.toU32 (Conversion.millisecondsToNanoseconds millisecondsRemainder),
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
    (seconds, microsecondsRemainder) = Utils.flooredIntegerDivisionAndModulus microseconds Conversion.microsecondsInASecond
    if Num.isNegative microsecondsRemainder then
        {
            seconds: (seconds - 1),
            nanoseconds: Num.toU32 (Conversion.nanosecondsInASecond + (Conversion.microsecondsToNanoseconds microsecondsRemainder)),
        }
    else
        {
            seconds: seconds,
            nanoseconds: Num.toU32 (Conversion.microsecondsToNanoseconds microsecondsRemainder),
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
fromMinutes = \minutes -> { seconds: Conversion.minutesToSeconds minutes, nanoseconds: 0 }

expect
    out = fromMinutes 123
    out == { seconds: 7380, nanoseconds: 0 }

## Convert a number of hours to a duration.
fromHours : I64 -> Duration
fromHours = \hours -> { seconds: Conversion.hoursToSeconds hours, nanoseconds: 0 }

expect
    out = fromHours 123
    out == { seconds: 442_800, nanoseconds: 0 }

## Convert a number of days to a duration.
fromDays : I64 -> Duration
fromDays = \days -> { seconds: Conversion.daysToSeconds days, nanoseconds: 0 }

expect
    out = fromDays 123
    out == { seconds: 10_627_200, nanoseconds: 0 }

## Convert a number of weeks to a duration.
fromWeeks : I64 -> Duration
fromWeeks = \weeks -> { seconds: Conversion.weeksToSeconds weeks, nanoseconds: 0 }

expect
    out = fromWeeks 123
    out == { seconds: 74_390_400, nanoseconds: 0 }

## Convert a number of time units to a duration.
from : I64, [Nanoseconds, Milliseconds, Microseconds, Seconds, Minutes, Hours, Days, Weeks] -> Duration
from = \value, unit ->
    when unit is
        Nanoseconds -> fromNanoseconds value
        Milliseconds -> fromMilliseconds value
        Microseconds -> fromMicroseconds value
        Seconds -> fromSeconds value
        Minutes -> fromMinutes value
        Hours -> fromHours value
        Days -> fromDays value
        Weeks -> fromWeeks value

expect
    out = from 123 Nanoseconds
    out == { seconds: 0, nanoseconds: 123 }

expect
    out = from -123 Nanoseconds
    out == { seconds: -1, nanoseconds: 999_999_877 }

expect
    out = from 123 Milliseconds
    out == { seconds: 0, nanoseconds: 123_000_000 }

expect
    out = from -123 Milliseconds
    out == { seconds: -1, nanoseconds: 877_000_000 }

expect
    out = from 123 Microseconds
    out == { seconds: 0, nanoseconds: 123_000 }

expect
    out = from -123 Microseconds
    out == { seconds: -1, nanoseconds: 999_877_000 }

expect
    out = from 123 Seconds
    out == { seconds: 123, nanoseconds: 0 }

expect
    out = from 123 Minutes
    out == { seconds: 7380, nanoseconds: 0 }

expect
    out = from 123 Hours
    out == { seconds: 442_800, nanoseconds: 0 }

expect
    out = from 123 Days
    out == { seconds: 10_627_200, nanoseconds: 0 }

expect
    out = from 123 Weeks
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
    (Conversion.secondsToNanoseconds seconds) + (if Num.isPositive seconds then 1 else -1) * (Num.toI64 nanoseconds)

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
getMinutes = \duration -> duration |> getSeconds |> Conversion.secondsToWholeMinutes

## Get the number of whole hours in the duration, rounded towards zero.
getHours : Duration -> I64
getHours = \duration -> duration |> getSeconds |> Conversion.secondsToWholeHours

## Get the number of whole days in the duration, rounded towards zero.
getDays : Duration -> I64
getDays = \duration -> duration |> getSeconds |> Conversion.secondsToWholeDays

## Get the number of whole weeks in the duration, rounded towards zero.
getWeeks : Duration -> I64
getWeeks = \duration -> duration |> getSeconds |> Conversion.secondsToWholeWeeks

## Add two durations together.
add : Duration, Duration -> Duration
add = \a, b ->
    seconds = a.seconds + b.seconds
    nanoseconds = a.nanoseconds + b.nanoseconds
    if (nanoseconds >= (Conversion.secondsToNanoseconds 1)) then
        { seconds: seconds + 1, nanoseconds: nanoseconds - (Conversion.secondsToNanoseconds 1) }
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
