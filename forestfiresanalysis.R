
# Variables: spatial (X,Y), temporal (month, day), FWI indices (FFMC, DMC, DC, ISI), weather (temp, RH, wind, rain), area burned


#Libraries
library(tidyverse)   # dplyr, ggplot2, tidyr, readr, etc.
library(corrplot)    # correlation heatmap
library(gridExtra)   # arrange multiple ggplots
library(scales)      # axis formatting


# Place forestfires.csv in your working directory, or adjust the path below.

View(forestfires)

df <- forestfires
               col_types = cols(
  X     = col_integer(),
  Y     = col_integer(),
  month = col_factor(levels = c("jan","feb","mar","apr","may",
                                "jun","jul","aug","sep","oct",
                                "nov","dec")),
  day   = col_factor(levels = c("mon","tue","wed","thu",
                                "fri","sat","sun")), .default = col_double()
)


cat("Dimensions:", nrow(df), "rows ×", ncol(df), "columns\n")
glimpse(df)

# Summary Statistics

summary(df)

# Share of fires with zero burned area

zero_pct <- mean(df$area == 0) * 100
#Fires with zero burned area: 47.8%

#Log-transform burned area (standard for this dataset)
# area is heavily right-skewed; log(area + 1) is the conventional transform.
df <- df %>% mutate(log_area = log1p(area))

#Periodical Patterns

#Fires per month 
month_counts = table(df$month)

barplot(month_counts,
        main = "Number of Fires by Month",
        xlab = "Month",
        ylab = "Fire count",
        col  = "steelblue",
        las  = 2)

#Median burned area by month 
median_by_month <- tapply(df$log_area, df$month, median)

barplot(median_by_month,
        main = "Median log(area+1) by Month",
        xlab = "Month",
        ylab = "Median log(area+1)",
        col  = "coral",
        las  = 2)

#Fires per day of week 
day_counts <- table(df$day)

barplot(day_counts,
        main = "Number of Fires by Day of Week",
        xlab = "Day",
        ylab = "Fire count",
        col  = "mediumseagreen",
        las  = 2)

#Spatial Distribution
# X = 1–9 (west–east), Y = 2–9 (south–north) grid coordinates
p_spatial <- df %>%
  group_by(X, Y) %>%
  summarise(n = n(), total_area = sum(area), .groups = "drop") %>%
  ggplot(aes(x = X, y = Y)) +
  geom_tile(aes(fill = n), colour = "white", linewidth = 0.5) +
  geom_text(aes(label = n), size = 3, colour = "white", fontface = "bold") +
  scale_fill_gradient(low = "#ffffd4", high = "#b10026", name = "Fire count") +
  scale_x_continuous(breaks = 1:9) +
  scale_y_continuous(breaks = 2:9) +
  labs(title = "Fire Frequency by Grid Cell (Montesinho Park)",
       x = "X coordinate (W → E)", y = "Y coordinate (S → N)") +
  theme_minimal(base_size = 13) +
  coord_fixed()

print(p_spatial)

#Weather & FWI Distributions 
numeric_vars <- c("FFMC","DMC","DC","ISI","temp","RH","wind","rain","log_area")

plot_list <- map(numeric_vars, function(v) {
  ggplot(df, aes(x = .data[[v]])) +
    geom_histogram(bins = 30, fill = "#2166ac", alpha = 0.75, colour = "white") +
    labs(title = v, x = NULL, y = NULL) +
    theme_minimal(base_size = 11)
})
grid.arrange(grobs = plot_list, ncol = 3,
             top = "Variable Distributions (log_area = log(area+1))")

# Correlation Matrix 
cor_data = df[, c("FFMC","DMC","DC","ISI","temp","RH","wind","rain","log_area")]
cor_mat  <- cor(cor_data, use = "complete.obs")

corrplot(cor_mat,
         method   = "color",
         type     = "upper",
         addCoef.col = "black",
         number.cex  = 0.75,
         tl.col   = "black",
         tl.srt   = 45,
         col      = colorRampPalette(c("#d73027","white","#4575b4"))(200),
         title    = "Pearson Correlation Matrix",
         mar      = c(0,0,2,0))

#Burned Area vs. Key Predictors
predictors <- c("temp","FFMC","DMC","DC","ISI","RH","wind")

scatter_list <- map(predictors, function(v) {
  ggplot(df, aes(x = .data[[v]], y = log_area)) +
    geom_point(alpha = 0.3, colour = "#d73027", size = 1.5) +
    geom_smooth(method = "loess", se = TRUE, colour = "#2166ac", linewidth = 0.8) +
    labs(title = paste(v, "vs log(area+1)"), x = v, y = "log(area+1)") +
    theme_minimal(base_size = 11)
})
grid.arrange(grobs = scatter_list, ncol = 3,
             top = "Burned Area vs. Weather & FWI Variables (LOESS fit)")

#Boxplots: log(area) by Month and by Day
# Boxplot of burned area by month
boxplot(log_area ~ month, data = df,
        main  = "Burned Area by Month",
        xlab  = "Month",
        ylab  = "log(area+1)",
        col   = "steelblue",
        las   = 2)

# Boxplot of burned area by day of week
boxplot(log_area ~ day, data = df,
        main  = "Burned Area by Day of Week",
        xlab  = "Day",
        ylab  = "log(area+1)",
        col   = "coral",
        las   = 2)

#Simple Linear Regression
# Predict log(area+1) from weather and FWI indices.

lm_FWI_indices <- lm(log_area ~ FFMC + DMC + DC + ISI + temp + RH + wind + rain,
             data = df)
print(summary(lm_FWI_indices))

