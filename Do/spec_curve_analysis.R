library(specr)
library(ggplot2)
library(tidyverse)
library(gghighlight)
library(patchwork)
library(ggpubr)

#these codes need to be run after all stata codes have run
#and the csv files for the spacifiaction reults and 
# csv files for estimates on nullfied outcomes are ready

#set woring directory
#setwd("C:/Users/bardi/Dropbox/Children in State Care/Revision/specification curve analysis")


#for outcome index
#read in data
model_results<-as_tibble(t(read_csv("sca_reg_results_outcome_index.csv", col_select=-1)))

#drop the unneccesseary var
model_results<- model_results %>% select(-V2)
#remove = and "

model_results <- model_results %>%
  mutate(across(everything(), ~ gsub('^=|"', '', .)))

#rename
model_results <- model_results %>%
  rename(
    modelname = V1,
    estimate = V3,
    std.error = V4,
    p.value = V5,
    conf.low = V6,
    conf.high = V7,
    N = V8
    
  )

model_results <- model_results %>%
  mutate(
    estimate = as.numeric(estimate),
    std.error = as.numeric(std.error),
    p.value = as.numeric(p.value),
    conf.low = as.numeric(conf.low),
    conf.high = as.numeric(conf.high),
    N = as.numeric(N)
  )

model_results <- model_results %>%
  mutate(
    outcome = case_when(
      str_detect(modelname, "o1") ~ "mean of all",
      str_detect(modelname, "o2") ~ "mean w/o fertility",
      str_detect(modelname, "o3") ~ "pca w/o fertility",
      TRUE ~ NA_character_  # For cases where neither "lpm" nor "pr" is found
    )
  )

model_results <- model_results %>%
  mutate(
    agemax = case_when(
      str_detect(modelname, "19") ~ 19,
      str_detect(modelname, "18") ~ 18,
      str_detect(modelname, "20") ~ 20,
      TRUE ~ NA_real_  # For cases where none of these values are found
    )
  )

model_results <- model_results %>%
  mutate(
    group = case_when(
      str_detect(modelname, "fs") ~ "full sample",
      str_detect(modelname, "ol") ~ "overlap",
      str_detect(modelname, "sn") ~ "no sn",
      TRUE ~ NA_character_  # For cases where none of these values are found
    )
  )

model_results <- model_results %>%
  mutate(
    controls = case_when(
      str_detect(modelname, "c1") ~ "full set",
      str_detect(modelname, "c2") ~ "baseline+behavior",
      str_detect(modelname, "c3") ~ "behavior",
      TRUE ~ NA_character_  # In case none of the conditions match
    )
  )

model_results <- model_results %>%
  mutate(
    sample = case_when(
      str_detect(modelname, "just6") ~ "just 6th grade home type",
      TRUE ~ "home type does not change"
    )
  )


model_results <- model_results %>%
  filter(!is.na(agemax))


# Add a significance column based on the p-value
model_results <- model_results %>%
  mutate(significance = ifelse(p.value < 0.05, "Significant", "Not Significant"))

