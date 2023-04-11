from sentence_transformers import SentenceTransformer, LoggingHandler
from sentence_transformers import models, util, datasets, evaluation, losses
from torch.utils.data import DataLoader
import pandas as pd
import numpy as np
import math

def to_string(s):
  return ",".join(map(str,s))

# RISK ACTION ----

data = p.read_csv("1_data/td_data_coded_1000.csv")

# get texts
crnt = data.loc[:,"decision_text_crnt"].values
past = data.loc[:,"decision_text_past"].values
all = np.append(crnt, past).tolist()
all_no_nan = [str(x) for x in all if not pd.isna(x)]

# Define your sentence transformer model using CLS pooling
model_name = 'all-mpnet-base-v2'
model = SentenceTransformer(model_name)

# Create the special denoising dataset that adds noise on-the-fly
train_dataset = datasets.DenoisingAutoEncoderDataset(np.unique(all_no_nan))

# DataLoader to batch your data
train_dataloader = DataLoader(train_dataset, batch_size=8, shuffle=True)

# Use the denoising auto-encoder loss
train_loss = losses.MultipleNegativesRankingLoss(model)

# write original embedding
embedding = model.encode(all_no_nan)
with open('1_data/mpnet.txt','w') as f:
    for i in range(len(embedding)):
        f.write(all_no_nan[i] + "@@@" + to_string((embedding[i]).tolist()) + "\n")

# Call the fit method
model.fit(
    train_objectives=[(train_dataloader, train_loss)],
    epochs=1,
    weight_decay=0,
    scheduler='constantlr',
    optimizer_params={'lr': 3e-5},
    show_progress_bar=True)

# write adapted embedding
embedding = model.encode(all_no_nan)
with open('1_data/mpnet_simcse.txt','w') as f:
    for i in range(len(embedding)):
        f.write(all_no_nan[i] + "@@@" + to_string((embedding[i]).tolist()) + "\n")
        


