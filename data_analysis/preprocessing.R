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


#' bday messages 
bday_msgs = read_csv(here::here("data", "moj_bday_msgs.csv"), 
                     col_names = read_csv(here::here("data", "moj_bday_msgs.csv"), 
                                          col_names = T,
                                          skip = 1,
                                          n_max = 0) %>% 
                       colnames(),
                     skip = 3) 


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

#' tokenizing b-day msgs 
bday_words = bday_msgs %>% 
  rowid_to_column("sender") %>% 
  mutate_at("bday_msg", ~stringr::str_replace_all(., c(":heart:" = "\U1F496",
                                                       ":hugging_face:" = "\U1F917",
                                                       ":partying_face:" = "\U1F973",
                                                       ":sparkling_heart:" = "\U1F496",
                                                       ":star-struck:" = "\U1F929",
                                                       ":nerd_face:" = "\U1F913",
                                                       ":partying_face:" = "\U1F973",
                                                       ":heart_eyes:" = "\U1F60D",
                                                       ":desert_island:" = "\U1F3DD",
                                                       ":tropical_drink:" = "\U1F379",
                                                       ":full_moon_with_face:" = "\U1F31D",
                                                       ":thumb_up:" = "\U1F44D",
                                                       ":tada:" = "\U1F389",
                                                       ":bouquet:" = "\U1F490",
                                                       ":champagne:" = "\U1F942"))) %>% 
  tidytext::unnest_tokens(word, bday_msg) %>% 
  dplyr::anti_join(tidytext::get_stopwords()) %>% 
  group_by(sender) %>% 
  distinct(word) %>% 
  ungroup()

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