# Order the models by the size of the estimates
model_results <- model_results %>%
  arrange(desc(-abs(estimate))) %>%
  mutate(x=row_number())# Order by the absolute value of estimates

  
  # Add a new column to identify the rows meeting the highlight condition
  model_results$highlight <- ifelse(
    model_results$sample == "home type does not change"   &
      model_results$group == "full sample" &
      model_results$agemax == 19 &
      model_results$controls == "full set" &
      model_results$outcome == "mean of all", 
    TRUE, 
    FALSE
  )
  
  highlight_rect<-model_results%>%filter(highlight==TRUE)
  
  top <- ggplot(model_results, aes(x = x, y = estimate)) +
    geom_rect(data = highlight_rect,
              aes(xmin = x - 0.5, xmax = x + 0.5, ymin = -Inf, ymax = Inf),
              color = NA, fill = "lightblue", alpha = 0.5) +
    geom_point(aes(color = significance), size = 2) +  # Make the points smaller (size = 2)
    geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2, color = "grey") +  # Confidence intervals in grey
    scale_color_manual(values = c("Significant" = "red", "Not Significant" = "grey")) +# Color by significance
    theme_minimal() +
    labs(x = "", y = "Estimate", color = "Statistical Significance at 5%") +
    theme(axis.text.x = element_blank()) + #angle = 45, hjust = 1)) +
    guides(color = "none") + 
    geom_hline(yintercept = 0, linetype = "dashed", color = "black")
  
  # Display the plot
  print(top)
  
  bottom_panel<-model_results %>%
    gather(variable, value, sample, group, agemax, controls, outcome) %>%
    mutate(variable=factor(variable, levels=c("sample", "group", "agemax", "controls", "outcome")))
  
  highlight_rect<-bottom_panel%>%filter(highlight==TRUE)
  
  # Bottom plot
  bottom <-  bottom_panel%>% 
    ggplot(aes(x = x, y = value, color = significance)) +
    geom_rect(data = highlight_rect,
              aes(xmin = x - 0.5, xmax = x + 0.5, ymin = -Inf, ymax = Inf),
              color = NA, fill = "lightblue", alpha = 0.5) +
    geom_point(aes(x = x, y = value), shape = 124, size = 3) +
    facet_grid(variable ~ 1, scales = "free_y", space = "free_y") +
    scale_color_manual(values = c("Significant" = "red", "Not Significant" = "grey")) + 
    labs(x = "\nSpecification number", y = "") + 
    theme_minimal() +
    theme(strip.text.x = element_blank(), legend.position = "none")
  
  # Display the bottom plot
  print(bottom)
  
  
spaplot<-plot_grid(top, bottom, ncol = 1, align = "v", axis = "lr", rel_heights = c(0.5, 1))


ggsave("plot_sca_reg_results_outcome_index.png", spaplot, height = 6, width = 8, units = "in")

summary(model_results$estimate)
model_results %>%
  summarise(share = mean(significance == "Significant"))


#read in function
#model_results<-as_tibble(t(read_csv("sca_reg_results_ever_mental_problem.csv", col_select=-1)))
#model_results<-as_tibble(t(read_csv("sca_reg_results_ever_birth.csv", col_select=-1)))
#model_results<-as_tibble(t(read_csv("sca_reg_results_ever_abort.csv", col_select=-1)))
#model_results<-as_tibble(t(read_csv("sca_reg_results_neet_6m.csv", col_select=-1)))
model_results<-as_tibble(t(read_csv("sca_reg_results_secondary_finished.csv", col_select=-1)))


