# libraries
library(dplyr)
library(tidyr)
library(tidyverse)

#read in the data

df <- read.csv("/Users/bovickraha/Downloads/Project_r/Electric_Vehicle_Population_Data.csv")

# ----------------------------------------------------
# Tesla Executive Briefing: Electric Vehicle Analysis
# ----------------------------------------------------
# Project Summary:
# This project analyzes electric vehicle (EV) data in Washington State.
# The main goals:
# 1. Calculate Tesla's market share.
# 2. Identify top-selling Tesla models and estimate revenue.
# 3. Compare Tesla vs competitors on range and MSRP (avg/median).
# 4. Analyze PHEV vs BEV trends over time.
# 5. Identify top electric utility providers for Tesla owners.


# Data Cleaning
clean_df <- df %>% 
  rename_all(~ gsub("\\.", "_", .)) %>% ## Replace dots in column names with underscores
  mutate(
    Base.MSRP = as.numeric(Base_MSRP),
    Tesla = ifelse(Make == "TESLA", "TESLA", "OTHER")
  )

# 1. What percentage of EVs in Washington are Teslas? -tesla/all Vehicles * 100

total_vehicles <- nrow(clean_df)
tesla_vehicles <- clean_df %>% filter(Tesla == "TESLA") %>% nrow()

tesla_market_share <- round(tesla_vehicles/total_vehicles * 100, 1)


#2. Top Tesla models selling in the area
#- How much are we making from these models?

make_model_sold <- clean_df %>% 
  filter(Tesla == "TESLA") %>% 
  group_by(Make, Model) %>% 
  summarise(count_sold = n(), .groups = "drop") %>% 
  arrange(desc(count_sold))

msrp_by_year <- clean_df %>% 
  filter(Base_MSRP > 0) %>% 
  filter(Tesla == "TESLA") %>% 
  group_by(Model_Year, Make, Model) %>%
  summarise(min(Base_MSRP)) %>% 
  arrange(Model_Year, Make, Model)

#There weren't good data base msrp in this dataset - supplementing with online data

df_tesla_prices <- read.csv("/Users/bovickraha/Downloads/Project_r/Tesla_Current_Base_Prices.csv")

#transform Data to upper
df_tesla_prices <- df_tesla_prices %>% 
 mutate(Model = toupper(Model)
         )


Top_Tesla_Models_Priced <- make_model_sold  %>% 
  left_join(df_tesla_prices, by = "Model") %>% 
  mutate(
   Estimate_revenue = as.numeric(count_sold) * as.numeric(Base_Price_USD)
  )

# Final Estimates for Lifetime Sales
Top_Tesla_Models_Priced <- Top_Tesla_Models_Priced %>% 
  filter(!is.na(Estimate_revenue)) %>% 
  group_by(Model) %>% 
  slice_min(Base_Price_USD) %>% 
  ungroup

# 3. Tesla vs Competitors - Range and MSRP
# - AVG and Median

#AVG Range
Avg_range_for_evs <- clean_df %>% 
  filter(Electric_Vehicle_Type == "Battery Electric Vehicle (BEV)",
         Electric_Range != 0,
         Base_MSRP != 0) %>% 
  group_by(Tesla) %>% 
  summarise(AVG_Range = mean(Electric_Range),
            AVG_MSRP = mean(Base_MSRP))
  
# Median Range
Median_range_for_evs <- clean_df %>% 
  filter(Electric_Vehicle_Type == "Battery Electric Vehicle (BEV)",
         Electric_Range != 0) %>% 
  group_by(Tesla) %>% 
  summarise(Median_Range = median(Electric_Range),
            Median_MSRP = median(Base_MSRP))

#MSRP Dta isn't fully populated and may skew results

#4. PHEV vs. BEV
bhev_vs_bev <- clean_df %>% 
  group_by(Model_Year, Electric_Vehicle_Type) %>% 
  summarise(Count = n(), .groups = "drop")

# 5. Top Electric Utilities in Washington for Tesla

Utilities_Count_for_Teslas <- clean_df %>% 
  filter(Tesla == "TESLA") %>% 
  group_by(Electric_Utility) %>% 
  summarise(Count = n(), .groups = "drop") %>% 
  arrange(desc(Count)) %>% 
  head(5)






