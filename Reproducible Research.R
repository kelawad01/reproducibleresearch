# Make sure the data set activity.csv in your working directory

library(lubridate)
library(ggplot2)
library(dplyr)
df <-
        read.csv(
                "activity.csv",
                header = TRUE,
                sep = ',',
                colClasses = c("numeric", "character", "integer")
        )
df$date <- ymd(df$date)

newdf <- aggregate(df$steps, list(df$date), FUN = sum)

colnames(newdf) <- c("Date", "Steps")

g <-
        ggplot(newdf, aes(Steps)) + geom_histogram(binwidth = 3000, fill = "red") + ggtitle("Steps per Day") + xlab("Daily Steps") + ylab("Frequency")

g

mean_steps <- mean(newdf$Steps, na.rm = TRUE)

mean_steps

median_steps <- median(newdf$Steps, na.rm = TRUE)

median_steps

steps_time_series <-
        aggregate(steps ~ interval,
                  data = df,
                  FUN = mean,
                  na.action = na.omit)

steps_time_series$time <- steps_time_series$interval

g2 <-
        ggplot(steps_time_series, aes(time, steps)) + geom_line(col = "red") + ggtitle("Average steps per time interval") + xlab("Time") + ylab("Average Steps")

g2

steps_time_series[which.max(steps_time_series$steps),]

df_fill <- df
missing <- is.na(df_fill$steps)
interval_average <-
        tapply(df_fill$steps,
               df_fill$interval,
               mean,
               na.rm = TRUE,
               simplify = TRUE)
df_fill$steps[missing] <-
        interval_average[as.character(df_fill$interval[missing])]

newdf_fill <-
        aggregate(df_fill$steps, list(df_fill$date), FUN = sum)
colnames(newdf_fill) <- c("Dates, Steps")

g3 <-
        ggplot(newdf_fill, aes(Steps)) + geom_histogram(binwidth = 3000, fill = "blue") + ggtitle("Steps per Day (filled missing values") + xlab("Daily Steps") + ylab("Frequency")

mean_steps_fill <- mean(newdf_fill$Steps)
mean_steps_fill

median_steps_fill <- median(newdf_fill$Steps)
median_steps_fill

df_fill$numdate <- as.Date(df_fill$date, format = "%Y-%m-%d")
df_fill$day <- weekdays(df_fill$numdate)
df_fill$type <-
        ifelse(df_fill$day == 'Saturday' |
                       df_fill$day == 'Sunday',
               'weekend',
               'weekday')

steps_time_series_fill <-
        aggregate(
                steps ~ interval + type,
                data = df_fill,
                FUN = mean,
                na.action = na.omit
        )

steps_time_series_fill$time <- steps_time_series$interval

g4 <-
        ggplot(steps_time_series_fill, aes(time, steps)) + geom_line(col = "blue") + ggtitle("Steps per time interval: weekends/weekdays") + xlab("Time") + ylab("Steps") + facet_grid(type ~ .)

g4