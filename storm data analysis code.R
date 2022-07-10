# The package "dplyr" is useful for simplification of data manipulation process.
# The author of the "dplyr" are Eli Miller, Mike Stackhouse, Ashley Tarasiewicz, Nathan Kosiba, Atorus Research LLC.
# The manipulation works on three categories of dataset component: 
# 
# Manipulation of Rows:
# filter() chooses rows based on column values.
# slice() chooses rows based on location.
# arrange() changes the order of the rows.
# Manipulation of Columns:
# select() changes whether or not a column is included.
# rename() changes the name of columns.
# mutate() changes the values of columns and creates new columns.
# relocate() changes the order of the columns.
# Manipulation of Groups of rows:
#   summarise() collapses a group into a single row.


### 
# filter() subsets rows using column conditions.
# syntax: filter(your data, condition1 & condition 2....) or data %>% filter(condition1 & condition 2....)
# data type: a data frame or a tibble
# conditions: expressions that return a logical value
# when a condition return NA the row will be removed (Different from base subsetting using "[") 
###

###
# mutate() adds new variables/columns w/o removing the existing variables to/from a dataframe
# transmute() adds new variables/columns + removing the existing variables used to create new variables
# data type: a data frame or a tibble
# syntax: mutate(data, )

# 1. Loading data and preview data
# This data is a subset of the NOAA Atlantic hurricane database best track data, https://www.nhc.noaa.gov/data/#hurdat. 
# The data includes the positions and attributes of storms from 1975-2020, measured every six hours during the lifetime of a storm.


data() # see all the built-in dataset in R
library(dplyr)
data(storms) 
head(storms)
str(storms)
?storms


# 2. Checking number of rows (observations) and columns (variables)
nrow(storms)
ncol(storms)
colnames(storms)
rownames(storms)

# 3. Analysis:
# (1) Which month has highest storm developed from year from 1990 to 2010 (accumulated)
# and what were the status they develop (Tropical Depression, Tropical Storm, or to Hurricane)


# issue 1: the same storm has been recorded multiple times but I want to count it only once
# solution 1: apply distinct()
# issue 2: different storms with same names were presented in the data set: 
# solution 2: the storm name list usually contain do not repeat in the same year
# so I can group by year and status first before performing distinct() to keep the different storms




length(unique(storms$status))
unique(storms$status)

data = NULL
for(i in 1:length(unique(storms$status))){
  data[[i]] <- storms %>% 
    # step 1: group by year and status first before performing distinct() 
    # to keep the different storms with same names
    group_by(year, status) %>% 
    
    # step 2: filter by year and storm status
    filter(year >= 1990 & year <= 2010 & status == unique(storms$status)[i]) %>% 
    # step 3: keep only one name for the same storm from same status
    distinct(name, .keep_all = TRUE) %>% 
    ungroup() %>% 
    group_by(month) %>% 
    summarise(n = n())
  
}

data

# issue 3: the month without storm do not show in the tibble
# solution: assign 0 to the month without storm

vec = NULL
df_ordered = NULL


for(i in 1:length(data)){
  # iterate through subset of data with different storm status
  x = data[[i]]
  
 
  for(j in 1:12) {
    # put the month without storms into a vector 
    if (j %in% x$month == F){
      vec[j] <- j
    } else {
      
    }
    
    vec <- vec[!is.na(vec)]
    # assign 0 as n to the month without storms 
    df <- data.frame(month = vec, n = rep(0, length(vec)))
    # combine the new df with original tibble
    df_new <- rbind(x,df)
    # order the combined df by month
    df_ordered[[i]] <- arrange(df_new, month)

  }
  
}

df_ordered

df_ordered[[2]] <- distinct(df_ordered[[2]])

# assign names to the list
names(df_ordered) <- unique(storms$status)

df_ordered

library(ggplot2)

# assign status to new column: status
# use mutate() and cbind() to ordered df with new columns
# combine three status df together
a <- mutate(df_ordered[[1]], data.frame(status = names(df_ordered[1])))
b <- mutate(df_ordered[[2]], data.frame(status = names(df_ordered[2])))
c <- mutate(df_ordered[[3]], data.frame(status = names(df_ordered[3])))
final_data <- rbind(a, b, c)

# visualize accumulated storm number per month from 1990 to 2010
ggplot(final_data, mapping = aes(x = month, y = n, color = status)) +
  geom_point(size = 3) +
  geom_line(size =1) +
  theme_classic() +
  labs(title ="Accumulated Storm Number Per Month From 1990 to 2010", 
       x = "Month", y = "Storm Status",
       color = "Storm Status") +
  scale_x_continuous(limits = c(1, 12), breaks = seq(1, 12, by =1)) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, by =20)) +
  theme(axis.text.x = element_text(face = "bold", size =12, color = "black"),
        axis.text.y = element_text(face = "bold", size =12, color = "black"),
        axis.title = element_text(face = "bold", size =14, color = "black"),
        plot.title = element_text(face = "bold", hjust = 0.5, size=14),
        legend.position = c(0.15,0.8),
        legend.title = element_text(face = "bold", size = 12))

# save the ggplot to a png
ggsave("Accumulated Storm Per Month 1990 to 2010.png")
