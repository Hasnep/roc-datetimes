interface NaiveDateTime exposes [
        NaiveDateTime,
        epoch,
        fromYmdhmsn,
        fromYmdhms,
    ] imports [
        NaiveDate,
        NaiveDate.{ NaiveDate },
        NaiveTime,
        NaiveTime.{ NaiveTime },
    ]

## A date and time without a timezone.
NaiveDateTime : { naiveDate : NaiveDate.NaiveDate, naiveTime : NaiveTime.NaiveTime }

## You know, that epoch.
epoch : NaiveDateTime
epoch = { naiveDate: NaiveDate.epoch, naiveTime: NaiveTime.midnight }

# Constructors

## Convert a year, month, day, hour, minute, second, and nanosecond to a NaiveDateTime.
fromYmdhmsn : I64, U8, U8, U8, U8, U8, U32 -> [Ok NaiveDateTime, Err [InvalidDateTime]]
fromYmdhmsn = \year, month, day, hour, minute, second, nanosecond ->
    naiveTime = NaiveTime.fromHmsn hour minute second nanosecond
    naiveDate = NaiveDate.fromYmd year month day
    if (Result.isOk naiveTime) && (Result.isOk naiveDate) then
        Ok {
            naiveDate: naiveDate |> Result.withDefault NaiveDate.epoch,
            naiveTime: naiveTime |> Result.withDefault NaiveTime.midnight,
        }
    else
        Err InvalidDateTime

expect
    fromYmdhmsn 7 6 5 4 3 2 1
    == Ok {
        naiveDate: { year: 7, month: 6, day: 5 },
        naiveTime: { hour: 4, minute: 3, second: 2, nanosecond: 1 },
    }

fromYmdhms = \year, month, day, hour, minute, second -> fromYmdhmsn year month day hour minute second 0

expect
    out = fromYmdhms 6 5 4 3 2 1
    out
    == Ok {
        naiveDate: { year: 6, month: 5, day: 4 },
        naiveTime: { hour: 3, minute: 2, second: 1, nanosecond: 0 },
    }

# Methods

# ## add
# add : NaiveDateTime, Duration -> NaiveDateTime
# add = \naiveDateTime, duration ->
