import pandas as pd

raw_data = '~/Documents/SIE/01_raw_data/'

# read round 1.1 data
r1w1 = pd.read_csv(raw_data+'sie_w1.csv', encoding='ISO-8859-1')
print(r1w1.info())
print(r1w1)