# library(tidyverse)

#----- import data -----
#' grab the names of columns to be used in the dataset
var_names = read_csv(here::here("data", "moj_raw_data.csv"), 
                   col_names = T,
                   skip = 1,
                   n_max = 0)

#' main dataset with the colnames extracted above 
dataset = read_csv(here::here("data", "moj_raw_data.csv"), 
                   col_names = colnames(var_names),
                   skip = 3) %>% 
  rowid_to_column("pid")


#---- data processing -----
#' clean up column names so that it's easy to process  
dataset = dataset %>% 
  rename_all(stringr::str_remove_all, "\\(in seconds\\)|..1")  %>%  
  # get rid of white spaces
  rename_all(stringr::str_remove_all, "\\s") 


#' recode values that are mis-coded 
# `joel_amazingness` levels range from 31 to 36; recoding it so that it ranges from 1 - 6
# `joel_season` levels range from 5 to 8; recoding it so that it ranges from 1 - 4
dataset = dataset %>% 
  mutate(joel_amazingness = joel_amazingness - 30,
         joel_season = joel_season - 4)

#----- processing for word cloud-----  
#' preparing joel descriptors for word cloud 
joel_words = dataset %>% 
select(joel_descriptors.2:joel_descriptors.4) %>% 
  rowid_to_column("pid") %>% 
  pivot_longer(cols = joel_descriptors.2:joel_descriptors.4,
               names_to = "word_rank",
               values_to = "word",
               names_prefix = "joel_descriptors.") %>% 
  drop_na(word) %>% 
  mutate_at("word", tolower)


#----data dictionary----
# import dictionary for every question
c("joel_amazingness", "joel_version", "joel_season", "joel_goose", "joel_conspiracy") %>% 
  purrr::map(function(sheet_name) {
    assign(x = sheet_name,
           value = readxl::read_excel(here::here("data_dictionary.xlsx"),
                                      sheet = sheet_name),
           envir = .GlobalEnv)
    })

readxl::read_excel(here::here("data_dictionary.xlsx"))

#---- clean up ----
rm(list = c("var_names"))
