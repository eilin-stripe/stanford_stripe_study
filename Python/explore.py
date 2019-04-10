###########
## SETUP ##
###########
import pandas as pd
import numpy as np
import re


#################
## Data Import ##
#################
base = '../'
stripe = pd.read_csv(base + 'Data/stripe_us_merchant_sample.csv')

# Replace all string missing values with actual missing values
stripe = stripe.replace('null', np.nan)

# Remove any country columns since this data is US only
no_country_cols = [col for col in stripe.columns if 'country' in col]
stripe = stripe[no_country_cols]

# Remove lengthy prefixes for easier analysis
stripe = stripe.rename(columns=lambda x: re.sub('unified_funnel__','',x))
stripe = stripe.rename(columns=lambda x: re.sub('unified__','',x))
stripe = stripe.rename(columns=lambda x: re.sub('legal_entity__','',x))



