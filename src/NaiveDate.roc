interface NaiveDate exposes [
        NaiveDate,
        fromYmd,
        toIsoStr,
        withNaiveTime,
        epoch,
    ] imports [
        Utils,
        NaiveTime.{ NaiveTime },
    ]

## A date in the Gregorian calendar without a timezone.
##
## Dates before the start of the Gregorian calendar are extrapolated, so be careful with historical dates.
## Years are 1 indexed to match the Common Era, i.e. year 1 is 1 CE, year 0 is 1 BCE, year -1 is 2 BCE, etc.
NaiveDate : { year : I64, month : U8, day : U8 }

# Constructors

## The Gregorian epoch. You know, that epoch.
epoch = { year: 1970, month: 1, day: 1 }

## Convert a year, month, and day to a NaiveDate.
fromYmd : I64, U8, U8 -> [Ok NaiveDate, Err [InvalidMonth, InvalidDay]]
fromYmd = \year, month, day ->
    if month == 0 || month > 12 then
        Err InvalidMonth
    else
        nDaysInMonth = Utils.nDaysInMonthOfYear month year |> Utils.unwrap "This should never happen, because we already checked that the month is valid."
        if day == 0 || day > nDaysInMonth then
            Err InvalidDay
        else
            Ok { year, month, day }

expect
    out = fromYmd 2023 1 1
    out == Ok { year: 2023, month: 1, day: 1 }

## Convert a year and day of year to a NaiveDate.
##
## The first day of the year is 1st January.
## Trying to convert the 0th day of the year or a day after the last day of the year returns an InvalidDayOfYear error.
fromOrdinalDate : { dayOfYear : U16, year : I64 } -> [Ok NaiveDate, Err [InvalidDayOfYear]]
fromOrdinalDate = \{ dayOfYear, year } ->
    if dayOfYear == 0 || dayOfYear > (Utils.nDaysInYear year) then
        Err InvalidDayOfYear
    else
        cumulativeDaysInYear =
            Utils.nDaysInEachMonthOfYear year
            |> List.map Num.toU16
            |> Utils.cumulativeSum
        month =
            cumulativeDaysInYear
            |> List.findLastIndex (\cumulativeDays -> dayOfYear > cumulativeDays)
            |> Utils.unwrap "This should never happen because we already checked that the day of the year is valid."
        day =
            Num.sub
                dayOfYear
                (
                    cumulativeDaysInYear
                    |> List.get month
                    |> Utils.unwrap "This should never happen because the month is an index of cumulativeDaysInYear by definition."
                    |> Num.toU16
                )
        Ok { year: year, month: Num.toU8 month, day: Num.toU8 day }

expect
    out = fromOrdinalDate { dayOfYear: 0, year: 1 } # 0th day of 1 CE
    out == Err InvalidDayOfYear

expect
    out = fromOrdinalDate { dayOfYear: 1, year: 1 } # 1st Janurary 1 CE
    out == Ok { year: 1, month: 1, day: 1 }

expect
    out = fromOrdinalDate { dayOfYear: 365, year: 1 } # 31st December 1 CE
    out == Ok { year: 1, month: 12, day: 31 }

expect
    out = fromOrdinalDate { dayOfYear: 366, year: 1 } # Day after the last day of 1 CE
    out == Err InvalidDayOfYear

expect
    out = fromOrdinalDate { dayOfYear: 366, year: 4 } # 31st December 4 CE
    out == Ok { year: 4, month: 12, day: 31 }

expect
    out = fromOrdinalDate { dayOfYear: 367, year: 4 } # Day after the last day of 4 CE
    out == Err InvalidDayOfYear

expect
    out = fromOrdinalDate { dayOfYear: 59, year: 1 } # 28th February 1 CE
    out == Ok { year: 1, month: 2, day: 28 }

## Convert a number of days since the Common Era to a NaiveDate.
##
## The zeroth day of the Common Era is 31st December, 1 BCE, and the first day of the Common Era is 1st January, 1 CE.
fromDaysSinceCE : U64 -> NaiveDate
fromDaysSinceCE = \daysSinceCE ->
    if daysSinceCE == 0 then
        { year: 0, month: 12, day: 31 }
    else
        daysSinceCEIndex = daysSinceCE - 1 + 366
        yearUpperBound = (daysSinceCEIndex // 365) + 2 # Just to be safe.
        daysInEachYear = List.range { start: At 0, end: At yearUpperBound } |> List.map Utils.nDaysInYear |> List.map Num.toU64
        { quotient: year, remainder: dayOfYearIndex } = Utils.subtractWhileGreaterThanZero daysSinceCEIndex daysInEachYear
        fromOrdinalDate { dayOfYear: Num.toU16 dayOfYearIndex + 1, year: Num.toI64 year }
        |> Utils.unwrap "This should never happen because we already checked that the day of the year is valid."

expect
    out = fromDaysSinceCE 0
    out == { year: 0, month: 12, day: 31 }

expect
    out = fromDaysSinceCE 1
    out == { year: 1, month: 1, day: 1 }

expect
    out = fromDaysSinceCE 365
    out == { year: 1, month: 12, day: 31 }

expect
    out = fromDaysSinceCE 366
    out == { year: 2, month: 1, day: 1 }

expect
    nDaysInFirstFourYearsOfCE =
        List.range { start: At 1, end: At 4 }
        |> List.map Utils.nDaysInYear
        |> List.map Num.toU64
        |> List.sum
    out = fromDaysSinceCE nDaysInFirstFourYearsOfCE
    out == { year: 4, month: 12, day: 31 }

# Serialise

## Serialise a date to ISO format.
toIsoStr = \naiveDate ->
    year = Utils.padIntegerToLength naiveDate.year 4
    month = Utils.padIntegerToLength naiveDate.month 2
    day = Utils.padIntegerToLength naiveDate.day 2
    "\(year)-\(month)-\(day)"

expect
    out = toIsoStr epoch
    out == "1970-01-01"

expect
    out = { year: 2023, month: 12, day: 31 } |> toIsoStr
    out == "2023-12-31"

# Methods

## Add a NaiveTime to a NaiveDate.
withNaiveTime = \naiveDate, naiveTime -> { naiveDate, naiveTime }

expect
    out = epoch |> withNaiveTime NaiveTime.midnight
    out == { naiveDate: epoch, naiveTime: NaiveTime.midnight }
