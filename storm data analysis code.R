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
# (1) Does the month affect the status of storm (Tropical Depression, Tropical Storm, or Hurricane) for storms tracked from 2000 to 2020

# filter the storm tracked from 1990 to 2010

storms %>% filter(year >= 2000 & year <= 2020)

# in base R, you can filter by:
# storms[storms$year >= 1990 & storms$year <= 2010, ]

# issue 1: the same storm has been recorded multiple times but I want to count it only once
# solution 1: apply distinct()
# issue 2: different storms with same names were presented in the data set: 
# solution 2: group by year first before performing distinct() to keep the different storms with same names

storms %>% 
  filter(status == "tropical depression")
  
  

  storms %>%
  group_by(year) %>% 
  filter(year >= 1990 & year <= 2010 & status == "tropical depression") %>% 
  distinct(name, .keep_all = TRUE) %>% 
  ungroup() %>% 
  group_by(month)

   %>% 
  summarise(n = n())
  
  
  
  mutate(count(unique(name)))
 