process_data <- function(file_path){
  
  #read in data
  model_results<-as_tibble(t(read_csv(file_path, col_select=-1)))
  
  #drop the unneccesseary var
  model_results<- model_results %>% select(-V2)
  #remove = and "
  
  model_results <- model_results %>%
    mutate(across(everything(), ~ gsub('^=|"', '', .)))
  
  #rename
  model_results <- model_results %>%
    rename(
      modelname = V1,
      estimate = V3,
      std.error = V4,
      p.value = V5,
      conf.low = V6,
      conf.high = V7,
      N = V8
      
    )
  
  model_results <- model_results %>%
    mutate(
      estimate = as.numeric(estimate),
      std.error = as.numeric(std.error),
      p.value = as.numeric(p.value),
      conf.low = as.numeric(conf.low),
      conf.high = as.numeric(conf.high),
      N = as.numeric(N)
    )
  
  model_results <- model_results %>%
    mutate(
      model = case_when(
        str_detect(modelname, "lpm") ~ "lpm",
        str_detect(modelname, "pr") ~ "probit",
        TRUE ~ NA_character_  # For cases where neither "lpm" nor "pr" is found
      )
    )
  
  model_results <- model_results %>%
    mutate(
      agemax = case_when(
        str_detect(modelname, "19") ~ 19,
        str_detect(modelname, "18") ~ 18,
        str_detect(modelname, "20") ~ 20,
        TRUE ~ NA_real_  # For cases where none of these values are found
      )
    )
  
  model_results <- model_results %>%
    mutate(
      group = case_when(
        str_detect(modelname, "fs") ~ "full sample",
        str_detect(modelname, "ol") ~ "overlap",
        str_detect(modelname, "sn") ~ "no sni",
        TRUE ~ NA_character_  # For cases where none of these values are found
      )
    )
  
  model_results <- model_results %>%
    mutate(
      controls = case_when(
        str_detect(modelname, "c1") ~ "full set",
        str_detect(modelname, "c2") ~ "baseline+behavior",
        str_detect(modelname, "c3") ~ "behavior",
        TRUE ~ NA_character_  # In case none of the conditions match
      )
    )
  
  model_results <- model_results %>%
    mutate(
      sample = case_when(
        str_detect(modelname, "just6") ~ "just 6th grade home type",
        TRUE ~ "home type does not change"
      )
    )
  
  
  model_results <- model_results %>%
    filter(!is.na(agemax))
  
  
  # Add a significance column based on the p-value
  model_results <- model_results %>%
    mutate(significance = ifelse(p.value < 0.05, "Significant", "Not Significant"))
  
  # Order the models by the size of the estimates
  model_results <- model_results %>%
    arrange(desc(-abs(estimate))) %>%
    mutate(x=row_number())# Order by the absolute value of estimates
  return(model_results)
}


spa_plot<-function(model_results){
  
  # Add a new column to identify the rows meeting the highlight condition
  model_results$highlight <- ifelse(
    model_results$sample == "home type does not change"   &
      model_results$group == "full sample" &
      model_results$agemax == 19 &
      model_results$controls == "full set" &
      model_results$model == "lpm", 
    TRUE, 
    FALSE
  )
  
  highlight_rect<-model_results%>%filter(highlight==TRUE)
  
  top <- ggplot(model_results, aes(x = x, y = estimate)) +
    geom_rect(data = highlight_rect,
              aes(xmin = x - 0.5, xmax = x + 0.5, ymin = -Inf, ymax = Inf),
              color = NA, fill = "lightblue", alpha = 0.5) +
    geom_point(aes(color = significance), size = 2) +  # Make the points smaller (size = 2)
    geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.2, color = "grey") +  # Confidence intervals in grey
    scale_color_manual(values = c("Significant" = "red", "Not Significant" = "grey")) +# Color by significance
    theme_minimal() +
    labs(x = "", y = "Estimate", color = "Statistical Significance at 5%") +
    theme(axis.text.x = element_blank()) + #angle = 45, hjust = 1)) +
    guides(color = "none") + 
    geom_hline(yintercept = 0, linetype = "dashed", color = "black")
  
  # Display the plot
  print(top)
  
  bottom_panel<-model_results %>%
    gather(variable, value, sample, group, agemax, controls, model) %>%
    mutate(variable=factor(variable, levels=c("sample", "group", "agemax", "controls", "model")))
  
  highlight_rect<-bottom_panel%>%filter(highlight==TRUE)
  
  # Bottom plot
  bottom <-  bottom_panel%>% 
    ggplot(aes(x = x, y = value, color = significance)) +
    geom_rect(data = highlight_rect,
              aes(xmin = x - 0.5, xmax = x + 0.5, ymin = -Inf, ymax = Inf),
              color = NA, fill = "lightblue", alpha = 0.5) +
    geom_point(aes(x = x, y = value), shape = 124, size = 3) +
    facet_grid(variable ~ 1, scales = "free_y", space = "free_y") +
    scale_color_manual(values = c("Significant" = "red", "Not Significant" = "grey")) + 
    labs(x = "\nSpecification number", y = "") + 
    theme_minimal() +
    theme(strip.text.x = element_blank(), legend.position = "none")
  
  # Display the bottom plot
  print(bottom)
  
  
  spaplot<-plot_grid(top, bottom, ncol = 1, align = "v", axis = "lr", rel_heights = c(0.4, 1))
  return(spaplot)
  
}

