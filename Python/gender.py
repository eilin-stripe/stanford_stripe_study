import pandas as pd 

combdata = '~/Documents/SIE/01_raw_data/Combined.dta'

df = pd.read_stata(combdata)

##############################
# 1. Do women start smaller?
##############################

print(df['StartingFunding'].value_counts())

# less than 5k
df['start5k'] = (df['StartingFunding'] == 2).astype(int)
print(df['start5k'].value_counts())