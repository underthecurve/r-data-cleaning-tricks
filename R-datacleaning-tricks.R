########################################
## Tricks for cleaning your data in R 
##    Christine Zhang  			          
##     @christinezhang                
##  ychristinezhang at gmail dot com  
########################################

## Tricks for cleaning your data in R
## By Christine Zhang (@christinezhang on Twitter; ychristinezhang at gmail dot com)

# Link to annotated code: 
# https://github.com/underthecurve/r-data-cleaning-tricks/blob/master/R-datacleaning-tricks.md (markdown file for viewing on the web)
# https://github.com/underthecurve/r-data-cleaning-tricks/blob/master/R-datacleaning-tricks.pdf (pdf file for printing out)

# Before starting, ensure this .R file and the following data files are in the same folder:
# "employee-earnings-report-2016.csv"
# "unemployment.xlsx"
# "attendees.csv"

# We need to tell R that our files are saved in the same location.
# In order to do this, you should click through the following:
# "Session --> Set Working Directory --> To Source File Location"

# In this workshop, I'll show you some examples of real-life "messy" datasets, the problems they present for analysis in R, and the "tidy" solutions to these problems.

#### 1. Finding and replacing non-numeric characters like , and $ ####

salary <- read.csv('employee-earnings-report-2016.csv')

head(salary)

# install.packages('dplyr') # if you don't already have the 'dplyr' package
library('dplyr') # load the dplyr package
salary.selected <- select(salary, # the data frame
                          NAME, DEPARTMENT_NAME, TOTAL.EARNINGS) # the variables to select

names(salary.selected) <- tolower(names(salary.selected)) # change variable names to lowercase

head(salary.selected)

salary.sort <-  arrange(salary.selected, # dataset to sort
                        total.earnings) # variable to sort by

head(salary.sort)

## What went wrong?

class(salary.selected$total.earnings)

# install.packages('stringr') # if you don't already have the 'stringr' package
library('stringr') # load the stringr package

salary.selected$total.earnings <- str_replace(
    salary.selected$total.earnings, # column we want to search
    pattern = ',', # what to find
    replacement = '' # what to replace it with
)

head(salary.selected) # this works - the commas are gone

salary.selected$total.earnings <- str_replace(
    salary.selected$total.earnings, # column we want to search
    pattern = '$', # what to find
    replacement = '' # what to replace it with
)

head(salary.selected) # this didn't work - the dollar signs are still there

salary.selected$total.earnings <- str_replace(
    salary.selected$total.earnings, # column we want to search
    pattern = '\\$', # what to find
    replacement = '' # what to replace it with
)

head(salary.selected)

# Will this work?
salary.sort <- arrange(salary.selected, 
                       total.earnings)

salary.selected$total.earnings <- as.numeric(salary.selected$total.earnings)

class(salary.selected$total.earnings)

salary.sort <- arrange(salary.selected,
                       total.earnings)

head(salary.sort) # ascending order by default

salary.sort <- arrange(salary.selected,
                       desc(total.earnings)) # descending order

head(salary.sort) # Waiman Lee from the Boston PD is the highest paid city employee

# Now would be a good time to introduce `%>%`, known as the pipe operator.
# `%>%` is an extremely valuable tool in R, because it allows functions to be chained rather than nested. `%>` looks strange but can be read as "then"—it tells R to do whatever comes after it to the stuff comes before it.

salary.average <- salary.selected %>% # take the salary.selected data frame, THEN
  group_by(department_name) %>% # group by department_name, THEN
  summarise(average.earnings = mean(total.earnings)) # calculate the mean of total.earnings for each department_name and name this average.earnings

head(salary.average) # first six rows of average salary by department (alphabetical order)

salary.average %>% filter(department_name == 'Boston Police Department')

# Exercise: The `salary.average` data frame is currently ordered alphabetically by department. How would you sort this dataset by average earnings, from highest to lowest?

#### 2. Merging datasets ####

salary.merged <- merge(x = salary.sort, y = salary.average, by = 'department_name')

head(salary.merged)

#### 3. Reshaping data ####

# install.packages('readxl') # if you don't already have the 'readxl' package
library('readxl') # load the readxl package

unemployment <- read_excel('unemployment.xlsx') 

# install.packages('tidyr') # if you don't already have the 'tidyr' package
library('tidyr') # load the tidyr package

unemployment.long <- gather(unemployment, # data to reshape
                            Year, # column we want to create from the rows
                            Rate.Unemployed, # the values of interest
                            -Country # already a column in the data
                            )

head(unemployment.long)

class(unemployment.long$Rate.Unemployed) ## "character", not "numeric"

# Why do you think this is? (hint, use `head()` to find out)

unemployment.long$Rate.Unemployed <- as.numeric(unemployment.long$Rate.Unemployed)

str(unemployment.long) # Rate.Unemployed is now "num", which stands for "numeric"

# Exercise: How would we sort `uemployment.long` by Country, then Year using the `arrange() function in `dplyr`?

#### 4. Calculating year-over-year change in panel data ####

unemployment.long <- arrange(unemployment.long, # data frame to sort
                             Country, Year) # variables to sort by

unemployment.long <- unemployment.long %>% # Take the unemployment.long data frame, THEN
  arrange(Country, Year) # sort it by Country and then Year.

head(unemployment.long, 5) # First five rows of the data

unemployment.long <- unemployment.long %>% # take the unemployment.long dataset, THEN
  mutate(Change = Rate.Unemployed - lag(Rate.Unemployed)) # create a variable called Change

head(unemployment.long, 5)

tail(unemployment.long, 5) # last five rows of the data

# Why does Vietnam have a -18.493 percentage point change in 2012?

unemployment.long <- unemployment.long %>% 
  group_by(Country) %>%
  mutate(Change = Rate.Unemployed - lag(Rate.Unemployed))

tail(unemployment.long, 5)

#### 5. Recoding numerical variables into categorical ones ####

attendees <- read.csv('attendees.csv', stringsAsFactors = F)
head(attendees)

table(attendees$Age.group)

attendees$Age.group <- ifelse(attendees$Age.group == '30 - 39', # if attendees$Age.group == '30 - 39'
                              '30-39', # replace attendees$Age.group with '30-39'
                              attendees$Age.group) # otherwise, keep attendees$Age.group values the same

table(attendees$Age.group)

table(attendees$Choose.your.status.)

attendees$status <- ifelse(attendees$Choose.your.status. == 'Nonprofit, Academic, Government' |
                             attendees$Choose.your.status. == 'Nonprofit, Academic, Government Early Bird',
                           'Nonprofit/Gov', 
                           attendees$Choose.your.status.)
table(attendees$status)

#### What else? ####

# - How would you use `ifelse()` and `|` to create a new variable in the `attendees` data (let's call it `status2`) that has just two categories, "Student" and "Other"? 
                                                                                         
# - How would you rename the variables in the `attendees` data to make them easier to work with?
                                                                                         
# - What are some other issues with this dataset that could be solved using the data cleaning tools we've learned today?  
                                                                                         
# - What are some other "messy" data issues you've encountered?