#print


get_med_stats <- function(model_results) {
  median_effect <- summary(model_results$estimate)[["Median"]]
  
  share_sig <- model_results %>%
    summarise(share = mean(significance == "Significant")) %>%
    pull(share)  # get the numeric value out of the data frame
  
  return(list(
    median_effect = median_effect,
    share_significant = share_sig
  ))
}


##############################################################################
#run for all
###########################################################################

model_results_oi <- process_data("sca_reg_results_outcome_index.csv")

get_med_stats(model_results_oi)

model_results_sf <- process_data("sca_reg_results_secondary_finished.csv")

get_med_stats(model_results_sf)

model_results_mp <- process_data("sca_reg_results_ever_mental_problem.csv")

get_med_stats(model_results_mp)

model_results_b <- process_data("sca_reg_results_ever_birth.csv")

get_med_stats(model_results_b)

model_results_a <- process_data("sca_reg_results_ever_abort.csv")

get_med_stats(model_results_a)

model_results_n <- process_data("sca_reg_results_neet_6m.csv")

get_med_stats(model_results_n)

files <- c("sca_reg_results_secondary_finished.csv", 
           "sca_reg_results_ever_mental_problem.csv", 
           "sca_reg_results_neet_6m.csv",
           "sca_reg_results_ever_birth.csv", 
           "sca_reg_results_ever_abort.csv")

# Initialize an empty list to store the plots
plots <- list()

# Loop over the files
for (file in files) {
  # Process the data
  model_results <- process_data(file)
  
  
  #show the stats
  get_med_stats(model_results)
  
  # Generate the plot
  myplot <- spa_plot(model_results)
  
  # Store the plot in the list (using the file name without '.csv' as the key)
  plots[[file]] <- myplot
  
  # Ensure that file name is valid (no special characters or spaces)
  clean_filename <- gsub(".csv$", "", file)  # Remove the .csv extension
  clean_filename <- gsub("[[:space:]]", "_", clean_filename)  # Replace spaces with underscores
  
  # Save the plot with the clean filename
  ggsave(paste0("plot_", clean_filename, ".png"), myplot, height = 6, width = 8, units = "in")
  # Or print the plot (optional)
  print(myplot)
}


# fubction to process
get_stats_for_file <- function(file_name) {
  model_results_eb <- process_data(file_name)
  stats <- get_med_stats(model_results_eb)
  return(c(file = file_name, stats))
}


# Define function to readn in and process null results
process_bootstrap <- function(file_prefix) {
  # Create filenames
  file_names <- paste0(file_prefix, "_0_", 1:500, ".csv")
  
  # Read and process each file
  all_results <- lapply(file_names, get_stats_for_file)
  results_df <- do.call(rbind, lapply(all_results, as.data.frame))
  
  #get original results
  model_results <- process_data(paste0(file_prefix, ".csv"))
  
  # Compare to benchmark
  results_df <- results_df %>%
    mutate(
      share_larger_med_effect = if_else(median_effect <= get_med_stats(model_results)$median_effect, 1, 0),
      share_sig = if_else(share_significant >= get_med_stats(model_results)$share_significant, 1, 0)
    )
  
  # Return the means as a tibble
  tibble(
    file_prefix = file_prefix,
    mean_share_sig = mean(results_df$share_sig, na.rm = TRUE),
    mean_share_larger_med_effect = mean(results_df$share_larger_med_effect, na.rm = TRUE)
  )
}


#note that share smaller is calculated
secondary_results<-process_bootstrap("sca_reg_results_secondary_finished")
mp_results<-process_bootstrap("sca_reg_results_ever_mental_problem")
birth_results<-process_bootstrap("sca_reg_results_ever_birth")
abort_results<-process_bootstrap("sca_reg_results_ever_abort")
neet_results<-process_bootstrap("sca_reg_results_neet_6m")
oi_results<-process_bootstrap("sca_reg_results_outcome_index")

